# Flash Message Flow - Before and After Fix

## Before Fix (Broken Behavior)

```
┌─────────────────────────────────────────────────────────────────┐
│ Admin creates a product                                          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 1: POST /admin/products                                  │
│ Controller sets flash[:notice] = "Product was successfully..."   │
│ Response: Redirect to /admin/products/123                        │
│ Session: {flash: {notice: "Product was successfully..."}}        │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 2: GET /admin/products/123                               │
│ View renders flash message                                       │
│ Stimulus controller auto-dismisses after 3 seconds              │
│ Session: {flash: {notice: "Product was successfully..."}} ← STILL THERE! │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Admin navigates to Categories page                              │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 3: GET /admin/categories                                 │
│ View renders flash message AGAIN! ← PROBLEM!                    │
│ Session: {flash: {}} ← Only cleared after 2nd display           │
└─────────────────────────────────────────────────────────────────┘
```

## After Fix (Correct Behavior)

```
┌─────────────────────────────────────────────────────────────────┐
│ Admin creates a product                                          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 1: POST /admin/products                                  │
│ Controller sets flash[:notice] = "Product was successfully..."   │
│ Response: Redirect to /admin/products/123                        │
│ Session: {flash: {notice: "Product was successfully..."}}        │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 2: GET /admin/products/123                               │
│ View renders flash message                                       │
│ after_action :discard_flash runs                                 │
│ flash.discard marks all messages for removal                     │
│ Session: {flash: {}} ← CLEARED IMMEDIATELY!                      │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Admin navigates to Categories page                              │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Request 3: GET /admin/categories                                 │
│ No flash messages to display ← FIXED!                           │
│ Session: {flash: {}}                                             │
└─────────────────────────────────────────────────────────────────┘
```

## Code Flow

### AdminController

```ruby
class AdminController < ApplicationController
  after_action :discard_flash  # ← Runs after every action

  def index
    # ... dashboard logic ...
  end

  private

  def discard_flash
    flash.discard  # ← Marks all flash messages for immediate removal
  end
end
```

### What `flash.discard` does:

1. **Without discard (default Rails behavior):**
   - Flash messages persist for 1 additional request after being displayed
   - `flash[:notice] = "msg"` → Request 1 (display) → Request 2 (display again) → Request 3 (cleared)

2. **With discard (our fix):**
   - Flash messages cleared immediately after being displayed
   - `flash[:notice] = "msg"` → Request 1 (display) → Request 2 (cleared)

### Controller Action Flow:

```
┌──────────────────────────────────────────────────────────────┐
│ 1. before_action :authenticate_admin_user!                   │
│    └─ Ensure admin is logged in                             │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ 2. Controller action executes (create/update/destroy)        │
│    └─ Business logic runs, flash message may be set          │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ 3. View renders (if not redirecting)                         │
│    └─ Flash messages displayed in _flash_messages.html.erb   │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ 4. after_action :discard_flash                               │
│    └─ flash.discard clears all messages from session         │
└──────────────────────────────────────────────────────────────┘
```

## Testing Verification

### Unit Test Flow:

```ruby
test 'flash messages are cleared after create action' do
  # Create a product → sets flash message
  post admin_products_url, params: { ... }
  
  # Follow redirect → flash displayed
  follow_redirect!
  assert_not flash.empty?  # ✓ Flash exists
  
  # Navigate to another page → flash should be cleared
  get admin_path
  assert flash.empty?  # ✓ Flash is empty (FIXED!)
end
```

### System Test Flow:

```ruby
test 'flash messages do not persist when navigating' do
  # Create product
  visit new_admin_product_path
  fill_in 'Name', with: 'Test Product'
  click_button 'Create Product'
  
  # Verify flash appears
  assert_selector '#flash-messages', text: 'successfully created'
  
  # Navigate to different page
  visit admin_categories_path
  
  # Verify flash does NOT appear (FIXED!)
  assert_no_selector '#flash-messages', text: 'successfully created'
end
```

## Key Points

1. **Minimal Change**: One line added to base controller affects all admin pages
2. **Rails Convention**: Uses built-in `flash.discard` method
3. **Inheritance**: All admin controllers inherit from AdminController
4. **No Breaking Changes**: Public-facing pages unaffected
5. **Well Tested**: 6 unit tests + 5 system tests = 11 total test cases
