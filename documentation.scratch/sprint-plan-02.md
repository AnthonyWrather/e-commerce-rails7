# Sprint Plan 02 - Production Readiness & User Experience
**Sprint Goal**: Enhance production readiness with CI/CD, improve user experience with search & cart persistence, and strengthen security.

**Sprint Duration**: 2 weeks
**Start Date**: November 29, 2025
**End Date**: December 13, 2025

## Sprint Status Summary

**Last Updated**: November 30, 2025

### Epic Completion Status

| Epic | Status | Points Completed | Stories |
|------|--------|-----------------|---------|
| Epic 1: Infrastructure & DevOps | ✅ Complete | 16/16 | 3/3 |
| Epic 2: User Experience | ✅ Complete | 34/34 | 3/3 |
| Epic 3: Security | ✅ Complete | 26/26 | 3/3 |
| Epic 4: Performance | ✅ Complete | 16/16 | 2/2 |
| Epic 5: Code Quality | ✅ Complete | 21/21 | 2/2 |
| **Total** | **✅ Complete** | **113/113** | **13/13** |

### Story Completion Summary

| Story | Status | Implementation |
|-------|--------|---------------|
| 1.1 GitHub Actions CI/CD | ✅ Done | `.github/workflows/ci.yml` |
| 1.2 Honeybadger Error Tracking | ✅ Done | `config/honeybadger.yml`, error pages |
| 1.3 Uptime Monitoring | ✅ Done | Documentation in `uptime-monitoring.md` |
| 2.1 Product Search | ✅ Done | `pg_search`, `SearchController` |
| 2.2 Cart Persistence | ✅ Done | `Cart`/`CartItem` models, API endpoints |
| 2.3 Sorting & Filtering | ✅ Done | Product scopes, category UI |
| 3.1 Two-Factor Auth | ✅ Done | `devise-two-factor`, QR codes, backup codes |
| 3.2 Audit Logging | ✅ Done | `paper_trail`, `AuditLogsController` |
| 3.3 CSP Headers | ✅ Done | `content_security_policy.rb` |
| 4.1 Redis Caching | ✅ Done | Production cache store, fragment caching |
| 4.2 Asset Optimization | ✅ Done | WebP variants, lazy loading |
| 5.1 Service Objects | ✅ Done | `QuantityCalculatorService` |
| 5.2 Test Coverage | ✅ Done | 84% coverage, 719 tests |

## Sprint Objectives

1. **Infrastructure & DevOps** - Implement CI/CD pipeline and monitoring
2. **User Experience** - Add product search and improve cart functionality
3. **Security** - Enhance admin security with MFA and improved authorization
4. **Performance** - Optimize asset delivery and implement caching
5. **Code Quality** - Refactor calculator logic and improve test coverage

## Sprint Stories & Tasks

### Epic 1: Infrastructure & DevOps (Priority: HIGH)

#### Story 1.1: GitHub Actions CI/CD Pipeline
**Priority**: High
**Story Points**: 8
**Assignee**: TBD

**Description**: Implement automated CI/CD pipeline to run tests, linting, and security scans on all pull requests and deployments.

**Acceptance Criteria**:
- [ ] Tests run automatically on all PRs
- [ ] RuboCop linting enforced on PRs
- [ ] Brakeman security scanning included
- [ ] SimpleCov coverage report generated
- [ ] Failed CI blocks PR merging
- [ ] Green CI required for deployment

**Tasks**:
- [ ] Create `.github/workflows/ci.yml` workflow file
- [ ] Configure test job (Minitest + system tests)
- [ ] Configure lint job (RuboCop)
- [ ] Configure security scan job (Brakeman)
- [ ] Add coverage reporting (SimpleCov → CI artifacts)
- [ ] Configure branch protection rules
- [ ] Document CI/CD process in README

**Technical Notes**:
```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request, push]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:17
  lint:
    runs-on: ubuntu-latest
  security:
    runs-on: ubuntu-latest
```

---

#### Story 1.2: Error Tracking with Honeybadger
**Priority**: High
**Story Points**: 5
**Assignee**: TBD

**Description**: Configure and enable Honeybadger error tracking (already in Gemfile) for production monitoring.

**Acceptance Criteria**:
- [ ] Honeybadger API key configured in credentials
- [ ] Error notifications sent to Honeybadger
- [ ] JavaScript errors tracked
- [ ] Performance metrics enabled
- [ ] Alert channels configured (email/Slack)
- [ ] Custom error pages with error ID display

**Tasks**:
- [ ] Add Honeybadger API key to Rails credentials
- [ ] Configure `config/honeybadger.yml` for production
- [ ] Add JavaScript error tracking to frontend
- [ ] Set up alert policies in Honeybadger dashboard
- [ ] Create custom error pages (500.html) with error ID
- [ ] Test error tracking in staging
- [ ] Document error handling procedures

**Technical Notes**:
```ruby
# config/honeybadger.yml
api_key: <%= Rails.application.credentials.dig(:honeybadger, :api_key) %>
env: <%= Rails.env %>
report_data: true
```

---

#### Story 1.3: Uptime Monitoring
**Priority**: Medium
**Story Points**: 3
**Assignee**: TBD

**Description**: Set up external uptime monitoring to track availability and response times.

**Acceptance Criteria**:
- [ ] Uptime monitor configured (UptimeRobot or similar)
- [ ] Health check endpoint monitored
- [ ] Alert on downtime (>5 minutes)
- [ ] Response time tracking enabled
- [ ] SSL certificate expiry monitoring
- [ ] Monthly uptime report available

**Tasks**:
- [ ] Sign up for UptimeRobot or similar service
- [ ] Configure `/up` endpoint monitoring
- [ ] Set up alert contacts (email/SMS)
- [ ] Configure SSL certificate monitoring
- [ ] Create uptime status page (optional)
- [ ] Document monitoring setup

**Technical Notes**:
- Rails health check already exists at `/up`
- Monitor at 5-minute intervals
- Alert after 2 consecutive failures

---

### Epic 2: User Experience (Priority: HIGH)

#### Story 2.1: Product Search Functionality
**Priority**: High
**Story Points**: 13
**Assignee**: TBD

**Description**: Implement full-text product search using PostgreSQL pg_search gem to allow users to find products by name, description, and category.

**Acceptance Criteria**:
- [ ] Search box in navbar
- [ ] Full-text search across products (name, description, category)
- [ ] Search results page with filtering
- [ ] Search highlights matching terms
- [ ] Pagination on search results (Pagy)
- [ ] Empty state for no results
- [ ] Search query preserved in URL (bookmarkable)
- [ ] Tests for search functionality

**Tasks**:
- [ ] Add `pg_search` gem to Gemfile
- [ ] Create search scope in Product model
- [ ] Create `SearchController` and routes
- [ ] Add search form to navbar partial
- [ ] Create search results view with highlighting
- [ ] Implement pagination for results
- [ ] Add tests (unit + integration + system)
- [ ] Optimize search performance (indexes)
- [ ] Document search features

**Technical Notes**:
```ruby
# app/models/product.rb
include PgSearch::Model
pg_search_scope :search_by_full_text,
  against: [:name, :description],
  associated_against: {
    category: [:name, :description]
  },
  using: {
    tsearch: { prefix: true }
  }
```

---

#### Story 2.2: Server-Side Cart Persistence
**Priority**: High
**Story Points**: 13
**Assignee**: TBD

**Description**: Add optional cart persistence to database for better UX and cross-device support, while maintaining localStorage fallback for guests.

**Acceptance Criteria**:
- [ ] Cart model with has_many :cart_items
- [ ] Database migration for carts and cart_items tables
- [ ] Sync localStorage cart to database on user action
- [ ] Cart expiry after 30 days of inactivity
- [ ] Price refresh on cart load (prevent stale prices)
- [ ] Merge carts when user returns
- [ ] Tests for cart persistence logic

**Tasks**:
- [ ] Create Cart and CartItem models
- [ ] Generate migration (carts, cart_items tables)
- [ ] Add cart persistence service object
- [ ] Update cart_controller.ts to sync with server
- [ ] Implement cart merge logic (localStorage + database)
- [ ] Add cart expiry background job (optional)
- [ ] Update checkout flow to use persisted cart
- [ ] Add tests (model + controller + system)
- [ ] Document cart persistence strategy

**Technical Notes**:
```ruby
# app/models/cart.rb
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  scope :expired, -> { where('updated_at < ?', 30.days.ago) }
end

# app/models/cart_item.rb
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  validates :quantity, numericality: { greater_than: 0 }
end
```

---

#### Story 2.3: Product Sorting and Advanced Filtering
**Priority**: Medium
**Story Points**: 8
**Assignee**: TBD

**Description**: Add sorting options (name, price, newest) and additional filters (material type, fiberglass reinforcement) to category pages.

**Acceptance Criteria**:
- [ ] Sort by: Name (A-Z, Z-A), Price (Low-High, High-Low), Newest
- [ ] Filter by: Fiberglass reinforcement (yes/no)
- [ ] Filter by: Weight range, Size availability
- [ ] Filters persist in URL (bookmarkable)
- [ ] Clear filters button
- [ ] Product count displayed
- [ ] Tests for sorting and filtering

**Tasks**:
- [ ] Add sort parameter to CategoriesController
- [ ] Implement sorting logic with scopes
- [ ] Add fiberglass filter checkbox
- [ ] Add weight range filter
- [ ] Update category view with sort/filter UI
- [ ] Preserve filters in pagination links
- [ ] Add tests (controller + system)
- [ ] Document filtering API

**Technical Notes**:
```ruby
# app/models/product.rb
scope :fiberglass_only, -> { where(fiberglass_reinforcement: true) }
scope :by_weight, ->(min, max) { where(shipping_weight: min..max) }
scope :sorted_by, ->(sort) {
  case sort
  when 'name_asc' then order(name: :asc)
  when 'name_desc' then order(name: :desc)
  when 'price_asc' then order(price: :asc)
  when 'price_desc' then order(price: :desc)
  when 'newest' then order(created_at: :desc)
  end
}
```

---

### Epic 3: Security (Priority: HIGH)

#### Story 3.1: Two-Factor Authentication for Admin
**Priority**: High
**Story Points**: 13
**Assignee**: TBD

**Description**: Implement 2FA/MFA for admin users using devise-two-factor gem with TOTP (Time-based One-Time Password) support.

**Acceptance Criteria**:
- [ ] 2FA setup page with QR code
- [ ] TOTP verification on login
- [ ] Backup codes generated (10 codes)
- [ ] Backup code usage tracking
- [ ] 2FA required for all admin users
- [ ] 2FA disable requires password confirmation
- [ ] Tests for 2FA flow

**Tasks**:
- [ ] Add `devise-two-factor` and `rqrcode` gems
- [ ] Generate migration for 2FA fields
- [ ] Create 2FA setup controller/views
- [ ] Generate QR codes for authenticator apps
- [ ] Implement backup code generation
- [ ] Update login flow to request TOTP
- [ ] Add 2FA management in admin profile
- [ ] Add tests (unit + integration + system)
- [ ] Document 2FA setup for admins

**Technical Notes**:
```ruby
# app/models/admin_user.rb
devise :two_factor_authenticatable,
       otp_secret_encryption_key: Rails.application.credentials.dig(:devise, :otp_secret_key)

# Migration
add_column :admin_users, :encrypted_otp_secret, :string
add_column :admin_users, :encrypted_otp_secret_iv, :string
add_column :admin_users, :encrypted_otp_secret_salt, :string
add_column :admin_users, :consumed_timestep, :integer
add_column :admin_users, :otp_required_for_login, :boolean
```

---

#### Story 3.2: Admin Audit Logging
**Priority**: Medium
**Story Points**: 8
**Assignee**: TBD

**Description**: Implement audit trail for admin actions using PaperTrail gem to track who did what and when.

**Acceptance Criteria**:
- [ ] Track all admin CRUD operations (products, categories, orders, stocks)
- [ ] Store user ID, action type, timestamp
- [ ] Store before/after values for updates
- [ ] Admin audit log page (filterable by user, date, action)
- [ ] Export audit log to CSV
- [ ] 90-day retention policy
- [ ] Tests for audit logging

**Tasks**:
- [ ] Add `paper_trail` gem to Gemfile
- [ ] Generate PaperTrail migration
- [ ] Enable versioning on models (Product, Category, Order, Stock)
- [ ] Create Admin::AuditLogsController
- [ ] Create audit log view with filters
- [ ] Add CSV export functionality
- [ ] Configure retention policy (auto-delete old versions)
- [ ] Add tests (model + controller)
- [ ] Document audit log access

**Technical Notes**:
```ruby
# app/models/product.rb
has_paper_trail on: [:update, :destroy],
                meta: { admin_user_id: :current_admin_user_id }

# app/controllers/admin_controller.rb
def current_admin_user_id
  current_admin_user&.id
end
```

---

#### Story 3.3: Content Security Policy (CSP)
**Priority**: Medium
**Story Points**: 5
**Assignee**: TBD

**Description**: Implement Content Security Policy headers to prevent XSS attacks and improve security posture.

**Acceptance Criteria**:
- [ ] CSP headers configured in production
- [ ] Allow inline styles for Tailwind (nonce-based)
- [ ] Allow Stripe JavaScript SDK
- [ ] Allow Google Analytics (if enabled)
- [ ] Report-only mode initially
- [ ] Monitor CSP violations
- [ ] Enforce mode after validation

**Tasks**:
- [ ] Configure CSP in `config/initializers/content_security_policy.rb`
- [ ] Add nonce support for inline scripts
- [ ] Whitelist external domains (Stripe, GA)
- [ ] Test CSP in staging (report-only mode)
- [ ] Set up CSP violation reporting endpoint
- [ ] Switch to enforce mode
- [ ] Add tests for CSP headers
- [ ] Document CSP policy

**Technical Notes**:
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.script_src  :self, :https, 'https://js.stripe.com'
  policy.style_src   :self, :https, :unsafe_inline
  policy.connect_src :self, 'https://api.stripe.com'
end
```

---

### Epic 4: Performance (Priority: MEDIUM)

#### Story 4.1: Redis Caching Layer
**Priority**: Medium
**Story Points**: 8
**Assignee**: TBD

**Description**: Implement Redis-based caching for frequently accessed data (products, categories, dashboard stats).

**Acceptance Criteria**:
- [ ] Redis configured in production
- [ ] Fragment caching for product cards
- [ ] Russian Doll caching for categories
- [ ] Dashboard stats cached (5-minute TTL)
- [ ] Cache invalidation on model updates
- [ ] Cache hit rate monitoring
- [ ] Tests for caching logic

**Tasks**:
- [ ] Add Redis to Render.com services
- [ ] Configure Rails cache store (Redis)
- [ ] Add fragment caching to product partials
- [ ] Implement Russian Doll caching for categories
- [ ] Cache dashboard aggregations
- [ ] Add cache invalidation callbacks
- [ ] Monitor cache performance (hit rate)
- [ ] Add tests for cache invalidation
- [ ] Document caching strategy

**Technical Notes**:
```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 1.hour
}

# app/views/products/_product.html.erb
<% cache product do %>
  <!-- Product card HTML -->
<% end %>
```

---

#### Story 4.2: Asset Optimization & CDN
**Priority**: Medium
**Story Points**: 8
**Assignee**: TBD

**Description**: Optimize asset delivery with compression, modern image formats, and optional CDN integration.

**Acceptance Criteria**:
- [ ] Gzip/Brotli compression enabled
- [ ] JavaScript bundle size reduced (<400KB)
- [ ] WebP images generated for products
- [ ] Lazy loading for product images
- [ ] Font loading optimized (font-display: swap)
- [ ] CDN configured (optional: Cloudflare)
- [ ] Lighthouse score >90 for performance

**Tasks**:
- [ ] Enable Brotli compression in Puma/Nginx
- [ ] Analyze JavaScript bundle (source-map-explorer)
- [ ] Add WebP variant generation (Active Storage)
- [ ] Implement lazy loading for images
- [ ] Optimize font loading strategy
- [ ] Configure Cloudflare CDN (optional)
- [ ] Run Lighthouse audit and fix issues
- [ ] Add performance budget to CI
- [ ] Document asset optimization

**Technical Notes**:
```ruby
# app/models/product.rb
has_many_attached :images do |attachable|
  attachable.variant :thumb, resize_to_limit: [50, 50], preprocessed: true
  attachable.variant :medium, resize_to_limit: [250, 250], preprocessed: true
  attachable.variant :webp, resize_to_limit: [250, 250], format: :webp
end
```

---

### Epic 5: Code Quality (Priority: MEDIUM)

#### Story 5.1: Refactor Calculator Logic to Service Objects
**Priority**: Medium
**Story Points**: 13
**Assignee**: TBD

**Description**: Extract calculator business logic from controllers to service objects for better testability and maintainability.

**Acceptance Criteria**:
- [ ] QuantityCalculatorService class created
- [ ] Constants extracted to module (material_width, ratio, wastage)
- [ ] Three calculator methods (area, dimensions, mould)
- [ ] Controllers use service objects
- [ ] Unit tests for service objects
- [ ] Integration tests still pass
- [ ] Documentation updated

**Tasks**:
- [ ] Create `app/services/` directory
- [ ] Create `QuantityCalculatorService` class
- [ ] Extract constants to `QuantityCalculatorService::Constants`
- [ ] Implement `calculate_area` method
- [ ] Implement `calculate_dimensions` method
- [ ] Implement `calculate_mould_rectangle` method
- [ ] Update Quantities controllers to use service
- [ ] Write unit tests for service methods
- [ ] Verify integration tests pass
- [ ] Update documentation

**Technical Notes**:
```ruby
# app/services/quantity_calculator_service.rb
class QuantityCalculatorService
  module Constants
    MATERIAL_WIDTH = 0.95
    RATIO = 1.6
    WASTAGE = 1.15
  end

  def calculate_area(area:, layers:, material_weight:, catalyst_percent:)
    # Extract business logic from controller
    {
      mat: calculate_mat(area, layers),
      mat_total: calculate_mat_with_wastage(area, layers),
      resin: calculate_resin(area, layers),
      catalyst_ml: calculate_catalyst(area, layers, catalyst_percent)
    }
  end
end
```

---

#### Story 5.2: Improve Test Coverage for Critical Paths
**Priority**: Medium
**Story Points**: 8
**Assignee**: TBD

**Description**: Increase test coverage for critical integration paths and edge cases.

**Acceptance Criteria**:
- [ ] CheckoutsController#create unit tests added
- [ ] End-to-end checkout integration test
- [ ] Stripe webhook edge case tests
- [ ] Cart merge scenario tests
- [ ] Coverage maintained above 85%
- [ ] All critical paths have integration tests

**Tasks**:
- [ ] Add CheckoutsController#create unit tests (Stripe mocking)
- [ ] Add end-to-end checkout integration test
- [ ] Add Stripe webhook edge case tests (duplicate events, invalid data)
- [ ] Add cart merge tests (localStorage + database)
- [ ] Add search edge case tests
- [ ] Run SimpleCov and verify coverage
- [ ] Document testing strategy

**Technical Notes**:
- Use `stripe-ruby-mock` for Stripe API mocking
- Use VCR for recording Stripe responses
- Test with Stripe CLI for webhook testing

---

## Sprint Metrics & Goals

### Velocity Targets
- **Story Points**: 90 (9 stories)
- **Expected Velocity**: 70-80 points (team capacity)
- **Stretch Goals**: 10-20 points (if ahead)

### Quality Metrics
- **Code Coverage**: Maintain >85% (currently 85.12%)
- **RuboCop Offenses**: 0 (all auto-fixable)
- **Test Suite**: <2 minutes run time
- **Lighthouse Score**: >90 for performance

### Success Criteria
1. ✅ CI/CD pipeline live and enforcing on all PRs
2. ✅ Product search functional with good UX
3. ✅ Admin 2FA enabled for all admin users
4. ✅ Error tracking catching production issues
5. ✅ Cache hit rate >80% for frequently accessed pages

## Dependencies & Risks

### External Dependencies
- **Honeybadger**: API key and setup
- **Redis**: Render.com service provisioning
- **UptimeRobot**: Account creation and configuration
- **Stripe Test Mode**: For webhook testing

### Technical Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Stripe mocking limitations in tests | High | Medium | Use Stripe CLI for manual testing, document strategy |
| Redis performance in production | Medium | Medium | Monitor cache hit rates, implement gradual rollout |
| Search performance on large datasets | Medium | High | Add database indexes, implement pagination |
| Cart merge logic complexity | High | Medium | Write comprehensive tests, document edge cases |
| 2FA user adoption resistance | Medium | Low | Provide clear documentation, enforce gradually |

### Team Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Underestimation of story points | Medium | Medium | Buffer 10-20% for unknowns |
| New gem integration issues | Low | High | Test in staging first, have rollback plan |
| Deployment issues | Low | High | Use staging environment, gradual rollout |

## Definition of Done

### Story Level
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] All tests passing (unit + integration + system)
- [ ] RuboCop passing with 0 offenses
- [ ] Documentation updated (README, ADRs, inline comments)
- [ ] Deployed to staging and tested
- [ ] Product Owner acceptance

### Sprint Level
- [ ] All high-priority stories completed
- [ ] CI/CD pipeline live and enforcing
- [ ] Production deployment successful
- [ ] Monitoring and alerting configured
- [ ] Sprint retrospective completed
- [ ] Next sprint planned

## Sprint Ceremonies

### Daily Standups (15 minutes)
- What did I complete yesterday?
- What am I working on today?
- Any blockers or risks?

### Sprint Planning (2 hours)
- Review and refine backlog
- Estimate story points
- Commit to sprint goal
- Assign initial stories

### Sprint Review (1 hour)
- Demo completed features
- Gather stakeholder feedback
- Update product backlog

### Sprint Retrospective (1 hour)
- What went well?
- What could be improved?
- Action items for next sprint

## Technical Debt & Future Considerations

### Identified Technical Debt
1. **Calculator logic in controllers** - Addressed in Story 5.1
2. **No JavaScript tests** - Future sprint
3. **Letter Opener in production** - Already fixed (dev only)
4. **No PWA features** - Future sprint
5. **No mobile app** - Long-term roadmap

### Future Sprint Ideas
1. **Mobile PWA** - Service workers, offline mode, app manifest
2. **Customer accounts** - User registration, order history, wishlists
3. **Product recommendations** - "Customers also bought" algorithm
4. **Advanced inventory** - Low stock alerts, auto-reorder, stock history
5. **Multi-currency support** - USD, EUR alongside GBP
6. **Analytics dashboard** - Conversion funnel, traffic sources, revenue trends
7. **A/B testing framework** - Experiment with pricing, layouts
8. **Email marketing** - Newsletter, abandoned cart, promotions

## Appendix

### Useful Commands
```bash
# Start development server
bin/dev

# Run all tests
bin/rails test:all

# Run specific test
bin/rails test test/controllers/search_controller_test.rb

# Check code style
rubocop -a

# Build TypeScript
yarn build

# Database operations
bin/rails db:migrate
bin/rails db:rollback

# Rails console
bin/rails c

# Edit credentials
EDITOR="code --wait" rails credentials:edit

# Deploy to Render
git push origin main
```

### Reference Documentation
- [Rails 7.1 Guides](https://guides.rubyonrails.org/v7.1/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [PaperTrail Gem](https://github.com/paper-trail-gem/paper_trail)
- [PgSearch Gem](https://github.com/Casecommons/pg_search)
- [Honeybadger API](https://docs.honeybadger.io/ruby/)
- [Stripe Testing](https://stripe.com/docs/testing)

### Sprint Board Structure (GitHub Projects)
- **Backlog**: All unstarted stories
- **To Do**: Stories committed for this sprint
- **In Progress**: Currently being worked on
- **In Review**: Awaiting code review
- **Testing**: In QA/staging testing
- **Done**: Deployed and accepted

---

**Last Updated**: November 29, 2025
**Sprint Start**: November 29, 2025
**Sprint End**: December 13, 2025
