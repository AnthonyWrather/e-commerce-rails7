# Pull Request

## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

<!-- Mark relevant items with [x] -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Refactoring (no functional changes, code improvements)
- [ ] Documentation update
- [ ] Dependency update
- [ ] Performance improvement
- [ ] Security fix

## Related Issues

<!-- Link to related issues using #issue_number -->

Closes #

## Changes Made

<!-- List the specific changes in this PR -->

-
-
-

## Testing

### Test Coverage

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] System tests added/updated
- [ ] All tests pass (`bin/rails test:all`)

### Manual Testing

<!-- Describe the manual testing performed -->

**Steps to test**:
1.
2.
3.

**Expected behavior**:


## Pre-Submission Checklist

### Code Quality
- [ ] Code follows project conventions (see [CONTRIBUTING.md](../CONTRIBUTING.md))
- [ ] All Ruby files start with `# frozen_string_literal: true`
- [ ] Strong parameters used in controllers
- [ ] RuboCop passes (`rubocop -a`)
- [ ] TypeScript builds without errors (`yarn build`)
- [ ] No debug code (e.g., `binding.pry`, `console.log`) left in

### Rails Conventions
- [ ] Admin controllers inherit from `AdminController`
- [ ] Instance variables use `@admin_` prefix in admin namespace
- [ ] Models referenced correctly (e.g., `Product`, not `Admin::Product`)
- [ ] Validations present on model fields
- [ ] Used `with_attached_images` to prevent N+1 queries

### Security & Performance
- [ ] No SQL injection vulnerabilities (parameterized queries used)
- [ ] CSRF token included in AJAX requests
- [ ] Sensitive data not logged (parameter filtering checked)
- [ ] No N+1 queries introduced (eager loading used)
- [ ] Indexes added for new foreign keys

### Critical Patterns
- [ ] Orders created ONLY in webhooks (not in controllers)
- [ ] Webhook signatures verified before processing
- [ ] Stock decremented ONLY after payment confirmation
- [ ] Prices stored in pence (integers, not floats)
- [ ] Used `:unprocessable_content` (not deprecated `:unprocessable_entity`)

### Documentation
- [ ] README.md updated if public API changed
- [ ] `.github/copilot-instructions.md` updated if architecture changed
- [ ] Inline comments added for complex business logic
- [ ] Schema diagram updated if database changed

## Screenshots

<!-- If applicable, add screenshots to help explain your changes -->

## Database Migrations

<!-- If applicable, describe any database changes -->

- [ ] Migration tested locally
- [ ] Migration is reversible
- [ ] Indexes added for new foreign keys
- [ ] Schema diagram updated

**Migration details**:


## Breaking Changes

<!-- If applicable, describe any breaking changes and migration path -->

- [ ] No breaking changes
- [ ] Breaking changes documented below

**Breaking change details**:


## Deployment Notes

<!-- Any special deployment instructions? -->

- [ ] No special deployment needed
- [ ] Requires environment variable changes
- [ ] Requires data migration
- [ ] Requires dependency updates

**Deployment instructions**:


## Rollback Plan

<!-- How to rollback if this PR causes issues in production -->


## Additional Context

<!-- Add any other context about the PR here -->

---

## Reviewer Checklist

<!-- For reviewers - do not modify -->

### Functionality
- [ ] Feature works as described
- [ ] No regressions in existing features
- [ ] Edge cases handled

### Code Quality
- [ ] Follows project conventions
- [ ] DRY principle applied
- [ ] Clear variable/method names
- [ ] Appropriate abstraction level

### Testing
- [ ] Test coverage adequate
- [ ] Tests are meaningful (not just coverage)
- [ ] System tests for user flows

### Security
- [ ] No security vulnerabilities introduced
- [ ] Input validation present
- [ ] Authorization checks in place

### Performance
- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] Appropriate caching strategy
