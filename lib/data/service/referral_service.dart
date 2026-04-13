import 'package:sampan/data/models/referral_response_model.dart';
import 'package:sampan/data/service/network_caller.dart';
import 'package:sampan/data/service/utils.dart';

/// CleanCloud getReferral API. Returns referral data for the given customer.
class ReferralService {
  /// POST getReferral. Returns parsed model or null on failure/empty.
  static Future<ReferralResponseModel?> fetchReferral(String customerId) async {
    if (customerId.trim().isEmpty) return null;

    final response = await NetworkCaller.postRequest(
      url: Urls.referral_earned_amount,
      body: {
        'api_token': ApiConfig.apiToken,
        'customerID': customerId.trim(),
      },
    );

    if (!response.isSuccess || response.body == null) return null;

    final model = ReferralResponseModel.fromJson(response.body);
    return model;
  }
}
