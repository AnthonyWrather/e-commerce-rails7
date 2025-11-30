# Database Schema Diagram

Last updated: 2025-11-30
Schema version: 2025_11_30_015033

```mermaid
erDiagram
    categories ||--o{ products : "has many"
    products ||--o{ stocks : "has many"
    products ||--o{ order_products : "has many"
    products ||--o{ cart_items : "has many"
    orders ||--o{ order_products : "has many"
    orders }o--|| users : "belongs to (optional)"
    carts ||--o{ cart_items : "has many"
    carts }o--|| users : "belongs to (optional)"
    stocks ||--o{ cart_items : "has many (optional)"
    active_storage_blobs ||--o{ active_storage_attachments : "has many"
    active_storage_blobs ||--o{ active_storage_variant_records : "has many"
    users ||--o{ conversations : "has many"
    users ||--o{ messages : "has many (as sender)"
    users ||--o{ addresses : "has many"
    users ||--o{ carts : "has many"
    users ||--o{ orders : "has many"
    conversations ||--o{ messages : "has many"
    conversations ||--o{ conversation_participants : "has many"
    conversations }o--|| users : "belongs to"
    conversation_participants }o--|| conversations : "belongs to"
    conversation_participants }o--|| admin_users : "belongs to"
    admin_users ||--o{ messages : "has many (as sender)"
    admin_users ||--o{ conversation_participants : "has many"
    admin_users ||--|| admin_presences : "has one"

    categories {
        bigint id PK
        string name
        text description
        datetime created_at
        datetime updated_at
    }

    products {
        bigint id PK
        string name
        text description
        integer price "in pence"
        integer category_id FK
        boolean active
        datetime created_at
        datetime updated_at
        integer stock_level
        integer shipping_weight "in grams"
        integer shipping_length "in cm"
        integer shipping_width "in cm"
        integer shipping_height "in cm"
        boolean fiberglass_reinforcement "default: false"
        integer min_resin_per_m2 "default: 0"
        integer max_resin_per_m2 "default: 0"
        integer avg_resin_per_m2 "default: 0"
    }

    stocks {
        bigint id PK
        string size
        integer stock_level
        integer product_id FK
        datetime created_at
        datetime updated_at
        integer price "in pence"
        integer shipping_weight "in grams"
        integer shipping_length "in cm"
        integer shipping_width "in cm"
        integer shipping_height "in cm"
        boolean fiberglass_reinforcement "default: false"
        integer min_resin_per_m2 "default: 0"
        integer max_resin_per_m2 "default: 0"
        integer avg_resin_per_m2 "default: 0"
    }

    orders {
        bigint id PK
        string customer_email
        boolean fulfilled
        integer total "in pence"
        string address
        datetime created_at
        datetime updated_at
        string name
        string phone
        string billing_name
        string billing_address
        string payment_status
        string payment_id
        integer shipping_cost "in pence"
        string shipping_id
        string shipping_description
    }

    order_products {
        bigint id PK
        integer product_id FK
        integer order_id FK
        string size
        integer quantity
        datetime created_at
        datetime updated_at
        integer price "captured at purchase"
    }

    admin_users {
        bigint id PK
        string email UK
        string encrypted_password
        string reset_password_token UK
        datetime reset_password_sent_at
        datetime remember_created_at
        datetime created_at
        datetime updated_at
        string otp_secret "encrypted 2FA secret"
        integer consumed_timestep "2FA replay prevention"
        boolean otp_required_for_login "default: false"
        text otp_backup_codes "JSON array of backup codes"
    }

    carts {
        bigint id PK
        string session_token UK "unique cart identifier"
        datetime expires_at "cart expiration time"
        datetime created_at
        datetime updated_at
        bigint user_id FK "optional, for logged-in users"
    }

    cart_items {
        bigint id PK
        bigint cart_id FK
        bigint product_id FK
        bigint stock_id FK "nullable, for size variants"
        string size "product size variant"
        integer quantity "item quantity"
        integer price "in pence, captured at add"
        datetime created_at
        datetime updated_at
    }

    users {
        bigint id PK
        string email UK
        string encrypted_password
        string reset_password_token UK
        datetime reset_password_sent_at
        datetime remember_created_at
        string confirmation_token UK
        datetime confirmed_at
        datetime confirmation_sent_at
        string unconfirmed_email
        string full_name "required"
        string phone "optional"
        datetime created_at
        datetime updated_at
    }

    addresses {
        bigint id PK
        bigint user_id FK
        string label "default: Home"
        string full_name "required"
        string line1 "required"
        string line2 "optional"
        string city "required"
        string county "optional"
        string postcode "required"
        string country "default: United Kingdom"
        string phone "optional"
        boolean primary "default: false"
        datetime created_at
        datetime updated_at
    }

    conversations {
        bigint id PK
        bigint user_id FK
        integer status "enum: open(0), active(1), resolved(2), closed(3)"
        string subject "optional"
        datetime last_message_at "updated on new message"
        datetime created_at
        datetime updated_at
    }

    messages {
        bigint id PK
        bigint conversation_id FK
        string sender_type "User or AdminUser"
        bigint sender_id "polymorphic sender"
        text content "max 5000 chars"
        datetime read_at "nullable"
        datetime created_at
        datetime updated_at
    }

    conversation_participants {
        bigint id PK
        bigint conversation_id FK
        bigint admin_user_id FK
        datetime last_read_at "track read status"
        boolean active "default: true"
        datetime created_at
        datetime updated_at
    }

    admin_presences {
        bigint id PK
        bigint admin_user_id FK UK
        string status "online or offline"
        datetime last_seen_at "nullable"
        datetime created_at
        datetime updated_at
    }

    versions {
        bigint id PK
        string whodunnit "user who made the change"
        datetime created_at
        bigint item_id
        string item_type
        string event "create/update/destroy"
        text object "serialized object before change"
        text object_changes "serialized changes"
    }

    active_storage_blobs {
        bigint id PK
        string key UK
        string filename
        string content_type
        text metadata
        string service_name
        bigint byte_size
        string checksum
        datetime created_at
    }

    active_storage_attachments {
        bigint id PK
        string name
        string record_type
        bigint record_id
        bigint blob_id FK
        datetime created_at
    }

    active_storage_variant_records {
        bigint id PK
        bigint blob_id FK
        string variation_digest
    }
```

## Key Relationships

### Core E-Commerce Flow
- **categories → products**: One category can have many products
- **products → stocks**: One product can have many size variants (stocks)
- **products → order_products**: Products can appear in multiple orders
- **orders → order_products**: One order contains multiple products

### Cart & Session Management
- **carts → cart_items**: One cart contains multiple cart items
- **products → cart_items**: Products can be added to multiple carts
- **stocks → cart_items**: Optional relationship for size variants in cart
- **Cart expiry**: Carts automatically expire after 30 days (configurable via `Cart::EXPIRY_DAYS`)
- **Session token**: Unique identifier for each cart, stored in browser localStorage

### Active Storage (Images)
- **active_storage_blobs → active_storage_attachments**: Polymorphic relationship
  - Products: `has_many_attached :images`
  - Categories: `has_one_attached :image`
- **active_storage_blobs → active_storage_variant_records**: Image variants (thumb, medium)

### Authentication & Two-Factor Authentication
- **admin_users**: Standalone table (Devise authentication with 2FA support)
  - No foreign key relationships to other tables
  - Only admins have accounts, customers checkout as guests
  - Uses `devise-two-factor` gem for TOTP-based 2FA
  - Backup codes stored as encrypted JSON array

### Audit Trail (PaperTrail)
- **versions**: Polymorphic audit log tracking changes to all models
  - Tracks who made changes (`whodunnit`)
  - Stores object state before/after changes
  - Indexed for efficient querying

## Pricing Model
The schema supports two pricing strategies:

1. **Single Price**: Product has `price` and `stock_level` directly
2. **Variant Pricing**: Product has multiple Stocks, each with their own `price` and `stock_level`

## Important Notes

- All prices stored in **pence** (integer)
- All weights in **grams** (integer)
- All dimensions (shipping_weight, shipping_length, shipping_width, shipping_height) in **cm** or **grams**
- `order_products.price` captures the price at time of purchase (not calculated)
- Orders created via Stripe webhook only (no direct user creation)
- **fiberglass_reinforcement**: Boolean flag indicating if product/stock is a fiberglass material
- **Resin estimation fields** (min_resin_per_m2, max_resin_per_m2, avg_resin_per_m2): Used for calculating material requirements for composite projects

## Model Relationships & Validations

### Product Model
**Associations:**
- `belongs_to :category`
- `has_many :stocks`
- `has_many :order_products`
- `has_many :cart_items`
- `has_many_attached :images` (with variants: `:thumb`, `:medium`)

**Scopes:**
- `active` - Returns only active products
- `in_price_range(min, max)` - Filters products by price range

**Validations:**
- `name`: required
- `price`: required, integer, >= 0
- `stock_level`: integer, >= 0, nullable
- `shipping_weight`, `shipping_length`, `shipping_width`, `shipping_height`: integer, > 0, nullable

### Stock Model
**Associations:**
- `belongs_to :product`
- `has_many :cart_items`

**Validations:**
- `size`: required
- `price`: required, integer, >= 0
- `stock_level`: integer, >= 0, nullable
- `shipping_weight`, `shipping_length`, `shipping_width`, `shipping_height`: integer, > 0, nullable

### Category Model
**Associations:**
- `has_many :products, dependent: :destroy`
- `has_one_attached :image` (with variant: `:thumb`)

**Validations:**
- `name`: required, unique (case-insensitive)

### Order Model
**Associations:**
- `has_many :order_products`

**Scopes:**
- `unfulfilled` - Returns unfulfilled orders
- `fulfilled` - Returns fulfilled orders
- `recent(limit = 5)` - Returns recent orders (ordered by created_at desc)
- `for_month(date = Time.current)` - Returns orders for a specific month

**Validations:**
- `customer_email`: required, valid email format
- `total`: required, integer, >= 0
- `shipping_cost`: integer, >= 0, nullable
- `address`: required
- `name`: required

### OrderProduct Model
**Associations:**
- `belongs_to :product`
- `belongs_to :order`

**Validations:**
- `quantity`: required, integer, > 0
- `price`: required, integer, >= 0

### Cart Model
**Associations:**
- `has_many :cart_items, dependent: :destroy`

**Scopes:**
- `active` - Returns carts that haven't expired
- `expired` - Returns expired carts

**Validations:**
- `session_token`: required, unique
- `expires_at`: required

**Methods:**
- `find_or_create_by_token(token)` - Class method to find/create cart by session token
- `expired?` - Check if cart has expired
- `extend_expiry!` - Extend cart expiration by 30 days
- `total` - Calculate total price of all cart items
- `refresh_prices!` - Update cart item prices from current product/stock prices
- `merge_items!(other_cart_items)` - Merge items from another cart (for localStorage sync)

### CartItem Model
**Associations:**
- `belongs_to :cart`
- `belongs_to :product`
- `belongs_to :stock, optional: true`

**Validations:**
- `quantity`: required, integer, > 0
- `price`: required, integer, >= 0
- `product_id`: unique within cart and size (prevents duplicate items)

**Methods:**
- `refresh_price!` - Update price from current product/stock price
- `total` - Calculate total for this item (price × quantity)
- `stock_available?` - Check if sufficient stock is available

### User Model
**Associations:**
- `has_many :carts`
- `has_many :addresses`
- `has_many :orders`
- `has_many :conversations`
- `has_many :messages` (polymorphic as sender)

**Authentication:** Devise modules
- `database_authenticatable`
- `registerable`
- `recoverable`
- `rememberable`
- `validatable`
- `confirmable`

**Validations:**
- `email`: required, unique, valid email format
- `full_name`: required, 2-100 characters
- `phone`: optional, format validation (numbers/spaces/+/-)

**Methods:**
- `display_name` - Returns full_name or email prefix
- `primary_address` - Returns the primary shipping address

**Note:** PaperTrail audit logging enabled

### Address Model
**Associations:**
- `belongs_to :user` (dependent: destroy)

**Validations:**
- `full_name`: required
- `line1`: required (address line 1)
- `city`: required
- `postcode`: required, format validation
- `country`: default "United Kingdom"
- `primary`: boolean, default false

**Indexes:**
- `user_id`
- `postcode`
- Composite: `user_id` + `primary`

**Methods:**
- `display_name` - Returns label or "Home"
- `to_s` - Returns formatted multi-line address

### Conversation Model
**Associations:**
- `belongs_to :user` (customer who initiated)
- `has_many :messages`
- `has_many :conversation_participants`
- `has_many :admin_users, through: :conversation_participants`

**Status Enum:**
- `open` (0) - Newly created, awaiting admin assignment
- `active` (1) - Admin assigned and responding
- `resolved` (2) - Issue resolved, may be reopened
- `closed` (3) - Permanently closed

**Scopes:**
- `recent` - Ordered by last_message_at desc
- `unresolved` - Status is open or active
- `for_user(user_id)` - Conversations for specific user
- `for_admin(admin_user_id)` - Conversations assigned to admin

**Methods:**
- `unread_messages_for(participant)` - Count unread messages
- `latest_message` - Returns most recent message
- `participant_for(admin_user)` - Returns participant record for admin

**Note:** PaperTrail audit logging enabled

### Message Model
**Associations:**
- `belongs_to :conversation` (touches last_message_at on create)
- `belongs_to :sender` (polymorphic: User or AdminUser)

**Validations:**
- `content`: required, max 5000 characters
- `sender_type`: must be 'User' or 'AdminUser'

**Scopes:**
- `recent` - Ordered by created_at asc
- `unread_for(participant)` - Messages with read_at nil after participant's last_read_at

**Callbacks:**
- `after_create_commit :update_conversation_timestamp` - Updates conversation.last_message_at

**Methods:**
- `sender_name` - Returns sender's display name
- `sender_type_class` - Returns 'admin' or 'user' for CSS classes

### ConversationParticipant Model
**Associations:**
- `belongs_to :conversation`
- `belongs_to :admin_user`

**Validations:**
- Unique constraint: conversation_id + admin_user_id (enforces one admin per conversation)

**Fields:**
- `last_read_at` - Timestamp for read status tracking
- `active` - Boolean, default true (for soft deletion)

**Indexes:**
- Unique composite: conversation_id + admin_user_id

### AdminPresence Model
**Associations:**
- `belongs_to :admin_user`

**Validations:**
- `admin_user_id`: unique (one presence record per admin)
- `status`: required, values 'online' or 'offline'

**Indexes:**
- Unique: `admin_user_id`
- `status` - For filtering online admins
- `last_seen_at` - For cleanup queries

**Broadcasting:**
- Status changes broadcast to PresenceChannel (Action Cable)
- Customers see real-time admin availability

**Methods:**
- `update_status!(status)` - Updates status and broadcasts change
- `online?` - Returns true if status is 'online'
- `offline?` - Returns true if status is 'offline'

### AdminUser Model
**Authentication:** Devise modules
- `database_authenticatable`
- `registerable`
- `recoverable`
- `rememberable`
- `validatable`
- `two_factor_authenticatable` (TOTP-based)
- `two_factor_backupable` (backup codes)

**Two-Factor Authentication Methods:**
- `setup_two_factor!` - Generate OTP secret for user
- `enable_two_factor!(otp_attempt)` - Enable 2FA after verifying OTP code
- `disable_two_factor!(password)` - Disable 2FA after password verification
- `two_factor_enabled?` - Check if 2FA is enabled
- `two_factor_pending?` - Check if 2FA setup is in progress
- `regenerate_backup_codes!` - Generate new backup codes
- `validate_backup_code(code)` - Validate and consume a backup code
- `otp_provisioning_uri` - Generate QR code URI for authenticator apps

**Note:** No associations to other models; standalone authentication table

## Indexes

### Products Table
- `index_products_on_active`
- `index_products_on_category_id`
- `index_products_on_name`
- `index_products_on_price`
- `index_products_on_active_and_price_and_category_id` (composite index)

### Stocks Table
- `index_stocks_on_product_id`

### Orders Table
- `index_orders_on_created_at`
- `index_orders_on_fulfilled`
- `index_orders_on_fulfilled_and_created_at` (composite index)

### OrderProducts Table
- `index_order_products_on_product_id`
- `index_order_products_on_order_id`

### Carts Table
- `index_carts_on_session_token` (unique)
- `index_carts_on_expires_at`

### CartItems Table
- `index_cart_items_on_cart_id`
- `index_cart_items_on_product_id`
- `index_cart_items_on_stock_id`
- `index_cart_items_on_cart_id_and_product_id_and_size` (unique composite)

### AdminUsers Table
- `index_admin_users_on_email` (unique)
- `index_admin_users_on_reset_password_token` (unique)

### Users Table
- `index_users_on_email` (unique)
- `index_users_on_reset_password_token` (unique)
- `index_users_on_confirmation_token` (unique)

### Addresses Table
- `index_addresses_on_user_id`
- `index_addresses_on_postcode`
- `index_addresses_on_user_id_and_primary` (composite)

### Conversations Table
- `index_conversations_on_user_id`
- `index_conversations_on_status`
- `index_conversations_on_last_message_at`
- `index_conversations_on_user_id_and_status` (composite)

### Messages Table
- `index_messages_on_conversation_id`
- `index_messages_on_sender` (polymorphic composite: sender_type, sender_id)
- `index_messages_on_conversation_id_and_created_at` (composite)

### ConversationParticipants Table
- `index_conversation_participants_on_conversation_id_and_admin_user_id` (unique composite)
- `index_conversation_participants_on_admin_user_id`

### AdminPresences Table
- `index_admin_presences_on_admin_user_id` (unique)
- `index_admin_presences_on_status`
- `index_admin_presences_on_last_seen_at`

### Versions Table (PaperTrail)
- `index_versions_on_item_type_and_item_id` (composite)
- `index_versions_on_whodunnit`
- `index_versions_on_created_at`
- `index_versions_on_event`

### Active Storage Tables
- `index_active_storage_attachments_on_blob_id`
- `index_active_storage_attachments_uniqueness` (unique composite: record_type, record_id, name, blob_id)
- `index_active_storage_blobs_on_key` (unique)
- `index_active_storage_variant_records_uniqueness` (unique composite: blob_id, variation_digest)

## Schema Version

Current schema version: `2025_11_30_165804` (PostgreSQL 17)

## Foreign Key Constraints

### Cart Tables
- `carts.user_id` → `users.id` (on_delete: nullify, nullable)
- `cart_items.cart_id` → `carts.id` (on_delete: cascade, on_update: cascade)
- `cart_items.product_id` → `products.id` (on_delete: cascade, on_update: cascade)
- `cart_items.stock_id` → `stocks.id` (on_delete: cascade, on_update: cascade)

### Product Tables
- `products.category_id` → `categories.id`
- `stocks.product_id` → `products.id`

### Order Tables
- `orders.user_id` → `users.id` (nullable)
- `order_products.product_id` → `products.id`
- `order_products.order_id` → `orders.id`

### User & Address Tables
- `addresses.user_id` → `users.id` (on_delete: cascade)

### Chat Tables
- `conversations.user_id` → `users.id`
- `messages.conversation_id` → `conversations.id`
- `messages.sender_id` → polymorphic (users.id or admin_users.id, based on sender_type)
- `conversation_participants.conversation_id` → `conversations.id`
- `conversation_participants.admin_user_id` → `admin_users.id`
- `admin_presences.admin_user_id` → `admin_users.id`

### Active Storage Tables
- `active_storage_attachments.blob_id` → `active_storage_blobs.id`
- `active_storage_variant_records.blob_id` → `active_storage_blobs.id`

## Important Data Integrity Notes

### Cascade Deletes
- **Carts**: Deleting a cart automatically deletes all associated cart_items
- **Products**: Deleting a product cascades to cart_items (prevents orphaned cart references)
- **Categories**: Deleting a category cascades to products (as per model `dependent: :destroy`)
- **Users**: Deleting a user cascades to addresses but nullifies cart references
- **Conversations**: Messages are dependent on conversations (cascade delete expected)

### Referential Integrity
- All foreign keys enforce referential integrity at the database level
- Cart items cannot reference non-existent products, stocks, or carts
- Order products maintain references even if product is deleted (no cascade on orders)
- Messages use polymorphic association to reference either User or AdminUser as sender
- Unique constraint on conversation_participants ensures one admin per conversation

