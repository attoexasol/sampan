# Customer ID / cid Session Implementation

## Summary

Customer ID from login or signup is saved in **one central place** (SharedPreferences key `customer_id` via `LocalStore`). All API calls that need `customerID` or `cid` read from this session. If the value is missing, empty, or the literal `"null"`, the app shows a snackbar **"Please Sign Up / Sign In first"** and navigates the user to the **Sign In** screen instead of sending broken requests.

---

## Files Modified

| File | Change |
|------|--------|
| `lib/data/service/local_store.dart` | Added `isValidCustomerId(String?)`, `getValidCustomerId()`, `clearCustomerId()`; documented `saveCustomerIdFromResponse` priority. |
| `lib/data/service/customer_session_helper.dart` | **New.** Central helper: `getValidCustomerId()`, `requireCustomerIdOrRedirect()`. |
| `lib/controller/order_history_controller.dart` | Uses `requireCustomerIdOrRedirect()` before fetching orders; removed local `_isInvalidCustomerId`. |
| `lib/modules/laundry/laundry_controller.dart` | Dream Big Plan tap uses `requireCustomerIdOrRedirect()`; removed scattered login/cid checks. |
| `lib/modules/schedule/schedule_controller.dart` | Place order flow uses `requireCustomerIdOrRedirect()` instead of raw `getCustomerId()`. |
| `lib/modules/schedule/schedule_view.dart` | Payment flow uses `requireCustomerIdOrRedirect()`; removed long fallback/parsing block. |
| `lib/widgets/PaymentMethodDialog.dart` | Uses `requireCustomerIdOrRedirect()` before payment. |
| `lib/widgets/DeliveryAddressDialog.dart` | Save address uses `requireCustomerIdOrRedirect()` before API call. |
| `lib/widgets/payment_information.dart` | Init uses `getValidCustomerId()` for display and conditional fetch. |
| `lib/widgets/preferences.dart` | Save preferences uses `requireCustomerIdOrRedirect()`; load uses `getValidCustomerId()`. |

**Not changed:** Login and signup controllers already saved customer ID via `saveSession(customerId: ...)` and `saveCustomerIdFromResponse(body)`. No change to auth flow or UI.

---

## Where CustomerID / cid Is Captured

- **Login** (`lib/modules/login/login_controller.dart`): On success, extracts `(body['cid'] ?? body['CustomerID'])?.toString().trim()`, passes to `saveSession(customerId: ...)` and `saveCustomerIdFromResponse(body)`.
- **Signup** (`lib/modules/signup/signup_controller.dart`): On success, extracts `(body['CustomerID'] ?? body['cid'])?.toString().trim()`, passes to `saveSession(customerId: ...)` and `saveCustomerIdFromResponse(body)`.

Both support **int** (e.g. `3492`) or **string** (e.g. `"3492"`); stored as trimmed string.

---

## Where It Is Stored

- **Key:** `customer_id` in SharedPreferences (constant `_customerIdKey` in `LocalStore`).
- **Write:** Only when value is valid (`LocalStore.isValidCustomerId`): non-null, non-empty, not the string `"null"`, trimmed.
- **Cleared on logout:** `ProfileController.logout()` → `LocalStore.clearSession()` (removes `customer_id` and other session keys).

---

## How Missing Customer ID Is Handled

1. **Validation:** `LocalStore.isValidCustomerId(String? id)` returns false for `null`, empty, whitespace-only, or the literal `"null"` (case-insensitive).
2. **Reading:** `LocalStore.getValidCustomerId()` returns the trimmed stored value or `null` if invalid/missing.
3. **Require-or-redirect:** `CustomerSessionHelper.requireCustomerIdOrRedirect()`:
   - If a valid ID exists → returns it (caller proceeds with API).
   - If missing/invalid → shows snackbar **"Please Sign Up / Sign In first"**, calls `Get.offAllNamed(Routes.LOGIN)`, returns `null`. Callers must **abort** the operation when `null` is returned (no API call with empty cid/customerID).

---

## API Flows Updated

| Flow | Before | After |
|------|--------|--------|
| Order history fetch | `getCustomerId()` + local invalid check + snackbar | `requireCustomerIdOrRedirect()`; abort if null |
| Dream Big Plan tap | `isLoggedIn` + `getCustomerId()` + `isInvalidCustomerId` | `requireCustomerIdOrRedirect()`; return needLogin if null |
| Schedule / place order | `getCustomerId()` + empty check + snackbar | `requireCustomerIdOrRedirect()`; abort if null |
| Schedule payment | Long fallback from getCustomerId + last API response | `requireCustomerIdOrRedirect()`; abort if null |
| PaymentMethodDialog | `getCustomerId()` + null snackbar | `requireCustomerIdOrRedirect()`; abort if null |
| DeliveryAddressDialog save | `getCustomerId()` + empty check | `requireCustomerIdOrRedirect()`; abort if null |
| Payment information init | `getCustomerId()` | `getValidCustomerId()`; fetch only if non-null |
| Preferences save | `_customerId` check + snackbar | `requireCustomerIdOrRedirect()`; use returned cid |

Other usages (e.g. subscription_card, subscription_service, dream_big_payment_dialog) still receive customer ID from the caller; callers that need it now get it via the helper or from session after redirect.

---

## Central Helper API

- **`CustomerSessionHelper.getValidCustomerId()`**  
  Returns valid customer ID from session or `null`. Use for display or conditional logic (e.g. only fetch if signed in).

- **`CustomerSessionHelper.requireCustomerIdOrRedirect()`**  
  Returns valid customer ID or, if missing, shows snackbar, navigates to Sign In, and returns `null`. Use before any API call that requires customerID/cid.

- **`LocalStore.isValidCustomerId(String? id)`**  
  Static check: false for null, empty, `"null"`. Use when you already have a value (e.g. validating a parameter).

- **`LocalStore.clearCustomerId()`**  
  Removes only `customer_id`. Logout uses `clearSession()` which clears all session keys including customer_id.

---

## Assumptions

- Login route is `Routes.LOGIN` (`/login`). Redirect uses `Get.offAllNamed(Routes.LOGIN)`.
- Snackbar is shown only when `Get.overlayContext != null` in the helper to avoid overlay crashes.
- All APIs that need customer identity use the same key in the request body (`customerID` or `cid` as already used); we only centralize **where the value comes from** (session), not the key name per API.
- Response format: login may return `"cid": "3492"` or `"CustomerID": 3492`; signup may return `"CustomerID": 3492` or `"cid": "3492"`. Priority in `saveCustomerIdFromResponse`: first match in list `CustomerID`, `customerID`, `customer_id`, … `cid`, … wins.

---

## Manual QA Checklist

- [ ] **Login response with CustomerID saves correctly**  
  Use an API/stub that returns `"CustomerID": 3492` (or string). After login, confirm stored value (e.g. debug log or a screen that displays it) is `3492`.

- [ ] **Signup response with cid saves correctly**  
  Use an API/stub that returns `"cid": "3492"`. After signup, confirm stored value is `3492`.

- [ ] **Stored customer ID is reused in later API calls**  
  After login/signup, perform order history, place order, save address, or preferences. Confirm request body contains the same customer ID (e.g. via logs or network inspector).

- [ ] **Missing customer ID shows snackbar**  
  Clear app data or use a build that doesn’t persist session. Trigger an action that requires customer ID (e.g. Order History, Dream Big Plan, Place Order). Confirm snackbar: **"Please Sign Up / Sign In first"**.

- [ ] **Missing customer ID redirects to Sign In screen**  
  Same as above; after snackbar, confirm app navigates to the Sign In screen (and no API request is sent with empty cid/customerID).

- [ ] **Logout clears saved customer ID**  
  Login, then logout. Confirm session is cleared (e.g. next action that needs customer ID shows snackbar and redirects to Sign In).

- [ ] **App does not send broken API requests with empty cid/customerID**  
  Without being logged in (or after logout), trigger any flow that used to send customerID (order history, place order, payment, address, preferences). Confirm no request is sent with empty or "null" customerID (request should not be made; user is redirected instead).
