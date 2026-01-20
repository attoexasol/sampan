# Laundry Page Refactoring Plan

## 📁 Recommended Folder Structure

```
lib/
├── modules/
│   └── laundry/
│       ├── laundry_controller.dart ✅ (Created)
│       ├── laundry_view.dart (Main view - to be created)
│       ├── laundry_binding.dart (Update existing)
│       └── widgets/
│           ├── how_it_works_card.dart
│           ├── premium_bag_card.dart
│           ├── subscription_card.dart
│           ├── pay_as_you_go_card.dart
│           ├── bulky_items_section.dart (API-driven)
│           ├── express_service_card.dart
│           ├── special_instructions_card.dart
│           ├── order_summary_section.dart
│           ├── how_we_care_card.dart
│           └── more_about_services_card.dart
```

## 🎯 LaundryController Responsibilities

**Created in:** `lib/modules/laundry/laundry_controller.dart`

### Key Responsibilities:
1. ✅ **Load Bulky Items from API**
   - Fetches products from `ProductsController`
   - Filters for bulky items (laundry category)
   - Manages loading state (`isLoadingBulkyItems`)

2. ✅ **Manage Service Selections**
   - Premium Bag (`isPremiumBagSelected`)
   - Subscriptions (`isSubscriptionSelected`)
   - Pay As You Go (`isPayAsYouGoSelected`)
   - Express Service (`isExpressServiceSelected`)

3. ✅ **Manage Bulky Item Quantities**
   - `updateBulkyItemQuantity()`
   - `incrementBulkyItem()`
   - `decrementBulkyItem()`
   - Integrates with `OrderSummaryController`

4. ✅ **Manage Special Instructions**
   - `specialInstructions` (reactive)
   - `specialInstructionsController` (TextEditingController)

5. ✅ **Update Order Summary**
   - Automatically syncs service selections to `OrderSummaryController`
   - Provides `getOrderSummarySnapshot()` for navigation

## 📦 Widget Breakdown

### 1. `how_it_works_card.dart`
**Type:** Static informational card  
**Reusable:** ✅ Yes  
**Content:**
- Three icons: Select (Pickup Time), Wash (Full Load), Enjoy (Clean Clothes)
- Static content, no API dependency

### 2. `premium_bag_card.dart`
**Type:** Service selection card  
**Reusable:** ✅ Yes  
**Props:**
- `isSelected` (bool)
- `onToggle` (VoidCallback)
- Price: $20/bag
- Description & bullet points

### 3. `subscription_card.dart`
**Type:** Service selection card  
**Reusable:** ✅ Yes  
**Props:**
- `isSelected` (bool)
- `onToggle` (VoidCallback)
- Price: $18/bag
- "Most Popular" badge
- Description & bullet points

### 4. `pay_as_you_go_card.dart`
**Type:** Service selection card  
**Reusable:** ✅ Yes  
**Props:**
- `isSelected` (bool)
- `onToggle` (VoidCallback)
- Price: $2.25/lb
- Description & bullet points

### 5. `bulky_items_section.dart` ⚠️ **API-DRIVEN**
**Type:** Dynamic section with API integration  
**Reusable:** ⚠️ Specific to Laundry (but pattern is reusable)  
**Props:**
- `controller` (LaundryController)
- Loads items from `controller.bulkyItems` (from API)
- Each item shows: name, price, +/- quantity buttons
- Uses `Obx()` for reactive updates
- Handles loading state

**Key Implementation:**
```dart
Obx(() {
  if (controller.isLoadingBulkyItems.value) {
    return CircularProgressIndicator();
  }
  
  return Column(
    children: controller.bulkyItems.map((product) {
      final qty = controller.getBulkyItemQuantity(product.id);
      return BulkyItemCard(
        product: product,
        quantity: qty,
        onIncrement: () => controller.incrementBulkyItem(product),
        onDecrement: () => controller.decrementBulkyItem(product),
      );
    }).toList(),
  );
})
```

### 6. `express_service_card.dart`
**Type:** Optional service card  
**Reusable:** ✅ Yes  
**Props:**
- `isSelected` (bool)
- `onToggle` (VoidCallback)
- Price: +$5.00
- Red-themed styling

### 7. `special_instructions_card.dart`
**Type:** Input card  
**Reusable:** ✅ Yes  
**Props:**
- `controller` (TextEditingController)
- Manages special instructions text
- Single TextField with placeholder

### 8. `order_summary_section.dart`
**Type:** Reactive summary card  
**Reusable:** ✅ Yes (can reuse `OrderSummaryCard` widget)  
**Props:**
- `orderController` (OrderSummaryController)
- Uses `Obx()` to reactively update
- Shows: items, subtotal, delivery fee, tax, total
- Empty state when no items selected

### 9. `how_we_care_card.dart`
**Type:** Expandable informational card  
**Reusable:** ✅ Yes  
**Props:**
- `isExpanded` (bool, optional)
- Static content about cleaning process
- Can use `ExpansionTile` or custom expandable widget

### 10. `more_about_services_card.dart`
**Type:** FAQ-style expandable card  
**Reusable:** ✅ Yes  
**Props:**
- Multiple expandable sections
- Static content
- Uses `ExpansionTile` for each section

## 🔌 API Integration for Bulky Items

### Current Flow:
1. `ProductsController` loads all products on app init (via `onInit()`)
2. Products are cached in `LocalStore` (24hr TTL)
3. `LaundryController.loadBulkyItems()`:
   - Gets products from `ProductsController.products`
   - Filters using `ProductsService.filterByCategory(category, ProductCategory.laundry)`
   - Stores in `bulkyItems` (reactive list)

### API Endpoint:
- URL: `https://cleancloudapp.com/api/getProducts`
- Method: POST
- Body: `{"api_token": "..."}`
- Response: `ProductsResponse` with `Products[]` array

### Filtering Logic:
Currently filters by `ProductCategory.laundry` which includes sections `['7', '11']`.

**If you need to filter ONLY bulky items**, you may need to:
- Filter by product name (contains "Bulky", "Duvet", "Pillow", etc.)
- Or add a category/type field in API response
- Or filter by specific section IDs if API provides them

## 🔄 Integration with OrderSummaryController

### How It Works:
1. `LaundryController` holds reference to `OrderSummaryController`:
   ```dart
   final orderCtrl = Get.find<OrderSummaryController>();
   ```

2. When service is toggled, updates `OrderSummaryController`:
   ```dart
   void togglePremiumBag() {
     isPremiumBagSelected.value = !isPremiumBagSelected.value;
     if (isPremiumBagSelected.value) {
       orderCtrl.updateItem(
         key: 'premium_bag',
         title: 'Premium Bag',
         subtitle: 'Premium Bag Service',
         price: 20.0,
         qty: 1,
       );
     } else {
       orderCtrl.items.remove('premium_bag');
     }
   }
   ```

3. Bulky items use same pattern:
   ```dart
   void incrementBulkyItem(Product product) {
     orderCtrl.incrementItem(
       key: product.id,
       title: product.name,
       subtitle: '${product.pieces} piece(s)',
       price: product.price,
     );
   }
   ```

4. Navigation to ScheduleView:
   ```dart
   Get.toNamed(
     Routes.SCHEDULE,
     arguments: {
       'orderSummary': controller.getOrderSummarySnapshot(),
     },
   );
   ```

## 📋 Main LaundryView Structure

```dart
class LaundryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(), // Existing header
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    // 1. How It Works Card
                    HowItWorksCard(),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 2. Premium Bag Card
                    PremiumBagCard(
                      isSelected: controller.isPremiumBagSelected.value,
                      onToggle: () => controller.togglePremiumBag(),
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 3. Subscriptions Card
                    SubscriptionCard(
                      isSelected: controller.isSubscriptionSelected.value,
                      onToggle: () => controller.toggleSubscription(),
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 4. Pay As You Go Card
                    PayAsYouGoCard(
                      isSelected: controller.isPayAsYouGoSelected.value,
                      onToggle: () => controller.togglePayAsYouGo(),
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 5. Bulky Items Section (API-driven)
                    BulkyItemsSection(controller: controller),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 6. Express Service Card
                    ExpressServiceCard(
                      isSelected: controller.isExpressServiceSelected.value,
                      onToggle: () => controller.toggleExpressService(),
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 7. Special Instructions Card
                    SpecialInstructionsCard(
                      controller: controller.specialInstructionsController,
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 8. Order Summary Section
                    OrderSummarySection(
                      orderController: controller.orderCtrl,
                    ),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 9. How We Care Card
                    HowWeCareCard(),
                    
                    SizedBox(height: AppSizes.md),
                    
                    // 10. More About Services Card
                    MoreAboutServicesCard(),
                    
                    SizedBox(height: AppSizes.xl),
                    
                    // Action Buttons
                    _buildActionButtons(controller),
                    
                    SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## ✅ Next Steps

1. ✅ LaundryController created
2. ⏳ Update LaundryBinding
3. ⏳ Create widget files (10 widgets)
4. ⏳ Create main LaundryView
5. ⏳ Update navigation from HomeScreen
6. ⏳ Test API integration for bulky items

## 📝 Notes

- All widgets should use `AppColors` and `AppSizes` for consistency
- Use `Obx()` for reactive updates in widgets
- Break large widgets into smaller methods if needed
- Follow existing design patterns from `laundry_how_it_works.dart`
- Ensure proper disposal of controllers in `onClose()`
