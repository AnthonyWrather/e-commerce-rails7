# Architectural Domains

## Overview
This application follows a **Monolithic Rails MVC architecture** with clear separation between public-facing e-commerce functionality and admin management. The architecture is **deliberately simple**, avoiding common Rails patterns like service objects, concerns, and API layers in favor of straightforward controller-based logic.

## Domain Layer Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│  Public Views (ERB)        │        Admin Views (ERB)           │
│  - Product catalog         │        - Dashboard & reports       │
│  - Shopping cart           │        - CRUD interfaces           │
│  - Material calculators    │        - Order management          │
│  - Checkout flow           │                                    │
├────────────────────────────┴────────────────────────────────────┤
│                     CLIENT-SIDE LAYER                            │
├──────────────────────────────────────────────────────────────────┤
│  TypeScript/Stimulus Controllers                                 │
│  - cart_controller (localStorage, checkout)                      │
│  - products_controller (size selection, add to cart)             │
│  - dashboard_controller (Chart.js visualizations)                │
│  - quantities_controller (calculator stub)                       │
├──────────────────────────────────────────────────────────────────┤
│                     APPLICATION LAYER                            │
├──────────────────────────────────────────────────────────────────┤
│  Controllers (Business Logic)                                    │
│  ┌──────────────────────┬──────────────────────────────────────┐│
│  │ Public Controllers   │ Admin Controllers                    ││
│  │ - Home              │ - AdminController (dashboard)        ││
│  │ - Categories        │ - Admin::ProductsController          ││
│  │ - Products          │ - Admin::CategoriesController        ││
│  │ - Carts             │ - Admin::StocksController            ││
│  │ - Checkouts         │ - Admin::OrdersController            ││
│  │ - Webhooks          │ - Admin::ReportsController           ││
│  │ - Contact           │ - Admin::ImagesController            ││
│  │ - Quantities::*     │                                       ││
│  └──────────────────────┴──────────────────────────────────────┘│
├──────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                              │
├──────────────────────────────────────────────────────────────────┤
│  Models (Data & Associations Only)                               │
│  - Category → Products                                           │
│  - Product → Stocks, OrderProducts, Images (Active Storage)     │
│  - Stock (variant pricing)                                       │
│  - Order → OrderProducts                                         │
│  - OrderProduct (line items)                                     │
│  - AdminUser (Devise authentication)                             │
├──────────────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE LAYER                          │
├──────────────────────────────────────────────────────────────────┤
│  External Services & Storage                                     │
│  - PostgreSQL (database)                                         │
│  - Stripe (payment processing + webhooks)                        │
│  - AWS S3 (production image storage)                             │
│  - Redis (Action Cable, unused)                                  │
│  - SMTP/MailerSend (email delivery)                              │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Presentation Layer

### Public-Facing Views
**Purpose**: Customer-facing HTML interfaces

**Components**:
- **Home Page** - Landing page with hero, featured products, newsletter signup
- **Category Browsing** - Product grid with price filtering
- **Product Details** - Image gallery, description, size selection, add to cart
- **Shopping Cart** - Cart summary with VAT breakdown
- **Checkout Flow** - Success/cancel pages (Stripe handles payment form)
- **Material Calculators** - Form-based calculation tools with results display
- **Contact Form** - Basic contact form (no backend logic)

**Layout**: `app/views/layouts/application.html.erb`
- Navbar with category navigation
- Footer with contact info
- Breadcrumbs (breadcrumbs_on_rails)
- Tailwind CSS styling
- Font Awesome icons

**Characteristics**:
- Server-rendered ERB templates
- Turbo for SPA-like navigation
- Stimulus controllers for interactivity
- No React, Vue, or Angular

### Admin Dashboard Views
**Purpose**: Admin management interfaces

**Components**:
- **Dashboard** - Revenue charts, monthly statistics
- **Product Management** - CRUD with multi-image upload
- **Category Management** - CRUD with cascade delete
- **Stock Management** - Variant pricing (nested under products)
- **Order Management** - Order listing, fulfillment tracking
- **Reports** - Monthly/daily revenue visualizations

**Layout**: `app/views/layouts/admin.html.erb`
- Sticky sidebar navigation
- Gray color scheme (vs blue public site)
- Devise authentication required
- Pagy pagination

**Characteristics**:
- Traditional CRUD scaffolding
- JSON builders for API responses (minimal)
- Chart.js for data visualization
- No real-time updates (page refresh required)

### Email Templates
**Purpose**: Transactional email rendering

**Components**:
- **Order Confirmation** - HTML and text versions
- **Layout** - Mailer-specific layouts

**Mailer**: `OrderMailer`
- Triggered in Stripe webhook handler
- Letter Opener Web for preview (dev)
- SMTP delivery (production)

## 2. Client-Side Layer

### TypeScript/Stimulus Controllers
**Purpose**: Progressive enhancement with type-safe JavaScript

**Architecture**:
- **Stimulus** - Modest JavaScript framework (Hotwire stack)
- **TypeScript** - Strict type checking, interfaces
- **esbuild** - Fast bundler (no webpack)
- **No State Management Library** - LocalStorage for cart, Stimulus values for data passing

**Controllers**:

#### cart_controller.ts
- **Responsibilities**:
  - Render cart from localStorage
  - Calculate VAT totals
  - POST checkout to Rails backend
  - Remove items, clear cart
  - Flash messages
- **Data Flow**:
  - Read: `localStorage.getItem("cart")` → CartItem[]
  - Write: Modifies cart array → `localStorage.setItem("cart")`
  - Submit: POST /checkout → Stripe session redirect
- **Type Safety**: CartItem, CheckoutPayload, CheckoutResponse interfaces

#### products_controller.ts
- **Responsibilities**:
  - Size variant selection
  - Update displayed price
  - Add to cart (localStorage)
  - Flash messages
- **Data Flow**:
  - Input: Stimulus values (product, stocks from Rails JSON)
  - Output: Updated localStorage cart
- **Type Safety**: Product, Stock, MessageOptions interfaces

#### dashboard_controller.ts
- **Responsibilities**:
  - Render Chart.js revenue charts
  - Multiple charts per page support
- **Data Flow**:
  - Input: Revenue data from Stimulus value (Rails JSON)
  - Output: Chart.js canvas rendering
- **Type Safety**: Array<[string, number]> for revenue data

#### quantities_controller.ts
- **Responsibilities**: Stub for future calculator enhancements
- **Current State**: Minimal implementation
- **Note**: Calculations done server-side in controllers

**Patterns**:
- No Stimulus targets (uses `getElementById`)
- Type casting for DOM elements (`as HTMLButtonElement`)
- Null safety with optional chaining
- No `.ts` extensions in imports
- Declare readonly for immutable Stimulus values

### Hotwire Stack
- **Turbo Drive** - SPA-like navigation (automatic)
- **Turbo Frames** - Partial page updates (minimal usage, mainly calculators)
- **Turbo Streams** - Real-time updates (not implemented)

## 3. Application Layer (Controllers)

### Public Controllers
**Purpose**: Handle customer-facing HTTP requests

**Pattern**: Fat controllers (business logic inline)

#### HomeController
- **Route**: `GET /`
- **Action**: `index` - Render landing page
- **Logic**: None (static page)

#### CategoriesController
- **Route**: `GET /categories/:id`
- **Action**: `show` - Category with filtered products
- **Logic**:
  - Load category
  - Filter products (active only)
  - Apply price range (min/max in pence)
  - No scopes (inline `where` clauses)

#### ProductsController
- **Route**: `GET /products/:id`
- **Action**: `show` - Product details
- **Logic**:
  - Load product with stocks
  - Pass to view as JSON for Stimulus
  - No stock validation (done at checkout)

#### CartsController
- **Route**: `GET /cart`
- **Action**: `show` - Render cart page
- **Logic**: None (cart rendered client-side from localStorage)

#### CheckoutsController
- **Routes**: `POST /checkout`, `GET /success`, `GET /cancel`
- **Actions**:
  - `create` - Build Stripe session, validate stock, redirect to Stripe
  - `success` - Order confirmation page
  - `cancel` - Checkout cancelled page
- **Logic**:
  - Parse cart JSON from params
  - Validate stock availability (product or variant level)
  - Build Stripe line items with metadata
  - Create Stripe Checkout Session
  - Return redirect URL
  - **Stock NOT decremented here** (done in webhook)

**Checkout Flow**:
1. User clicks "Checkout" in cart
2. Stimulus controller POSTs cart to `/checkout`
3. Rails validates stock, creates Stripe session
4. Redirect to Stripe Checkout
5. User completes payment on Stripe
6. Stripe sends webhook to `/webhooks`
7. Rails creates Order, decrements stock, sends email
8. Redirect to `/success`

#### WebhooksController
- **Route**: `POST /webhooks`
- **Action**: `stripe` - Handle Stripe events
- **Logic**:
  - Verify webhook signature
  - Handle `checkout.session.completed` event
  - Create Order and OrderProducts
  - Decrement stock (product or variant)
  - Send order confirmation email
  - Return 200 OK
- **Critical**: This is where orders are created and stock is decremented

**Webhook Flow**:
```
Stripe webhook → WebhooksController#stripe
├── Verify signature
├── Parse checkout session
├── Extract line items metadata
├── Create Order (email, totals, addresses)
├── Create OrderProducts (price captured)
├── Decrement stock (Product.amount or Stock.amount)
├── Send OrderMailer.new_order_email
└── Return 200 OK
```

#### ContactController
- **Routes**: `GET /contact`, `POST /contact`
- **Actions**:
  - `index` - Contact form
  - `create` - Form submission (stub, no email sent)
- **Logic**: Flash message only (no mailer)

#### QuantitiesController
- **Route**: `GET /quantities`
- **Action**: `index` - Calculator selection page
- **Logic**: None (static page)

### Quantities Namespace Controllers
**Purpose**: Material calculation tools

**Pattern**: GET requests with query parameters, calculations in controller

#### Quantities::AreaController
- **Route**: `GET /quantities/area`
- **Action**: `index` - Area-based material calculations
- **Logic**:
  - Parse params (area, layers, material, catalyst)
  - Constants: material_width = 0.95m, ratio = 1.6:1
  - Calculate:
    - Mat length (m) = (area * layers) / material_width
    - Mat weight (kg) = area * layers * material_weight
    - Resin (L) = area * layers * ratio
    - Catalyst (ml) = (resin / 10) * catalyst_percentage * 100
    - Total weight = mat + resin + catalyst
    - Add 15% wastage to all
  - Render results in Turbo Frame

#### Quantities::DimensionsController
- **Route**: `GET /quantities/dimensions`
- **Action**: `index` - Dimension-based calculations
- **Logic**:
  - Parse params (length, width, depth, layers, material, catalyst)
  - Calculate area: length * width + 2 * (length * depth) + 2 * (width * depth)
  - Same calculation logic as AreaController

#### Quantities::MouldRectangleController
- **Route**: `GET /quantities/mould_rectangle`
- **Action**: `index` - Rectangular mould calculations
- **Logic**:
  - Same as DimensionsController
  - Calculates all 6 faces of rectangle

**Calculation Patterns**:
- **No model layer** - all calculations in controller
- **No persistence** - pure calculation, no database
- **Bookmarkable** - GET requests with params in URL
- **Turbo Frames** - Results update without full page reload
- **Material Types**: 14 options (Chop Strand, Woven Roving, etc.)

### Admin Namespace Controllers
**Purpose**: Admin CRUD operations with authentication

**Pattern**: RESTful resources with Devise authentication

#### AdminController
- **Route**: `GET /admin`
- **Action**: `index` - Admin dashboard
- **Logic**:
  - Calculate monthly statistics (sales, revenue, avg sale, etc.)
  - Group orders by day for revenue chart
  - Fill missing days with 0 revenue
  - Pass to Chart.js via Stimulus values
- **Aggregations**:
  ```ruby
  Order.where(created_at: month_range).count # sales
  Order.where(created_at: month_range).sum(:total) # revenue
  Order.where(created_at: month_range).average(:total) # avg sale
  OrderProduct.joins(:order).where(orders: { created_at: month_range }).sum(:quantity) # items sold
  ```

#### Admin::ProductsController
- **Routes**: RESTful (index, show, new, create, edit, update, destroy)
- **Actions**: Standard CRUD
- **Special Logic**:
  - **update**: Delete existing image if duplicate filename before attaching new
  - **destroy**: Soft delete via Active Storage purge
  - Multi-image upload with Active Storage
  - Image variants (thumb 50x50, medium 250x250)
- **Pagination**: Pagy gem
- **Variables**: `@admin_product` (not `@product`)

#### Admin::CategoriesController
- **Routes**: RESTful
- **Actions**: Standard CRUD
- **Special Logic**: Cascade delete products on category destroy
- **Variables**: `@admin_category`

#### Admin::StocksController
- **Routes**: Nested under products (`/admin/products/:product_id/stocks`)
- **Actions**: RESTful CRUD
- **Logic**: Manage size variants with individual pricing
- **Variables**: `@admin_stock`, `@admin_product`

#### Admin::OrdersController
- **Routes**: RESTful (read-only, index/show)
- **Actions**: index, show (no create/edit/destroy)
- **Logic**:
  - Orders created via webhook only
  - Fulfillment toggle (update action)
  - Order details with line items
- **Variables**: `@admin_order`

#### Admin::ReportsController
- **Route**: `GET /admin/reports`
- **Action**: `index` - Revenue reports
- **Logic**:
  - Same calculations as AdminController
  - Current month + previous month
  - Two Chart.js instances (different elementId values)
  - VAT calculations (Ex VAT = total / 1.2)

#### Admin::ImagesController
- **Route**: `DELETE /admin/products/:product_id/images/:id`
- **Action**: `destroy` - Delete product image
- **Logic**: Active Storage purge, redirect to product

**Admin Controller Patterns**:
- `before_action :authenticate_admin_user!` (Devise)
- `before_action :set_admin_resource` (for show/edit/update/destroy)
- `@admin_*` instance variables (namespace convention)
- Pagy pagination on index actions
- JSON builders for API responses (minimal usage)

## 4. Domain Layer (Models)

### Data Models
**Purpose**: Database schema and ActiveRecord associations

**Pattern**: Anemic domain model (no business logic)

#### Category
```ruby
has_many :products, dependent: :destroy
has_one_attached :image # Active Storage
# Fields: name, description
```
- **Cascade Delete**: Destroying category deletes products
- **Image**: Single image with thumb variant

#### Product
```ruby
belongs_to :category
has_many :stocks
has_many :order_products
has_many_attached :images # Active Storage
# Fields: name, description, price (pence), amount (stock), active,
#         weight, length, width, height
```
- **Dual Pricing**: Can have direct price OR rely on stock variants
- **Images**: Multiple images with variants (thumb, medium)
- **Dimensions**: For shipping calculations

#### Stock
```ruby
belongs_to :product
# Fields: size, amount, price (pence), weight, length, width, height
```
- **Variant Pricing**: Each size has individual price and stock level
- **Dimensions**: Override product dimensions if needed

#### Order
```ruby
has_many :order_products
# Fields: customer_email, fulfilled, total (pence), address, name, phone,
#         billing_name, billing_address, payment_status, payment_id,
#         shipping_cost (pence), shipping_id, shipping_description
```
- **No User Association**: Guest checkout only
- **Immutable**: Created via webhook, no editing
- **Fulfilled**: Boolean flag for order tracking

#### OrderProduct
```ruby
belongs_to :product
belongs_to :order
# Fields: product_id, order_id, size, quantity, price (pence)
```
- **Join Table**: Links orders to products
- **Price Capture**: Stores price at time of purchase (not calculated)
- **Size Tracking**: Records selected variant

#### AdminUser
```ruby
# Devise model
# Fields: email, encrypted_password, reset_password_token,
#         reset_password_sent_at, remember_created_at
```
- **Authentication**: Devise database_authenticatable, recoverable, rememberable
- **No Public Users**: Admin-only authentication

#### ProductStock
```ruby
# Legacy model - appears unused
```
- **Status**: Not referenced in codebase (use Stock instead)

**Model Patterns**:
- **No Validations**: Relies on database NOT NULL constraints
- **No Scopes**: Filtering done in controllers
- **No Callbacks**: Simple CRUD operations
- **No Concerns**: Empty concerns directory
- **No Methods**: Pure data models with associations only

### Active Storage Integration
- **Attachments**: `has_one_attached`, `has_many_attached`
- **Variants**: Defined inline (`:thumb`, `:medium`)
- **Storage**:
  - Development: Local disk (`storage/`)
  - Production: AWS S3 (configured in credentials)
- **Image Processing**: VIPS (not ImageMagick)

## 5. Infrastructure Layer

### Database (PostgreSQL)
**Purpose**: Persistent data storage

**Configuration**:
- **Development**: PostgreSQL via Docker devcontainer
- **Production**: PostgreSQL via `DATABASE_URL` (Render.com)
- **Connection**: `host: postgres`, user/pass: `postgres`

**Schema Management**:
- Migrations in `db/migrate/`
- Schema in `db/schema.rb` (auto-generated)
- Iterative evolution (17 migrations)

**Backup Tables**:
- `products_backup`, `stocks_backup` - Historical snapshots

### Payment Processing (Stripe)
**Purpose**: Handle online payments securely

**Integration Points**:
1. **Checkout Session Creation** (CheckoutsController)
   - Creates Stripe Checkout Session
   - Line items with product metadata
   - Shipping options (3 choices)
   - Redirects to Stripe-hosted checkout
2. **Webhook Handler** (WebhooksController)
   - Receives `checkout.session.completed` event
   - Verifies webhook signature
   - Creates Order and OrderProducts
   - Decrements stock
3. **Configuration**:
   - Secret key in credentials (`stripe.secret_key`)
   - Webhook key in credentials (`stripe.webhook_key`)
   - Currency: GBP (not USD)
   - Mode: Payment (not subscription)

**Stripe Flow**:
```
Browser → Rails (validate stock)
       → Stripe (create session)
       → Stripe Checkout (user pays)
       → Stripe Webhook → Rails (create order)
       → Email confirmation
       → Redirect to /success
```

### Cloud Storage (AWS S3)
**Purpose**: Production image storage

**Configuration**:
- **Service**: Amazon S3
- **Region**: eu-central-1
- **Bucket**: e-commerce-rails7-aws-s3-bucket
- **Credentials**: In `credentials.yml.enc` (aws:access_key_id, aws:secret_access_key)
- **Development**: Local disk storage

**Active Storage**:
- Polymorphic attachments (products, categories)
- Variant generation with VIPS
- Direct uploads not implemented (server-side only)

### Email Delivery
**Purpose**: Send transactional emails

**Configuration**:
- **Development**: Letter Opener Web (browser preview)
- **Production**: SMTP via MailerSend
  - Host, port, username, password from ENV vars
  - STARTTLS enabled
  - Port 587

**Mailers**:
- `OrderMailer.new_order_email` - Triggered in webhook handler
- Default from: `scfs@cariana.tech` (TODO: update)

### Caching & Background Jobs
**Current State**: Configured but not actively used

**Redis**:
- Configured for Action Cable
- Development: `redis://localhost:6379/1`
- Production: `REDIS_URL` ENV var
- **Usage**: Minimal (no WebSocket channels defined)

**Active Job**:
- Queue adapter not specified (defaults to inline)
- No custom job classes
- Email sent synchronously
- **Opportunity**: Move email sending to background job

### Web Server (Puma)
**Configuration**:
- **Threads**: 5 (configurable via `RAILS_MAX_THREADS`)
- **Workers**: Auto-scaled to CPU count in production (`WEB_CONCURRENCY`)
- **Port**: 3000 (configurable via `PORT`)
- **Preload App**: Enabled for memory efficiency

## Cross-Cutting Concerns

### Authentication & Authorization
- **Framework**: Devise (admin users only)
- **Strategy**: Database authenticatable, recoverable, rememberable
- **Routes**: `devise_for :admin_users`
- **Controllers**: `before_action :authenticate_admin_user!` in admin namespace
- **No Public Users**: Guest checkout only, no customer accounts

### Pagination
- **Library**: Pagy
- **Usage**: Admin index pages (products, categories, orders, stocks)
- **Pattern**: `@pagy, @admin_products = pagy(Product.all)`
- **View**: `pagy_nav(@pagy) if @pagy.pages > 1`

### Navigation
- **Breadcrumbs**: breadcrumbs_on_rails gem
- **Pattern**: `add_breadcrumb 'Label', :path` in controller
- **Rendering**: `render_breadcrumbs separator: ' / '` in navbar
- **Hierarchy**: Home → Category → Product

### Form Helpers
- **Icon Helper**: `icon('fa-solid', 'shopping-cart')` - Font Awesome integration
- **Price Helper**: `formatted_price(price)` - Divides pence by 100, formats as £X,XXX.XX
- **Pagy Helper**: `pagy_nav(@pagy)` - Pagination UI

### Error Handling
- **Validation**: Minimal (database constraints)
- **Stock Validation**: In CheckoutsController before Stripe session
- **Stripe Errors**: Signature verification in webhook handler
- **User Feedback**: Flash messages (server-side), Stimulus messages (client-side)

## Architecture Principles

### Simplicity Over Abstraction
- **No Service Objects**: Business logic in controllers
- **No Concerns**: Empty directory
- **No Decorators/Presenters**: Logic in views/helpers
- **No API Layer**: Traditional server-rendered app

### Convention Over Configuration
- **Rails Defaults**: Follows Rails conventions closely
- **RESTful Routes**: Standard resourceful routing
- **MVC Pattern**: Clear separation of concerns
- **Naming Conventions**: Consistent across codebase

### Progressive Enhancement
- **Server-Rendered**: Works without JavaScript
- **Stimulus Enhancement**: Adds interactivity progressively
- **Turbo Drive**: SPA-like navigation without full JS framework
- **LocalStorage**: Client-side cart persistence (non-critical)

### Type Safety (Recent Addition)
- **TypeScript Migration**: All Stimulus controllers converted
- **Strict Mode**: Enabled with comprehensive interfaces
- **Build Pipeline**: esbuild for fast compilation
- **Developer Experience**: IDE autocomplete, compile-time errors

## Domain Boundaries

### Clear Separation
1. **Public vs Admin**: Separate namespaces, layouts, controllers
2. **E-Commerce vs Calculators**: Different concerns (sales vs tools)
3. **Client vs Server**: Clear data flow (localStorage → POST → webhook)
4. **Presentation vs Logic**: Views render, controllers calculate

### Coupling Points
- **Stripe Integration**: Tightly coupled to checkout and webhook flow
- **Active Storage**: Images coupled to products and categories
- **Devise**: Admin authentication coupled to admin namespace
- **LocalStorage**: Cart state coupled to Stimulus controller

### Extension Points
- **New Calculators**: Add to quantities namespace
- **New Admin Resources**: Add to admin namespace
- **New Product Attributes**: Add columns via migrations
- **New Charts**: Add Chart.js instances to dashboard

## Summary

This application uses a **traditional monolithic Rails architecture** with:
- **Fat controllers** handling business logic
- **Anemic models** with associations only
- **Server-rendered views** with progressive enhancement
- **TypeScript/Stimulus** for client-side interactivity
- **External services** (Stripe, S3) for payments and storage
- **Clear namespace separation** (public, admin, quantities)

The architecture prioritizes **simplicity and Rails conventions** over abstraction layers, making it easy to understand and modify but potentially challenging to test in isolation or extract into microservices.

