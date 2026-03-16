# Referral Feature Project Analysis

## 1. Project Architecture Overview

### Folder structure
- **`lib/`** – main app code
  - **`constants/`** – `colors.dart`, `sizes.dart` (AppColors, AppSizes)
  - **`controller/`** – GetX controllers (e.g. `profile_controller.dart`, `order_history_controller.dart`, `products_controller.dart`)
  - **`data/`**
    - **`data/models/`** – API/domain models (e.g. `api_order_model.dart`, `subscription_state_model.dart`)
    - **`data/service/`** – API and storage: `network_caller.dart`, `local_store.dart`, `utils.dart` (Urls, ApiConfig), `customer_session_helper.dart`, `subscription_service.dart`
  - **`models/`** – other models (e.g. `product_model.dart`)
  - **`modules/`** – feature modules (e.g. `login/`, `signup/`, `laundry/`, `schedule/`, `dry_cleaning/`, `home/`) with views, controllers, bindings
  - **`routes/`** – `app_routes.dart`, `app_pages.dart` (GetX named routes)
  - **`screens/`** – full screens (e.g. `home_screen.dart`, `account_screen.dart`, `order_history_screen.dart`)
  - **`widgets/`** – shared UI (dialogs, cards, e.g. `invite_friends.dart`, `GiftCardDialog.dart`, `DeliveryAddressDialog.dart`)

### State management
- **GetX**: `Get.find<>()`, `Get.to()`, `Get.offAllNamed()`, `Obx()`, reactive `.obs`, bindings for dependency injection. No separate repository/provider layer; controllers and services are used directly.

### Networking pattern
- **`NetworkCaller`** (`lib/data/service/network_caller.dart`): static `postRequest(url, body: Map<String, dynamic>)` and `getRequest(url)`. Returns `NetworkResponse` with `isSuccess`, `statusCode`, `body` (decoded JSON `Map<String, dynamic>?`), `errorMessage`. No global interceptors; each caller builds body and parses response.

### Model / repository / controller pattern
- **No repository layer.** Controllers or widgets call services directly. Services (e.g. `SubscriptionService`) are static/class-based and use `NetworkCaller` + `Urls` + `ApiConfig`. API response models live in `data/models/` with `fromJson` (e.g. `ApiOrder.fromJson`, `OrderHistoryResponse.fromJson`).

### Navigation pattern
- **GetX**: `Get.to(Widget, binding:)` for push, `Get.offAllNamed(Routes.XXX)` for replace (e.g. post-logout to LOGIN). Dialogs: `showDialog(context, builder:)` or `Get.dialog(Widget)`. Routes defined in `app_routes.dart` and `app_pages.dart`.

---

## 2. Auth & Customer Identity

### Where login/signup happens
- **Login:** `lib/modules/login/login_controller.dart` – `login()` calls `NetworkCaller.postRequest(url: Urls.logInAcc, body: { api_token, customerEmail, customerPassword })`. On success, reads `cid` or `CustomerID` from response.
- **Signup:** `lib/modules/signup/signup_controller.dart` – `signup()` calls `NetworkCaller.postRequest(url: Urls.accountCreate, body: {...})`. On success, reads `CustomerID` or `cid` from response.

### Where CustomerID or cid comes from
- **Login response:** `body['cid'] ?? body['CustomerID']` (string or int), then `.toString().trim()`.
- **Signup response:** `body['CustomerID'] ?? body['cid']`, same normalization.
- Both flows also call `LocalStore.instance.saveCustomerIdFromResponse(body)`, which tries multiple keys (CustomerID, cid, etc.) and saves a valid value.

### Where it is stored
- **SharedPreferences** via `LocalStore` singleton (`lib/data/service/local_store.dart`).
- Key: `_customerIdKey = 'customer_id'`. Methods: `saveCustomerId(String)`, `getCustomerId()`, `getValidCustomerId()`, `isValidCustomerId(String?)`. Session clear: `clearSession()` (also clears customer_id); used on logout.

### How to safely read it for referral API
- Use **`CustomerSessionHelper.requireCustomerIdOrRedirect()`** (`lib/data/service/customer_session_helper.dart`). It returns a valid customer ID string or null. If null, it shows snackbar "Please Sign Up / Sign In first" and navigates to `Routes.LOGIN`; caller must abort and not call the API.

---

## 3. API Integration Pattern

### How current API calls are made
- **Pattern:** `NetworkCaller.postRequest(url: Urls.xxx, body: { 'api_token': ApiConfig.apiToken, 'customerID': cid, ... })`. Then check `response.isSuccess` and `response.body`, and parse fields (e.g. `body['Success'] == 'True'`, `body['referralCode']`).

### Where Urls are defined
- **`lib/data/service/utils.dart`** – `class Urls` with `_baseUrl = "https://cleancloudapp.com/api"`. **`Urls.gift`** already exists: `static const String gift = "$_baseUrl/getReferral";` (i.e. getReferral endpoint is already defined).

### Where request bodies are built
- In the caller (controller, service, or widget). Typical body: `api_token` from `ApiConfig.apiToken`, `customerID` from session (via `CustomerSessionHelper.requireCustomerIdOrRedirect()` or `getValidCustomerId()`).

### Where responses are parsed
- In the same place as the call, or in a small service class. Models in `data/models/` use `fromJson(Map<String, dynamic>)` when the response is structured (e.g. `OrderHistoryResponse.fromJson`). Simpler APIs are parsed inline (e.g. `SubscriptionService` checks `body['Success']`).

### Best location for getReferral integration
- **New service:** `lib/data/service/referral_service.dart` (same pattern as `subscription_service.dart`) – static method that calls `NetworkCaller.postRequest(url: Urls.gift, body: { api_token, customerID })`, then parses response into a small model or returns a typed result. Caller (invite UI) gets customer ID via `CustomerSessionHelper.requireCustomerIdOrRedirect()` before calling the service.

---

## 4. Account Screen Analysis

### Exact file(s) for account page
- **`lib/screens/account_screen.dart`** – main Profile/Account screen (StatefulWidget, uses `ProfileController` via `Get.find<ProfileController>()`). Renders header "Profile", then a column of cards and sections.

### Where referral card should be inserted
- The **“Invite Friends”** card already exists: **`_buildInviteFriendsCard()`** at line ~430. It is placed after the 2x2 feature grid (Your Wallet, Buy Gift Card) and before the “Settings” section. No structural change needed; only behavior and data source change (open popup that fetches referral from API and shows correct copy).

### Where bottom sheet/popup should open from
- **Current:** `_buildInviteFriendsCard()` uses `onTap: () => InviteFriendsWidget.showInviteDialog(context)`. So the tap already opens a dialog. The dialog is implemented in **`lib/widgets/invite_friends.dart`** as `InviteFriendsWidget.showInviteDialog(context)` which uses `showDialog(..., builder: (_) => AlertDialog(...))`. This is the right hook: keep opening from the same card, but the content of the dialog/bottom sheet should (1) require customer ID, (2) call getReferral, (3) show share options with API-derived referral code/link and correct text (existing $15, new $0).

---

## 5. UI Components Reuse

### Existing widgets/components to reuse
- **`lib/widgets/invite_friends.dart`** – `InviteFriendsWidget` with `showInviteDialog(context)`, `_inviteOption(icon, title, subtitle, onTap)` for WhatsApp, Text Message, Email, Copy Link. Currently uses hardcoded `referralCode`, `referralLink`, `shareText` and wrong copy (“you'll both get $15”). Reuse the dialog structure and share options; replace data source and copy.
- **Card style on Account:** `_buildInviteFriendsCard()` and other cards use `InkWell` + `Container` with `BoxDecoration`: `color: AppColors.card`, `borderRadius: 12`, `border: Border.all(color: AppColors.border)`, `boxShadow: [ BoxShadow(...) ]`. Same style can be used for any new card if needed.
- **`GiftCardDialog`** (`lib/widgets/GiftCardDialog.dart`) – `Dialog` with `RoundedRectangleBorder(borderRadius: 16)`, header row with title + close `IconButton`, scrollable content. Good reference for a bottom sheet or dialog layout (title, close, body).

### Bottom sheet / dialog styles
- **Dialogs:** `showDialog(context, builder: (_) => AlertDialog(...))` or `Get.dialog(SomeDialog())`. `AlertDialog` with `shape: RoundedRectangleBorder(borderRadius: 16)`.
- **Bottom sheet:** Used elsewhere (e.g. order detail) with `showModalBottomSheet(..., backgroundColor: Colors.transparent, builder: ...)`. Either keep `AlertDialog` for invite or switch to `showModalBottomSheet` for a “reference design” bottom sheet; both are already used in the project.

### Icons/assets handling
- **Icons:** `Icons.*`, `FontAwesomeIcons.*` (font_awesome_flutter), `LucideIcons.*` (lucide_icons). Invite dialog already uses `FontAwesomeIcons.whatsapp`, `Icons.sms`, `Icons.email_outlined`, `Icons.link`.

### Snackbar / loading / error handling
- **Snackbar:** `Get.snackbar(...)` (with check for `Get.overlayContext != null` in helpers to avoid crashes), or `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` when context is available. **CustomerSessionHelper** already shows “Please Sign Up / Sign In first” and redirects; reuse that for missing customer ID.
- **Loading/error:** No global pattern. Typical: set a loading flag in state, show `CircularProgressIndicator` in UI; on error show snackbar or error message. For invite, can show loading in dialog until getReferral returns, then show share options or error.

---

## 6. Referral Feature Implementation Plan

Based on the current codebase, a minimal plan that reuses existing patterns:

1. **Referral API and model**
   - Add **`lib/data/models/referral_response_model.dart`** (or similar name) with a small class for getReferral response: `success`, `referralCode`, `referralType`, `referralAmountNewCustomer`, `referralAmountExistingCustomer`, `referralPercentEarn`, `currencySymbol`, with defensive `fromJson` and null-safe getters.
   - Add **`lib/data/service/referral_service.dart`**: static method `Future<ReferralResponse?> fetchReferral(String customerId)` that calls `NetworkCaller.postRequest(url: Urls.gift, body: { 'api_token': ApiConfig.apiToken, 'customerID': customerId })`, checks `response.isSuccess` and `body['Success'] == 'True'`, then parses body into the model and returns it; otherwise returns null or throws.

2. **Invite flow and customer ID**
   - Before opening the invite UI, call **`CustomerSessionHelper.requireCustomerIdOrRedirect()`**. If null, do not open dialog (user will see snackbar and be sent to Sign In).
   - Only when non-null: open the same invite dialog/bottom sheet; inside it, call `ReferralService.fetchReferral(cid)` (and show loading until done). If fetch fails or returns null/empty code, show error message in dialog and optionally a retry; do not show share options with empty code.

3. **Update invite UI and copy**
   - In **`lib/widgets/invite_friends.dart`**: Remove hardcoded `referralCode`, `referralLink`, `shareText`. Either (a) make the dialog stateful and accept referral data (code, amounts, currency) and build link/text inside, or (b) keep a static show method that first gets customerId via `requireCustomerIdOrRedirect`, then fetches referral, then shows dialog with fetched data. Title: e.g. “Invite Friends & Earn $15” (existing customer amount from API). Body text must reflect **existing customer earns e.g. $15, new customer $0** (use `referralAmountExistingCustomer` and `referralAmountNewCustomer` from API). Build share text/link from `referralCode` (and app store link if applicable).
   - Share actions: Keep WhatsApp, Text Message, Email, Copy Link. Use **`share_plus`** (already in pubspec) for a unified share where appropriate, or keep `url_launcher` for WhatsApp/SMS/Email and Clipboard + toast for Copy Link. Do not call “addReward” or gift-card logic; this is referral only.

4. **Account screen**
   - In **`lib/screens/account_screen.dart`**, **`_buildInviteFriendsCard()`** `onTap`: replace direct `InviteFriendsWidget.showInviteDialog(context)` with: (1) `requireCustomerIdOrRedirect()`; (2) if non-null, call the updated invite flow (e.g. same `showInviteDialog(context)` but the widget internally fetches referral first, or a new method that does require + fetch + show). Optionally update card label to “Invite Friends & Earn $15” to match feature.

5. **No new architecture**
   - No new GetX controller for referral unless you later need reactive state; a static service + a dialog that holds fetch state is enough. Reuse existing Urls.gift, ApiConfig.apiToken, NetworkCaller, CustomerSessionHelper.

### Required files to update
- **`lib/widgets/invite_friends.dart`** – Integrate referral API, correct copy (existing $15, new $0), use referral code/link from API; guard by customer ID (or delegate to caller); loading/error state in dialog.
- **`lib/screens/account_screen.dart`** – In `_buildInviteFriendsCard()` onTap: call `CustomerSessionHelper.requireCustomerIdOrRedirect()` and only open invite UI when ID is present; optionally adjust card title/subtitle.

### Required new files (if needed)
- **`lib/data/models/referral_response_model.dart`** – Model for getReferral response (success, referralCode, referralAmountNewCustomer, referralAmountExistingCustomer, etc.).
- **`lib/data/service/referral_service.dart`** – Static fetch method calling Urls.gift with api_token and customerID, returning parsed model or null.

### Reason for each change
- **referral_response_model.dart** – Type-safe, null-safe parsing of API response; single place to map field names and defaults.
- **referral_service.dart** – Keeps API call and response handling in one place; same pattern as SubscriptionService; callable from invite widget or any future screen.
- **invite_friends.dart** – Currently hardcoded and wrong copy; must use API data and correct messaging (existing $15, new $0).
- **account_screen.dart** – Ensure no dialog opens without a valid customer ID; redirect to Sign In when not logged in.

---

## 7. Proposed Data Model

### Referral response model fields (from API)

| API field (example) | Model field | Type | Notes |
|---------------------|-------------|------|--------|
| Success | success | bool | Map "True" → true |
| referralCode | referralCode | String | Required for share link; default "" |
| referralType | referralType | String? | Optional |
| referralAmountNewCustomer | referralAmountNewCustomer | String | e.g. "0.00"; for UI "New customer gets $0" |
| referralAmountExistingCustomer | referralAmountExistingCustomer | String | e.g. "15.00"; for UI "You earn $15" |
| referralPercentEarn | referralPercentEarn | num? | Optional |
| currencySymbol | currencySymbol | String | e.g. "$"; default "$" |

### Mapping from API response

- Parse in `fromJson(Map<String, dynamic> json)`:
  - `success`: `json['Success'] == 'True'` (or similar).
  - `referralCode`: `json['referralCode']?.toString().trim() ?? ''`.
  - `referralAmountNewCustomer`: `json['referralAmountNewCustomer']?.toString() ?? '0.00'`.
  - `referralAmountExistingCustomer`: `json['referralAmountExistingCustomer']?.toString() ?? '0.00'`.
  - `currencySymbol`: `json['currencySymbol']?.toString() ?? '\$'`.
- Build display strings in the model or in the UI, e.g. “You earn {currencySymbol}{referralAmountExistingCustomer}”, “New customer gets {currencySymbol}{referralAmountNewCustomer}”.

---

## 8. Edge Cases

- **Missing customerID/cid:** Before opening invite UI, call `CustomerSessionHelper.requireCustomerIdOrRedirect()`. If null, do not open dialog; user sees snackbar and is navigated to Sign In. Do not call getReferral.
- **API failure:** If `ReferralService.fetchReferral` returns null or throws (network/parse error), show a short error message in the dialog (e.g. “Could not load referral. Try again.”) and optionally a retry button; do not show share options with empty code.
- **Empty referral code:** If API returns success but `referralCode` is null or empty after trim, treat like API failure: show error in dialog, no share.
- **Null/optional fields:** Model and UI should use defaults (e.g. "0.00" for amounts, "$" for currency). Do not assume presence of optional fields (referralType, referralPercentEarn).
- **Share failure:** If `share_plus` or `url_launcher` fails, optionally show a snackbar (“Share failed”) and/or keep “Copy Link” as fallback. Copy Link: use `Clipboard.setData` and existing toast or `ScaffoldMessenger`; no need to change app state.

---

## 9. Packages

- **share_plus:** Already in **pubspec.yaml** (`share_plus: ^12.0.1`). Not yet used anywhere in `lib/`. Recommend using it for share actions (e.g. `Share.share(shareText)` or platform-specific share) so WhatsApp/SMS/Email can be unified or fallback to system share. No new package required.
- **url_launcher:** Already used in `invite_friends.dart` for WhatsApp/SMS/Email; can keep for deep links or switch to share_plus where appropriate.
- **Fluttertoast:** Used in invite for “Referral link copied!”; can keep for copy feedback or replace with `ScaffoldMessenger.of(context).showSnackBar(...)` if preferred.

---

## 10. Final Recommended Integration Approach

1. **Do not add a new architecture.** Use existing: Urls.gift, ApiConfig.apiToken, NetworkCaller, CustomerSessionHelper, same dialog/bottom sheet style as current invite.
2. **Guard by customer ID at entry:** From Account, on “Invite Friends” card tap, call `CustomerSessionHelper.requireCustomerIdOrRedirect()`. If null, return (snackbar + redirect already done). If non-null, open the invite dialog.
3. **Fetch referral in one place:** New `ReferralService.fetchReferral(customerId)` calling POST `Urls.gift` with `api_token` and `customerID`; return a small `ReferralResponse` model (new file in `data/models/`).
4. **Invite dialog:** When opened (only with valid cid), show loading, call `ReferralService.fetchReferral(cid)`. On success with non-empty `referralCode`, build referral link and share text from code and API amounts; show title “Invite Friends & Earn $15” (or use existing customer amount from API) and body text that states existing customer earns $15 and new customer $0. Show same four options: WhatsApp, Text Message, Email, Copy Link; implement with share_plus and/or url_launcher and Clipboard. On failure or empty code, show error + optional retry inside the dialog.
5. **Leave Account layout and card list unchanged;** only change the onTap behavior and the content of the existing invite dialog so the feature is referral-based, uses CleanCloud getReferral, and matches the required copy and edge-case handling.

---

**Summary of files most likely to change**

- **`lib/widgets/invite_friends.dart`** – Main change: integrate getReferral, correct copy (existing $15, new $0), require customer ID before opening, loading/error state.
- **`lib/screens/account_screen.dart`** – Small change: in `_buildInviteFriendsCard()` onTap, call `requireCustomerIdOrRedirect()` and only open invite when ID is present.
- **New: `lib/data/models/referral_response_model.dart`** – getReferral response model.
- **New: `lib/data/service/referral_service.dart`** – Fetch getReferral using Urls.gift and NetworkCaller.

**Is the project ready for referral integration?**

Yes. Auth and customer ID are centralized (LocalStore + CustomerSessionHelper), the getReferral URL is already defined as `Urls.gift`, the Account screen already has an “Invite Friends” card that opens a dialog, and the existing invite widget already has the share options (WhatsApp, SMS, Email, Copy Link). Only the data source (API vs hardcoded), copy (existing $15 / new $0), and customer-ID guard need to be added; no new architecture or new packages are required.
