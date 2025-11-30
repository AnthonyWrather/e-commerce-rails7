---
description: 'Ruby on Rails 7 development standards and best practices'
applyTo: '**/*.rb, **/*.erb, **/Gemfile, **/*.rake'
---

# Ruby on Rails 7 Development Instructions

Instructions for building high-quality Ruby on Rails 7 applications with modern patterns, conventions, and best practices following the official Rails documentation at https://guides.rubyonrails.org.

## Project Context
- Rails 7.1+ with Hotwire (Turbo + Stimulus) as default frontend
- Ruby 3.2+ with frozen string literals enabled
- PostgreSQL as the primary database
- Minitest for testing (not RSpec)
- Follow Rails conventions and the official style guide
- Use Devise for authentication when needed
- Implement Active Storage for file uploads

## Development Standards

### Architecture
- Follow Rails MVC architecture with clear separation of concerns
- Use RESTful routes and resourceful controllers
- Implement concerns for shared model/controller behavior
- Keep controllers thin by moving business logic to models or service objects
- Use namespaces (e.g., `Admin::`) for organizing related controllers
- Prefer composition over inheritance for code reuse

### Ruby Conventions
- All Ruby files must start with `# frozen_string_literal: true`
- Use snake_case for method and variable names
- Use CamelCase for class and module names
- Use SCREAMING_SNAKE_CASE for constants
- Keep methods short (under 10 lines when possible)
- Use guard clauses for early returns
- Prefer `&&` and `||` over `and` and `or`

### Model Design
- Implement validations for all user-facing inputs
- Use scopes for commonly used queries
- Define associations with appropriate dependent options
- Use `has_many :through` for complex associations
- Implement callbacks sparingly (prefer service objects for complex logic)
- Use Active Record enums for status fields
- Add database indexes for foreign keys and frequently queried columns

### Controller Design
- Use strong parameters for all input handling
- Implement proper before_action callbacks for authentication and authorization
- Return appropriate HTTP status codes:
  - Use `:unprocessable_content` (not deprecated `:unprocessable_entity`) for validation errors
  - Use `:not_found` for missing resources
  - Use `:unauthorized` for authentication failures
- Use `respond_to` blocks for multiple format support
- Implement pagination for index actions (use Pagy gem)

### View Design
- Use partials for reusable view components
- Implement helpers for complex view logic
- Use content_for blocks for page-specific content
- Prefer ERB over other templating languages
- Use form_with for all forms (not form_for or form_tag)
- Implement proper CSRF protection in all forms

### Hotwire Integration
- Use Turbo Drive for SPA-like navigation
- Implement Turbo Frames for partial page updates
- Use Turbo Streams for real-time updates
- Write Stimulus controllers in TypeScript when possible
- Keep Stimulus controllers focused on single responsibilities
- Use data attributes for passing data from Rails to JavaScript

### Database Conventions
- Use integer IDs as primary keys (not UUIDs unless specifically required)
- Store monetary values in the smallest unit (e.g., pence, not pounds)
- Use timestamps (`created_at`, `updated_at`) on all tables
- Implement soft deletes with `discarded_at` when needed
- Use database-level constraints in addition to model validations
- Write reversible migrations

### Authentication & Authorization
- Use Devise for authentication when applicable
- Implement role-based access control for admin features
- Use before_action filters for authorization
- Store sessions securely (encrypted cookies or database)
- Implement rate limiting for sensitive endpoints

### Testing
- Use Minitest (Rails default) for all tests
- Write controller tests as integration tests (`ActionDispatch::IntegrationTest`)
- Use fixtures for test data (not FactoryBot unless specifically required)
- Write system tests with Capybara for critical user flows
- Test model validations and associations
- Aim for high test coverage on business-critical code

### Security
- Never trust user input; always sanitize and validate
- Use strong parameters in all controllers
- Implement Content Security Policy headers
- Use Rails credentials for secrets (not environment variables in development)
- Implement Rack::Attack for rate limiting
- Sanitize HTML output to prevent XSS
- Use parameterized queries (never string interpolation in SQL)

### Performance
- Use eager loading to prevent N+1 queries (`includes`, `with_attached_*`)
- Implement database indexes for frequently queried columns
- Use counter caches for counting associations
- Implement fragment caching for expensive view renders
- Use background jobs for long-running tasks
- Optimize Active Storage variants at upload time

### Code Style (RuboCop)
- Run `rubocop -a` for safe auto-fixes before committing
- Follow the project's `.rubocop.yml` configuration
- Keep line length reasonable (usually 120 characters)
- Use consistent indentation (2 spaces)
- Prefer double quotes for strings unless interpolation not needed

## Common Patterns

### Service Objects
When business logic is too complex for models:
```ruby
# app/services/order_creation_service.rb
class OrderCreationService
  def initialize(params)
    @params = params
  end

  def call
    # Complex order creation logic
  end
end
```

### Query Objects
For complex database queries:
```ruby
# app/queries/products_query.rb
class ProductsQuery
  def initialize(relation = Product.all)
    @relation = relation
  end

  def active
    @relation.where(active: true)
  end

  def in_price_range(min, max)
    @relation.where(price: min..max)
  end
end
```

### Form Objects
For complex form handling:
```ruby
# app/forms/checkout_form.rb
class CheckoutForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :name, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end
```

### Presenters/Decorators
For complex view logic:
```ruby
# app/presenters/product_presenter.rb
class ProductPresenter < SimpleDelegator
  def formatted_price
    "£#{price / 100.0}"
  end
end
```

## Implementation Process
1. Plan database schema and model relationships
2. Write migrations with proper indexes
3. Implement models with validations and associations
4. Create controllers with strong parameters
5. Build views with partials and helpers
6. Add Stimulus controllers for interactivity
7. Write tests (model, controller, system)
8. Run RuboCop and fix style issues
9. Review for N+1 queries and performance
10. Ensure security best practices are followed

## Additional Guidelines
- Follow RESTful conventions for route naming
- Use meaningful commit messages following conventional commits
- Document complex business logic with comments
- Keep dependencies up to date and audit for vulnerabilities
- Use Rails generators for scaffolding when appropriate
- Implement proper logging for debugging and monitoring
- Use environment-specific configuration appropriately
