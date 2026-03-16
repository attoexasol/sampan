/// Rush Orders: service-aware timing and pricing.
///
/// Single source of truth:
/// - Laundry: Rush = delivery within 12h of pickup, 2x price, ⚡
/// - Dry Cleaning: Rush = delivery within 24h of pickup, 2x price, ⚡ + note
/// - Specialty (Alterations / Steaming / Shoe Care): no Rush

import 'package:sampan/data/service/express_delivery_service.dart';

enum RushServiceType { laundry, dryCleaning, specialty, unknown }

class RushOrderService {
  RushOrderService._();
  static final RushOrderService instance = RushOrderService._();

  /// Laundry: ready in ~12 hours
  static const int laundryRushWindowHours = 12;
  /// Dry cleaning: ready in up to 24 hours
  static const int dryCleaningRushWindowHours = 24;
  /// Rush = 2x regular price
  static const double rushPriceMultiplier = 2.0;

  /// Normalize service type from route/snapshot to enum
  RushServiceType serviceTypeFromString(String? value) {
    if (value == null || value.isEmpty) return RushServiceType.unknown;
    final v = value.toLowerCase().trim();
    if (v.contains('laundry')) return RushServiceType.laundry;
    if (v.contains('dry') || v.contains('cleaning')) return RushServiceType.dryCleaning;
    if (v.contains('specialty') || v.contains('alteration') || v.contains('steaming') || v.contains('shoe')) return RushServiceType.specialty;
    return RushServiceType.unknown;
  }

  /// Rush window in hours for service; null = no rush
  int? rushWindowHoursFor(RushServiceType type) {
    switch (type) {
      case RushServiceType.laundry:
        return laundryRushWindowHours;
      case RushServiceType.dryCleaning:
        return dryCleaningRushWindowHours;
      case RushServiceType.specialty:
      case RushServiceType.unknown:
        return null;
    }
  }

  /// Whether this service type supports Rush at all
  bool supportsRush(RushServiceType type) {
    return rushWindowHoursFor(type) != null;
  }

  /// For a given delivery slot (with pickup/delivery date+slot), is it valid and does it qualify as Rush?
  /// Uses slot START time for duration. Returns RushSlotResult.
  RushSlotResult evaluateDeliverySlot({
    required RushServiceType serviceType,
    required DateTime? pickupDate,
    required String? pickupTimeSlot,
    required DateTime? deliveryDate,
    required String? deliveryTimeSlot,
  }) {
    final durationHours = ExpressDeliveryService.instance.calculateDurationHours(
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );

    final gapResult = ExpressDeliveryService.instance.checkExpressDelivery(
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );

    final isValidGap = gapResult.isValidGap;
    final windowHours = rushWindowHoursFor(serviceType);
    final isRush = windowHours != null &&
        durationHours != null &&
        durationHours <= windowHours &&
        isValidGap;

    return RushSlotResult(
      isValidGap: isValidGap,
      durationHours: durationHours,
      isRush: isRush,
      rushWindowHours: windowHours,
      serviceType: serviceType,
    );
  }

  /// Human-readable rush label for service
  String rushLabelFor(RushServiceType type) {
    switch (type) {
      case RushServiceType.laundry:
        return 'Rush Laundry';
      case RushServiceType.dryCleaning:
        return 'Rush Dry Cleaning';
      default:
        return 'Rush';
    }
  }

  /// Messaging: Laundry rush
  String get laundryRushMessage =>
      'Double the regular price. Ready in ~12 hours.';

  /// Messaging: Dry cleaning rush
  String get dryCleaningRushMessage =>
      'Double the regular price. Ready in up to ~24 hours.';

  /// Dry cleaning rush confirmation note
  String get dryCleaningRushNote =>
      'For rush dry cleaning, please confirm timing with us before placing the order.';
}

/// Result of evaluating one delivery slot for rush/validity
class RushSlotResult {
  final bool isValidGap;
  final double? durationHours;
  final bool isRush;
  final int? rushWindowHours;
  final RushServiceType serviceType;

  const RushSlotResult({
    required this.isValidGap,
    this.durationHours,
    required this.isRush,
    this.rushWindowHours,
    required this.serviceType,
  });

  bool get canSelect => isValidGap;
}
