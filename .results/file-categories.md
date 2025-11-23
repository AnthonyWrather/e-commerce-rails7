# File Categorization

## Summary Statistics
- **Total Files**: 225
- **Ruby Files**: 67
- **TypeScript Files**: 7
- **ERB Templates**: 50
- **Configuration Files**: 27
- **Test Files**: 24
- **Static Assets**: 10
- **Build Artifacts**: 3
- **Documentation**: 6
- **Other**: 31

## 1. Backend - Models (8 files)
**Purpose**: ActiveRecord models defining database schema and relationships
**Location**: `app/models/`

- `app/models/application_record.rb` - Base class for all models
- `app/models/admin_user.rb` - Devise authentication model
- `app/models/category.rb` - Product categories
- `app/models/order.rb` - Customer orders
- `app/models/order_product.rb` - Join table (order line items)
- `app/models/product.rb` - Products with images
- `app/models/product_stock.rb` - Legacy stock model (unused)
- `app/models/stock.rb` - Size variant pricing

**Characteristics**:
- Minimal business logic (mostly associations)
- No validations (relies on DB constraints)
- No scopes or custom methods
- Active Storage attachments (images)

## 2. Backend - Controllers (20 files)
**Purpose**: Handle HTTP requests, orchestrate business logic
**Location**: `app/controllers/`

### Public-Facing Controllers (9)
- `app/controllers/application_controller.rb` - Base controller
- `app/controllers/home_controller.rb` - Landing page
- `app/controllers/categories_controller.rb` - Category browsing with filtering
- `app/controllers/products_controller.rb` - Product details
- `app/controllers/carts_controller.rb` - Shopping cart display
- `app/controllers/checkouts_controller.rb` - Stripe checkout creation
- `app/controllers/webhooks_controller.rb` - Stripe webhook handler
- `app/controllers/contact_controller.rb` - Contact form (stub)
- `app/controllers/quantities_controller.rb` - Calculator landing page

### Admin Controllers (6)
**Namespace**: `admin/`
- `app/controllers/admin_controller.rb` - Admin dashboard with metrics
- `app/controllers/admin/categories_controller.rb` - Category CRUD
- `app/controllers/admin/products_controller.rb` - Product CRUD with image management
- `app/controllers/admin/stocks_controller.rb` - Variant CRUD (nested under products)
- `app/controllers/admin/orders_controller.rb` - Order management
- `app/controllers/admin/reports_controller.rb` - Revenue charts
- `app/controllers/admin/images_controller.rb` - Image deletion

### Quantities Calculator Controllers (3)
**Namespace**: `quantities/`
- `app/controllers/quantities/area_controller.rb` - Area-based material calculations
- `app/controllers/quantities/dimensions_controller.rb` - Dimension-based calculations
- `app/controllers/quantities/mould_rectangle_controller.rb` - Mould calculations

**Characteristics**:
- Business logic in controllers (no service objects)
- Pagy pagination in admin controllers
- Breadcrumbs_on_rails for navigation
- `@admin_*` instance variable naming in admin controllers

## 3. Frontend - Views (50 files)
**Purpose**: ERB templates for HTML rendering
**Location**: `app/views/`

### Layouts (4)
- `app/views/layouts/application.html.erb` - Public-facing layout
- `app/views/layouts/admin.html.erb` - Admin interface layout
- `app/views/layouts/mailer.html.erb` - Email HTML layout
- `app/views/layouts/mailer.text.erb` - Email text layout

### Shared Partials (2)
- `app/views/shared/_navbar.html.erb` - Public navigation
- `app/views/shared/_footer.html.erb` - Public footer

### Public Views (8)
- `app/views/home/index.html.erb` - Landing page
- `app/views/categories/show.html.erb` - Category with product grid
- `app/views/products/show.html.erb` - Product details with Stimulus
- `app/views/carts/show.html.erb` - Shopping cart
- `app/views/checkouts/success.html.erb` - Order confirmation
- `app/views/checkouts/cancel.html.erb` - Checkout cancellation
- `app/views/contact/index.html.erb` - Contact form
- `app/views/quantities/index.html.erb` - Calculator selection

### Calculator Views (3)
- `app/views/quantities/area/index.html.erb` - Area calculator form & results
- `app/views/quantities/dimensions/index.html.erb` - Dimensions calculator
- `app/views/quantities/mould_rectangle/index.html.erb` - Mould calculator

### Admin Views (30)
**Categories** (8 files):
- index, show, new, edit (HTML)
- index, show (JSON builders)
- `_form.html.erb`, `_category.html.erb` (partials)
- `_admin_category.json.jbuilder` (JSON partial)

**Products** (8 files):
- index, show, new, edit (HTML)
- index, show (JSON builders)
- `_form.html.erb`, `_product.html.erb` (partials)
- `_admin_product.json.jbuilder` (JSON partial)

**Stocks** (8 files):
- index, show, new, edit (HTML)
- index, show (JSON builders)
- `_form.html.erb`, `_stock.html.erb` (partials)
- `_admin_stock.json.jbuilder` (JSON partial)

**Orders** (8 files):
- index, show, new, edit (HTML)
- index, show (JSON builders)
- `_form.html.erb`, `_order.html.erb` (partials)
- `_admin_order.json.jbuilder` (JSON partial)

**Reports** (1 file):
- `app/views/admin/reports/index.html.erb` - Revenue dashboard

**Dashboard** (1 file):
- `app/views/admin/index.html.erb` - Admin landing with charts

**Images** (1 file):
- `app/views/admin/images/destroy.html.erb` - Image deletion view

### Email Views (2)
- `app/views/order_mailer/new_order_email.html.erb` - Order confirmation HTML
- `app/views/order_mailer/new_order_email.text.erb` - Order confirmation text

**Characteristics**:
- Tailwind CSS utility classes
- Stimulus data attributes for interactivity
- Turbo Frame tags in calculators
- Font Awesome icons via helper
- Pagy pagination
- Breadcrumbs in public views

## 4. Frontend - TypeScript (7 files)
**Purpose**: Client-side interactivity with type safety
**Location**: `app/javascript/`

### Application Entry Point (1)
- `app/javascript/application.ts` - Google Analytics, Turbo/Stimulus initialization

### Stimulus Controllers (6)
- `app/javascript/controllers/application.ts` - Stimulus app setup
- `app/javascript/controllers/index.ts` - Controller registration
- `app/javascript/controllers/cart_controller.ts` - Cart rendering, checkout, localStorage
- `app/javascript/controllers/products_controller.ts` - Size selection, add to cart
- `app/javascript/controllers/dashboard_controller.ts` - Chart.js revenue charts
- `app/javascript/controllers/quantities_controller.ts` - Calculator stub

**Characteristics**:
- TypeScript 5.3.3 with strict mode
- Comprehensive interfaces (CartItem, Product, Stock, etc.)
- Type declarations for Stimulus values
- Null safety with type guards
- DOM element type casting
- No `.ts` extensions in imports

## 5. Frontend - Styles (2 files)
**Purpose**: CSS styling
**Location**: `app/assets/stylesheets/`

- `app/assets/stylesheets/application.tailwind.css` - Tailwind directives
- `app/assets/stylesheets/application.css.scss` - Font Awesome import

**Characteristics**:
- Tailwind CSS utility-first approach
- Font Awesome SASS integration
- Minimal custom CSS

## 6. Frontend - Static Assets (10 files)
**Purpose**: Images, icons, static files
**Location**: `app/assets/images/`, `public/`

### Images (4)
- `app/assets/images/favicon.ico`
- `app/assets/images/SCFS-Header.jpg`
- `app/assets/images/SCFS-Logo.jpg`
- `app/assets/images/success.png`

### Public Files (6)
- `public/404.html` - Not found page
- `public/422.html` - Unprocessable entity
- `public/500.html` - Server error
- `public/favicon.ico`
- `public/apple-touch-icon.png`
- `public/apple-touch-icon-precomposed.png`
- `public/robots.txt`

## 7. Build Artifacts (3 files)
**Purpose**: Generated files from build process
**Location**: `app/assets/builds/`

- `app/assets/builds/application.js` - esbuild output (762KB)
- `app/assets/builds/application.js.map` - Source map
- `app/assets/builds/tailwind.css` - Compiled Tailwind

**Note**: These should be in `.gitignore` but are currently tracked

## 8. Backend - Mailers (2 files)
**Purpose**: Email sending logic
**Location**: `app/mailers/`

- `app/mailers/application_mailer.rb` - Base mailer
- `app/mailers/order_mailer.rb` - Order confirmation emails

**Characteristics**:
- ActionMailer framework
- Triggered in webhooks controller
- Letter Opener Web for preview

## 9. Backend - Helpers (12 files)
**Purpose**: View helper methods
**Location**: `app/helpers/`

### Application Helpers (2)
- `app/helpers/application_helper.rb` - `formatted_price`, `icon` helpers
- `app/helpers/contact_helper.rb`
- `app/helpers/quantities_helper.rb`

### Admin Helpers (6)
- `app/helpers/admin/categories_helper.rb`
- `app/helpers/admin/images_helper.rb`
- `app/helpers/admin/orders_helper.rb`
- `app/helpers/admin/products_helper.rb`
- `app/helpers/admin/reports_helper.rb`
- `app/helpers/admin/stocks_helper.rb`

### Quantities Helpers (3)
- `app/helpers/quantities/area_helper.rb`
- `app/helpers/quantities/dimensions_helper.rb`
- `app/helpers/quantities/mould_rectangle_helper.rb`

**Characteristics**:
- Mostly empty (Rails convention)
- `formatted_price` in application_helper (divides pence by 100)
- `icon` helper for Font Awesome

## 10. Backend - Jobs (1 file)
**Purpose**: Background job processing
**Location**: `app/jobs/`

- `app/jobs/application_job.rb` - Base job class (unused)

**Note**: Active Job configured but no custom jobs defined

## 11. Backend - Channels (2 files)
**Purpose**: WebSocket connections
**Location**: `app/channels/`

- `app/channels/application_cable/channel.rb` - Base channel
- `app/channels/application_cable/connection.rb` - Connection setup

**Note**: Action Cable configured but no custom channels

## 12. Configuration - Rails (17 files)
**Purpose**: Application configuration
**Location**: `config/`

### Core Config (7)
- `config/application.rb` - Rails app config (timezone: London)
- `config/boot.rb` - Bundler setup
- `config/environment.rb` - Environment loader
- `config/routes.rb` - URL routing
- `config/database.yml` - PostgreSQL config
- `config/puma.rb` - Web server config
- `config/cable.yml` - Action Cable (Redis)
- `config/storage.yml` - Active Storage (S3 in production)

### Environment-Specific (3)
- `config/environments/development.rb` - Dev settings (ngrok host)
- `config/environments/production.rb` - Prod settings (force SSL)
- `config/environments/test.rb` - Test settings

### Initializers (6)
- `config/initializers/assets.rb` - Asset pipeline
- `config/initializers/content_security_policy.rb` - CSP (commented out)
- `config/initializers/devise.rb` - Authentication
- `config/initializers/filter_parameter_logging.rb` - Sensitive data filtering
- `config/initializers/inflections.rb` - Pluralization rules
- `config/initializers/permissions_policy.rb` - Permissions (commented out)

### Secrets (2)
- `config/master.key` - Credentials encryption key
- `config/credentials.yml.enc` - Encrypted secrets (Stripe keys, AWS)

**Characteristics**:
- Convention over configuration
- Timezone: London
- Database: PostgreSQL (development and production)
- Active Storage: S3 in production, local in development
- Redis for Action Cable

## 13. Configuration - Frontend (4 files)
**Purpose**: JavaScript/TypeScript build configuration
**Location**: Root and `config/`

- `package.json` - npm dependencies and scripts
- `yarn.lock` - Dependency lock file
- `tsconfig.json` - TypeScript compiler config
- `config/tailwind.config.js` - Tailwind CSS config
- `config/importmap.rb` - Import maps (deprecated, migrated to esbuild)

**Characteristics**:
- esbuild bundler (not webpack)
- TypeScript strict mode
- Tailwind plugins: forms, aspect-ratio, typography, container-queries

## 14. Configuration - Deployment (3 files)
**Purpose**: Docker, build, deployment
**Location**: Root

- `Dockerfile` - Multi-stage production build
- `render.yaml` - Render.com deployment config
- `Procfile.dev` - Foreman process management (dev)

**Characteristics**:
- Multi-stage Dockerfile (base, build, final)
- Non-root user in production
- Node.js 20.x for JavaScript build
- Render.com deployment target

## 15. Database (22 files)
**Purpose**: Schema, migrations, seeds
**Location**: `db/`

### Schema (2)
- `db/schema.rb` - Current database schema (auto-generated)
- `db/seeds.rb` - Seed data (empty stub)

### Migrations (20)
Chronological list:
1. `20231212144708_devise_create_admins.rb` - Admin users (Devise)
2. `20231213150925_create_admin_categories.rb` - Categories table
3. `20231213154754_create_active_storage_tables.active_storage.rb` - Active Storage
4. `20231213163456_create_admin_products.rb` - Products table
5. `20231214001038_create_admin_stocks.rb` - Stocks table
6. `20231214151144_create_admin_orders.rb` - Orders table
7. `20231214152733_create_order_products.rb` - Order products join table
8. `20250824224009_add_price_to_stock.rb` - Variant pricing
9. `20250825165212_add_amount_to_product.rb` - Product stock level
10. `20250829205019_add_price_to_order_products.rb` - Capture price at purchase
11. `20250831003533_add_name_to_order.rb` - Shipping name
12. `20250904201029_add_billing_to_order.rb` - Billing address
13. `20250922122911_add_shipping_to_stock.rb` - Shipping dimensions (stock)
14. `20250922122955_add_shipping_to_product.rb` - Shipping dimensions (product)
15. `20250923165631_add_shipping_to_orders.rb` - Shipping cost
16. `20250923193239_add_shipping_id_and_description_to_orders.rb` - Shipping tracking
17. `20251120215534_rename_admins_to_admin_users.rb` - Rename admin table

**Migration Patterns**:
- Iterative schema evolution
- Add columns (no schema changes after initial create)
- Recent focus on shipping and pricing features

## 16. Testing - Unit Tests (24 files)
**Purpose**: Minitest test suite
**Location**: `test/`

### Test Infrastructure (2)
- `test/test_helper.rb` - Test configuration
- `test/application_system_test_case.rb` - System test base (Selenium)

### Model Tests (6)
- `test/models/admin_user_test.rb`
- `test/models/order_product_test.rb`
- `test/models/admin/category_test.rb`
- `test/models/admin/order_test.rb`
- `test/models/admin/product_test.rb`
- `test/models/admin/stock_test.rb`

### Controller Tests (10)
- `test/controllers/contact_controller_test.rb`
- `test/controllers/quantities_controller_test.rb`
- `test/controllers/admin/categories_controller_test.rb`
- `test/controllers/admin/images_controller_test.rb`
- `test/controllers/admin/orders_controller_test.rb`
- `test/controllers/admin/products_controller_test.rb`
- `test/controllers/admin/reports_controller_test.rb`
- `test/controllers/admin/stocks_controller_test.rb`
- `test/controllers/quantities/area_controller_test.rb`
- `test/controllers/quantities/dimensions_controller_test.rb`
- `test/controllers/quantities/mould_rectangle_controller_test.rb`

### System Tests (4)
- `test/system/admin/categories_test.rb` - Browser tests with Capybara
- `test/system/admin/orders_test.rb`
- `test/system/admin/products_test.rb`
- `test/system/admin/stocks_test.rb`

### Mailer Tests (2)
- `test/mailers/order_mailer_test.rb`
- `test/mailers/previews/order_mailer_preview.rb` - Email preview

### Channel Tests (1)
- `test/channels/application_cable/connection_test.rb`

### Fixtures (6)
YAML test data:
- `test/fixtures/admin_users.yml`
- `test/fixtures/categories.yml`
- `test/fixtures/order_products.yml`
- `test/fixtures/orders.yml`
- `test/fixtures/products.yml`
- `test/fixtures/stocks.yml`

**Characteristics**:
- Minitest (not RSpec)
- Capybara for system tests
- Selenium WebDriver (Chrome headless)
- Minimal fixtures
- 36 tests, 55 assertions, 1 skip

## 17. Scripts & Executables (8 files)
**Purpose**: Command-line tools
**Location**: `bin/`

- `bin/bundle` - Bundler wrapper
- `bin/dev` - Foreman process manager (Rails + Tailwind + JS)
- `bin/docker-entrypoint` - Container startup script
- `bin/importmap` - Import map CLI (deprecated)
- `bin/rails` - Rails CLI
- `bin/rake` - Rake task runner
- `bin/render-build.sh` - Render.com build script
- `bin/setup` - Initial project setup

**Characteristics**:
- All executable (`chmod +x`)
- `bin/dev` runs Foreman (Procfile.dev)
- `bin/render-build.sh` runs yarn build, assets:precompile, db:migrate

## 18. Documentation (6 files)
**Purpose**: Project documentation
**Location**: `documentation/`, root

- `README.md` - Project overview and setup guide
- `LICENSE` - Project license
- `documentation/schema-diagram.md` - Database ER diagram (Mermaid)
- `documentation/DevCICD Pipeline.pdf` - CI/CD documentation
- `documentation/Product-Stock-Order-Order_Products.pdf` - Data model diagram
- `documentation/The Scrum Process.pdf` - Scrum methodology
- `documentation/Data Layout .pdf` - Data structure documentation

**Characteristics**:
- Comprehensive README with setup instructions
- Mermaid ER diagram for database schema
- PDF documentation for processes

## 19. Localization (2 files)
**Purpose**: Internationalization
**Location**: `config/locales/`

- `config/locales/en.yml` - English translations
- `config/locales/devise.en.yml` - Devise authentication messages

**Note**: Only English locale defined (UK-focused app)

## 20. Root Configuration (6 files)
**Purpose**: Project-level configuration
**Location**: Root directory

- `Gemfile` - Ruby dependencies
- `Gemfile.lock` - Dependency lock file
- `Rakefile` - Rake task definitions
- `config.ru` - Rack application entry point
- `.rubocop.yml` - (if exists) RuboCop linting rules
- `render.yaml` - Render.com deployment

## File Organization Patterns

### Naming Conventions
- **Models**: Singular (e.g., `product.rb`, not `products.rb`)
- **Controllers**: Plural + `_controller.rb` (e.g., `products_controller.rb`)
- **Views**: Match controller action names
- **TypeScript**: Snake case with `.ts` extension
- **Tests**: Match source file with `_test.rb` suffix

### Namespace Structure
- **Admin**: Separate namespace for admin features (`app/controllers/admin/`, `app/views/admin/`)
- **Quantities**: Separate namespace for calculators
- **Shared**: Common partials in `app/views/shared/`

### Asset Pipeline
- **Source**: `app/javascript/`, `app/assets/stylesheets/`
- **Build**: `app/assets/builds/`
- **Static**: `public/`
- **Images**: `app/assets/images/` (processed) or `public/` (static)

### Configuration Hierarchy
1. **Global**: `config/application.rb`
2. **Environment**: `config/environments/{development,test,production}.rb`
3. **Initializers**: `config/initializers/*.rb` (run on boot)
4. **Secrets**: `config/credentials.yml.enc` (encrypted)

## Files by Domain

### E-Commerce Core
- Models: Product, Category, Stock, Order, OrderProduct
- Controllers: Products, Categories, Carts, Checkouts, Webhooks
- Views: Product listings, cart, checkout success/cancel
- TypeScript: cart_controller, products_controller

### Admin Dashboard
- Controllers: Admin namespace (6 controllers)
- Views: Admin layouts, CRUD views, reports
- TypeScript: dashboard_controller (Chart.js)

### Material Calculators
- Controllers: Quantities namespace (4 controllers)
- Views: Calculator forms and results
- TypeScript: quantities_controller (stub)

### Authentication
- Model: AdminUser (Devise)
- Config: devise.rb initializer
- Locales: devise.en.yml

### Payment Processing
- Controller: Checkouts, Webhooks
- Config: Stripe keys in credentials
- Views: Success, cancel pages

### Email
- Mailer: OrderMailer
- Views: HTML and text email templates
- Config: Letter Opener Web for preview

## Dependency Graph

### Backend Dependencies
```
ApplicationController
├── Admin controllers → AdminUser (Devise)
├── Public controllers → No auth
└── Webhooks → Stripe signature verification

ApplicationRecord
├── AdminUser (Devise)
├── Category → has_many Products
├── Product → belongs_to Category, has_many Stocks, has_many OrderProducts
├── Stock → belongs_to Product
├── Order → has_many OrderProducts
└── OrderProduct → belongs_to Product, belongs_to Order
```

### Frontend Dependencies
```
application.ts (entry point)
├── Stimulus (Hotwire)
│   ├── cart_controller.ts → localStorage, Stripe checkout
│   ├── products_controller.ts → add to cart, size selection
│   ├── dashboard_controller.ts → Chart.js
│   └── quantities_controller.ts → (stub)
├── Turbo (Hotwire) → SPA-like navigation
└── Google Analytics → gtag.js
```

### Build Pipeline
```
TypeScript (.ts files)
└── esbuild → application.js (762KB)
    └── Sprockets → served to browser

Tailwind CSS (.tailwind.css)
└── Tailwind CLI → tailwind.css
    └── Sprockets → served to browser
```

## Files to Ignore (Not in Categorization)

### Generated/Temporary (excluded from count)
- `tmp/` - Temporary files, cache, PIDs
- `log/` - Rails logs
- `storage/` - Active Storage files (development)
- `node_modules/` - npm packages
- `vendor/` - Vendored gems
- `.git/` - Git repository
- Hidden files (`.env`, `.gitignore`, etc.)

### Build Artifacts (should be ignored)
- `app/assets/builds/application.js` - esbuild output
- `app/assets/builds/application.js.map` - Source map
- `app/assets/builds/tailwind.css` - Tailwind output

**Note**: Build artifacts are currently tracked in git but should be in `.gitignore` and regenerated on deployment

