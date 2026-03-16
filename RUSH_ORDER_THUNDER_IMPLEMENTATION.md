# Rush Order Thunder Implementation

## Summary

A **Rush Orders** system was implemented across the Flutter CleanCloud app with:

- **Service-aware rush rules**: Laundry (12h window, 2× price), Dry Cleaning (24h window, 2× price), Specialty (no rush).
- **Slot-level thunder icons (⚡)** on delivery time slots that qualify as Rush (or Express when not Rush), with reactive updates when pickup/delivery date or time changes.
- **Centralized rush logic** in `RushOrderService` and reuse of `ExpressDeliveryService` for date/slot parsing and minimum 4h gap validation.
- **Rush pricing**: 2× base price when a Rush-eligible slot is selected; no separate rush fee. Express (5% fee) applies only when the slot is **not** Rush but is within 24h.
- **Dry cleaning** rush is now **slot-based only** (manual Rush Service toggle and 50% add-on removed).
- **Specialty services** have no Rush option: no ⚡, no rush pricing, no rush messaging.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/data/service/rush_order_service.dart` | **New.** Single source of truth: rush windows (12h laundry, 24h dry), `evaluateDeliverySlot()`, messaging, `RushServiceType`. |
| `lib/data/service/express_delivery_service.dart` | Unchanged. Reused for slot parsing and 4h minimum gap. |
| `lib/controller/order_summary_controller.dart` | Added `isRushDelivery`, `baseSubTotal`; `subTotal` = 2× when rush; `expressFee` = 0 when rush; `setRushAndExpressDelivery(serviceType, ...)`. |
| `lib/modules/schedule/schedule_controller.dart` | Added `isRushDelivery`, `rushServiceType`; `isDeliverySlotRush(slot)`; `_updateExpressDeliveryState()` now sets rush + express from `RushOrderService`; `grandTotal` uses `OrderSummaryController` when registered. |
| `lib/modules/schedule/schedule_view.dart` | Delivery slot list: ⚡ + "Rush" or "Express" per slot via `isDeliverySlotRush()` / express check; Rush/Express indicator panel (Rush message + dry cleaning note when applicable); order summary uses `OrderSummaryController` when available and passes `isRushDelivery`; payment uses `setRushAndExpressDelivery` before opening sheet. |
| `lib/modules/laundry/laundry_view.dart` | Navigate to schedule with `serviceType: 'laundry'`. |
| `lib/modules/laundry/widgets/express_service_card.dart` | Copy updated: Rush Laundry (≤12h, 2×), Express (12–24h, 5%). |
| `lib/modules/dry_cleaning/dry_cleaning_view.dart` | Navigate with `serviceType: 'dry_cleaning'`; removed `RushServiceCard`. |
| `lib/modules/dry_cleaning/dry_cleaning_controller.dart` | Removed `isRushServiceSelected`, `rushServiceMultiplier`, `toggleRushService()`, and manual rush pricing; rush is slot-based only. |
| `lib/modules/dry_cleaning/widgets/schedule_delivery_card.dart` | Bullets updated: Rush Dry Cleaning = slot within 24h, 2× price; added confirmation note. |
| `lib/widgets/common_specialty_service_view.dart` | Navigate with `serviceType: 'specialty'`; removed `SpecialtyRushServiceCard`. |
| `lib/widgets/order_summary_card_widget.dart` | Added `isRushDelivery`; "Rush (2× price)" row when rush; schedule section shows Rush/Express badge; `_buildScheduleRow` accepts `badgeLabel` (Rush vs Express). |

**Unchanged but relevant:** `lib/data/service/express_delivery_service.dart` (slot parsing, 4h gap, 24h express threshold), `lib/modules/dry_cleaning/widgets/rush_service_card.dart` (file kept but no longer used in view), `lib/widgets/specialty_rush_service_card.dart` (kept but not used in specialty view).

---

## Laundry Rush Behavior

- **Window**: Delivery slot **within 12 hours** of pickup (using slot start times).
- **Pricing**: **2×** regular laundry price when a Rush-eligible slot is selected.
- **UI**: Qualifying delivery slots show **⚡ Rush** beside the slot; selected Rush slot shows Rush indicator and “Ready in ~12 hours” messaging.
- **Validation**: Same 4h minimum gap as express; invalid slots stay disabled.
- **Express**: If the chosen slot is 12–24h (not Rush), it is treated as Express and **5% express fee** applies (no 2×).

---

## Dry Cleaning Rush Behavior

- **Window**: Delivery slot **within 24 hours** of pickup.
- **Pricing**: **2×** regular dry cleaning price when a Rush-eligible slot is selected.
- **UI**: Qualifying slots show **⚡ Rush**; Rush panel shows: “For rush dry cleaning, please confirm timing with us before placing the order.”
- **Manual Rush removed**: Previous “Rush Service” toggle and 50% add-on are removed; rush is **only** slot-based.

---

## Specialty Services (No Rush)

- **Alterations / Steaming / Shoe Care**: No rush logic.
- **No ⚡** on any delivery slot for specialty.
- **No rush pricing** and no rush messaging.
- **SpecialtyRushServiceCard** removed from the specialty flow; `serviceType: 'specialty'` is passed to schedule so `RushOrderService` treats it as no-rush.

---

## Slot-Level Thunder Icon Detection

- **When**: For each **delivery time slot** row, before the user selects it.
- **How**:
  1. `ScheduleController.isDeliverySlotRush(slot)` calls `RushOrderService.evaluateDeliverySlot()` with current pickup date/slot, delivery date, and candidate delivery slot.
  2. `ExpressDeliveryService` parses pickup and delivery into `DateTime` (slot start) and computes duration in hours.
  3. If the slot is **valid** (≥4h gap) and duration ≤ service rush window (12h laundry, 24h dry), the slot is Rush → show **⚡ Rush**.
  4. If not Rush but duration &lt; 24h and valid → show **⚡ Express**.
- **Reactivity**: Delivery slot list is inside `Obx()` and depends on `selectedPickupDate`, `selectedPickupTimeSlot`, `selectedDeliveryDate`, and `rushServiceType`, so changing pickup date/time or delivery date updates icons immediately.
- **Specialty**: `supportsRush(rushServiceType)` is false, so no thunder icon is shown for specialty.

---

## Pricing Rules

- **Rush (Laundry or Dry Cleaning)**  
  - Subtotal = **2 × base subtotal** (base = sum of line items at regular price).  
  - **No** express fee.  
  - Delivery fee and tax apply to this subtotal.

- **Express (not Rush)**  
  - Subtotal = base subtotal.  
  - **5%** express fee on base subtotal.  
  - Delivery fee and tax as usual.

- **Specialty**  
  - No rush; no express fee from rush/express logic (any existing specialty-specific logic unchanged).

- **Implementation**: `OrderSummaryController.baseSubTotal` = sum of item line totals; `subTotal` = `baseSubTotal * 2` when `isRushDelivery`, else `baseSubTotal`. `expressFee` = 0 when `isRushDelivery`, else 5% of `baseSubTotal` when `isExpressDelivery`. `grandTotal` = `subTotal + deliveryFee + expressFee + tax`. Payment uses this `grandTotal`.

---

## Schedule / Timing Rules

- **Minimum gap**: **4 hours** between pickup and delivery (unchanged; `ExpressDeliveryService.minimumGapHours`). Slots that violate this remain **unavailable** (e.g. “min 4h gap”).
- **Laundry Rush**: Turnaround ≤ **12 hours** (from pickup slot start to delivery slot start).
- **Dry Cleaning Rush**: Turnaround ≤ **24 hours**.
- **Slot times**: Uses slot **start** time for both pickup and delivery (same as `ExpressDeliveryService`).
- **Specialty**: No rush window; only 4h minimum gap applies for availability.

---

## UI Behavior

- **Delivery slot list**: Each slot shows label + optional **⚡ Rush** or **⚡ Express** (only when available and qualifying). Rush takes precedence over Express for labeling.
- **After selecting a delivery slot**: Panel below shows either **Rush** (with service-specific message and, for dry cleaning, the confirmation note) or **Express** (5% fee text).
- **Order summary card**: Shows “Rush (2× price)” with “Included” when `isRushDelivery`; shows “Express Fee (5%)” when express and not rush; schedule section shows Rush or Express badge on delivery row.
- **Laundry**: Express card text explains Rush (≤12h, 2×) and Express (12–24h, 5%).
- **Dry cleaning**: Schedule/delivery card explains Rush (≤24h, 2×) and the confirmation note.

---

## How Old Express / Rush Conflicts Were Handled

- **Express (existing)**: Kept. It now applies only when the selected slot is **not** Rush (i.e. when `!isRushDelivery`). So for laundry, slots in 12–24h are Express (5%); for dry cleaning, non-rush slots &lt; 24h could still be Express if we ever split dry-cleaning express vs standard (currently rush covers 24h).
- **Dry cleaning manual Rush**: **Removed.** The old “Rush Service” toggle and 50% add-on were removed; rush is only slot-based (24h, 2×).
- **No double charge**: When a slot is Rush, we set `isRushDelivery = true` and `isExpressDelivery = false`, so only 2× subtotal is applied and express fee is 0.

---

## Assumptions

- Service type is passed from Laundry / Dry Cleaning / Specialty screens via `arguments: { serviceType: 'laundry' | 'dry_cleaning' | 'specialty', orderSummary: ... }`. Schedule uses this for rush vs express vs no-rush.
- Order summary and payment use `OrderSummaryController` when the user has come from a flow that registers it (e.g. laundry or dry cleaning); otherwise schedule falls back to `controller.orderSummaryData` and controller totals.
- Rush is applied at **payment/order summary** level by doubling the **current** cart subtotal when the **selected** delivery slot is Rush; we do not send a separate “rush” flag to the backend. If the backend expects a rush flag or different total structure, that would need to be added and documented.

---

## API Limitations

- **addOrder / addSchedule**: No dedicated “rush” or “express” field was assumed. The **final total** sent to the backend is the rush-adjusted (or express-adjusted) `grandTotal`. If the API supports a rush/express flag or line-item modifiers, the client does not send them; only the final amount is consistent with the UI.
- **Local order history**: Snapshot includes `isRushDelivery` in totals for potential future use; no guarantee that existing history screens display it.

---

## Manual QA Checklist

- [ ] **Laundry normal pricing**: Select laundry items, pick pickup/delivery with turnaround &gt; 12h; subtotal and total are regular (no 2×, no rush).
- [ ] **Laundry rush doubles price**: Select laundry, pick pickup and delivery so that a slot is within 12h; select that slot; subtotal and total are 2× base; “Rush (2× price)” appears in summary.
- [ ] **Laundry rush slots show ⚡**: With laundry, set pickup date/time and delivery date so some slots are ≤12h; those slots show ⚡ and “Rush” beside the time.
- [ ] **Dry cleaning normal pricing**: Select dry cleaning items, pick slot &gt; 24h; no 2×, no rush.
- [ ] **Dry cleaning rush doubles price**: Select dry cleaning, pick delivery within 24h of pickup; select that slot; total is 2× base; Rush messaging and note visible.
- [ ] **Dry cleaning rush slots show ⚡**: With dry cleaning, delivery slots within 24h of pickup show ⚡ and “Rush”.
- [ ] **Dry cleaning rush note**: When a Rush dry cleaning slot is selected, the note “For rush dry cleaning, please confirm timing with us before placing the order.” is visible.
- [ ] **Specialty no rush**: From Alterations/Steaming/Shoe Care, go to schedule; no delivery slot shows ⚡; no rush pricing.
- [ ] **Specialty never ⚡**: Confirm no thunder icon on any slot when service type is specialty.
- [ ] **Specialty never rush pricing**: With specialty selected, total is never doubled for rush.
- [ ] **Invalid slots blocked**: Slots that violate the 4h minimum stay disabled (e.g. “min 4h gap”); cannot select them.
- [ ] **Order summary reflects rush**: When a Rush slot is selected, order summary shows Rush badge and “Rush (2× price)” (or equivalent) and total matches 2× subtotal + delivery + tax.
- [ ] **Payment total matches rush**: On payment screen, grand total equals the rush-adjusted amount (2× base + delivery + tax, no express fee).
- [ ] **No duplicate charge from old express**: Select a Rush slot; confirm only 2× is applied and no 5% express fee on top.
- [ ] **Changing pickup date/time updates thunder icons**: Change pickup date or time; delivery slot list updates so ⚡ appears or disappears per new turnaround.
- [ ] **Changing delivery date updates thunder icons**: Change delivery date; slot list updates ⚡ accordingly.
