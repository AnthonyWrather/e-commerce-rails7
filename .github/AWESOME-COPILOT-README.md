# GitHub Copilot Collections Guide

This repository includes **37 curated GitHub Copilot assets** across 5 specialized collections to enhance development workflows, code quality, testing, security, and performance.

## 📦 Installed Collections

### 1. Ruby MCP Server Development (3 items)
Build Model Context Protocol (MCP) servers in Ruby to extend GitHub Copilot capabilities.

**Assets:**
- `instructions/ruby-mcp-server.instructions.md` - Best practices for MCP server development
- `prompts/ruby-mcp-server-generator.prompt.md` - Scaffold new MCP servers
- `chatmodes/ruby-mcp-expert.chatmode.md` - Expert guidance for MCP architecture

**Use Cases:**
- Create custom Rails-specific MCP tools
- Extend Copilot with domain-specific knowledge
- Build reusable development workflows

---

### 2. Testing & Test Automation (9 items)
Comprehensive testing support with TDD workflows, Playwright automation, and test generation.

**Assets:**
- **Instructions:**
  - `playwright-python.instructions.md` - Python test generation with Playwright
  - `playwright-typescript.instructions.md` - TypeScript test generation
- **Chat Modes:**
  - `tdd-red.chatmode.md` - Write failing tests first
  - `tdd-green.chatmode.md` - Make tests pass
  - `tdd-refactor.chatmode.md` - Improve code quality
  - `playwright-tester.chatmode.md` - Playwright testing guidance
- **Prompts:**
  - `playwright-generate-test.prompt.md` - Generate comprehensive tests
  - `playwright-explore-website.prompt.md` - Explore sites for testing
  - `java-junit.prompt.md` - JUnit 5+ best practices
  - `csharp-nunit.prompt.md` - NUnit best practices

**Use Cases for This Project:**
- Generate system tests for checkout flow: `@workspace #file:.github/prompts/playwright-generate-test.prompt.md`
- Write tests for untested models (Product, Stock, Category)
- TDD workflow for new features (activate TDD chat modes)
- Test Stripe webhook integration
- Test calculator tools (quantities controllers)

**Quick Start:**
```bash
# Activate TDD Red mode, then:
# "Write failing tests for Product model validations"
# "Generate Playwright tests for cart checkout flow"
```

---

### 3. Security & Code Quality (5 items)
OWASP security practices, accessibility, performance optimization, and clean code principles.

**Assets:**
- `a11y.instructions.md` - WCAG 2.2 Level AA accessibility guidelines
- `object-calisthenics.instructions.md` - Clean code principles for maintainable code
- `performance-optimization.instructions.md` - Frontend, backend, and database performance
- `security-and-owasp.instructions.md` - OWASP Top 10 secure coding practices
- `self-explanatory-code-commenting.instructions.md` - Code documentation standards

**Use Cases for This Project:**
- **Security:** Review Stripe webhook validation against OWASP guidelines
- **Performance:** Fix N+1 queries in `CategoriesController#show`, optimize `AdminController#index` aggregations
- **Accessibility:** Add ARIA labels to cart/checkout forms, ensure keyboard navigation
- **Code Quality:** Refactor long methods using object calisthenics principles
- **Documentation:** Apply self-explanatory commenting to complex calculator logic

**Quick Start:**
```bash
# Examples:
# "Review app/controllers/webhooks_controller.rb for OWASP security issues"
# "Optimize the N+1 queries in app/controllers/categories_controller.rb"
# "Add accessibility improvements to app/views/carts/show.html.erb"
```

---

### 4. Database & Data Management (8 items)
PostgreSQL optimization, SQL best practices, and database administration guidance.

**Assets:**
- **Chat Modes:**
  - `ms-sql-dba.chatmode.md` - SQL Server DBA guidance
  - `postgresql-dba.chatmode.md` - PostgreSQL DBA guidance
- **Instructions:**
  - `ms-sql-dba.instructions.md` - SQL Server administration
  - `sql-sp-generation.instructions.md` - Stored procedure generation
- **Prompts:**
  - `postgresql-code-review.prompt.md` - PostgreSQL code review
  - `postgresql-optimization.prompt.md` - PostgreSQL query optimization
  - `sql-code-review.prompt.md` - Universal SQL code review
  - `sql-optimization.prompt.md` - Universal SQL optimization

**Use Cases for This Project:**
- **Query Optimization:** Analyze slow queries in admin dashboard
- **Indexing:** Review missing indexes on `products`, `stocks`, `orders` tables
- **Performance:** Optimize revenue aggregations in `AdminController#index`
- **Schema Review:** Validate foreign key constraints and data types
- **N+1 Prevention:** Add eager loading for `@products.with_attached_images`

**Quick Start:**
```bash
# Activate PostgreSQL DBA mode, then:
# "Review the schema in db/schema.rb for missing indexes"
# "Optimize the revenue queries in app/controllers/admin_controller.rb"
# "Analyze potential N+1 queries in the categories controller"
```

---

### 5. Frontend Web Development (12 items)
Modern frontend standards for TypeScript, React, Angular, Vue, Next.js, and Tailwind CSS.

**Assets:**
- **TypeScript/JavaScript:**
  - `angular.instructions.md` - Angular development standards
  - `nodejs-javascript-vitest.instructions.md` - Node.js/Vitest testing
  - `nextjs-tailwind.instructions.md` - Next.js + Tailwind standards
  - `nextjs.instructions.md` - Next.js 2025 best practices
  - `reactjs.instructions.md` - React development standards
  - `tanstack-start-shadcn-tailwind.instructions.md` - TanStack Start guidelines
  - `vuejs3.instructions.md` - Vue 3 Composition API standards
- **Chat Modes:**
  - `electron-angular-native.chatmode.md` - Electron code review
  - `expert-react-frontend-engineer.chatmode.md` - React 19 expert

**Use Cases for This Project:**
- **TypeScript:** Type-safe Stimulus controller development
- **JavaScript:** Refactor `cart_controller.ts` with proper error handling
- **Testing:** Generate Vitest tests for TypeScript controllers
- **Performance:** Optimize Chart.js rendering in dashboard
- **Code Quality:** Apply React patterns to Stimulus architecture

**Quick Start:**
```bash
# Examples:
# "Review app/javascript/controllers/cart_controller.ts for TypeScript best practices"
# "Generate Vitest tests for products_controller.ts"
# "Optimize the Chart.js implementation in dashboard_controller.ts"
```

---

## 🚀 How to Use These Assets

### Instructions (Auto-Loaded)
Automatically loaded by GitHub Copilot when editing relevant files.
- **Location:** `.github/instructions/*.instructions.md`
- **Activation:** Automatic based on file type/context
- **Example:** Editing a `.ts` file auto-loads TypeScript instructions

### Prompts (Copy & Reference)
Use with `#file:` syntax or copy/paste into Copilot chat.
- **Location:** `.github/prompts/*.prompt.md`
- **Usage:** `@workspace #file:.github/prompts/postgresql-optimization.prompt.md`
- **Example:** Copy prompt content and add your specific file/context

### Chat Modes (Activate in UI)
Specialized modes for focused guidance.
- **Location:** `.github/chatmodes/*.chatmode.md`
- **Activation:** Select from chat mode dropdown in Copilot interface
- **Example:** Activate "TDD Red" mode to write failing tests first

---

## 💡 Recommended Workflows for This Project

### 1. Test Coverage Improvement
**Goal:** Increase test coverage from 36 tests to comprehensive suite

**Workflow:**
1. Activate `tdd-red.chatmode.md`
2. Ask: "Write failing tests for Product model validations"
3. Switch to `tdd-green.chatmode.md`
4. Ask: "Implement validations to make tests pass"
5. Switch to `tdd-refactor.chatmode.md`
6. Ask: "Refactor Product model for better maintainability"

**Focus Areas:**
- Model validations (Product, Stock, Category, Order)
- Stripe webhook handler (`WebhooksController#stripe`)
- Cart checkout flow (`CheckoutsController#create`)
- Calculator business logic (Quantities controllers)

---

### 2. Performance Optimization
**Goal:** Eliminate N+1 queries and optimize database access

**Workflow:**
1. Reference: `#file:.github/prompts/postgresql-optimization.prompt.md`
2. Ask: "Analyze app/controllers/categories_controller.rb for N+1 queries"
3. Ask: "Add missing indexes based on db/schema.rb"
4. Reference: `#file:.github/instructions/performance-optimization.instructions.md`
5. Ask: "Optimize admin dashboard revenue aggregations"

**Focus Areas:**
- `CategoriesController#show` - Products with images
- `AdminController#index` - Revenue aggregations
- `Admin::ProductsController` - Pagy pagination queries
- Active Storage image variants

---

### 3. Security Hardening
**Goal:** Apply OWASP Top 10 practices to production code

**Workflow:**
1. Reference: `#file:.github/instructions/security-and-owasp.instructions.md`
2. Ask: "Review app/controllers/webhooks_controller.rb for security issues"
3. Ask: "Audit Stripe webhook signature validation"
4. Ask: "Review XSS prevention in cart_controller.ts"
5. Ask: "Check SQL injection risks in checkout flow"

**Focus Areas:**
- Stripe webhook validation (A01: Broken Access Control)
- Secret management (A02: Cryptographic Failures)
- SQL injection prevention (A03: Injection)
- Session security (A07: Authentication Failures)
- Letter Opener in production (A05: Security Misconfiguration)

---

### 4. Accessibility Compliance
**Goal:** Achieve WCAG 2.2 Level AA compliance

**Workflow:**
1. Reference: `#file:.github/instructions/a11y.instructions.md`
2. Ask: "Review app/views/carts/show.html.erb for accessibility"
3. Ask: "Add ARIA labels to checkout form"
4. Ask: "Ensure keyboard navigation in admin tables"
5. Ask: "Audit color contrast in Tailwind classes"

**Focus Areas:**
- Cart and checkout forms
- Admin dashboard tables
- Navigation skip links
- Image alt text (product images, category images)
- Form error messages

---

### 5. TypeScript Best Practices
**Goal:** Apply strict TypeScript patterns to Stimulus controllers

**Workflow:**
1. Reference: `#file:.github/instructions/nodejs-javascript-vitest.instructions.md`
2. Ask: "Review app/javascript/controllers/cart_controller.ts"
3. Ask: "Generate Vitest tests for products_controller.ts"
4. Ask: "Add type safety to dashboard_controller.ts Chart.js usage"

**Focus Areas:**
- `cart_controller.ts` - LocalStorage type safety
- `products_controller.ts` - Product/Stock interfaces
- `dashboard_controller.ts` - Chart.js types
- `quantities_controller.ts` - Calculator types

---

## 📊 Project-Specific Quick Wins

### Immediate High-Impact Tasks

**1. Fix Known N+1 Queries (5 minutes)**
```bash
# Reference performance instructions
@workspace #file:.github/instructions/performance-optimization.instructions.md
# Ask: "Fix N+1 queries in app/controllers/categories_controller.rb line 14-16"
```

**2. Add Missing Product Model Validations (10 minutes)**
```bash
# Activate TDD Red mode
# Ask: "Write tests for Product model validations (name, price, amount)"
# Switch to TDD Green mode
# Ask: "Implement validations to pass tests"
```

**3. Security Audit Stripe Webhook (15 minutes)**
```bash
# Reference security instructions
@workspace #file:.github/instructions/security-and-owasp.instructions.md
# Ask: "Security audit app/controllers/webhooks_controller.rb"
```

**4. Generate System Tests for Checkout (20 minutes)**
```bash
# Reference Playwright prompt
@workspace #file:.github/prompts/playwright-generate-test.prompt.md
# Ask: "Generate Playwright tests for cart checkout flow"
```

**5. Add Database Indexes (10 minutes)**
```bash
# Activate PostgreSQL DBA mode
# Ask: "Analyze db/schema.rb and suggest missing indexes for queries in app/controllers/admin_controller.rb"
```

---

## 🎯 Collection Synergy Examples

### Example 1: Secure, Tested, Performant Feature
**Scenario:** Add product filtering with price range

**Combined Workflow:**
1. **TDD Red Mode:** Write failing tests for filter logic
2. **Security Instructions:** Validate and sanitize price input params
3. **Performance Instructions:** Ensure indexed query execution
4. **Accessibility Instructions:** Add ARIA labels to filter form
5. **TDD Green Mode:** Implement feature to pass tests
6. **PostgreSQL Optimization:** Verify query plan with EXPLAIN

**Assets Used:**
- `tdd-red.chatmode.md`, `tdd-green.chatmode.md`
- `security-and-owasp.instructions.md`
- `performance-optimization.instructions.md`
- `a11y.instructions.md`
- `postgresql-optimization.prompt.md`

---

### Example 2: Full-Stack TypeScript Feature
**Scenario:** Add real-time stock level updates with ActionCable

**Combined Workflow:**
1. **TypeScript Instructions:** Type-safe Stimulus controller
2. **Testing Instructions:** Vitest tests for WebSocket logic
3. **Performance Instructions:** Optimize broadcast frequency
4. **Security Instructions:** Validate channel subscriptions
5. **TDD Workflow:** Red/Green/Refactor cycle

**Assets Used:**
- `nodejs-javascript-vitest.instructions.md`
- `tdd-red/green/refactor.chatmode.md`
- `performance-optimization.instructions.md`
- `security-and-owasp.instructions.md`

---

## 📚 Additional Resources

### Official Documentation
- [GitHub Copilot Collections](https://github.com/github/awesome-copilot)
- [Rails 7 Guides](https://guides.rubyonrails.org/v7.1/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.2 Guidelines](https://www.w3.org/TR/WCAG22/)

### Project-Specific Documentation
- [Copilot Instructions](/.github/copilot-instructions.md) - Project-specific Copilot guidance
- [Schema Diagram](/documentation/schema-diagram.md) - Database entity relationships
- [README](../README.md) - Project setup and deployment

---

## 🔄 Keeping Collections Updated

Collections are versioned and maintained by the community. To update:

1. **Check for Updates:**
   ```bash
   # Visit awesome-copilot repository
   # Check collection file timestamps
   ```

2. **Selective Updates:**
   ```bash
   # Re-download specific assets
   curl -sL https://raw.githubusercontent.com/github/awesome-copilot/main/instructions/security-and-owasp.instructions.md \
     -o .github/instructions/security-and-owasp.instructions.md
   ```

3. **Full Refresh:**
   ```bash
   # Re-run installation for all collections
   # Follow instructions in suggest-awesome-github-copilot-collections.prompt.md
   ```

---

## 📝 Contributing

If you create custom prompts, instructions, or chat modes specific to this project:

1. Add to appropriate directory (`.github/instructions/`, `.github/prompts/`, `.github/chatmodes/`)
2. Follow naming conventions (`kebab-case.type.md`)
3. Document in this README under a "Custom Assets" section
4. Consider contributing back to [awesome-copilot](https://github.com/github/awesome-copilot)

---

## 🎓 Learning Path

**Beginner (Week 1):**
- Use `tdd-red/green/refactor.chatmode.md` for simple model tests
- Apply `self-explanatory-code-commenting.instructions.md` to new code
- Try `postgresql-code-review.prompt.md` on existing queries

**Intermediate (Week 2-3):**
- Generate Playwright tests with `playwright-generate-test.prompt.md`
- Apply `security-and-owasp.instructions.md` to controllers
- Use `performance-optimization.instructions.md` for N+1 fixes

**Advanced (Week 4+):**
- Build custom MCP server with `ruby-mcp-server-generator.prompt.md`
- Combine multiple assets for full-stack features
- Create project-specific custom prompts/instructions

---

## 🆘 Troubleshooting

**Collections Not Loading?**
- Ensure files are in `.github/` directories
- Check file extensions (`.instructions.md`, `.prompt.md`, `.chatmode.md`)
- Restart VS Code / Copilot extension

**Chat Modes Not Appearing?**
- Update GitHub Copilot extension to latest version
- Check `.chatmode.md` files have correct frontmatter
- Try selecting from chat mode dropdown in Copilot UI

**Instructions Not Applied?**
- Check `applyTo` pattern in frontmatter matches your file type
- Instructions auto-load based on file context
- May need to explicitly reference with `#file:` syntax

---

## 📊 Collection Statistics

- **Total Assets:** 37 unique items
- **Instructions:** 17 (auto-loaded by context)
- **Prompts:** 11 (reference with `#file:`)
- **Chat Modes:** 9 (activate via UI)
- **Coverage:** Ruby, TypeScript, PostgreSQL, Security, Testing, Accessibility, Performance
- **Installation Date:** November 24, 2025
- **Source:** [github/awesome-copilot](https://github.com/github/awesome-copilot)

---

**Happy Coding! 🚀**

*These collections are designed to make GitHub Copilot even more powerful for your Rails 7 e-commerce project. Start with the recommended workflows above and gradually explore all assets to maximize your development efficiency.*
