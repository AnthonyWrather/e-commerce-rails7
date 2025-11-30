# Server-Side Cart Persistence

This document describes the server-side cart persistence feature that enables cross-device cart synchronization for the e-commerce platform.

## Overview

The cart persistence system allows customers to maintain their shopping cart across multiple devices and browser sessions. The cart data is stored in the database and synchronized with the client-side localStorage implementation.

## Architecture

### Data Models

#### Cart

The `Cart` model represents a shopping cart session:

```ruby
# Fields:
# - session_token: Unique identifier for the cart session (string, required, unique)
# - expires_at: Expiration timestamp for the cart (datetime, required)
# - created_at/updated_at: Standard Rails timestamps

# Associations:
# - has_many :cart_items
```

**Key Features:**
- Carts expire after 30 days (`Cart::EXPIRY_DAYS`)
- Session tokens are used to identify carts across requests
- Expired carts are automatically cleaned up by the `CartCleanupJob`

#### CartItem

The `CartItem` model represents individual items in a cart:

```ruby
# Fields:
# - cart_id: Reference to the parent cart (required)
# - product_id: Reference to the product (required)
# - stock_id: Reference to specific stock/variant (optional)
# - size: Size variant selected (string)
# - quantity: Number of items (integer, required, > 0)
# - price: Price in pence at time of addition (integer, required, >= 0)

# Constraints:
# - Unique index on [cart_id, product_id, size] prevents duplicates
```

**Key Features:**
- Prices are captured at time of addition to track price changes
- Stock association is optional (for products without size variants)
- Quantity must be positive

### Service Layer

#### CartPersistenceService

The `CartPersistenceService` handles all cart operations:

```ruby
service = CartPersistenceService.new(session_token)

# Sync from localStorage
service.sync_from_local_storage(cart_items_data)

# Load cart with refreshed prices
service.load_cart

# Convert to localStorage format
service.to_local_storage_format

# Merge incoming items
service.merge_carts(incoming_items)

# Clear all items
service.clear_cart
```

### API Endpoints

The cart API is available under the `/api/cart` namespace:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/cart` | Get current cart items |
| POST | `/api/cart/sync` | Sync localStorage to server |
| POST | `/api/cart/merge` | Merge incoming items with existing cart |
| DELETE | `/api/cart/clear` | Clear all cart items |

**Authentication:**
Cart operations use a session token passed via:
- `X-Cart-Token` header (preferred)
- `session_token` or `cart_token` query/body parameter

**Response Format:**
```json
{
  "items": [
    {
      "id": 1,
      "name": "Product Name",
      "price": 1500,
      "size": "1m x 10m Roll",
      "quantity": 2
    }
  ],
  "expires_at": "2024-02-28T12:00:00.000Z"
}
```

### Background Jobs

#### CartCleanupJob

The `CartCleanupJob` removes expired carts from the database:

```ruby
CartCleanupJob.perform_now
# Or schedule for later
CartCleanupJob.perform_later
```

**Recommended Schedule:** Run daily via cron or scheduler.

## Usage Flow

### Initial Page Load

1. Client checks for existing cart token in localStorage
2. If token exists, client calls `GET /api/cart` with the token
3. Server returns cart items with refreshed prices
4. Client updates localStorage with server data

### Adding to Cart

1. Client adds item to localStorage (existing behavior)
2. Client calls `POST /api/cart/sync` with current localStorage data
3. Server updates database cart
4. Server returns updated cart with current prices

### Cross-Device Sync

1. User visits site on new device
2. User provides cart token (could be via login, QR code, etc.)
3. Client calls `GET /api/cart` with the token
4. Server returns stored cart items
5. Client merges with any local items via `POST /api/cart/merge`

### Cart Expiry

- Carts expire 30 days after creation
- Each sync operation extends the expiry date
- Expired carts are cleaned up by the `CartCleanupJob`
- Cart items are automatically deleted when parent cart is deleted (cascade)

## Price Refresh

When loading a cart, prices are automatically refreshed from current product/stock prices:

```ruby
cart.refresh_prices!
```

This ensures customers always see current pricing, even if products have been updated since they added items.

## Data Schema

### carts table

| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | Primary Key |
| session_token | string | NOT NULL, UNIQUE, indexed |
| expires_at | datetime | NOT NULL, indexed |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

### cart_items table

| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | Primary Key |
| cart_id | bigint | NOT NULL, FK to carts (CASCADE) |
| product_id | bigint | NOT NULL, FK to products (CASCADE) |
| stock_id | bigint | FK to stocks (CASCADE), nullable |
| size | string | |
| quantity | integer | NOT NULL |
| price | integer | NOT NULL |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:**
- `[cart_id, product_id, size]` - Unique index for item lookup

## Testing

Tests are located in:
- `test/models/cart_test.rb`
- `test/models/cart_item_test.rb`
- `test/services/cart_persistence_service_test.rb`
- `test/controllers/api/carts_controller_test.rb`
- `test/jobs/cart_cleanup_job_test.rb`

Run cart-related tests:
```bash
bin/rails test test/models/cart_test.rb test/models/cart_item_test.rb \
  test/services/cart_persistence_service_test.rb \
  test/controllers/api/carts_controller_test.rb \
  test/jobs/cart_cleanup_job_test.rb
```

## Future Improvements

1. **User Authentication Integration**: Link carts to user accounts when logged in
2. **Cart Recovery Emails**: Send reminders for abandoned carts
3. **Stock Validation**: Validate stock availability on sync
4. **Webhooks**: Notify external systems of cart updates
5. **Analytics**: Track cart abandonment metrics
