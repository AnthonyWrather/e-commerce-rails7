# Contributing to E-Commerce Rails 7

Thank you for your interest in contributing to this Rails 7 e-commerce application! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Project Conventions](#project-conventions)

## Code of Conduct

This project follows a professional code of conduct. We expect all contributors to:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the project
- Show empathy towards other contributors

## Getting Started

### Prerequisites

- Ruby 3.2.3
- Rails 7.1.2
- PostgreSQL 17
- Node.js and Yarn (for JavaScript assets)
- VIPS (for Active Storage image processing)

### Setting Up the Development Environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/AnthonyWrather/e-commerce-rails7.git
   cd e-commerce-rails7
   ```

2. **Install dependencies**
   ```bash
   bundle install
   yarn install
   ```

3. **Set up the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed  # Optional: Load sample data
   ```

4. **Create an admin user**
   ```bash
   bin/rails c
   AdminUser.create(email: "admin@example.com", password: "12345678")
   exit
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```

### DevContainer Setup (Optional)

This project includes a DevContainer configuration for consistent development environments:

```bash
# Open in VS Code and select "Reopen in Container"
# Or use the Dev Containers extension
```

The DevContainer includes:
- PostgreSQL 17
- pgAdmin
- All necessary Ruby and JavaScript dependencies
- Pre-configured VS Code extensions

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `refactor/*` - Code refactoring
- `docs/*` - Documentation updates

### Typical Workflow

1. Create a new branch from `main`
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following our coding standards

3. Write or update tests to cover your changes

4. Run the full test suite
   ```bash
   bin/rails test:all
   ```

5. Run RuboCop to check code style
   ```bash
   rubocop -a
   ```

6. Build TypeScript/JavaScript
   ```bash
   yarn build
   ```

7. Commit your changes with a descriptive message
   ```bash
   git commit -m "Add feature: description of feature"
   ```

8. Push to your branch and create a pull request

## Coding Standards

### Ruby/Rails Standards

- Follow the [Ruby Style Guide](https://rubystyle.guide/)
- Use RuboCop for code linting (configuration in `.rubocop.yml`)
- All Ruby files must start with `# frozen_string_literal: true`
- Use strong parameters in all controllers
- Keep controllers thin - move business logic to models or services

### JavaScript/TypeScript Standards

- Use TypeScript for all new JavaScript code
- Follow the existing Stimulus controller patterns
- Place controller files in `app/javascript/controllers/`
- Use proper type definitions and interfaces
- Run `yarn build` before committing

### Database Conventions

- Use migrations for all schema changes
- Never edit `schema.rb` directly
- Add indexes for foreign keys and frequently queried columns
- Use meaningful migration names: `AddFieldToTable` or `CreateTableName`

### View Conventions

- Use Tailwind CSS for styling
- Follow existing component patterns
- Use partials for reusable UI components
- Keep view logic minimal - use helpers or presenters

## Testing Requirements

### Test Coverage

- Maintain or improve test coverage (currently 85.12%)
- All new features must include tests
- Bug fixes should include regression tests

### Test Types

**Unit Tests** (Models, Helpers)
```bash
bin/rails test test/models/
```

**Integration Tests** (Controllers)
```bash
bin/rails test test/controllers/
```

**System Tests** (Capybara)
```bash
bin/rails test:system
```

**Full Test Suite**
```bash
bin/rails test:all
```

### Test Patterns

- Use fixtures for test data (defined in `test/fixtures/`)
- Use Minitest (not RSpec)
- Follow existing test structure and naming
- Sign in admin users with `sign_in admin_users(:admin_user_one)`
- Use `assert`, `assert_equal`, `assert_not`, etc. for assertions

### Writing Good Tests

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  test "should validate presence of name" do
    product = Product.new(price: 1000)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "should validate price is non-negative" do
    product = Product.new(name: "Test", price: -100)
    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than or equal to 0"
  end
end
```

## Pull Request Process

### Before Submitting

- [ ] All tests pass (`bin/rails test:all`)
- [ ] RuboCop passes (`rubocop -a`)
- [ ] TypeScript builds without errors (`yarn build`)
- [ ] No `binding.pry` or debug code left in
- [ ] Documentation updated if needed
- [ ] Commit messages are clear and descriptive

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactoring

## Testing
Describe the testing you've done:
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] System tests added/updated
- [ ] Manual testing performed

## Related Issues
Closes #(issue number)

## Screenshots (if applicable)
Add screenshots for UI changes.

## Additional Notes
Any additional context or notes for reviewers.
```

### Review Process

1. At least one maintainer review is required
2. All CI checks must pass
3. Address all review comments
4. Squash commits if requested
5. Maintainer will merge when approved

## Project Conventions

### Admin Namespace

- Admin controllers inherit from `AdminController`
- Use `@admin_` prefix for instance variables (e.g., `@admin_product`)
- Require authentication with `authenticate_admin_user!`
- Use admin layout: `layout 'admin'`

### Pricing and Currency

- Store all prices in **pence** (integers) in the database
- Use `formatted_price(price)` helper for display
- Currency is GBP (British Pounds)
- VAT inclusive pricing (20% UK VAT)

### Image Handling

- Use Active Storage for all images
- Define variants in models (`:thumb`, `:medium`)
- Require VIPS for image processing
- Handle duplicate filenames (see `Admin::ProductsController#update`)

### Environment Variables and Secrets

- Use Rails credentials for secrets in development
  ```bash
  EDITOR="code --wait" rails credentials:edit
  ```
- Use environment variables in production
- Never commit secrets to version control
- Required secrets: `stripe.secret_key`, `stripe.webhook_key`

### HTTP Status Codes

- Use `:unprocessable_content` (not deprecated `:unprocessable_entity`)
- Use `:see_other` for redirects in Turbo/Hotwire contexts
- Return appropriate status codes for API responses

### Common Commands

```bash
# Start development server with Tailwind watch
bin/dev

# Database operations
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:reset

# Test suite
bin/rails test              # Unit and integration tests
bin/rails test:system       # System tests
bin/rails test:all          # All tests

# Code quality
rubocop -a                  # Auto-fix RuboCop issues
rubocop -A                  # Auto-fix unsafe RuboCop issues

# TypeScript/JavaScript
yarn build                  # Build once
yarn build --watch          # Watch mode
tsc --noEmit               # Type check only

# Rails console
bin/rails c

# Asset compilation
bin/rails assets:precompile
bin/rails assets:clean
```

## Code Review Guidelines

### For Authors

When your PR is under review:

- **Respond promptly** to review comments
- **Explain your reasoning** if you disagree with feedback
- **Make requested changes** or discuss alternatives
- **Update tests** if functionality changes during review
- **Keep commits clean** - squash commits if requested
- **Re-request review** after making changes

### For Reviewers

When reviewing PRs, check:

**Functionality**
- Does the code do what it claims to do?
- Are edge cases handled?
- Is error handling appropriate?
- Are there any security concerns?

**Code Quality**
- Does it follow project conventions?
- Is the code DRY (Don't Repeat Yourself)?
- Are names clear and descriptive?
- Is the abstraction level appropriate?
- Could it be simpler?

**Testing**
- Is test coverage adequate?
- Are tests meaningful (not just coverage)?
- Do tests cover edge cases?
- Are there system tests for user flows?

**Performance**
- Are there N+1 query issues?
- Is caching used appropriately?
- Are database queries optimized?
- Are there obvious performance bottlenecks?

**Security**
- Is user input validated and sanitized?
- Are authorization checks in place?
- Are secrets handled properly?
- Is SQL injection prevented (parameterized queries)?

**Common Issues to Flag**

❌ **Critical Issues** (must fix):
- Orders created outside webhooks
- Using deprecated status codes
- Missing CSRF tokens in AJAX
- SQL injection vulnerabilities
- Missing authentication/authorization
- Passwords or secrets in code
- Prices stored as floats instead of integers

⚠️ **Important Issues** (should fix):
- N+1 queries without eager loading
- Missing validations on models
- Missing tests for critical code
- Using wrong model names (Admin::Product)
- Not following strong parameters
- Poor error handling

💡 **Suggestions** (nice to have):
- Extract complex logic to service objects
- Add helpful code comments
- Improve variable naming
- Refactor duplicated code
- Add integration tests

### Review Comment Examples

**Good Review Comments**:
```markdown
This introduces an N+1 query. Consider using `includes(:order_products)` here to eager load the associations.
```

```markdown
Great test coverage! One edge case to consider: what happens if the stock_level is nil?
```

```markdown
This is vulnerable to SQL injection. Use parameterized queries: `Product.where('name LIKE ?', "%#{search}%")`
```

**Poor Review Comments**:
```markdown
This is bad. ❌ (Not specific, not helpful)
```

```markdown
Why did you do it this way? ❌ (Sounds confrontational)
```

```markdown
Just refactor this. ❌ (Not actionable)
```

## Git Commit Guidelines

### Commit Message Format

Follow this format for commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**: One of the following:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring (no functional changes)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build config, etc.)
- `perf`: Performance improvements
- `security`: Security fixes

**Scope** (optional): Component affected (e.g., `admin`, `cart`, `checkout`, `products`)

**Subject**: Brief description (50 chars or less, imperative mood)

**Body** (optional): Detailed explanation of what and why

**Footer** (optional): Breaking changes, issue references

### Commit Message Examples

```
feat(checkout): add VAT display on Stripe checkout

Display VAT breakdown on Stripe checkout screen to meet UK tax requirements.
VAT is calculated at 20% (ex VAT = total/1.2).

Closes #42
```

```
fix(webhooks): verify Stripe signature before processing

Added signature verification to prevent webhook spoofing attacks.
Returns 400 if signature is invalid.

Fixes #78
```

```
refactor(calculators): extract business logic to service objects

Moved quantity calculation logic from controllers to CalculatorService.
This improves testability and follows single responsibility principle.
```

```
test(admin): add integration tests for product CRUD

Added comprehensive tests for admin product creation, updating, and deletion.
Covers validation, image upload, and stock management.
```

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality
- **PATCH** version for backwards-compatible bug fixes

### Creating a Release

1. **Update version** in `config/application.rb`
2. **Update CHANGELOG.md** with release notes
3. **Run full test suite** (`bin/rails test:all`)
4. **Tag the release**
   ```bash
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin v1.2.0
   ```
5. **Deploy to production** (via Render.com)
6. **Monitor** for errors and performance issues
7. **Create GitHub release** with notes

### Deployment Checklist

Before deploying to production:

- [ ] All tests pass locally
- [ ] RuboCop passes
- [ ] Database migrations tested
- [ ] Environment variables updated (if needed)
- [ ] Secrets/credentials synced
- [ ] Rollback plan documented
- [ ] Monitoring alerts configured
- [ ] Stakeholders notified

## Troubleshooting Common Issues

### RuboCop Failures

```bash
# Auto-fix safe issues
rubocop -a

# Auto-fix all issues (including unsafe)
rubocop -A

# Ignore specific cops (use sparingly)
# rubocop:disable Rails/SkipsModelValidations
```

### Test Failures

```bash
# Run specific test file
bin/rails test test/models/product_test.rb

# Run specific test
bin/rails test test/models/product_test.rb:10

# Run with backtrace
bin/rails test --backtrace

# Run in random order (catch flaky tests)
bin/rails test --seed 12345
```

### TypeScript Build Errors

```bash
# Check TypeScript errors
tsc --noEmit

# Rebuild from scratch
rm -rf app/assets/builds/
yarn build

# Check for syntax errors
yarn build --watch
```

### Database Issues

```bash
# Reset database (WARNING: destroys data)
bin/rails db:reset

# Check migration status
bin/rails db:migrate:status

# Rollback last migration
bin/rails db:rollback

# Rollback multiple migrations
bin/rails db:rollback STEP=3
```

### Active Storage Issues

```bash
# Check VIPS installation
vips --version

# Install VIPS (macOS)
brew install vips

# Install VIPS (Linux)
apt-get install libvips
```

## Additional Resources

- [Project README](README.md)
- [Copilot Instructions](.github/copilot-instructions.md)
- [AI Agent Quick Start](.github/AGENTS.md)
- [Pull Request Template](.github/pull_request_template.md)
- [Documentation](documentation/)
- [Sprint Plans](documentation/sprint-plan-01.md)
- [Test Analysis](documentation/test-analysis.md)
- [Schema Diagram](documentation/schema-diagram.md)

## Questions or Issues?

If you have questions or encounter issues:

1. Check existing documentation
2. Search existing GitHub issues
3. Open a new issue with detailed information
4. Join discussions in pull requests

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE) file).

---

Thank you for contributing to E-Commerce Rails 7! 🎉
