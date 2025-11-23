# Technology Stack Analysis

## Core Technology Analysis

### Programming Languages
- **Ruby 3.2.2** - Primary backend language
- **TypeScript 5.3.3** - Frontend type-safe JavaScript (migrated from vanilla JS)
- **SQL** - PostgreSQL database queries
- **HTML/ERB** - View templates (Embedded Ruby)
- **CSS** - Via Tailwind CSS utility framework

### Primary Framework
- **Ruby on Rails 7.1.2** - Full-stack MVC web framework
  - Convention over configuration
  - Active Record ORM
  - Action Cable for WebSockets (configured but minimal usage)
  - Active Storage for file uploads (images)
  - Active Job for background processing (configured but not actively used)

### Secondary Frameworks & Libraries

#### Frontend Stack
- **Hotwire** - Modern frontend framework
  - **Turbo Rails 8.0.4** - SPA-like navigation without full JavaScript framework
  - **Stimulus 3.2.2** - Modest JavaScript framework for progressive enhancement
- **Tailwind CSS** - Utility-first CSS framework
- **esbuild 0.19.11** - JavaScript/TypeScript bundler (replaced importmap)
- **Chart.js 4.4.1** - Data visualization for admin dashboard

#### Backend Integrations
- **Devise 4.9** - Authentication framework (admin-only users)
- **Stripe 10.3** - Payment processing API
- **AWS S3** - Cloud file storage (production images)
- **Redis 4.0.1+** - In-memory data store for Action Cable
- **ShipEngine SDK** - Shipping integration (configured)

#### Developer Tools
- **Pagy 6.2** - Pagination library
- **RuboCop** - Ruby code linter/formatter
  - rubocop-rails, rubocop-capybara, rubocop-rspec
- **Letter Opener Web 3.0** - Email preview in development
- **Breadcrumbs on Rails** - Navigation breadcrumbs
- **Font Awesome SASS 6.5.1** - Icon library

#### Testing Stack
- **Minitest** - Rails default testing framework (not RSpec)
- **Capybara** - System/browser testing
- **Selenium WebDriver** - Browser automation for system tests

#### Build & Deployment
- **Puma** - Web server
- **Foreman** - Process manager (runs Rails + Tailwind + JS build in development)
- **Docker** - Containerization for development (devcontainer) and production
- **PostgreSQL** - Production database (SQLite in early development, now fully migrated)
- **VIPS** - Image processing library for Active Storage variants

### State Management Approach

#### Client-Side State
- **localStorage** - Shopping cart persistence (ephemeral, browser-only)
  - Cart lives entirely in browser as JSON array
  - No server-side cart persistence
  - Cleared on successful order completion
  - Structure: `{id, name, price, size, quantity}`

#### Server-Side State
- **Active Record** - Database-backed models with minimal business logic
- **Session-based Authentication** - Devise manages admin sessions
- **No API tokens** - Traditional cookie-based sessions
- **Webhook-driven Order Creation** - Orders created exclusively via Stripe webhooks
- **No Background Jobs Active** - Synchronous processing (Active Job configured but unused)

#### State Flow Patterns
1. **Cart → Checkout Flow**:
   - User adds products to localStorage cart (Stimulus controller)
   - Checkout POST sends cart JSON to Rails backend
   - Rails validates stock availability
   - Creates Stripe session with product metadata
   - Redirects to Stripe Checkout
   - Webhook creates Order after payment

2. **Admin Dashboard State**:
   - Real-time metrics calculated on-demand (no caching)
   - Chart.js renders revenue data from controller aggregations
   - No WebSocket updates (static page loads)

## Domain Specificity Analysis

### Problem Domain
**Composite Materials E-Commerce Platform with Material Calculation Tools**

This is a specialized B2B/B2C e-commerce application for selling composite materials (fiberglass, resins, catalysts) with integrated material quantity calculators.

### Core Business Concepts

#### 1. Composite Materials Sales
- **Product Catalog Management**
  - Categories (Chop Strand Mat, Woven Roving, Tools, etc.)
  - Products with variant pricing (size-based stocks)
  - Physical dimensions (weight, length, width, height)
  - Stock levels (both product-level and variant-level)
  - Multi-image product galleries (Active Storage)

- **Dual Pricing Model**
  - **Single Price**: Product has direct `price` and `amount`
  - **Variant Pricing**: Product has multiple Stocks with individual `price` and `amount` per size
  - Prices stored in pence (GBP currency, not USD)
  - Price captured at purchase time in `order_products.price`

- **Guest Checkout Only**
  - No customer accounts
  - Email-based order identification
  - Admin users only for management

#### 2. Material Quantity Calculations
Specialized calculators for composite material projects:

- **Material Calculation Constants**
  - Roll width: 0.95m (standard)
  - Resin to glass ratio: 1.6:1
  - Wastage factor: 15% (multiply by 1.15)

- **Calculator Types**
  1. **Area Calculator** - Given area (m²), layers, material type, catalyst percentage
  2. **Dimensions Calculator** - Given length, width, depth, layers
  3. **Mould Rectangle Calculator** - Surface area of rectangular moulds

- **Calculations Performed**
  - Linear meters of mat needed
  - Total weight (kg) including wastage
  - Resin quantity (litres)
  - Catalyst amount (ml)
  - Total project weight

- **Material Types** (14 options)
  - Chop Strand: 300g, 450g, 600g
  - Plain Weave: 285g, 400g
  - Woven Roving: 450g, 600g, 800g, 900g
  - Combination Mat: 450g, 600g, 900g
  - Biaxial: 400g, 800g
  - Gel Coat

#### 3. Order Fulfillment Workflow
- **Stripe Integration**
  - Checkout session creation with product metadata
  - Shipping options (Collection, 3-5 days, Overnight)
  - Shipping restricted to GB only
  - Phone number collection
  - Separate billing and shipping addresses

- **Webhook-Driven Order Creation**
  - Orders created on `checkout.session.completed` event
  - Stock decremented at webhook (not checkout)
  - Email confirmation sent (OrderMailer)
  - Payment status tracking

- **Admin Order Management**
  - Order fulfillment tracking (boolean flag)
  - Revenue reporting by day/month
  - Chart.js visualizations
  - No real-time updates (page refresh required)

### User Interaction Types

#### Customer-Facing (Public)
1. **Product Browsing**
   - Category-based navigation
   - Price range filtering (min/max in pence)
   - Active products only

2. **Shopping Cart**
   - Add/remove items via Stimulus controllers
   - Size variant selection
   - Quantity management
   - VAT calculation display (20% UK VAT)
   - LocalStorage persistence
   - Flash messages for feedback

3. **Material Calculators**
   - Form-based parameter input
   - GET request with URL parameters (bookmarkable results)
   - Turbo Frame rendering
   - No persistence (pure calculation)

4. **Checkout Process**
   - Guest checkout (email required)
   - Stripe Checkout redirect
   - Stock validation before payment
   - Order confirmation email

#### Admin-Facing (Authenticated)
1. **Product Management**
   - CRUD operations for products
   - Multi-image upload with Active Storage
   - Duplicate filename prevention
   - Image variant generation (thumb 50x50, medium 250x250)
   - Nested stock (variant) management

2. **Category Management**
   - CRUD operations with cascade delete

3. **Order Management**
   - Order listing with pagination (Pagy)
   - Fulfillment tracking
   - Payment status monitoring
   - No order editing (immutable after creation)

4. **Reporting Dashboard**
   - Monthly/daily revenue charts
   - Sales metrics: count, revenue, avg sale, items sold
   - Shipping cost tracking
   - VAT calculations (Ex VAT = total/1.2)

### Primary Data Types & Structures

#### Core Models
```ruby
Category
├── has_many :products (cascade delete)
└── has_one_attached :image (Active Storage)

Product
├── belongs_to :category
├── has_many :stocks (size variants)
├── has_many :order_products
├── has_many_attached :images (Active Storage)
└── Fields: name, description, price (pence), amount (stock),
            active (boolean), weight, length, width, height

Stock
├── belongs_to :product
└── Fields: size, amount, price (pence), weight, length, width, height

Order
├── has_many :order_products
└── Fields: customer_email, fulfilled, total (pence), address, name, phone,
            billing_name, billing_address, payment_status, payment_id,
            shipping_cost (pence), shipping_id, shipping_description

OrderProduct (Join Table)
├── belongs_to :product
├── belongs_to :order
└── Fields: product_id, order_id, size, quantity, price (captured at purchase)

AdminUser (Devise)
└── Fields: email, encrypted_password, remember_token, etc.
```

#### TypeScript Interfaces (Frontend)
```typescript
CartItem { id, name, price, size, quantity }
Product { /* matches Rails model */ }
Stock { /* matches Rails model */ }
CheckoutPayload { authenticity_token, cart }
```

#### Measurement Units
- **Currency**: Pence (GBP) - integer storage, divide by 100 for display
- **Weight**: Grams (integer)
- **Dimensions**: Centimeters (integer)
- **Area**: Square meters (float)
- **Volume**: Litres (float)
- **Catalyst**: Millilitres (float)

## Application Boundaries

### Features Clearly Within Scope

#### E-Commerce Core
✅ Product catalog with categories
✅ Variant pricing (size-based)
✅ Multi-image product galleries
✅ Guest checkout (no accounts)
✅ Stripe payment processing
✅ Email order confirmations
✅ Stock management (product and variant level)
✅ Admin authentication (Devise)
✅ Order tracking and fulfillment
✅ Shipping cost integration
✅ UK-specific features (GBP, GB shipping, 20% VAT)

#### Material Calculators
✅ Area-based calculations
✅ Dimension-based calculations
✅ Mould rectangle calculations
✅ Material weight/quantity estimation
✅ Resin and catalyst calculations
✅ Wastage factoring

#### Admin Features
✅ Revenue reporting and charts
✅ Order management
✅ Product/category CRUD
✅ Stock variant management
✅ Image management with variants

### Features Architecturally Inconsistent

#### Customer Features
❌ **User Accounts** - Architecture is guest-only checkout
  - No customer model
  - No user authentication beyond admin
  - Cart is localStorage-only
  - Orders identified by email only

❌ **Wish Lists / Favorites** - No user persistence
  - Would require user accounts
  - Conflicts with guest checkout model

❌ **Order History for Customers** - No customer login
  - Orders not linked to user accounts
  - Could implement email-based lookup but not currently designed

❌ **Reviews / Ratings** - No user-generated content model
  - No moderation workflow
  - No review approval system

❌ **Advanced Search** - Simple category/price filtering only
  - No full-text search (PostgreSQL capabilities unused)
  - No faceted search
  - No search indexing

#### Cart & Checkout
❌ **Saved Carts** - Ephemeral localStorage only
  - No server-side cart persistence
  - Cleared on order success
  - Lost on browser clear

❌ **Multiple Currencies** - Hardcoded GBP
  - Stripe sessions use GBP only
  - Price display assumes GBP
  - No currency conversion

❌ **International Shipping** - GB-only restriction
  - Shipping address collection limited to GB
  - No international rates configured

❌ **Discount Codes / Coupons** - No promotion system
  - No promo code model
  - No discount calculation logic
  - Stripe sessions don't include coupon support

#### Advanced Features
❌ **Real-Time Inventory Updates** - Page refresh required
  - Action Cable configured but unused
  - No WebSocket channels defined
  - Admin dashboard is static

❌ **Background Jobs** - Synchronous processing
  - Active Job configured but unused
  - Email sent synchronously in webhook
  - No job queue (Sidekiq, DelayedJob, etc.)

❌ **API Endpoints** - Traditional server-rendered views
  - No JSON API controllers
  - No API authentication
  - Minimal JSON responses (checkout only)

❌ **Multi-Vendor / Marketplace** - Single vendor model
  - Products not linked to sellers
  - No vendor dashboard
  - Single admin namespace

❌ **Subscription / Recurring Payments** - One-time purchases only
  - Stripe mode is 'payment' not 'subscription'
  - No subscription model
  - No recurring billing

### Specialized Libraries & Domain Constraints

#### Material Science Domain
- **Composite Material Ratios** - Hardcoded resin:glass ratio (1.6:1)
  - Different materials may have different ratios
  - Current implementation assumes single ratio

- **Material Width Standard** - 0.95m roll width assumption
  - Real materials may vary by supplier
  - No configuration for different widths

- **Wastage Factor** - Fixed 15% wastage
  - Industry standard approximation
  - No variance by material type or project complexity

#### Payment Processing Constraints
- **Stripe-Only** - No alternative payment gateways
  - No PayPal, Apple Pay, Google Pay (unless via Stripe)
  - Webhook signature verification required
  - Dependency on Stripe availability

#### Geographic Constraints
- **UK-Focused** - GBP currency, GB shipping, London timezone
  - VAT calculations assume 20% UK VAT
  - Shipping options UK-specific
  - Phone number collection UK format

#### Image Processing
- **VIPS Dependency** - Required for Active Storage variants
  - Not ImageMagick
  - Specific variant sizes (50x50, 250x250)
  - Production requires VIPS installation

#### Development Environment
- **Docker DevContainer** - VSCode-specific setup
  - PostgreSQL in separate container
  - pgAdmin for database management
  - ngrok for Stripe webhook testing in development
  - Node.js 20.x for TypeScript build

### Architectural Patterns & Constraints

#### No Service Objects
- Business logic lives in controllers
- No service layer abstraction
- Calculations performed inline
- Validation minimal (database constraints)

#### No API Layer
- Traditional server-rendered Rails app
- Turbo for SPA-like navigation
- Minimal JSON responses
- Not headless CMS or API-first

#### No Caching
- Development uses `:null_store` by default
- Production caching not implemented
- Potential N+1 queries (no eager loading)
- No fragment caching in views

#### Minimal Model Logic
- Models are intentionally simple
- No scopes defined
- No custom methods or concerns
- ActiveRecord associations only
- No validations (relies on NOT NULL constraints)

#### TypeScript Migration (Recent)
- All Stimulus controllers now TypeScript
- Comprehensive type interfaces
- Strict type checking enabled
- esbuild bundler (not webpack)
- Build required before deployment

### Future-Proof Considerations

#### Easy Additions (Architecturally Compatible)
✅ More material types and calculators
✅ Additional product categories
✅ More shipping options
✅ Additional admin reports/charts
✅ Email template improvements
✅ More Stimulus controllers (TypeScript)
✅ Product filtering enhancements
✅ Category-specific attributes

#### Challenging Additions (Requires Refactoring)
⚠️ Customer accounts (major architecture shift)
⚠️ Multi-currency support (price model changes)
⚠️ International shipping (address validation, rates)
⚠️ Real-time features (need WebSocket implementation)
⚠️ API endpoints (need serializers, authentication)
⚠️ Background jobs (need worker process, queue)
⚠️ Service layer (need refactoring from controllers)
⚠️ Caching strategy (need cache key management)

## Summary

This is a **specialized B2B composite materials e-commerce platform** built with:
- **Rails 7.1** backend (Ruby 3.2.2)
- **TypeScript/Stimulus** frontend (strict typing, Hotwire stack)
- **PostgreSQL** database
- **Stripe** payment processing
- **UK-focused** business (GBP, GB shipping, VAT)
- **Guest checkout only** (no customer accounts)
- **Material calculators** (unique domain feature)
- **Admin dashboard** with Chart.js visualizations

The architecture is **simple and focused**, deliberately avoiding complexity like service objects, API layers, background jobs, and caching. It uses **convention over configuration** heavily and stores business logic in controllers. The recent **TypeScript migration** demonstrates a commitment to type safety while maintaining Rails conventions.

Domain constraints include **composite material mathematics** (ratios, wastage, material weights), **UK-specific commerce** (VAT, shipping), and **Stripe-dependent payment flow** (webhook-driven order creation).

