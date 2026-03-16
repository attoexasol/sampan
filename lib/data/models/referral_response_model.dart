/// CleanCloud getReferral API response.
/// Existing customer earns referralAmountExistingCustomer; new customer gets referralAmountNewCustomer.
class ReferralResponseModel {
  final bool success;
  final String referralCode;
  final String? referralType;
  final String referralAmountNewCustomer;
  final String referralAmountExistingCustomer;
  final num? referralPercentEarn;
  final String currencySymbol;

  const ReferralResponseModel({
    required this.success,
    required this.referralCode,
    this.referralType,
    this.referralAmountNewCustomer = '0.00',
    this.referralAmountExistingCustomer = '0.00',
    this.referralPercentEarn,
    this.currencySymbol = r'$',
  });

  bool get isSuccess => success;

  /// Whether we have a non-empty code to share.
  bool get hasValidCode =>
      referralCode.trim().isNotEmpty;

  /// Display string for existing customer reward, e.g. "\$15.00".
  String get existingCustomerRewardText =>
      '$currencySymbol$referralAmountExistingCustomer';

  /// Display string for new customer reward, e.g. "\$0.00".
  String get newCustomerRewardText =>
      '$currencySymbol$referralAmountNewCustomer';

  static ReferralResponseModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final success = _parseSuccess(json['Success']);
    final referralCode = json['referralCode']?.toString().trim() ?? '';
    final referralType = json['referralType']?.toString();
    final amountNew = json['referralAmountNewCustomer']?.toString().trim() ?? '0.00';
    final amountExisting =
        json['referralAmountExistingCustomer']?.toString().trim() ?? '0.00';
    final percent = json['referralPercentEarn'];
    final symbol = json['currencySymbol']?.toString().trim();
    final currencySymbol = symbol != null && symbol.isNotEmpty ? symbol : r'$';

    return ReferralResponseModel(
      success: success,
      referralCode: referralCode,
      referralType: referralType,
      referralAmountNewCustomer: amountNew,
      referralAmountExistingCustomer: amountExisting,
      referralPercentEarn: percent is num ? percent : null,
      currencySymbol: currencySymbol,
    );
  }

  static bool _parseSuccess(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.trim().toLowerCase() == 'true';
    return false;
  }
}
