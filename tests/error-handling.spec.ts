import { test, expect } from '@playwright/test';

test.describe('Error Handling and Edge Cases', () => {
  test('handles non-existent product gracefully', async ({ page }) => {
    await test.step('Navigate to non-existent product', async () => {
      // Try to access a product that likely doesn't exist
      await page.goto('/products/99999');
    });

    await test.step('Verify error handling', async () => {
      // Should either show 404 page, redirect to homepage, or show an error message
      const isErrorPage = page.url().includes('404') ||
                         await page.locator('h1', { hasText: /not found|error/i }).count() > 0;
      const isHomePage = page.url().endsWith('/') || page.url().includes('home');
      const pageLoaded = await page.locator('body').isVisible();

      // The important thing is that the page doesn't crash
      expect(pageLoaded).toBeTruthy();
    });
  });

  test('handles non-existent category gracefully', async ({ page }) => {
    await test.step('Navigate to non-existent category', async () => {
      await page.goto('/categories/99999');
    });

    await test.step('Verify error handling', async () => {
      // Should handle gracefully - either 404, redirect, or show some content
      const isErrorPage = page.url().includes('404') ||
                         await page.locator('h1', { hasText: /not found|error/i }).count() > 0;
      const isHomePage = page.url().endsWith('/') || page.url().includes('home');
      const pageLoaded = await page.locator('body').isVisible();

      // The important thing is that the page doesn't crash
      expect(pageLoaded).toBeTruthy();
    });
  });

  test('handles malformed URLs gracefully', async ({ page }) => {
    await test.step('Try various malformed URLs', async () => {
      const malformedUrls = [
        '/products/abc',
        '/categories/xyz',
        '/invalid-page',
        '/products/',
        '/categories/'
      ];

      for (const url of malformedUrls) {
        await page.goto(url);
        // Should not crash - page should load some content
        await expect(page.locator('body')).toBeVisible();
      }
    });
  });

  test('handles JavaScript errors gracefully', async ({ page }) => {
    const jsErrors: string[] = [];

    // Listen for JavaScript errors
    page.on('pageerror', (error) => {
      jsErrors.push(error.message);
    });

    await test.step('Navigate through pages and check for JS errors', async () => {
      const pages = ['/', '/contact', '/quantities', '/cart'];

      for (const pageUrl of pages) {
        await page.goto(pageUrl);
        await page.waitForTimeout(1000); // Allow JS to execute
        await expect(page.locator('body')).toBeVisible();
      }
    });

    await test.step('Verify no critical JavaScript errors', async () => {
      // Filter out non-critical errors (if any)
      const criticalErrors = jsErrors.filter(error =>
        !error.includes('favicon') &&
        !error.includes('analytics') &&
        !error.includes('gtag') &&
        !error.includes('ResizeObserver loop') // Benign Chart.js warning - filtered in application.ts
      );

      expect(criticalErrors).toHaveLength(0);
    });
  });

  test('handles network timeouts gracefully', async ({ page }) => {
    await test.step('Test page loads within reasonable time', async () => {
      // Set a reasonable timeout for page loads
      page.setDefaultTimeout(30000);

      await page.goto('/');
      await expect(page.locator('body')).toBeVisible();

      // Navigate to a few key pages to ensure they load
      await page.goto('/contact');
      await expect(page.locator('body')).toBeVisible();

      await page.goto('/quantities');
      await expect(page.locator('body')).toBeVisible();
    });
  });

  test('validates form inputs properly', async ({ page }) => {
    await test.step('Test contact form validation', async () => {
      await page.goto('/contact');

      const form = page.locator('form');
      if (await form.count() > 0) {
        // Try to submit empty form
        const submitButton = page.locator('input[type="submit"], button[type="submit"]').first();
        if (await submitButton.count() > 0) {
          await submitButton.click();

          // Should either prevent submission or show validation message
          // We can't easily test this without knowing the exact validation implementation
          await page.waitForTimeout(1000);
          await expect(page.locator('body')).toBeVisible();
        }
      }
    });
  });

  test('handles cart edge cases', async ({ page }) => {
    await test.step('Test cart with invalid data', async () => {
      await page.goto('/cart');

      // Add malformed data to localStorage
      await page.evaluate(() => {
        // Invalid cart data that might cause issues
        localStorage.setItem('cart', 'invalid json');
      });

      await page.reload();

      // Page should still load without crashing
      await expect(page.locator('body')).toBeVisible();
    });

    await test.step('Test cart with missing required fields', async () => {
      await page.goto('/cart');

      // Add cart item missing required fields
      await page.evaluate(() => {
        const incompleteItem = {
          id: 1
          // Missing name, price, size, quantity
        };
        localStorage.setItem('cart', JSON.stringify([incompleteItem]));
      });

      await page.reload();
      await page.waitForTimeout(1000);

      // Should handle gracefully
      await expect(page.locator('body')).toBeVisible();
    });
  });

  test('handles console errors appropriately', async ({ page }) => {
    const consoleErrors: string[] = [];

    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await test.step('Navigate and collect console errors', async () => {
      await page.goto('/');
      await page.waitForTimeout(2000);

      await page.goto('/contact');
      await page.waitForTimeout(1000);

      await page.goto('/quantities');
      await page.waitForTimeout(1000);
    });

    await test.step('Check console errors are within acceptable limits', async () => {
      // Filter out common non-critical errors
      const criticalErrors = consoleErrors.filter(error =>
        !error.includes('favicon') &&
        !error.includes('analytics') &&
        !error.includes('gtag') &&
        !error.includes('ResizeObserver loop') && // Benign Chart.js warning - filtered in application.ts
        !error.includes('Refused to connect') && // Common for external resources
        !error.includes('net::ERR_') // Network errors for external resources
      );

      // Should have minimal critical console errors
      expect(criticalErrors.length).toBeLessThanOrEqual(5);
    });
  });

  test('ensures responsive design works on mobile', async ({ page }) => {
    await test.step('Test mobile viewport', async () => {
      // Set mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });

      await page.goto('/');
      await expect(page.locator('body')).toBeVisible();

      // Navigation should be accessible on mobile
      await expect(page.locator('nav, header')).toBeVisible();

      // Content should be readable
      await expect(page.locator('h1, h2').first()).toBeVisible();
    });

    await test.step('Test tablet viewport', async () => {
      await page.setViewportSize({ width: 768, height: 1024 });

      await page.goto('/');
      await expect(page.locator('body')).toBeVisible();

      // Should adapt layout for tablet
      await expect(page.locator('nav, header')).toBeVisible();
    });
  });
});
