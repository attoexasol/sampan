class Urls{
   static const String _baseUrl = "https://cleancloudapp.com/api";


  // Auth
   static const String accountCreate = "$_baseUrl/addCustomer";
   static const String logInAcc = "$_baseUrl/loginCustomer";
   static const String PreferencesMsg = "$_baseUrl/addMessage";
   static const String deleteCustomer = "$_baseUrl/deleteCustomer";


   // Services
   static const String deliverLocation = "$_baseUrl/getRoute";
   static const String PickupDeliveryDates  = "$_baseUrl/getDates";
   static const String PickupDeliveryTimes = "$_baseUrl/getSlots";
   static const String gift = "$_baseUrl/getReferral";
   static const String itemsOfLaundry = "$_baseUrl/getProducts";



   // Payment endpoints
   static const String getPayments = "$_baseUrl/getPayments";
   static const String addCard = "$_baseUrl/addCard";
   static const String chargeCard = "$_baseUrl/chargeCard";
   static const String addOrder = "$_baseUrl/addOrder"; // hypothetical
   static const String StripePayment = "https://clean-cloud.attoexasolutions.com/create-payment-intent";



// 1. Premium Bag Service
// 2. Subscriptions
// 3. Want it sooner?
// 4. Your Order History
// 5. Your Wallet
// 6. Send a Gift Card
// 7. Invite Friends & Earn $15
// 8. Rate Your Experience
// 9. Delivery Address









}