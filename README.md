# Composite Materials E-Commerce Platform

[![Rails](https://img.shields.io/badge/Rails-7.1.2-red?style=flat-square&logo=rubyonrails)](https://rubyonrails.org)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.2-red?style=flat-square&logo=ruby)](https://www.ruby-lang.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3.3-blue?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-blue?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

A specialized B2B/B2C e-commerce platform for selling composite materials (fiberglass, resins, tools) with integrated **material quantity calculators** for precise project estimation. Built with Rails 7, TypeScript, and Stripe payments.

## What This Project Does

This platform serves the composite materials industry with a unique combination of e-commerce functionality and engineering calculation tools. Unlike typical online stores, it includes specialized calculators that help customers determine exact material quantities needed for their fiberglass and composite projects.

**Core Capabilities:**

- **Product Sales**: Full e-commerce with product catalog, shopping cart, and Stripe checkout
- **Material Calculators**: Three specialized calculators (Area, Dimensions, Mould Rectangle) for composite material estimation
- **Variant Pricing**: Products can have single pricing or variant pricing by size (e.g., Small £10, Large £15)
- **Guest Checkout**: No customer accounts required; orders tracked via email
- **Admin Dashboard**: CRUD operations, revenue charts, order management, and stock control

**Technology Highlights:**

- Ruby 3.2.2 + Rails 7.1.2 with PostgreSQL database
- TypeScript 5.3.3 (strict mode) with Stimulus controllers
- Tailwind CSS for responsive UI
- Stripe for secure payment processing (GBP currency)
- Docker devcontainer for consistent development environment
- AWS S3 for production image storage

## Why It's Useful

### For Composite Materials Businesses

- **Industry-Specific Tools**: Built-in calculators understand composite materials terminology and formulas
- **Dual Pricing Model**: Supports both single pricing and size-variant pricing for products
- **UK-Focused**: GBP currency, 20% VAT, designed for Great Britain market
- **Low Overhead**: Guest checkout eliminates user account management complexity

### For Developers

- **Modern Rails Architecture**: Rails 7 with Hotwire (Turbo + Stimulus) for SPA-like experience
- **TypeScript Integration**: Full TypeScript support with strict mode for type-safe frontend
- **DevContainer Ready**: Fully configured Docker development environment with PostgreSQL and pgAdmin
- **Production Deployment**: Ready for Render.com deployment with multi-stage Docker builds

### Key Features

#### Material Calculators

Calculate exact quantities for composite material projects:

1. **Area Calculator** - For projects with known area (m²)
2. **Dimensions Calculator** - For projects with length, width, depth
3. **Mould Rectangle Calculator** - For rectangular mould projects

**Calculation Features:**

- 14 material types (Chop Strand Mat, Woven Roving, Biaxial, etc.)
- Industry-standard constants (0.95m roll width, 1.6:1 resin ratio)
- Automatic 15% wastage calculation
- Outputs: mat length/weight, resin volume, catalyst volume, total weight

#### E-Commerce Features

- Guest checkout with localStorage-based shopping cart
- Multi-image product galleries with Active Storage
- Category-based product organization
- Stock management at product and variant levels
- Stripe payment integration with webhook-driven order creation
- Email order confirmations with full invoice details
- Admin dashboard with revenue charts (Chart.js)

## Getting Started

### Prerequisites

**Option 1: Using Dev Container (Recommended)**

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [VS Code](https://code.visualstudio.com) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Git](https://git-scm.com/downloads)

**Option 2: Local Development**

- [Ruby 3.2.2](https://www.ruby-lang.org/en/downloads/)
- [Node.js 20.x](https://nodejs.org/download/) with Yarn
- [PostgreSQL 14+](https://www.postgresql.org/download/)
- [VIPS](https://www.libvips.org/install.html) - For image processing

### Quick Start with Dev Container

The easiest way to get started is using the included devcontainer, which provides a fully configured development environment with PostgreSQL, pgAdmin, and all required tools.

1. **Clone the repository**

   ```bash
   git clone https://github.com/AnthonyWrather/e-commerce-rails7.git
   cd e-commerce-rails7
   ```

2. **Open in VS Code and reopen in container**

   ```bash
   code .
   # Press F1 → "Dev Containers: Reopen in Container"
   # Wait for container to build (first time: ~5 minutes)
   ```

3. **Setup the database**

   ```bash
   bin/rails db:migrate
   ```

4. **Create an admin user**

   ```bash
   bin/rails c
   # In Rails console:
   AdminUser.create(email: "admin@example.com", password: "12345678")
   exit
   ```

5. **Start the development server**

   ```bash
   bin/dev
   ```

6. **Visit the application**

   - Shop: http://localhost:3000
   - Admin: http://localhost:3000/admin_users/sign_in
   - Email previews: http://localhost:3000/letter_opener
   - pgAdmin: http://localhost:15432 (admin@pgadmin.com / password)

### Local Development (Without Docker)

If you prefer not to use Docker:

1. **Install dependencies**

   ```bash
   bundle install
   yarn install
   ```

2. **Setup PostgreSQL**

   Ensure PostgreSQL is running and update `config/database.yml` with your credentials.

3. **Setup database and build assets**

   ```bash
   bin/rails db:create db:migrate
   yarn build
   ```

4. **Create admin user** (see step 4 above)

5. **Start the development server**

   ```bash
   bin/dev
   ```

### Example Usage

Once the application is running:

1. **Browse Products**: Visit http://localhost:3000 to see the product catalog
2. **Try a Calculator**: Navigate to "Quantity Calculator" → "Area Calculator"
   - Enter: Area: 10 m², Layers: 2, Material: 450g Chop Strand Mat
   - See calculated material quantities with wastage
3. **Add to Cart**: Select a product, choose a size (if applicable), add to cart
4. **Admin Access**: Login at `/admin_users/sign_in` to manage products and view orders

## Development Guide

### Development Workflow

The project uses **Foreman** via `bin/dev` to run multiple processes simultaneously:

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

All Stimulus controllers are written in TypeScript with strict mode enabled:

```bash
yarn build                 # One-time build
yarn build --watch         # Watch mode (included in bin/dev)
tsc --noEmit              # Type-check only
```

Build output: `app/assets/builds/application.js`

**Key TypeScript Files:**

- `app/javascript/controllers/cart_controller.ts` - Shopping cart management
- `app/javascript/controllers/products_controller.ts` - Product interactions
- `app/javascript/controllers/dashboard_controller.ts` - Admin revenue charts
- `app/javascript/controllers/quantities_controller.ts` - Calculator UI

### Testing

The project uses **Minitest** with Capybara for system tests:

```bash
bin/rails test             # Run all unit/integration tests
bin/rails test:system      # Run Capybara browser tests
bin/rails test:all         # Run everything
```

**Current Test Status:** 36 test runs, 55 assertions, 0 failures

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

### Configuration & Secrets

This project uses **Rails encrypted credentials** (not `.env` files):

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

### Database Management

The devcontainer includes **pgAdmin** for database administration:

- Access: http://localhost:15432
- Login: admin@pgadmin.com / password
- Direct PostgreSQL: localhost:5432 (postgres/postgres)

### Email Testing

Development uses **Letter Opener Web** to preview emails in the browser:

```bash
# Access email previews at:
http://localhost:3000/letter_opener

# Trigger test email by completing a checkout
```

### Project Structure

```text
app/
├── controllers/
│   ├── admin/              # Admin CRUD controllers
│   ├── quantities/         # Material calculator controllers
│   └── ...                 # Public controllers
├── javascript/
│   ├── controllers/        # Stimulus controllers (TypeScript)
│   └── application.ts      # Entry point
├── models/                 # ActiveRecord models (8 total)
└── views/
    ├── admin/              # Admin interface
    ├── quantities/         # Calculator interfaces
    └── ...                 # Public views

config/                     # Rails configuration
db/
├── migrate/                # Database migrations
└── schema.rb               # Current database schema

test/                       # Minitest tests
.devcontainer/              # Docker dev environment config
```

### Deployment

The application is configured for deployment on **Render.com**:

**Build Command:** `./bin/render-build.sh`

**Required Environment Variables:**

- `RAILS_MASTER_KEY` - Copy from `config/master.key`
- `STRIPE_SECRET_KEY` - Stripe API secret key
- `STRIPE_WEBHOOK_KEY` - Stripe webhook signing secret
- `WEB_CONCURRENCY` - Set to `2` for production

**After deploying:**

Configure the Stripe webhook in your Stripe Dashboard:

- URL: `https://your-app.onrender.com/webhooks`
- Events: `checkout.session.completed`

See [render.yaml](render.yaml) for full deployment configuration.

## Where to Get Help

### Documentation

- **[Copilot Instructions](.github/copilot-instructions.md)** - Comprehensive codebase guide for AI-assisted development
- **[Database Schema](documentation/schema-diagram.md)** - Entity-relationship diagram
- **[GitHub Copilot Collections](.github/AWESOME-COPILOT-README.md)** - 37 curated prompts, instructions, and chat modes

### Support Resources

- **Issues**: [GitHub Issues](https://github.com/AnthonyWrather/e-commerce-rails7/issues) - Report bugs or request features
- **Discussions**: [GitHub Discussions](https://github.com/AnthonyWrather/e-commerce-rails7/discussions) - Ask questions and share ideas
- **Rails Guides**: [Rails 7.1 Documentation](https://guides.rubyonrails.org/v7.1/)
- **Stripe Integration**: [Stripe API Docs](https://stripe.com/docs/api)

### Common Issues

**PostgreSQL Connection Failed:**

```bash
# Check if PostgreSQL is running (Docker)
docker ps | grep postgres
# Restart devcontainer: F1 → "Dev Containers: Rebuild Container"
```

**TypeScript Compilation Errors:**

```bash
rm -rf app/assets/builds/*
yarn build
```

**Stripe Webhook Not Working:**

- Verify `STRIPE_WEBHOOK_KEY` matches Stripe signing secret
- Check ngrok is running (local development)
- Review webhook logs in Stripe Dashboard

## Maintainers & Contributors

**Maintainer:** [Anthony Wrather](https://github.com/AnthonyWrather)

### Contributing

Contributions are welcome! This is an open-source educational project demonstrating Rails 7 + TypeScript + Stripe integration.

**Development Process:**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following existing patterns
4. Run tests (`bin/rails test`) and RuboCop (`rubocop -a`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

**Code Style:**

- Follow Rails conventions and use RuboCop for Ruby style
- Use TypeScript strict mode for frontend code
- Write tests for new features
- Update documentation as needed

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Acknowledgments

- **Rails Team** - For the amazing web framework
- **Hotwire Team** - For Turbo and Stimulus
- **Stripe** - For reliable payment processing
- **Tailwind CSS** - For utility-first styling
- **TypeScript Team** - For type safety in JavaScript

---

**Built with ❤️ for the composite materials industry**
