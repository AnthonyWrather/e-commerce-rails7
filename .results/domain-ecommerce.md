# E-Commerce Domain Documentation

## Overview
The e-commerce domain handles all customer-facing shopping functionality including product browsing, cart management, and checkout processing. This domain is **guest-only** with no customer accounts required.

## Core Concepts

### Guest Checkout Model
- **No User Accounts**: Customers checkout without registration
- **Email Identification**: Orders tracked by customer email only
- **Ephemeral Cart**: Shopping cart stored in browser localStorage only
- **No Order History**: Customers cannot view past orders (admin can via email search)

### Dual Pricing Strategy
Products support two pricing models:

1. **Single Price Product**
   - Product has `price` and `amount` fields directly
   - Simple items with no size variations
   - Example: Tools, single-size materials

2. **Variant Pricing Product**
   - Product has multiple Stock records
   - Each stock has `size`, `price`, and `amount`
   - Size selection required at checkout
   - Example: Fiberglass mat in 300g, 450g, 600g variants

### Stock Management
- **Product-Level Stock**: `Product.amount` for single-price items
- **Variant-Level Stock**: `Stock.amount` for size variants
- **Stock Validation**: Checked at checkout creation (before Stripe)
- **Stock Decrement**: Happens in webhook after successful payment (not at checkout)
- **No Overselling Protection**: Race condition possible between validation and decrement

## Data Flow

### Browse → Cart → Checkout → Order

```
1. Browse Products
   └─ CategoriesController#show
      ├─ Load category with products
      ├─ Filter: active products only
      ├─ Filter: price range (min/max in pence)
      └─ Render product grid

2. View Product Details
   └─ ProductsController#show
      ├─ Load product with stocks
      ├─ Pass product + stocks as JSON to Stimulus
      └─ Render product page with image gallery

3. Add to Cart (Client-Side)
   └─ products_controller.ts#addToCart
      ├─ Read current cart from localStorage
      ├─ Find existing item (by id + size)
      ├─ Increment quantity OR add new item
      ├─ Save cart to localStorage
      └─ Show flash message

4. View Cart (Client-Side)
   └─ cart_controller.ts#initialize
      ├─ Read cart from localStorage
      ├─ Build HTML table with items
      ├─ Calculate totals (subtotal, VAT, total)
      └─ Render cart UI

5. Checkout (Server-Side)
   └─ CheckoutsController#create
      ├─ Parse cart JSON from params
      ├─ For each item:
      │  ├─ Load product
      │  ├─ Determine price (stock variant OR product price)
      │  ├─ Validate stock availability
      │  └─ Build Stripe line item with metadata
      ├─ Create Stripe Checkout Session
      │  ├─ Line items with prices
      │  ├─ Shipping options (3 choices)
      │  ├─ Shipping address collection (GB only)
      │  ├─ Phone number collection
      │  └─ Billing address collection
      └─ Return session URL for redirect

6. Payment (External)
   └─ Stripe Checkout
      ├─ Customer enters payment details
      ├─ Customer enters shipping/billing addresses
      ├─ Customer selects shipping method
      ├─ Stripe processes payment
      └─ Stripe sends webhook to Rails

7. Order Creation (Webhook)
   └─ WebhooksController#stripe
      ├─ Verify webhook signature
      ├─ Extract checkout session data
      ├─ Create Order record
      │  ├─ customer_email
      │  ├─ total (in pence)
      │  ├─ shipping_cost
      │  ├─ shipping_id, shipping_description
      │  ├─ name, phone, address (shipping)
      │  ├─ billing_name, billing_address
      │  ├─ payment_status, payment_id
      │  └─ fulfilled = false
      ├─ Create OrderProduct records
      │  ├─ For each line item in session
      │  ├─ Extract metadata (product_id, size, price)
      │  ├─ Create OrderProduct (price captured)
      │  └─ Decrement stock (Product OR Stock)
      ├─ Send order confirmation email
      │  └─ OrderMailer.new_order_email(order).deliver_now
      └─ Return 200 OK to Stripe

8. Success Page
   └─ CheckoutsController#success
      ├─ Render success message
      ├─ cart_controller.ts clears localStorage
      └─ Display order confirmation
```

## Key Components

### Models

#### Product
```ruby
class Product < ApplicationRecord
  belongs_to :category
  has_many :stocks
  has_many :order_products
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :medium, resize_to_limit: [250, 250]
  end
end
```

**Fields**:
- `name` - Product title
- `description` - Product details (text)
- `price` - Price in pence (integer) - used if no stocks
- `amount` - Stock quantity (integer) - used if no stocks
- `active` - Visibility flag (boolean)
- `weight`, `length`, `width`, `height` - Shipping dimensions (integers, in grams/cm)
- `category_id` - Foreign key to Category

**Image Management**:
- Multiple images via Active Storage
- Variants generated: thumb (50x50), medium (250x250)
- VIPS processing required
- Stored in S3 (production) or local disk (development)

#### Stock
```ruby
class Stock < ApplicationRecord
  belongs_to :product
end
```

**Fields**:
- `size` - Variant name (string) e.g., "300g", "Large"
- `amount` - Stock quantity for this variant (integer)
- `price` - Price in pence for this variant (integer)
- `weight`, `length`, `width`, `height` - Override product dimensions (integers)
- `product_id` - Foreign key to Product

**Usage**:
- Created via admin interface (nested under product)
- Used when product has multiple size options
- Price overrides product price when size selected

#### Category
```ruby
class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
  end
end
```

**Fields**:
- `name` - Category title
- `description` - Category description (text)

**Cascade Delete**:
- Deleting category deletes all products
- Products have foreign key constraint

#### Order
```ruby
class Order < ApplicationRecord
  has_many :order_products
end
```

**Fields**:
- `customer_email` - Customer email (string)
- `fulfilled` - Order fulfillment status (boolean, default: false)
- `total` - Order total in pence (integer)
- `address` - Shipping address (string)
- `name` - Shipping recipient name (string)
- `phone` - Customer phone number (string)
- `billing_name` - Billing name (string)
- `billing_address` - Billing address (string)
- `payment_status` - Stripe payment status (string)
- `payment_id` - Stripe payment intent ID (string)
- `shipping_cost` - Shipping cost in pence (integer)
- `shipping_id` - Stripe shipping rate ID (string)
- `shipping_description` - Shipping method name (string)

**Immutability**:
- Created exclusively via webhook
- No edit functionality in admin (view only)
- Fulfillment flag can be toggled

#### OrderProduct
```ruby
class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order
end
```

**Fields**:
- `product_id` - Foreign key to Product
- `order_id` - Foreign key to Order
- `size` - Selected variant (string) - may be empty
- `quantity` - Items ordered (integer)
- `price` - Price at time of purchase in pence (integer)

**Critical**:
- `price` is captured at purchase time (not calculated)
- This preserves historical pricing even if product price changes
- `size` records which variant was selected

### Controllers

#### CategoriesController
**Route**: `GET /categories/:id`

```ruby
def show
  @category = Category.find(params[:id])
  @products = @category.products
  @products = @products.where(active: true)
  @products = @products.where('price <= ?', params[:max]) if params[:max].present?
  @products = @products.where('price >= ?', params[:min]) if params[:min].present?
end
```

**Features**:
- Category-based product listing
- Active products only filter
- Price range filtering (min/max in pence)
- No pagination (shows all matching products)

**URL Patterns**:
- `/categories/1` - All active products
- `/categories/1?min=1000` - Products £10 and above
- `/categories/1?min=1000&max=5000` - Products £10-£50

#### ProductsController
**Route**: `GET /products/:id`

```ruby
def show
  @product = Product.find(params[:id])
end
```

**View Logic**:
- Passes product and stocks to Stimulus as JSON
- Stimulus handles size selection and cart management
- No server-side cart logic

#### CartsController
**Route**: `GET /cart`

```ruby
def show
  # Cart rendered entirely client-side from localStorage
end
```

**Features**:
- Empty action (view only)
- cart_controller.ts reads localStorage
- VAT calculations (20% UK VAT)
- Remove items, clear cart
- Checkout button posts to `/checkout`

#### CheckoutsController
**Routes**:
- `POST /checkout` - Create Stripe session
- `GET /success` - Order confirmation
- `GET /cancel` - Checkout cancelled

**Key Methods**:

```ruby
def create
  Stripe.api_key = stripe_secret_key
  line_items = build_line_items(params[:cart])
  return if performed? # Stop if stock validation failed
  session = create_stripe_session(line_items)
  render json: { url: session.url }
end

private

def build_line_items(cart)
  cart.map do |item|
    product = Product.find(item['id'])
    product_stock_id, price = get_product_pricing(product, item)
    return unless stock_available?(product, product_stock_id, item)
    build_line_item(item, product, product_stock_id, price)
  end
end

def get_product_pricing(product, item)
  product_stock = product.stocks.find { |ps| ps.size == item['size'] }
  if product_stock
    [product_stock.id, product_stock.price]
  else
    [product.id, product.price]
  end
end

def stock_available?(product, product_stock_id, item)
  stock_obj = Stock.find_by(id: product_stock_id) if product_stock_id != product.id
  available = stock_obj ? stock_obj.amount : product.amount

  if available < item['quantity'].to_i
    size_text = item['size'].present? ? " in size #{item['size']}" : ''
    render json: { error: "Not enough stock for #{product.name}#{size_text}. Only #{available} left." }, status: 400
    return false
  end
  true
end
```

**Stripe Session Configuration**:
```ruby
Stripe::Checkout::Session.create(
  mode: 'payment',
  line_items: line_items,
  success_url: "#{request.protocol}#{request.host_with_port}/success",
  cancel_url: "#{request.protocol}#{request.host_with_port}/cart",
  shipping_address_collection: { allowed_countries: %w[GB] },
  currency: 'GBP',
  payment_method_types: ['card'],
  phone_number_collection: { enabled: true },
  billing_address_collection: 'required',
  shipping_options: SHIPPING_OPTIONS
)
```

**Shipping Options**:
1. **Collection** - Free (1 business day)
2. **3-5 Day Shipping** - £25.00
3. **Overnight** - £50.00 (order before 11:00am Mon-Thu)

**Line Item Metadata**:
```ruby
{
  quantity: item['quantity'].to_i,
  price_data: {
    product_data: {
      name: item['name'],
      metadata: {
        product_id: product.id,
        size: item['size'],
        product_stock_id: product_stock_id,
        product_price: price
      }
    },
    currency: 'gbp',
    unit_amount: item['price'].to_i
  }
}
```

#### WebhooksController
**Route**: `POST /webhooks`

**Critical Logic**:
```ruby
def stripe
  # Verify webhook signature
  stripe_secret_key = ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
  Stripe.api_key = stripe_secret_key

  sig_header = request.env['HTTP_STRIPE_SIGNATURE']
  endpoint_secret = ENV['STRIPE_WEBHOOK_KEY'] || Rails.application.credentials.dig(:stripe, :webhook_key)
  payload = request.body.read

  begin
    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
  rescue Stripe::SignatureVerificationError
    render json: { error: 'Invalid signature' }, status: 400
    return
  end

  # Handle checkout.session.completed event
  if event.type == 'checkout.session.completed'
    session = event.data.object

    # Create Order
    order = Order.create!(
      customer_email: session.customer_details.email,
      total: session.amount_total,
      fulfilled: false,
      address: format_address(session.shipping_details.address),
      name: session.shipping_details.name,
      phone: session.customer_details.phone,
      billing_name: session.customer_details.name,
      billing_address: format_address(session.customer_details.address),
      payment_status: session.payment_status,
      payment_id: session.payment_intent,
      shipping_cost: session.total_details.amount_shipping,
      shipping_id: session.shipping_rate,
      shipping_description: retrieve_shipping_description(session.shipping_rate)
    )

    # Create OrderProducts and decrement stock
    full_session = Stripe::Checkout::Session.retrieve({ id: session.id, expand: ['line_items'] })
    full_session.line_items.data.each do |line_item|
      metadata = line_item.price.product.metadata

      OrderProduct.create!(
        order: order,
        product_id: metadata.product_id,
        size: metadata.size,
        quantity: line_item.quantity,
        price: metadata.product_price
      )

      # Decrement stock
      if metadata.product_stock_id.to_i != metadata.product_id.to_i
        stock = Stock.find(metadata.product_stock_id)
        stock.update!(amount: stock.amount - line_item.quantity)
      else
        product = Product.find(metadata.product_id)
        product.update!(amount: product.amount - line_item.quantity)
      end
    end

    # Send order confirmation email
    OrderMailer.new_order_email(order).deliver_now
  end

  render json: { status: 'success' }, status: 200
end
```

**Security**:
- Webhook signature verification prevents replay attacks
- Only processes `checkout.session.completed` events
- Validates Stripe signature before creating orders

**Error Handling**:
- Returns 400 for invalid signatures
- Returns 200 for all other cases (including unhandled event types)
- Stripe retries failed webhooks automatically

### TypeScript Controllers

#### products_controller.ts
**Purpose**: Size selection and add to cart functionality

**Stimulus Values**:
```typescript
static values = {
  size: String,           // Currently selected size
  product: Object,        // Product JSON from Rails
  stock: Array,           // Stock variants JSON from Rails
  messageTimeout: Number  // Flash message duration (default 2500ms)
}
```

**Key Methods**:

```typescript
selectSize(e: Event): void {
  const button = e.currentTarget as HTMLButtonElement
  const size = button.value
  this.sizeValue = size

  // Find stock variant or use product price
  const stock = this.stockValue.find((s: Stock) => s.size === size)
  const price = stock ? stock.price : this.productValue.price

  // Update UI
  const selectedSizeEl = document.getElementById("selected-size")
  if (selectedSizeEl) {
    selectedSizeEl.textContent = size
  }

  const priceEl = document.getElementById("price")
  if (priceEl) {
    priceEl.textContent = this.formatCurrency(price)
  }

  // Enable add to cart button
  const addToCartBtn = document.getElementById("add-to-cart-btn")
  if (addToCartBtn) {
    addToCartBtn.classList.remove("invisible")
    addToCartBtn.removeAttribute("disabled")
  }
}

addToCart(): void {
  const cartString = localStorage.getItem("cart") || "[]"
  const cart: CartItem[] = JSON.parse(cartString)

  // Find existing item
  const existingItem = cart.find(
    item => item.id === this.productValue.id && item.size === this.sizeValue
  )

  if (existingItem) {
    existingItem.quantity += 1
  } else {
    const stock = this.stockValue.find((s: Stock) => s.size === this.sizeValue)
    const price = stock ? stock.price : this.productValue.price

    cart.push({
      id: this.productValue.id,
      name: this.productValue.name,
      price: price,
      size: this.sizeValue,
      quantity: 1
    })
  }

  localStorage.setItem("cart", JSON.stringify(cart))
  this.addMessage({ message: "Item added to cart!" })
}
```

**Type Interfaces**:
```typescript
interface Product {
  id: number
  name: string
  price: number
  // ... other fields
}

interface Stock {
  id: number
  size: string
  price: number
  amount: number
  // ... other fields
}

interface CartItem {
  id: number
  name: string
  price: number
  size: string
  quantity: number
}
```

#### cart_controller.ts
**Purpose**: Cart rendering, VAT calculations, checkout submission

**Key Methods**:

```typescript
initialize(): void {
  const cartData = localStorage.getItem("cart")
  if (!cartData) return

  const cart: CartItem[] = JSON.parse(cartData)

  let total = 0
  const table_body = document.getElementById("table_body") as HTMLTableSectionElement
  if (!table_body) return

  cart.forEach((item, index) => {
    const row = table_body.insertRow()

    // Name
    row.insertCell().textContent = item.name

    // Size
    row.insertCell().textContent = item.size || "N/A"

    // Price
    const itemTotal = item.price * item.quantity
    row.insertCell().textContent = this.formatCurrency(itemTotal)

    // Quantity
    row.insertCell().textContent = item.quantity.toString()

    // Remove button
    const removeCell = row.insertCell()
    const removeBtn = document.createElement("button")
    removeBtn.textContent = "Remove"
    removeBtn.dataset.action = "click->cart#removeFromCart"
    removeBtn.dataset.index = index.toString()
    removeCell.appendChild(removeBtn)

    total += itemTotal
  })

  // Calculate VAT (20% UK VAT)
  const exVat = total / 1.2
  const vat = total - exVat

  // Update totals
  const totalEl = document.getElementById("total")
  const exVatEl = document.getElementById("ex-vat")
  const vatEl = document.getElementById("vat")

  if (totalEl) totalEl.textContent = this.formatCurrency(total)
  if (exVatEl) exVatEl.textContent = this.formatCurrency(exVat)
  if (vatEl) vatEl.textContent = this.formatCurrency(vat)
}

checkout(): void {
  const cartData = localStorage.getItem("cart")
  if (!cartData) {
    this.addMessage({ message: "Cart is empty" }, { type: 'error' })
    return
  }

  const cart: CartItem[] = JSON.parse(cartData)
  const csrfToken = (document.querySelector("[name='csrf-token']") as HTMLMetaElement)?.content

  const payload: CheckoutPayload = {
    authenticity_token: csrfToken,
    cart: cart
  }

  fetch("/checkout", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken
    },
    body: JSON.stringify(payload)
  })
    .then(response => response.json())
    .then((data: CheckoutResponse | ErrorResponse) => {
      if ('error' in data) {
        this.addMessage({ message: data.error }, { type: 'error' })
      } else {
        window.location.href = data.url
      }
    })
    .catch(error => {
      this.addMessage({ message: "Checkout failed. Please try again." }, { type: 'error' })
    })
}
```

**VAT Calculation**:
- UK VAT is 20%
- Prices stored inclusive of VAT
- Ex VAT = Total / 1.2
- VAT Amount = Total - Ex VAT

## Business Rules

### Pricing
1. **Currency**: GBP only (pence storage)
2. **VAT**: 20% UK VAT (inclusive pricing)
3. **Display**: Divide pence by 100, format as £X,XXX.XX
4. **Historical Pricing**: OrderProduct.price captures price at purchase time

### Stock
1. **Validation**: Check stock at checkout creation
2. **Decrement**: Reduce stock in webhook after payment
3. **Race Condition**: Possible overselling if multiple customers checkout simultaneously
4. **No Reservation**: Stock not reserved during checkout process

### Shipping
1. **Geographic Restriction**: GB (United Kingdom) only
2. **Address Collection**: Required at Stripe checkout
3. **Options**: Collection (free), 3-5 days (£25), overnight (£50)
4. **Overnight Cutoff**: Order before 11:00am Mon-Thu

### Orders
1. **Immutable**: Once created, orders cannot be edited
2. **Fulfillment**: Boolean flag only (no status workflow)
3. **Email Only**: No customer login to view orders
4. **Admin Access**: Full order history via admin interface

## Common Patterns

### Price Formatting
```ruby
# Helper
def formatted_price(price)
  return '£0.00' if price.nil? || price.zero?
  number_to_currency(price / 100.0, unit: '£')
end
```

```typescript
// TypeScript
formatCurrency(price: number): string {
  return '£' + (price / 100).toLocaleString('en-GB', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}
```

### Stock Lookup
```ruby
# Get price for product (variant or product-level)
product_stock = product.stocks.find { |ps| ps.size == size }
price = product_stock ? product_stock.price : product.price
```

### Cart Management
```typescript
// Add to cart
const cart = JSON.parse(localStorage.getItem("cart") || "[]")
const existing = cart.find(item => item.id === id && item.size === size)
if (existing) {
  existing.quantity += 1
} else {
  cart.push({ id, name, price, size, quantity: 1 })
}
localStorage.setItem("cart", JSON.stringify(cart))
```

## Testing Considerations

### Stock Validation Edge Cases
- Zero stock should reject checkout
- Negative stock after decrement (data integrity issue)
- Multiple checkouts for last item (race condition)
- Stock variant vs product-level stock selection

### Price Capture
- Verify OrderProduct.price matches checkout price
- Test price changes don't affect existing orders
- Validate variant price vs product price selection

### Cart Persistence
- LocalStorage cleared on success page
- Cart survives page refresh
- Cart cleared on browser clear
- Empty cart edge cases

## Known Limitations

1. **No Overselling Protection**: Race condition between stock validation and webhook decrement
2. **No Customer Accounts**: Can't view order history without admin access
3. **Single Currency**: GBP only, no multi-currency support
4. **Geographic Restriction**: GB shipping only
5. **No Discount Codes**: No promotion/coupon system
6. **Synchronous Email**: Order email sent synchronously in webhook (no background job)
7. **No Inventory Alerts**: No low stock notifications
8. **No Product Reviews**: No user-generated content

## Future Enhancements

### Recommended
- Background job for order email sending
- Stock reservation during checkout (Redis-based locking)
- Customer accounts with order history
- Low stock admin alerts
- Discount code system

### Architectural Changes Required
- Multi-currency: Price model changes, currency conversion
- International shipping: Address validation, shipping rate calculation
- Product reviews: User-generated content model, moderation workflow
- Inventory management: Stock tracking, purchase orders, suppliers

