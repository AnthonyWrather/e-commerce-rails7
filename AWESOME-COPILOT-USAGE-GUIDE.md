# Awesome Copilot Collections - Usage Guide

## 📦 Installed Collections

This workspace has **21 AI workflow automation files** installed from the [github/awesome-copilot](https://github.com/github/awesome-copilot) repository:

### 1. Project Planning & Management (17 items)

**Agents** (11 files):
- `task-planner.agent.md` - Research validation → 3-file planning workflow
- `task-researcher.agent.md` - Research-only specialist mode
- `planner.agent.md` - Simple planning mode
- `plan.agent.md` - Strategic planning and architecture
- `prd.agent.md` - Product Requirements Document creation
- `implementation-plan.agent.md` - AI-to-AI planning mode
- `research-technical-spike.agent.md` - Spike validation and research
- `tdd-red.agent.md` - Write failing tests (RED phase)
- `tdd-green.agent.md` - Minimal implementation (GREEN phase)
- `tdd-refactor.agent.md` - Quality & security improvements (REFACTOR phase)
- `playwright-tester.agent.md` - E2E test generation

**Instructions** (2 files):
- `task-implementation.instructions.md` - Progressive task tracking
- `spec-driven-workflow-v1.instructions.md` - 6-phase ANALYZE-DESIGN-IMPLEMENT-VALIDATE-REFLECT-HANDOFF workflow

**Prompts** (8 files):
- `breakdown-feature-implementation.prompt.md` - Feature implementation plans
- `breakdown-feature-prd.prompt.md` - Feature PRD based on Epic
- `breakdown-epic-arch.prompt.md` - Epic architecture specification
- `breakdown-epic-pm.prompt.md` - Epic PRD creation
- `create-implementation-plan.prompt.md` - New plan creation
- `update-implementation-plan.prompt.md` - Plan updates
- `create-github-issues-feature-from-implementation-plan.prompt.md` - GitHub issue automation
- `create-technical-spike.prompt.md` - Technical spike documents

---

## 🚀 Quick Start

### Agent Invocation

Use `@workspace` with agent names:

```
@workspace /task-planner
@workspace /tdd-red
@workspace /implementation-plan
```

### Prompt Usage

Use `#` with prompt names:

```
#breakdown-epic-pm
#breakdown-feature-prd
#create-implementation-plan
```

---

## 📖 Workflow Examples for Rails E-Commerce

### Example 1: WebhooksController Testing (Gap from codebase-analysis.md)

**Gap**: WebhooksController has no tests, critical for payment processing reliability

**Complete TDD Workflow**:

```bash
# 1. Research Stripe webhook testing patterns
@workspace /task-researcher

Context: Research best practices for testing Stripe webhook controllers in Rails applications, including signature verification, event handling, and idempotency

# 2. Plan implementation with research validation
@workspace /task-planner

Context: Create plan to add comprehensive tests for WebhooksController including:
- Stripe signature verification tests
- Event type handling (checkout.session.completed)
- Order creation and stock decrement validation
- Idempotency checks
- Email sending verification

# 3. Write failing test (RED phase)
@workspace /tdd-red

Context: Write failing test for WebhooksController#stripe that verifies:
- Valid Stripe signature acceptance
- Invalid signature rejection
- Event: checkout.session.completed creates Order
- Stock decremented correctly
- Email sent to customer

# 4. Minimal implementation (GREEN phase)
@workspace /tdd-green

Context: Implement WebhooksController test setup:
- Stripe webhook signature mocking
- Test fixtures for checkout.session.completed event
- Test database setup and teardown

# 5. Refactor for quality (REFACTOR phase)
@workspace /tdd-refactor

Context: Extract webhook handling to WebhookProcessor service object following pattern in TaxCalculator and VatCalculator. Add security hardening:
- Rate limiting for webhook endpoint
- Webhook event logging
- Dead letter queue for failed events
```

**Expected Outputs**:
- `.copilot-tracking/research/YYYYMMDD-stripe-webhook-testing-research.md` (research findings)
- `.copilot-tracking/plans/YYYYMMDD-webhooks-controller-tests-plan.instructions.md` (implementation plan)
- `.copilot-tracking/details/YYYYMMDD-webhooks-controller-tests-details.md` (task details)
- `.copilot-tracking/prompts/implement-webhooks-controller-tests.prompt.md` (execution prompt)
- `test/controllers/webhooks_controller_test.rb` (new test file)
- `app/services/webhook_processor.rb` (new service object)
- `.copilot-tracking/changes/YYYYMMDD-webhooks-controller-tests-changes.md` (implementation log)

---

### Example 2: Cart Persistence Feature (Gap from codebase-analysis.md)

**Gap**: Cart data stored only in localStorage, lost on device change

**Epic-to-Story Workflow**:

```bash
# 1. Create Epic PRD
#breakdown-epic-pm

Context:
- Epic name: checkout-improvements
- Business problem: Users lose cart when switching devices, leading to abandoned purchases
- Target users: Returning customers, mobile-first shoppers
- Success metrics: 20% increase in cart retention, 15% increase in conversion

# 2. Define Epic Architecture
#breakdown-epic-arch

Context:
- Epic: checkout-improvements
- Epic PRD: /docs/ways-of-work/plan/checkout-improvements/epic.md
- Technical requirements: Session management, Redis caching, database persistence
- Scale: Support 1000 concurrent carts

# 3. Break down into Features
#breakdown-feature-prd

Context:
- Epic: checkout-improvements
- Feature: cart-persistence
- Requirements: Store cart server-side, sync across devices, maintain for 30 days

# 4. Technical Implementation Plan
#breakdown-feature-implementation

Context:
- Epic: checkout-improvements
- Feature: cart-persistence
- PRD Location: /docs/ways-of-work/plan/checkout-improvements/cart-persistence/prd.md

# 5. Create GitHub Issues with automation
#create-github-issues-feature-from-implementation-plan

Context:
Implementation plan: /docs/ways-of-work/plan/checkout-improvements/cart-persistence/implementation-plan.md
```

**GitHub Issues Created**:
- **Epic Issue**: "Checkout Improvements" (milestone: Q2 2025)
- **Feature Issue**: "Cart Persistence" (linked to Epic)
- **User Story 1**: "As a returning user, I want my cart saved when I log in"
- **User Story 2**: "As a mobile user, I want to start cart on phone and complete on desktop"
- **Technical Enabler 1**: "Redis session store configuration"
- **Technical Enabler 2**: "Cart model and database migration"

**Directory Structure Created**:
```
docs/ways-of-work/plan/
  checkout-improvements/
    epic.md                              # Epic PRD
    arch.md                              # System architecture
    cart-persistence/
      prd.md                             # Feature requirements
      implementation-plan.md             # Technical plan
      project-plan.md                    # GitHub project setup
      issues-checklist.md                # Issue creation checklist
```

---

### Example 3: Technical Spike for Redis vs Database Session Storage

**Use Case**: Validate technical approach before implementing cart persistence

```bash
# 1. Create technical spike document
#create-technical-spike

Inputs:
- Spike Title: "Session Storage Strategy for Multi-Device Cart Persistence"
- Category: "Architecture"
- Priority: "High"
- Timebox: "3 days"
- Owner: "Backend Team"
- Folder Path: "docs/spikes"

# 2. Research and validate spike using agent
@workspace /research-technical-spike

Context:
Spike document: docs/spikes/architecture-session-storage-strategy-spike.md

Key questions to answer:
1. Redis vs PostgreSQL for session storage (performance comparison)
2. Session expiration strategy (30 days idle vs active management)
3. Multi-device sync approach (polling vs WebSockets vs SSE)
4. Cost implications (Redis pricing vs database row count)
5. Migration strategy from localStorage to server-side storage
```

**Agent Workflow**:
1. **Parse spike document** using `#codebase`
2. **Research Redis session stores** using `#search` and `#fetch` (ActionDispatch::Session::RedisStore, redis-session-store gem)
3. **Benchmark PostgreSQL session table** using `#runCommands` (create test table, measure query performance)
4. **Research existing Rails patterns** using `#codebase` (Devise session storage, ActionDispatch)
5. **Update spike document** continuously with findings in "Investigation Results" section
6. **Create prototype** (with permission) using `#edit` to test Redis session integration
7. **Document recommendation** in spike "Decision" section with clear rationale

**Output**: `docs/spikes/architecture-session-storage-strategy-spike.md` with:
- Investigation results (Redis: 1ms avg, PostgreSQL: 15ms avg)
- Recommendation: Redis for active sessions (<24h), PostgreSQL for long-term (>24h)
- Implementation notes: Use ActionDispatch::Session::CacheStore with Redis backend
- Cost analysis: Redis $30/mo for 1000 concurrent users
- Migration strategy: 3-phase rollout with feature flag

---

### Example 4: Admin MFA Implementation (Security Gap)

**Gap**: Admin authentication lacks two-factor authentication (security risk)

**Spec-Driven Workflow** (6-phase ANALYZE-DESIGN-IMPLEMENT-VALIDATE-REFLECT-HANDOFF):

```bash
# Phase 1: ANALYZE
# Create Epic PRD with comprehensive requirements analysis
#breakdown-epic-pm

Context:
- Epic: admin-mfa
- Problem: Admin accounts vulnerable to credential compromise
- Compliance: SOC 2 requires MFA for privileged access
- Users: AdminUser model (Devise-based)

Output: docs/ways-of-work/admin-mfa/epic.md
EARS Requirements:
- REQ-001 (Ubiquitous): System shall require TOTP code after password verification
- REQ-002 (Event-driven): When admin enables MFA, system shall generate QR code
- REQ-003 (State-driven): While MFA enabled, system shall enforce code on every login
- REQ-004 (Unwanted): If TOTP invalid 3 times, system shall lock account for 15 minutes

# Phase 2: DESIGN
# Architecture and technical design
#breakdown-epic-arch

Context: admin-mfa Epic
Output: docs/ways-of-work/admin-mfa/arch.md
- Authentication flow: Password → TOTP → Session
- Gem: devise-two-factor (ROTP-based)
- Database: Add mfa_secret, mfa_enabled to admin_users table
- Recovery: Backup codes stored encrypted
- Security: Rate limiting on TOTP verification (Rack::Attack integration)

# Phase 3: IMPLEMENT
# Use TDD workflow for implementation
@workspace /task-planner

# Then TDD cycle for each story:
@workspace /tdd-red      # Write failing test
@workspace /tdd-green    # Minimal implementation
@workspace /tdd-refactor # Security hardening

# Phase 4: VALIDATE
# Run test suite and validate requirements
bin/rails test test/models/admin_user_test.rb
bin/rails test:system test/system/admin/mfa_test.rb

# Validate EARS requirements:
# REQ-001: ✓ TOTP required after password (test passing)
# REQ-002: ✓ QR code generated (integration test)
# REQ-003: ✓ MFA enforced on login (system test)
# REQ-004: ✓ Account lock after 3 failures (controller test)

# Phase 5: REFLECT
# Update specification with implementation notes
Output: docs/ways-of-work/admin-mfa/reflection.md
- Design deviation: Used encrypted_mfa_secret instead of mfa_secret (security improvement)
- Technical debt: Recovery codes not yet implemented (future story)
- Lessons learned: Rack::Attack throttling simpler than custom rate limiter

# Phase 6: HANDOFF
# Prepare for code review and deployment
Output: Pull request with:
- Commit message: "feat(admin): Add TOTP-based MFA for admin users"
- PR description: Links to epic.md and arch.md
- Deployment checklist:
  - Database migration: AddMfaToAdminUsers
  - Environment variable: MFA_ISSUER_NAME
  - Documentation update: Admin setup guide
  - Rollback plan: Disable MFA feature flag
```

---

## 🏗️ Directory Structure Created by Workflows

### Planning Directories
```
.copilot-tracking/
  research/                     # Research documents (task-researcher agent)
    YYYYMMDD-topic-research.md
  plans/                        # Implementation plans (task-planner agent)
    YYYYMMDD-task-plan.instructions.md
  details/                      # Task details (task-planner agent)
    YYYYMMDD-task-details.md
  prompts/                      # Execution prompts (task-planner agent)
    implement-task.prompt.md
  changes/                      # Implementation logs (task-implementation instructions)
    YYYYMMDD-task-changes.md

plan/                           # AI-executable plans (implementation-plan agent)
  upgrade-system-command-4.md
  feature-auth-module-1.md

docs/
  ways-of-work/
    plan/
      {epic-name}/
        epic.md                 # Epic PRD (breakdown-epic-pm prompt)
        arch.md                 # Architecture spec (breakdown-epic-arch prompt)
        {feature-name}/
          prd.md                # Feature PRD (breakdown-feature-prd prompt)
          implementation-plan.md # Technical plan (breakdown-feature-implementation prompt)
          project-plan.md       # GitHub project (create-github-issues prompt)
          issues-checklist.md   # Issue tracking
          requirements.md       # EARS requirements (spec-driven workflow Phase 1)
          design.md             # Technical design (Phase 2)
          tasks.md              # Implementation tasks (Phase 3)
          validation.md         # Test results (Phase 4)
          reflection.md         # Lessons learned (Phase 5)
  spikes/                       # Technical spikes (create-technical-spike prompt)
    architecture-session-storage-strategy-spike.md
    performance-n-plus-one-queries-spike.md
```

---

## 🔧 Rails-Specific Integration Patterns

### 1. Service Object Extraction (Refactor Pattern)

Existing service objects: `TaxCalculator`, `VatCalculator`

**Use TDD Refactor agent to extract new service objects**:

```bash
@workspace /tdd-refactor

Context:
Refactor CheckoutsController checkout logic into CheckoutProcessor service object following TaxCalculator pattern:
- Input validation
- Cart item processing
- Stripe session creation
- Error handling

Ensure:
- Single Responsibility Principle
- OWASP input validation
- Comprehensive error logging
- Service object tests
```

### 2. Minitest Integration (All TDD Agents)

**TDD agents work with existing Minitest setup**:

```ruby
# test/controllers/webhooks_controller_test.rb
require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  # TDD-red agent writes this
  test "should verify Stripe signature" do
    payload = stripe_event_payload
    signature = generate_stripe_signature(payload)

    post webhooks_stripe_url,
         params: payload,
         headers: { 'HTTP_STRIPE_SIGNATURE' => signature }

    assert_response :success
  end

  # TDD-green agent implements signature verification
  # TDD-refactor agent extracts to service object
end
```

### 3. N+1 Query Resolution (Epic Planning)

**Use Epic planning prompts to systematically address performance issues**:

```bash
# 1. Epic PRD
#breakdown-epic-pm

Context:
- Epic: performance-optimization
- Problem: N+1 queries in CategoriesController#show (products.images)
- Target: <100ms p95 latency
- Metrics: Query count, response time

# 2. Architecture
#breakdown-epic-arch

Context: performance-optimization Epic
Solutions:
- Eager loading: @products = @category.products.with_attached_images
- Fragment caching: cache product cards
- Database indexes: products.category_id, active_storage_attachments.record_id

# 3. Feature PRD
#breakdown-feature-prd

Context:
- Epic: performance-optimization
- Feature: eager-loading-optimization
- Stories:
  1. Add includes for images
  2. Fragment cache product cards
  3. Database index creation
```

---

## 📊 Metrics and Success Tracking

### Test Coverage Improvements

**Before Collections Installation** (from test-analysis.md):
- Total tests: 301
- Assertions: 749
- Coverage gaps: WebhooksController, Contact form, Newsletter

**Track Progress with TDD Agents**:
```bash
# After each TDD cycle:
bin/rails test
bin/rails test:system

# Monitor metrics:
# - Test count increase (target: +50 tests for webhook coverage)
# - Assertion count increase (target: +120 assertions)
# - Coverage percentage (target: 85% from current ~70%)
```

### Sprint Planning Metrics

**Use GitHub Issues from breakdown-plan prompt**:
- **Epic Burndown**: Track feature completion via Epic issue milestone
- **Story Points**: Use Fibonacci estimation in User Story issues
- **Velocity**: Measure completed story points per sprint
- **Lead Time**: Track time from Epic PRD to deployment

---

## 🎯 Best Practices

### 1. Always Start with Research

```bash
# GOOD: Research first, plan second
@workspace /task-researcher     # Understand the problem
@workspace /task-planner         # Create actionable plan

# BAD: Skip research, create uninformed plan
@workspace /task-planner         # Incomplete context
```

### 2. Use Spec-Driven Workflow for Complex Features

**When to use spec-driven-workflow-v1.instructions.md**:
- ✅ New features with unclear requirements (MFA, payment methods)
- ✅ Major refactors (cart persistence migration)
- ✅ Security-critical changes (authentication, authorization)
- ✅ Performance optimization requiring validation

**When to use simple task-planner**:
- ✅ Bug fixes with clear reproduction steps
- ✅ Minor UI tweaks
- ✅ Documentation updates

### 3. Leverage GitHub Issue Automation

**Use prompts to generate issues, not manual creation**:

```bash
# GOOD: Automated issue creation with dependencies
#create-github-issues-feature-from-implementation-plan

# RESULT:
# - Epic issue (milestone tracking)
# - 3 Feature issues (linked to Epic)
# - 8 User Story issues (with acceptance criteria)
# - 5 Technical Enabler issues (infrastructure)
# - Automated dependency linking
# - Label assignment (priority, type, team)

# BAD: Manually creating issues one-by-one
# - Inconsistent formatting
# - Missing dependencies
# - No automation triggers
```

### 4. Update Documentation Continuously

**Pattern from task-implementation.instructions.md**:
```bash
# After EVERY task completion:
# Update .copilot-tracking/changes/YYYYMMDD-task-changes.md with:
# - Files modified
# - Key changes
# - Testing performed
# - Status (✅ complete)

# NEVER batch documentation updates at the end
```

---

## 🐛 Troubleshooting

### Agent Not Found Error

```
Error: Agent 'task-planner' not found
```

**Solution**: Use exact agent name without extension:
```bash
@workspace /task-planner        # ✅ Correct
@workspace /task-planner.agent  # ❌ Incorrect
```

### Prompt Not Autocompleting

**Solution**: Prompts use `#` not `/`:
```bash
#breakdown-epic-pm              # ✅ Correct
@workspace #breakdown-epic-pm   # ❌ Incorrect
```

### Directory Not Created

**Solution**: Agents create directories automatically:
```bash
# If .copilot-tracking/ doesn't exist:
@workspace /task-planner

# Agent will create:
# .copilot-tracking/plans/
# .copilot-tracking/details/
# .copilot-tracking/prompts/
```

---

## 📚 Additional Resources

- **Awesome Copilot Repository**: https://github.com/github/awesome-copilot
- **Project Planning Collection**: https://github.com/github/awesome-copilot/blob/main/collections/project-planning.md
- **Testing Collection**: https://github.com/github/awesome-copilot/blob/main/collections/testing.md
- **TDD Best Practices**: https://github.com/github/awesome-copilot/blob/main/docs/README.agents.md#tdd-workflow

---

## 🚦 Next Steps

1. **Test Agent Invocation**:
   ```bash
   @workspace /task-planner

   Context: Create plan to add tests for WebhooksController with Stripe signature verification
   ```

2. **Generate Your First Epic**:
   ```bash
   #breakdown-epic-pm

   Context:
   - Epic name: admin-dashboard-improvements
   - Problem: Admin dashboard lacks key metrics
   - Metrics: Revenue, orders, user activity
   ```

3. **Run TDD Cycle**:
   ```bash
   @workspace /tdd-red

   Context: Write failing test for Cart#persist method
   ```

4. **Validate Installation**:
   ```bash
   # Verify all files exist:
   ls -la .github/agents/
   ls -la .github/instructions/
   ls -la .github/prompts/
   ```

---

**Installation Complete!** 🎉

All 21 AI workflow automation files are ready to use. Start with a simple agent invocation to test the setup, then explore the Epic-to-Story workflows for larger features.
