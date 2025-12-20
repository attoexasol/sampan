class Urls{
   static const String _baseUrl = "https://cleancloudapp.com/api";

   static const String accountCreate = "$_baseUrl/addCustomer";
   static const String logInAcc = "$_baseUrl/loginCustomer";
   static const String PreferencesMsg = "$_baseUrl/addMessage";
   static const String deleteCustomer = "$_baseUrl/deleteCustomer";
   static const String deliverLocation = "$_baseUrl/getRoute";
   static const String getPayments = "$_baseUrl/getPayments";
   static const String PickupDeliveryDates  = "$_baseUrl/getDates";
   static const String PickupDeliveryTimes = "$_baseUrl/getSlots";
   static const String gift = "$_baseUrl/getReferral";
   static const String itemsOfLaundry = "$_baseUrl/getProducts";

   // Payment endpoints
   static const String addCard = "$_baseUrl/addCard";
   static const String chargeCard = "$_baseUrl/chargeCard";
   static const String addOrder = "$_baseUrl/addOrder"; // hypothetical
   static const String StripePayment = "https://clean-cloud.attoexasolutions.com/create-payment-intent";




}