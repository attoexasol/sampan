/// Same api_token for every user (app-level). customerID is per-user and stored locally after login/signup.
class ApiConfig {
  static const String apiToken = 'af547bb45f372a7b1171ba7a304fcd84ab319852';
}

/// Dream Big Plan subscription config (CleanCloud subscription ID and display).
class SubscriptionConfig {
  static const String dreamBigPlanId = '5483';
  static const String dreamBigPlanName = 'Dream Big Plan';
  static const double dreamBigPlanPrice = 69.0;
}

class Urls {
  static const String baseUrl = "https://cleancloudapp.com/api";
  static const String _baseUrl = baseUrl;

  // Auth — save CustomerID (signup) or cid (login) from responses; same identity, single storage key
   static const String accountCreate = "$_baseUrl/addCustomer";   // Response: CustomerID
   static const String logInAcc = "$_baseUrl/loginCustomer";      // Response: cid
   static const String PreferencesMsg = "$_baseUrl/addMessage";                                                   //
  static const String deleteCustomer = "$_baseUrl/deleteCustomer";
  static const String updateCustomerAddress = "$_baseUrl/updateCustomer";
  static const String getOrders_History = "$_baseUrl/getOrders";
  static const String ResetPassword = "$_baseUrl/passwordCustomer";

  // Services
   static const String deliverLocation = "$_baseUrl/getRoute";
   static const String PickupDeliveryDates  = "$_baseUrl/getDates";
   static const String PickupDeliveryTimes = "$_baseUrl/getSlots";
   static const String referral_earned_amount = "$_baseUrl/getReferral";
   static const String itemsOfLaundry = "$_baseUrl/getProducts";



   // Payment endpoints
   static const String getPayments = "$_baseUrl/getPayments";
   static const String addCard = "$_baseUrl/addCard";
   static const String chargeCard = "$_baseUrl/chargeCard";
   static const String addOrder = "$_baseUrl/addOrder"; // hypothetical
   static const String StripePayment = "https://clean-cloud.attoexasolutions.com/create-payment-intent";


   // Subscription
   static const String addSubscription = "$baseUrl/addSubscription";
   static const String getSubscriptions = "$baseUrl/getSubscription";

// 1. Premium Bag Service
// 2. Subscriptions
// 3. Want it sooner?
// 4. Your Order History
// 5. Your Wallet
// 6. Send a Gift Card
// 7. Invite Friends & Earn $15
// 8. Rate Your Experience
// 9. Delivery Address



// 1. Premium Bag Service ;
// 2 Want it sooner?     ;
// 3 Your Wallet         ;
// 4 Invite Friends & Earn $15
// 5 Rate Your Experience
// 6 Delivery Address
//
// 2. Subscriptions                https://cleancloudapp.com/api/getSubscription
// 4. Your Order History           https://cleancloudapp.com/api/getMessages
// 6. Send a Gift Card             https://cleancloudapp.com/api/getReferral


}

/// Backend endpoints for referral validation and reward (your backend; change base if different).
class AuthEndpoints {
  static const String backendBaseUrl = 'https://cleancloudapp.com/api';
  static String get validateReferralCode => '$backendBaseUrl/validate-referral-code';
  static String get applyReferral => '$backendBaseUrl/referral/apply';
}