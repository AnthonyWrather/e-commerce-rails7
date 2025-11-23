# Material Calculators Domain Documentation

## Overview
The material calculators domain provides specialized tools for calculating composite material quantities, resin amounts, and catalyst measurements for fiberglass/composite material projects. This is a **unique business differentiator** for the e-commerce platform.

## Core Concepts

### Composite Material Mathematics
The calculators are based on industry-standard formulas for composite material projects:

**Key Constants**:
- **Roll Width**: 0.95m (standard fiberglass mat roll width)
- **Resin to Glass Ratio**: 1.6:1 (resin litres per square meter per layer)
- **Wastage Factor**: 15% (industry standard for overlap, trimming, mistakes)

**Material Types** (14 options with weights in g/m²):
1. **Chop Strand Mat**: 300g, 450g, 600g
2. **Plain Weave**: 285g, 400g
3. **Woven Roving**: 450g, 600g, 800g, 900g
4. **Combination Mat**: 450g, 600g, 900g
5. **Biaxial**: 400g, 800g
6. **Gel Coat**: (special case)

### Calculator Types

#### 1. Area Calculator
**Input**: Area (m²), layers, material type, catalyst percentage
**Output**: Mat length, mat weight, resin quantity, catalyst amount, total weight

**Use Case**: When you know the total surface area to be covered

#### 2. Dimensions Calculator
**Input**: Length, width, depth, layers, material type, catalyst percentage
**Output**: Same as Area Calculator

**Use Case**: When you have object dimensions and need to calculate surface area first

#### 3. Mould Rectangle Calculator
**Input**: Length, width, depth, layers, material type, catalyst percentage
**Output**: Same as Area Calculator

**Use Case**: Rectangular mould calculations (all 6 faces)

**Note**: Dimensions and Mould Rectangle controllers are nearly identical in implementation

## Data Flow

### Calculator Workflow

```
1. User Selects Calculator Type
   └─ GET /quantities
      └─ Render calculator selection page

2. User Fills Form
   └─ GET /quantities/{calculator_type}
      ├─ Load calculator page with form
      └─ Show empty results table

3. User Submits Form (GET request)
   └─ GET /quantities/{calculator_type}?params
      ├─ Parse parameters
      ├─ Calculate mat requirements
      ├─ Calculate resin requirements
      ├─ Calculate catalyst requirements
      ├─ Calculate total weight
      ├─ Add 15% wastage to all
      └─ Render results in Turbo Frame

4. Results Displayed
   └─ Turbo Frame updates with results table
      ├─ Mat length (m) and total with wastage
      ├─ Mat weight (kg) and total with wastage
      ├─ Resin (L) and total with wastage
      ├─ Catalyst (ml)
      └─ Total project weight (kg)
```

## Key Components

### Controllers

#### Quantities::AreaController
**Route**: `GET /quantities/area`

**Parameters**:
- `area` - Area in square meters (float, default: 1.0)
- `layers` - Number of layers (integer)
- `material` - Material type g/m² (string, e.g., "300", "450")
- `catalyst` - Catalyst percentage (integer, default: 1)

**Calculation Logic**:
```ruby
def index
  # Parse inputs with defaults
  @area = (params[:area].presence || '1.0').to_f
  @catalyst = (params[:catalyst].presence || '1').to_i
  @material = params[:material].presence || ''
  @material_width = 0.95  # meters
  @ratio = 1.6  # resin to glass ratio
  @layers = params[:layers].to_i

  # Calculate mat length (linear meters)
  @mat = ((@area * @layers) / @material_width).round(2)
  @mat_total = (@mat * 1.15).round(2)  # Add 15% wastage

  # Calculate mat weight (kg)
  @material_weight = @material.to_i / 1000.0  # Convert g/m² to kg/m²
  @mat_kg = ((@area * @layers) * @material_weight).round(2)
  @mat_total_kg = (@mat_kg * 1.15).round(2)

  # Calculate resin (litres)
  @resin = ((@area * @layers) * @ratio).round(2)
  @resin_total = (@resin * 1.15).round(2)

  # Calculate catalyst (millilitres)
  # Formula: (resin_litres / 10) * catalyst_percentage * 100
  @catalyst_ml = (((@resin_total / 10) * @catalyst) * 100).round(2)

  # Calculate total project weight (kg)
  @total_weight = (@mat_total_kg + @resin_total + (@catalyst_ml / 1000)).round(2)
end
```

**Example Calculation**:
```
Input:
  Area: 5 m²
  Layers: 2
  Material: 450g/m²
  Catalyst: 2%

Calculations:
  Mat length = (5 * 2) / 0.95 = 10.53 m
  Mat length (with wastage) = 10.53 * 1.15 = 12.11 m

  Material weight = 450 / 1000 = 0.45 kg/m²
  Mat weight = (5 * 2) * 0.45 = 4.5 kg
  Mat weight (with wastage) = 4.5 * 1.15 = 5.18 kg

  Resin = (5 * 2) * 1.6 = 16 L
  Resin (with wastage) = 16 * 1.15 = 18.4 L

  Catalyst = (18.4 / 10) * 2 * 100 = 368 ml

  Total weight = 5.18 + 18.4 + 0.368 = 23.95 kg
```

#### Quantities::DimensionsController
**Route**: `GET /quantities/dimensions`

**Parameters**:
- `length` - Object length (float)
- `width` - Object width (float)
- `depth` - Object depth (float)
- `layers` - Number of layers (integer)
- `material` - Material type g/m² (string)
- `catalyst` - Catalyst percentage (integer)

**Calculation Logic**:
```ruby
def index
  @length = (params[:length].presence || '1.0').to_f
  @width = (params[:width].presence || '1.0').to_f
  @depth = (params[:depth].presence || '1.0').to_f

  # Calculate total surface area (all faces)
  @area = ((@length * @width) +
           (2 * (@length * @depth)) +
           (2 * (@width * @depth)))

  # Then use same calculations as AreaController
  # ... (mat, resin, catalyst calculations)
end
```

**Surface Area Formula**:
- Top/Bottom: length × width
- Front/Back: length × depth (×2)
- Left/Right: width × depth (×2)
- Total = L×W + 2(L×D) + 2(W×D)

#### Quantities::MouldRectangleController
**Route**: `GET /quantities/mould_rectangle`

**Implementation**: Identical to DimensionsController
**Note**: Separate controller for semantic clarity (mould vs general object)

#### QuantitiesController
**Route**: `GET /quantities`

**Purpose**: Landing page with calculator selection
**Logic**: None (static page with links to calculators)

### Views

#### Calculator Selection Page
**File**: `app/views/quantities/index.html.erb`

**Contents**:
- Breadcrumbs (Home → Quantity Calculator)
- Brief description of calculators
- Links to three calculator types:
  - Calculate by Area
  - Calculate by Dimensions
  - Calculate Mould Rectangle

#### Calculator Forms
**Files**:
- `app/views/quantities/area/index.html.erb`
- `app/views/quantities/dimensions/index.html.erb`
- `app/views/quantities/mould_rectangle/index.html.erb`

**Structure**:
```erb
<!-- Breadcrumbs -->
<%= add_breadcrumb 'Home', :root_path %>
<%= add_breadcrumb 'Quantity Calculator', :quantities_path %>
<%= add_breadcrumb 'Calculate by Area', :quantities_area_path %>

<!-- Form -->
<%= form_with url: quantities_area_path, method: :get do |form| %>
  <!-- Input fields for parameters -->
  <%= form.number_field :area, step: 0.01, min: 0 %>
  <%= form.number_field :layers, min: 1 %>
  <%= form.select :material, options_for_material_types %>
  <%= form.number_field :catalyst, min: 1, max: 5 %>
  <%= form.submit "Calculate" %>
<% end %>

<!-- Results (Turbo Frame) -->
<%= turbo_frame_tag "area" do %>
  <% if @mat.present? %>
    <table>
      <!-- Results rows -->
      <tr><td>Mat Length</td><td><%= @mat %> m</td></tr>
      <tr><td>Mat Length (with wastage)</td><td><%= @mat_total %> m</td></tr>
      <!-- ... more results -->
    </table>
  <% end %>
<% end %>
```

**Form Patterns**:
- GET request (not POST) - results bookmarkable
- Turbo Frame for results section
- Blue-themed table styling
- Form persists input values after submission
- No JavaScript validation (server-side only)

### TypeScript Controller

#### quantities_controller.ts
**Purpose**: Placeholder for future client-side enhancements
**Current State**: Stub implementation

```typescript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  declare readonly outputTarget: HTMLElement

  initialize(): void {
    console.log("Quantities controller initialized")
  }
}
```

**Future Enhancements**:
- Client-side calculation preview
- Input validation
- Unit conversion (metric ↔ imperial)
- Save/load calculation presets

## Calculation Formulas

### Mat Length (Linear Meters)
```
mat_length = (area × layers) / roll_width
mat_length_with_wastage = mat_length × 1.15
```

**Explanation**:
- Area in square meters × number of layers = total coverage needed
- Divide by roll width (0.95m) to get linear meters required
- Add 15% for wastage

### Mat Weight (Kilograms)
```
material_weight_per_m² = material_g_per_m² / 1000
mat_weight = (area × layers) × material_weight_per_m²
mat_weight_with_wastage = mat_weight × 1.15
```

**Explanation**:
- Convert material weight from g/m² to kg/m²
- Multiply by total area (area × layers)
- Add 15% for wastage

### Resin Quantity (Litres)
```
resin = (area × layers) × ratio
resin_with_wastage = resin × 1.15
```

**Explanation**:
- Use 1.6:1 ratio (1.6 litres resin per m² per layer)
- Add 15% for wastage

**Note**: This is an industry approximation. Actual ratio varies by:
- Laminating technique (hand lay-up vs spray)
- Material type and thickness
- Temperature and humidity
- Applicator skill level

### Catalyst Amount (Millilitres)
```
catalyst_ml = ((resin_with_wastage / 10) × catalyst_percentage) × 100
```

**Explanation**:
- Resin in litres / 10 = base amount
- Multiply by catalyst percentage (typically 1-2%)
- Multiply by 100 to convert to millilitres

**Catalyst Percentages**:
- 1% = Standard cure time (~30 minutes gel time)
- 2% = Faster cure (~15 minutes gel time)
- Higher percentages = faster cure but more exothermic reaction (risk of cracking)

### Total Project Weight (Kilograms)
```
total_weight = mat_weight_with_wastage + resin_with_wastage + (catalyst_ml / 1000)
```

**Explanation**:
- Sum of mat weight (kg), resin weight (assuming 1kg/L), catalyst weight (kg)
- Used for shipping calculations

## Business Rules

### Constants
1. **Roll Width**: 0.95m (cannot be changed by user)
2. **Resin Ratio**: 1.6:1 (cannot be changed by user)
3. **Wastage Factor**: 15% (cannot be changed by user)

**Future Enhancement**: Make these configurable in admin settings

### Input Validation
1. **Area/Dimensions**: Must be positive numbers
2. **Layers**: Must be positive integer
3. **Material**: Must be from predefined list
4. **Catalyst**: Typically 1-5% (no hard limit in code)

### Material Types
Currently hardcoded in view with select options:
```erb
<option value="">Select Material</option>
<option value="300">Chop Strand Mat 300g</option>
<option value="450">Chop Strand Mat 450g</option>
<option value="600">Chop Strand Mat 600g</option>
<!-- ... etc -->
```

**Future Enhancement**: Move to database table with admin CRUD

### Precision
- All calculations rounded to 2 decimal places
- Prevents overly precise results that don't match real-world measurements

## Common Patterns

### Parameter Parsing with Defaults
```ruby
@area = (params[:area].presence || '1.0').to_f
@catalyst = (params[:catalyst].presence || '1').to_i
@layers = params[:layers].to_i  # Defaults to 0 if nil
```

### Conditional Rendering
```erb
<% if @mat.present? %>
  <!-- Show results -->
<% else %>
  <!-- Show form only -->
<% end %>
```

### Turbo Frame Updates
```erb
<%= turbo_frame_tag "area" do %>
  <!-- Results rendered here, updates without full page reload -->
<% end %>
```

### Breadcrumb Trail
```ruby
add_breadcrumb 'Home', :root_path
add_breadcrumb 'Quantity Calculator', :quantities_path
add_breadcrumb 'Calculate by Area', :quantities_area_path
```

## Testing Considerations

### Edge Cases
- Zero area/dimensions
- Negative values
- Very large values (overflow?)
- Missing material selection
- Extreme catalyst percentages

### Calculation Accuracy
- Verify formulas against industry standards
- Test with known real-world examples
- Compare with manual calculations

### Precision
- Verify rounding doesn't compound errors
- Test edge cases near rounding boundaries

### Wastage Calculation
- Verify 15% applied to correct values
- Ensure wastage not double-applied

## Known Limitations

1. **Fixed Constants**: Roll width, ratio, wastage cannot be changed
2. **No Unit Conversion**: Metric only (no imperial units)
3. **No Persistence**: Calculations not saved (must recalculate)
4. **No Material Database**: Material types hardcoded in view
5. **Single Ratio**: Assumes 1.6:1 for all materials (not accurate for all)
6. **No Project Saving**: Can't save calculation for later reference
7. **No PDF Export**: Results only viewable on screen
8. **No Email**: Can't send results to customer

## Industry Context

### Composite Materials Overview
- **Fiberglass**: Glass fibers in resin matrix
- **Chop Strand Mat**: Random fiber orientation, general purpose
- **Woven Roving**: Woven fibers, higher strength
- **Biaxial**: Fibers in two directions, specific applications
- **Gel Coat**: Surface finish, not structural

### Typical Applications
- Boat building and repair
- Automotive body work
- Pool and spa construction
- Sculpture and art projects
- Industrial molding

### Calculation Importance
- **Material Waste**: Costly to over-order or run short
- **Project Planning**: Estimate total cost before starting
- **Shipping Weight**: Calculate freight costs
- **Safety**: Catalyst percentage affects cure and heat

## Future Enhancements

### Recommended (Low Effort)
- Save calculation results to PDF
- Email results to customer
- Unit conversion (metric ↔ imperial)
- Print-friendly results page

### Medium Effort
- Material database with admin CRUD
- Configurable constants (roll width, ratio, wastage)
- Project saving (requires customer accounts or email-based retrieval)
- Calculation history

### High Effort
- Advanced calculators (complex shapes, multiple materials)
- Visual shape builder
- Material properties database
- Cost estimation (integrate with product catalog)
- Integration with shopping cart (auto-add calculated materials)

## Integration with E-Commerce

### Current State
- **Standalone**: Calculators separate from product catalog
- **No Cart Integration**: Results don't auto-populate cart
- **Educational**: Helps customers understand material needs

### Potential Integration
1. **Material Linking**: Link material types to actual products
2. **Auto-Add to Cart**: Button to add calculated materials to cart
3. **Bundle Pricing**: Discount for buying complete calculated kits
4. **Project Quotes**: Save calculation and request quote

### Business Value
- **Differentiation**: Unique tool competitors may not offer
- **Education**: Helps customers buy correct amounts
- **Confidence**: Reduces returns and support inquiries
- **Upselling**: Opportunity to suggest related products

