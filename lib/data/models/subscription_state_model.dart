/// Local state for Dream Big Plan: pending (Inactive) or active.
/// Pending: isPending=true, no activatedAt/expiresAt. Active: isActive=true, has dates.
class SubscriptionStateModel {
  final String subscriptionId;
  final String planName;
  final String customerId;
  final double price;
  final bool isActive;
  final bool isPending;
  final DateTime? activatedAt;
  final DateTime? expiresAt;

  const SubscriptionStateModel({
    required this.subscriptionId,
    required this.planName,
    required this.customerId,
    this.price = 0,
    this.isActive = false,
    this.isPending = false,
    this.activatedAt,
    this.expiresAt,
  });

  /// Status for UI: add | inactive | active
  String get status {
    if (isActive && activatedAt != null && expiresAt != null) return 'active';
    if (isPending) return 'inactive';
    return 'add';
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() => {
        'subscriptionId': subscriptionId,
        'planName': planName,
        'customerId': customerId,
        'price': price,
        'isActive': isActive,
        'isPending': isPending,
        'activatedAt': activatedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  static SubscriptionStateModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    DateTime? activatedAt;
    DateTime? expiresAt;
    if (json['activatedAt'] != null && json['activatedAt'].toString().isNotEmpty) {
      activatedAt = DateTime.tryParse(json['activatedAt'].toString());
    }
    if (json['expiresAt'] != null && json['expiresAt'].toString().isNotEmpty) {
      expiresAt = DateTime.tryParse(json['expiresAt'].toString());
    }
    final price = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price']?.toString() ?? '') ?? 0.0;
    return SubscriptionStateModel(
      subscriptionId: json['subscriptionId']?.toString() ?? json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      price: price,
      isActive: json['isActive'] == true,
      isPending: json['isPending'] == true,
      activatedAt: activatedAt,
      expiresAt: expiresAt,
    );
  }
}
