import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/utils.dart';

/// CleanCloud subscription API: add subscription for a customer.
class SubscriptionService {
  /// POST addSubscription. Returns true if API Success == "True".
  static Future<bool> addSubscription(String customerId) async {
    final response = await NetworkCaller.postRequest(
      url: Urls.addSubscription,
      body: {
        'api_token': ApiConfig.apiToken,
        'customerID': customerId,
        'subscriptionID': SubscriptionConfig.dreamBigPlanId,
      },
    );

    if (!response.isSuccess) return false;
    final body = response.body;
    if (body == null) return false;

    final success = body['Success'];
    if (success == null) return false;
    if (success is bool) return success;
    if (success is String) return success.toLowerCase() == 'true';
    return false;
  }
}
