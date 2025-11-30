# Sprint Plan: Live Chat Feature

**Sprint Duration**: 2-3 weeks (10-15 working days)
**Story Points**: 68 points
**Priority**: MEDIUM
**Issue**: [#176](https://github.com/AnthonyWrather/e-commerce-rails7/issues/176)

---

## Executive Summary

This sprint implements a **real-time live chat system** using Action Cable (WebSockets) to enable customers to ask questions and administrators to provide support. The system includes conversation persistence, online status tracking, and a dedicated admin chat interface.

### Key Requirements (from Issue #176)

**Administrator Features**:
1. ✅ View all customer chats in a dashboard
2. ✅ See their own account details
3. ✅ Register as available/unavailable to answer questions
4. ✅ Respond to customer messages in real-time

**User Features**:
1. ✅ Start a chat with administration
2. ✅ See previous conversations (history)
3. ✅ See if administrators are online (availability indicator)

### Technical Challenges

1. **Real-time messaging** - Action Cable WebSocket implementation
2. **Conversation persistence** - Store messages in database
3. **Online status tracking** - Presence system for admins
4. **User authentication** - Both User and AdminUser need chat access
5. **Unread message counts** - Track new messages per conversation
6. **Security** - Prevent cross-user message access, XSS protection

---

## Architecture & Design Decisions

### 1. Data Models

#### Conversation Model

```ruby
# app/models/conversation.rb
class Conversation < ApplicationRecord
  has_paper_trail  # Audit conversation changes

  belongs_to :user
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :admin_users, through: :conversation_participants

  enum status: { open: 0, active: 1, resolved: 2, closed: 3 }

  validates :user_id, presence: true
  validates :status, presence: true

  scope :recent, -> { order(updated_at: :desc) }
  scope :unresolved, -> { where(status: [:open, :active]) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_admin, ->(admin_user_id) {
    joins(:conversation_participants).where(conversation_participants: { admin_user_id: admin_user_id })
  }

  def unread_messages_for(participant)
    messages.where('created_at > ?', participant.last_read_at || created_at)
  end

  def latest_message
    messages.order(created_at: :desc).first
  end

  def participant_for(admin_user)
    conversation_participants.find_by(admin_user: admin_user)
  end
end
```

**Fields**:
- `user_id` (bigint, indexed) - Customer who started chat
- `status` (integer, enum) - open, active, resolved, closed
- `subject` (string, optional) - Brief topic/summary
- `last_message_at` (datetime, indexed) - For sorting conversations
- `timestamps` - created_at, updated_at

**Status Flow**:
- `open` - Customer started, no admin response yet
- `active` - Admin has joined conversation
- `resolved` - Admin marked as resolved (customer can reopen)
- `closed` - Permanently closed (no reopening)

---

#### Message Model

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation, touch: :last_message_at
  belongs_to :sender, polymorphic: true  # User or AdminUser

  validates :content, presence: true, length: { maximum: 5000 }
  validates :sender_type, inclusion: { in: %w[User AdminUser] }

  scope :recent, -> { order(created_at: :asc) }
  scope :unread_for, ->(participant) {
    where('created_at > ?', participant.last_read_at || Time.at(0))
  }

  after_create_commit :broadcast_message
  after_create_commit :update_conversation_timestamp

  def sender_name
    sender.try(:full_name) || sender.try(:email) || 'Unknown'
  end

  def sender_type_class
    sender_type == 'AdminUser' ? 'admin' : 'user'
  end

  private

  def broadcast_message
    ConversationChannel.broadcast_to(
      conversation,
      message: MessagesController.render(partial: 'messages/message', locals: { message: self }),
      sender_id: sender.id,
      sender_type: sender_type
    )
  end

  def update_conversation_timestamp
    conversation.update_column(:last_message_at, created_at)
  end
end
```

**Fields**:
- `conversation_id` (bigint, indexed) - Parent conversation
- `sender_id` (bigint, indexed) - User or AdminUser ID
- `sender_type` (string, indexed) - 'User' or 'AdminUser'
- `content` (text, required) - Message body (max 5000 chars)
- `read_at` (datetime, nullable) - When recipient read message
- `timestamps` - created_at, updated_at

**Composite Index**: `[conversation_id, created_at]` for fast message retrieval

---

#### ConversationParticipant Model

```ruby
# app/models/conversation_participant.rb
class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :admin_user

  validates :admin_user_id, uniqueness: { scope: :conversation_id }

  scope :active, -> { where(active: true) }

  def mark_as_read!
    update!(last_read_at: Time.current)
  end

  def unread_count
    conversation.messages.where('created_at > ?', last_read_at || conversation.created_at).count
  end
end
```

**Fields**:
- `conversation_id` (bigint, indexed) - Parent conversation
- `admin_user_id` (bigint, indexed) - Admin assigned to conversation
- `last_read_at` (datetime, nullable) - Last time admin read messages
- `active` (boolean, default: true) - Admin still assigned
- `timestamps` - created_at, updated_at

**Purpose**: Tracks which admins are handling which conversations and their read status.

---

#### AdminPresence Model

```ruby
# app/models/admin_presence.rb
class AdminPresence < ApplicationRecord
  belongs_to :admin_user

  validates :admin_user_id, uniqueness: true
  validates :status, inclusion: { in: %w[online away offline] }

  scope :online, -> { where(status: 'online') }
  scope :available, -> { where(status: %w[online away]) }

  after_commit :broadcast_status_change

  def self.mark_online(admin_user)
    find_or_initialize_by(admin_user: admin_user).tap do |presence|
      presence.status = 'online'
      presence.last_seen_at = Time.current
      presence.save!
    end
  end

  def self.mark_offline(admin_user)
    find_by(admin_user: admin_user)&.update(status: 'offline', last_seen_at: Time.current)
  end

  private

  def broadcast_status_change
    PresenceChannel.broadcast_to(
      'all',
      admin_id: admin_user.id,
      status: status,
      admin_name: admin_user.email
    )
  end
end
```

**Fields**:
- `admin_user_id` (bigint, unique, indexed) - Admin user
- `status` (string, enum) - 'online', 'away', 'offline'
- `last_seen_at` (datetime, indexed) - Last activity timestamp
- `timestamps` - created_at, updated_at

---

### 2. Action Cable Channels

#### ConversationChannel

```ruby
# app/channels/conversation_channel.rb
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    # Authorization check
    if authorized_for_conversation?(conversation)
      stream_for conversation
      mark_presence_online if current_admin_user
    else
      reject
    end
  end

  def unsubscribed
    mark_presence_offline if current_admin_user
  end

  def speak(data)
    conversation = Conversation.find(params[:conversation_id])
    return unless authorized_for_conversation?(conversation)

    message = conversation.messages.create!(
      sender: current_user || current_admin_user,
      content: data['message']
    )

    # Mark conversation as active if admin sends first message
    conversation.update!(status: :active) if current_admin_user && conversation.open?
  end

  def typing(data)
    ConversationChannel.broadcast_to(
      Conversation.find(params[:conversation_id]),
      typing: true,
      sender_id: current_user&.id || current_admin_user&.id,
      sender_type: current_user ? 'User' : 'AdminUser'
    )
  end

  private

  def authorized_for_conversation?(conversation)
    (current_user && conversation.user_id == current_user.id) ||
    (current_admin_user && conversation.conversation_participants.exists?(admin_user: current_admin_user))
  end

  def mark_presence_online
    AdminPresence.mark_online(current_admin_user)
  end

  def mark_presence_offline
    AdminPresence.mark_offline(current_admin_user)
  end
end
```

---

#### PresenceChannel

```ruby
# app/channels/presence_channel.rb
class PresenceChannel < ApplicationCable::Channel
  def subscribed
    # Public channel for showing admin availability to customers
    stream_from 'presence_channel'

    # Broadcast current online admins
    AdminPresence.online.each do |presence|
      transmit(
        admin_id: presence.admin_user.id,
        status: presence.status,
        admin_name: presence.admin_user.email
      )
    end
  end

  def unsubscribed
    # Cleanup if needed
  end
end
```

---

### 3. Action Cable Connection

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_admin_user

    def connect
      self.current_user = find_verified_user
      self.current_admin_user = find_verified_admin_user

      reject_unauthorized_connection if current_user.nil? && current_admin_user.nil?
    end

    private

    def find_verified_user
      if (user_id = cookies.encrypted[:user_id])
        User.find_by(id: user_id)
      elsif (session_data = cookies.encrypted[Rails.application.config.session_options[:key]])
        user_id = session_data.dig('warden.user.user.key', 0, 0)
        User.find_by(id: user_id) if user_id
      end
    end

    def find_verified_admin_user
      if (session_data = cookies.encrypted[Rails.application.config.session_options[:key]])
        admin_user_id = session_data.dig('warden.user.admin_user.key', 0, 0)
        AdminUser.find_by(id: admin_user_id) if admin_user_id
      end
    end
  end
end
```

---

### 4. Controllers

#### User-Facing: ConversationsController

```ruby
# app/controllers/conversations_controller.rb
class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  def index
    @conversations = current_user.conversations.recent
  end

  def show
    @messages = @conversation.messages.recent
    @message = Message.new
  end

  def create
    @conversation = current_user.conversations.create!(
      status: :open,
      subject: conversation_params[:subject]
    )

    # Send initial message if provided
    if conversation_params[:initial_message].present?
      @conversation.messages.create!(
        sender: current_user,
        content: conversation_params[:initial_message]
      )
    end

    redirect_to conversation_path(@conversation), notice: 'Chat started. An administrator will respond shortly.'
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:subject, :initial_message)
  end
end
```

---

#### Admin-Facing: Admin::ConversationsController

```ruby
# app/controllers/admin/conversations_controller.rb
class Admin::ConversationsController < AdminController
  before_action :set_conversation, only: [:show, :assign, :resolve, :close]

  def index
    @conversations = Conversation.unresolved.recent
    @assigned_conversations = Conversation.for_admin(current_admin_user.id).recent
    @online_admins = AdminPresence.online.includes(:admin_user)
  end

  def show
    @messages = @conversation.messages.recent
    @message = Message.new

    # Create or update participant record
    @participant = @conversation.conversation_participants.find_or_create_by(
      admin_user: current_admin_user
    )
    @participant.mark_as_read!
  end

  def assign
    @conversation.conversation_participants.find_or_create_by(
      admin_user: current_admin_user
    )
    @conversation.update!(status: :active)

    redirect_to admin_conversation_path(@conversation), notice: 'Conversation assigned to you.'
  end

  def resolve
    @conversation.update!(status: :resolved)
    redirect_to admin_conversations_path, notice: 'Conversation marked as resolved.'
  end

  def close
    @conversation.update!(status: :closed)
    redirect_to admin_conversations_path, notice: 'Conversation closed.'
  end

  def toggle_availability
    presence = AdminPresence.find_or_initialize_by(admin_user: current_admin_user)
    presence.status = presence.status == 'online' ? 'offline' : 'online'
    presence.last_seen_at = Time.current
    presence.save!

    redirect_to admin_conversations_path, notice: "Status updated to #{presence.status}."
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
```

---

#### MessagesController (Shared)

```ruby
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user_or_admin!
  before_action :set_conversation
  before_action :authorize_conversation_access!

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user || current_admin_user

    if @message.save
      # Broadcasting handled by after_create_commit callback
      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def authorize_conversation_access!
    authorized = (current_user && @conversation.user_id == current_user.id) ||
                 (current_admin_user && @conversation.conversation_participants.exists?(admin_user: current_admin_user))

    redirect_to root_path, alert: 'Unauthorized' unless authorized
  end

  def authenticate_user_or_admin!
    unless user_signed_in? || admin_user_signed_in?
      redirect_to new_user_session_path, alert: 'Please sign in to continue.'
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
```

---

### 5. Stimulus Controllers (TypeScript)

#### chat_controller.ts

```typescript
// app/javascript/controllers/chat_controller.ts
import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["messages", "input", "form", "typingIndicator"]
  static values = {
    conversationId: Number,
    currentUserId: Number,
    currentUserType: String
  }

  declare readonly messagesTarget: HTMLElement
  declare readonly inputTarget: HTMLInputElement
  declare readonly formTarget: HTMLFormElement
  declare readonly typingIndicatorTarget: HTMLElement

  declare conversationIdValue: number
  declare currentUserIdValue: number
  declare currentUserTypeValue: string

  subscription: any
  typingTimeout: number | null = null

  connect(): void {
    this.subscribeToConversation()
    this.scrollToBottom()
  }

  disconnect(): void {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToConversation(): void {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "ConversationChannel",
        conversation_id: this.conversationIdValue
      },
      {
        received: (data: any) => {
          if (data.message) {
            this.appendMessage(data.message)
          }
          if (data.typing && data.sender_id !== this.currentUserIdValue) {
            this.showTypingIndicator()
          }
        }
      }
    )
  }

  sendMessage(event: Event): void {
    event.preventDefault()

    const content = this.inputTarget.value.trim()
    if (!content) return

    this.subscription.perform("speak", { message: content })
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  handleTyping(): void {
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }

    this.subscription.perform("typing", {})

    this.typingTimeout = window.setTimeout(() => {
      // Stop typing indicator after 3 seconds
    }, 3000)
  }

  appendMessage(messageHTML: string): void {
    this.messagesTarget.insertAdjacentHTML("beforeend", messageHTML)
    this.scrollToBottom()
  }

  showTypingIndicator(): void {
    this.typingIndicatorTarget.classList.remove("hidden")
    setTimeout(() => {
      this.typingIndicatorTarget.classList.add("hidden")
    }, 3000)
  }

  scrollToBottom(): void {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
```

---

#### presence_controller.ts

```typescript
// app/javascript/controllers/presence_controller.ts
import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["indicator", "count"]

  declare readonly indicatorTarget: HTMLElement
  declare readonly countTarget: HTMLElement

  subscription: any
  onlineAdmins: Set<number> = new Set()

  connect(): void {
    this.subscribeToPresence()
  }

  disconnect(): void {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToPresence(): void {
    this.subscription = consumer.subscriptions.create(
      { channel: "PresenceChannel" },
      {
        received: (data: any) => {
          if (data.status === 'online') {
            this.onlineAdmins.add(data.admin_id)
          } else {
            this.onlineAdmins.delete(data.admin_id)
          }
          this.updateIndicator()
        }
      }
    )
  }

  updateIndicator(): void {
    const count = this.onlineAdmins.size
    this.countTarget.textContent = count.toString()

    if (count > 0) {
      this.indicatorTarget.classList.add("online")
      this.indicatorTarget.classList.remove("offline")
    } else {
      this.indicatorTarget.classList.add("offline")
      this.indicatorTarget.classList.remove("online")
    }
  }
}
```

---

### 6. Routing Strategy

```ruby
# config/routes.rb

# Customer chat routes
authenticated :user do
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end

# Admin chat routes
namespace :admin do
  resources :conversations, only: [:index, :show] do
    member do
      post :assign
      patch :resolve
      patch :close
    end
  end

  post 'toggle_availability', to: 'conversations#toggle_availability'
end

# Mount Action Cable
mount ActionCable.server => '/cable'
```

**URL Structure**:
- `/conversations` - User's chat list
- `/conversations/:id` - User's chat view
- `/admin/conversations` - Admin chat dashboard
- `/admin/conversations/:id` - Admin chat view
- `/cable` - WebSocket endpoint

---

## Sprint Stories & Tasks

### Epic 1: Database & Models (Priority: HIGH)

#### Story 1.1: Create Conversation Model
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Create Conversation model with status tracking and user association.

**Acceptance Criteria**:
- ✅ Conversation model created with validations
- ✅ Enum status: open, active, resolved, closed
- ✅ Belongs to User
- ✅ Has many Messages
- ✅ Scopes for filtering conversations
- ✅ PaperTrail auditing enabled
- ✅ Tests for validations and associations

**Tasks**:
- [ ] Generate Conversation model
- [ ] Add status enum and validations
- [ ] Create `test/models/conversation_test.rb`
- [ ] Create `test/fixtures/conversations.yml`
- [ ] Run tests
- [ ] Run RuboCop

**Migration**:
```ruby
class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :subject
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, :status
    add_index :conversations, :last_message_at
    add_index :conversations, [:user_id, :status]
  end
end
```

---

#### Story 1.2: Create Message Model
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Create Message model with polymorphic sender (User or AdminUser).

**Acceptance Criteria**:
- ✅ Message model created
- ✅ Polymorphic sender (User or AdminUser)
- ✅ Belongs to Conversation
- ✅ Validations for content (max 5000 chars)
- ✅ Broadcasts message on create
- ✅ Tests for associations and broadcasting

**Tasks**:
- [ ] Generate Message model
- [ ] Add polymorphic sender association
- [ ] Add validations
- [ ] Add broadcast callback
- [ ] Create `test/models/message_test.rb`
- [ ] Create `test/fixtures/messages.yml`
- [ ] Run tests
- [ ] Run RuboCop

**Migration**:
```ruby
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, polymorphic: true, null: false
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, [:sender_type, :sender_id]
  end
end
```

---

#### Story 1.3: Create ConversationParticipant & AdminPresence Models
**Priority**: MEDIUM
**Story Points**: 5
**Assignee**: TBD

**Description**: Track admin assignments and online status.

**Acceptance Criteria**:
- ✅ ConversationParticipant model tracks admin assignments
- ✅ AdminPresence model tracks online/offline status
- ✅ Validations and scopes
- ✅ Tests for both models

**Tasks**:
- [ ] Generate ConversationParticipant model
- [ ] Generate AdminPresence model
- [ ] Add validations and scopes
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

**Migrations**:
```ruby
class CreateConversationParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :admin_user, null: false, foreign_key: true
      t.datetime :last_read_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :conversation_participants, [:conversation_id, :admin_user_id],
              unique: true, name: 'index_participants_on_conversation_and_admin'
  end
end

class CreateAdminPresences < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_presences do |t|
      t.references :admin_user, null: false, foreign_key: true, index: { unique: true }
      t.string :status, default: 'offline', null: false
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :admin_presences, :status
    add_index :admin_presences, :last_seen_at
  end
end
```

---

### Epic 2: Action Cable Setup (Priority: HIGH)

#### Story 2.1: Configure Action Cable Connection
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Set up Action Cable with user/admin authentication.

**Acceptance Criteria**:
- ✅ Connection identifies current_user and current_admin_user
- ✅ Warden session extraction working
- ✅ Unauthorized connections rejected
- ✅ Tests for connection authentication

**Tasks**:
- [ ] Update `app/channels/application_cable/connection.rb`
- [ ] Add Warden session extraction helpers
- [ ] Create `test/channels/application_cable/connection_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 2.2: Create ConversationChannel
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Implement WebSocket channel for real-time messaging.

**Acceptance Criteria**:
- ✅ Subscriptions authorized per conversation
- ✅ Speak action sends messages
- ✅ Typing action broadcasts typing indicator
- ✅ Messages broadcast to conversation subscribers
- ✅ Tests for channel actions

**Tasks**:
- [ ] Create `app/channels/conversation_channel.rb`
- [ ] Implement subscribed, unsubscribed, speak, typing actions
- [ ] Add authorization checks
- [ ] Create `test/channels/conversation_channel_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 2.3: Create PresenceChannel
**Priority**: MEDIUM
**Story Points**: 5
**Assignee**: TBD

**Description**: Broadcast admin online/offline status to customers.

**Acceptance Criteria**:
- ✅ PresenceChannel broadcasts admin status changes
- ✅ Customers see admin availability in real-time
- ✅ Tests for presence broadcasting

**Tasks**:
- [ ] Create `app/channels/presence_channel.rb`
- [ ] Implement subscribed action
- [ ] Create `test/channels/presence_channel_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

### Epic 3: Customer Chat Interface (Priority: HIGH)

#### Story 3.1: Conversations List View
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Display list of customer's conversations with status.

**Acceptance Criteria**:
- ✅ List view shows all conversations
- ✅ Displays latest message preview
- ✅ Shows unread message count
- ✅ Shows conversation status
- ✅ Styled with Tailwind

**Tasks**:
- [ ] Create `ConversationsController#index`
- [ ] Create view `app/views/conversations/index.html.erb`
- [ ] Add unread count badge
- [ ] Create `test/controllers/conversations_controller_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 3.2: Chat View with Real-Time Messages
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Real-time chat interface with message history and input.

**Acceptance Criteria**:
- ✅ Shows message history
- ✅ Real-time message updates via WebSocket
- ✅ Send message form
- ✅ Typing indicator
- ✅ Auto-scroll to latest message
- ✅ Styled with Tailwind

**Tasks**:
- [ ] Create `ConversationsController#show`
- [ ] Create view `app/views/conversations/show.html.erb`
- [ ] Create Stimulus controller `chat_controller.ts`
- [ ] Add WebSocket subscription
- [ ] Create `test/system/customer_chat_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 3.3: Start New Conversation
**Priority**: MEDIUM
**Story Points**: 5
**Assignee**: TBD

**Description**: Allow customers to start new chat conversations.

**Acceptance Criteria**:
- ✅ "Start Chat" button in navigation
- ✅ Modal or form to start conversation
- ✅ Optional subject field
- ✅ Initial message sent
- ✅ Redirects to conversation view

**Tasks**:
- [ ] Create `ConversationsController#create`
- [ ] Create form partial
- [ ] Add navigation link
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 3.4: Admin Availability Indicator
**Priority**: MEDIUM
**Story Points**: 5
**Assignee**: TBD

**Description**: Show customer if admins are online.

**Acceptance Criteria**:
- ✅ Green indicator when admins online
- ✅ Gray indicator when no admins online
- ✅ Shows count of online admins
- ✅ Updates in real-time

**Tasks**:
- [ ] Create `presence_controller.ts`
- [ ] Add presence indicator to chat view
- [ ] Subscribe to PresenceChannel
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

---

### Epic 4: Admin Chat Interface (Priority: HIGH)

#### Story 4.1: Admin Chat Dashboard
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Admin dashboard showing all conversations and assignments.

**Acceptance Criteria**:
- ✅ Two tabs: "All Conversations" and "My Conversations"
- ✅ Shows conversation status, user, last message
- ✅ Shows unread count per conversation
- ✅ Filter by status (open, active, resolved)
- ✅ Availability toggle button
- ✅ Styled with Tailwind

**Tasks**:
- [ ] Create `Admin::ConversationsController#index`
- [ ] Create view `app/views/admin/conversations/index.html.erb`
- [ ] Add filtering logic
- [ ] Add availability toggle
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 4.2: Admin Chat View
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Admin interface for responding to customer chats.

**Acceptance Criteria**:
- ✅ Shows full message history
- ✅ Real-time message updates
- ✅ Send message form
- ✅ Conversation actions (assign, resolve, close)
- ✅ Customer info sidebar
- ✅ Styled with Tailwind

**Tasks**:
- [ ] Create `Admin::ConversationsController#show`
- [ ] Create view `app/views/admin/conversations/show.html.erb`
- [ ] Reuse `chat_controller.ts` Stimulus controller
- [ ] Add conversation action buttons
- [ ] Create `test/system/admin_chat_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 4.3: Conversation Management Actions
**Priority**: MEDIUM
**Story Points**: 8
**Assignee**: TBD

**Description**: Admin actions to manage conversation lifecycle.

**Acceptance Criteria**:
- ✅ Assign conversation to self
- ✅ Resolve conversation (customer can reopen)
- ✅ Close conversation (permanent)
- ✅ Actions update status in real-time
- ✅ Confirmation for close action

**Tasks**:
- [ ] Implement `assign`, `resolve`, `close` actions
- [ ] Add confirmation modals
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

---

### Epic 5: Integration & Testing (Priority: HIGH)

#### Story 5.1: Navigation Links
**Priority**: MEDIUM
**Story Points**: 3
**Assignee**: TBD

**Description**: Add chat links to main navigation.

**Acceptance Criteria**:
- ✅ "Messages" link in user navigation (with unread count badge)
- ✅ "Chat" link in admin sidebar
- ✅ Links only visible to authenticated users

**Tasks**:
- [ ] Update `app/views/layouts/_navbar.html.erb`
- [ ] Update `app/views/layouts/admin.html.erb`
- [ ] Add unread count queries
- [ ] Create tests
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 5.2: Comprehensive Testing
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Write comprehensive tests for chat system.

**Acceptance Criteria**:
- ✅ Model tests (Conversation, Message, etc.)
- ✅ Controller tests (all controllers)
- ✅ Channel tests (ConversationChannel, PresenceChannel)
- ✅ System tests (full chat flows)
- ✅ Test coverage >80%

**Tasks**:
- [ ] Write model tests
- [ ] Write controller tests
- [ ] Write channel tests
- [ ] Write system tests
- [ ] Run all tests
- [ ] Run RuboCop

---

#### Story 5.3: Security Hardening
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: Ensure chat system is secure.

**Acceptance Criteria**:
- ✅ XSS protection (escape user input)
- ✅ CSRF protection for message creation
- ✅ Authorization checks on all actions
- ✅ Rate limiting on message creation
- ✅ SQL injection prevention (parameterized queries)

**Tasks**:
- [ ] Add HTML escaping in views
- [ ] Verify CSRF tokens
- [ ] Add authorization checks
- [ ] Configure Rack::Attack for chat endpoints
- [ ] Security audit
- [ ] Run tests
- [ ] Run RuboCop

---

## Testing Strategy

### Test Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Models (Conversation, Message, etc.) | 90%+ |
| Controllers (Conversations, Messages) | 80%+ |
| Channels (ConversationChannel, PresenceChannel) | 85%+ |
| System (Chat flows) | 70%+ |

### Key Test Scenarios

1. **Customer Starts Chat**
   - Customer creates conversation
   - Initial message sent
   - Admin sees new conversation in dashboard

2. **Admin Responds**
   - Admin assigns conversation
   - Admin sends message
   - Customer receives message in real-time

3. **Real-Time Updates**
   - Customer sends message → Admin sees it
   - Admin sends message → Customer sees it
   - Typing indicators work

4. **Conversation Status Flow**
   - open → active (admin joins)
   - active → resolved (admin resolves)
   - resolved → active (customer reopens)
   - active → closed (admin closes permanently)

5. **Admin Presence**
   - Admin goes online → Customers see indicator
   - Admin goes offline → Indicator updates
   - Multiple admins online → Count accurate

---

## Sprint Schedule (2-3 weeks)

### Week 1: Foundation (Epic 1 + Epic 2)
**Focus**: Database models and Action Cable setup

- **Day 1-2**: Story 1.1 - Create Conversation Model (8 pts)
- **Day 2-3**: Story 1.2 - Create Message Model (8 pts)
- **Day 3**: Story 1.3 - ConversationParticipant & AdminPresence (5 pts)
- **Day 4**: Story 2.1 - Configure Action Cable Connection (8 pts)
- **Day 5**: Story 2.2 - Create ConversationChannel (13 pts)

**Deliverables**: Database models, Action Cable channels working

---

### Week 2: Customer & Admin Interfaces (Epic 3 + Epic 4)
**Focus**: User-facing and admin chat UIs

- **Day 6**: Story 2.3 - Create PresenceChannel (5 pts)
- **Day 6-7**: Story 3.1 - Conversations List View (8 pts)
- **Day 7-8**: Story 3.2 - Chat View with Real-Time Messages (13 pts)
- **Day 9**: Story 3.3 - Start New Conversation (5 pts)
- **Day 9**: Story 3.4 - Admin Availability Indicator (5 pts)
- **Day 10**: Story 4.1 - Admin Chat Dashboard (13 pts)

**Deliverables**: Customers can chat, admins can see conversations

---

### Week 3: Admin Features & Testing (Epic 4 + Epic 5)
**Focus**: Admin conversation management, testing, polish

- **Day 11-12**: Story 4.2 - Admin Chat View (13 pts)
- **Day 12**: Story 4.3 - Conversation Management Actions (8 pts)
- **Day 13**: Story 5.1 - Navigation Links (3 pts)
- **Day 14**: Story 5.3 - Security Hardening (5 pts)
- **Day 14-15**: Story 5.2 - Comprehensive Testing (13 pts)

**Deliverables**: Full chat system, tested, secure, production-ready

---

## Definition of Done (DoD)

Each story is considered done when:

- [ ] Code implemented and follows Rails conventions
- [ ] Database migrations created and run
- [ ] Model validations and associations added
- [ ] Action Cable channels tested with subscriptions
- [ ] Stimulus controllers functional with WebSocket
- [ ] Views styled with Tailwind CSS
- [ ] Unit tests written and passing (>80% coverage)
- [ ] System tests written and passing (key flows)
- [ ] RuboCop passes with zero offenses
- [ ] All existing tests still passing (no regressions)
- [ ] Security review completed (XSS, CSRF, authorization)
- [ ] Documentation updated (if needed)

---

## Security Considerations

1. **WebSocket Authentication**
   - Action Cable connection verifies user/admin via Warden session
   - Unauthorized connections rejected immediately

2. **Authorization**
   - Customers can only access their own conversations
   - Admins can only access assigned conversations
   - Channel subscriptions authorized before streaming

3. **XSS Protection**
   - All user input HTML-escaped in views
   - Message content sanitized before rendering

4. **CSRF Protection**
   - Message creation via POST requires CSRF token
   - WebSocket actions don't bypass CSRF (connection authenticated)

5. **Rate Limiting**
   - Rack::Attack rules for message creation endpoints
   - Prevent spam: 60 messages per minute per user

6. **SQL Injection**
   - All queries use Active Record (parameterized)
   - No raw SQL with user input

7. **Sensitive Data**
   - Conversation history visible only to participants
   - Admin presence doesn't leak admin details

---

## Rollback Plan

If critical issues arise during sprint:

1. **Database Rollback**:
   ```bash
   rails db:rollback STEP=N
   ```

2. **Feature Toggle**:
   - Add `ENV['CHAT_ENABLED']` flag
   - Hide chat links if disabled

3. **Disable Action Cable**:
   - Comment out `mount ActionCable.server` in routes
   - Remove WebSocket subscriptions from frontend

4. **Data Integrity**:
   - Conversations and messages can be safely deleted
   - No impact on orders, products, or users

---

## Post-Sprint Enhancements (Future Work)

These are **NOT** included in this sprint but can be added later:

1. **File Attachments** (images, PDFs in chat)
2. **Chat Notifications** (email alerts for new messages)
3. **Chat History Export** (CSV download)
4. **Canned Responses** (admin quick replies)
5. **Chat Routing** (assign to specific admin based on topic)
6. **Customer Satisfaction Ratings** (thumbs up/down after resolution)
7. **Chat Analytics** (response times, resolution rates)
8. **Mobile Push Notifications** (PWA integration)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Customer Chat Adoption | 10% of logged-in users |
| Admin Response Time | <5 minutes average |
| Conversation Resolution Rate | >80% |
| Test Coverage | >80% overall |
| RuboCop Violations | 0 |
| WebSocket Connection Success | >98% |
| Message Delivery Latency | <1 second |

---

## Dependencies

- **External**: Redis (already configured for Action Cable)
- **Internal**: User model (already exists from user accounts sprint)
- **Blocking**: None (can start immediately)

---

## Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| WebSocket connection issues | Medium | High | Fallback to polling, extensive testing |
| Redis reliability | Low | High | Use managed Redis (Render, AWS ElastiCache) |
| Spam/abuse of chat | Medium | Medium | Rate limiting, admin moderation tools |
| Scaling (high message volume) | Low | Medium | Redis can handle 10k+ concurrent connections |
| Real-time sync bugs | Medium | Medium | Comprehensive system tests, manual QA |

---

## Sprint Retrospective Questions

Post-sprint evaluation:

1. Did real-time messaging work as expected?
2. Were there any WebSocket connection issues?
3. Is the admin chat interface intuitive?
4. Are there any security concerns?
5. What performance issues were discovered?
6. What documentation is missing?
7. What would we do differently next time?

---

## Conclusion

This sprint adds a **real-time live chat system** using Action Cable, enabling direct communication between customers and administrators. The dual-interface design (customer-facing chat + admin dashboard) provides a professional support experience while leveraging existing Rails infrastructure. With comprehensive testing and security hardening, we can deliver a production-ready chat feature in 2-3 weeks.

**Total Story Points**: 68
**Estimated Effort**: 2-3 weeks (10-15 days)
**Priority**: MEDIUM
**Risk Level**: MEDIUM (mitigated by existing Action Cable infrastructure)
