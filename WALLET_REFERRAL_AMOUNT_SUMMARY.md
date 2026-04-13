# Wallet Referral Amount — Summary

## Files changed

| File | Change |
|------|--------|
| `lib/widgets/your_wallet.dart` | Wallet screen now fetches referral data on load via existing `ReferralService.fetchReferral(customerId)`. Gets customer ID with `CustomerSessionHelper.getValidCustomerId()` before calling API. Displays **Referral Reward Amount** card using `referralAmountExistingCustomer` and `currencySymbol` from the getReferral response. Added loading (CircularProgressIndicator), error ("Unable to load wallet amount" + Retry), and success/empty (card with amount or $0.00) states. Kept existing `walletBalance` and `addReward` for backward compatibility. |
| `lib/screens/account_screen.dart` | No change. Wallet card already uses `CustomerSessionHelper.requireCustomerIdOrRedirect('your-wallet')` before navigating to `YourWalletWidget()`. |
| `WALLET_REFERRAL_AMOUNT_SUMMARY.md` | This file. |

---

## Endpoint used

- **URL:** CleanCloud getReferral — in the project this is `Urls.gift` (same as `Urls.referral_earned_amount` in `lib/data/service/utils.dart`): `https://cleancloudapp.com/api/getReferral`.

---

## Request body used

- **Method:** POST (via `NetworkCaller.postRequest` inside `ReferralService.fetchReferral`).
- **Body:**
  ```json
  {
    "api_token": "<ApiConfig.apiToken>",
    "customerID": "<valid customer id>"
  }
  ```

---

## Response field used for wallet amount

- **Primary:** `referralAmountExistingCustomer` (e.g. `"15.00"`).
- **Display:** Combined with `currencySymbol` (e.g. `"$"`) as **"Referral Reward Amount"** in the wallet card. The app uses the existing `ReferralResponseModel.existingCustomerRewardText` getter (`'$currencySymbol$referralAmountExistingCustomer'`), so the amount is **not** hardcoded.

---

## Wallet screen behavior

1. **Open:** User taps "Your Wallet" on the account screen. Account screen already calls `CustomerSessionHelper.requireCustomerIdOrRedirect('your-wallet')`; if null, flow stops and user is redirected to login. If valid, `YourWalletWidget()` is pushed.
2. **Load:** In `initState`, the wallet widget calls `CustomerSessionHelper.getValidCustomerId()`. If missing, it sets `_loadFailed = true` and does **not** call the API. If present, it calls `ReferralService.fetchReferral(customerId)`.
3. **Display:** On success, a card shows "Referral Reward Amount", the value from `existingCustomerRewardText` (e.g. `$15.00`), and the subtitle "Current referral reward configured for your account". If the model is null or not successful, the card shows `$0.00`.
4. **No refactor:** Existing `walletBalance` and `addReward` are unchanged for any other usages.

---

## Loading / error behavior

- **Loading:** Full-screen `CircularProgressIndicator` while the referral request is in progress.
- **Error / no customer ID:** Message "Unable to load wallet amount" with a Retry button that calls `_loadReferralAmount()` again.
- **API failure or invalid response:** Treated as failed load; same error UI as above.
- **Success with no/missing amount:** Card is shown with `$0.00` and the subtitle. No crash; nulls are handled via the existing model and fallback `$0.00`.

---

## Assumptions

- **Customer ID:** The account screen guard ensures only logged-in users reach the wallet screen. The widget still re-checks with `getValidCustomerId()`; if null (e.g. session cleared after open), it shows the error state and does not call the API.
- **Referral API:** Same as Invite Friends: `ReferralService` and `ReferralResponseModel` (getReferral) are used as-is; no new service or model was added.
- **URL:** Referral data is loaded from `Urls.gift` (getReferral). `referral_earned_amount` in utils points to the same path; the code uses the existing `ReferralService` that uses `Urls.gift`.
