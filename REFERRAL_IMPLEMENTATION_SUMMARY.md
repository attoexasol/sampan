# Referral Feature Implementation Summary

## Files created

| File | Purpose |
|------|--------|
| `lib/data/models/referral_response_model.dart` | Null-safe model for CleanCloud getReferral response with success, referralCode, amounts, currency. |
| `lib/data/service/referral_service.dart` | Static `fetchReferral(String customerId)` using NetworkCaller, Urls.gift, ApiConfig.apiToken. |

## Files updated

| File | Changes |
|------|--------|
| `lib/screens/account_screen.dart` | Invite Friends card onTap: call `CustomerSessionHelper.requireCustomerIdOrRedirect()` first; if null return; if valid, call `InviteFriendsWidget.showInviteDialog(context, customerId: customerId)`. Added import for `customer_session_helper.dart`. |
| `lib/widgets/invite_friends.dart` | Reworked to use live referral data: removed hardcoded code/link/text; dialog now takes required `customerId`; shows loading → fetches via `ReferralService.fetchReferral(customerId)` → shows content or error + Retry. Title/body use API amounts (existing customer earns $15, new customer $0). Share message: "Try Sampan for laundry pickup and delivery. Use my referral code: {code}. I'll receive {amount} credit when you join." WhatsApp/SMS/Email via url_launcher; Copy Link uses Clipboard + SnackBar. Removed YourWalletWidget/addReward (referral-only). |

## What was changed in each file

### lib/data/models/referral_response_model.dart (new)
- Class `ReferralResponseModel` with: success, referralCode, referralType, referralAmountNewCustomer, referralAmountExistingCustomer, referralPercentEarn, currencySymbol.
- Safe defaults (e.g. "0.00" for amounts, "$" for currency).
- `fromJson` with null-safe parsing; `_parseSuccess` for "True" string or bool.
- Getters: `isSuccess`, `hasValidCode`, `existingCustomerRewardText`, `newCustomerRewardText`.

### lib/data/service/referral_service.dart (new)
- `ReferralService.fetchReferral(String customerId)`: POST to `Urls.gift` with body `{ api_token: ApiConfig.apiToken, customerID: customerId }`.
- Returns `ReferralResponseModel?`; null on failure or empty body. No throw; callers check null.

### lib/screens/account_screen.dart
- Import: `../data/service/customer_session_helper.dart`.
- `_buildInviteFriendsCard()`: `onTap` is now async; calls `CustomerSessionHelper.requireCustomerIdOrRedirect()`; if null returns (user sees snackbar + redirect to Sign In); if valid, calls `InviteFriendsWidget.showInviteDialog(context, customerId: customerId)`.

### lib/widgets/invite_friends.dart
- Removed: hardcoded `referralCode`, `referralLink`, `shareText`; `YourWalletWidget` usage; Fluttertoast.
- Added: import for `referral_response_model`, `referral_service`, `constants/colors`, `flutter/services` (Clipboard).
- `showInviteDialog(context, { required String customerId })`: now requires customerId; opens `_InviteFriendsDialog(customerId:)`.
- New `_InviteFriendsDialog` StatefulWidget: in initState calls `_fetchReferral()`; loading state → `ReferralService.fetchReferral(customerId)`; on success with valid code shows title "Invite Friends & Earn $15" (from API), body "Share Sampan with friends and earn $15 credit when they join using your referral code.", referral code line, and four options (WhatsApp, Text Message, Email, Copy Link). On failure or empty code shows error message + Retry.
- Share message built by `buildReferralShareMessage(model)`.
- WhatsApp/SMS/Email: same url_launcher pattern with dynamic message; on failure show SnackBar.
- Copy Link: `Clipboard.setData` + `ScaffoldMessenger.showSnackBar` "Referral message copied!", then pop dialog.

## Final referral flow

1. User taps **Invite Friends** on Account screen.
2. App calls **CustomerSessionHelper.requireCustomerIdOrRedirect()**. If no valid customer ID → snackbar "Please Sign Up / Sign In first" and redirect to Login; tap ends.
3. If valid customer ID → **InviteFriendsWidget.showInviteDialog(context, customerId)** is called.
4. Dialog opens and shows **loading**.
5. **ReferralService.fetchReferral(customerId)** is called (POST getReferral with api_token + customerID).
6. If API fails or response has no valid referralCode → dialog shows **error** message and **Retry** button.
7. If success → dialog shows **title** "Invite Friends & Earn $15" (from referralAmountExistingCustomer), **body** explaining existing customer earns $15 and referral code, and **four share options**.
8. WhatsApp / Text Message / Email open with **dynamic message** including referral code and "I'll receive $15 credit when you join." Copy Link copies the same message and shows "Referral message copied!".

## Manual setup required from CleanCloud admin

- Ensure **getReferral** is enabled and returns the expected shape for the app (Success, referralCode, referralAmountNewCustomer, referralAmountExistingCustomer, currencySymbol).
- Configure referral amounts so **existing/referring customer** gets the desired credit (e.g. $15) and **new customer** gets $0 if that is the business rule.
- No app-side config for share link URL: message uses referral code only (no store link). If a store link is required later, it can be added in one place (e.g. `buildReferralShareMessage` or a config constant).

## Assumptions made

- **Share link:** No app store or web referral URL is used; share message is text-only with referral code. If CleanCloud or marketing provides a referral URL pattern, it can be appended to the message in `buildReferralShareMessage` or in the invite widget.
- **API response:** Success is determined by `Success == "True"` (or bool true) and non-empty `referralCode`; other fields are optional with safe defaults.
- **Customer ID:** Always obtained via **CustomerSessionHelper.requireCustomerIdOrRedirect()** before opening the dialog; dialog assumes caller has already validated.
- **Errors:** Network or parse errors result in null from `ReferralService.fetchReferral`; dialog shows generic error + Retry. No distinction between network vs server error in UI.
- **share_plus:** Available in pubspec; url_launcher is used for WhatsApp/SMS/Email and Clipboard for Copy Link. share_plus can be added later for a system "Share" option if desired.

## Manual steps still required

1. **CleanCloud:** Ensure getReferral is enabled and returns Success, referralCode, referralAmountExistingCustomer, referralAmountNewCustomer, currencySymbol. Set amounts (e.g. existing $15, new $0).
2. **Test:** With a logged-in user, tap Invite Friends and confirm loading → referral code and share options. Without login, confirm snackbar and redirect to Sign In.
