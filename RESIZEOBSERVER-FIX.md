# ResizeObserver Error Fix

## Issue
The error "ResizeObserver loop completed with undelivered notifications" was being reported to Honeybadger from the production environment.

## Root Cause
This is a **benign browser warning** that occurs when:
- Libraries using ResizeObserver (like Chart.js) take too long to process resize notifications
- The browser's ResizeObserver event loop completes before all callbacks finish
- This is a timing issue that **does not affect functionality**

The issue was in `app/javascript/application.ts` where the global error handler was catching ALL errors, including these harmless ResizeObserver warnings, and reporting them to Honeybadger.

## Solution
Modified the global error handler in `app/javascript/application.ts` to filter out ResizeObserver errors before reporting to Honeybadger.

### Code Changes
```typescript
window.addEventListener('error', (event: ErrorEvent) => {
  if (window.Honeybadger && event.error) {
    // Filter out benign ResizeObserver errors from Chart.js and other libraries
    // These are harmless browser warnings that don't affect functionality
    const errorMessage = event.error?.message || event.message || '';
    if (errorMessage.includes('ResizeObserver loop') || 
        errorMessage.includes('ResizeObserver loop completed with undelivered notifications')) {
      return; // Silently ignore ResizeObserver errors
    }

    window.Honeybadger.notify(event.error, {
      context: {
        url: window.location.href,
        userAgent: navigator.userAgent
      }
    });
  }
});
```

### Why This Approach?
1. **Targeted filtering**: Only filters the specific ResizeObserver error messages
2. **Maintains error reporting**: All other genuine JavaScript errors continue to be reported
3. **No functionality impact**: The errors were already benign, now they just don't pollute logs
4. **Industry standard**: This is a common approach used across many web applications

## Testing

### Manual Testing
1. Navigate to the admin dashboard (contains Chart.js charts)
2. Resize the browser window rapidly
3. Verify no ResizeObserver errors appear in Honeybadger
4. Trigger a genuine JavaScript error to verify error reporting still works

### Automated Testing
The existing Playwright test in `tests/error-handling.spec.ts` already monitors for JavaScript errors. The test filters non-critical errors and should continue to pass.

### Browser Console Testing
1. Open browser DevTools console
2. Navigate to a page with charts (e.g., admin dashboard)
3. Resize the window
4. You may see ResizeObserver warnings in the console (this is normal)
5. These warnings will NOT be sent to Honeybadger

## Impact
- ✅ Reduces Honeybadger error noise
- ✅ Maintains genuine error reporting
- ✅ No code functionality changes
- ✅ No performance impact
- ✅ Follows industry best practices

## References
- [MDN - ResizeObserver](https://developer.mozilla.org/en-US/docs/Web/API/ResizeObserver)
- [Chart.js GitHub Issue - ResizeObserver](https://github.com/chartjs/Chart.js/issues/9239)
- This is a known issue with Chart.js and many other charting/UI libraries

## Related Files
- `app/javascript/application.ts` - Error filtering implementation
- `app/javascript/controllers/dashboard_controller.ts` - Chart.js usage
- `tests/error-handling.spec.ts` - Error handling tests
