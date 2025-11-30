# Copilot Instructions for E-Commerce Rails 7

> **Quick Reference**: Rails 7.1.2 | Ruby 3.2.3 | PostgreSQL 17 | TypeScript 5.3.3 | Minitest | Deployed on Render

## Project Overview
B2B/B2C composite materials e-commerce platform with **material quantity calculators** for fiberglass project estimation. Features variant pricing, guest checkout, Stripe payments (GBP), and admin dashboard with revenue analytics.

**Key Architecture**: Rails MVC + Hotwire (Turbo/Stimulus) + TypeScript + Tailwind CSS + PostgreSQL

## Architecture & Data Flow

### Core Models

**Product** (`app/models/product.rb`)
- `belongs_to :category`
- `has_many :stocks` (size variants)
- `has_many :order_products`
- `has_many_attached :images` with variants:
  - `:thumb` - 50x50px
  - `:medium` - 250x250px
- Fields: `name`, `description`, `price` (pence), `stock_level`, `active` (boolean)
- Shipping fields: `shipping_weight`, `shipping_length`, `shipping_width`, `shipping_height` (grams/cm)
- Fiberglass fields: `fiberglass_reinforcement` (boolean), `min_resin_per_m2`, `max_resin_per_m2`, `avg_resin_per_m2`
- **Has validations**: name (required), price (required, integer, ≥0), stock_level (integer, ≥0, nullable), shipping dimensions (integer, >0, nullable)
- **Scopes**: `active`, `in_price_range(min, max)`

**Stock** (`app/models/stock.rb`)
- `belongs_to :product`
- Fields: `size`, `stock_level`, `price` (pence)
- Shipping fields: `shipping_weight`, `shipping_length`, `shipping_width`, `shipping_height` (grams/cm)
- Fiberglass fields: `fiberglass_reinforcement` (boolean), `min_resin_per_m2`, `max_resin_per_m2`, `avg_resin_per_m2`
- Represents size variants with individual pricing (e.g., "Small £10", "Large £15")
- **Has validations**: size (required), price (required, integer, ≥0), stock_level (integer, ≥0, nullable), shipping dimensions (integer, >0, nullable)

**Category** (`app/models/category.rb`)
- `has_many :products, dependent: :destroy`
- `has_one_attached :image` with `:thumb` variant (50x50px)
- Fields: `name`, `description`
- Cascade deletes products when category deleted
- **Has validations**: name (required, unique case-insensitive)

**Order** (`app/models/order.rb`)
- `has_many :order_products`
- Fields: `customer_email`, `fulfilled` (boolean), `total` (pence), `address`, `name`, `phone`, `billing_name`, `billing_address`, `payment_status`, `payment_id`, `shipping_cost`, `shipping_id`, `shipping_description`
- Created exclusively via Stripe webhook (`WebhooksController#stripe`)
- No direct user creation
- **Scopes**: `unfulfilled`, `fulfilled`, `recent(limit=5)`, `for_month(date=Time.current)`
- **Has validations**: customer_email (required, valid format), total (required, integer, ≥0), shipping_cost (integer, ≥0, nullable), address (required), name (required)

**OrderProduct** (`app/models/order_product.rb`)
- `belongs_to :product`
- `belongs_to :order`
- Fields: `product_id`, `order_id`, `size`, `quantity`, `price`
- **Critical**: `price` captures the price at time of purchase (not a calculated field)
- Foreign keys to both `products` and `orders` tables
- **Has validations**: quantity (required, integer, >0), price (required, integer, ≥0)

**AdminUser** (`app/models/admin_user.rb`)
- Devise authentication model with Two-Factor Authentication
- Modules: `:database_authenticatable`, `:registerable`, `:recoverable`, `:rememberable`, `:validatable`, `:two_factor_authenticatable`, `:two_factor_backupable`
- Fields: `email`, `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `remember_created_at`
- 2FA Fields: `otp_secret`, `consumed_timestep`, `otp_required_for_login`, `otp_backup_codes` (JSON array)
- **Table name**: `admin_users` (migrated from `admins` to fix namespace conflict)
- **2FA Methods**: `setup_two_factor!`, `enable_two_factor!(otp_attempt)`, `disable_two_factor!(password)`, `regenerate_backup_codes!`, `validate_backup_code(code)`
- **Backup Codes**: 10 codes generated, JSON serialized, consumed on use

**Cart** (`app/models/cart.rb`)
- `has_many :cart_items, dependent: :destroy`
- Fields: `session_token` (unique), `expires_at` (30 days from creation)
- **Expiry**: `EXPIRY_DAYS = 30` constant, auto-set on creation
- **Scopes**: `active` (not expired), `expired` (past expiry)
- **Methods**: `find_or_create_by_token(token)`, `expired?`, `extend_expiry!`, `total`, `refresh_prices!`, `merge_items!(other_cart_items)`
- **Session Token**: Stored in localStorage, used to retrieve cart across requests

**CartItem** (`app/models/cart_item.rb`)
- `belongs_to :cart`
- `belongs_to :product`
- `belongs_to :stock, optional: true`
- Fields: `product_id`, `stock_id`, `size`, `quantity`, `price` (snapshot at time added)
- **Validations**: quantity > 0, price >= 0, unique product+size per cart
- **Methods**: `refresh_price!`, `name` (delegate to product), `total`, `stock_available?`

**ProductStock** (`app/models/product_stock.rb`)
- `belongs_to :product`
- Legacy model - appears unused (use `Stock` instead)

### Pricing Logic
Products can have two pricing models:
1. **Single price**: Product has `stock_level` and `price` fields directly
2. **Variant pricing**: Product has Stocks with individual `price` and `stock_level` per size

See `CheckoutsController#create` lines 13-23 for the logic that determines which price to use.

### Shipping & Material Properties
Both Product and Stock models include:
- **Shipping Dimensions**: `shipping_weight` (grams), `shipping_length`, `shipping_width`, `shipping_height` (cm)
- **Fiberglass Properties**: `fiberglass_reinforcement` flag and resin requirements (`min_resin_per_m2`, `max_resin_per_m2`, `avg_resin_per_m2`)

These fields support material quantity calculators and shipping cost calculations.

### Model Patterns & Conventions

**Validations**:
- Models now have comprehensive validations (see individual model sections above)
- Controllers handle validation errors via `save`/`update` return values
- Database constraints provide additional safety layer

**Scopes**:
- Product: `active`, `in_price_range(min, max)`
- Order: `unfulfilled`, `fulfilled`, `recent(limit)`, `for_month(date)`
- Business logic for aggregations lives in controllers (see `AdminController#index`)

**Concerns**:
- No concerns defined (concerns directory exists but is empty)

**Active Storage Integration**:
- Images stored via Active Storage (requires VIPS)
- Multiple attachments on Product (`has_many_attached :images`)
- Single attachment on Category (`has_one_attached :image`)
- Variants defined inline in model (`:thumb`, `:medium`)

**Admin Controller Naming Convention**:
- Controllers use `@admin_product`, `@admin_category` instance variables
- But reference base models: `Product.find`, not `Admin::Product`
- This creates namespace confusion in tests (Admin model vs Admin:: module)

**Pagy Pagination**:
- Admin controllers use Pagy gem for pagination
- Pattern: `@pagy, @admin_products = pagy(Product.all)`

**Image Handling (Update Pattern)**:
- Products controller has custom logic to prevent duplicate filenames
- Deletes existing image with same filename before attaching new one
- See `Admin::ProductsController#update` lines 47-59

### Stripe Integration Flow
1. **Checkout** (`CheckoutsController#create`): Creates Stripe session with product metadata (product_id, size, product_stock_id, product_price)
2. **Webhook** (`WebhooksController#stripe`): On `checkout.session.completed`, creates Order and OrderProducts, decrements stock, sends email
3. Stock is decremented in the webhook handler, not at checkout creation
4. Currency is **GBP** (changed from USD) - see line 35 in `CheckoutsController`

## Environment & Secrets

Use **Rails credentials** for secrets (not env vars in development):
```bash
EDITOR="code --wait" rails credentials:edit
```

Required credentials:
- `stripe.secret_key` - Stripe API key
- `stripe.webhook_key` - Stripe webhook signing secret

Fallback to ENV vars: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_KEY`

## DevContainer Setup

### Container Architecture
Multi-service Docker Compose setup with 3 containers:
1. **app**: Rails application (Ruby 3.2.3)
2. **postgres**: PostgreSQL 17 database
3. **pgadmin**: pgAdmin web interface for database management

### Network Configuration
- App container shares network with postgres (`network_mode: service:postgres`)
- Forwarded ports: 3000 (Rails), 5432 (PostgreSQL), 15432 (pgAdmin), 587, 2525
- pgAdmin accessible at `localhost:15432` (admin@pgadmin.com / password)

### Database Users
Created via `.devcontainer/create-db-user.sql`:
- `postgres` (superuser) - password: `postgres`
- `vscode` - with CREATEDB privilege
- `e_commerce_rails7` - password: `e_commerce_rails7`, with CREATEDB privilege

### Volume Mounts
- **Workspace**: `../..:/workspaces:cached` (mounts parent directories)
- **PostgreSQL data**: Persistent volume `postgres-data`
- **pgAdmin**: Persistent volume + backup mount to `storage/pgadmin/backups`

### Pre-installed VS Code Extensions
Comprehensive extension pack auto-installed in devcontainer:
- **Ruby**: ruby-lsp, solargraph, rubocop, endwise
- **Rails**: rails-snippets, erb-beautify, erb-linter
- **Tailwind**: vscode-tailwindcss, tailwind-docs, tailwind-snippets, headwind
- **Database**: ms-ossdata.vscode-pgsql
- **DevOps**: vscode-containers, docker-compose, vscode-github-actions
- **Utilities**: code-spell-checker, todo-tree, indent-rainbow, prettier, vscode-icons

### Docker Entrypoint
`bin/docker-entrypoint` auto-runs `db:prepare` when starting Rails server, ensuring database exists and migrations are current.

### Environment Variables (DevContainer)
Set in docker-compose.yml:
- `DATABASE_HOST=postgres`
- `DATABASE_USERNAME=postgres`
- `DATABASE_PASSWORD=postgres`
- `DATABASE_NAME=e_commerce_rails7_development`

## Development Workflow

### Initial Setup
```bash
bin/rails db:migrate
yarn install              # Install JavaScript dependencies
yarn build                # Build TypeScript/JavaScript
bin/dev                   # Runs Rails server, Tailwind watcher, and JS build watcher
```

### TypeScript Development
```bash
yarn build                # One-time TypeScript → JavaScript build
yarn build:ts             # Type-check then build
yarn build --watch        # Watch mode (runs via bin/dev)
tsc --noEmit              # Type-check only
```

Build output: `app/assets/builds/application.js` (762KB bundled)

### Create Admin Users
```bash
bin/rails c
AdminUser.create(email: "admin@example.com", password: "12345678")
```

### Email Testing
Uses `letter_opener_web` for email preview (currently enabled in production - TODO to restrict):
- Local: `http://localhost:3000/letter_opener`
- See `OrderMailer.new_order_email` triggered on order completion

### Ngrok for Stripe Webhooks (Local)
```bash
ngrok http --url=YOUR-SUBDOMAIN.ngrok-free.app 3000
```
Add host to `config/environments/development.rb`:
```ruby
config.hosts << "YOUR-SUBDOMAIN.ngrok-free.app"
```

## Security

### Rack::Attack Rate Limiting
**Configuration**: `config/initializers/rack_attack.rb`
- **Global throttle**: 300 requests per 5 minutes per IP (excludes `/assets`)
- **Admin login**: 5 attempts per 20 seconds per IP and email (prevents credential stuffing)
- **Checkout**: 10 attempts per minute per IP (prevents abuse)
- **Contact form**: 5 submissions per minute per IP (prevents spam)
- **Test environment**: Conditionally disabled via `config/application.rb` unless `ENV['RACK_ATTACK_ENABLED']=true`
- Returns HTTP 429 with plain text message when throttled
- See `test/integration/rack_attack_test.rb` for 6 test cases (skipped by default)

### Strong Parameters
All admin controllers use strong parameters:
- Product: `:name, :description, :price, :stock_level, :category_id, :active, :shipping_weight, :shipping_length, :shipping_width, :shipping_height, :fiberglass_reinforcement, :min_resin_per_m2, :max_resin_per_m2, :avg_resin_per_m2, images: []`
- Stock: similar pattern with size-variant fields
- Unpermitted parameters logged but silently ignored

## Code Conventions

### Frozen String Literals
All Ruby files start with `# frozen_string_literal: true` (enforced by RuboCop)

### RuboCop
- Run safe fixes: `rubocop -a`
- Run safe + unsafe: `rubocop -A` (use caution)
- Many cops disabled (see `.rubocop.yml`): Documentation, LineLength, all Metrics, ClassAndModuleChildren

### Admin Namespace
Admin controllers inherit from `AdminController` which:
- Uses `layout 'admin'` for separate admin UI
- Requires `authenticate_admin_user!` before all actions
- See `app/controllers/admin/` for examples

### Admin Authentication Views
All admin authentication screens follow a consistent Tailwind design pattern:
- **Layout**: Centered card (`max-w-md`) on gray background (`bg-gray-50`)
- **Views**: `app/views/admin_users/sessions/new.html.erb`, `app/views/admin_users/passwords/new.html.erb`, `app/views/admin_users/registrations/new.html.erb`
- **Error Messages**: Red alert styling in `app/views/admin_users/shared/_error_messages.html.erb`
- **Styling Pattern**:
  ```erb
  <div class="flex items-center justify-center min-h-screen px-4 py-12 bg-gray-50 sm:px-6 lg:px-8">
    <div class="w-full max-w-md space-y-8">
      <div>
        <h2 class="mt-6 text-3xl font-extrabold text-center text-gray-900">
          Admin Login
        </h2>
      </div>
      <%= form_for(resource, ..., html: { class: "mt-8 space-y-6" }) do |f| %>
        <!-- Form fields with consistent input styling -->
        <%= f.email_field :email,
            class: "block w-full px-3 py-2 mt-1 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm" %>
      <% end %>
    </div>
  </div>
  ```
- **Custom Devise Controllers**: `app/controllers/admin_users/sessions_controller.rb` uses `layout 'devise'` for authentication pages

### Routing Pattern
- Admin namespace uses resourceful routes: `namespace :admin do resources :products`
- Devise for admin users: `devise_for :admin_users, controllers: { sessions: 'admin_users/sessions' }`
- Custom routes for cart/checkout: `get 'cart'`, `post 'checkout'`, etc.

## Database

### Development vs Production
- **Development**: PostgreSQL via DevContainer (`host: postgres`, user/pass: `postgres`)
- **Production**: PostgreSQL via `DATABASE_URL` env var (Render)

### Migrations of Note
- `AddPriceToStock` - variant pricing
- `RenameAmountToStockLevel` - renamed `amount` to `stock_level` in products and stocks tables
- `RenameWeightFieldsToShipping` - prefixed physical dimensions with `shipping_`
- `AddFiberglassFields` - added `fiberglass_reinforcement` and resin calculation fields
- `AddPriceToOrderProducts` - capture price at purchase time
- `AddNameToOrderOrders` - shipping name separate from billing
- Latest schema version: `2025_11_30_015033`

### Schema Backup Tables
`products_backup` and `stocks_backup` exist in schema - likely from data migration work

## Testing & Quality

### Test Framework
Uses **Minitest** (Rails default, not RSpec) with Capybara for system tests.

**Test Structure**:
- `test/models/` - Model unit tests (mostly placeholder stubs)
- `test/controllers/` - Controller integration tests
- `test/controllers/admin/` - Admin namespace controller tests
- `test/system/admin/` - Capybara browser tests for admin UI
- `test/fixtures/` - YAML test data (minimal fixtures defined)
- `test/mailers/` - Mailer tests

**Running Tests**:
```bash
bin/rails test              # Run all unit/integration tests (285 runs, 730 assertions)
bin/rails test:system       # Run Capybara system tests (16 runs, 19 assertions)
bin/rails test:all          # Run everything (301 total runs, 749 assertions, 8 skips)
```

**Test Patterns**:
- Controller tests use `ActionDispatch::IntegrationTest`
- System tests use Selenium with Chrome (1400x1400 screen size)
- Tests run in parallel (`parallelize(workers: :number_of_processors)`)
- Admin controller tests use `sign_in admin_users(:admin_user_one)` for authentication
- Fixtures loaded for all tests via `fixtures :all`
- Rack::Attack tests skipped by default (6 tests in `test/integration/rack_attack_test.rb`)

**Rack 3.x Compatibility**:
- Using Rack 3.2.4 and Capybara 3.40.0 (required for Rack 3.x support)
- Capybara automatically handles Puma server setup
- See `test/application_system_test_case.rb` for simple default configuration

**Known Issue (Resolved)**:
Previously had namespace conflict when admin model was named `Admin` (conflicted with `Admin::` module). Resolved via migration to `AdminUser` model.

### RuboCop
Project uses `rubocop-rspec` gem but implements **Minitest**, not RSpec (likely leftover dependency).

### Image Processing
Requires **VIPS** for Active Storage variants (thumb, medium):
```bash
brew install vips  # macOS
```

## Deployment (Render)

Build command: `./bin/render-build.sh`
- Runs `bundle install`, `assets:precompile`, `assets:clean`, `db:migrate`

Start command: `bundle exec puma -C config/puma.rb`

Environment variables:
- `DATABASE_URL` (from Render PostgreSQL)
- `RAILS_MASTER_KEY` (sync manually)
- `WEB_CONCURRENCY=2`

## Notable Custom Features

### Quantities Calculator
Controllers under `app/controllers/quantities/` delegate to `QuantityCalculatorService` for composite material calculations.

**Service Architecture**:
- **Service**: `app/services/quantity_calculator_service.rb` - Contains all calculation logic
- **Constants**: `app/services/quantity_calculator_constants.rb` - Defines MATERIAL_WIDTH, RESIN_TO_GLASS_RATIO, WASTAGE_FACTOR
- **Controllers**: Thin controllers that delegate to service and expose results as instance variables

**Material Types** (14 options):
- Chop Strand: 300g, 450g, 600g
- Plain Weave: 285g, 400g
- Woven Roving: 450g, 600g, 800g, 900g
- Combination Mat: 450g, 600g, 900g
- Biaxial: 400g, 800g
- Gel Coat

**Core Constants** (in `QuantityCalculatorConstants`):
- `MATERIAL_WIDTH` = 0.95m (standard roll width)
- `RESIN_TO_GLASS_RATIO` = 1.6:1 (resin to glass ratio)
- `WASTAGE_FACTOR` = 1.15 (15% wastage)

**Calculator Methods**:

1. **calculate_area**:
   - Input: Area (m²), layers, material type, catalyst percentage
   - Returns Result struct with all calculated values

2. **calculate_dimensions**:
   - Input: Length, width, layers, material, catalyst
   - Calculates area: `(length * width)` (depth is always 0)
   - Then applies same formulas

3. **calculate_mould_rectangle**:
   - Input: Length, width, depth, layers, material, catalyst
   - Calculates surface area: `(length * width) + (2 * length * depth) + (2 * width * depth)`
   - Then applies same formulas

**Service Usage**:
```ruby
result = QuantityCalculatorService.new(params.permit(:area, :catalyst, :material, :layers)).calculate_area
@mat = result.mat
@resin_total = result.resin_total
# ... other results
```

**Key Patterns**:
- Service returns `Result` struct with all calculated values
- Controllers extract values from Result to instance variables for views
- Results displayed in Turbo Frame tables with blue-themed styling
- Form submits via GET (params in URL, bookmarkable results)
- No persistence - pure calculation engine
- Breadcrumbs show hierarchy: Home → Quantity Calculator → Specific Calculator

### Breadcrumbs
Uses `breadcrumbs_on_rails` gem - see `CartsController` for example:
```ruby
add_breadcrumb 'Home', :root_path
add_breadcrumb 'Shopping Cart'
```

### Stock Management
Admin can manage product stocks via nested routes:
```ruby
namespace :admin do
  resources :products do
    resources :stocks
  end
end
```

## Frontend Architecture

### View Layers
Two distinct layouts:
- **application.html.erb**: Public-facing shop with navbar/footer partials, blue theme
- **admin.html.erb**: Admin interface with sticky sidebar nav, gray theme

### JavaScript/TypeScript Stack
- **TypeScript**: Full TypeScript setup with esbuild bundler (migrated from importmap)
- **Hotwire**: Turbo + Stimulus controllers (now TypeScript-first)
- **esbuild**: JavaScript/TypeScript bundler (no webpack/node)
- **Chart.js**: Dashboard visualizations (via npm package)
- **Build process**: `yarn build` compiles TypeScript → JavaScript in `app/assets/builds/`

### Stimulus Controllers (TypeScript)
- **cart_controller.ts**: LocalStorage cart management, checkout flow, VAT calculations
- **products_controller.ts**: Size selection, dynamic pricing, add to cart with flash messages
- **dashboard_controller.ts**: Chart.js integration for revenue visualization
- **quantities_controller.ts**: Custom material calculations (stub)

All controllers now use TypeScript with proper type definitions for:
- Stimulus values (e.g., `declare readonly productValue: Product`)
- DOM elements (e.g., `HTMLButtonElement`, `HTMLTemplateElement`)
- Event handlers with typed parameters
- Interface definitions for data structures (Product, Stock, CartItem)

### Stimulus Controller Details

#### cart_controller.ts
**Purpose**: Complete cart lifecycle - render, modify, checkout
**Type Interfaces**: `CartItem`, `MessageContent`, `MessageOptions`, `CheckoutPayload`, `CheckoutResponse`, `ErrorResponse`
**Static Values**: `messageTimeout` (default: 3500ms)
**Actions**:
- `initialize()` - Auto-runs on connect, reads localStorage, builds table DOM, calculates VAT totals
- `checkout()` - POST to `/checkout` endpoint with CSRF token, redirects to Stripe
- `clear()` - Removes cart from localStorage, reloads page
- `removeFromCart(event)` - Removes specific item by id+size, reloads page
- `addMessage(content, options)` - Template-based flash messages (3.5s timeout)
- `formatCurrency(price)` - Divides by 100, formats as £X,XXX.XX

**Key Patterns**:
- Inline styles on table cells (border, textAlign) - no Tailwind on dynamic elements
- VAT calculation: Ex VAT = price/1.2 (20% UK VAT)
- Duplicate in `success.html.erb` - cart renders same way after order
- Page reload strategy (not Turbo updates)
- Typed fetch responses and localStorage parsing

#### products_controller.ts
**Purpose**: Product page size selection and add-to-cart
**Type Interfaces**: `Product`, `Stock`, `MessageOptions`
**Static Values**:
- `size` (String) - Currently selected size
- `product` (Object) - Full product JSON from Rails
- `stock` (Array) - All stock variants from Rails
- `messageTimeout` (default: 2500ms)

**Actions**:
- `addToCart()` - Adds/increments item in localStorage, shows success message
- `selectSize(e: Event)` - Updates UI price, enables "Add to Cart" button
- `addMessage()` - Template-based flash (2.5s timeout)
- `formatCurrency()` - Same as cart controller

**Key Patterns**:
- Button value contains size, button ID is `button-text-{size}`
- Price extraction via string split on "£" character
- Finds stock by size, falls back to product.price if no variants
- Button disabled state + invisible class until size selected
- Quantity increment logic: finds existing cart item by id+size
- Null checks for all DOM element queries

#### dashboard_controller.ts
**Purpose**: Chart.js line charts for admin revenue visualization
**Static Values**:
- `revenue` (Array<[string, number]>) - Array of `[label, value_in_pence]` tuples
- `elementid` (String) - Canvas element ID to render into

**Actions**:
- `initialize()` - Creates Chart.js instance on connect

**Key Patterns**:
- Divides revenue by 100 for display (pence → pounds)
- Disables legend display
- Custom grid styling (dashed y-axis, hidden x-axis)
- Used in both `admin/index` and `admin/reports/index`
- Multiple charts per page (different elementid values)
- Canvas element cast to `HTMLCanvasElement` for Chart.js

#### quantities_controller.ts
**Purpose**: Placeholder for material calculations
**Current State**: Stub implementation with TypeScript types
**Static Targets**: `output` (HTMLElement)
**Note**: Actual calculations are server-side in Quantities controllers

### Key Patterns

#### Stimulus Values API
Pass Rails data to controllers via `data-*-value` attributes:
```erb
data-products-product-value="<%= @product.to_json %>"
data-products-stock-value="<%= @product.stocks.to_json %>"
data-dashboard-revenue-value="<%= @revenue_by_month.to_json %>"
data-dashboard-elementId-value="revenueChartMonthly"
```

TypeScript controllers declare these values with proper types:
```typescript
declare readonly productValue: Product
declare readonly stockValue: Stock[]
declare sizeValue: string  // Mutable values don't use readonly
```

#### Action Syntax
Controllers use click events primarily:
```erb
data-action="click->cart#checkout"
data-action="click->products#selectSize"
```

#### No Targets Used
Controllers primarily use `document.getElementById()` instead of Stimulus targets:
```typescript
const table_body = document.getElementById("table_body") as HTMLTableSectionElement
const selectedSizeEl = document.getElementById("selected-size") as HTMLSpanElement
```

**TypeScript Pattern**: Always cast getElementById results to specific HTML element types for proper type checking.

#### LocalStorage Cart
Cart lives entirely in browser localStorage (JSON array):
```typescript
interface CartItem {
  id: number
  name: string
  price: number
  size: string
  quantity: number
}
```
**Cart Structure**:
- `id` - Product ID (integer)
- `name` - Product name (string)
- `price` - Price in pence (integer)
- `size` - Selected size variant (string, can be empty)
- `quantity` - Item count (integer)

**Cart Operations**:
- Added via `products#addToCart` Stimulus action
- Rendered in `cart#initialize` controller (builds table DOM)
- Modified via `cart#removeFromCart` (splice by index)
- Cleared via `cart#clear` or auto-cleared on success page load
- Sent to backend on checkout (`POST /checkout` with CSRF token)

**Important**: Cart is ephemeral - no persistence, no user accounts, cleared on success

**TypeScript Pattern**: Parse localStorage with type assertion: `JSON.parse(cartString) as CartItem[]`

#### Price Display
- Prices stored in **pence** (integers) in database
- Formatted in views: `formatted_price(price)` helper (£ with 2 decimals)
- JavaScript: `formatCurrency(price)` method in controllers divides by 100
- **VAT inclusive** pricing (Ex VAT = price/1.2)

#### Flash Messages
Custom template-based flash system using Stimulus:
```javascript
this.addMessage({ message: "Item added" }, { type: 'alert' });
```
See `products/show.html.erb` for `<template data-template>` pattern

#### Font Awesome Icons
Uses `font-awesome-sass` gem with helper:
```erb
<%= icon('fa-solid', 'shopping-cart', class: 'mr-2') %>
```

### Turbo Frames
Limited use - mainly for quantities calculators:
```erb
<%= turbo_frame_tag "area" do %>
```

### View Helpers

**formatted_price(price)** (`app/helpers/application_helper.rb`)
- Primary price formatting helper used throughout views
- Converts pence to pounds: `price / 100.0`
- Returns '£0.00' for nil or zero values
- Uses Rails `number_to_currency` with £ symbol

**icon(style, name, options)** (Font Awesome)
- Renders Font Awesome icons via `font-awesome-sass` gem
- Pattern: `icon('fa-solid', 'shopping-cart', class: 'mr-2')`
- Used extensively in admin navigation sidebar

**Pagy Pagination**
- `pagy(collection)` in controllers returns `[@pagy, @records]`
- `pagy_nav(@pagy)` in views renders pagination UI
- Conditional rendering: `pagy_nav(@pagy) if @pagy.pages > 1`
- Used in all admin index pages

**Breadcrumbs** (`breadcrumbs_on_rails` gem)
- `add_breadcrumb 'Label', :path` in controller actions
- `render_breadcrumbs separator: ' / '` in navbar
- Pattern: Always start with Home, then build hierarchy
- Examples: Home → Category → Product

## Email System

### Mailers

**OrderMailer** (`app/mailers/order_mailer.rb`)
- `new_order_email(order)` - Sent after successful Stripe payment
- Triggered in `WebhooksController#stripe` after order creation
- Sends to `order.customer_email`

**Email Template** (`app/views/order_mailer/new_order_email.html.erb`)
- Full invoice with shipping/billing details
- Product line items with VAT breakdown
- VAT calculations: Ex VAT = total/1.2, VAT = total - (total/1.2)
- Company contact information and VAT number

**Delivery Configuration**:
- **Development**: `letter_opener_web` (browser preview at `/letter_opener`)
- **Production**: SMTP via MailerSend
  - Domain, username, password from ENV vars
  - Port 587, STARTTLS enabled
- Default from: `scfs@cariana.tech` (TODO: change to real email)

## Configuration & Build

### Tailwind CSS (`config/tailwind.config.js`)
- **Content paths**: Views, helpers, JavaScript
- **Plugins**: forms, aspect-ratio, typography, container-queries
- **Font**: Inter var as default sans-serif
- **Custom config**: Extends default theme, no custom colors defined
- **Build commands**:
  - `bin/rails tailwindcss:build` - One-time build
  - `bin/rails tailwindcss:watch` - Watch mode
  - `bin/dev` - Runs Rails + Tailwind together (Procfile.dev)

### Import Maps (`config/importmap.rb`)
**Status**: Removed in favor of esbuild bundling
- Previous approach used browser-native ESM from CDN
- Migrated to TypeScript with esbuild for better type safety and bundling
- See package.json and tsconfig.json for current JavaScript/TypeScript configuration

### Active Storage
- **Development**: Local disk (`storage/`)
- **Production**: Amazon S3
  - Region: eu-central-1
  - Bucket: e-commerce-rails7-aws-s3-bucket
  - Credentials from Rails credentials (aws:access_key_id, aws:secret_access_key)
- **Test**: Temporary disk (`tmp/storage`)

### Action Cable (WebSockets)
- **Development**: Redis at localhost:6379/1
- **Production**: Redis from `REDIS_URL` ENV var
- **Channel prefix**: ecomm_production
- Currently minimal usage (infrastructure present but unused)

### Puma Web Server
- **Threads**: 5 (configurable via `RAILS_MAX_THREADS`)
- **Workers (Production)**: Auto-scaled to physical CPU count via `WEB_CONCURRENCY`
- **Worker timeout**: 3600s in development
- **Port**: 3000 (configurable via `PORT`)
- **Preload app**: Enabled for memory efficiency

## Security & Authentication

### Devise (Admin Only)
- Single model: `AdminUser` with email/password authentication
- Modules: database_authenticatable, registerable, recoverable, rememberable, validatable
- Routes: `devise_for :admin_users`
- **No public user accounts** - customers checkout as guests
- Mailer sender: `admin@e-commerce-rails7.com`

### CSRF Protection
- Automatic via Rails
- Stimulus controllers fetch token: `document.querySelector("[name='csrf-token']").content`
- Included in checkout POST: `"X-CSRF-Token": csrfToken`

### Production Security
- **Force SSL**: Enabled (`config.force_ssl = true`)
- **Static files**: Served when `RAILS_SERVE_STATIC_FILES` or `RENDER` ENV present
- **Secrets**: Rails credentials (not ENV vars) in development
- **Master key**: Required in production via `RAILS_MASTER_KEY`

### Tailwind CSS
- Built via `bin/rails tailwindcss:build` or watch mode
- Config: `config/tailwind.config.js`
- Custom color scheme: blue-600 primary, gray admin interface

### Google Analytics
Conditional loading in production only (meta tag approach):
```erb
<% if Rails.env.production? %>
  <meta name="google-analytics-id" content="G-481BNJ1GVB">
<% end %>
```
Event listener on `turbo:load` reads meta tag and initializes gtag.

## Common Gotchas

1. **Letter Opener in Production**: Currently mounted in production (line 59 routes.rb) - TODO to restrict
2. **Currency**: Changed from USD to GBP - ensure Stripe dashboard matches
3. **Stock Decrement Timing**: Happens in webhook, not checkout creation
4. **Timezone**: Set to 'London' in `config/application.rb`
5. **Credentials**: Use `rails credentials:edit` not `.env` files for secrets
6. **Price Storage**: Always in pence (multiply user input by 100 before saving)
7. **Cart State**: Cart cleared on success page load - stored in localStorage only
8. **TypeScript Build**: Must run `yarn build` before deploying (automated in render-build.sh)
9. **Type Safety**: Use proper type casting for DOM elements and localStorage parsing
10. **Import Extensions**: Don't use `.ts` extensions in TypeScript imports (extension-less preferred)

## Form Patterns & Conventions

### Admin Form Structure
All admin forms follow consistent patterns using `form_with`:

**Error Handling**:
```erb
<% if admin_product.errors.any? %>
  <div id="error_explanation" class="px-3 py-2 mt-3 font-medium text-red-500 rounded-lg bg-red-50">
    <h2><%= pluralize(admin_product.errors.count, "error") %> prohibited this admin_product from being saved:</h2>
    <ul>
      <% admin_product.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

**Input Helper Text**:
Forms use inline `<p>` tags with `.text-xs.text-gray-500` to clarify units:
```erb
<%= form.label :price %><p class="text-xs text-gray-500">in pence</p>
<%= form.label :weight %><p class="text-xs text-gray-500">in grams</p>
<%= form.label :length %><p class="text-xs text-gray-500">in cm</p>
```

**Image Upload with Preview**:
Products form shows existing images with delete buttons:
```erb
<% if admin_product.images.any? %>
  <% admin_product.images.each do |image| %>
    <div class="flex border border-gray-200">
      <div class="relative z-0 w-40 h-40 bg-gray-400">
        <%= image_tag image, class: "w-30 h-30 object-cover rounded-md" %>
        <%= link_to "X", admin_product_image_path(admin_product, image),
                    data: { turbo_method: :delete, turbo_confirm: "Are you sure?" },
                    class: "absolute top-0 right-0 bg-red-500 text-white rounded-full w-5 h-5" %>
      </div>
    </div>
  <% end %>
<% end %>
<%= form.file_field :images, multiple: true, class: "..." %>
```

**Nested Resource Links**:
Forms for parent resources link to nested children:
```erb
<% unless admin_product.new_record? %>
  <%= link_to "Edit Product Size/Price/Stock", admin_product_stocks_path(admin_product), class: "..." %>
<% end %>
```

**Form Styling**:
Consistent Tailwind classes across all forms:
- Inputs: `block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full`
- Submit buttons: `rounded-lg py-3 px-5 bg-blue-600 text-white inline-block font-medium cursor-pointer`
- Labels: Auto-styled by Tailwind forms plugin

## Admin Dashboard & Reports

### Dashboard Statistics (`AdminController#index`)
Calculates 6 key metrics for current month:

**Aggregation Patterns**:
```ruby
@monthly_stats = {
  sales: Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).count,
  items: OrderProduct.joins(:order).where(orders: { created_at: ... }).sum(:quantity),
  revenue: Order.where(...).sum(:total)&.round(),
  avg_sale: Order.where(...).average(:total)&.round(),
  shipping: Order.where(...).where.not(shipping_cost: nil).sum(:shipping_cost)&.round(),
  per_sale: avg_items_monthly  # Calculated: num_products / num_orders
}
```

**Daily Revenue Breakdown**:
```ruby
@monthly_orders_by_day = Order.where(...).group_by { |order| order.created_at.to_date }
@monthly_revenue_by_day = @monthly_orders_by_day.map { |day, orders|
  [day.strftime('%e %A'), orders.sum(&:total)]
}
# Fill missing days with 0 revenue
@days_of_month = (1..Time.days_in_month(Date.today.month, Date.today.year)).to_a
@revenue_by_month = @days_of_month.map { |day|
  [day, @monthly_revenue_by_day.fetch(Date.new(...).strftime('%e %A'), 0)]
}
```

**Pattern Notes**:
- Uses `sum`, `count`, `average` directly on Active Record relations
- Safe navigation: `&.round()` prevents nil errors
- Conditional division check before calculating averages
- Manual group_by with Ruby enumerable (not SQL GROUP BY)
- Fills calendar gaps with 0 values for complete charts

### Reports Dashboard (`Admin::ReportsController`)
- Displays current month and previous month revenue charts side-by-side
- Same aggregation patterns as AdminController
- Multiple Chart.js instances per page (different `elementId` values)
- Stats cards show: Gross Revenue, Net Revenue (÷1.2), Shipping, VAT, Sales count, Items count, Average Sale, Average Items/Sale

**VAT Calculations** (20% UK VAT):
```erb
Net Revenue: <%= formatted_price(@monthly_stats[:revenue] / 1.2) %>
VAT: <%= formatted_price(@monthly_stats[:revenue] - (@monthly_stats[:revenue] / 1.2)) %>
```

**Chart.js Integration**:
```erb
<div data-controller="dashboard"
     data-dashboard-revenue-value="<%= @revenue_by_month.to_json %>"
     data-dashboard-elementId-value="revenueChartMonthly">
  <canvas id="revenueChartMonthly"></canvas>
</div>
```

## Production Deployment Details

### Multi-Stage Dockerfile
Optimized production build with 3 stages:

**Base Stage**:
- Ruby 3.2.2-slim image
- Sets production environment variables
- Bundle deployment mode, excludes development gems
- Working directory: `/rails`

**Build Stage** (throw-away):
- Installs build dependencies: build-essential, git, libpq-dev, libvips, pkg-config
- Runs `bundle install` and cleans cache
- Precompiles bootsnap for faster boot times (gemfile + app/lib code)
- **Asset precompilation trick**: Uses `SECRET_KEY_BASE_DUMMY=1` to bypass master key requirement
- Build artifacts discarded after copying to final stage

**Final Stage**:
- Minimal runtime dependencies: curl, libvips, postgresql-client
- Copies compiled gems and app from build stage
- Creates non-root `rails` user for security
- Changes ownership of writable directories: db, log, storage, tmp
- Runs as `USER rails:rails` (not root)
- Entrypoint runs `bin/docker-entrypoint` (auto-runs db:prepare)
- Exposes port 3000, default CMD: `./bin/rails server`

**Key Security Patterns**:
- Multi-stage reduces final image size (discards build tools)
- Non-root user execution
- Minimal installed packages (attack surface reduction)
- Secret key not required at build time (uses dummy value)

### Render Build Script (`bin/render-build.sh`)
```bash
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
```

**Environment Variables (Production)**:
- `RAILS_MASTER_KEY` - Required for credentials decryption
- `DATABASE_URL` - Render PostgreSQL connection string
- `WEB_CONCURRENCY=2` - Puma worker count
- `RAILS_SERVE_STATIC_FILES` or `RENDER` - Enables static file serving

## Controller Patterns & Filters

### ApplicationController
Base controller for all controllers, minimal configuration:
```ruby
class ApplicationController < ActionController::Base
  include Pagy::Backend
end
```
- Includes Pagy for pagination globally
- No authentication required by default (public-facing)
- No custom before_action filters

### Admin Namespace Controllers
All admin controllers inherit from `AdminController` which:
- Uses `layout 'admin'` for separate admin UI
- Requires `authenticate_admin!` before all actions (Devise)
- Sets instance variables with `@admin_` prefix (e.g., `@admin_product`)

**Standard before_action Pattern**:
```ruby
before_action :set_admin_product, only: %i[show edit update destroy]

private
  def set_admin_product
    @admin_product = Product.find(params[:id])
  end
```

Applied to:
- `Admin::ProductsController` - `set_admin_product`
- `Admin::CategoriesController` - `set_admin_category`
- `Admin::OrdersController` - `set_admin_order`
- `Admin::StocksController` - `set_admin_stock`

### Public Controllers (No Authentication)
- `HomeController` - Landing page
- `CategoriesController` - Category browsing with filtering
- `ProductsController` - Product details
- `CartsController` - Shopping cart display
- `CheckoutsController` - Stripe checkout initiation
- `WebhooksController` - Stripe webhook handler
- `ContactController` - Contact form (no mailer, just flash message)
- `Quantities::*Controller` - Calculator tools

## Search & Filtering

### Category Filtering (`CategoriesController#show`)
Simple price range filtering using query parameters:

```ruby
@products = @category.products
@products = @products.where(active: true)
@products = @products.where('price <= ?', params[:max]) if params[:max].present?
@products = @products.where('price >= ?', params[:min]) if params[:min].present?
```

**Filter Form Pattern**:
```erb
<%= form_with url: category_path(@category), method: :get do |form| %>
  <%= form.number_field :min, placeholder: "Min Price" %>
  <%= form.number_field :max, placeholder: "Max Price" %>
  <%= form.submit "Filter" %>
<% end %>
```

**Key Patterns**:
- No scopes defined - uses inline `where` clauses
- Always filters to `active: true` products
- Price in pence (user must enter pence values)
- GET method preserves filter in URL (bookmarkable)
- Separate "Clear" button reloads page without params

### Admin Product Search
Currently not implemented (no search functionality in admin interface)

## Contact Form & Newsletter

### Contact Form (`ContactController`)
**Status**: Stub implementation - no actual email sent
```ruby
def create
  @first_name = params[:contact_form][:first_name]
  @last_name = params[:contact_form][:last_name]
  @email = params[:contact_form][:email]
  @message = params[:contact_form][:message]

  flash[:success] = 'Your message has been sent successfully.'
  redirect_to :contact
end
```

**Missing Features**:
- No ContactMailer (should send email to admin)
- No spam protection (no reCAPTCHA)
- No validation (accepts empty submissions)
- Form data captured but not persisted or sent

### Newsletter Subscription
**Status**: Not implemented
```erb
<%= form_with url: root_path, method: :post do %>
  <%= email_field_tag :email, nil, placeholder: "Enter your email" %>
  <%= submit_tag "Subscribe" %>
<% end %>
```
- Form exists in `home/index.html.erb` and `contact/index.html.erb`
- No route handler (POSTs to root_path which doesn't accept POST)
- No newsletter service integration
- TODO: Implement with Mailchimp/SendGrid or save to database

## Turbo & Hotwire Usage

### Limited Turbo Adoption
Project uses Hotwire stack but minimal Turbo features:

**Turbo Frames** (only in quantities calculators):
```erb
<%= turbo_frame_tag "area" do %>
  <!-- Calculator form and results -->
<% end %>
```

**Turbo Methods** (for delete actions):
```erb
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }
```

**No Turbo Streams**:
- No real-time updates
- No inline editing without page reload
- Cart uses full page reloads (localStorage → reload pattern)

**Turbo Drive Enabled**:
- Default Rails 7 behavior (SPA-like navigation)
- Stylesheets use `data-turbo-track: "reload"`

**Opportunities**:
- Cart could use Turbo Frames for inline updates
- Admin tables could use Turbo Streams for real-time order updates
- Product filtering could use Turbo Frames to avoid full page reload

## Configuration & Initializers

### Key Initializers

**Assets** (`config/initializers/assets.rb`):
- Default Rails asset configuration
- Version: 1.0
- No custom precompile paths (uses defaults)

**Devise** (`config/initializers/devise.rb`):
- Mailer sender: `please-change-me-at-config-initializers-devise@example.com` (TODO: update)
- Default authentication: `:database_authenticatable`
- ORM: Active Record
- Standard Devise defaults (mostly unchanged)

**Filter Parameters** (`config/initializers/filter_parameter_logging.rb`):
- Filters sensitive data from logs: `passw`, `secret`, `token`, `_key`, `crypt`, `salt`, `certificate`, `otp`, `ssn`
- Important: Stripe keys logged unless explicitly filtered

**Content Security Policy** (`config/initializers/content_security_policy.rb`):
- Not configured (commented out)
- No CSP headers sent
- Potential security improvement opportunity

**Permissions Policy** (`config/initializers/permissions_policy.rb`):
- Not configured (commented out)
- No permissions policy headers

### Development Environment Specifics

**Allowed Hosts**:
```ruby
config.hosts << 'loved-anchovy-on.ngrok-free.app'
config.hosts << '54.187.216.72'
```

**Cache Store**:
- With caching: `:memory_store`
- Without caching: `:null_store`
- Toggle: `rails dev:cache` creates/removes `tmp/caching-dev.txt`

**Email in Development**:
- Currently uses SMTP (MailerSend) even in development
- Letter Opener Web commented out (line 85-86)
- Recommendation: Uncomment letter_opener_web for local testing

## Data Seeding & Sample Data

### Seeds File
**Status**: Empty stub
```ruby
# This file should ensure the existence of records required to run the application
# No seed data defined
```

**Missing Seed Data**:
- No sample categories
- No sample products
- No admin users
- Developers must manually create data

**Recommendation**: Add seed data for:
```ruby
# Create admin user
AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
  admin.password = "password123"
end

# Create categories
["Chop Strand Mat", "Woven Roving", "Tools"].each do |name|
  Category.find_or_create_by!(name: name) do |category|
    category.description = "Sample category"
  end
end
```

## Background Jobs & Active Job

### Current Status
- **Active Job configured** but not actively used
- `ApplicationJob` exists (standard Rails stub)
- No custom job classes defined
- No background job processor configured (no Sidekiq/DelayedJob/etc.)

**Potential Use Cases** (not implemented):
- Order confirmation email sending (currently synchronous)
- Image processing for uploaded product images
- Stock level alerts when low
- Report generation for admin

**Configuration**:
- Development: Inline execution (blocks request)
- Production: Inline execution (no async adapter)
- Opportunity: Add Sidekiq for production

## Action Cable & WebSockets

### Current Status
- **Action Cable configured** but unused
- Redis configured for production (`REDIS_URL`)
- No channels defined (only `ApplicationCable::Channel` and `ApplicationCable::Connection` stubs)
- No real-time features

**Potential Use Cases** (not implemented):
- Real-time order notifications for admin
- Live stock level updates
- Chat support widget
- Live visitor count

**Configuration**:
- Development: Redis at `redis://localhost:6379/1`
- Production: Redis from ENV `REDIS_URL`
- Channel prefix: `ecomm_production`

## Image Handling & Active Storage

### Custom Image Management Logic

**Duplicate Filename Prevention** (`Admin::ProductsController#update`):
```ruby
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
- Checks for existing image with same filename
- Purges old image before attaching new one
- Prevents duplicates in Active Storage blobs

**Image Variants**:
```ruby
# Product model
has_many_attached :images
# Variants: :thumb (50x50), :medium (250x250)

# Category model
has_one_attached :image
# Variants: :thumb (50x50)
```

**Display Pattern**:
```erb
<%= product.images.first ? image_tag(product.images.first.variant(:medium)) :
                           image_tag("http://via.placeholder.com/250") %>
```

**Delete Pattern** (with confirmation):
```erb
<%= link_to "X", admin_product_image_path(admin_product, image),
            data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %>
```

## Performance & Optimization

### Current State
- **No caching implemented** (development uses `:null_store` by default)
- **No eager loading** - potential N+1 queries
- **No database indexes** beyond default Rails indexes
- **No CDN** for assets (served from Render)
- **Asset precompilation** at deploy time (not at runtime)

### Known N+1 Opportunities
```ruby
# CategoriesController#show
@products.each do |product|
  product.images.first  # N+1 query for images
end

# AdminController#index
@orders.each do |order|
  order.order_products  # Potential N+1
end
```

**Recommended Fixes**:
```ruby
@products = @category.products.with_attached_images
@orders = Order.includes(:order_products).where(...)
```

### No Fragment Caching
Views don't use Russian Doll caching:
```erb
<!-- Opportunity: Cache product cards -->
<% cache product do %>
  <%= render product %>
<% end %>
```

## Security Considerations

### Current Security Measures
✅ **Implemented**:
- HTTPS enforced in production (`config.force_ssl = true`)
- CSRF protection enabled (default Rails)
- Parameter filtering for sensitive data
- Devise for admin authentication
- Non-root Docker user in production
- Database credentials via environment variables

⚠️ **Missing/Weak**:
- No Content Security Policy headers
- No rate limiting on contact form
- No admin 2FA/MFA
- Letter Opener Web exposed in production (routes.rb line 59)
- Devise mailer sender not updated (placeholder email)
- No IP whitelisting for admin area
- No audit logging for admin actions
- Contact form accepts spam (no reCAPTCHA)

### Recommended Improvements
1. Add `rack-attack` gem for rate limiting
2. Implement CSP headers via initializer
3. Add admin action logging (PaperTrail gem)
4. Restrict Letter Opener to development only
5. Add 2FA for admin users (devise-two-factor gem)
6. Validate Stripe webhook signatures (already implemented in WebhooksController)
