# Sprint Plan: User Accounts & Authentication

**Sprint Duration**: 3 weeks (15 working days)
**Story Points**: 89 points
**Priority**: MEDIUM-HIGH
**Issue**: [#186](https://github.com/AnthonyWrather/e-commerce-rails7/issues/186)

---

## Executive Summary

This sprint implements a **dual-mode customer account system** that preserves the existing guest checkout experience while adding optional user registration, authentication, and persistent cross-device cart functionality. The goal is to transition from session-token-based guest carts to user-owned carts without disrupting the current workflow.

### Key Requirements (from Issue #186)

1. ✅ **Preserve guest checkout** - No forced registration
2. ✅ **User registration** - Optional account creation
3. ✅ **Password reset** - Self-service password recovery
4. ✅ **Profile management** - Edit user details
5. ✅ **Cross-device carts** - Logged-in users see cart on all devices
6. ✅ **User profile fields**: Full name, telephone, email, company name

### Technical Challenges

1. **Cart ownership migration** - Cart currently uses `session_token`, needs optional `user_id`
2. **Guest → User transition** - Preserve guest cart when user logs in/registers
3. **Dual authentication** - AdminUser (Devise) + User (new Devise scope)
4. **Security** - Separate routes, sessions, and authentication for admin vs. customer users

---

## Architecture & Design Decisions

### 1. User Model Design

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_paper_trail  # Audit user changes

  # Devise modules
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable

  # Associations
  has_many :carts, dependent: :nullify
  has_many :addresses, dependent: :destroy
  has_one :primary_address, -> { where(primary: true) }, class_name: 'Address'

  # Validations
  validates :full_name, presence: true
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-()]+\z/ }
  validates :company_name, length: { maximum: 255 }, allow_blank: true

  # Methods
  def active_cart
    carts.active.order(updated_at: :desc).first || carts.create(session_token: SecureRandom.uuid)
  end
end
```

**Fields**:
- `email` (string, indexed, unique) - Primary identifier
- `encrypted_password` (string) - Devise encrypted password
- `full_name` (string, required) - Customer name
- `phone` (string, required) - Contact number
- `company_name` (string, optional) - B2B company name
- `reset_password_token`, `reset_password_sent_at` - Password recovery
- `remember_created_at` - Remember me functionality
- `confirmation_token`, `confirmed_at`, `confirmation_sent_at` - Email confirmation
- `timestamps` - created_at, updated_at

---

### 2. Cart Ownership Model

**Current State** (Guest Only):
```ruby
Cart.find_or_create_by(session_token: token)
# Cart belongs to no one, identified only by token
```

**New State** (Guest + User):
```ruby
# Guest cart (no user_id)
Cart.find_or_create_by(session_token: token, user_id: nil)

# User cart (has user_id)
user.active_cart  # Returns most recent active cart for user
```

**Schema Changes**:
```ruby
# Migration: add_user_id_to_carts
add_reference :carts, :user, foreign_key: true, index: true
add_index :carts, [:user_id, :expires_at]
```

**Cart Model Updates**:
```ruby
class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :guest, -> { where(user_id: nil) }

  def assign_to_user!(user)
    update!(user: user, session_token: SecureRandom.uuid)
  end
end
```

---

### 3. Guest → User Cart Transition

When a guest user registers or logs in, their cart must be preserved:

**Scenario 1: Registration**
```ruby
# app/controllers/users/registrations_controller.rb
def create
  super do |user|
    if user.persisted?
      # Transfer guest cart to new user
      guest_cart = Cart.find_by(session_token: cookies[:cart_token])
      if guest_cart
        guest_cart.assign_to_user!(user)
      end
    end
  end
end
```

**Scenario 2: Login (with existing cart)**
```ruby
# app/controllers/users/sessions_controller.rb
def create
  super do |user|
    guest_cart = Cart.find_by(session_token: cookies[:cart_token])
    user_cart = user.active_cart

    if guest_cart && guest_cart.cart_items.any?
      # Merge guest cart into user cart
      user_cart.merge_items!(guest_cart.cart_items)
      guest_cart.destroy
    end
  end
end
```

**Scenario 3: Logout**
```ruby
# Create new guest cart with fresh token
def destroy
  super do
    cookies[:cart_token] = SecureRandom.uuid
  end
end
```

---

### 4. Address Management

**Address Model**:
```ruby
# app/models/address.rb
class Address < ApplicationRecord
  belongs_to :user

  validates :full_name, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true, format: { with: /\A[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}\z/i }
  validates :country, presence: true
  validates :phone, presence: true

  scope :primary, -> { where(primary: true) }

  before_save :clear_other_primary, if: :primary?

  def full_address
    [address_line_1, address_line_2, city, county, postal_code, country].compact.join(', ')
  end

  private

  def clear_other_primary
    user.addresses.where.not(id: id).update_all(primary: false)
  end
end
```

**Fields**:
- `user_id` (bigint, indexed) - Foreign key
- `full_name` (string, required) - Recipient name
- `company_name` (string, optional) - Delivery company
- `address_line_1` (string, required)
- `address_line_2` (string, optional)
- `city` (string, required)
- `county` (string, optional)
- `postal_code` (string, required, validated UK format)
- `country` (string, required, default: 'GB')
- `phone` (string, required)
- `primary` (boolean, default: false) - One per user
- `timestamps`

---

### 5. Routing Strategy

**Namespaced Devise Routes**:
```ruby
# config/routes.rb

# Admin authentication (existing)
devise_for :admin_users, path: 'admin', controllers: {
  sessions: 'admin_users/sessions',
  passwords: 'admin_users/passwords',
  registrations: 'admin_users/registrations'
}

# Customer authentication (NEW)
devise_for :users, controllers: {
  sessions: 'users/sessions',
  passwords: 'users/passwords',
  registrations: 'users/registrations',
  confirmations: 'users/confirmations'
}

# Customer account dashboard
authenticated :user do
  resource :account, only: [:show, :edit, :update], controller: 'users/accounts'
  resources :addresses, only: [:index, :new, :create, :edit, :update, :destroy], controller: 'users/addresses'
  resources :orders, only: [:index, :show], controller: 'users/orders'
end
```

**URL Structure**:
- `/users/sign_in` - Customer login
- `/users/sign_up` - Customer registration
- `/users/password/new` - Password reset
- `/account` - User dashboard
- `/addresses` - Address book
- `/orders` - Order history

---

## Sprint Stories & Tasks

### Epic 1: Database & Models (Priority: HIGH)

#### Story 1.1: Create User Model with Devise
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Set up User model with Devise authentication and basic profile fields.

**Acceptance Criteria**:
- ✅ User model created with Devise modules
- ✅ Email confirmation enabled (`:confirmable`)
- ✅ Password reset enabled (`:recoverable`)
- ✅ Remember me enabled (`:rememberable`)
- ✅ Validations for full_name, phone, email
- ✅ PaperTrail auditing enabled
- ✅ Tests for validations (model test)

**Tasks**:
- [ ] Install Devise gem (if not already installed)
- [ ] Generate Devise User model: `rails g devise User`
- [ ] Add custom fields migration: `full_name`, `phone`, `company_name`
- [ ] Enable confirmable module in migration (confirmation_token, confirmed_at, etc.)
- [ ] Add validations to User model
- [ ] Add `has_paper_trail` for auditing
- [ ] Generate Devise views: `rails g devise:views users`
- [ ] Create `test/models/user_test.rb` with validation tests
- [ ] Create `test/fixtures/users.yml`
- [ ] Run tests and fix any errors
- [ ] Run RuboCop and fix any issues

**Migration**:
```ruby
class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      ## Custom fields
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :company_name

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
```

---

#### Story 1.2: Add user_id to Carts (Cart Ownership)
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: Modify Cart model to support both guest carts (session_token) and user carts (user_id).

**Acceptance Criteria**:
- ✅ Cart has optional `user_id` foreign key
- ✅ Cart `belongs_to :user, optional: true`
- ✅ User `has_many :carts`
- ✅ Scope: `Cart.for_user(user_id)`
- ✅ Scope: `Cart.guest` (user_id is nil)
- ✅ Method: `cart.assign_to_user!(user)`
- ✅ Tests for cart ownership

**Tasks**:
- [ ] Create migration: `add_user_id_to_carts`
- [ ] Add `belongs_to :user, optional: true` to Cart model
- [ ] Add `has_many :carts, dependent: :nullify` to User model
- [ ] Add scopes: `for_user`, `guest`
- [ ] Add method: `assign_to_user!(user)`
- [ ] Update `test/models/cart_test.rb`
- [ ] Run tests and fix any errors
- [ ] Run RuboCop

**Migration**:
```ruby
class AddUserIdToCarts < ActiveRecord::Migration[7.1]
  def change
    add_reference :carts, :user, foreign_key: true, index: true
    add_index :carts, [:user_id, :expires_at]
  end
end
```

---

#### Story 1.3: Create Address Model
**Priority**: MEDIUM
**Story Points**: 8
**Assignee**: TBD

**Description**: Create Address model for saving shipping/billing addresses.

**Acceptance Criteria**:
- ✅ Address model created
- ✅ Belongs to User
- ✅ Validations for all required fields
- ✅ UK postcode validation
- ✅ Primary address logic (one per user)
- ✅ Tests for validations and primary address

**Tasks**:
- [ ] Generate Address model
- [ ] Add validations
- [ ] Add `primary` boolean field with uniqueness per user
- [ ] Add `before_save` callback to clear other primary addresses
- [ ] Create `test/models/address_test.rb`
- [ ] Create `test/fixtures/addresses.yml`
- [ ] Run tests
- [ ] Run RuboCop

**Migration**:
```ruby
class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :company_name
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :county
      t.string :postal_code, null: false
      t.string :country, null: false, default: 'GB'
      t.string :phone, null: false
      t.boolean :primary, default: false, null: false

      t.timestamps
    end

    add_index :addresses, [:user_id, :primary]
  end
end
```

---

### Epic 2: Authentication & Registration (Priority: HIGH)

#### Story 2.1: User Registration Flow
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Implement user registration with email confirmation and guest cart transfer.

**Acceptance Criteria**:
- ✅ Registration form with full_name, phone, company_name, email, password
- ✅ Email confirmation sent on registration
- ✅ Guest cart transferred to new user
- ✅ Tailwind-styled registration page (consistent with admin login)
- ✅ Tests for registration flow
- ✅ System tests for registration UI

**Tasks**:
- [ ] Generate custom Devise controllers: `rails g devise:controllers users`
- [ ] Override `RegistrationsController#create`
- [ ] Add guest cart transfer logic after user creation
- [ ] Style registration view (`app/views/users/registrations/new.html.erb`)
- [ ] Add company logo/branding
- [ ] Create `test/controllers/users/registrations_controller_test.rb`
- [ ] Create `test/system/user_registration_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Controller**:
```ruby
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  layout 'devise'

  def create
    super do |user|
      if user.persisted?
        transfer_guest_cart_to_user(user)
      end
    end
  end

  private

  def transfer_guest_cart_to_user(user)
    guest_cart = Cart.find_by(session_token: cookies[:cart_token])
    return unless guest_cart

    guest_cart.assign_to_user!(user)
    cookies[:cart_token] = nil
  end

  def sign_up_params
    params.require(:user).permit(:full_name, :phone, :company_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:full_name, :phone, :company_name, :email, :password, :password_confirmation, :current_password)
  end
end
```

---

#### Story 2.2: User Login/Logout with Cart Merge
**Priority**: HIGH
**Story Points**: 13
**Assignee**: TBD

**Description**: Implement user login with guest cart merging and logout with new guest cart creation.

**Acceptance Criteria**:
- ✅ Login form styled with Tailwind
- ✅ Guest cart merged into user cart on login
- ✅ New guest cart created on logout
- ✅ Remember me functionality
- ✅ Tests for login/logout flows
- ✅ System tests for login UI

**Tasks**:
- [ ] Override `SessionsController#create`
- [ ] Add cart merge logic after sign in
- [ ] Override `SessionsController#destroy`
- [ ] Add new guest cart token generation on logout
- [ ] Style login view (`app/views/users/sessions/new.html.erb`)
- [ ] Create `test/controllers/users/sessions_controller_test.rb`
- [ ] Create `test/system/user_login_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Controller**:
```ruby
# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  layout 'devise'

  def create
    super do |user|
      merge_guest_cart_with_user_cart(user)
    end
  end

  def destroy
    create_new_guest_cart_token
    super
  end

  private

  def merge_guest_cart_with_user_cart(user)
    guest_cart = Cart.find_by(session_token: cookies[:cart_token])
    return unless guest_cart && guest_cart.cart_items.any?

    user_cart = user.active_cart
    user_cart.merge_items!(guest_cart.cart_items.map(&:attributes))
    guest_cart.destroy
    cookies[:cart_token] = nil
  end

  def create_new_guest_cart_token
    cookies[:cart_token] = SecureRandom.uuid
  end
end
```

---

#### Story 2.3: Password Reset Flow
**Priority**: MEDIUM
**Story Points**: 8
**Assignee**: TBD

**Description**: Implement password reset (forgot password) functionality for users.

**Acceptance Criteria**:
- ✅ Forgot password form
- ✅ Reset password email sent
- ✅ Reset password form with new password
- ✅ Tailwind-styled views
- ✅ Tests for password reset flow

**Tasks**:
- [ ] Override `PasswordsController` if needed
- [ ] Style forgot password view (`app/views/users/passwords/new.html.erb`)
- [ ] Style reset password view (`app/views/users/passwords/edit.html.erb`)
- [ ] Configure mailer templates
- [ ] Create `test/controllers/users/passwords_controller_test.rb`
- [ ] Create `test/system/password_reset_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

### Epic 3: User Dashboard & Profile (Priority: MEDIUM)

#### Story 3.1: User Account Dashboard
**Priority**: MEDIUM
**Story Points**: 13
**Assignee**: TBD

**Description**: Create user account dashboard with profile view and edit functionality.

**Acceptance Criteria**:
- ✅ Dashboard shows user profile (full_name, email, phone, company_name)
- ✅ Edit profile functionality
- ✅ Password change functionality
- ✅ Tailwind-styled dashboard layout
- ✅ Tests for account controller

**Tasks**:
- [ ] Create `Users::AccountsController`
- [ ] Add `show` action (dashboard)
- [ ] Add `edit` action (profile edit form)
- [ ] Add `update` action (save profile changes)
- [ ] Create dashboard layout (`app/views/layouts/user_dashboard.html.erb`)
- [ ] Create views: `show.html.erb`, `edit.html.erb`
- [ ] Add navigation sidebar (Profile, Addresses, Orders)
- [ ] Create `test/controllers/users/accounts_controller_test.rb`
- [ ] Create `test/system/user_dashboard_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Controller**:
```ruby
# app/controllers/users/accounts_controller.rb
class Users::AccountsController < ApplicationController
  before_action :authenticate_user!
  layout 'user_dashboard'

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to account_path, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :phone, :company_name, :email, :current_password, :password, :password_confirmation)
  end
end
```

---

#### Story 3.2: Address Book Management
**Priority**: MEDIUM
**Story Points**: 13
**Assignee**: TBD

**Description**: Create address book CRUD interface for saved addresses.

**Acceptance Criteria**:
- ✅ List all addresses
- ✅ Add new address
- ✅ Edit existing address
- ✅ Delete address
- ✅ Set primary address
- ✅ Tests for address controller

**Tasks**:
- [ ] Create `Users::AddressesController`
- [ ] Add `index`, `new`, `create`, `edit`, `update`, `destroy` actions
- [ ] Add primary address toggle functionality
- [ ] Create views for all actions
- [ ] Style with Tailwind
- [ ] Create `test/controllers/users/addresses_controller_test.rb`
- [ ] Create `test/system/address_management_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Controller**:
```ruby
# app/controllers/users/addresses_controller.rb
class Users::AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy]
  layout 'user_dashboard'

  def index
    @addresses = current_user.addresses.order(primary: :desc, created_at: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      redirect_to addresses_path, notice: 'Address added successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: 'Address updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: 'Address deleted successfully.'
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:full_name, :company_name, :address_line_1, :address_line_2, :city, :county, :postal_code, :country, :phone, :primary)
  end
end
```

---

#### Story 3.3: Order History View
**Priority**: LOW
**Story Points**: 8
**Assignee**: TBD

**Description**: Display order history for logged-in users (read-only).

**Acceptance Criteria**:
- ✅ List all orders for current user
- ✅ Order details view
- ✅ Display order status (fulfilled/unfulfilled)
- ✅ Display order products with prices
- ✅ Tests for orders controller

**Tasks**:
- [ ] Add `user_id` to Order model (nullable for backward compatibility)
- [ ] Create migration: `add_user_id_to_orders`
- [ ] Update `OrderProcessor` service to assign user_id when creating order
- [ ] Create `Users::OrdersController`
- [ ] Add `index` and `show` actions
- [ ] Create views for order list and detail
- [ ] Create `test/controllers/users/orders_controller_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Migration**:
```ruby
class AddUserIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :user, foreign_key: true, index: true
  end
end
```

---

### Epic 4: Integration & Testing (Priority: HIGH)

#### Story 4.1: Update CheckoutController for User Association
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: Update checkout flow to use user cart when logged in.

**Acceptance Criteria**:
- ✅ Checkout uses `current_user.active_cart` if logged in
- ✅ Checkout uses guest cart (session_token) if not logged in
- ✅ Tests for both scenarios

**Tasks**:
- [ ] Modify `CheckoutsController#create` to detect logged-in user
- [ ] Use `current_user.active_cart` instead of session token cart
- [ ] Update `test/controllers/checkouts_controller_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 4.2: Update OrderProcessor for User Assignment
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: Assign orders to users when creating from Stripe webhook.

**Acceptance Criteria**:
- ✅ Order assigned to user if email matches existing user
- ✅ Order not assigned if no matching user found (guest order)
- ✅ Tests for user assignment

**Tasks**:
- [ ] Modify `OrderProcessor#create_order` to lookup user by email
- [ ] Assign `user_id` if user found
- [ ] Update `test/services/order_processor_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

**Code Change**:
```ruby
# app/services/order_processor.rb
def create_order
  user = User.find_by(email: customer_email)

  Order.create!(
    user: user,  # NEW: Assign user if found
    customer_email: customer_email,
    total: @stripe_session['amount_total'],
    # ... rest of attributes
  )
end
```

---

#### Story 4.3: Add Navigation Links for User Account
**Priority**: MEDIUM
**Story Points**: 3
**Assignee**: TBD

**Description**: Add user account links to main navigation.

**Acceptance Criteria**:
- ✅ Show "Login" and "Sign Up" links if not logged in
- ✅ Show "My Account" dropdown if logged in
- ✅ Dropdown includes: Dashboard, Addresses, Orders, Logout
- ✅ Styled with Tailwind

**Tasks**:
- [ ] Update `app/views/layouts/_navbar.html.erb`
- [ ] Add conditional logic for `user_signed_in?`
- [ ] Add Stimulus controller for dropdown toggle
- [ ] Update `test/system/navigation_test.rb`
- [ ] Run tests
- [ ] Run RuboCop

---

#### Story 4.4: Comprehensive Testing
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: Write comprehensive tests for all user authentication flows.

**Acceptance Criteria**:
- ✅ Model tests for User, Address
- ✅ Controller tests for all user controllers
- ✅ Integration tests for cart transfer/merge
- ✅ System tests for full registration/login flows
- ✅ Test coverage >80%

**Tasks**:
- [ ] Write model tests
- [ ] Write controller tests
- [ ] Write integration tests for cart logic
- [ ] Write system tests
- [ ] Run all tests
- [ ] Run RuboCop

---

## Testing Strategy

### Test Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Models (User, Address) | 90%+ |
| Controllers (Users::*) | 80%+ |
| Integration (Cart transfer/merge) | 85%+ |
| System (UI flows) | 70%+ |

### Key Test Scenarios

1. **Guest → User Registration**
   - Guest adds items to cart
   - Guest registers
   - Cart transferred to user
   - Items persist

2. **Guest → User Login**
   - Guest adds items to cart
   - User logs in with existing account
   - Guest cart merged into user cart
   - Items combined (quantities added)

3. **User → Guest Logout**
   - User logs out
   - New guest cart token created
   - Old user cart preserved

4. **Cross-Device Cart**
   - User logs in on Device A
   - Adds items to cart
   - User logs in on Device B
   - Same cart visible

5. **Address Management**
   - Create address
   - Set as primary
   - Edit address
   - Delete address (not if primary)

---

## Sprint Schedule (3 weeks)

### Week 1: Foundation (Epic 1 + Story 2.1)
**Focus**: Database models and user registration

- **Day 1-2**: Story 1.1 - Create User Model (8 pts)
- **Day 2-3**: Story 1.2 - Add user_id to Carts (5 pts)
- **Day 3-4**: Story 1.3 - Create Address Model (8 pts)
- **Day 4-5**: Story 2.1 - User Registration Flow (13 pts)

**Deliverables**: User can register, email confirmation sent, guest cart transferred

---

### Week 2: Authentication & Dashboard (Epic 2 + Epic 3)
**Focus**: Login/logout, password reset, user dashboard

- **Day 6-7**: Story 2.2 - Login/Logout with Cart Merge (13 pts)
- **Day 8**: Story 2.3 - Password Reset Flow (8 pts)
- **Day 9-10**: Story 3.1 - User Account Dashboard (13 pts)

**Deliverables**: Users can log in, reset password, view/edit profile

---

### Week 3: Addresses, Orders & Integration (Epic 3 + Epic 4)
**Focus**: Address book, order history, integration, testing

- **Day 11-12**: Story 3.2 - Address Book Management (13 pts)
- **Day 12**: Story 3.3 - Order History View (8 pts)
- **Day 13**: Story 4.1 - Update CheckoutController (5 pts)
- **Day 13**: Story 4.2 - Update OrderProcessor (5 pts)
- **Day 14**: Story 4.3 - Add Navigation Links (3 pts)
- **Day 14-15**: Story 4.4 - Comprehensive Testing (8 pts)

**Deliverables**: Address book, order history, full integration, 80%+ test coverage

---

## Definition of Done (DoD)

Each story is considered done when:

- [ ] Code implemented and follows Rails conventions
- [ ] Database migrations created and run
- [ ] Model validations added
- [ ] Controller strong parameters defined
- [ ] Views styled with Tailwind CSS
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration tests written and passing
- [ ] System tests written and passing (key flows)
- [ ] RuboCop passes with zero offenses
- [ ] All existing tests still passing (no regressions)
- [ ] Code reviewed (if team workflow includes reviews)
- [ ] Documentation updated (if needed)

---

## Security Considerations

1. **Password Security**
   - Devise handles password encryption (bcrypt)
   - Password complexity enforced (min 6 chars)
   - Password reset tokens expire after 6 hours

2. **Email Confirmation**
   - Email confirmation required before login
   - Prevents fake account creation

3. **CSRF Protection**
   - Devise forms include CSRF tokens
   - Session fixation attacks prevented

4. **Strong Parameters**
   - All controllers use strong parameters
   - No mass assignment vulnerabilities

5. **SQL Injection**
   - All queries use Active Record (parameterized)
   - No raw SQL with user input

6. **XSS Protection**
   - All user input HTML-escaped by default
   - Tailwind CSS classes safe

7. **Session Security**
   - Secure session cookies
   - HttpOnly and Secure flags set in production

8. **Rate Limiting**
   - Existing Rack::Attack rules apply
   - Login throttling: 5 attempts/20sec per IP+email

---

## Rollback Plan

If critical issues arise during sprint:

1. **Database Rollback**:
   ```bash
   rails db:rollback STEP=N
   ```

2. **Feature Toggle**:
   - Add `ENV['USER_ACCOUNTS_ENABLED']` flag
   - Hide registration/login links if disabled

3. **Preserve Guest Checkout**:
   - Guest checkout always works (fallback mode)
   - User accounts are additive, not replacement

4. **Data Migration**:
   - Users table can be emptied without affecting orders
   - Carts retain session_token for guest mode

---

## Post-Sprint Enhancements (Future Work)

These are **NOT** included in this sprint but can be added later:

1. **OAuth Login** (Google, Facebook)
2. **User Wishlist** (save products for later)
3. **Email Preferences** (marketing emails opt-in)
4. **User Reviews** (product reviews)
5. **Referral Program** (invite friends)
6. **Loyalty Points** (reward system)
7. **Order Tracking** (shipping updates)
8. **Saved Payment Methods** (Stripe customer portal)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| User Registration Rate | 20% of checkout users |
| Guest → User Conversion | 15% of guests register |
| Cart Retention (cross-device) | 100% for logged-in users |
| Test Coverage | >80% overall |
| RuboCop Violations | 0 |
| Page Load Time | <2s for dashboard |
| Email Delivery Rate | >98% |

---

## Dependencies

- **External**: None (Devise already used for AdminUser)
- **Internal**: Stable cart persistence system (already exists)
- **Blocking**: None (can start immediately)

---

## Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Cart merge logic bugs | Medium | High | Extensive testing, feature toggle |
| Email delivery issues | Low | Medium | Use reliable SMTP (MailerSend) |
| Security vulnerabilities | Low | High | Follow Devise best practices, security audit |
| Performance degradation | Low | Medium | Database indexes, query optimization |
| User confusion (2 login types) | Medium | Low | Clear UI labels, separate paths |

---

## Sprint Retrospective Questions

Post-sprint evaluation:

1. Did user registration work as expected?
2. Were there any cart transfer/merge bugs?
3. Is the UI intuitive for customers?
4. Are there any security concerns?
5. What performance issues were discovered?
6. What documentation is missing?
7. What would we do differently next time?

---

## Conclusion

This sprint adds **optional user accounts** while preserving the existing guest checkout experience. The dual-mode system ensures no disruption to current customers while providing a better experience for returning users. With comprehensive testing and careful integration, we can deliver a robust user authentication system in 3 weeks.

**Total Story Points**: 89
**Estimated Effort**: 3 weeks (15 days)
**Priority**: MEDIUM-HIGH
**Risk Level**: MEDIUM (mitigated by extensive testing)
