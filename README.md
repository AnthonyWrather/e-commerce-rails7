# Composite Materials E-Commerce Platform

[![Rails](https://img.shields.io/badge/Rails-7.1.2-red?style=flat-square&logo=rubyonrails)](https://rubyonrails.org)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.3-red?style=flat-square&logo=ruby)](https://www.ruby-lang.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3.3-blue?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

A specialized B2B/B2C e-commerce platform for selling composite materials (fiberglass, resins, tools) with integrated **material quantity calculators** for precise project estimation. Built with Rails 7, TypeScript, and Stripe payments.

## Table of Contents

- [What This Project Does](#what-this-project-does)
- [Why It's Useful](#why-its-useful)
- [Architecture & Design](#architecture--design)
  - [System Architecture](#system-architecture)
  - [Data Flow Patterns](#data-flow-patterns)
  - [Database Schema Overview](#database-schema-overview)
  - [Frontend Architecture](#frontend-architecture)
  - [Security Architecture](#security-architecture)
  - [Performance Considerations](#performance-considerations)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Quick Start with Dev Container](#quick-start-with-dev-container)
  - [Local Development](#local-development-without-docker)
  - [Example Usage](#example-usage)
- [Calculator API Reference](#calculator-api-reference)
  - [Common Constants](#common-constants)
  - [Material Types](#material-types-14-options)
  - [Calculation Formulas](#calculation-formulas)
  - [Area Calculator](#1-area-calculator)
  - [Dimensions Calculator](#2-dimensions-calculator)
  - [Mould Rectangle Calculator](#3-mould-rectangle-calculator)
- [Development Guide](#development-guide)
  - [Development Workflow](#development-workflow)
  - [TypeScript Development](#typescript-development)
  - [Testing](#testing)
  - [Configuration & Secrets](#configuration--secrets)
  - [Database Management](#database-management)
  - [Email Testing](#email-testing)
  - [Project Structure](#project-structure)
- [Deployment](#deployment)
  - [Render.com Setup](#rendercom-setup)
  - [Environment Variables](#environment-variables)
  - [Multi-Environment Strategy](#multi-environment-strategy)
  - [Post-Deployment Configuration](#post-deployment-configuration)
  - [Monitoring & Maintenance](#monitoring--maintenance)
- [Where to Get Help](#where-to-get-help)
- [Maintainers & Contributors](#maintainers--contributors)
- [License](#license)

## What This Project Does

This platform serves the composite materials industry with a unique combination of e-commerce functionality and engineering calculation tools. Unlike typical online stores, it includes specialized calculators that help customers determine exact material quantities needed for their fiberglass and composite projects.

**Core Capabilities:**

- **Product Sales**: Full e-commerce with product catalog, shopping cart, and Stripe checkout
- **Material Calculators**: Three specialized calculators (Area, Dimensions, Mould Rectangle) for composite material estimation
- **Variant Pricing**: Products can have single pricing or variant pricing by size (e.g., Small £10, Large £15)
- **Guest Checkout**: No customer accounts required; orders tracked via email
- **Admin Dashboard**: CRUD operations, revenue charts, order management, and stock control

**Technology Highlights:**

- Ruby 3.2.3 + Rails 7.1.2 with PostgreSQL 17 database
- TypeScript 5.3.3 (strict mode) with Stimulus controllers
- Tailwind CSS for responsive UI
- Stripe for secure payment processing (GBP currency)
- Docker devcontainer for consistent development environment
- AWS S3 for production image storage
- Rack 3.2.4 with Rack::Attack rate limiting
- Capybara 3.40.0 for system testing

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

## Architecture & Design

### System Architecture

This application follows a **Rails MVC architecture** with modern JavaScript enhancements and a PostgreSQL database backend.

```text
┌─────────────────────────────────────────────────────────────────┐
│                         Browser (Client)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │ Public Shop  │  │ Admin Panel  │  │ Calculator Tools   │   │
│  │ (Guest)      │  │ (Devise Auth)│  │ (Turbo Frames)     │   │
│  └──────────────┘  └──────────────┘  └────────────────────┘   │
│         │                  │                     │              │
│    localStorage       Stimulus Controllers (TypeScript)         │
│    (Cart State)       ↓        ↓        ↓                       │
└─────────────────────────────────────────────────────────────────┘
                               ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                      Rails 7 Application                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Controllers Layer                      │  │
│  │  • Public: Home, Categories, Products, Carts, Checkouts  │  │
│  │  • Admin: Products, Categories, Orders, Stocks, Reports  │  │
│  │  • Quantities: Area, Dimensions, Mould Rectangle         │  │
│  │  • Webhooks: Stripe webhook handler                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                               ↓                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                      Models Layer                         │  │
│  │  • Product (has_many :stocks, :images)                   │  │
│  │  • Category (has_many :products)                         │  │
│  │  • Stock (belongs_to :product) - Variant pricing         │  │
│  │  • Order (has_many :order_products)                      │  │
│  │  • OrderProduct (join table with price snapshot)         │  │
│  │  • AdminUser (Devise authentication)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                               ↓                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Views Layer (ERB)                      │  │
│  │  • Tailwind CSS for styling                              │  │
│  │  • Turbo Frames for calculator tools                     │  │
│  │  • Stimulus for interactivity                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                   External Services                             │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────────────┐ │
│  │ PostgreSQL  │  │   Stripe    │  │  AWS S3 (Production)   │ │
│  │  Database   │  │  Payments   │  │  Image Storage         │ │
│  └─────────────┘  └─────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow Patterns

#### 1. **Shopping Cart Flow** (Client-Side State)

```text
User browses → Selects product/size → Click "Add to Cart"
                                            ↓
                        Stimulus ProductsController (TypeScript)
                                            ↓
                        Store in localStorage as JSON array:
                        [{id, name, price, size, quantity}, ...]
                                            ↓
User navigates → Cart page loads → Stimulus CartController reads localStorage
                                            ↓
                        Renders cart table with VAT calculations
                                            ↓
User clicks Checkout → POST /checkout → CheckoutsController
                                            ↓
                        Creates Stripe session with metadata
                                            ↓
                        Redirects to Stripe Checkout
```

#### 2. **Order Creation Flow** (Webhook-Driven)

```text
Stripe Checkout completed → Stripe sends webhook → /webhooks endpoint
                                                            ↓
                                    WebhooksController#stripe verifies signature
                                                            ↓
                        Extracts session data (email, line_items, metadata)
                                                            ↓
                        Creates Order record with customer info
                                                            ↓
                        Creates OrderProduct records (captures price at purchase)
                                                            ↓
                        Decrements stock (Product.amount or Stock.amount)
                                                            ↓
                        Sends OrderMailer.new_order_email with invoice
                                                            ↓
                        Returns 200 OK to Stripe
```

**Key Design Decision:** Orders are created exclusively via webhooks, not during checkout, ensuring payment confirmation before inventory changes.

#### 3. **Material Calculator Flow** (Turbo Frame Pattern)

```text
User visits /quantities → Selects calculator type (Area/Dimensions/Mould)
                                            ↓
                        Navigates to /quantities/area (for example)
                                            ↓
                        Form inside Turbo Frame (GET request)
                                            ↓
User fills form (area, layers, material) → Submits
                                            ↓
                        GET /quantities/area with params
                                            ↓
                        Quantities::AreaController#index calculates:
                        • Material length/weight with 15% wastage
                        • Resin volume (1.6:1 ratio)
                        • Catalyst volume (based on percentage)
                        • Total project weight
                                            ↓
                        Renders results in same Turbo Frame (no page reload)
```

**Design Note:** Calculations are stateless and performed entirely in the controller (no model layer), using industry constants defined in the controller.

### Database Schema Overview

**Core Entities:**

```text
categories ──┐
             │
             ├─< products >─┬─< stocks (variant pricing)
             │              ├─< order_products
             │              └─< images (Active Storage)
             │
orders ──────┴─< order_products

admin_users (Devise authentication)
```

**Key Relationships:**

- **Product → Category**: Many-to-one (products categorized)
- **Product → Stocks**: One-to-many (size variants with individual pricing)
- **Product → Images**: One-to-many (Active Storage attachments)
- **Product → OrderProducts**: One-to-many (purchase history)
- **Order → OrderProducts**: One-to-many (line items)
- **OrderProduct**: Captures `price` at time of purchase (not calculated)

**Pricing Models:**

1. **Single Price**: Product has `price` and `stock_level` directly
2. **Variant Price**: Product has multiple Stocks, each with `price`, `size`, and `amount`

The checkout flow determines which pricing model to use (lines 13-23 in `CheckoutsController#create`).

### Frontend Architecture

**Technology Stack:**

- **Hotwire Turbo**: SPA-like navigation without full page reloads
- **Stimulus (TypeScript)**: Lightweight JavaScript framework for sprinkles of interactivity
- **Tailwind CSS**: Utility-first styling
- **esbuild**: Fast JavaScript/TypeScript bundler

**Stimulus Controllers (TypeScript):**

| Controller | Purpose | Key Features |
|------------|---------|--------------|
| `cart_controller.ts` | Shopping cart management | localStorage, VAT calculations, checkout flow |
| `products_controller.ts` | Product interactions | Size selection, dynamic pricing, add to cart |
| `dashboard_controller.ts` | Admin analytics | Chart.js integration, revenue visualization |
| `quantities_controller.ts` | Calculator UI | Form interactions (currently stub) |

**State Management:**

- **Client State**: Shopping cart stored in `localStorage` (no server session)
- **Server State**: Orders, products, stock levels in PostgreSQL
- **No Global State**: Each Stimulus controller manages its own scope

**TypeScript Type Safety:**

All controllers use strict mode with proper interfaces:

```typescript
interface CartItem {
  id: number;
  name: string;
  price: number;      // in pence
  size: string;
  quantity: number;
}
```

### Security Architecture

**Authentication:**

- **Admin Panel**: Devise-based authentication (AdminUser model)
- **Public Shop**: No authentication required (guest checkout)

**Rate Limiting:**

- **Implementation**: Rack::Attack middleware for protection against brute force and DDoS attacks
- **Global Limit**: 300 requests per 5 minutes per IP (excludes asset requests)
- **Admin Login**: 5 attempts per 20 seconds per IP and email (prevents credential stuffing)
- **Checkout**: 10 attempts per minute per IP (prevents checkout abuse)
- **Contact Form**: 5 submissions per minute per IP (prevents spam)
- **Throttled Response**: HTTP 429 "Too Many Requests" status with plain text message
- **Configuration**: `config/initializers/rack_attack.rb`

**Payment Security:**

- **Stripe Integration**: PCI-compliant payment processing
- **Webhook Verification**: Cryptographic signature validation
- **No Card Storage**: All payment data handled by Stripe

**Secret Management:**

- **Development**: Rails encrypted credentials (`config/credentials.yml.enc`)
- **Production**: Environment variables with fallback to credentials
- **API Keys**: Never committed to repository

**CSRF Protection:**

- Rails automatic CSRF protection enabled
- Stimulus controllers fetch CSRF token: `document.querySelector("[name='csrf-token']").content`

### Performance Considerations

**Current Optimizations:**

- **Active Storage Variants**: Pre-processed image sizes (thumb: 50x50, medium: 250x250)
- **Pagination**: Pagy gem for admin tables
- **Asset Pipeline**: esbuild for fast JavaScript builds
- **Production**: Multi-stage Docker builds, Puma web server

**Known N+1 Opportunities:**

- `CategoriesController#show`: Products with images (add `with_attached_images`)
- `AdminController#index`: Orders with order_products (add `includes(:order_products)`)

**Caching Strategy:**

- **Current**: No caching implemented
- **Opportunity**: Fragment caching for product cards, category lists

See [documentation/schema-diagram.md](documentation/schema-diagram.md) for detailed entity-relationship diagram.

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

## Calculator API Reference

The Material Quantity Calculators are accessible via GET requests and return HTML pages with calculated results. All calculators share common formulas and constants.

### Common Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `material_width` | 0.95 m | Standard roll width for composite materials |
| `ratio` | 1.6:1 | Resin-to-glass fiber weight ratio |
| `wastage` | 15% | Industry-standard wastage factor (multiplier: 1.15) |

### Material Types (14 Options)

Composite materials are categorized by weight per square meter (g/m²):

**Chop Strand Mat:**
- `300` - 300g/m²
- `450` - 450g/m²
- `600` - 600g/m²

**Plain Weave:**
- `285` - 285g/m²
- `400` - 400g/m²

**Woven Roving:**
- `450` - 450g/m²
- `600` - 600g/m²
- `800` - 800g/m²
- `900` - 900g/m²

**Combination Mat:**
- `450` - 450g/m²
- `600` - 600g/m²
- `900` - 900g/m²

**Biaxial:**
- `400` - 400g/m²
- `800` - 800g/m²

**Other:**
- `Gel Coat`

### Calculation Formulas

All calculators use the following formulas:

```ruby
# Material calculations
material_length = (area × layers) / material_width
material_length_with_wastage = material_length × 1.15

material_weight_kg = (area × layers) × (material_g_per_m² / 1000)
material_weight_with_wastage = material_weight_kg × 1.15

# Resin calculations
resin_litres = (area × layers) × 1.6
resin_with_wastage = resin_litres × 1.15

# Catalyst calculations
catalyst_ml = ((resin_with_wastage / 10) × catalyst_percentage) × 100

# Total weight
total_weight = material_weight_with_wastage + resin_with_wastage + (catalyst_ml / 1000)
```

### 1. Area Calculator

Calculate material quantities for a project with known surface area.

**Endpoint:** `GET /quantities/area`

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `area` | Float | No | 1.0 | Surface area in square meters (m²) |
| `layers` | Integer | No | 0 | Number of material layers to apply |
| `material` | String | No | "" | Material type (g/m² value or "Gel Coat") |
| `catalyst` | Integer | No | 1 | Catalyst percentage (1-3%) |

**Example Request:**

```
GET /quantities/area?area=10&layers=2&material=450&catalyst=2
```

**Returns:**

| Output | Description |
|--------|-------------|
| `@area` | Input area (m²) |
| `@layers` | Number of layers |
| `@mat` | Linear meters of material needed |
| `@mat_total` | Linear meters with 15% wastage |
| `@mat_kg` | Material weight in kg |
| `@mat_total_kg` | Material weight with wastage |
| `@resin` | Resin volume in litres |
| `@resin_total` | Resin with wastage |
| `@catalyst_ml` | Catalyst volume in millilitres |
| `@total_weight` | Total project weight in kg |

**Example Calculation:**

```
Input:
  Area: 10 m²
  Layers: 2
  Material: 450g Chop Strand Mat
  Catalyst: 2%

Output:
  Material: 21.05 linear meters (with wastage)
  Material Weight: 10.35 kg (with wastage)
  Resin: 36.80 litres (with wastage)
  Catalyst: 736.00 ml
  Total Weight: 47.89 kg
```

### 2. Dimensions Calculator

Calculate material quantities based on length and width (depth is currently set to 0).

**Endpoint:** `GET /quantities/dimensions`

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `length` | Float | No | 1.0 | Length in meters |
| `width` | Float | No | 1.0 | Width in meters |
| `layers` | Integer | No | 0 | Number of material layers |
| `material` | String | No | "" | Material type (g/m² value) |
| `catalyst` | Integer | No | 1 | Catalyst percentage (1-3%) |

**Area Calculation:**

```ruby
area = (length × width) + (2 × (length × depth)) + (2 × (width × depth))
# Note: depth is currently hardcoded to 0, so effectively: area = length × width
```

**Example Request:**

```
GET /quantities/dimensions?length=5&width=2&layers=3&material=600&catalyst=2
```

**Returns:** Same output structure as Area Calculator

### 3. Mould Rectangle Calculator

Calculate material quantities for a rectangular mould including depth (all 6 faces).

**Endpoint:** `GET /quantities/mould_rectangle`

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `length` | Float | No | 1.0 | Length in meters |
| `width` | Float | No | 1.0 | Width in meters |
| `depth` | Float | No | 1.0 | Depth in meters |
| `layers` | Integer | No | 0 | Number of material layers |
| `material` | String | No | "" | Material type (g/m² value) |
| `catalyst` | Integer | No | 1 | Catalyst percentage (1-3%) |

**Area Calculation:**

```ruby
area = (length × width) + (2 × (length × depth)) + (2 × (width × depth))
```

This calculates the total surface area of a rectangular mould:
- Base: `length × width`
- Two long sides: `2 × (length × depth)`
- Two short sides: `2 × (width × depth)`

**Example Request:**

```
GET /quantities/mould_rectangle?length=2&width=1.5&depth=0.5&material=450&catalyst=2&layers=2
```

**Example Calculation:**

```
Input:
  Length: 2.0 m
  Width: 1.5 m
  Depth: 0.5 m
  Layers: 2
  Material: 450g Chop Strand Mat
  Catalyst: 2%

Calculated Area: 6.5 m²
  (base: 3.0 + long sides: 2.0 + short sides: 1.5)

Output:
  Material: 15.79 linear meters (with wastage)
  Material Weight: 6.73 kg (with wastage)
  Resin: 23.92 litres (with wastage)
  Catalyst: 478.40 ml
  Total Weight: 31.13 kg
```

### Usage Notes

**Bookmarkable Results:**
All calculators use GET requests with query parameters, making results bookmarkable and shareable.

**Turbo Frame Integration:**
Results update within a Turbo Frame on the same page (no full page reload).

**No Persistence:**
Calculations are stateless - no data is stored in the database. Each request is independent.

**Browser Compatibility:**
Requires JavaScript enabled for optimal experience with Turbo Frames.

**Units:**
- Dimensions: meters (m)
- Area: square meters (m²)
- Weight: kilograms (kg) and grams (g)
- Volume: litres (L) and millilitres (mL)
- All outputs rounded to 2 decimal places

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

**Current Test Status:** All tests passing (507 runs, 1,151 assertions, 0 failures, 0 errors, 8 skips)
**Code Coverage:** 86.22% (513/595 lines)

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

## Deployment

The application is production-ready and optimized for deployment on **Render.com** with multi-stage Docker builds, PostgreSQL database, Redis for Action Cable, and AWS S3 for file storage.

### Render.com Setup

#### Infrastructure Components

The deployment uses the following services (configured in [render.yaml](render.yaml)):

**Production Environment:**
- **Web Service**: Rails application (Starter plan, Frankfurt region)
  - Domain: `shop.cariana.tech`
  - Docker-based deployment
  - Auto-deploy on commit to `main` branch
  - Health check: `/up` endpoint
  - Persistent disk: 1GB mounted at `/rails/storage`

- **PostgreSQL Database**: Basic 256MB plan, PostgreSQL 17
  - Database: `e_commerce_rails7_production`
  - Region: Frankfurt
  - User: `e_commerce_rails7`

- **Redis**: Free plan for Action Cable (WebSockets)
  - Max memory policy: `allkeys-lru`
  - Region: Frankfurt

**Test Environment:**
- **Web Service**: Rails application (Free plan)
  - Domain: `test.cariana.tech`
  - Shares same PostgreSQL and Redis instances
  - Uses separate database: `e_commerce_rails7_test`

#### Build Process

The application uses a **multi-stage Dockerfile** for optimized production builds:

```dockerfile
# Stage 1: Base - Set up Ruby environment
# Stage 2: Build - Install gems, precompile bootsnap, precompile assets
# Stage 3: Final - Minimal runtime image with only production dependencies
```

**Build Command:** `./bin/render-build.sh`

This script executes:
```bash
bundle install              # Install Ruby gems
bundle exec rails assets:precompile  # Compile CSS/JS assets
bundle exec rails assets:clean       # Remove old assets
bundle exec rails db:migrate         # Run database migrations
```

**Build Filters** (skip rebuilds for documentation changes):
- **Included paths**: `app/`, `config/`, `db/`, `lib/`, `Gemfile`, `Gemfile.lock`
- **Ignored paths**: `*.md`, `documentation/`, `.results/`

### Environment Variables

#### Required Secrets (Set Manually)

These must be configured in Render Dashboard for each environment:

| Variable | Description | How to Obtain |
|----------|-------------|---------------|
| `RAILS_MASTER_KEY` | Decrypts Rails credentials | Copy from `config/master.key` |
| `STRIPE_SECRET_KEY` | Stripe API secret | Stripe Dashboard → Developers → API Keys |
| `STRIPE_WEBHOOK_KEY` | Stripe webhook signing secret | Stripe Dashboard → Webhooks → Signing secret |
| `MAILERSEND_DOMAIN` | MailerSend SMTP domain | MailerSend Dashboard → Domains |
| `MAILERSEND_USERNAME` | MailerSend SMTP username | MailerSend Dashboard → SMTP |
| `MAILERSEND_PASSWORD` | MailerSend SMTP password | MailerSend Dashboard → SMTP |
| `AWS_ACCESS_KEY_ID` | AWS S3 access key | AWS IAM Console |
| `AWS_SECRET_ACCESS_KEY` | AWS S3 secret key | AWS IAM Console |

#### Auto-Configured Variables

These are automatically set by Render:

| Variable | Source | Value |
|----------|--------|-------|
| `DATABASE_URL` | PostgreSQL service | Connection string |
| `REDIS_URL` | Redis service | Connection string |

#### Application Configuration

**Production:**
```bash
RAILS_ENV=production
RAILS_LOG_LEVEL=info
RAILS_SERVE_STATIC_FILES=true
WEB_CONCURRENCY=2              # Puma worker processes
RAILS_MAX_THREADS=5            # Threads per worker
AWS_REGION=eu-central-1
AWS_BUCKET=e-commerce-rails7-aws-s3-bucket
```

**Test:**
```bash
RAILS_ENV=test
RAILS_LOG_LEVEL=debug
WEB_CONCURRENCY=1              # Fewer workers for free tier
```

### Multi-Environment Strategy

#### Database Separation

Both environments share the same PostgreSQL server but use **separate databases**:

- Production: `e_commerce_rails7_production`
- Test: `e_commerce_rails7_test`

This approach:
- ✅ Reduces costs (single database server)
- ✅ Isolates data completely
- ✅ Allows testing production-like scenarios

#### Redis Sharing

Both environments share the same Redis instance:
- Safe because Action Cable namespaces by `RAILS_ENV`
- Channel prefix: `ecomm_production` vs `ecomm_test`

#### Build Optimization

Build filters prevent unnecessary deployments:
- Documentation changes (`*.md`) don't trigger rebuilds
- Only application code changes trigger deployments
- Saves build minutes and deployment time

### Post-Deployment Configuration

#### 1. Configure Stripe Webhooks

**Production Webhook:**
```
URL: https://shop.cariana.tech/webhooks
Events: checkout.session.completed
API Version: Latest
```

**Test Webhook:**
```
URL: https://test.cariana.tech/webhooks
Events: checkout.session.completed
Use test mode endpoint
```

**Steps:**
1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. Enter the webhook URL
4. Select event: `checkout.session.completed`
5. Copy the **Signing secret** and set as `STRIPE_WEBHOOK_KEY`

#### 2. Configure Custom Domain (Production)

1. In Render Dashboard → Service Settings → Custom Domain
2. Add `shop.cariana.tech`
3. Configure DNS:
   ```
   Type: CNAME
   Name: shop
   Value: e-commerce-rails7-prod.onrender.com
   ```
4. Wait for SSL certificate provisioning (~15 minutes)

#### 3. Setup AWS S3 Bucket

**Create Bucket:**
```bash
Bucket name: e-commerce-rails7-aws-s3-bucket
Region: eu-central-1 (Frankfurt)
Public access: Blocked (use signed URLs)
```

**IAM Policy** (attach to user):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::e-commerce-rails7-aws-s3-bucket",
        "arn:aws:s3:::e-commerce-rails7-aws-s3-bucket/*"
      ]
    }
  ]
}
```

**CORS Configuration:**
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": ["https://shop.cariana.tech"],
    "ExposeHeaders": ["ETag"]
  }
]
```

#### 4. Create Admin User

Connect to production Rails console:
```bash
# Via Render Shell
Run: "bin/rails console"

# In console:
AdminUser.create!(
  email: "admin@example.com",
  password: "secure_password_here"
)
```

#### 5. Verify Health Checks

Check the health endpoint:
```bash
curl https://shop.cariana.tech/up
# Should return: 200 OK
```

### Monitoring & Maintenance

#### Application Monitoring

**Honeybadger Integration:**
The app includes Honeybadger for error tracking:
```yaml
# config/honeybadger.yml
api_key: <%= ENV['HONEYBADGER_API_KEY'] %>
```

Set `HONEYBADGER_API_KEY` in Render for error notifications.

#### Log Management

**View Logs:**
```bash
# In Render Dashboard
Service → Logs tab

# Filter by level:
RAILS_LOG_LEVEL=info    # Production (default)
RAILS_LOG_LEVEL=debug   # Test environment
```

**Key Log Patterns:**
- `Started POST "/checkout"` - Checkout initiated
- `Stripe webhook received` - Webhook processing
- `OrderMailer#new_order_email` - Email sent
- `[ActiveJob]` - Background job execution

#### Performance Monitoring

**Metrics to Monitor:**
- Response times (target: <500ms for pages, <100ms for API)
- Database query times (watch for slow queries)
- Memory usage (Starter plan: 512MB limit)
- Disk usage (1GB storage)

**Puma Configuration:**
```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
```

#### Database Maintenance

**Backup Strategy:**
Render automatically backs up PostgreSQL databases:
- Frequency: Daily
- Retention: 7 days (Basic plan)
- Manual backups available in dashboard

**Migration Workflow:**
```bash
# Automatic on deploy via render-build.sh
bundle exec rails db:migrate

# Manual rollback if needed:
bin/rails db:rollback STEP=1
```

#### Scaling Considerations

**Horizontal Scaling:**
- Upgrade Render plan for more workers
- Current: 2 workers × 5 threads = 10 concurrent requests
- Recommended for >1000 daily visitors: Standard plan (4 workers)

**Database Scaling:**
- Current: Basic 256MB (up to 1GB data)
- Upgrade path: Standard 1GB → Pro 4GB
- Monitor connections (max 25 on Basic plan)

**Asset Storage:**
- S3 scales automatically
- Monitor bucket size and costs
- Consider CloudFront CDN for static assets

#### Troubleshooting

**Common Issues:**

| Issue | Solution |
|-------|----------|
| 500 errors after deploy | Check `RAILS_MASTER_KEY` is set correctly |
| Webhook failures | Verify `STRIPE_WEBHOOK_KEY` matches Stripe dashboard |
| Image upload errors | Confirm AWS credentials and bucket permissions |
| Database connection errors | Check `DATABASE_URL` and connection limit |
| Slow page loads | Review database queries, add indexes |
| Email not sending | Verify MailerSend credentials and domain |

**Debug Checklist:**
1. Check Render logs for errors
2. Verify all environment variables are set
3. Test health endpoint: `curl https://shop.cariana.tech/up`
4. Check Stripe webhook logs in dashboard
5. Review Honeybadger for exceptions
6. Verify DNS and SSL certificate status

## Where to Get Help

### Documentation

- **[Copilot Instructions](.github/copilot-instructions.md)** - Comprehensive codebase guide for AI-assisted development (1222 lines)
- **[Database Schema](documentation/schema-diagram.md)** - Entity-relationship diagram with model relationships
- **[Test Suite Analysis](documentation/test-analysis.md)** - Complete testing strategy and coverage report (301 tests, 749 assertions)
- **[Codebase Analysis](documentation/codebase-analysis.md)** - Detailed analysis of 10 areas for improvement
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
