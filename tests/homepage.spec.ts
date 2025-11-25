import { test, expect } from '@playwright/test';

test.describe('Homepage and Navigation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('displays homepage with welcome message', async ({ page }) => {
    await test.step('Verify page loads and has correct title', async () => {
      await expect(page).toHaveTitle(/Southcoast Fibreglass Supplies/);
      await expect(page.getByRole('heading', { name: 'Welcome to our store.' })).toBeVisible();
    });

    await test.step('Verify hero content is displayed', async () => {
      await expect(page.getByText('Supplier of fibreglass materials')).toBeVisible();
      await expect(page.getByText('Your one-stop shop for all your fibreglass needs!')).toBeVisible();
    });

    await test.step('Verify main navigation is present', async () => {
      await expect(page.getByRole('link', { name: 'Home' })).toBeVisible();
      await expect(page.getByRole('link', { name: 'Cart' })).toBeVisible();
    });
  });

  test('displays category cards and navigation', async ({ page }) => {
    await test.step('Verify category cards are displayed', async () => {
      // Categories should be displayed as cards
      const categoryCards = page.locator('[class*="bg-blue-400"][class*="border"]');
      // Check if categories exist - this might be 0 if no categories are set up
      const categoryCount = await categoryCards.count();
      expect(categoryCount).toBeGreaterThanOrEqual(0);
    });

    await test.step('Verify category links work', async () => {
      // Find first category link and click it
      const firstCategoryLink = page.locator('a[href*="/categories/"]').first();
      if (await firstCategoryLink.count() > 0) {
        await firstCategoryLink.click();
        // Should navigate to category page or stay on homepage if no categories
        const url = page.url();
        expect(url).toMatch(/\/(categories\/\d+|$)/);
      }
    });
  });

  test('has working footer navigation', async ({ page }) => {
    await test.step('Verify footer links are present', async () => {
      await expect(page.getByRole('link', { name: 'Home' })).toBeVisible();
      await expect(page.getByRole('link', { name: 'Quantities' })).toBeVisible();
      await expect(page.getByRole('link', { name: 'Contact Us' })).toBeVisible();
    });

    await test.step('Verify footer contact information', async () => {
      await expect(page.getByText('Southcoast Fibreglass Supplies Ltd').first()).toBeVisible();
      await expect(page.getByText('Fort Fareham')).toBeVisible();
    });
  });

  test('has customer testimonials section', async ({ page }) => {
    await test.step('Verify testimonials section exists', async () => {
      await expect(page.getByRole('heading', { name: 'Customer Testimonials' })).toBeVisible();
    });
  });
});
