# Customer Session Guard – Summary

## Helper used

- **`CustomerSessionHelper.requireCustomerIdOrRedirect([String? featureName])`**  
  - Defined in `lib/data/service/customer_session_helper.dart`.
  - Uses `LocalStore.instance.getValidCustomerId()` and `LocalStore.isValidCustomerId()`.
  - Returns a valid customer ID (trimmed string) or `null` when missing/invalid.
  - When invalid: shows snackbar **"Please Sign In / Sign Up first"**, navigates to Sign In (`Routes.LOGIN`), returns `null`. Callers must abort when `null` is returned.

## Debug logs

- `[AuthGuard] Checking customer session for: <feature-name>`
- `[AuthGuard] customerId found: <id>` when valid
- `[AuthGuard] Missing customerId. Redirecting to Sign In.` when invalid

## Files changed

| File | Change |
|------|--------|
| `lib/data/service/customer_session_helper.dart` | Added `requireCustomerIdOrRedirect([String? featureName])`, AuthGuard logs, snackbar text "Please Sign In / Sign Up first". |
| `lib/controller/order_history_controller.dart` | Guard before fetch with feature name `order-history`. |
| `lib/modules/laundry/laundry_controller.dart` | Guard before Dream Big plan with feature name `dream-big-plan`. |
| `lib/modules/laundry/widgets/subscription_card.dart` | Pending and canContinue branches use `requireCustomerIdOrRedirect('dream-big-payment')`; removed local `getCustomerId` + `isInvalidCustomerId`. |
| `lib/modules/schedule/schedule_controller.dart` | Guard before place order with feature name `place-order`. |
| `lib/modules/schedule/schedule_view.dart` | Guard before schedule payment with feature name `schedule-payment`. |
| `lib/widgets/PaymentMethodDialog.dart` | Guard before loading/saving with feature name `payment-method`. |
| `lib/widgets/DeliveryAddressDialog.dart` | Guard on save with feature name `delivery-address`. |
| `lib/widgets/preferences.dart` | Guard on save with feature name `preferences`. |
| `lib/widgets/delete_acc.dart` | Replaced manual customer ID check with `requireCustomerIdOrRedirect('delete-account')`. |
| `lib/screens/account_screen.dart` | Guard + feature names for: **Your Wallet** (`your-wallet`), **Buy Gift Card** (`gift-card`), **Payment Methods** (`payment-methods`), **Delivery Address** (`delivery-address`), **Your Preferences** (`preferences`), **Invite Friends** (`invite-friends`). |

## Protected flows updated

- **Order history** – fetch orders  
- **Dream Big plan** – onTap Dream Big (laundry), and subscription card (pending + canContinue → payment dialog)  
- **Place order** – schedule flow  
- **Schedule payment** – payment from schedule view  
- **Payment method** – load/save payment methods dialog  
- **Delivery address** – save address in dialog (opening guarded from account)  
- **Preferences** – save preferences (opening guarded from account)  
- **Delete account** – delete customer API  
- **Your Wallet** – open wallet screen  
- **Buy Gift Card** – open gift card dialog  
- **Payment Methods** – open payment methods dialog  
- **Delivery Address** – open delivery address dialog  
- **Your Preferences** – open preferences screen  
- **Invite Friends** – open invite dialog  

## Final behavior

1. User taps any protected service (booking, checkout, subscription, referral, order, wallet, gift card, address, schedule, payment, order history, delete account, preferences, invite friends, etc.).
2. App runs `requireCustomerIdOrRedirect('<feature-name>')`.
3. **If customer ID is valid:**  
   - Log: `[AuthGuard] customerId found: <id>`.  
   - Action continues (API called, screen/dialog opened).
4. **If customer ID is missing, null, empty, `"null"`, or invalid:**  
   - Log: `[AuthGuard] Missing customerId. Redirecting to Sign In.`  
   - Snackbar: **"Please Sign In / Sign Up first"**  
   - Navigate to Sign In page  
   - Action stops: no API request, no next screen/booking/checkout/subscription/referral/order/wallet/gift card/address/schedule/payment/order history/service request.

No new auth architecture was added; the guard reuses **LocalStore** and **CustomerSessionHelper** only.
