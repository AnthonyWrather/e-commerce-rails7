#!/bin/bash
# Sprint 02 - GitHub Issues Creation Script
# This script creates GitHub issues and a project board for Sprint 02

set -e  # Exit on error

REPO="AnthonyWrather/e-commerce-rails7"
PROJECT_NAME="Sprint 02 - Production Readiness"

echo "Creating Sprint 02 issues and project board for $REPO"
echo "=================================================="

# Check if gh CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "Error: Not authenticated with GitHub CLI"
    echo "Please run: gh auth login"
    exit 1
fi

# Note: Project board creation via CLI is limited
# Create issues first, then manually create project board via web UI
echo "Note: Issues will be created. Create project board manually at:"
echo "https://github.com/users/AnthonyWrather/projects/new"
echo ""

# Epic 1: Infrastructure & DevOps

echo "Creating Epic 1 issues..."

# Story 1.1: GitHub Actions CI/CD Pipeline
gh issue create \
  --repo "$REPO" \
  --title "[Infra 1.1] GitHub Actions CI/CD Pipeline" \
  --label "enhancement,infrastructure,priority-high,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: High
**Story Points**: 8

## Description
Implement automated CI/CD pipeline to run tests, linting, and security scans on all pull requests and deployments.

## Acceptance Criteria
- [ ] Tests run automatically on all PRs
- [ ] RuboCop linting enforced on PRs
- [ ] Brakeman security scanning included
- [ ] SimpleCov coverage report generated
- [ ] Failed CI blocks PR merging
- [ ] Green CI required for deployment

## Tasks
- [ ] Create \`.github/workflows/ci.yml\` workflow file
- [ ] Configure test job (Minitest + system tests)
- [ ] Configure lint job (RuboCop)
- [ ] Configure security scan job (Brakeman)
- [ ] Add coverage reporting (SimpleCov → CI artifacts)
- [ ] Configure branch protection rules
- [ ] Document CI/CD process in README

## Technical Notes
\`\`\`yaml
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
\`\`\`

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] All tests passing
- [ ] Documentation updated"

echo "Created issue: [Infra 1.1] GitHub Actions CI/CD Pipeline"

# Story 1.2: Error Tracking with Honeybadger
ISSUE_1_2=$(gh issue create \
  --repo "$REPO" \
  --title "Error Tracking with Honeybadger" \
  --label "enhancement,infrastructure,priority:high,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: High
**Story Points**: 5

## Description
Configure and enable Honeybadger error tracking (already in Gemfile) for production monitoring.

## Acceptance Criteria
- [ ] Honeybadger API key configured in credentials
- [ ] Error notifications sent to Honeybadger
- [ ] JavaScript errors tracked
- [ ] Performance metrics enabled
- [ ] Alert channels configured (email/Slack)
- [ ] Custom error pages with error ID display

## Tasks
- [ ] Add Honeybadger API key to Rails credentials
- [ ] Configure \`config/honeybadger.yml\` for production
- [ ] Add JavaScript error tracking to frontend
- [ ] Set up alert policies in Honeybadger dashboard
- [ ] Create custom error pages (500.html) with error ID
- [ ] Test error tracking in staging
- [ ] Document error handling procedures

## Technical Notes
\`\`\`ruby
# config/honeybadger.yml
api_key: <%= Rails.application.credentials.dig(:honeybadger, :api_key) %>
env: <%= Rails.env %>
report_data: true
\`\`\`

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Error tracking tested in staging
- [ ] Documentation complete" --format "%U")

echo "Created issue: $ISSUE_1_2"

# Story 1.3: Uptime Monitoring
ISSUE_1_3=$(gh issue create \
  --repo "$REPO" \
  --title "Uptime Monitoring Setup" \
  --label "enhancement,infrastructure,priority:medium,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: Medium
**Story Points**: 3

## Description
Set up external uptime monitoring to track availability and response times.

## Acceptance Criteria
- [ ] Uptime monitor configured (UptimeRobot or similar)
- [ ] Health check endpoint monitored
- [ ] Alert on downtime (>5 minutes)
- [ ] Response time tracking enabled
- [ ] SSL certificate expiry monitoring
- [ ] Monthly uptime report available

## Tasks
- [ ] Sign up for UptimeRobot or similar service
- [ ] Configure \`/up\` endpoint monitoring
- [ ] Set up alert contacts (email/SMS)
- [ ] Configure SSL certificate monitoring
- [ ] Create uptime status page (optional)
- [ ] Document monitoring setup

## Technical Notes
- Rails health check already exists at \`/up\`
- Monitor at 5-minute intervals
- Alert after 2 consecutive failures

## Definition of Done
- [ ] Monitoring active and alerting
- [ ] Documentation complete" --format "%U")

echo "Created issue: $ISSUE_1_3"

# Epic 2: User Experience

echo "Creating Epic 2 issues..."

# Story 2.1: Product Search Functionality
ISSUE_2_1=$(gh issue create \
  --repo "$REPO" \
  --title "Product Search Functionality" \
  --label "feature,ux,priority:high,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: High
**Story Points**: 13

## Description
Implement full-text product search using PostgreSQL pg_search gem to allow users to find products by name, description, and category.

## Acceptance Criteria
- [ ] Search box in navbar
- [ ] Full-text search across products (name, description, category)
- [ ] Search results page with filtering
- [ ] Search highlights matching terms
- [ ] Pagination on search results (Pagy)
- [ ] Empty state for no results
- [ ] Search query preserved in URL (bookmarkable)
- [ ] Tests for search functionality

## Tasks
- [ ] Add \`pg_search\` gem to Gemfile
- [ ] Create search scope in Product model
- [ ] Create \`SearchController\` and routes
- [ ] Add search form to navbar partial
- [ ] Create search results view with highlighting
- [ ] Implement pagination for results
- [ ] Add tests (unit + integration + system)
- [ ] Optimize search performance (indexes)
- [ ] Document search features

## Technical Notes
\`\`\`ruby
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
\`\`\`

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Tests passing with >85% coverage
- [ ] Search performance acceptable (<500ms)" --format "%U")

echo "Created issue: $ISSUE_2_1"

# Story 2.2: Server-Side Cart Persistence
ISSUE_2_2=$(gh issue create \
  --repo "$REPO" \
  --title "Server-Side Cart Persistence" \
  --label "feature,ux,priority:high,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: High
**Story Points**: 13

## Description
Add optional cart persistence to database for better UX and cross-device support, while maintaining localStorage fallback for guests.

## Acceptance Criteria
- [ ] Cart model with has_many :cart_items
- [ ] Database migration for carts and cart_items tables
- [ ] Sync localStorage cart to database on user action
- [ ] Cart expiry after 30 days of inactivity
- [ ] Price refresh on cart load (prevent stale prices)
- [ ] Merge carts when user returns
- [ ] Tests for cart persistence logic

## Tasks
- [ ] Create Cart and CartItem models
- [ ] Generate migration (carts, cart_items tables)
- [ ] Add cart persistence service object
- [ ] Update cart_controller.ts to sync with server
- [ ] Implement cart merge logic (localStorage + database)
- [ ] Add cart expiry background job (optional)
- [ ] Update checkout flow to use persisted cart
- [ ] Add tests (model + controller + system)
- [ ] Document cart persistence strategy

## Technical Notes
\`\`\`ruby
# app/models/cart.rb
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  scope :expired, -> { where('updated_at < ?', 30.days.ago) }
end
\`\`\`

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Cart merge logic tested
- [ ] Documentation complete" --format "%U")

echo "Created issue: $ISSUE_2_2"

# Story 2.3: Product Sorting and Advanced Filtering
ISSUE_2_3=$(gh issue create \
  --repo "$REPO" \
  --title "Product Sorting and Advanced Filtering" \
  --label "feature,ux,priority:medium,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: Medium
**Story Points**: 8

## Description
Add sorting options (name, price, newest) and additional filters (material type, fiberglass reinforcement) to category pages.

## Acceptance Criteria
- [ ] Sort by: Name (A-Z, Z-A), Price (Low-High, High-Low), Newest
- [ ] Filter by: Fiberglass reinforcement (yes/no)
- [ ] Filter by: Weight range, Size availability
- [ ] Filters persist in URL (bookmarkable)
- [ ] Clear filters button
- [ ] Product count displayed
- [ ] Tests for sorting and filtering

## Tasks
- [ ] Add sort parameter to CategoriesController
- [ ] Implement sorting logic with scopes
- [ ] Add fiberglass filter checkbox
- [ ] Add weight range filter
- [ ] Update category view with sort/filter UI
- [ ] Preserve filters in pagination links
- [ ] Add tests (controller + system)
- [ ] Document filtering API

## Technical Notes
\`\`\`ruby
scope :sorted_by, ->(sort) {
  case sort
  when 'name_asc' then order(name: :asc)
  when 'price_asc' then order(price: :asc)
  end
}
\`\`\`

## Definition of Done
- [ ] All sorting/filtering options working
- [ ] Tests passing
- [ ] Documentation updated" --format "%U")

echo "Created issue: $ISSUE_2_3"

# Epic 3: Security

echo "Creating Epic 3 issues..."

# Story 3.1: Two-Factor Authentication
ISSUE_3_1=$(gh issue create \
  --repo "$REPO" \
  --title "Two-Factor Authentication for Admin" \
  --label "security,priority:high,sprint-02" \
  --body "**Epic**: Security
**Priority**: High
**Story Points**: 13

## Description
Implement 2FA/MFA for admin users using devise-two-factor gem with TOTP (Time-based One-Time Password) support.

## Acceptance Criteria
- [ ] 2FA setup page with QR code
- [ ] TOTP verification on login
- [ ] Backup codes generated (10 codes)
- [ ] Backup code usage tracking
- [ ] 2FA required for all admin users
- [ ] 2FA disable requires password confirmation
- [ ] Tests for 2FA flow

## Tasks
- [ ] Add \`devise-two-factor\` and \`rqrcode\` gems
- [ ] Generate migration for 2FA fields
- [ ] Create 2FA setup controller/views
- [ ] Generate QR codes for authenticator apps
- [ ] Implement backup code generation
- [ ] Update login flow to request TOTP
- [ ] Add 2FA management in admin profile
- [ ] Add tests (unit + integration + system)
- [ ] Document 2FA setup for admins

## Security Impact
- Prevents unauthorized admin access even if password is compromised
- Meets industry standard for admin security

## Definition of Done
- [ ] All admin users have 2FA enabled
- [ ] Tests passing
- [ ] Documentation complete" --format "%U")

echo "Created issue: $ISSUE_3_1"

# Story 3.2: Admin Audit Logging
ISSUE_3_2=$(gh issue create \
  --repo "$REPO" \
  --title "Admin Audit Logging with PaperTrail" \
  --label "security,priority:medium,sprint-02" \
  --body "**Epic**: Security
**Priority**: Medium
**Story Points**: 8

## Description
Implement audit trail for admin actions using PaperTrail gem to track who did what and when.

## Acceptance Criteria
- [ ] Track all admin CRUD operations (products, categories, orders, stocks)
- [ ] Store user ID, action type, timestamp
- [ ] Store before/after values for updates
- [ ] Admin audit log page (filterable by user, date, action)
- [ ] Export audit log to CSV
- [ ] 90-day retention policy
- [ ] Tests for audit logging

## Tasks
- [ ] Add \`paper_trail\` gem to Gemfile
- [ ] Generate PaperTrail migration
- [ ] Enable versioning on models (Product, Category, Order, Stock)
- [ ] Create Admin::AuditLogsController
- [ ] Create audit log view with filters
- [ ] Add CSV export functionality
- [ ] Configure retention policy (auto-delete old versions)
- [ ] Add tests (model + controller)
- [ ] Document audit log access

## Compliance Impact
- Supports compliance requirements (SOX, GDPR)
- Provides accountability for admin actions

## Definition of Done
- [ ] All admin actions tracked
- [ ] Audit log accessible and filterable
- [ ] Tests passing" --format "%U")

echo "Created issue: $ISSUE_3_2"

# Story 3.3: Content Security Policy
ISSUE_3_3=$(gh issue create \
  --repo "$REPO" \
  --title "Content Security Policy (CSP) Headers" \
  --label "security,priority:medium,sprint-02" \
  --body "**Epic**: Security
**Priority**: Medium
**Story Points**: 5

## Description
Implement Content Security Policy headers to prevent XSS attacks and improve security posture.

## Acceptance Criteria
- [ ] CSP headers configured in production
- [ ] Allow inline styles for Tailwind (nonce-based)
- [ ] Allow Stripe JavaScript SDK
- [ ] Allow Google Analytics (if enabled)
- [ ] Report-only mode initially
- [ ] Monitor CSP violations
- [ ] Enforce mode after validation

## Tasks
- [ ] Configure CSP in \`config/initializers/content_security_policy.rb\`
- [ ] Add nonce support for inline scripts
- [ ] Whitelist external domains (Stripe, GA)
- [ ] Test CSP in staging (report-only mode)
- [ ] Set up CSP violation reporting endpoint
- [ ] Switch to enforce mode
- [ ] Add tests for CSP headers
- [ ] Document CSP policy

## Security Impact
- Prevents XSS attacks
- Improves overall security score

## Definition of Done
- [ ] CSP headers enforced in production
- [ ] No CSP violations reported
- [ ] Documentation complete" --format "%U")

echo "Created issue: $ISSUE_3_3"

# Epic 4: Performance

echo "Creating Epic 4 issues..."

# Story 4.1: Redis Caching
ISSUE_4_1=$(gh issue create \
  --repo "$REPO" \
  --title "Redis Caching Layer Implementation" \
  --label "performance,priority:medium,sprint-02" \
  --body "**Epic**: Performance
**Priority**: Medium
**Story Points**: 8

## Description
Implement Redis-based caching for frequently accessed data (products, categories, dashboard stats).

## Acceptance Criteria
- [ ] Redis configured in production
- [ ] Fragment caching for product cards
- [ ] Russian Doll caching for categories
- [ ] Dashboard stats cached (5-minute TTL)
- [ ] Cache invalidation on model updates
- [ ] Cache hit rate monitoring
- [ ] Tests for caching logic

## Tasks
- [ ] Add Redis to Render.com services
- [ ] Configure Rails cache store (Redis)
- [ ] Add fragment caching to product partials
- [ ] Implement Russian Doll caching for categories
- [ ] Cache dashboard aggregations
- [ ] Add cache invalidation callbacks
- [ ] Monitor cache performance (hit rate)
- [ ] Add tests for cache invalidation
- [ ] Document caching strategy

## Performance Impact
- Expected 50-70% reduction in database queries
- Faster page load times for product/category pages

## Definition of Done
- [ ] Cache hit rate >80%
- [ ] Page load time improved
- [ ] Tests passing" --format "%U")

echo "Created issue: $ISSUE_4_1"

# Story 4.2: Asset Optimization
ISSUE_4_2=$(gh issue create \
  --repo "$REPO" \
  --title "Asset Optimization & CDN Integration" \
  --label "performance,priority:medium,sprint-02" \
  --body "**Epic**: Performance
**Priority**: Medium
**Story Points**: 8

## Description
Optimize asset delivery with compression, modern image formats, and optional CDN integration.

## Acceptance Criteria
- [ ] Gzip/Brotli compression enabled
- [ ] JavaScript bundle size reduced (<400KB)
- [ ] WebP images generated for products
- [ ] Lazy loading for product images
- [ ] Font loading optimized (font-display: swap)
- [ ] CDN configured (optional: Cloudflare)
- [ ] Lighthouse score >90 for performance

## Tasks
- [ ] Enable Brotli compression in Puma/Nginx
- [ ] Analyze JavaScript bundle (source-map-explorer)
- [ ] Add WebP variant generation (Active Storage)
- [ ] Implement lazy loading for images
- [ ] Optimize font loading strategy
- [ ] Configure Cloudflare CDN (optional)
- [ ] Run Lighthouse audit and fix issues
- [ ] Add performance budget to CI
- [ ] Document asset optimization

## Performance Impact
- 40-60% reduction in initial page load size
- Faster Time to Interactive (TTI)

## Definition of Done
- [ ] Lighthouse score >90
- [ ] JavaScript bundle <400KB
- [ ] WebP images working" --format "%U")

echo "Created issue: $ISSUE_4_2"

# Epic 5: Code Quality

echo "Creating Epic 5 issues..."

# Story 5.1: Refactor Calculators
ISSUE_5_1=$(gh issue create \
  --repo "$REPO" \
  --title "Refactor Calculator Logic to Service Objects" \
  --label "refactor,code-quality,priority:medium,sprint-02" \
  --body "**Epic**: Code Quality
**Priority**: Medium
**Story Points**: 13

## Description
Extract calculator business logic from controllers to service objects for better testability and maintainability.

## Acceptance Criteria
- [ ] QuantityCalculatorService class created
- [ ] Constants extracted to module (material_width, ratio, wastage)
- [ ] Three calculator methods (area, dimensions, mould)
- [ ] Controllers use service objects
- [ ] Unit tests for service objects
- [ ] Integration tests still pass
- [ ] Documentation updated

## Tasks
- [ ] Create \`app/services/\` directory
- [ ] Create \`QuantityCalculatorService\` class
- [ ] Extract constants to \`QuantityCalculatorService::Constants\`
- [ ] Implement \`calculate_area\` method
- [ ] Implement \`calculate_dimensions\` method
- [ ] Implement \`calculate_mould_rectangle\` method
- [ ] Update Quantities controllers to use service
- [ ] Write unit tests for service methods
- [ ] Verify integration tests pass
- [ ] Update documentation

## Code Quality Impact
- Improved testability (unit tests for business logic)
- Better separation of concerns
- Easier to maintain and extend

## Definition of Done
- [ ] All tests passing (including new service tests)
- [ ] Controllers simplified
- [ ] Documentation updated" --format "%U")

echo "Created issue: $ISSUE_5_1"

# Story 5.2: Improve Test Coverage
ISSUE_5_2=$(gh issue create \
  --repo "$REPO" \
  --title "Improve Test Coverage for Critical Paths" \
  --label "testing,code-quality,priority:medium,sprint-02" \
  --body "**Epic**: Code Quality
**Priority**: Medium
**Story Points**: 8

## Description
Increase test coverage for critical integration paths and edge cases.

## Acceptance Criteria
- [ ] CheckoutsController#create unit tests added
- [ ] End-to-end checkout integration test
- [ ] Stripe webhook edge case tests
- [ ] Cart merge scenario tests
- [ ] Coverage maintained above 85%
- [ ] All critical paths have integration tests

## Tasks
- [ ] Add CheckoutsController#create unit tests (Stripe mocking)
- [ ] Add end-to-end checkout integration test
- [ ] Add Stripe webhook edge case tests (duplicate events, invalid data)
- [ ] Add cart merge tests (localStorage + database)
- [ ] Add search edge case tests
- [ ] Run SimpleCov and verify coverage
- [ ] Document testing strategy

## Quality Impact
- Higher confidence in critical payment flow
- Better edge case handling
- Easier to catch regressions

## Definition of Done
- [ ] Coverage >85%
- [ ] All critical paths tested
- [ ] Edge cases documented" --format "%U")

echo "Created issue: $ISSUE_5_2"

echo ""
echo "=================================================="
echo "✅ Created 15 issues for Sprint 02"
echo "✅ Created project board: $PROJECT_NAME"
echo ""
echo "View issues: gh issue list --repo $REPO --label sprint-02"
echo "View project: gh project view $PROJECT_ID"
echo ""
echo "Next steps:"
echo "1. Review and prioritize issues"
echo "2. Assign team members"
echo "3. Start sprint planning meeting"
