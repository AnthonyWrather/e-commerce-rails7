# Copilot Instructions for E-Commerce Rails 7 (Bitovi Analysis)

> **Generated**: November 22, 2025
> **Analysis Type**: Comprehensive Codebase Architecture & Domain Analysis
> **Project**: Composite Materials E-Commerce Platform with Material Calculators
> **Framework**: Ruby on Rails 7.1.2, TypeScript 5.3.3, PostgreSQL

---

## Quick Reference

### Project Identity
**Composite Materials B2B/B2C E-Commerce with Calculation Tools**

- **Domain**: Fiberglass and composite materials sales
- **Unique Feature**: Material quantity calculators (not found in typical e-commerce)
- **Architecture**: Monolithic Rails MVC with TypeScript/Stimulus frontend
- **Deployment**: Render.com with PostgreSQL, Stripe payments, AWS S3 storage

### Key Technologies
- **Backend**: Ruby 3.2.2, Rails 7.1.2, PostgreSQL, Devise, Stripe, Active Storage
- **Frontend**: TypeScript 5.3.3 (strict mode), Stimulus 3.2.2, Turbo Rails 8.0.4, Tailwind CSS
- **Build**: esbuild 0.19.11 (JavaScript bundler), Tailwind CLI
- **Infrastructure**: Docker (devcontainer), Puma, Redis (configured but minimal usage)

### Core Principles
1. **Simplicity Over Abstraction** - Fat controllers, anemic models, no service objects
2. **Convention Over Configuration** - Follows Rails conventions closely
3. **Guest Checkout Only** - No customer accounts, email-based orders
4. **Type Safety** - All Stimulus controllers use TypeScript with comprehensive interfaces
5. **UK-Focused** - GBP currency, GB shipping, 20% VAT, London timezone

---

## Technology Stack

### Programming Languages
- **Ruby 3.2.2** - Backend MVC logic
- **TypeScript 5.3.3** - Frontend with strict type checking
- **SQL** - PostgreSQL database (not SQLite anymore)
- **ERB** - View templates (Embedded Ruby)
- **CSS** - Tailwind utility framework + Font Awesome

### Primary Framework
**Ruby on Rails 7.1.2** - Full-stack MVC
- Active Record ORM (minimal business logic)
- Action Cable for WebSockets (configured, unused)
- Active Storage for images (AWS S3 production, local dev)
- Active Job (configured, unused - all synchronous)

### Frontend Stack
- **Hotwire** - Modern progressive enhancement
  - **Turbo Rails 8.0.4** - SPA-like navigation
  - **Stimulus 3.2.2** - Modest JavaScript framework
- **TypeScript** - Migrated from importmap, now esbuild-bundled
- **esbuild 0.19.11** - Fast JavaScript bundler
- **Tailwind CSS** - Utility-first styling
- **Chart.js 4.4.1** - Admin dashboard visualizations
- **Font Awesome SASS 6.5.1** - Icons

### Backend Integrations
- **Devise 4.9** - Admin-only authentication
- **Stripe 10.3** - Payment processing (GBP, webhook-driven orders)
- **AWS S3** - Production image storage (development uses local disk)
- **Redis 4.0.1+** - Action Cable support (minimal usage)
- **Pagy 6.2** - Pagination for admin tables
- **Breadcrumbs on Rails** - Navigation breadcrumbs

### Development Tools
- **RuboCop** - Code linting (many cops disabled for simplicity)
- **Letter Opener Web 3.0** - Email preview in development/test
- **Minitest** - Testing framework (not RSpec)
- **Capybara + Selenium** - System/browser tests
- **Foreman** - Process manager (Rails + Tailwind + JS build)

### Infrastructure
- **PostgreSQL** - Database (both dev and production)
- **Puma** - Web server (5 threads, auto-scaled workers)
- **Docker** - Devcontainer + production deployment
- **Node.js 20.x** - TypeScript build pipeline
- **VIPS** - Image processing for Active Storage variants

---

## Project Structure

### File Organization (225 files)
```
app/
├── assets/
│   ├── builds/         # esbuild + Tailwind output (762KB application.js)
│   ├── images/         # Static images
│   └── stylesheets/    # Tailwind directives, Font Awesome
├── channels/           # Action Cable (unused)
├── controllers/        # 20 controllers (fat controllers pattern)
│   ├── admin/          # 6 admin CRUD controllers
│   ├── quantities/     # 3 material calculator controllers
│   └── ...             # Public controllers (home, products, cart, checkout, webhooks)
├── helpers/            # 12 helper modules (mostly empty, some for price formatting)
├── javascript/         # 7 TypeScript files
│   ├── application.ts
│   └── controllers/    # 6 Stimulus controllers (TypeScript)
├── jobs/               # Active Job base (unused)
├── mailers/            # 2 mailers (OrderMailer)
├── models/             # 8 models (anemic, associations only)
├── views/              # 50 ERB templates
│   ├── admin/          # 30 admin views (CRUD scaffolding)
│   ├── quantities/     # 3 calculator views
│   └── ...             # Public views, layouts, mailers
bin/                    # 8 executable scripts
config/                 # 27 configuration files
db/                     # Schema + 17 migrations
documentation/          # 6 docs (README, PDFs, schema diagram)
public/                 # Static files, error pages
test/                   # 24 test files (Minitest, 36 runs, 55 assertions)
```

### Namespace Structure
- **Public** - `/` routes, customer-facing
- **Admin** - `/admin` routes, Devise authentication required
- **Quantities** - `/quantities` routes, material calculators

---

## Architectural Layers

### 1. Presentation Layer (Views)
**Two distinct layouts**:
- `application.html.erb` - Public (blue theme, navbar/footer)
- `admin.html.erb` - Admin (gray theme, sticky sidebar)

**View Patterns**:
- Server-rendered ERB templates
- Tailwind CSS utility classes
- Stimulus data attributes for interactivity
- Pagy pagination in admin
- Breadcrumbs in public views
- Font Awesome icons via helper

### 2. Client-Side Layer (TypeScript/Stimulus)
**No state management library** - LocalStorage for cart only

**Controllers**:
- `cart_controller.ts` - Cart rendering, checkout, localStorage, VAT calculations
- `products_controller.ts` - Size selection, add to cart, price updates
- `dashboard_controller.ts` - Chart.js revenue visualizations
- `quantities_controller.ts` - Calculator stub (server-side calculations)

**Type Safety**:
- Comprehensive interfaces (CartItem, Product, Stock, CheckoutPayload, etc.)
- Strict TypeScript mode enabled
- DOM element type casting (`as HTMLButtonElement`)
- Null safety with optional chaining
- No `.ts` extensions in imports

### 3. Application Layer (Controllers)
**Pattern**: Fat controllers with inline business logic

**Public Controllers**:
- `HomeController` - Landing page
- `CategoriesController` - Product browsing with price filtering
- `ProductsController` - Product details
- `CartsController` - Cart display (client-side rendering)
- `CheckoutsController` - Stripe session creation, stock validation
- `WebhooksController` - **Critical**: Order creation, stock decrement, email sending
- `ContactController` - Contact form stub (no mailer)
- `Quantities::*` - 3 material calculator controllers

**Admin Controllers**:
- `AdminController` - Dashboard with revenue charts
- `Admin::ProductsController` - Product CRUD, multi-image upload
- `Admin::CategoriesController` - Category CRUD, cascade delete
- `Admin::StocksController` - Variant pricing (nested under products)
- `Admin::OrdersController` - Order management (read-only, webhook creates)
- `Admin::ReportsController` - Revenue reports
- `Admin::ImagesController` - Image deletion

**Controller Conventions**:
- `@admin_*` instance variables in admin namespace
- `before_action :set_admin_*` for show/edit/update/destroy
- Pagy pagination: `@pagy, @admin_products = pagy(Product.all)`
- No scopes - inline `where` clauses

### 4. Domain Layer (Models)
**Pattern**: Anemic domain model - associations only, no business logic

**Models**:
```
Category (has_many products, has_one_attached image)
├── Product (belongs_to category, has_many stocks, has_many order_products, has_many_attached images)
    ├── Stock (belongs_to product) - size variants with individual pricing
    └── OrderProduct (belongs_to product, order)

Order (has_many order_products) - created via webhook only
AdminUser (Devise) - admin authentication only
```

**No Validations** - Relies on database NOT NULL constraints
**No Scopes** - Filtering in controllers
**No Callbacks** - Simple CRUD operations
**No Concerns** - Empty directory

### 5. Infrastructure Layer
- **PostgreSQL** - Persistent storage (development and production)
- **Stripe** - Payment processing + webhook order creation
- **AWS S3** - Production image storage (dev uses local disk)
- **Redis** - Action Cable (configured but unused)
- **SMTP/MailerSend** - Email delivery (Letter Opener in dev)

---

## Core Domain: E-Commerce

### Guest Checkout Model
- **No customer accounts** - Email-based order identification
- **Ephemeral cart** - LocalStorage only, cleared on success
- **No order history** - Customers can't view past orders
- **Admin-only auth** - Devise for admin users only

### Dual Pricing Strategy
1. **Single Price**: Product has `price` and `amount` directly
2. **Variant Pricing**: Product has Stocks with `size`, `price`, `amount`

**Price Storage**: Always in **pence** (integer)
**Display**: Divide by 100, format as `£X,XXX.XX`
**Capture**: OrderProduct.price captures price at purchase time (not calculated)

### Stock Management
- **Validation**: Checked at checkout creation (before Stripe)
- **Decrement**: Happens in webhook after payment (not at checkout)
- **No Reservation**: Race condition possible (no overselling protection)
- **Product-Level**: `Product.amount` for single-price items
- **Variant-Level**: `Stock.amount` for size variants

### Checkout Flow
```
1. Browse → CategoriesController#show (price filtering, active products)
2. Product → ProductsController#show (pass JSON to Stimulus)
3. Add to Cart → products_controller.ts (localStorage)
4. View Cart → cart_controller.ts (render from localStorage, VAT calc)
5. Checkout → CheckoutsController#create (validate stock, create Stripe session)
6. Pay → Stripe Checkout (external, collects shipping/billing/phone)
7. Webhook → WebhooksController#stripe (create Order, decrement stock, send email)
8. Success → CheckoutsController#success (cart cleared)
```

### Stripe Integration
- **Currency**: GBP (not USD)
- **Mode**: Payment (not subscription)
- **Shipping**: GB only, 3 options (Collection free, 3-5 days £25, Overnight £50)
- **Metadata**: product_id, size, product_stock_id, product_price
- **Webhook Signature**: Verified before order creation
- **Order Creation**: Exclusively via `checkout.session.completed` event

---

## Core Domain: Material Calculators

### Composite Material Mathematics
**Constants** (hardcoded):
- Roll width: 0.95m
- Resin to glass ratio: 1.6:1
- Wastage factor: 15%

**Material Types** (14 options):
- Chop Strand Mat: 300g, 450g, 600g
- Plain Weave: 285g, 400g
- Woven Roving: 450g, 600g, 800g, 900g
- Combination Mat: 450g, 600g, 900g
- Biaxial: 400g, 800g
- Gel Coat

### Calculator Types
1. **Area Calculator** - Input: area (m²), layers, material, catalyst %
2. **Dimensions Calculator** - Input: L, W, D, layers, material, catalyst %
3. **Mould Rectangle** - Input: L, W, D, layers, material, catalyst %

**Calculations**:
```
mat_length_m = (area × layers) / 0.95
mat_weight_kg = (area × layers) × (material_g_per_m² / 1000)
resin_litres = (area × layers) × 1.6
catalyst_ml = ((resin / 10) × catalyst_%) × 100
total_weight = mat_kg + resin_L + (catalyst_ml / 1000)

All values × 1.15 for 15% wastage
```

**Implementation**:
- GET requests with query params (bookmarkable)
- Calculations in controller (no model layer)
- No persistence (pure calculation)
- Turbo Frame rendering

---

## TypeScript Patterns

### Type Interfaces
```typescript
interface CartItem {
  id: number
  name: string
  price: number  // in pence
  size: string
  quantity: number
}

interface Product {
  id: number
  name: string
  price: number  // in pence
  // ... other fields
}

interface Stock {
  id: number
  size: string
  price: number  // in pence
  amount: number
  // ... other fields
}
```

### Stimulus Value Declarations
```typescript
static values = {
  size: String,           // Mutable
  product: Object,        // Readonly
  stock: Array,           // Readonly
  messageTimeout: Number  // Readonly with default
}

declare sizeValue: string  // Mutable (no readonly)
declare readonly productValue: Product
declare readonly stockValue: Stock[]
declare readonly messageTimeoutValue: number
```

### DOM Element Casting
```typescript
const table_body = document.getElementById("table_body") as HTMLTableSectionElement
const button = e.currentTarget as HTMLButtonElement
const meta = document.querySelector("[name='csrf-token']") as HTMLMetaElement
```

### LocalStorage Pattern
```typescript
const cartString = localStorage.getItem("cart") || "[]"
const cart: CartItem[] = JSON.parse(cartString) as CartItem[]

// Modify cart
cart.push({ id, name, price, size, quantity })

// Save
localStorage.setItem("cart", JSON.stringify(cart))
```

### Null Safety
```typescript
const priceEl = document.getElementById("price")
if (priceEl) {
  priceEl.textContent = this.formatCurrency(price)
}

// Or optional chaining
const csrfToken = document.querySelector("[name='csrf-token']")?.content
```

---

## Ruby/Rails Patterns

### Controller Patterns

#### Admin CRUD Standard
```ruby
class Admin::ProductsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_admin_product, only: %i[show edit update destroy]

  def index
    @pagy, @admin_products = pagy(Product.all)
  end

  private

  def set_admin_product
    @admin_product = Product.find(params[:id])
  end

  def admin_product_params
    params.require(:product).permit(:name, :description, :price, ...)
  end
end
```

#### Aggregations (No Scopes)
```ruby
@monthly_stats = {
  sales: Order.where(created_at: month_range).count,
  revenue: Order.where(created_at: month_range).sum(:total)&.round(),
  avg_sale: Order.where(created_at: month_range).average(:total)&.round(),
  items: OrderProduct.joins(:order).where(orders: { created_at: month_range }).sum(:quantity)
}
```

#### Stock Validation
```ruby
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

### Model Patterns

#### Active Storage
```ruby
class Product < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :medium, resize_to_limit: [250, 250]
  end
end

# Usage in views
<%= image_tag product.images.first.variant(:medium) %>
```

#### Duplicate Image Prevention
```ruby
# In Admin::ProductsController#update
if params[:admin_product][:images].present?
  params[:admin_product][:images].each do |image|
    @admin_product.images.each do |existing_image|
      if existing_image.filename == image.original_filename
        existing_image.purge
      end
    end
  end
end
```

### Helper Patterns

#### Price Formatting
```ruby
def formatted_price(price)
  return '£0.00' if price.nil? || price.zero?
  number_to_currency(price / 100.0, unit: '£')
end
```

#### Font Awesome Icons
```ruby
<%= icon('fa-solid', 'shopping-cart', class: 'mr-2') %>
```

### View Patterns

#### Form Helpers
```erb
<%= form_with model: [:admin, @admin_product] do |form| %>
  <%= form.label :price %><p class="text-xs text-gray-500">in pence</p>
  <%= form.number_field :price, class: "block shadow rounded-md..." %>

  <%= form.file_field :images, multiple: true %>
<% end %>
```

#### Stimulus Data Attributes
```erb
<div data-controller="products"
     data-products-product-value="<%= @product.to_json %>"
     data-products-stock-value="<%= @product.stocks.to_json %>">

  <button data-action="click->products#addToCart">Add to Cart</button>
</div>
```

#### Turbo Frames
```erb
<%= turbo_frame_tag "area" do %>
  <% if @mat.present? %>
    <!-- Results table -->
  <% end %>
<% end %>
```

---

## Data Flow Diagrams

### Order Creation Flow
```
Browser (cart_controller.ts)
  ├─ Read cart from localStorage
  ├─ POST /checkout with cart JSON + CSRF token
  └─ Redirect to Stripe

Rails (CheckoutsController#create)
  ├─ Parse cart JSON
  ├─ Validate stock (Product.amount or Stock.amount)
  ├─ Build Stripe line items with metadata
  ├─ Create Stripe::Checkout::Session
  └─ Return { url: stripe_session_url }

Stripe Checkout
  ├─ Customer enters payment details
  ├─ Customer enters shipping/billing addresses
  ├─ Customer selects shipping method (3 options)
  ├─ Process payment
  └─ Send webhook to /webhooks

Rails (WebhooksController#stripe)
  ├─ Verify webhook signature
  ├─ Extract checkout.session.completed event
  ├─ Create Order (customer_email, total, addresses, payment info)
  ├─ For each line item:
  │  ├─ Create OrderProduct (product_id, size, quantity, price)
  │  └─ Decrement stock (Product OR Stock)
  ├─ Send OrderMailer.new_order_email
  └─ Return 200 OK

Browser
  ├─ Stripe redirects to /success
  └─ cart_controller.ts clears localStorage
```

### Material Calculator Flow
```
Browser
  ├─ Fill form (area, layers, material, catalyst)
  └─ Submit (GET request)

Rails (Quantities::AreaController#index)
  ├─ Parse params (defaults: area=1.0, catalyst=1)
  ├─ Calculate mat length = (area × layers) / 0.95
  ├─ Calculate mat weight = area × layers × (material_g/1000)
  ├─ Calculate resin = area × layers × 1.6
  ├─ Calculate catalyst = (resin/10 × catalyst%) × 100
  ├─ Add 15% wastage to all
  └─ Render results in Turbo Frame

Browser (Turbo Frame)
  └─ Update results table without full page reload
```

---

## Configuration & Secrets

### Credentials (Not ENV Vars in Dev)
```bash
EDITOR="code --wait" rails credentials:edit
```

**Required Credentials**:
```yaml
stripe:
  secret_key: sk_...
  webhook_key: whsec_...
aws:
  access_key_id: AKIA...
  secret_access_key: ...
```

**Fallback to ENV**: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_KEY`

### Database
- **Development**: PostgreSQL via Docker (`host: postgres`, user/pass: `postgres`)
- **Production**: PostgreSQL via `DATABASE_URL` (Render.com)

### Active Storage
- **Development**: Local disk (`storage/`)
- **Production**: AWS S3 (bucket: `e-commerce-rails7-aws-s3-bucket`, region: `eu-central-1`)

### Email
- **Development**: Letter Opener Web (`/letter_opener`)
- **Production**: SMTP via MailerSend (host, port, username, password from ENV)

---

## Development Workflow

### Initial Setup
```bash
bin/rails db:migrate       # Run migrations
yarn install               # Install JavaScript dependencies
yarn build                 # Build TypeScript → JavaScript (762KB)
bin/dev                    # Foreman: Rails + Tailwind + JS watch
```

### TypeScript Development
```bash
yarn build                 # One-time build
yarn build:ts              # Type-check + build
yarn build --watch         # Watch mode (via bin/dev)
tsc --noEmit               # Type-check only
```

### Create Admin Users
```bash
bin/rails c
AdminUser.create(email: "admin@example.com", password: "12345678")
```

### Email Testing
Letter Opener Web (dev/test): `http://localhost:3000/letter_opener`

### Ngrok for Stripe Webhooks (Local)
```bash
ngrok http --url=YOUR-SUBDOMAIN.ngrok-free.app 3000
```

Add to `config/environments/development.rb`:
```ruby
config.hosts << "YOUR-SUBDOMAIN.ngrok-free.app"
```

### Testing
```bash
bin/rails test             # Unit + integration tests (36 runs, 55 assertions)
bin/rails test:system      # Capybara system tests
rubocop -a                 # Safe RuboCop fixes
```

---

## Deployment (Render.com)

### Build Script (`bin/render-build.sh`)
```bash
bundle install
bundle exec rails assets:precompile  # Includes yarn build
bundle exec rails assets:clean
bundle exec rails db:migrate
```

### Start Command
```bash
bundle exec puma -C config/puma.rb
```

### Environment Variables
- `DATABASE_URL` - PostgreSQL connection (auto from Render)
- `RAILS_MASTER_KEY` - Credentials decryption key
- `WEB_CONCURRENCY=2` - Puma worker count
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_KEY` - Stripe API keys

### Dockerfile (Multi-Stage)
1. **Base**: Ruby 3.2.2-slim, production gems
2. **Build**: Node.js 20.x, yarn, install deps, yarn build, assets:precompile
3. **Final**: Non-root rails user, minimal packages, expose port 3000

---

## Common Gotchas

1. **Letter Opener in Production**: Currently mounted (TODO: restrict to dev/test)
2. **Currency**: GBP not USD - ensure Stripe dashboard matches
3. **Stock Timing**: Decremented in webhook, not checkout (race condition possible)
4. **Timezone**: London (not UTC)
5. **Credentials**: Use `rails credentials:edit` not `.env` in development
6. **Price Storage**: Always pence (multiply by 100 before saving)
7. **Cart State**: Cleared on success, stored in localStorage only
8. **TypeScript Build**: Must run `yarn build` before deploying (automated in render-build.sh)
9. **Type Casting**: Use proper types for DOM elements and localStorage parsing
10. **Import Extensions**: Don't use `.ts` extensions in TypeScript imports

---

## Testing Patterns

### Minitest (Not RSpec)
- **Unit Tests**: `test/models/` (mostly stubs)
- **Controller Tests**: `test/controllers/` (integration tests)
- **System Tests**: `test/system/` (Capybara + Selenium Chrome)
- **Fixtures**: `test/fixtures/` (minimal test data)

**Run Tests**:
```bash
bin/rails test             # All unit/integration
bin/rails test:system      # Browser tests
bin/rails test:all         # Everything
```

**Current Status**: 36 runs, 55 assertions, 0 failures, 1 skip

### Known Issue
Tests reference `Admin::` namespaced models (e.g., `Admin::Product.count`) but models are in root namespace. This is a convention inconsistency.

---

## Architectural Constraints

### Features Within Scope
✅ Product catalog with categories
✅ Variant pricing (size-based)
✅ Multi-image galleries
✅ Guest checkout (no accounts)
✅ Stripe payment processing
✅ Email order confirmations
✅ Stock management (product + variant level)
✅ Admin authentication (Devise)
✅ Material calculators (unique feature)
✅ Revenue reporting (Chart.js)

### Features Architecturally Inconsistent
❌ **Customer accounts** - Guest checkout only
❌ **Wish lists** - No user persistence
❌ **Order history for customers** - No customer login
❌ **Reviews/ratings** - No user-generated content model
❌ **Saved carts** - Ephemeral localStorage only
❌ **Multiple currencies** - Hardcoded GBP
❌ **International shipping** - GB-only restriction
❌ **Discount codes** - No promotion system
❌ **Real-time inventory** - No WebSocket implementation
❌ **Background jobs** - All synchronous (email sent in webhook)
❌ **API endpoints** - Traditional server-rendered views
❌ **Multi-vendor** - Single vendor model
❌ **Subscriptions** - One-time purchases only

---

## Coding Guidelines

### Ruby Style
- **Frozen String Literals**: All files start with `# frozen_string_literal: true`
- **RuboCop**: Many cops disabled (Documentation, LineLength, all Metrics)
- **No Service Objects**: Business logic in controllers
- **No Concerns**: Empty directory
- **No Validations**: Database constraints only
- **No Scopes**: Inline `where` clauses

### TypeScript Style
- **Strict Mode**: Enabled in tsconfig.json
- **Interfaces**: Define for all data structures
- **Type Declarations**: Use `declare readonly` for Stimulus values
- **DOM Casting**: Always cast getElementById results
- **Null Safety**: Use optional chaining and null checks
- **No Extensions**: Import without `.ts` extensions

### View Style
- **Tailwind Classes**: Utility-first approach
- **No Custom CSS**: Minimal custom styles
- **Stimulus Actions**: `data-action="click->controller#method"`
- **Stimulus Values**: `data-controller-value-name="<%= json %>"`
- **Pagy Pagination**: `pagy_nav(@pagy) if @pagy.pages > 1`
- **Breadcrumbs**: `add_breadcrumb 'Label', :path` in controller

### Naming Conventions
- **Models**: Singular (`product.rb`)
- **Controllers**: Plural + `_controller.rb` (`products_controller.rb`)
- **Admin Variables**: `@admin_product` (not `@product`)
- **Namespaces**: `Admin::`, `Quantities::`
- **Tests**: Match source file + `_test.rb`

---

## Domain-Specific Knowledge

### Composite Materials
- **Fiberglass**: Glass fibers in resin matrix
- **Chop Strand Mat**: Random fiber orientation (general purpose)
- **Woven Roving**: Woven fibers (higher strength)
- **Gel Coat**: Surface finish (not structural)

### Material Calculations
- **Roll Width**: 0.95m standard for fiberglass mat
- **Resin Ratio**: 1.6:1 is industry approximation (varies by technique)
- **Wastage**: 15% accounts for overlap, trimming, mistakes
- **Catalyst**: 1-2% typical (higher = faster cure, more heat)

### UK E-Commerce
- **VAT**: 20% Value Added Tax (inclusive pricing)
- **Shipping**: GB (United Kingdom) only
- **Currency**: GBP (pence storage, divide by 100 for display)
- **Timezone**: Europe/London

---

## Extension Points

### Easy Additions
✅ More material types and calculators
✅ Additional product categories
✅ More shipping options
✅ Additional admin reports/charts
✅ Email template improvements
✅ More Stimulus controllers (TypeScript)
✅ Product filtering enhancements

### Challenging Additions (Requires Refactoring)
⚠️ Customer accounts (major architecture shift)
⚠️ Multi-currency (price model changes)
⚠️ International shipping (address validation, rates)
⚠️ Real-time features (WebSocket implementation)
⚠️ API endpoints (serializers, authentication)
⚠️ Background jobs (worker process, queue)
⚠️ Service layer (refactoring from controllers)
⚠️ Caching strategy (cache key management)

---

## Quick Command Reference

### Development
```bash
bin/dev                                    # Start all processes (Rails + Tailwind + JS)
bin/rails c                                # Console
bin/rails db:migrate                       # Run migrations
yarn build                                 # Build TypeScript
yarn build:ts                              # Type-check + build
rubocop -a                                 # Safe auto-fixes
bin/rails test                             # Run unit tests
bin/rails test:system                      # Run system tests
EDITOR="code --wait" rails credentials:edit # Edit encrypted credentials
```

### Production (Render)
```bash
bin/render-build.sh                        # Build script
bundle exec puma -C config/puma.rb         # Start server
```

### Docker
```bash
docker build -f Dockerfile -t e-commerce-rails7 .
docker run -p 3000:3000 -v $(PWD):/rails e-commerce-rails7
```

---

## Project Contacts & Resources

### URLs
- **Dev**: `http://localhost:3000`
- **Dev External**: `https://YOUR-SUBDOMAIN.ngrok-free.app`
- **Test**: `https://e-commerce-rails7.onrender.com`
- **Production**: `https://shop.cariana.tech` (not yet deployed)

### Admin Access
- **Dev**: `http://localhost:3000/admin_users/sign_in`
- Email: Create via `bin/rails c` → `AdminUser.create(...)`

### External Integrations
- **Stripe**: Dashboard for payments and webhooks
- **AWS S3**: Console for image storage
- **Render**: Dashboard for deployments
- **Ngrok**: Webhook testing in development

---

## Summary

This is a **specialized B2B/B2C e-commerce platform** for composite materials with unique material quantity calculators. Built with **Rails 7.1.2 + TypeScript 5.3.3**, using **Stripe for payments** (GBP, GB shipping), **PostgreSQL database**, and **AWS S3 for images**.

**Architecture Philosophy**: Deliberately simple and Rails-conventional, avoiding abstraction layers in favor of straightforward controller-based logic. Recent TypeScript migration demonstrates commitment to type safety while maintaining Rails conventions.

**Domain Constraints**: Composite material mathematics (ratios, wastage), UK-specific commerce (VAT, shipping), Stripe-dependent payment flow (webhook-driven order creation), guest checkout only (no customer accounts).

**Unique Differentiator**: Material quantity calculators with composite material domain expertise - not found in typical e-commerce platforms.

