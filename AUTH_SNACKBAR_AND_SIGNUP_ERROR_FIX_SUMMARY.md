# Auth Snackbar and Signup Error Fix Summary

## Root cause of crash

- **Error:** `No Overlay widget found.`
- **Cause:** `Get.snackbar()` was called from the signup controller after the addCustomer API returned (e.g. with `{"Error": "An account already exists with this email address..."}`). At that moment, GetX had no overlay in the widget tree (e.g. after an async gap or before the route’s overlay was built), so Get.snackbar tried to show on a null overlay and threw.
- **Where:** `SignupController._err()` and the success path’s direct `Get.snackbar()` call in `signup_controller.dart`; similar risk in `login_controller.dart` for success and error snackbars.

---

## How snackbar was made safe

- **New helper:** `lib/data/service/safe_snackbar.dart` — `SafeSnackbar.show(title, message, { isError })`.
- **Logic:**
  - If `Get.overlayContext != null`: call `Get.snackbar(...)` with the given title/message and red (error) or green (success) style.
  - If `Get.overlayContext == null`: do **not** call Get.snackbar; only `debugPrint('[Snackbar] $title: $message')` so the app never throws due to missing overlay.
- **Usage:** All signup and login snackbars (success and error) now go through `SafeSnackbar.show()` instead of direct `Get.snackbar()`.

---

## How signup “email already exists” is handled

- After `NetworkCaller.postRequest` to addCustomer, the **response body** is read.
- **Body error check:** If `body['Error']` is present and non-empty (even when HTTP status is 200), signup is treated as **failure**:
  - If the message contains “already exists” (case-insensitive): show user-friendly snackbar: **Title:** Error, **Message:** “An account already exists with this email. Please sign in instead.”
  - Otherwise: show the API’s `body['Error']` text.
- **No session save, no navigation:** On any body error, the flow returns immediately; session is not saved and the user is not sent home.
- **Success path:** Only when there is **no** `body['Error']` and we have a valid `CustomerID`/`cid` do we save session, show “Account created successfully” via `SafeSnackbar.show`, clear the form, and navigate home.

---

## How login/signup success messages are handled

- **Signup success:** After saving session and profile, the code calls `SafeSnackbar.show('Success', 'Account created successfully', isError: false)`, then clears the form and navigates to home. No direct `Get.snackbar()`; no crash if overlay is missing.
- **Login success:** After saving session and updating profile, the code calls `SafeSnackbar.show('Success', 'Logged in successfully', isError: false)`, then navigates to home. Same safe behavior.

---

## Files changed

| File | Change |
|------|--------|
| `lib/data/service/safe_snackbar.dart` | **New.** Static helper `SafeSnackbar.show(title, message, { isError })` that checks `Get.overlayContext` before calling `Get.snackbar`, otherwise uses `debugPrint`. |
| `lib/modules/signup/signup_controller.dart` | 1) Import and use `SafeSnackbar.show` for all snackbars (`_err` and success). 2) After addCustomer, treat `body['Error']` as failure even when HTTP is 200; show “An account already exists with this email. Please sign in instead.” when message contains “already exists”; otherwise show API error. 3) Success only when no body error and valid CustomerID; then save session and show success via SafeSnackbar. 4) Added debug logs: `[Signup] API returned error:`, `[Signup] Email already exists`, `[Signup] Account created successfully`, `[Signup] Showing safe snackbar`. |
| `lib/modules/login/login_controller.dart` | Replaced all `Get.snackbar` calls with `SafeSnackbar.show` (validation error, login failed, catch). Success path: `SafeSnackbar.show('Success', 'Logged in successfully', isError: false)`. Added debug log: `[Login] Logged in successfully`. |
| `AUTH_SNACKBAR_AND_SIGNUP_ERROR_FIX_SUMMARY.md` | **New.** This summary. |

---

## Debug logs added

- `[Snackbar] overlay available: true/false` — in `SafeSnackbar.show`.
- `[Signup] API returned error: <message>` — when body contains `Error`.
- `[Signup] Email already exists` — when error message indicates duplicate email.
- `[Signup] Account created successfully` — when signup succeeds.
- `[Signup] Showing safe snackbar` — before showing success snackbar.
- `[Login] Logged in successfully` — when login succeeds.

---

## Expected final behavior

- **Signup with existing email:** Snackbar shows “An account already exists with this email. Please sign in instead.” No crash; signup flow stops; no session save or navigation.
- **Successful signup:** Snackbar shows “Account created successfully.” No crash; session saved; user navigated home.
- **Successful login:** Snackbar shows “Logged in successfully.” No crash; user navigated home.
