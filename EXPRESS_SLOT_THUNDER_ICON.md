# Express Delivery Slot Thunder Icon Implementation

## Overview

This document describes the implementation of CleanCloud-style Express Delivery indicators in the Flutter Schedule screen. A lightning/thunder icon (⚡) appears beside delivery time slots that qualify for Express Delivery (turnaround under 24 hours).

---

## Root Cause (Previous Issue)

The Express Delivery icons were not appearing because:

1. **Date Picker Constraint**: The `getTurnaroundDays()` method returned a minimum of 2 days, preventing users from selecting a delivery date within 24 hours of pickup.

2. **Solution**: Changed `getTurnaroundDays()` to return `0`, allowing same-day delivery. The 4-hour minimum gap is now enforced at the time slot level via `isDeliveryTimeSlotAvailable()`.

---

## Files Modified

| File | Purpose |
|------|---------|
| `lib/modules/schedule/schedule_view.dart` | UI rendering of delivery time slots with express badge |
| `lib/modules/schedule/schedule_controller.dart` | Date picker constraints, slot validation |
| `lib/data/service/express_delivery_service.dart` | Reusable express delivery calculation logic |

---

## How Slot-by-Slot Express Detection Works

### Flow for Each Delivery Slot

```
┌─────────────────────────────────────────────────────────────┐
│ User selects: Pickup Date + Pickup Slot + Delivery Date    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ For EACH delivery time slot in the list:                   │
│                                                             │
│  1. Calculate candidate pickup DateTime                     │
│     → pickupDate + timeSlotStartHours[pickupSlot]          │
│                                                             │
│  2. Calculate candidate delivery DateTime                   │
│     → deliveryDate + timeSlotStartHours[candidateSlot]     │
│                                                             │
│  3. Calculate duration (hours)                              │
│     → (deliveryDateTime - pickupDateTime) / 60 minutes     │
│                                                             │
│  4. Determine:                                              │
│     • isValidGap = duration >= 4 hours                     │
│     • isExpress = duration < 24 hours                      │
│                                                             │
│  5. Render slot row:                                        │
│     • If !isValidGap → Show "(min 4h gap)", disable slot   │
│     • If isValidGap && isExpress → Show ⚡ Express badge   │
│     • If isValidGap && !isExpress → Normal slot, no icon   │
└─────────────────────────────────────────────────────────────┘
```

### Code Location (schedule_view.dart)

```dart
// Inside Obx wrapper for reactive updates
Obx(() {
  final pickupDate = controller.selectedPickupDate.value;
  final pickupSlot = controller.selectedPickupTimeSlot.value;
  final deliveryDate = controller.selectedDeliveryDate.value;
  final selectedDeliverySlot = controller.selectedDeliveryTimeSlot.value;
  
  return Column(
    children: [
      ...controller.timeSlots.map((slot) {
        // Check validity (>= 4 hours)
        final isAvailable = controller.isDeliveryTimeSlotAvailable(slot);
        
        // Check if express (< 24 hours)
        bool wouldBeExpress = false;
        if (isAvailable && pickupDate != null && deliveryDate != null && pickupSlot.isNotEmpty) {
          final result = ExpressDeliveryService.instance.checkExpressDelivery(
            pickupDate: pickupDate,
            pickupTimeSlot: pickupSlot,
            deliveryDate: deliveryDate,
            deliveryTimeSlot: slot,
          );
          wouldBeExpress = result.isExpress;
        }
        
        return RadioListTile(
          title: Row(
            children: [
              Text(slot),
              if (isAvailable && wouldBeExpress) ...[
                // ⚡ Express badge
                Container(
                  child: Row(
                    children: [
                      Icon(Icons.bolt),
                      Text('Express'),
                    ],
                  ),
                ),
              ],
              if (!isAvailable)
                Text('(min 4h gap)'),
            ],
          ),
          onChanged: isAvailable ? (v) => controller.setDeliveryTimeSlot(v) : null,
        );
      }),
    ],
  );
})
```

---

## How Invalid Slots Are Handled

### Validation Logic (schedule_controller.dart)

```dart
bool isDeliveryTimeSlotAvailable(String timeSlot) {
  if (selectedPickupDate.value == null || selectedDeliveryDate.value == null) {
    return true;
  }
  
  final result = ExpressDeliveryService.instance.checkExpressDelivery(
    pickupDate: selectedPickupDate.value,
    pickupTimeSlot: selectedPickupTimeSlot.value,
    deliveryDate: selectedDeliveryDate.value,
    deliveryTimeSlot: timeSlot,
  );
  
  return result.isValidGap;  // true if >= 4 hours
}
```

### UI Behavior for Invalid Slots

- **Text color**: Grey instead of black
- **Label**: Shows "(min 4h gap)" in red
- **Radio button**: Disabled (`onChanged: null`)
- **Tap behavior**: Cannot be selected

---

## UI Change Made

### Before
```
○ 8:00 AM - 10:00 AM
○ 10:00 AM - 12:00 PM
○ 12:00 PM - 2:00 PM
```

### After (with Express Detection)
```
○ 8:00 AM - 10:00 AM   (min 4h gap)  ← Invalid, greyed out
○ 10:00 AM - 12:00 PM  (min 4h gap)  ← Invalid, greyed out
○ 12:00 PM - 2:00 PM   [⚡ Express]   ← Valid, express
● 2:00 PM - 4:00 PM    [⚡ Express]   ← Selected, express (bolder)
○ 4:00 PM - 6:00 PM    [⚡ Express]   ← Valid, express
```

### Badge Styling

| State | Background | Border | Text/Icon Color |
|-------|------------|--------|-----------------|
| Unselected Express | `orange.shade50` | `orange.shade300` | `orange.shade600` |
| Selected Express | `orange.shade200` | `orange.shade600` | `orange.shade800` |

---

## Assumptions

1. **Slot Start Time**: Express calculation uses the **start hour** of each time slot (e.g., "8:00 AM - 10:00 AM" uses 8:00 AM).

2. **Time Slot Strings Must Match**: The slot labels in `ScheduleController.timeSlots` must exactly match the keys in `ExpressDeliveryService.timeSlotStartHours`.

3. **Reactive Updates**: The entire delivery slot column is wrapped in `Obx()` to ensure immediate UI updates when pickup/delivery selections change.

4. **Same-Day Delivery Allowed**: `getTurnaroundDays()` returns 0, allowing the date picker to offer same-day delivery options.

5. **4-Hour Minimum Enforced at Slot Level**: The date picker allows same-day selection; invalid time slots (< 4 hours) are disabled in the UI.

---

## Time Slot Mapping

| Slot Label | Start Hour | End Hour |
|------------|------------|----------|
| 8:00 AM - 10:00 AM | 8 | 10 |
| 10:00 AM - 12:00 PM | 10 | 12 |
| 12:00 PM - 2:00 PM | 12 | 14 |
| 2:00 PM - 4:00 PM | 14 | 16 |
| 4:00 PM - 6:00 PM | 16 | 18 |

---

## Manual QA Checklist

### Test 1: Pickup + Delivery Over 24 Hours (No Icon)
- [ ] Select pickup: March 12, 8:00 AM - 10:00 AM
- [ ] Select delivery: March 14 (2 days later)
- [ ] **Expected**: No ⚡ Express badge on any delivery slot

### Test 2: Pickup + Delivery Under 24 Hours (Icon Shows)
- [ ] Select pickup: March 12, 8:00 AM - 10:00 AM
- [ ] Select delivery: March 12 (same day)
- [ ] **Expected**: ⚡ Express badge appears beside 12:00 PM, 2:00 PM, 4:00 PM slots

### Test 3: Under 4 Hours (Slot Remains Invalid)
- [ ] Select pickup: March 12, 10:00 AM - 12:00 PM
- [ ] Select delivery: March 12 (same day)
- [ ] **Expected**: 
  - 12:00 PM slot shows "(min 4h gap)" and is disabled
  - 2:00 PM and 4:00 PM slots show ⚡ Express badge

### Test 4: Changing Pickup Date Updates Icons
- [ ] Select pickup: March 12, 8:00 AM
- [ ] Select delivery: March 12 (express icons visible)
- [ ] Change pickup to March 11
- [ ] **Expected**: Express icons disappear (delivery is now 24+ hours away)

### Test 5: Changing Pickup Time Updates Icons
- [ ] Select pickup: March 12, 8:00 AM slot
- [ ] Select delivery: March 12 (some express icons visible)
- [ ] Change pickup slot to 4:00 PM - 6:00 PM
- [ ] **Expected**: All March 12 delivery slots now invalid (< 4h gap) except possibly later ones

### Test 6: Changing Delivery Date Updates Icons
- [ ] Select pickup: March 12, 8:00 AM slot
- [ ] Select delivery: March 12 (express icons visible)
- [ ] Change delivery date to March 15
- [ ] **Expected**: All ⚡ Express badges disappear

### Test 7: Selected Express Slot Keeps Icon
- [ ] Select pickup: March 12, 8:00 AM slot
- [ ] Select delivery: March 12, 2:00 PM slot (should show express badge)
- [ ] **Expected**: 
  - Selected slot shows ⚡ Express badge with bolder styling
  - Slot text is bold/primary colored
  - Badge has darker background and border

### Test 8: Edge Case - Exactly 24 Hours
- [ ] Select pickup: March 12, 8:00 AM slot
- [ ] Select delivery: March 13, 8:00 AM slot
- [ ] **Expected**: No ⚡ Express badge (exactly 24h is NOT express, only < 24h)

### Test 9: Edge Case - Exactly 4 Hours
- [ ] Select pickup: March 12, 8:00 AM slot
- [ ] Select delivery: March 12, 12:00 PM slot
- [ ] **Expected**: Slot is VALID (exactly 4h is valid, only < 4h is invalid)

---

## Business Logic (Unchanged)

| Rule | Value | Enforced By |
|------|-------|-------------|
| Express Threshold | < 24 hours | `ExpressDeliveryService.expressThresholdHours` |
| Minimum Gap | >= 4 hours | `ExpressDeliveryService.minimumGapHours` |
| Express Fee | 5% of subtotal | `ExpressDeliveryService.expressRatePercent` |
