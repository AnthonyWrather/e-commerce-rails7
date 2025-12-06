# Testing Plan for ResizeObserver Fix

## Overview
This document outlines the testing strategy for the ResizeObserver error filtering fix implemented in `app/javascript/application.ts`.

## Automated Tests to Run

### 1. Playwright Tests (Already Updated)
The existing Playwright test suite has been updated to expect ResizeObserver errors to be filtered.

**Files Updated:**
- `tests/error-handling.spec.ts`

**Test Coverage:**
- `handles JavaScript errors gracefully` - Now filters ResizeObserver from critical errors
- `handles console errors appropriately` - Now filters ResizeObserver from console errors

**Command to Run:**
```bash
yarn test
# or
yarn test:headed  # For headed mode
```

**Expected Result:**
All tests should pass, including pages with Chart.js charts that may trigger ResizeObserver errors.

### 2. Rails Unit Tests
No specific unit tests were added for this JavaScript change, as the fix is purely client-side error filtering.

**Command to Run:**
```bash
timeout 300 bin/rails test
```

**Expected Result:**
All existing tests should continue to pass. No new test failures should occur.

### 3. Rails System Tests
System tests use Capybara which runs in a browser environment, so they may encounter ResizeObserver errors.

**Command to Run:**
```bash
timeout 600 bin/rails test:system
```

**Expected Result:**
All system tests should pass. The admin dashboard tests (which use Chart.js) should not report JavaScript errors.

## Manual Testing Checklist

### Test Environment Setup
1. Start the Rails server: `bin/dev` or `bin/rails server`
2. Open browser DevTools Console (F12)
3. Monitor the Console and Network tabs

### Test Cases

#### Test 1: Admin Dashboard with Charts
**Steps:**
1. Navigate to `/admin` (or admin dashboard URL)
2. Log in as admin if required
3. Navigate to pages with Chart.js charts (revenue reports, analytics)
4. Resize browser window multiple times rapidly
5. Check browser console for ResizeObserver warnings

**Expected Results:**
- ✅ You MAY see "ResizeObserver loop" warnings in the browser console (this is normal)
- ✅ These errors should NOT be sent to Honeybadger
- ✅ Page functionality works normally
- ✅ Charts resize correctly

**How to Verify Honeybadger:**
- Check Honeybadger dashboard for new errors
- Should NOT see "ResizeObserver loop completed with undelivered notifications" errors
- Should only see genuine JavaScript errors (if any)

#### Test 2: Genuine Error Reporting Still Works
**Steps:**
1. Navigate to `/admin/test_errors` (if available)
2. Trigger a test JavaScript error
3. Check Honeybadger dashboard

**Expected Results:**
- ✅ Genuine JavaScript errors ARE still reported to Honeybadger
- ✅ Only ResizeObserver errors are filtered out
- ✅ Error reporting functionality is not broken

#### Test 3: Multiple Pages with Dynamic Content
**Steps:**
1. Navigate through various pages:
   - Home page
   - Product pages
   - Admin dashboard
   - Reports pages
2. Resize window on each page
3. Monitor browser console and Honeybadger

**Expected Results:**
- ✅ No ResizeObserver errors in Honeybadger
- ✅ Other errors (if any) still reported correctly
- ✅ No JavaScript functionality broken

## Regression Testing

### Areas to Check
1. **Chart.js Functionality**
   - Charts render correctly
   - Charts resize with window
   - No visual glitches

2. **Error Reporting**
   - Console.error() still reported
   - Unhandled promise rejections still caught
   - Other error types not affected

3. **Browser Compatibility**
   - Test in Chrome
   - Test in Firefox
   - Test in Safari (if available)
   - Test in Edge

## Success Criteria

The fix is successful if:
- ✅ ResizeObserver errors are NOT reported to Honeybadger
- ✅ All other JavaScript errors ARE still reported to Honeybadger
- ✅ All Playwright tests pass
- ✅ All Rails tests pass (unit and system)
- ✅ All manual test cases pass
- ✅ No regression in existing functionality
- ✅ RuboCop has no offenses
- ✅ Test coverage remains above 40%

## Test Coverage Report

After running the full test suite, verify coverage with:

```bash
# System tests show coverage report at the end
bin/rails test:system
```

**Expected Coverage:**
- Overall coverage should remain above 40%
- JavaScript files (application.ts) are not typically included in Rails coverage
- Focus on ensuring no regression in Ruby test coverage

## Notes

### Database Setup Required
Some tests require PostgreSQL database. If database is not available:
1. Set up PostgreSQL locally or in container
2. Run `RAILS_ENV=test bin/rails db:create db:schema:load`
3. Then run the test suite

### CI/CD Integration
This fix should be tested in:
- Local development environment
- CI/CD pipeline (if available)
- Staging environment before production deployment

### Monitoring Post-Deployment
After deploying to production:
1. Monitor Honeybadger for ResizeObserver errors (should be zero)
2. Monitor for any increase in other JavaScript errors
3. Check application performance and functionality
4. Review user reports for any issues

## Rollback Plan

If issues are discovered after deployment:
1. Revert the commit: `git revert <commit-hash>`
2. Or remove the filtering logic from `app/javascript/application.ts`
3. Rebuild JavaScript: `yarn build`
4. Redeploy

The original behavior will be restored (all errors including ResizeObserver sent to Honeybadger).
