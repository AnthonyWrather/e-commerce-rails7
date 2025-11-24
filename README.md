# Composite Materials E-Commerce Platform

[![Rails](https://img.shields.io/badge/Rails-7.1.2-red?style=flat-square&logo=rubyonrails)](https://rubyonrails.org)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.2-red?style=flat-square&logo=ruby)](https://www.ruby-lang.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3.3-blue?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-blue?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

A specialized B2B/B2C e-commerce platform for selling composite materials (fiberglass, resins, tools) with integrated **material quantity calculators** for precise project estimation. Built with Rails 7, TypeScript, and Stripe payments.

[Overview](#overview) • [Features](#features) • [Getting Started](#getting-started) • [Development](#development) • [Deployment](#deployment) • [Documentation](#documentation)

---

## Overview

This platform serves the composite materials industry with a unique combination of e-commerce and engineering calculation tools. Unlike typical online stores, it includes specialized calculators that help customers determine exact material quantities needed for their fiberglass and composite projects.

**Key Characteristics:**
- **Guest Checkout Only** - No customer accounts required, email-based order tracking
- **UK-Focused** - GBP currency, 20% VAT, GB shipping options only
- **Dual Pricing Model** - Products can have single pricing or variant pricing by size
- **Stripe Integration** - Payment processing with webhook-driven order creation
- **Material Calculators** - Industry-specific tools for composite material calculations

**Technology Stack:**
- **Backend**: Ruby 3.2.2, Rails 7.1.2, PostgreSQL
- **Frontend**: TypeScript 5.3.3 (strict mode), Stimulus, Turbo, Tailwind CSS
- **Payments**: Stripe (GBP, webhook-driven orders)
- **Storage**: AWS S3 (production), Active Storage
- **Email**: MailerSend (production), Letter Opener Web (development)
- **Infrastructure**: Docker, Puma, Redis (configured)

---

## Features

### E-Commerce Core
- **Product Catalog** - Categories, multi-image galleries, product variants
- **Variant Pricing** - Size-based pricing (e.g., Small £10, Large £15)
- **Stock Management** - Product-level and variant-level inventory
- **Guest Checkout** - Shopping cart in localStorage, no account required
- **Stripe Payments** - Secure payment processing with GBP currency
- **Email Confirmations** - Order confirmation emails with full invoice details
- **Admin Dashboard** - CRUD operations, revenue charts, order management

### Material Calculators (Unique Feature)
Three specialized calculators for composite material project estimation:

1. **Area Calculator** - Calculate materials needed for a given area (m²)
2. **Dimensions Calculator** - Calculate based on length, width, depth
3. **Mould Rectangle Calculator** - Calculate for rectangular mould projects

**Calculation Features:**
- 14 material types (Chop Strand Mat, Woven Roving, Biaxial, etc.)
- Industry-standard constants (0.95m roll width, 1.6:1 resin ratio)
- Automatic wastage calculation (15%)
- Outputs: mat length/weight, resin volume, catalyst volume, total weight

### Admin Features
- **Revenue Reports** - Chart.js visualizations, monthly/daily breakdowns
- **Product Management** - Multi-image upload, variant pricing, stock levels
- **Order Management** - View orders, mark as fulfilled
- **Category Management** - Organize products with images
- **Authentication** - Devise-based admin-only access

---

## Getting Started

### Prerequisites

**Required Tools:**
- [Docker](https://www.docker.com/products/docker-desktop) - For devcontainer
- [VS Code](https://code.visualstudio.com) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Git](https://git-scm.com/downloads)

**OR for local development without Docker:**
- [Ruby 3.2.2](https://www.ruby-lang.org/en/downloads/)
- [Node.js 20.x](https://nodejs.org/download/) with Yarn
- [PostgreSQL 14+](https://www.postgresql.org/download/)
- [VIPS](https://www.libvips.org/install.html) - For image processing

### Quick Start with Dev Container

The easiest way to get started is using the included devcontainer, which provides a fully configured development environment.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AnthonyWrather/e-commerce-rails7.git
   cd e-commerce-rails7
   ```

2. **Open in VS Code:**
   ```bash
   code .
   ```

3. **Reopen in Container:**
   - Press `F1` and select "Dev Containers: Reopen in Container"
   - Wait for the container to build (first time only, ~5 minutes)

4. **Setup the database:**
   ```bash
   bin/rails db:migrate
   ```

5. **Create an admin user:**
   ```bash
   bin/rails c
   # In the Rails console:
   AdminUser.create(email: "admin@example.com", password: "12345678")
   exit
   ```

6. **Start the development server:**
   ```bash
   bin/dev
   ```

7. **Visit the application:**
   - Shop: http://localhost:3000
   - Admin: http://localhost:3000/admin_users/sign_in
   - Email previews: http://localhost:3000/letter_opener
   - pgAdmin: http://localhost:15432 (admin@pgadmin.com / password)

> [!TIP]
> The devcontainer includes PostgreSQL, pgAdmin, and all required extensions pre-installed.

### Local Development (Without Docker)

If you prefer not to use Docker:

1. **Install dependencies:**
   ```bash
   bundle install
   yarn install
   ```

2. **Setup PostgreSQL:**
   - Ensure PostgreSQL is running
   - Update `config/database.yml` with your credentials

3. **Setup database and build assets:**
   ```bash
   bin/rails db:create db:migrate
   yarn build
   ```

4. **Create admin user** (see step 5 above)

5. **Start the server:**
   ```bash
   bin/dev
   ```

---

## Development

### Development Workflow

The project uses **Foreman** via `bin/dev` to run multiple processes:
- Rails server (port 3000)
- Tailwind CSS watcher (rebuilds on file changes)
- TypeScript/JavaScript watcher (esbuild)

**Common Commands:**
```bash
bin/dev                                    # Start all processes
bin/rails c                                # Rails console
bin/rails db:migrate                       # Run migrations
yarn build                                 # Build TypeScript once
yarn build:ts                              # Type-check + build
rubocop -a                                 # Auto-fix Ruby style issues
bin/rails test                             # Run tests
EDITOR="code --wait" rails credentials:edit # Edit encrypted credentials
```

### TypeScript Development

All Stimulus controllers are written in **TypeScript with strict mode** enabled:

```bash
yarn build                 # One-time build
yarn build --watch         # Watch mode (included in bin/dev)
tsc --noEmit              # Type-check only
```

Build output: `app/assets/builds/application.js` (762KB bundled)

**TypeScript Files:**
- `app/javascript/application.ts` - Entry point
- `app/javascript/controllers/cart_controller.ts` - Shopping cart
- `app/javascript/controllers/products_controller.ts` - Product interactions
- `app/javascript/controllers/dashboard_controller.ts` - Admin charts
- `app/javascript/controllers/quantities_controller.ts` - Calculator UI

### Testing Stripe Webhooks Locally

For local Stripe webhook testing, use **ngrok**:

```bash
# Start ngrok
ngrok http --url=YOUR-SUBDOMAIN.ngrok-free.app 3000

# Add to config/environments/development.rb:
config.hosts << "YOUR-SUBDOMAIN.ngrok-free.app"

# Configure webhook in Stripe Dashboard:
# URL: https://YOUR-SUBDOMAIN.ngrok-free.app/webhooks
# Events: checkout.session.completed
```

### Database Management

**PostgreSQL via Docker:**
- **pgAdmin**: http://localhost:15432
- **Direct connection**: `localhost:5432` (postgres/postgres)

**Users created:**
- `postgres` (superuser)
- `vscode` (with CREATEDB)
- `e_commerce_rails7` (with CREATEDB)

**Database backup directory:** `storage/pgadmin/backups`

### Email Testing

Development uses **Letter Opener Web** to preview emails in the browser:

```bash
# Access email previews at:
http://localhost:3000/letter_opener

# Trigger test email by completing a checkout
# or run in Rails console:
OrderMailer.new_order_email(Order.last).deliver_now
```

---

## Testing

The project uses **Minitest** (Rails default) with Capybara for system tests.

```bash
bin/rails test             # Run all unit/integration tests
bin/rails test:system      # Run Capybara browser tests
bin/rails test:all         # Run everything
```

**Current Status:**
- 36 test runs
- 55 assertions
- 0 failures
- 1 skip

**Test Structure:**
- `test/models/` - Model unit tests
- `test/controllers/` - Controller integration tests
- `test/system/admin/` - Browser tests for admin UI
- `test/fixtures/` - Test data

---

## Deployment

### Render.com Deployment

The application is configured for deployment on **Render.com** with PostgreSQL.

**Build Command:**
```bash
./bin/render-build.sh
# Runs: bundle install, assets:precompile, assets:clean, db:migrate, track-deployment
```

**Start Command:**
```bash
bundle exec puma -C config/puma.rb
```

**Required Environment Variables:**
- `DATABASE_URL` - Provided automatically by Render PostgreSQL
- `RAILS_MASTER_KEY` - Copy from `config/master.key`
- `STRIPE_SECRET_KEY` - Stripe API secret key
- `STRIPE_WEBHOOK_KEY` - Stripe webhook signing secret
- `WEB_CONCURRENCY` - Set to `2` for production

**Optional Environment Variables:**
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - For S3 storage (production only)
- `SMTP_ADDRESS`, `SMTP_USERNAME`, `SMTP_PASSWORD` - For email (MailerSend)

> [!IMPORTANT]
> After deploying, configure the Stripe webhook in your Stripe Dashboard:
> - URL: `https://your-app.onrender.com/webhooks`
> - Events to send: `checkout.session.completed`
> - Copy the webhook signing secret to `STRIPE_WEBHOOK_KEY`

### Docker Deployment

A multi-stage `Dockerfile` is included for production deployment:

```bash
# Build the image
docker build -f Dockerfile -t e-commerce-rails7 .

# Run the container
docker run -p 3000:3000 \
  -e DATABASE_URL=your_db_url \
  -e RAILS_MASTER_KEY=your_key \
  e-commerce-rails7
```

**Docker Features:**
- Multi-stage build (minimal final image)
- Non-root user execution
- Secret key not required at build time
- VIPS for image processing

---

## Configuration

### Credentials Management

This project uses **Rails encrypted credentials** (not `.env` files) for secrets:

```bash
# Edit credentials (opens in VS Code)
EDITOR="code --wait" rails credentials:edit
```

**Required credentials structure:**
```yaml
stripe:
  secret_key: sk_...
  webhook_key: whsec_...
aws:
  access_key_id: AKIA...
  secret_access_key: ...
```

**Fallback:** If credentials aren't set, the app falls back to ENV vars (`STRIPE_SECRET_KEY`, etc.)

### Database Configuration

**Development:**
- Host: `postgres` (Docker service name)
- Database: `e_commerce_rails7_development`
- User: `postgres`
- Password: `postgres`

**Production:**
- Uses `DATABASE_URL` environment variable

### Active Storage Configuration

**Development:** Local disk (`storage/`)
**Production:** AWS S3
- Bucket: `e-commerce-rails7-aws-s3-bucket`
- Region: `eu-central-1`

**Image Variants:**
- `:thumb` - 50x50px
- `:medium` - 250x250px

---

## Project Structure

```
app/
├── assets/
│   ├── builds/           # esbuild + Tailwind output
│   ├── images/           # Static images
│   └── stylesheets/      # Tailwind directives
├── controllers/
│   ├── admin/            # Admin CRUD controllers (6 files)
│   ├── quantities/       # Material calculator controllers (3 files)
│   └── ...               # Public controllers
├── javascript/
│   ├── controllers/      # Stimulus controllers (TypeScript, 6 files)
│   └── application.ts    # Entry point
├── models/               # 8 ActiveRecord models
└── views/
    ├── admin/            # Admin interface (30 views)
    ├── quantities/       # Calculator interfaces (3 views)
    └── ...               # Public views, layouts

config/                   # Rails configuration
db/
├── migrate/              # 17 database migrations
└── schema.rb             # Current database schema

test/                     # Minitest tests (24 files)
.devcontainer/            # Docker dev environment config
documentation/            # Project documentation
.results/                 # Generated analysis files
```

---

## Architecture

### Architectural Philosophy

This application follows a **deliberately simple architecture** prioritizing Rails conventions over abstraction:

- **Fat Controllers** - Business logic lives in controllers
- **Anemic Models** - Models define associations only, no business logic
- **No Service Objects** - Straightforward controller-based logic
- **No Concerns** - Empty directory, patterns kept inline
- **Type Safety** - TypeScript with strict mode for frontend

### Key Patterns

**E-Commerce Flow:**
```
Browse Products → Add to Cart (localStorage) → Checkout (Stripe)
→ Payment → Webhook → Create Order → Send Email
```

**Stock Management:**
- Validated at checkout creation
- Decremented in webhook after successful payment
- Supports product-level and variant-level stock

**Pricing:**
- Stored in pence (integer)
- Dual model: single price OR variant pricing by size
- Price captured at purchase time in `OrderProduct`

**Admin Authentication:**
- Devise for admin users only
- No public user accounts
- Guest checkout for all customers

---

## Documentation

### Comprehensive Guides

- **[Copilot Instructions](.github/copilot-instructions-bitovi.md)** - Complete codebase guide for AI agents
- **[Original README](README-orig.md)** - Original project documentation
- **[Database Schema](documentation/schema-diagram.md)** - ER diagram with relationships

### Analysis Files (.results/)

Generated comprehensive analysis documentation:
- **[Tech Stack](.results/techstack.md)** - Technology inventory and domain analysis
- **[File Categories](.results/file-categories.md)** - 225 files organized into 20 categories
- **[Architectural Domains](.results/architectural-domains.md)** - Layer diagrams and patterns
- **[E-Commerce Domain](.results/domain-ecommerce.md)** - Guest checkout, pricing, Stripe integration
- **[Calculators Domain](.results/domain-calculators.md)** - Material calculation formulas and business rules

### Domain Knowledge

**Composite Materials:**
- Fiberglass mats come in standard 0.95m roll width
- Industry-standard resin-to-glass ratio: 1.6:1
- Typical wastage allowance: 15%
- Material weights: 300g-900g per m² depending on type

**UK E-Commerce:**
- VAT: 20% (inclusive pricing)
- Shipping: GB (Great Britain) only
- Currency: GBP (stored as pence in database)
- Timezone: Europe/London

---

## Material Calculator Examples

### Area Calculator

**Input:**
- Area: 10 m²
- Layers: 2
- Material: 450g Chop Strand Mat
- Catalyst: 1%

**Output:**
```
Mat Required: 21.05m (with wastage)
Mat Weight: 10.35kg (with wastage)
Resin: 36.8L (with wastage)
Catalyst: 368ml
Total Weight: 47.518kg
```

### Calculation Formulas

```ruby
# Linear meters of mat
mat_length = (area × layers) / 0.95
mat_with_wastage = mat_length × 1.15

# Mat weight in kg
mat_weight = (area × layers) × (material_g_per_m² / 1000)
mat_weight_with_wastage = mat_weight × 1.15

# Resin in litres
resin = (area × layers) × 1.6
resin_with_wastage = resin × 1.15

# Catalyst in ml
catalyst = ((resin_with_wastage / 10) × catalyst_percentage) × 100

# Total weight
total = mat_weight_with_wastage + resin_with_wastage + (catalyst / 1000)
```

---

## Common Gotchas

1. **Price Storage** - Always in pence (multiply by 100 before saving)
2. **Currency** - GBP only, ensure Stripe dashboard matches
3. **Stock Timing** - Decremented in webhook, not at checkout (race condition possible)
4. **Timezone** - London (not UTC)
5. **Credentials** - Use `rails credentials:edit` not `.env` in development
6. **TypeScript Build** - Run `yarn build` before deploying
7. **Cart State** - Stored in localStorage only, cleared on success
8. **Admin Model** - Class name conflicts with `Admin::` namespace in tests
9. **Letter Opener** - Currently mounted in production (TODO: restrict to dev/test)
10. **Image Processing** - Requires VIPS to be installed

---

## API Integrations

### Stripe Integration

**Checkout Flow:**
1. `POST /checkout` - Create Stripe session with cart items
2. Redirect to Stripe Checkout
3. Customer completes payment
4. Stripe sends webhook to `/webhooks`
5. Create order, decrement stock, send email

**Webhook Events:**
- `checkout.session.completed` - Creates Order and OrderProducts

**Important Settings:**
- Currency: GBP
- Payment mode (not subscription)
- Shipping: 3 options (Collection free, 3-5 days £25, Overnight £50)
- Metadata: product_id, size, product_stock_id, product_price

### AWS S3 Integration

**Production Image Storage:**
- Bucket: `e-commerce-rails7-aws-s3-bucket`
- Region: `eu-central-1`
- Files: Product images, category images
- Variants: Automatically generated (thumb, medium)

---

## Troubleshooting

### Common Issues

**PostgreSQL Connection Failed:**
```bash
# Check if PostgreSQL is running (Docker)
docker ps | grep postgres

# Restart devcontainer
# F1 → "Dev Containers: Rebuild Container"
```

**TypeScript Compilation Errors:**
```bash
# Clear build cache
rm -rf app/assets/builds/*
yarn build
```

**Test Failures:**
```bash
# Ensure test database is setup
RAILS_ENV=test bin/rails db:migrate

# Run specific test
bin/rails test test/controllers/products_controller_test.rb
```

**Stripe Webhook Not Working:**
- Check webhook URL in Stripe Dashboard
- Verify `STRIPE_WEBHOOK_KEY` matches Stripe signing secret
- Check ngrok is running (local development)
- Review webhook logs in Stripe Dashboard

**Image Upload Failed:**
```bash
# Ensure VIPS is installed
# macOS:
brew install vips

# Debian/Ubuntu (devcontainer):
apt-get install libvips
```

---

## Contributing

Contributions are welcome! This is an open-source educational project demonstrating Rails 7 + TypeScript + Stripe integration.

**Development Process:**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes (follow existing patterns)
4. Run tests (`bin/rails test`)
5. Run RuboCop (`rubocop -a`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

**Code Style:**
- Follow Rails conventions
- Use RuboCop for Ruby style
- Use TypeScript strict mode for frontend
- Write tests for new features
- Update documentation as needed

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Rails Team** - For the amazing web framework
- **Hotwire Team** - For Turbo and Stimulus
- **Stripe** - For reliable payment processing
- **Tailwind CSS** - For utility-first styling
- **TypeScript Team** - For type safety in JavaScript

---

## Support

For questions or issues:
- **Issues**: [GitHub Issues](https://github.com/AnthonyWrather/e-commerce-rails7/issues)
- **Discussions**: [GitHub Discussions](https://github.com/AnthonyWrather/e-commerce-rails7/discussions)

---

**Built with ❤️ for the composite materials industry**

