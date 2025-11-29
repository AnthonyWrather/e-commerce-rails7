#!/bin/bash
# Sprint 02 - GitHub Issues Creation Script (Simplified)

set -e
REPO="AnthonyWrather/e-commerce-rails7"

echo "Creating Sprint 02 issues for $REPO"
echo "======================================"

# Epic 1: Infrastructure

echo ""
echo "[1/14] Creating: GitHub Actions CI/CD Pipeline..."
gh issue create --repo "$REPO" \
  --title "[Infra 1.1] GitHub Actions CI/CD Pipeline" \
  --label "enhancement,infrastructure,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: High
**Story Points**: 8

## Description
Implement automated CI/CD pipeline to run tests, linting, and security scans on all pull requests.

## Acceptance Criteria
- [ ] Tests run automatically on all PRs
- [ ] RuboCop linting enforced on PRs
- [ ] Brakeman security scanning included
- [ ] SimpleCov coverage report generated
- [ ] Failed CI blocks PR merging

## Tasks
- [ ] Create .github/workflows/ci.yml
- [ ] Configure test job (Minitest + system tests)
- [ ] Configure lint job (RuboCop)
- [ ] Configure security scan (Brakeman)
- [ ] Add coverage reporting
- [ ] Configure branch protection
- [ ] Document CI/CD process"

echo "[2/14] Creating: Honeybadger Error Tracking..."
gh issue create --repo "$REPO" \
  --title "[Infra 1.2] Error Tracking with Honeybadger" \
  --label "enhancement,infrastructure,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: High
**Story Points**: 5

## Description
Configure Honeybadger error tracking (already in Gemfile) for production monitoring.

## Acceptance Criteria
- [ ] Honeybadger API key configured
- [ ] Error notifications sent to Honeybadger
- [ ] JavaScript errors tracked
- [ ] Alert channels configured
- [ ] Custom error pages with error ID

## Tasks
- [ ] Add API key to Rails credentials
- [ ] Configure config/honeybadger.yml
- [ ] Add JavaScript error tracking
- [ ] Set up alert policies
- [ ] Create custom error pages
- [ ] Test in staging
- [ ] Document error handling"

echo "[3/14] Creating: Uptime Monitoring..."
gh issue create --repo "$REPO" \
  --title "[Infra 1.3] Uptime Monitoring Setup" \
  --label "enhancement,infrastructure,sprint-02" \
  --body "**Epic**: Infrastructure & DevOps
**Priority**: Medium
**Story Points**: 3

## Description
Set up external uptime monitoring to track availability and response times.

## Acceptance Criteria
- [ ] Uptime monitor configured (UptimeRobot)
- [ ] /up endpoint monitored
- [ ] Alert on downtime >5 minutes
- [ ] Response time tracking
- [ ] SSL certificate monitoring

## Tasks
- [ ] Sign up for UptimeRobot
- [ ] Configure /up endpoint monitoring
- [ ] Set up alert contacts
- [ ] Configure SSL monitoring
- [ ] Document monitoring setup"

# Epic 2: User Experience

echo "[4/14] Creating: Product Search..."
gh issue create --repo "$REPO" \
  --title "[UX 2.1] Product Search Functionality" \
  --label "feature,ux,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: High
**Story Points**: 13

## Description
Implement full-text product search using PostgreSQL pg_search gem.

## Acceptance Criteria
- [ ] Search box in navbar
- [ ] Full-text search (name, description, category)
- [ ] Search results page with filtering
- [ ] Search highlights matching terms
- [ ] Pagination on results
- [ ] Empty state for no results
- [ ] Search query in URL (bookmarkable)
- [ ] Tests for search functionality

## Tasks
- [ ] Add pg_search gem
- [ ] Create search scope in Product model
- [ ] Create SearchController and routes
- [ ] Add search form to navbar
- [ ] Create search results view
- [ ] Implement pagination
- [ ] Add tests (unit + integration + system)
- [ ] Optimize search performance
- [ ] Document search features"

echo "[5/14] Creating: Cart Persistence..."
gh issue create --repo "$REPO" \
  --title "[UX 2.2] Server-Side Cart Persistence" \
  --label "feature,ux,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: High
**Story Points**: 13

## Description
Add optional cart persistence to database for cross-device support.

## Acceptance Criteria
- [ ] Cart model with has_many :cart_items
- [ ] Database migration for carts/cart_items
- [ ] Sync localStorage to database
- [ ] Cart expiry after 30 days
- [ ] Price refresh on cart load
- [ ] Merge carts when user returns
- [ ] Tests for cart persistence

## Tasks
- [ ] Create Cart and CartItem models
- [ ] Generate migrations
- [ ] Add cart persistence service
- [ ] Update cart_controller.ts
- [ ] Implement cart merge logic
- [ ] Add cart expiry background job
- [ ] Update checkout flow
- [ ] Add tests
- [ ] Document cart strategy"

echo "[6/14] Creating: Sorting & Filtering..."
gh issue create --repo "$REPO" \
  --title "[UX 2.3] Product Sorting and Filtering" \
  --label "feature,ux,sprint-02" \
  --body "**Epic**: User Experience
**Priority**: Medium
**Story Points**: 8

## Description
Add sorting and filtering options to category pages.

## Acceptance Criteria
- [ ] Sort by: Name (A-Z, Z-A), Price, Newest
- [ ] Filter by: Fiberglass reinforcement
- [ ] Filter by: Weight range, Size
- [ ] Filters persist in URL
- [ ] Clear filters button
- [ ] Product count displayed
- [ ] Tests for sorting/filtering

## Tasks
- [ ] Add sort parameter to controller
- [ ] Implement sorting scopes
- [ ] Add fiberglass filter
- [ ] Add weight range filter
- [ ] Update category view UI
- [ ] Preserve filters in pagination
- [ ] Add tests
- [ ] Document filtering API"

# Epic 3: Security

echo "[7/14] Creating: Two-Factor Authentication..."
gh issue create --repo "$REPO" \
  --title "[Security 3.1] Two-Factor Authentication for Admin" \
  --label "security,sprint-02" \
  --body "**Epic**: Security
**Priority**: High
**Story Points**: 13

## Description
Implement 2FA for admin users using devise-two-factor with TOTP.

## Acceptance Criteria
- [ ] 2FA setup page with QR code
- [ ] TOTP verification on login
- [ ] Backup codes generated (10 codes)
- [ ] 2FA required for all admins
- [ ] 2FA disable requires password
- [ ] Tests for 2FA flow

## Tasks
- [ ] Add devise-two-factor and rqrcode gems
- [ ] Generate migration for 2FA fields
- [ ] Create 2FA setup controller/views
- [ ] Generate QR codes
- [ ] Implement backup codes
- [ ] Update login flow
- [ ] Add 2FA management
- [ ] Add tests
- [ ] Document 2FA setup"

echo "[8/14] Creating: Audit Logging..."
gh issue create --repo "$REPO" \
  --title "[Security 3.2] Admin Audit Logging with PaperTrail" \
  --label "security,sprint-02" \
  --body "**Epic**: Security
**Priority**: Medium
**Story Points**: 8

## Description
Implement audit trail for admin actions using PaperTrail.

## Acceptance Criteria
- [ ] Track all admin CRUD operations
- [ ] Store user ID, action, timestamp
- [ ] Store before/after values
- [ ] Admin audit log page (filterable)
- [ ] Export audit log to CSV
- [ ] 90-day retention policy
- [ ] Tests for audit logging

## Tasks
- [ ] Add paper_trail gem
- [ ] Generate migration
- [ ] Enable versioning on models
- [ ] Create Admin::AuditLogsController
- [ ] Create audit log view
- [ ] Add CSV export
- [ ] Configure retention policy
- [ ] Add tests
- [ ] Document audit log access"

echo "[9/14] Creating: Content Security Policy..."
gh issue create --repo "$REPO" \
  --title "[Security 3.3] Content Security Policy Headers" \
  --label "security,sprint-02" \
  --body "**Epic**: Security
**Priority**: Medium
**Story Points**: 5

## Description
Implement CSP headers to prevent XSS attacks.

## Acceptance Criteria
- [ ] CSP headers configured
- [ ] Allow inline styles (nonce-based)
- [ ] Allow Stripe JavaScript SDK
- [ ] Allow Google Analytics
- [ ] Report-only mode initially
- [ ] Monitor CSP violations
- [ ] Enforce mode after validation

## Tasks
- [ ] Configure CSP initializer
- [ ] Add nonce support
- [ ] Whitelist external domains
- [ ] Test in staging (report-only)
- [ ] Set up violation reporting
- [ ] Switch to enforce mode
- [ ] Add tests for CSP headers
- [ ] Document CSP policy"

# Epic 4: Performance

echo "[10/14] Creating: Redis Caching..."
gh issue create --repo "$REPO" \
  --title "[Performance 4.1] Redis Caching Layer" \
  --label "performance,sprint-02" \
  --body "**Epic**: Performance
**Priority**: Medium
**Story Points**: 8

## Description
Implement Redis-based caching for frequently accessed data.

## Acceptance Criteria
- [ ] Redis configured in production
- [ ] Fragment caching for products
- [ ] Russian Doll caching for categories
- [ ] Dashboard stats cached (5-min TTL)
- [ ] Cache invalidation on updates
- [ ] Cache hit rate monitoring
- [ ] Tests for caching logic

## Tasks
- [ ] Add Redis to Render services
- [ ] Configure Rails cache store
- [ ] Add fragment caching
- [ ] Implement Russian Doll caching
- [ ] Cache dashboard aggregations
- [ ] Add cache invalidation callbacks
- [ ] Monitor cache performance
- [ ] Add tests
- [ ] Document caching strategy"

echo "[11/14] Creating: Asset Optimization..."
gh issue create --repo "$REPO" \
  --title "[Performance 4.2] Asset Optimization & CDN" \
  --label "performance,sprint-02" \
  --body "**Epic**: Performance
**Priority**: Medium
**Story Points**: 8

## Description
Optimize asset delivery with compression and modern formats.

## Acceptance Criteria
- [ ] Gzip/Brotli compression enabled
- [ ] JavaScript bundle <400KB
- [ ] WebP images generated
- [ ] Lazy loading for images
- [ ] Font loading optimized
- [ ] CDN configured (optional)
- [ ] Lighthouse score >90

## Tasks
- [ ] Enable Brotli compression
- [ ] Analyze JavaScript bundle
- [ ] Add WebP variant generation
- [ ] Implement lazy loading
- [ ] Optimize font loading
- [ ] Configure Cloudflare CDN
- [ ] Run Lighthouse audit
- [ ] Add performance budget to CI
- [ ] Document optimizations"

# Epic 5: Code Quality

echo "[12/14] Creating: Refactor Calculators..."
gh issue create --repo "$REPO" \
  --title "[Quality 5.1] Refactor Calculator Logic to Services" \
  --label "refactor,code-quality,sprint-02" \
  --body "**Epic**: Code Quality
**Priority**: Medium
**Story Points**: 13

## Description
Extract calculator logic from controllers to service objects.

## Acceptance Criteria
- [ ] QuantityCalculatorService created
- [ ] Constants extracted to module
- [ ] Three calculator methods (area, dimensions, mould)
- [ ] Controllers use service objects
- [ ] Unit tests for service objects
- [ ] Integration tests pass
- [ ] Documentation updated

## Tasks
- [ ] Create app/services/ directory
- [ ] Create QuantityCalculatorService
- [ ] Extract constants module
- [ ] Implement calculate_area method
- [ ] Implement calculate_dimensions
- [ ] Implement calculate_mould_rectangle
- [ ] Update controllers to use service
- [ ] Write unit tests
- [ ] Verify integration tests
- [ ] Update documentation"

echo "[13/14] Creating: Test Coverage..."
gh issue create --repo "$REPO" \
  --title "[Quality 5.2] Improve Test Coverage" \
  --label "testing,code-quality,sprint-02" \
  --body "**Epic**: Code Quality
**Priority**: Medium
**Story Points**: 8

## Description
Increase test coverage for critical integration paths.

## Acceptance Criteria
- [ ] CheckoutsController#create unit tests
- [ ] End-to-end checkout integration test
- [ ] Stripe webhook edge case tests
- [ ] Cart merge scenario tests
- [ ] Coverage maintained >85%
- [ ] All critical paths tested

## Tasks
- [ ] Add CheckoutsController unit tests
- [ ] Add E2E checkout integration test
- [ ] Add webhook edge case tests
- [ ] Add cart merge tests
- [ ] Add search edge case tests
- [ ] Run SimpleCov and verify coverage
- [ ] Document testing strategy"

echo "[14/14] Creating: Documentation Epic..."
gh issue create --repo "$REPO" \
  --title "[Meta] Sprint 02 - Production Readiness Planning" \
  --label "documentation,sprint-02" \
  --body "**Sprint**: 02 - Production Readiness & UX
**Duration**: Nov 29 - Dec 13, 2025
**Story Points**: 90 total (14 stories)

## Sprint Goals
1. ✅ Automated CI/CD with testing and security scanning
2. ✅ Production error tracking and monitoring
3. ✅ Enhanced user experience (search, cart persistence, filtering)
4. ✅ Security hardening (2FA, audit logging, CSP)
5. ✅ Performance optimization (caching, asset optimization)
6. ✅ Code quality improvements (service objects, test coverage)

## Epic Breakdown
- **Epic 1: Infrastructure** (3 stories, 16 points)
- **Epic 2: User Experience** (3 stories, 34 points)
- **Epic 3: Security** (3 stories, 26 points)
- **Epic 4: Performance** (2 stories, 16 points)
- **Epic 5: Code Quality** (2 stories, 21 points)

## Resources
- Sprint Plan: \`documentation.scratch/sprint-plan-02.md\`
- Codebase Analysis: \`documentation/codebase-analysis.md\`
- Test Analysis: \`documentation/test-analysis.md\`

## Success Criteria
- [ ] 70-80 story points completed
- [ ] All critical user stories delivered
- [ ] Test coverage maintained >85%
- [ ] Zero high-priority security issues
- [ ] Lighthouse performance score >90

## Sprint Ceremonies
- **Daily Standups**: 9:30 AM (15 min)
- **Sprint Review**: Dec 12, 2025
- **Sprint Retrospective**: Dec 13, 2025"

echo ""
echo "======================================"
echo "✅ Created 14 issues for Sprint 02"
echo ""
echo "View all issues:"
echo "  gh issue list --repo $REPO --label sprint-02"
echo ""
echo "Or visit:"
echo "  https://github.com/$REPO/issues?q=is%3Aissue+is%3Aopen+label%3Asprint-02"
echo ""
echo "Next steps:"
echo "1. Create project board at: https://github.com/users/AnthonyWrather/projects/new"
echo "2. Add sprint-02 labeled issues to the board"
echo "3. Organize into columns: Backlog, To Do, In Progress, Review, Testing, Done"
echo "4. Start sprint planning meeting!"
