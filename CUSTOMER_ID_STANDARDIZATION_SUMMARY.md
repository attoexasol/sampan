# Customer ID Standardization Summary

## Overview

Customer identity is unified: **CustomerID** (from signup) and **cid** (from login) are the same logical value. Both are stored in a single key and retrieved via the same helpers. No customer ID is hardcoded anywhere in production flows.

---

## Files changed

| File | Change |
|------|--------|
| `lib/data/service/local_store.dart` | In `getValidCustomerId()`: added debug logs `[CustomerSession] fetched stored customer id: <value>` when valid, and `[CustomerSession] missing/invalid customer id` when null/invalid. In `saveCustomerIdFromResponse()`: when saving, log `[CustomerSession] normalized and saved customer id: <value>`; when invalid, log `[CustomerSession] missing/invalid customer id`. |
| `lib/modules/signup/signup_controller.dart` | After extracting customer ID from response body, added `[CustomerSession] signup returned CustomerID: <value>`. No change to save flow: still uses `saveSession(customerId:)` and `saveCustomerIdFromResponse(body)`. |
| `lib/modules/login/login_controller.dart` | After extracting customer ID from response body, added `[CustomerSession] login returned cid: <value>`. Comment updated to state cid and CustomerID are the same identity. No change to save flow. |
| `lib/data/service/utils.dart` | Comments for `accountCreate` and `logInAcc` updated to remove example numeric IDs; clarified that signup returns CustomerID and login returns cid (same identity, single storage). |
| `CUSTOMER_ID_STANDARDIZATION_SUMMARY.md` | This file. |

---

## How CustomerID and cid were unified

- **Signup:** CleanCloud addCustomer returns **CustomerID**. The app reads `body['CustomerID'] ?? body['cid']`, trims to string, then:
  - passes it to `LocalStore.instance.saveSession(customerId: customerId)`
  - calls `LocalStore.instance.saveCustomerIdFromResponse(body)` (which extracts CustomerID or cid from the same body and saves to the single key).
- **Login:** CleanCloud loginCustomer returns **cid**. The app reads `body['cid'] ?? body['CustomerID']`, trims to string, then:
  - passes it to `LocalStore.instance.saveSession(customerId: customerId)`
  - calls `LocalStore.instance.saveCustomerIdFromResponse(body)` (which extracts and saves to the same key).
- **Storage:** Both paths write to the same SharedPreferences key. No separate keys for “CustomerID” vs “cid”. Values are normalized (trim, reject null/empty/"null") before save.

---

## Single storage key used

- **Key:** `customer_id` (constant `_customerIdKey` in `LocalStore`).
- **Write:** Via `saveCustomerId(cid)` or `saveSession(customerId:)` or `saveCustomerIdFromResponse(body)`.
- **Read:** Via `getCustomerId()` or `getValidCustomerId()` (valid = non-null, non-empty, not the string `"null"`).

---

## Retrieval helper used for all authenticated API calls

- **When you need the ID and must redirect if missing:**  
  **`CustomerSessionHelper.requireCustomerIdOrRedirect(featureName)`**  
  Returns a valid customer ID string or null (and shows snackbar + navigates to Sign In). Callers must not call the API when null.

- **When you only need to read the ID (e.g. wallet, conditional UI):**  
  **`CustomerSessionHelper.getValidCustomerId()`** or **`LocalStore.instance.getValidCustomerId()`**  
  Returns a valid trimmed string or null. No redirect.

All authenticated API calls in the project use one of these; the value is sent as **customerID** (or **cid** where the API expects it) in the request body. No hardcoded IDs are used.

---

## Places where hardcoded IDs were removed

- **None found in production code.** No literal customer IDs (e.g. "3492", "123") are used in API calls, widgets, or services.
- **Comments:** In `lib/data/service/utils.dart`, the previous comment examples that looked like literal response values (e.g. "3492") were replaced with neutral wording (“Response: CustomerID” / “Response: cid”) so it is clear no ID is hardcoded.

---

## Final rule for authenticated API calls

1. **Get identity:** Use **`CustomerSessionHelper.requireCustomerIdOrRedirect('<feature>')`** (or **`getValidCustomerId()`** when redirect is not desired).
2. **If null:** Do not call the API; stop the action; existing auth-required snackbar/redirect behavior applies.
3. **If non-null:** Send the returned string as the API field expected by CleanCloud (e.g. **`"customerID": storedCustomerId`**). Do not invent new identifier fields or send hardcoded values.
4. **Treat CustomerID and cid as the same:** Both are the same user identity; storage and retrieval are unified under one key and one set of helpers.

---

## Validation rule (existing behavior)

- **Invalid stored identity:** Rejected if null, empty, or the string `"null"` (see `LocalStore.isValidCustomerId()`). When invalid, `getValidCustomerId()` returns null and `requireCustomerIdOrRedirect()` shows the auth snackbar and navigates to Sign In; the protected action must not call the API.
