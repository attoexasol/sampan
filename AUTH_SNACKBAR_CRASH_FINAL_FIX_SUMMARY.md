# Auth Snackbar Crash — Final Fix Summary

## Root cause

- **Crash:** `No Overlay widget found.`
- **Where:** During signup, when the CleanCloud addCustomer API returned a body like `{"Error": "An account already exists with this email address..."}`. The code called `SafeSnackbar.show` → `Get.snackbar()`, which then threw.
- **Why:** The snackbar was shown from an async callback (after `NetworkCaller.postRequest`). Even when `Get.overlayContext != null` was true, **Get.snackbar** still threw. So the problem was not only “no context” but **relying on Get.snackbar**, which in this project can throw (e.g. overlay not in the right state, or Get using a different path that requires an Overlay that isn’t present in the current tree).

---

## Why Get.snackbar was unsafe here

- **Checking `Get.overlayContext != null` was not enough.** The log showed `[Snackbar] overlay available: true` and the app still crashed. So either:
  - Get.snackbar uses something other than overlayContext internally and can throw, or
  - The overlay was present but not in a state where Get.snackbar can attach, or
  - Timing (async after API) made the overlay invalid at show time.
- **Conclusion:** For auth flows (signup/login), **Get.snackbar must not be used** in this project if it can still crash. A different, safe mechanism was required.

---

## Final safe approach used

- **No more Get.snackbar** in the auth snackbar helper.
- **SafeSnackbar** in `lib/data/service/safe_snackbar.dart` now:
  1. **Gets a BuildContext** in this order:
     - `Get.context`
     - else `Get.key?.currentContext`
  2. If **no context:** only `debugPrint` the title and message and return (no crash).
  3. **Gets ScaffoldMessenger:** `ScaffoldMessenger.maybeOf(context)` (returns null if no Scaffold in the tree; does not throw).
  4. If **no messenger:** only `debugPrint` and return.
  5. **Shows the message:** `messenger.showSnackBar(SnackBar(content: Text(message), ...))` inside a **try/catch**. On exception, log `[SafeSnackbar] failed to show snackbar: <error>` and `debugPrint` the message; do not rethrow.
- **Debug logs:**
  - `[SafeSnackbar] using Get.context` or `[SafeSnackbar] using Get.key.currentContext`
  - or `[SafeSnackbar] no valid context found, printing only`
  - or `[SafeSnackbar] failed to show snackbar: <error>`

This way, **no call is made that can throw due to a missing Overlay**; we only use `ScaffoldMessenger.showSnackBar`, which is safe when a valid `BuildContext` with a `Scaffold` is available.

---

## How existing-email signup error is handled

- After addCustomer, the **response body** is read.
- If **`body['Error']`** is non-empty (even when HTTP status is 200):
  - Log: `[Signup] API returned error: <message>`
  - If the message contains “already exists” (case-insensitive):
    - Log: `[Signup] Email already exists`
    - Show via **SafeSnackbar:** title **Error**, message **"An account already exists with this email. Please sign in instead."**
  - Otherwise show the API’s `body['Error']` via SafeSnackbar.
- **Flow stops:** no session save, no navigation. Signup is aborted without crashing.

---

## How login/signup success messages are handled

- **Signup success:** When there is no `body['Error']` and a valid CustomerID is present, the app saves session as before, then calls **SafeSnackbar.show('Success', 'Account created successfully', isError: false)**, then clears the form and calls `Get.offAllNamed(Routes.HOME)`. The snackbar is shown on the current (signup) screen’s Scaffold before navigation; no Get.snackbar, so no overlay-related crash.
- **Login success:** After saving session and updating profile, the app calls **SafeSnackbar.show('Success', 'Logged in successfully', isError: false)**, then `Get.offAllNamed(Routes.HOME)`. Same safe path.

If no valid context or messenger is available, both success and error paths only log to debug and return; the app never crashes.

---

## Files changed

| File | Change |
|------|--------|
| `lib/data/service/safe_snackbar.dart` | Reimplemented to **stop using Get.snackbar**. Uses only **BuildContext** (Get.context then Get.key?.currentContext) and **ScaffoldMessenger.maybeOf(context)**. Shows **SnackBar** via **messenger.showSnackBar(...)** inside try/catch. On no context, no messenger, or exception: debugPrint and return. Added logs: using Get.context / Get.key.currentContext, no valid context found, failed to show snackbar. |
| `lib/modules/signup/signup_controller.dart` | No code change. Already uses SafeSnackbar for _err and success; already detects body['Error'] and “email already exists” and shows the correct message. |
| `lib/modules/login/login_controller.dart` | No code change. Already uses SafeSnackbar for all snackbars. |
| `AUTH_SNACKBAR_CRASH_FINAL_FIX_SUMMARY.md` | **New.** This summary. |

---

## Expected final behavior

- **Existing email on signup:** Message “An account already exists with this email. Please sign in instead.” is shown via ScaffoldMessenger when possible; otherwise only debug log. No crash; signup stops.
- **Successful signup:** “Account created successfully” shown safely; no crash.
- **Successful login:** “Logged in successfully” shown safely; no crash.
- **No valid context:** App prints the message in debug and continues; no crash.
