# Referral Signup Implementation Review

## Summary

Referral code support during signup was implemented using **only the existing project architecture**: GetX, `NetworkCaller.postRequest`, `Urls` and `ApiConfig` in `lib/data/service/utils.dart`, and `LocalStore` for session. No Dio, no auth module usage, no repository or clean architecture.

---

## Files changed

| File | Change |
|------|--------|
| `lib/modules/signup/signup_controller.dart` | Reimplemented to use `NetworkCaller.postRequest` only. Request body built in controller: `customerName` (firstName + lastName), `customerTel`, `customerEmail`, `customerPassword`, `customerAddress`, `customerNotes`. **promoCode** added only when referral code is non-empty after trim. Removed dependency on `AuthService` and `SignupRequest`. Success snackbar: title "Success", message "Account created successfully". CustomerID saved via existing `LocalStore` / `ProfileController` pattern. |
| `lib/modules/signup/signup_binding.dart` | Removed `AuthService` registration. Only `SignupController` is registered. |
| `lib/modules/signup/signup_view.dart` | No code change. Already contains "Referral Code (Optional)" field bound to `controller.referralCodeController` with existing text field style and no blocking validator. |

**Unchanged (existing pattern):**

- `lib/data/service/utils.dart` — `Urls.accountCreate`, `ApiConfig.apiToken` used as before. `AuthEndpoints` (validate-referral-code, referral/apply) remain in the file but are **not used** by the current signup flow.
- `lib/data/service/network_caller.dart` — used for signup via `NetworkCaller.postRequest`.
- `lib/data/service/local_store.dart` — used for saving session and CustomerID after signup.

---

## CleanCloud request key used

- **Key:** `promoCode`
- **When included:** Only when the user enters a non-empty referral code (after trim).
- **When omitted:** When the referral code field is empty or only spaces; the `promoCode` key is not added to the request body.

---

## Request body rule

- **Empty referral code:** `promoCode` is **not** included in the payload.
- **Non-empty referral code:** `promoCode` is set to the trimmed value. No dummy or placeholder values are sent.

---

## Backend validation endpoint in codebase

- **Does a referral validation endpoint exist in this project?** **No.**  
- The only referral-related API used in the app is **getReferral** (`Urls.gift`), called by `ReferralService.fetchReferral(customerId)` to fetch the **current user’s** referral code for sharing. There is no existing call (via `NetworkCaller` or otherwise) to validate an **input** referral code during signup.
- `AuthEndpoints.validateReferralCode` and `AuthEndpoints.applyReferral` exist in `utils.dart` but are **not** used in the current implementation. No validation or reward/apply logic was added so as not to rely on a non-existent backend.

---

## Does invalid referral block signup?

- **No.** With the current implementation, referral code is **not** validated before signup. Any non-empty value is sent as `promoCode` to CleanCloud addCustomer. Signup is only blocked by normal validation (required fields, email format, password match) and by addCustomer failure.  
- To block signup on invalid referral code, a real backend endpoint (e.g. `POST /validate-referral-code`) would need to exist and be called from the signup flow using `NetworkCaller` before calling addCustomer; that was not added because no such endpoint is present in the project.

---

## Reward / apply logic

- **Implemented?** **No.**  
- There is no existing backend call in the project for “apply referral” or “record referral and give reward” (e.g. `POST /referral/apply`).  
- Reward triggering was **not** implemented so as not to invent an incomplete production flow.  
- **Missing dependency:** A backend that accepts the new customer’s ID and the referral code and then records the referral and grants the referrer reward (e.g. $15) would need to be implemented and wired later (e.g. after addCustomer success), using `NetworkCaller.postRequest` and a URL added to `utils.dart` or `AuthEndpoints`.

---

## Optional backend dependencies (for strict validation and rewards)

1. **Referral validation**  
   Endpoint (e.g. `POST /validate-referral-code`) that accepts a referral code and returns whether it is valid. If added, signup flow could call it via `NetworkCaller` when the referral field is non-empty and block signup with snackbar “Invalid referral code” when invalid.

2. **Referral apply / reward**  
   Endpoint (e.g. `POST /referral/apply`) that accepts `newCustomerId` and `referralCode`, finds the referrer, stores the referral, and grants the referrer reward. If added, it could be called after successful addCustomer when a referral code was used.

---

## Unused code (left in repo)

- `lib/modules/auth/` (e.g. `models/signup_request.dart`, `services/auth_service.dart`) is still present but **not** used by signup or binding. It can be removed if you want to avoid confusion.
