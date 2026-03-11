# EXPRESS SLOT ICON UPDATE

## Overview

This document describes the lightning icon implementation for delivery time slots on the Schedule screen. When a delivery time slot would result in Express Delivery (within 24 hours of pickup), a lightning icon (⚡) appears beside that slot.

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/modules/schedule/schedule_view.dart` | Added lightning icon logic to delivery time slot rows |
| `lib/data/service/express_delivery_service.dart` | Used for express calculation (no changes, reused) |
| `lib/modules/schedule/schedule_controller.dart` | Used for state management (no changes, reused) |

---

## Where Lightning Icon Was Added

### Delivery Time Slot List

**Location:** `lib/modules/schedule/schedule_view.dart` (lines ~310-392)

**Widget:** `RadioListTile<String>` for each delivery time slot

**Visual Result:**
```
○ 8:00 AM - 10:00 AM   ⚡ Express
○ 10:00 AM - 12:00 PM  ⚡ Express
● 12:00 PM - 2:00 PM   ⚡         ← Selected (icon only, no label)
○ 2:00 PM - 4:00 PM    (min 4h gap)  ← Invalid
○ 4:00 PM - 6:00 PM                   ← Standard (no icon)
```

---

## How Express Slot Detection Works

### Code Flow

```dart
// For each delivery time slot:
final isAvailable = controller.isDeliveryTimeSlotAvailable(slot);
final isSelected = controller.selectedDeliveryTimeSlot.value == slot;

// Check if this slot would be express
bool wouldBeExpress = false;
if (isAvailable && 
    controller.selectedPickupDate.value != null &&
    controller.selectedDeliveryDate.value != null &&
    controller.selectedPickupTimeSlot.value.isNotEmpty) {
  
  final result = ExpressDeliveryService.instance.checkExpressDelivery(
    pickupDate: controller.selectedPickupDate.value,
    pickupTimeSlot: controller.selectedPickupTimeSlot.value,
    deliveryDate: controller.selectedDeliveryDate.value,
    deliveryTimeSlot: slot,  // Test each slot
  );
  wouldBeExpress = result.isExpress;
}
```

### Express Calculation (via ExpressDeliveryService)

1. Parse pickup date + time slot → pickup DateTime
2. Parse delivery date + time slot → delivery DateTime
3. Calculate duration in hours between them
4. If duration < 24 hours → `isExpress = true`
5. If duration < 4 hours → `isValidGap = false` (slot disabled)

---

## UI Behavior Changes

| Condition | Slot State | Icon | Label |
|-----------|------------|------|-------|
| Pickup not selected | Disabled | None | - |
| Delivery date not selected | Available | None | - |
| Duration < 4h | Invalid | None | "(min 4h gap)" in red |
| Duration 4h - 24h | Express | ⚡ | "Express" (unselected) |
| Duration 4h - 24h (selected) | Express | ⚡ | None (cleaner) |
| Duration > 24h | Standard | None | - |

### Icon Styling

```dart
Icon(
  Icons.bolt,
  size: 16,
  color: isSelected 
      ? Colors.orange.shade700   // Brighter when selected
      : Colors.orange.shade400,  // Dimmer when unselected
)
```

### Label Styling (unselected express slots only)

```dart
Text(
  'Express',
  style: TextStyle(
    fontSize: 10,
    color: Colors.orange.shade500,
    fontWeight: FontWeight.w500,
  ),
)
```

---

## Reactive Updates

The express icons update automatically when:

| User Action | Effect |
|-------------|--------|
| Change pickup date | All delivery slots recalculate express status |
| Change pickup time slot | All delivery slots recalculate express status |
| Change delivery date | All delivery slots recalculate express status |
| Select a delivery slot | Icon stays visible, "Express" label hides |

This is achieved via `Obx(() { ... })` wrapping each slot, which rebuilds when reactive values change.

---

## Assumptions

1. **Icon choice:** `Icons.bolt` provides a clear lightning symbol
2. **Color scheme:** Orange color family matches express branding elsewhere
3. **Label visibility:** "Express" label hides on selection to reduce clutter
4. **Size:** 16px icon is visible but not oversized
5. **Spacing:** 6px gap between slot text and icon

---

## Manual QA Checklist

### Setup
- [ ] Navigate to Schedule screen
- [ ] Select any item/service to have an order

### Express Detection Tests

| Test | Steps | Expected |
|------|-------|----------|
| **No pickup selected** | Don't select pickup date | All slots show no icon |
| **Pickup selected, no delivery date** | Select pickup date/slot only | Slots show no icon yet |
| **Standard delivery (>24h)** | Pickup: Today 8AM, Delivery: Tomorrow+1 8AM | No lightning icon |
| **Express delivery (<24h)** | Pickup: Today 8AM, Delivery: Tomorrow 8AM | Lightning icon + "Express" |
| **Same day express** | Pickup: Today 8AM, Delivery: Today 4PM | Lightning icon + "Express" |
| **Invalid (<4h gap)** | Pickup: Today 2PM, Delivery: Today 4PM | Shows "(min 4h gap)" |

### Slot Selection Tests

| Test | Steps | Expected |
|------|-------|----------|
| **Select express slot** | Click on slot with lightning icon | Icon stays, "Express" label hides |
| **Change to non-express** | Select later delivery date | Icons disappear from slots |
| **Re-select express** | Select earlier delivery date | Icons reappear on qualifying slots |

### Reactive Update Tests

| Test | Steps | Expected |
|------|-------|----------|
| **Change pickup date** | After setting delivery, change pickup | Icons update based on new gap |
| **Change pickup slot** | Change from 8AM to 4PM pickup | Icons update (some slots may lose icon) |
| **Change delivery date** | Change delivery date forward/back | Icons update accordingly |

### Edge Cases

| Test | Steps | Expected |
|------|-------|----------|
| **All slots express** | Same day, all valid slots | All show lightning icon |
| **No slots express** | Delivery 3+ days later | No slots show lightning icon |
| **Mixed validity** | Same day delivery | Some invalid (4h), some express |

### Consistency Tests

- [ ] Express banner below slots matches icon state
- [ ] Order summary shows express fee when express slot selected
- [ ] Payment sheet shows express indicator when express slot selected

---

## No Business Logic Changes

✅ Express detection logic: **UNCHANGED** (reused from `ExpressDeliveryService`)  
✅ 4-hour minimum gap: **UNCHANGED**  
✅ 5% express fee: **UNCHANGED**  
✅ Payment calculations: **UNCHANGED**  

---

## Code Reference

### Full Delivery Slot Implementation

```dart
...controller.timeSlots.map(
  (slot) => Obx(() {
    final isAvailable = controller.isDeliveryTimeSlotAvailable(slot);
    final isSelected = controller.selectedDeliveryTimeSlot.value == slot;
    
    // Check if this slot would be express
    bool wouldBeExpress = false;
    if (isAvailable && 
        controller.selectedPickupDate.value != null &&
        controller.selectedDeliveryDate.value != null &&
        controller.selectedPickupTimeSlot.value.isNotEmpty) {
      final result = ExpressDeliveryService.instance.checkExpressDelivery(
        pickupDate: controller.selectedPickupDate.value,
        pickupTimeSlot: controller.selectedPickupTimeSlot.value,
        deliveryDate: controller.selectedDeliveryDate.value,
        deliveryTimeSlot: slot,
      );
      wouldBeExpress = result.isExpress;
    }
    
    return RadioListTile<String>(
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14,
                    color: isAvailable ? Colors.black : Colors.grey,
                  ),
                ),
                // Show lightning icon for express slots
                if (isAvailable && wouldBeExpress) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: isSelected 
                        ? Colors.orange.shade700 
                        : Colors.orange.shade400,
                  ),
                  if (!isSelected)
                    Text(
                      'Express',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (!isAvailable)
            Text(
              '(min 4h gap)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red.shade400,
              ),
            ),
        ],
      ),
      value: slot,
      groupValue: controller.selectedDeliveryTimeSlot.value,
      onChanged: isAvailable
          ? (v) => controller.setDeliveryTimeSlot(v ?? '')
          : null,
      // ... styling props
    );
  }),
),
```

---

## Version

- **Implementation Date**: 2025
- **Icon Used**: `Icons.bolt`
- **Express Threshold**: 24 hours
- **Minimum Gap**: 4 hours
