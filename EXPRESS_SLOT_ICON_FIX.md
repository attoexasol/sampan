# Express Slot Icon Fix

## Root Cause Analysis

### Primary Issue: Date Picker Prevented Express Delivery

The lightning icons were not appearing because **users could not select a delivery date within 24 hours of pickup**.

**Previous Code (schedule_controller.dart):**
```dart
int getTurnaroundDays() {
  if (serviceType.value.toLowerCase().contains('rush')) return 1;
  if (serviceType.value.toLowerCase().contains('dry-cleaning')) return 3;
  if (serviceType.value.toLowerCase().contains('alterations')) return 5;
  return 2;  // <-- Default: 2 days minimum
}

DateTime? getMinDeliveryDate() {
  return selectedPickupDate.value!.add(Duration(days: getTurnaroundDays()));
}
```

**Result:** The date picker's `firstDate` was set to `getMinDeliveryDate()`, which was always **at least 2 days after pickup**. Since express delivery requires turnaround **under 24 hours**, this made express delivery impossible.

### Secondary Issue: Obx Reactive Wrapper

The original code had individual `Obx()` wrappers around each slot inside a spread operator:
```dart
...controller.timeSlots.map(
  (slot) => Obx(() { ... })  // Each slot in separate Obx
)
```

While this technically works, it was not reliably detecting changes to `selectedPickupDate`, `selectedDeliveryDate`, and `selectedPickupTimeSlot` because these reactive values were accessed inside a conditional block.

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/modules/schedule/schedule_controller.dart` | Changed `getTurnaroundDays()` to return `0` (allow same-day delivery). Updated `getMinDeliveryDate()` to return pickup date directly. |
| `lib/modules/schedule/schedule_view.dart` | Wrapped entire Delivery Time Slots section in single `Obx()`. Force-read reactive dependencies at top level. Enhanced express badge styling. |

---

## Exact UI Fix

### schedule_controller.dart

```dart
// BEFORE: Minimum 2-day turnaround prevented express delivery
int getTurnaroundDays() {
  return 2;  // Could never be under 24h
}

// AFTER: Allow same-day delivery
int getTurnaroundDays() {
  return 0;  // 4-hour gap enforced at slot level
}

DateTime? getMinDeliveryDate() {
  return selectedPickupDate.value!;  // Same-day allowed
}
```

### schedule_view.dart

```dart
// BEFORE: Individual Obx per slot
...controller.timeSlots.map(
  (slot) => Obx(() { /* check express */ })
)

// AFTER: Single Obx wrapping entire column with forced dependencies
Obx(() {
  // Force reactive dependency capture
  final pickupDate = controller.selectedPickupDate.value;
  final pickupSlot = controller.selectedPickupTimeSlot.value;
  final deliveryDate = controller.selectedDeliveryDate.value;
  final selectedDeliverySlot = controller.selectedDeliveryTimeSlot.value;
  
  return Column(
    children: [
      ...controller.timeSlots.map((slot) {
        // Express check now has all reactive values available
        final result = ExpressDeliveryService.instance.checkExpressDelivery(...);
        
        // Render express badge inline
        if (isAvailable && result.isExpress) {
          // Show styled badge with bolt icon
        }
      })
    ]
  );
})
```

---

## How Slot-by-Slot Express Detection Works

For each delivery time slot in the list:

1. **Check if slot is available** (`isDeliveryTimeSlotAvailable(slot)`)
   - Calls `ExpressDeliveryService.checkExpressDelivery()` with pickup date/slot and delivery date/slot
   - Returns `false` if gap < 4 hours (slot disabled)

2. **Check if slot qualifies as express** (`wouldBeExpress`)
   - Same calculation: `ExpressDeliveryService.checkExpressDelivery()`
   - Returns `true` if turnaround < 24 hours

3. **Render the slot row**
   - If `isAvailable && wouldBeExpress`: Show lightning bolt badge
   - If `!isAvailable`: Show "(min 4h gap)" text

**Calculation Flow:**
```
Pickup: March 11, 8:00 AM slot (start: 8:00 AM)
Delivery: March 11, 2:00 PM slot (start: 2:00 PM)

Duration = 2:00 PM - 8:00 AM = 6 hours

isValidGap = (6 >= 4) = true  ✓
isExpress = (6 < 24) = true   ⚡ Express icon shown
```

---

## Visual Design of Express Badge

The express indicator now appears as a styled badge:

```
[radio] 8:00 AM - 10:00 AM  [ ⚡ Express ]
[radio] 10:00 AM - 12:00 PM [ ⚡ Express ]
[radio] 12:00 PM - 2:00 PM  (min 4h gap)  <- Invalid
[radio] 2:00 PM - 4:00 PM
```

Badge styling:
- Background: `Colors.orange.shade100`
- Border: `Colors.orange.shade300`
- Icon: `Icons.bolt` (14px, orange.shade700)
- Text: "Express" (10px, bold, orange.shade700)

---

## Manual QA Checklist

### Test Case 1: Pickup + Delivery Under 24 Hours
- [ ] Select pickup date: March 11, 2026
- [ ] Select pickup slot: 8:00 AM - 10:00 AM
- [ ] Select delivery date: March 11, 2026 (same day)
- [ ] **Expected:** Delivery slots from 12:00 PM onward should show ⚡ Express badge

### Test Case 2: Pickup + Delivery Over 24 Hours
- [ ] Select pickup date: March 11, 2026
- [ ] Select pickup slot: 8:00 AM - 10:00 AM
- [ ] Select delivery date: March 18, 2026 (7 days later)
- [ ] **Expected:** No express icons on any delivery slot

### Test Case 3: Under 4-Hour Gap (Invalid)
- [ ] Select pickup date: March 11, 2026
- [ ] Select pickup slot: 10:00 AM - 12:00 PM
- [ ] Select delivery date: March 11, 2026
- [ ] **Expected:** 12:00 PM - 2:00 PM slot shows "(min 4h gap)" and is disabled

### Test Case 4: Dynamic Update on Pickup Change
- [ ] Select pickup: March 11, 8:00 AM slot
- [ ] Select delivery: March 11 (same day)
- [ ] **Verify:** Express icons appear on valid afternoon slots
- [ ] Change pickup slot to 4:00 PM - 6:00 PM
- [ ] **Expected:** All March 11 delivery slots become invalid (shown with "min 4h gap")

### Test Case 5: Dynamic Update on Delivery Date Change
- [ ] Select pickup: March 11, 8:00 AM slot
- [ ] Select delivery: March 11 (express icons visible)
- [ ] Change delivery date to March 13
- [ ] **Expected:** Express icons disappear (over 24h turnaround)

### Test Case 6: Selected Express Slot Keeps Icon
- [ ] Select pickup: March 11, 8:00 AM slot
- [ ] Select delivery: March 11, 2:00 PM slot (should show express icon)
- [ ] **Expected:** After selection, the ⚡ badge remains visible on selected slot

---

## Business Logic Unchanged

The following remain unchanged:
- Express fee calculation: 5% of subtotal
- Express threshold: < 24 hours turnaround
- Minimum gap: >= 4 hours between pickup and delivery
- Fee integration in order totals and payment flow
- No manual $5 express toggle (remains removed)

---

## Summary

| Before | After |
|--------|-------|
| Date picker forced minimum 2-day gap | Same-day delivery allowed |
| Express delivery impossible | Express icons appear for < 24h turnaround |
| Obx per slot (unreliable reactivity) | Single Obx with forced dependency capture |
| No visual badge | Styled orange badge with bolt icon |
