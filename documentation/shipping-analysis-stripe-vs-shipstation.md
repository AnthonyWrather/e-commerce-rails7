# Shipping Analysis: Stripe vs ShipStation

**Document Type:** Technical Spike Research  
**Date:** November 30, 2025  
**Author:** Technical Analysis  
**Status:** Complete

---

## Executive Summary

This document analyzes two approaches for improving the Collection/Delivery and Shipping implementation for a UK-based composite materials e-commerce business built on Rails 7 with Stripe Checkout.

**Current State:** The application uses Stripe Checkout with fixed shipping options (Collection £0, Standard £25, Overnight £50).

**Recommendation:** A **hybrid approach** is recommended:
1. **Short-term:** Enhance the current Stripe Checkout shipping with dynamic rate calculation based on cart weight
2. **Long-term:** Consider ShipStation integration if multi-carrier rate shopping and automated label printing become critical business requirements

---

## Table of Contents

1. [Current Implementation Analysis](#current-implementation-analysis)
2. [Option 1: Stripe Shipping Enhancement](#option-1-stripe-shipping-enhancement)
3. [Option 2: ShipStation API Integration](#option-2-shipstation-api-integration)
4. [Comparison Table](#comparison-table)
5. [Implementation Recommendations](#implementation-recommendations)
6. [UK-Specific Requirements](#uk-specific-requirements)
7. [Estimated Implementation Effort](#estimated-implementation-effort)
8. [Decision Matrix](#decision-matrix)
9. [Appendix](#appendix)

---

## Current Implementation Analysis

### Existing Architecture

```
┌─────────────────┐    ┌────────────────────┐    ┌─────────────────┐
│   Cart Page     │───▶│ CheckoutsController│───▶│ Stripe Checkout │
│   (LocalStorage)│    │   (create action)  │    │    Session      │
└─────────────────┘    └────────────────────┘    └────────┬────────┘
                                                          │
                       ┌────────────────────┐             │
                       │  OrderProcessor    │◀────────────┘
                       │  (webhook handler) │     Webhook
                       └────────────────────┘
```

### Current Shipping Options

```ruby
SHIPPING_OPTIONS = [
  {
    shipping_rate_data: {
      display_name: 'Collection',
      type: 'fixed_amount',
      fixed_amount: { amount: 0, currency: 'gbp' },
      delivery_estimate: { minimum: { unit: 'business_day', value: 1 }, maximum: { unit: 'business_day', value: 1 } }
    }
  },
  {
    shipping_rate_data: {
      display_name: '3 to 5 Business Days Shipping',
      type: 'fixed_amount',
      fixed_amount: { amount: 2500, currency: 'gbp' },
      delivery_estimate: { minimum: { unit: 'business_day', value: 3 }, maximum: { unit: 'business_day', value: 5 } }
    }
  },
  {
    shipping_rate_data: {
      display_name: 'Overnight Shipping (Order Before 11:00am Mon-Thu)',
      type: 'fixed_amount',
      fixed_amount: { amount: 5000, currency: 'gbp' },
      delivery_estimate: { minimum: { unit: 'business_day', value: 1 }, maximum: { unit: 'business_day', value: 1 } }
    }
  }
]
```

### Database Schema (Relevant Fields)

**Products table:**
- `shipping_weight` (integer, grams)
- `shipping_length` (integer, cm)
- `shipping_width` (integer, cm)
- `shipping_height` (integer, cm)

**Stocks table:**
- Same shipping fields for variant-level dimensions

**Orders table:**
- `shipping_cost` (integer, pence)
- `shipping_id` (string, Stripe shipping rate ID)
- `shipping_description` (string)

### Current Limitations

1. **Fixed pricing** - Doesn't account for cart weight or dimensions
2. **No carrier integration** - Manual label printing required
3. **No rate shopping** - Can't compare carrier prices
4. **Collection pickup** - Works but requires manual coordination

---

## Option 1: Stripe Shipping Enhancement

### Overview

Stripe Checkout provides built-in shipping functionality that the application already uses. This option focuses on enhancing the existing implementation rather than replacing it.

### Stripe Shipping Features

#### 1. Shipping Rate Types

| Type | Description | Use Case |
|------|-------------|----------|
| `fixed_amount` | Static shipping cost | Current implementation |
| `delivery_estimate` | Estimated delivery times | Already implemented |
| Pre-created Rates | Dashboard-defined rates | Better for permanent options |
| Dynamic Rates | Calculated at checkout time | Required for weight-based pricing |

#### 2. Stripe Tax Integration

Stripe Tax can automatically calculate VAT on shipping:

```ruby
session_options = {
  mode: 'payment',
  automatic_tax: { enabled: true },
  line_items: line_items,
  shipping_options: shipping_options,
  # Tax automatically applied to shipping
}
```

**Benefits:**
- Automatic UK VAT calculation (20%)
- Handles VAT on shipping costs
- Tax invoicing and reporting
- Already partially implemented with `tax_rate_id`

#### 3. Shipping Address Collection

Current implementation already uses:
```ruby
shipping_address_collection: { allowed_countries: %w[GB] }
```

Can be extended to support:
- Multiple country shipping zones
- Address validation
- Postcode restrictions

### Implementation: Dynamic Shipping Rates

To support weight-based pricing within Stripe, implement dynamic shipping rate calculation:

```ruby
# app/controllers/checkouts_controller.rb

class CheckoutsController < ApplicationController
  # Shipping tiers based on total cart weight (in grams)
  SHIPPING_TIERS = {
    standard: [
      { max_weight: 2000, price: 799 },    # Up to 2kg: £7.99
      { max_weight: 5000, price: 1299 },   # 2-5kg: £12.99
      { max_weight: 10000, price: 1999 },  # 5-10kg: £19.99
      { max_weight: 25000, price: 2999 },  # 10-25kg: £29.99
      { max_weight: Float::INFINITY, price: 4999 } # 25kg+: £49.99
    ],
    express: [
      { max_weight: 2000, price: 1499 },   # Up to 2kg: £14.99
      { max_weight: 5000, price: 2499 },   # 2-5kg: £24.99
      { max_weight: 10000, price: 3999 },  # 5-10kg: £39.99
      { max_weight: 25000, price: 5999 },  # 10-25kg: £59.99
      { max_weight: Float::INFINITY, price: 8999 } # 25kg+: £89.99
    ]
  }.freeze

  private

  def calculate_cart_weight(cart)
    cart.sum do |item|
      product = Product.find(item['id'])
      stock = product.stocks.find { |s| s.size == item['size'] }
      weight = stock&.shipping_weight || product.shipping_weight || 0
      weight * item['quantity'].to_i
    end
  end

  def shipping_price_for_weight(weight, tier)
    SHIPPING_TIERS[tier].find { |t| weight <= t[:max_weight] }[:price]
  end

  def build_shipping_options(cart)
    total_weight = calculate_cart_weight(cart)
    
    [
      # Collection option (always available)
      {
        shipping_rate_data: {
          display_name: 'Collection from Warehouse',
          type: 'fixed_amount',
          fixed_amount: { amount: 0, currency: 'gbp' },
          delivery_estimate: {
            minimum: { unit: 'business_day', value: 1 },
            maximum: { unit: 'business_day', value: 2 }
          },
          metadata: { shipping_type: 'collection' }
        }
      },
      # Standard delivery (weight-based)
      {
        shipping_rate_data: {
          display_name: "Standard Delivery (3-5 days) - #{weight_description(total_weight)}",
          type: 'fixed_amount',
          fixed_amount: { 
            amount: shipping_price_for_weight(total_weight, :standard), 
            currency: 'gbp' 
          },
          delivery_estimate: {
            minimum: { unit: 'business_day', value: 3 },
            maximum: { unit: 'business_day', value: 5 }
          },
          metadata: { shipping_type: 'standard', weight_grams: total_weight }
        }
      },
      # Express delivery (weight-based)
      {
        shipping_rate_data: {
          display_name: "Express Delivery (Next Day) - #{weight_description(total_weight)}",
          type: 'fixed_amount',
          fixed_amount: { 
            amount: shipping_price_for_weight(total_weight, :express), 
            currency: 'gbp' 
          },
          delivery_estimate: {
            minimum: { unit: 'business_day', value: 1 },
            maximum: { unit: 'business_day', value: 1 }
          },
          metadata: { shipping_type: 'express', weight_grams: total_weight }
        }
      }
    ]
  end

  def weight_description(grams)
    kg = (grams / 1000.0).round(1)
    kg < 1 ? "#{grams}g" : "#{kg}kg"
  end
end
```

### Benefits of Stripe Shipping

| Benefit | Description |
|---------|-------------|
| **Minimal Changes** | Already integrated, just needs enhancement |
| **PCI Compliance** | Payment handling remains fully compliant |
| **Unified Experience** | Single checkout flow for products and shipping |
| **Webhook Integration** | Already capturing shipping in OrderProcessor |
| **UK VAT Support** | Built-in tax calculation for shipping |
| **Collection Support** | Easy to implement as £0 shipping option |
| **No Additional Costs** | Included in standard Stripe fees (1.5% + 20p) |
| **Dashboard Management** | View shipping in Stripe Dashboard |

### Limitations of Stripe Shipping

| Limitation | Impact | Mitigation |
|------------|--------|------------|
| **No carrier integration** | Must print labels manually | Use separate label printing service |
| **No rate shopping** | Can't compare live carrier rates | Pre-negotiate rates with ACP International |
| **Fixed rate calculation** | Must define tiers ourselves | Regular review of shipping costs |
| **No tracking integration** | Manual tracking number entry | Store tracking in order metadata |
| **UK-only by default** | Need to expand for international | Currently meets requirements |
| **No label printing** | Separate system needed | Use carrier's web portal |

### Stripe Implementation Checklist

- [ ] Add product weight validation (ensure all products have `shipping_weight`)
- [ ] Create `ShippingCalculator` service class
- [ ] Update `CheckoutsController` with dynamic shipping options
- [ ] Add shipping metadata to Stripe session
- [ ] Update `OrderProcessor` to capture weight/tier data
- [ ] Add admin interface for managing shipping tiers
- [ ] Add Collection time slots selection (optional)
- [ ] Test with various cart weights

---

## Option 2: ShipStation API Integration

### Overview

ShipStation is a multi-carrier shipping platform that provides real-time rate shopping, label printing, and order management. It would require significant integration work alongside the existing Stripe checkout.

### ShipStation Features

#### 1. Multi-Carrier Rate Shopping

ShipStation connects to multiple carriers and provides real-time rate quotes:

**UK Carriers Supported:**
- Royal Mail (all services)
- DPD UK
- DHL Express
- Parcelforce
- Hermes/Evri
- UPS UK
- FedEx UK
- Yodel
- APC Overnight
- TNT

#### 2. API Capabilities

```
ShipStation API Endpoints:
├── /orders         - Create, update, list orders
├── /shipments      - Create shipments, get tracking
├── /carriers       - List available carriers
├── /services       - Get carrier services
├── /rates          - Get real-time shipping rates
├── /labels         - Create and print shipping labels
├── /webhooks       - Receive shipping updates
└── /stores         - Manage connected stores
```

#### 3. Rate Shopping Example

```ruby
# Example ShipStation rate request
class ShipStationService
  BASE_URL = 'https://ssapi.shipstation.com'
  
  def initialize
    @api_key = Rails.application.credentials.dig(:shipstation, :api_key)
    @api_secret = Rails.application.credentials.dig(:shipstation, :api_secret)
  end
  
  def get_rates(params)
    # ShipStation rate request structure
    rate_request = {
      carrierCode: nil, # Leave nil for all carriers
      serviceCode: nil, # Leave nil for all services
      packageCode: 'package',
      fromPostalCode: 'SW1A 1AA', # Warehouse postcode
      toCountry: 'GB',
      toPostalCode: params[:postcode],
      weight: {
        value: params[:weight_kg],
        units: 'kilograms'
      },
      dimensions: {
        units: 'centimeters',
        length: params[:length_cm],
        width: params[:width_cm],
        height: params[:height_cm]
      },
      confirmation: 'delivery',
      residential: params[:residential] || true
    }
    
    response = HTTP.basic_auth(user: @api_key, pass: @api_secret)
                   .post("#{BASE_URL}/shipments/getrates", json: rate_request)
                   
    JSON.parse(response.body)
  end
  
  def create_label(order_id, carrier_code, service_code)
    # Creates shipping label after order is placed
    label_request = {
      orderId: order_id,
      carrierCode: carrier_code,
      serviceCode: service_code,
      confirmation: 'delivery',
      shipDate: Date.today.iso8601,
      testLabel: !Rails.env.production?
    }
    
    response = HTTP.basic_auth(user: @api_key, pass: @api_secret)
                   .post("#{BASE_URL}/orders/createlabelfororder", json: label_request)
                   
    JSON.parse(response.body)
  end
end
```

### Integration Architecture

```
┌─────────────────┐                      ┌─────────────────────┐
│   Cart Page     │                      │     ShipStation     │
│                 │                      │        API          │
└────────┬────────┘                      └──────────┬──────────┘
         │                                          │
         ▼                                          │
┌─────────────────┐    Get Rates    ┌──────────────▼──────────┐
│ Shipping Quote  │◀───────────────▶│  ShippingRatesService   │
│    Page         │                 │  (Rails Service Class)  │
└────────┬────────┘                 └─────────────────────────┘
         │                                          
         ▼                                          
┌─────────────────┐                                 
│  Select Rate &  │                                 
│  Proceed        │                                 
└────────┬────────┘                                 
         │                                          
         ▼                                          
┌─────────────────┐    ┌────────────────────┐    ┌─────────────────┐
│ CheckoutsCtrl   │───▶│ Stripe Checkout    │───▶│  Order Created  │
│ (with shipping  │    │ (shipping pre-     │    │  (webhook)      │
│  rate in meta)  │    │  calculated)       │    └────────┬────────┘
└─────────────────┘    └────────────────────┘             │
                                                          │
                       ┌─────────────────────┐           │
                       │  ShipStation Order  │◀──────────┘
                       │  (via API)          │  Create Order
                       └──────────┬──────────┘
                                  │
                                  ▼
                       ┌─────────────────────┐
                       │  Admin: Print Label │
                       │  (ShipStation UI)   │
                       └─────────────────────┘
```

### Benefits of ShipStation

| Benefit | Description |
|---------|-------------|
| **Multi-carrier rates** | Compare rates across carriers in real-time |
| **Best price guarantee** | Always show cheapest option to customer |
| **Label printing** | Integrated label generation and printing |
| **Batch processing** | Handle multiple shipments efficiently |
| **Tracking** | Automatic tracking number assignment |
| **Customer notifications** | Automated shipping updates |
| **Returns management** | RMA and return label generation |
| **Analytics** | Shipping cost analysis and reporting |
| **UK carrier support** | Royal Mail, DPD, DHL, Hermes all available |
| **Customs documentation** | For future international expansion |

### Limitations of ShipStation

| Limitation | Impact | Cost/Effort |
|------------|--------|-------------|
| **Monthly fees** | £25-150/month depending on shipment volume | Ongoing cost |
| **Per-label fees** | Varies by carrier, typically £0.05-0.20 | Per order cost |
| **API complexity** | Significant development effort | 40-80 hours |
| **Two-step checkout** | Must quote rates before Stripe checkout | UX complexity |
| **Rate caching needed** | API rate limits (40 req/min) | Additional infrastructure |
| **Learning curve** | Team needs ShipStation training | Operational cost |
| **Collection handling** | Still needs custom solution | Development effort |
| **Reliability dependency** | Third-party service availability | Risk factor |

### ShipStation Pricing (UK)

| Plan | Monthly Cost | Shipments/Month | Features |
|------|--------------|-----------------|----------|
| Starter | £25 | 50 | Basic features |
| Bronze | £45 | 500 | Multi-user |
| Silver | £75 | 1,500 | Automation rules |
| Gold | £115 | 3,000 | Advanced reporting |
| Enterprise | Custom | Unlimited | Custom integration |

### ShipStation Implementation Checklist

- [ ] Create ShipStation account and obtain API credentials
- [ ] Develop `ShipStationService` class for API integration
- [ ] Create shipping quote page/component
- [ ] Implement rate caching with Redis
- [ ] Modify checkout flow to pre-calculate shipping
- [ ] Update `CheckoutsController` to pass pre-calculated rate
- [ ] Create `ShipStationOrderSync` service to create orders after payment
- [ ] Build admin interface for label printing
- [ ] Implement tracking number sync
- [ ] Handle Collection orders separately
- [ ] Set up ShipStation webhooks for status updates
- [ ] Create fallback for API failures

---

## Comparison Table

| Criteria | Stripe Shipping | ShipStation | Winner |
|----------|----------------|-------------|--------|
| **Setup Complexity** | Low (already integrated) | High (new integration) | ✅ Stripe |
| **Development Effort** | 16-24 hours | 60-80 hours | ✅ Stripe |
| **Carrier Flexibility** | None (manual) | High (multi-carrier) | ✅ ShipStation |
| **Real-time Rate Calculation** | Tier-based only | Yes, live quotes | ✅ ShipStation |
| **UK Market Support** | Basic | Excellent | ✅ ShipStation |
| **Monthly Cost** | £0 | £25-150+ | ✅ Stripe |
| **Per-Transaction Cost** | Included in Stripe fees | Label fees apply | ✅ Stripe |
| **Collection/Pickup Handling** | Simple to implement | Requires custom logic | ✅ Stripe |
| **Label Printing** | Not included | Built-in | ✅ ShipStation |
| **Tracking Integration** | Manual | Automated | ✅ ShipStation |
| **Customer Communication** | Manual emails | Automated | ✅ ShipStation |
| **Maintenance Overhead** | Low | Medium | ✅ Stripe |
| **Checkout UX** | Single flow | Two-step | ✅ Stripe |
| **Scalability** | Good | Excellent | ✅ ShipStation |
| **ACP Integration** | Manual | Possible via API | Draw |
| **VAT Handling** | Built-in | Requires config | ✅ Stripe |

### Score Summary

- **Stripe Shipping:** 10 wins
- **ShipStation:** 5 wins
- **Draw:** 1

---

## Implementation Recommendations

### Recommended Approach: Phased Implementation

#### Phase 1: Enhanced Stripe Shipping (Immediate)

**Timeline:** 1-2 weeks  
**Effort:** 16-24 hours  
**Cost:** £0

1. Implement weight-based dynamic shipping calculation
2. Add shipping weight validation for all products
3. Create `ShippingCalculator` service
4. Update checkout to use dynamic rates
5. Add Collection time slot selection (optional)

**Code Structure:**

```ruby
# app/services/shipping_calculator.rb
class ShippingCalculator
  TIERS = {
    standard: { ... },
    express: { ... }
  }.freeze
  
  def initialize(cart_items)
    @cart_items = cart_items
  end
  
  def calculate
    {
      total_weight: total_weight,
      standard_rate: rate_for(:standard),
      express_rate: rate_for(:express),
      shipping_options: build_stripe_options
    }
  end
  
  private
  
  def total_weight
    @total_weight ||= @cart_items.sum { |item| item_weight(item) }
  end
  
  def item_weight(item)
    product = Product.find(item['id'])
    stock = product.stocks.find { |s| s.size == item['size'] }
    (stock&.shipping_weight || product.shipping_weight || 0) * item['quantity'].to_i
  end
  
  def rate_for(tier)
    TIERS[tier].find { |t| total_weight <= t[:max_weight] }[:price]
  end
  
  def build_stripe_options
    # Returns array for Stripe shipping_options
  end
end
```

#### Phase 2: Admin Shipping Tools (Short-term)

**Timeline:** 1 week  
**Effort:** 8-16 hours

1. Admin interface to manage shipping tiers
2. Order shipping label generation helper
3. Tracking number input field on order admin
4. Email customer when tracking added

#### Phase 3: ShipStation Integration (Long-term, If Needed)

**Timeline:** 4-6 weeks  
**Effort:** 60-80 hours

Only proceed if:
- Order volume exceeds 500/month
- Multi-carrier rate shopping provides significant cost savings
- Automated label printing becomes operationally necessary
- ACP International integration is required

### Collection (Pickup) Implementation

For Collection orders, implement:

```ruby
# In shipping options
{
  shipping_rate_data: {
    display_name: 'Collection from Warehouse',
    type: 'fixed_amount',
    fixed_amount: { amount: 0, currency: 'gbp' },
    delivery_estimate: {
      minimum: { unit: 'business_day', value: 1 },
      maximum: { unit: 'business_day', value: 2 }
    },
    metadata: { 
      shipping_type: 'collection',
      collection_address: 'Your Warehouse Address, City, Postcode'
    }
  }
}
```

**Enhanced Collection Features (Optional):**
- Collection date/time slot selection
- Email reminder before collection
- SMS notification when order is ready
- QR code for pickup verification

---

## UK-Specific Requirements

### Royal Mail Integration Considerations

If integrating with Royal Mail (either directly or via ShipStation):

| Service | Use Case | Typical Cost |
|---------|----------|--------------|
| 1st Class | Light items, 2-3 days | From £1.85 |
| 2nd Class | Economy, 3-5 days | From £1.55 |
| Special Delivery | Guaranteed next day | From £6.95 |
| Parcelforce 48 | 2-day tracked | From £8.95 |
| Parcelforce 24 | Next day tracked | From £12.95 |

### VAT Considerations

- UK standard VAT rate: 20%
- VAT applies to shipping costs
- Current implementation uses `inclusive: true` (prices include VAT)
- Stripe Tax can handle this automatically

### Address Format

UK addresses require:
- House number/name
- Street
- Town/City
- County (optional but recommended)
- Postcode (essential for delivery)

Current schema (`addresses` table) already supports this format.

### Postcode Validation

Consider adding postcode validation:

```ruby
# UK postcode regex
UK_POSTCODE_REGEX = /^([A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})$/i

def valid_uk_postcode?(postcode)
  postcode.to_s.strip.match?(UK_POSTCODE_REGEX)
end
```

### Composite Materials Shipping Considerations

For heavy composite materials:

1. **Dimensional weight** may apply (L×W×H ÷ 5000)
2. **Oversized surcharges** for items over standard dimensions
3. **Palletized shipping** for bulk orders
4. **Hazmat considerations** for certain resins (likely not applicable)

---

## Estimated Implementation Effort

### Option 1: Enhanced Stripe Shipping

| Task | Hours | Priority |
|------|-------|----------|
| Create ShippingCalculator service | 4 | High |
| Update CheckoutsController | 4 | High |
| Add weight validation to products | 2 | High |
| Admin shipping tier management | 8 | Medium |
| Collection time slot selection | 6 | Low |
| Testing and QA | 4 | High |
| Documentation | 2 | Medium |
| **Total** | **24-30** | |

### Option 2: ShipStation Integration

| Task | Hours | Priority |
|------|-------|----------|
| ShipStation account setup | 2 | High |
| ShipStationService class | 12 | High |
| Rate caching with Redis | 8 | High |
| Shipping quote page | 12 | High |
| Checkout flow modification | 8 | High |
| Order sync service | 8 | High |
| Admin label printing interface | 12 | Medium |
| Tracking integration | 6 | Medium |
| Webhook handling | 4 | Medium |
| Error handling and fallbacks | 6 | High |
| Testing and QA | 12 | High |
| Documentation | 4 | Medium |
| **Total** | **80-100** | |

---

## Decision Matrix

### When to Choose Stripe Shipping Enhancement

✅ Choose Stripe if:
- Order volume is under 500/month
- Fixed shipping tiers are acceptable
- Collection is a significant portion of orders
- Development resources are limited
- Budget is constrained
- Single checkout flow is preferred
- Already using ACP International with agreed rates

### When to Choose ShipStation

✅ Choose ShipStation if:
- Order volume exceeds 500/month
- Carrier rate shopping would save significant money
- Automated label printing is essential
- Multiple warehouse locations planned
- International shipping is needed
- Order tracking automation is required
- Staff time for shipping operations is a bottleneck

### Hybrid Approach

🔄 Consider hybrid approach:
- Use Stripe for checkout and payment
- Use ShipStation's rate API only (not full integration)
- Display ShipStation rates in Stripe shipping options
- Manual label printing until volume justifies full integration

---

## Appendix

### A. Environment Variables Required

#### For Enhanced Stripe (Existing)
```bash
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_KEY=whsec_xxx
STRIPE_TAX_RATE_ID=txr_xxx  # Optional
```

#### For ShipStation (If Implemented)
```bash
SHIPSTATION_API_KEY=xxx
SHIPSTATION_API_SECRET=xxx
SHIPSTATION_WEBHOOK_SECRET=xxx
REDIS_URL=redis://localhost:6379  # For rate caching
```

### B. Database Migrations (If Needed)

```ruby
# Add tracking number to orders (future enhancement)
class AddTrackingToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :tracking_number, :string
    add_column :orders, :carrier_code, :string
    add_column :orders, :shipped_at, :datetime
    add_index :orders, :tracking_number
  end
end
```

### C. API Endpoints (ShipStation Reference)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/shipments/getrates` | POST | Get shipping rates |
| `/orders` | POST | Create order |
| `/orders/{id}` | GET | Get order details |
| `/orders/createlabelfororder` | POST | Create shipping label |
| `/shipments/{id}` | GET | Get shipment/tracking |
| `/carriers` | GET | List available carriers |

### D. Testing Checklist

- [ ] Test weight calculation with various cart combinations
- [ ] Test Collection option selection
- [ ] Test shipping rate display in Stripe checkout
- [ ] Test order creation with shipping metadata
- [ ] Test webhook handling with shipping data
- [ ] Test admin order view with shipping details
- [ ] Test email templates with shipping information
- [ ] Test edge cases (zero weight, maximum weight)
- [ ] Test error handling for missing product weights

### E. Monitoring and Alerts

Set up monitoring for:
- Stripe webhook delivery failures
- Orders without shipping method selected
- Products without shipping weight defined
- Shipping cost anomalies (unusually high/low)

### F. Future Considerations

1. **International Shipping:** Extend to EU/worldwide with customs handling
2. **Click & Collect Partners:** Partner pickup locations
3. **Shipping Insurance:** Optional insurance for valuable orders
4. **Returns Portal:** Self-service returns with prepaid labels
5. **Carbon Offset:** Optional carbon-neutral shipping
6. **Real-time Tracking Page:** Customer order tracking page

---

## Conclusion

For a UK-based composite materials business with the current technical setup and requirements:

1. **Immediate Recommendation:** Enhance the existing Stripe Checkout shipping with dynamic weight-based pricing. This provides the best balance of functionality, development effort, and cost.

2. **Future Consideration:** Re-evaluate ShipStation integration when order volume justifies the additional complexity and cost, or when multi-carrier rate shopping becomes a competitive necessity.

3. **Collection Handling:** The current approach of treating Collection as a £0 shipping option works well and can be enhanced with time slot selection if needed.

The Stripe-based approach maintains the simplicity of the current architecture while addressing the immediate need for weight-based shipping calculation. The existing integration with ACP International for actual shipping operations can continue unchanged.

---

**Document History:**
- v1.0 (2025-11-30): Initial analysis and recommendations
