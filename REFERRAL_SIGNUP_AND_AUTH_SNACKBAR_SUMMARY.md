# Referral Sign Up & Auth Snackbar Summary

## Files updated

| File | Changes |
|------|--------|
| `lib/modules/signup/signup_controller.dart` | Added `referralCodeController`; include optional `referralCode` in signup request body when non-empty; debug logs; signup success snackbar "Success" / "Account created successfully"; clear and dispose referral field. |
| `lib/modules/signup/signup_view.dart` | Added optional "Referral Code (Optional)" text field in the form (after Contact, before Security), same style as existing fields, no validator. |
| `lib/modules/login/login_controller.dart` | Login success snackbar changed to title "Success", message "Logged in successfully", with `snackPosition: SnackPosition.BOTTOM`. |
| `lib/widgets/invite_friends.dart` | `buildReferralShareMessage()` now returns only: "Try Sampan for laundry pickup and delivery. Use my referral code: {dynamicReferralCode}." (removed "I'll receive $amount credit when you join."). |

---

## Referral code field behavior

- **Label:** "Referral Code (Optional)".
- **Placement:** Sign up form, after Contact Information (Phone), before Security (Password).
- **Validation:** None. Empty or invalid referral code does **not** block signup.
- **Value:** Trimmed before use. If spaces only, treated as empty and not sent.
- **Request:** When non-empty after trim, sent in signup body under key **`referralCode`**.

---

## Signup request change

- **Endpoint:** Unchanged (`Urls.accountCreate` → CleanCloud `addCustomer`).
- **New optional field:** `referralCode` (string). Added to the request body only when the user enters a non-empty value (after trim). Not sent when empty.
- **Success:** Account creation success is determined by `response.isSuccess` only. Invalid referral code must not block signup; if the backend still creates the account, the app continues the normal success flow (snackbar, save session, navigate home).
- **Debug logs added:**
  - `[Signup] referralCode entered: <value>`
  - `[Signup] referralCode empty or skipped`
  - `[Signup] account created successfully`
  - `[Signup] referral code may be invalid but signup succeeded` (when success response contains referral-related error keys).

---

## Login success snackbar change

- **Where:** `lib/modules/login/login_controller.dart`, inside `login()` after successful login and before `Get.offAllNamed(Routes.HOME)`.
- **Title:** "Success".
- **Message:** "Logged in successfully".
- **Style:** Same as project (green background, white text, bottom position).

---

## Signup success snackbar change

- **Where:** `lib/modules/signup/signup_controller.dart`, inside `signup()` after successful account creation and before `_clearForm()` and `Get.offAllNamed(Routes.HOME)`.
- **Title:** "Success".
- **Message:** "Account created successfully".
- **Style:** Same as project (green background, white text, bottom position). Replaces the previous `_ok('Account created successfully!')` call.

---

## Final referral share message format

- **Format:** `Try Sampan for laundry pickup and delivery. Use my referral code: {dynamicReferralCode}.`
- **Source:** `{dynamicReferralCode}` is the live `model.referralCode` from the CleanCloud getReferral API (no hardcoded code).
- **Removed:** The sentence "I'll receive $15.00 credit when you join." (or any amount) is no longer part of the share message.
- **Where used:** WhatsApp, SMS, Email, and Copy Link all use this same message via `buildReferralShareMessage(model)`.

---

## Assumptions about backend referral field name

- **Request key used:** `referralCode` in the signup (addCustomer) request body.
- If CleanCloud expects a different name (e.g. `referral_code`, `referralCode`, `refCode`), the single place to change it is in `signup_controller.dart` where `requestedBody["referralCode"] = referralCode` is set.
- Backend is assumed to accept optional referral code and not fail account creation when the code is invalid or empty; the app only treats success when `response.isSuccess` is true.
