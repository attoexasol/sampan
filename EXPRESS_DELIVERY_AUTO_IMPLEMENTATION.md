# EXPRESS DELIVERY AUTO IMPLEMENTATION

## Overview

This document describes the implementation of **automatic Express Delivery** for the Sampan CleanCloud Flutter app. Express delivery is now automatically detected based on the pickup and delivery schedule, replacing the old manual $5 flat fee toggle.

---

## Express Delivery Rules

| Rule | Value |
|------|-------|
| **Express Threshold** | Delivery within **24 hours** of pickup |
| **Express Fee** | **5%** of order subtotal |
| **Minimum Gap** | **4 hours** between pickup and delivery |
| **Invalid Selection** | Gap < 4 hours → **Checkout blocked** |

---

## Changes Made

### 1. New Files Created

#### `lib/data/service/express_delivery_service.dart`
Reusable helper service for express delivery detection and validation.

**Features:**
- `parsePickupDateTime()` - Convert date + time slot to DateTime
- `parseDeliveryDateTime()` - Convert date + time slot to DateTime  
- `calculateDurationHours()` - Calculate hours between pickup and delivery
- `checkExpressDelivery()` - Returns `ExpressDeliveryResult` with:
  - `isExpress` - true if duration < 24h
  - `isValidGap` - true if duration >= 4h
  - `durationHours` - actual duration
  - `message` - user-friendly message
- `calculateExpressFee()` - Calculate 5% fee based on subtotal

---

### 2. Files Modified

#### `lib/controller/order_summary_controller.dart`
- Added `isExpressDelivery` reactive variable
- Added `expressDurationHours` reactive variable
- Added `expressFee` getter (5% of subtotal if express)
- Updated `grandTotal` to include `expressFee`
- Added `setExpressDelivery()` method to update state
- Added `resetExpressDelivery()` method
- Updated `snapshot()` to include express fee data

#### `lib/modules/schedule/schedule_controller.dart`
- Added import for `ExpressDeliveryService`
- Added `isExpressDelivery` reactive variable
- Added `isValidDeliveryGap` reactive variable
- Added `deliveryDurationHours` reactive variable
- Added `expressDeliveryMessage` reactive variable
- Added `_updateExpressDeliveryState()` method - called on date/time changes
- Added `setPickupTimeSlot()` method - validates and updates state
- Added `setDeliveryTimeSlot()` method - validates and blocks invalid selections
- Added `expressFee` getter
- Added `canProceedToCheckout` getter
- Added `orderTotalsWithExpress` getter
- Updated `grandTotal` to include express fee
- Updated `isDeliveryTimeSlotAvailable()` to use 4h validation
- Updated date/time selection methods to trigger state updates

#### `lib/modules/schedule/schedule_view.dart`
- Updated pickup time slot selection to use `setPickupTimeSlot()`
- Updated delivery time slot selection to use `setDeliveryTimeSlot()`
- Added "(min 4h gap)" indicator on unavailable time slots
- Added Express Delivery indicator after time slot selection
- Added express fee to OrderSummaryCard props
- Updated payment bottom sheet to:
  - Block checkout if gap < 4h
  - Show Express Delivery indicator with fee
  - Use grandTotal that includes express fee

#### `lib/widgets/order_summary_card_widget.dart`
- Added `expressFee` parameter (default 0.0)
- Added `isExpressDelivery` parameter (default false)
- Added Express Fee row in totals section (orange with flash icon)
- Updated `_buildSummaryRow()` to support express styling

#### `lib/modules/laundry/laundry_controller.dart`
- Removed `isExpressServiceSelected` reactive variable
- Removed `expressServicePrice` constant ($5)
- Removed `toggleExpressService()` method
- Removed express service from `_updateOrderSummary()`
- Added comments explaining automatic express detection

#### `lib/modules/laundry/widgets/express_service_card.dart`
- **Completely replaced** - now shows informational card about automatic express delivery
- Explains: 24h threshold, 5% fee, 4h minimum gap
- No longer has manual toggle button

---

## Express Logic Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER SELECTS SCHEDULE                         │
├─────────────────────────────────────────────────────────────────┤
│  1. User selects Pickup Date                                    │
│  2. User selects Pickup Time Slot                               │
│  3. User selects Delivery Date                                  │
│  4. User selects Delivery Time Slot                             │
│         ↓                                                        │
│  ScheduleController._updateExpressDeliveryState()               │
│         ↓                                                        │
│  ExpressDeliveryService.checkExpressDelivery()                  │
│         ↓                                                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Calculate duration between pickup and delivery          │    │
│  │ • duration < 4h  → isValidGap = false, BLOCK CHECKOUT   │    │
│  │ • duration < 24h → isExpress = true, ADD 5% FEE         │    │
│  │ • duration >= 24h → Standard delivery, NO EXPRESS FEE   │    │
│  └─────────────────────────────────────────────────────────┘    │
│         ↓                                                        │
│  Update UI:                                                      │
│  • Show Express Delivery indicator (orange badge)               │
│  • Update Order Summary with express fee                        │
│  • Update Grand Total                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4-Hour Validation

Invalid time slots are automatically disabled:

```dart
bool isDeliveryTimeSlotAvailable(String timeSlot) {
  final result = ExpressDeliveryService.instance.checkExpressDelivery(
    pickupDate: selectedPickupDate.value,
    pickupTimeSlot: selectedPickupTimeSlot.value,
    deliveryDate: selectedDeliveryDate.value,
    deliveryTimeSlot: timeSlot,
  );
  return result.isValidGap; // Must be >= 4 hours
}
```

If user somehow gets past this (e.g., date changes after selection), checkout is blocked:

```dart
void _showPaymentBottomSheet(BuildContext context) {
  if (!controller.canProceedToCheckout) {
    Get.snackbar('Invalid Schedule', 
      'Minimum 4 hours required between pickup and delivery');
    return;
  }
  // ... proceed to payment
}
```

---

## Express Fee Calculation

```dart
double get expressFee {
  if (!isExpressDelivery.value) return 0.0;
  return subTotal * 0.05; // 5% of subtotal
}

double get grandTotal => subTotal + deliveryFee + expressFee + tax;
```

---

## Removed Old Logic

### Old Implementation (REMOVED)
- `LaundryController.isExpressServiceSelected` - Manual toggle
- `LaundryController.expressServicePrice = 5.0` - Flat $5 fee
- `LaundryController.toggleExpressService()` - Toggle method
- Express service item in order summary (`key: 'express_service'`)
- Manual "Add" button in ExpressServiceCard

### Reason for Removal
- Flat fee didn't scale with order size
- Manual toggle was confusing for users
- No validation of actual delivery turnaround
- Not PCI or app store compliant for pricing display

---

## Assumptions

1. **Time slots are 2-hour windows** - Start times are used for duration calculation
2. **Time slot mapping is fixed**:
   - `8:00 AM - 10:00 AM` → starts at 8:00
   - `10:00 AM - 12:00 PM` → starts at 10:00
   - `12:00 PM - 2:00 PM` → starts at 12:00
   - `2:00 PM - 4:00 PM` → starts at 14:00
   - `4:00 PM - 6:00 PM` → starts at 16:00
3. **Express threshold is pickup-to-delivery start time** (not end time)
4. **Tax (GST 5%) is calculated on subtotal only**, not on express fee
5. **Delivery fee remains unchanged** ($10.99 if subtotal < $80, else FREE)
6. **Elite Express Bag** is a separate product, not related to express delivery

---

## QA Checklist

### Functional Tests

- [ ] **Express Detection (< 24h)**
  - [ ] Select same-day delivery → Express indicator shows
  - [ ] Select next-day delivery (< 24h gap) → Express indicator shows
  - [ ] Express fee (5%) appears in order summary
  - [ ] Grand total includes express fee

- [ ] **Standard Delivery (>= 24h)**
  - [ ] Select delivery 2+ days later → No express indicator
  - [ ] No express fee in order summary
  - [ ] Grand total is normal (subtotal + delivery + tax)

- [ ] **Minimum Gap Validation (4h)**
  - [ ] Same day, adjacent time slots → Slot disabled with "(min 4h gap)"
  - [ ] Same day, 2 slots apart → Slot disabled
  - [ ] Same day, 3+ slots apart → Slot available (8h gap)
  - [ ] If invalid selection made somehow → Checkout blocked with error

- [ ] **Time Slot Selection**
  - [ ] Changing pickup time slot clears invalid delivery selections
  - [ ] Changing delivery date validates current time slot
  - [ ] Express state updates immediately on selection change

- [ ] **Order Summary Display**
  - [ ] Express Fee row shows with orange flash icon
  - [ ] Express Fee shows "+$X.XX" format
  - [ ] Total updates to include express fee
  - [ ] Fee label shows "Express Fee (5%)"

- [ ] **Payment Flow**
  - [ ] Express indicator shows in payment bottom sheet
  - [ ] Payment amount includes express fee
  - [ ] Stripe charge uses correct total with express fee

### UI Tests

- [ ] Express Delivery indicator is orange with flash icon
- [ ] Disabled time slots show "(min 4h gap)" in red
- [ ] ExpressServiceCard shows informational content (no toggle)
- [ ] Order summary express row is styled consistently

### Edge Cases

- [ ] No dates selected → No express indicator, no validation errors
- [ ] Only pickup selected → No validation until delivery selected
- [ ] Rapid date/time changes → State updates correctly
- [ ] Very large order → Express fee scales correctly (5%)
- [ ] Zero subtotal → Express fee is $0.00

### Regression Tests

- [ ] Delivery fee still works ($10.99 if < $80, FREE if >= $80)
- [ ] Tax (GST) still calculates correctly
- [ ] Order history shows correct totals
- [ ] Elite Express Bag product still works independently
- [ ] Premium Bag, Subscription, Pay As You Go still work

---

## Files Summary

| File | Action |
|------|--------|
| `lib/data/service/express_delivery_service.dart` | **CREATED** |
| `lib/controller/order_summary_controller.dart` | Modified |
| `lib/modules/schedule/schedule_controller.dart` | Modified |
| `lib/modules/schedule/schedule_view.dart` | Modified |
| `lib/widgets/order_summary_card_widget.dart` | Modified |
| `lib/modules/laundry/laundry_controller.dart` | Modified |
| `lib/modules/laundry/widgets/express_service_card.dart` | **REPLACED** |

---

## Version

- **Implementation Date**: 2025
- **Flutter Stripe Version**: 12.1.0
- **Express Fee Rate**: 5%
- **Express Threshold**: 24 hours
- **Minimum Gap**: 4 hours
