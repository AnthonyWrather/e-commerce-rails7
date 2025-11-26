# VAT Display Implementation in Stripe Checkout

## Problem Statement
VAT (Value Added Tax) was not displayed on the Stripe Checkout screen. The cart page showed VAT calculations (Inc VAT, Ex VAT, Total VAT @20%), but when customers proceeded to checkout via Stripe, the Checkout Session did not display any tax information.

## Root Cause Analysis

### Frontend (Cart)
The cart is managed entirely in JavaScript using Stimulus controllers:
- **File**: `app/javascript/controllers/cart_controller.ts`
- **VAT Calculation**: Client-side calculation dividing price by 1.2 to get Ex VAT
- **Display**: Shows "Inc VAT", "Ex VAT", and "Total VAT @20%" columns in cart table
- **Cart Data**: Stores items in localStorage with VAT-inclusive prices

### Backend (Checkout)
The checkout flow did not inform Stripe about tax information:
- **File**: `app/controllers/checkouts_controller.rb`
- **Issue**: Line items were created with `unit_amount` but no `tax_behavior` or `tax_rates`
- **Result**: Stripe received prices but didn't know they included VAT

## Solution Implemented

### 1. Added Tax Behavior to Line Items
Modified `build_line_item` method to include `tax_behavior: 'inclusive'`:

```ruby
price_data: {
  product_data: { ... },
  currency: 'gbp',
  unit_amount: item['price'].to_i,
  tax_behavior: 'inclusive'  # ← NEW
}
```

This tells Stripe that the `unit_amount` already includes the tax.

### 2. Added UK VAT Tax Rate
Created methods to retrieve or create a UK VAT tax rate:

```ruby
def tax_rate_id
  # Try ENV var, then credentials, then create new
  ENV['STRIPE_TAX_RATE_ID'] ||
    Rails.application.credentials.dig(:stripe, :tax_rate_id) ||
    create_uk_vat_rate
end

def create_uk_vat_rate
  tax_rate = Stripe::TaxRate.create(
    display_name: 'VAT',
    description: 'UK VAT',
    jurisdiction: 'GB',
    percentage: 20.0,
    inclusive: true  # Prices already include VAT
  )
  tax_rate.id
rescue Stripe::StripeError => e
  Rails.logger.error("Failed to create tax rate: #{e.message}")
  nil  # Graceful fallback
end
```

### 3. Attached Tax Rate to Line Items
Modified `build_line_item` to conditionally add tax rate:

```ruby
line_item = {
  quantity: item['quantity'].to_i,
  price_data: { ... }
}

tax_id = tax_rate_id
line_item[:tax_rates] = [tax_id] if tax_id.present?

line_item
```

## Configuration

### Environment Variables (Recommended)
Set `STRIPE_TAX_RATE_ID` to avoid creating a new tax rate on every request:

```bash
# .env or production environment
STRIPE_TAX_RATE_ID=txr_1Abc123...
```

### Rails Credentials (Alternative)
Store in encrypted credentials:

```bash
EDITOR="code --wait" rails credentials:edit
```

```yaml
stripe:
  secret_key: sk_live_...
  tax_rate_id: txr_1Abc123...
```

### Creating Tax Rate in Stripe Dashboard
For production, create the tax rate once in the Stripe Dashboard:

1. Go to **Products** → **Tax rates**
2. Click **Add tax rate**
3. Set:
   - Display name: `VAT`
   - Description: `UK VAT`
   - Jurisdiction: `GB`
   - Percentage: `20.0%`
   - **Inclusive**: Yes (prices already include tax)
4. Copy the tax rate ID (e.g., `txr_1Abc123...`)
5. Set `STRIPE_TAX_RATE_ID` environment variable

## How It Works

### Checkout Flow
1. **Cart**: User adds items with VAT-inclusive prices
2. **Checkout Request**: Frontend sends cart to `/checkout` endpoint
3. **Build Line Items**: Backend creates Stripe line items with:
   - `unit_amount`: VAT-inclusive price (e.g., 1200 pence = £12.00)
   - `tax_behavior: 'inclusive'`
   - `tax_rates`: [UK VAT 20% rate ID]
4. **Stripe Session**: Stripe knows:
   - Total price is £12.00
   - Price includes 20% VAT
   - VAT amount is £2.00 (£12.00 ÷ 1.2 = £10.00 ex VAT)
5. **Stripe Checkout Page**: Displays:
   - Item price: £12.00
   - VAT breakdown: "includes £2.00 VAT"
   - Total: £12.00 (inc VAT)

### Error Handling
- If `STRIPE_TAX_RATE_ID` is not set, the system attempts to create a new tax rate
- If tax rate creation fails, the system gracefully degrades:
  - Line items still have `tax_behavior: 'inclusive'`
  - But no `tax_rates` array
  - Checkout still works, but VAT breakdown may not display
  - Error is logged via `Rails.logger.error`

## Testing

### Unit Tests
Created comprehensive tests in `test/controllers/checkouts_controller_test.rb`:

1. **VAT Tax Behavior**: Verifies line items include `tax_behavior: 'inclusive'`
2. **Tax Rate Assignment**: Verifies `tax_rates` array is populated
3. **Graceful Degradation**: Verifies system works when tax rate creation fails
4. **Stock Variants**: Verifies VAT works with different product sizes
5. **Product vs Stock Pricing**: Verifies correct price source

Run tests:
```bash
bin/rails test test/controllers/checkouts_controller_test.rb
```

### Manual Testing
1. Add items to cart
2. View cart page (verify VAT calculations display)
3. Click "Checkout"
4. Verify Stripe Checkout page shows:
   - Item prices
   - **VAT breakdown** (e.g., "includes £2.00 VAT")
   - Total amount

## UK VAT Details
- **Standard Rate**: 20%
- **Calculation**: Ex VAT = Inc VAT ÷ 1.2
- **Example**: £12.00 inc VAT = £10.00 ex VAT + £2.00 VAT
- **Inclusive Pricing**: Prices displayed to customers already include VAT

## Files Modified
- `app/controllers/checkouts_controller.rb`:
  - Added `tax_rate_id` method
  - Added `create_uk_vat_rate` method
  - Modified `build_line_item` to include `tax_behavior` and `tax_rates`
- `test/controllers/checkouts_controller_test.rb`:
  - Created comprehensive test suite

## Benefits
✅ VAT is now displayed on Stripe Checkout page
✅ Customers see clear price breakdown
✅ Complies with UK VAT display requirements
✅ Graceful error handling if tax rate unavailable
✅ Configurable via environment variables
✅ Fully tested with unit tests

## Future Enhancements
- Consider using Stripe Tax for automatic tax calculation
- Support for different tax rates (reduced, zero-rated items)
- Support for other jurisdictions beyond UK
- Cache tax_rate_id in application memory to avoid ENV lookups

