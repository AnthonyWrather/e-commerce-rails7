# AI Agent Instructions for E-Commerce Rails 7

> **Essential Guide**: This document provides the critical knowledge AI agents need to be immediately productive in this codebase. Read `.github/copilot-instructions.md` for comprehensive details.

## Quick Start Commands

```bash
# Development
bin/dev                   # Start Rails, Tailwind, TypeScript watchers
bin/rails c               # Rails console
yarn build                # Build TypeScript once

# Testing
bin/rails test:all        # All tests (507 runs, 1,151 assertions)
rubocop -a               # Auto-fix style issues

# Database
bin/rails db:migrate      # Run migrations
EDITOR="code --wait" rails credentials:edit  # Edit secrets

# Admin Access
AdminUser.create(email: "admin@example.com", password: "12345678")
```

## Architecture Decision Records

### 1. **Webhook-Driven Order Creation**
**Decision**: Orders are created exclusively via Stripe webhooks, NOT during checkout.
**Why**: Ensures payment confirmation before inventory changes. Stock is decremented in `WebhooksController#stripe` after successful payment.
**Critical**: Never create orders in `CheckoutsController` - this would bypass payment verification.

### 2. **Client-Side Cart State**
**Decision**: Shopping cart lives entirely in browser `localStorage` (no server session).
**Why**: Simplifies guest checkout, reduces database load, no user accounts needed.
**Tradeoff**: Cart not persistent across devices, abandoned cart tracking harder.
**Implementation**: `cart_controller.ts` manages cart as JSON array.

### 3. **Dual Pricing Model**
**Decision**: Products support both single pricing and variant pricing (by size).
**Why**: Flexibility for different product types (e.g., "Small £10, Large £15" vs flat price).
**Implementation**: Check `CheckoutsController#create` lines 13-23 for pricing logic.

### 4. **Calculator Logic in Controllers**
**Decision**: Material quantity calculations performed in controller `index` actions (no model layer).
**Why**: Pure calculation engine with no persistence, formulas are stateless.
**Pattern**: `Quantities::AreaController`, `Quantities::DimensionsController`, `Quantities::MouldRectangleController`.
**Note**: This is a code smell but acceptable for v1 - consider refactoring to service objects.

### 5. **TypeScript-First Frontend**
**Decision**: Migrated from importmap to esbuild + TypeScript with strict mode.
**Why**: Type safety, better bundling, modern JavaScript patterns.
**Build**: `yarn build` compiles to `app/assets/builds/application.js`.

## Critical Integration Points

### Stripe Payment Flow
```mermaid
sequenceDiagram
    User->>CheckoutsController: POST /checkout
    CheckoutsController->>Stripe: Create session with metadata
    Stripe->>User: Redirect to Stripe Checkout
    User->>Stripe: Complete payment
    Stripe->>WebhooksController: POST /webhooks (webhook)
    WebhooksController->>Order: Create with customer info
    WebhooksController->>OrderProduct: Create line items (capture price)
    WebhooksController->>Product/Stock: Decrement inventory
    WebhooksController->>OrderMailer: Send confirmation email
```

**Critical Files**:
- `app/controllers/checkouts_controller.rb` - Session creation
- `app/controllers/webhooks_controller.rb` - Order creation (CRITICAL - no tests!)
- `config/credentials.yml.enc` - `stripe.secret_key`, `stripe.webhook_key`

### Shopping Cart Flow (Client-Side)
```mermaid
sequenceDiagram
    User->>ProductsController: GET /products/:id
    ProductsController->>User: Render product page with Stimulus
    User->>products_controller.ts: Click "Add to Cart"
    products_controller.ts->>localStorage: Store CartItem JSON
    Note over localStorage: {id, name, price, size, quantity}
    User->>CartsController: GET /cart
    CartsController->>User: Render cart page with Stimulus
    User->>cart_controller.ts: initialize() on page load
    cart_controller.ts->>localStorage: Read cart JSON array
    cart_controller.ts->>DOM: Build table rows dynamically
    cart_controller.ts->>DOM: Calculate VAT (price/1.2)
    User->>cart_controller.ts: Click "Checkout"
    cart_controller.ts->>CheckoutsController: POST /checkout with cart
    Note over cart_controller.ts: Includes CSRF token
```

**Key Points**:
- Cart state managed entirely in browser localStorage (no database)
- TypeScript controllers handle all cart operations
- VAT calculated client-side: `exVAT = price / 1.2`
- Cart cleared on success page via JavaScript
- No server-side cart validation before Stripe

### Material Calculator Flow (Turbo Frame)
```mermaid
sequenceDiagram
    User->>QuantitiesController: GET /quantities
    QuantitiesController->>User: Render calculator selection page
    User->>User: Click "Area Calculator"
    User->>Quantities::AreaController: GET /quantities/area
    Quantities::AreaController->>User: Render form in Turbo Frame
    User->>User: Fill form (area, layers, material, catalyst)
    User->>Quantities::AreaController: GET /quantities/area?area=10&layers=2...
    Note over Quantities::AreaController: Stateless calculation in controller
    Quantities::AreaController->>Quantities::AreaController: Calculate material length
    Quantities::AreaController->>Quantities::AreaController: Calculate resin volume
    Quantities::AreaController->>Quantities::AreaController: Calculate catalyst
    Quantities::AreaController->>Quantities::AreaController: Apply 15% wastage
    Quantities::AreaController->>User: Render results in same Turbo Frame
    Note over User: Page doesn't reload, only frame updates
```

**Key Points**:
- Pure calculation engine (no database persistence)
- All formulas in controller `index` action (no model)
- Constants: `material_width=0.95`, `ratio=1.6`, `wastage=1.15`
- Results bookmarkable (GET request with params)
- Three calculators: Area, Dimensions, Mould Rectangle

### Active Storage Image Upload Flow
```mermaid
sequenceDiagram
    Admin->>Admin::ProductsController: POST /admin/products with images[]
    Admin::ProductsController->>Admin::ProductsController: Check for duplicate filenames
    loop For each new image
        Admin::ProductsController->>Product.images: Check existing.filename
        alt Filename exists
            Admin::ProductsController->>ActiveStorage: Purge old image
        end
        Admin::ProductsController->>ActiveStorage: Attach new image
    end
    ActiveStorage->>VIPS: Process image variants
    VIPS->>ActiveStorage: Generate :thumb (50x50)
    VIPS->>ActiveStorage: Generate :medium (250x250)
    alt Development
        ActiveStorage->>LocalDisk: Store in storage/
    else Production
        ActiveStorage->>S3: Store in e-commerce-rails7-aws-s3-bucket
    end
    Admin::ProductsController->>Admin: Redirect to product page
```

**Key Points**:
- Custom duplicate prevention in `Admin::ProductsController#update` (lines 47-59)
- Requires VIPS library for image processing
- Variants defined inline in model: `has_many_attached :images do |attachable|`
- Storage: Local (dev/test) vs S3 (production)
- S3 region: eu-central-1, bucket: e-commerce-rails7-aws-s3-bucket

### Active Storage Image Pipeline
- **Development**: Local disk (`storage/`)
- **Production**: AWS S3 (region: eu-central-1, bucket: e-commerce-rails7-aws-s3-bucket)
- **Variants**: `:thumb` (50x50), `:medium` (250x250)
- **Image Processing**: Requires VIPS library
- **Duplicate Prevention**: `Admin::ProductsController#update` lines 47-59

### Database Schema
```
categories ──┐
             ├─< products >─┬─< stocks (variant pricing)
             │              ├─< order_products (price snapshot)
             │              └─< images (Active Storage)
orders ──────┴─< order_products

admin_users (Devise auth)
```

**Key Relationships**:
- `OrderProduct.price` is a snapshot (not calculated) - captures price at purchase time
- `Product.stock_level` OR `Stock.stock_level` (two pricing models)
- Migration history: `amount` → `stock_level`, `weight` → `shipping_weight`

## Unique Project Patterns

### 1. **Admin Namespace Convention**
```ruby
# Controllers use @admin_ prefix for instance variables
@admin_product = Product.find(params[:id])  # NOT Admin::Product

# But reference base models
Product.all                                  # NOT Admin::Product.all
```
**Why**: No `Admin::Product` model exists - `admin` is just a controller namespace.

### 2. **Price Storage: Always in Pence**
```ruby
# Database
Product.create(price: 1000)  # £10.00 (stored as 1000 pence)

# Views
formatted_price(price)       # Helper converts to £10.00

# JavaScript
formatCurrency(price)        # Divides by 100 for display
```

### 3. **Stimulus Values API Pattern**
```erb
<!-- Rails passes data to TypeScript controllers -->
<div data-controller="products"
     data-products-product-value="<%= @product.to_json %>"
     data-products-stock-value="<%= @product.stocks.to_json %>">
```
```typescript
// TypeScript controller declares types
declare readonly productValue: Product
declare readonly stockValue: Stock[]
```

### 4. **VAT Calculation (20% UK VAT)**
```javascript
// Prices are VAT-inclusive
const exVAT = price / 1.2;
const vat = price - (price / 1.2);
```

### 5. **Turbo Frame Calculators**
```erb
<%= turbo_frame_tag "area" do %>
  <%= form_with url: quantities_area_path, method: :get %>
    <!-- Form submits, updates frame without page reload -->
  <% end %>
<% end %>
```

## Common Gotchas for AI Agents

### 🚨 Critical Mistakes to Avoid

1. **DO NOT** create orders in `CheckoutsController` - use webhooks only
2. **DO NOT** use `Admin::Product` - there's no such model (namespace confusion)
3. **DO NOT** use `:unprocessable_entity` status - use `:unprocessable_content` (Rails 7.1+)
4. **DO NOT** store prices in pounds - always use pence (integers)
5. **DO NOT** skip `with_attached_images` - will cause N+1 queries
6. **DO NOT** use RSpec syntax - this project uses Minitest

### ✅ Best Practices

1. **DO** use strong parameters in all controllers
2. **DO** start all Ruby files with `# frozen_string_literal: true`
3. **DO** run `bin/rails test:all` before committing
4. **DO** run `rubocop -a` to fix style issues
5. **DO** use TypeScript for all new JavaScript
6. **DO** use Rails credentials for secrets: `EDITOR="code --wait" rails credentials:edit`

## Testing Patterns

### Minitest (NOT RSpec)
```ruby
class ProductTest < ActiveSupport::TestCase
  test "should validate presence of name" do
    product = Product.new(price: 1000)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end
end
```

### Admin Controller Tests
```ruby
class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)  # Devise helper
    @admin_product = products(:one)
  end

  test "should get index" do
    get admin_products_url
    assert_response :success
  end
end
```

### System Tests (Capybara)
```ruby
class Admin::ProductsTest < ApplicationSystemTestCase
  setup do
    sign_in admin_users(:admin_user_one)
  end

  test "visiting the index" do
    visit admin_products_url
    assert_selector "h1", text: "Products"
  end
end
```

**Current Status**: 507 tests, 1,151 assertions, 0 failures, 85.12% coverage

**Critical Gap**: `WebhooksController` has NO tests (highest risk)

## Development Environment

### DevContainer (Recommended)
- **Containers**: app (Rails), postgres (PostgreSQL 17), pgadmin
- **Ports**: 3000 (Rails), 5432 (PostgreSQL), 15432 (pgAdmin)
- **Database**: postgres/postgres, auto-migrated on startup
- **Extensions**: ruby-lsp, solargraph, rubocop, tailwindcss, pgsql

### Build Process
```bash
# Procfile.dev (bin/dev)
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
js: yarn build --watch
```

### Credentials Structure
```yaml
stripe:
  secret_key: sk_...
  webhook_key: whsec_...
aws:
  access_key_id: AKIA...
  secret_access_key: ...
```

## File Structure Hotspots

```
app/
├── controllers/
│   ├── admin/              # Admin CRUD (inherits from AdminController)
│   ├── quantities/         # Material calculators (business logic in controllers)
│   ├── checkouts_controller.rb  # Stripe session creation
│   └── webhooks_controller.rb   # Order creation (NO TESTS!)
├── javascript/
│   └── controllers/        # TypeScript Stimulus controllers
│       ├── cart_controller.ts       # LocalStorage cart management
│       ├── products_controller.ts   # Add to cart, size selection
│       └── dashboard_controller.ts  # Chart.js revenue charts
├── models/                 # 8 models: Product, Stock, Category, Order, OrderProduct, AdminUser, ProductStock
└── views/
    ├── admin/              # Admin interface (layout: admin.html.erb)
    ├── quantities/         # Calculator interfaces (Turbo Frames)
    └── layouts/
        ├── application.html.erb  # Public shop (blue theme)
        └── admin.html.erb        # Admin panel (gray theme)

config/
├── credentials.yml.enc     # Stripe keys, AWS keys (use rails credentials:edit)
├── routes.rb              # 20 controllers, nested admin resources
└── tailwind.config.js     # Tailwind with forms, aspect-ratio, typography plugins

test/
├── controllers/           # Integration tests
├── models/                # Unit tests
└── system/                # Capybara browser tests
```

## Production Deployment (Render)

### Multi-Stage Docker Build
1. **Base**: Ruby 3.2.2-slim, set production env
2. **Build**: Install deps, precompile bootsnap, assets (SECRET_KEY_BASE_DUMMY=1 trick)
3. **Final**: Minimal runtime, non-root user, expose 3000

### Build Script (`bin/render-build.sh`)
```bash
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
```

### Required Environment Variables
- `RAILS_MASTER_KEY` - Decrypts credentials
- `DATABASE_URL` - Auto-set by Render
- `WEB_CONCURRENCY=2` - Puma workers
- Stripe keys (from credentials or ENV)
- AWS keys for S3 (from credentials or ENV)

## Security Considerations

### Rack::Attack Rate Limiting
- **Global**: 300 req/5min per IP
- **Admin login**: 5 attempts/20sec per IP+email
- **Checkout**: 10 attempts/min per IP
- **Contact**: 5 submissions/min per IP
- **Config**: `config/initializers/rack_attack.rb`

### Authentication
- **Admin**: Devise on `AdminUser` model
- **Public**: No authentication (guest checkout)
- **No MFA** - Recommended for production

### CSRF Protection
- Automatic via Rails
- Stimulus controllers: `document.querySelector("[name='csrf-token']").content`

## Material Quantity Calculator API

### Constants
- `material_width` = 0.95m (roll width)
- `ratio` = 1.6:1 (resin to glass)
- `wastage` = 15% (multiply by 1.15)

### Formulas
```ruby
# Material
@mat = ((@area * @layers) / @material_width).round(2)
@mat_total = (@mat * 1.15).round(2)

# Resin
@resin = ((@area * @layers) * @ratio).round(2)
@resin_total = (@resin * 1.15).round(2)

# Catalyst
@catalyst_ml = (((@resin_total / 10) * @catalyst) * 100).round(2)
```

### Endpoints
- `GET /quantities/area` - Area-based calculation
- `GET /quantities/dimensions` - Length/width calculation
- `GET /quantities/mould_rectangle` - Rectangular mould (all 6 faces)

## Code Review Checklist

### Pre-Submission Checklist

Before submitting a PR, AI agents should verify:

**Tests & Quality**
- [ ] All tests pass: `bin/rails test:all` (507 runs, 1,151 assertions)
- [ ] RuboCop passes: `rubocop -a` (136 files inspected, 0 offenses)
- [ ] TypeScript builds: `yarn build` (no compilation errors)
- [ ] Coverage maintained or improved (currently 85.12%)
- [ ] New features include tests (unit + integration minimum)

**Code Standards**
- [ ] All Ruby files start with `# frozen_string_literal: true`
- [ ] Strong parameters used in all controllers
- [ ] Prices stored in pence (integers, not floats)
- [ ] Used `:unprocessable_content` (not deprecated `:unprocessable_entity`)
- [ ] No `binding.pry` or debug code left in
- [ ] TypeScript uses strict mode with proper types

**Rails Conventions**
- [ ] Admin controllers inherit from `AdminController`
- [ ] Instance variables use `@admin_` prefix in admin namespace
- [ ] Models referenced correctly (e.g., `Product`, not `Admin::Product`)
- [ ] Validations present on all model fields
- [ ] Used `with_attached_images` to prevent N+1 queries

**Security & Performance**
- [ ] No SQL injection vulnerabilities (use parameterized queries)
- [ ] CSRF token included in AJAX requests
- [ ] Sensitive data not logged (check parameter filtering)
- [ ] No N+1 queries introduced (use `includes`, `with_attached_*`)
- [ ] Indexes added for new foreign keys or frequently queried columns

**Documentation**
- [ ] Updated README.md if public API changed
- [ ] Updated `.github/copilot-instructions.md` if architecture changed
- [ ] Added inline comments for complex business logic
- [ ] Updated schema diagram if database changed

**Critical Patterns**
- [ ] Orders created ONLY in webhooks (never in controllers)
- [ ] Webhook signatures verified before processing
- [ ] Stock decremented ONLY after payment confirmation
- [ ] Cart operations use localStorage (client-side)
- [ ] Calculator logic isolated to controller actions

### Common Review Issues

**❌ Anti-Patterns to Reject**:
1. Creating orders in `CheckoutsController` (bypasses payment verification)
2. Using `Admin::Product` (model doesn't exist)
3. Storing prices in pounds/floats (must be pence/integers)
4. Missing strong parameters
5. N+1 queries without eager loading
6. Missing tests for critical code paths
7. Using deprecated status codes (`:unprocessable_entity`)

**✅ Patterns to Approve**:
1. Webhook-driven order creation with signature verification
2. Client-side cart state in localStorage
3. Prices in pence with `formatted_price` helper
4. Strong parameters in all controllers
5. Eager loading with `includes` or `with_attached_*`
6. Comprehensive test coverage (unit + integration + system)
7. Modern Rails 7.1 status codes (`:unprocessable_content`)

### Review Template

When reviewing PRs, check:

```markdown
## Code Review

### Functionality
- [ ] Feature works as described
- [ ] No regressions in existing features
- [ ] Edge cases handled

### Code Quality
- [ ] Follows project conventions
- [ ] DRY principle applied
- [ ] Clear variable/method names
- [ ] Appropriate abstraction level

### Testing
- [ ] Test coverage adequate
- [ ] Tests are meaningful (not just coverage)
- [ ] System tests for user flows

### Security
- [ ] No security vulnerabilities introduced
- [ ] Input validation present
- [ ] Authorization checks in place

### Performance
- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] Appropriate caching strategy

### Comments
[Detailed feedback here]
```

## Where to Learn More

- **Comprehensive Guide**: [.github/copilot-instructions.md](.github/copilot-instructions.md) (detailed)
- **Contributing**: [CONTRIBUTING.md](../CONTRIBUTING.md) (coding standards)
- **Database Schema**: [documentation/schema-diagram.md](../documentation/schema-diagram.md) (ERD)
- **Test Analysis**: [documentation/test-analysis.md](../documentation/test-analysis.md) (test suite breakdown)
- **Improvement Ideas**: [documentation/codebase-analysis.md](../documentation/codebase-analysis.md) (10 areas)

## Feedback for Iteration

**Questions for Project Maintainer**:

1. **Calculator Refactoring**: Should we refactor calculator logic from controllers to service objects? Current pattern works but violates SRP.

2. **Webhook Testing**: `WebhooksController` has no tests - is this intentional? This is the most critical controller.

3. **Cart Persistence**: Should we add server-side cart storage for logged-in users? Current localStorage works for guests but no cross-device support.

4. **Admin MFA**: Production deployment needs 2FA for admin users - should we add devise-two-factor?

5. **N+1 Query Fixes**: Should we prioritize fixing known N+1 queries in `CategoriesController#show` and `AdminController#index`?

6. **Service Object Pattern**: Should we introduce a service object pattern for complex operations (e.g., `OrderCreationService`, `InventoryDecrementService`)?

---

**Last Updated**: November 29, 2025
**Schema Version**: 2025_11_27_015536
**Test Coverage**: 85.12% (509/598 lines)
