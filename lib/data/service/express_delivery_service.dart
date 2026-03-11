/// Express Delivery Service
/// 
/// Handles automatic express delivery detection and validation.
/// 
/// Rules:
/// - Express Delivery: delivery within 24 hours of pickup
/// - Express Fee: 5% of subtotal
/// - Minimum Gap: 4 hours between pickup and delivery
/// - If gap < 4 hours: block checkout

class ExpressDeliveryService {
  ExpressDeliveryService._();
  static final ExpressDeliveryService instance = ExpressDeliveryService._();

  /// Express fee rate (5% of subtotal)
  static const double expressRatePercent = 0.05;

  /// Express threshold: delivery within 24 hours of pickup
  static const int expressThresholdHours = 24;

  /// Minimum gap between pickup and delivery (4 hours)
  static const int minimumGapHours = 4;

  /// Time slot definitions (start hour for each slot)
  static const Map<String, int> timeSlotStartHours = {
    '8:00 AM - 10:00 AM': 8,
    '10:00 AM - 12:00 PM': 10,
    '12:00 PM - 2:00 PM': 12,
    '2:00 PM - 4:00 PM': 14,
    '4:00 PM - 6:00 PM': 16,
  };

  /// Time slot definitions (end hour for each slot)
  static const Map<String, int> timeSlotEndHours = {
    '8:00 AM - 10:00 AM': 10,
    '10:00 AM - 12:00 PM': 12,
    '12:00 PM - 2:00 PM': 14,
    '2:00 PM - 4:00 PM': 16,
    '4:00 PM - 6:00 PM': 18,
  };

  /// Parse a date and time slot into a DateTime (start time of the slot)
  DateTime? parsePickupDateTime(DateTime? date, String? timeSlot) {
    if (date == null || timeSlot == null || timeSlot.isEmpty) return null;
    
    final startHour = timeSlotStartHours[timeSlot];
    if (startHour == null) return null;
    
    return DateTime(date.year, date.month, date.day, startHour, 0, 0);
  }

  /// Parse a date and time slot into a DateTime (end time of the slot for delivery)
  DateTime? parseDeliveryDateTime(DateTime? date, String? timeSlot) {
    if (date == null || timeSlot == null || timeSlot.isEmpty) return null;
    
    final startHour = timeSlotStartHours[timeSlot];
    if (startHour == null) return null;
    
    return DateTime(date.year, date.month, date.day, startHour, 0, 0);
  }

  /// Calculate duration in hours between pickup and delivery
  double? calculateDurationHours({
    required DateTime? pickupDate,
    required String? pickupTimeSlot,
    required DateTime? deliveryDate,
    required String? deliveryTimeSlot,
  }) {
    final pickupDateTime = parsePickupDateTime(pickupDate, pickupTimeSlot);
    final deliveryDateTime = parseDeliveryDateTime(deliveryDate, deliveryTimeSlot);
    
    if (pickupDateTime == null || deliveryDateTime == null) return null;
    
    final duration = deliveryDateTime.difference(pickupDateTime);
    return duration.inMinutes / 60.0;
  }

  /// Check if delivery qualifies as express (within 24 hours of pickup)
  ExpressDeliveryResult checkExpressDelivery({
    required DateTime? pickupDate,
    required String? pickupTimeSlot,
    required DateTime? deliveryDate,
    required String? deliveryTimeSlot,
  }) {
    final durationHours = calculateDurationHours(
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );

    if (durationHours == null) {
      return ExpressDeliveryResult(
        isExpress: false,
        isValidGap: true,
        durationHours: null,
        message: null,
      );
    }

    final isExpress = durationHours < expressThresholdHours;
    final isValidGap = durationHours >= minimumGapHours;

    String? message;
    if (!isValidGap) {
      message = 'Minimum ${minimumGapHours} hours required between pickup and delivery';
    } else if (isExpress) {
      message = 'Express Delivery: ${durationHours.toStringAsFixed(1)} hours turnaround';
    }

    return ExpressDeliveryResult(
      isExpress: isExpress,
      isValidGap: isValidGap,
      durationHours: durationHours,
      message: message,
    );
  }

  /// Calculate express fee based on subtotal
  double calculateExpressFee(double subtotal, bool isExpress) {
    if (!isExpress) return 0.0;
    return subtotal * expressRatePercent;
  }

  /// Get human-readable duration string
  String formatDuration(double? hours) {
    if (hours == null) return '';
    
    if (hours < 1) {
      return '${(hours * 60).round()} minutes';
    } else if (hours < 24) {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      if (m > 0) {
        return '$h hours $m min';
      }
      return '$h hours';
    } else {
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      if (remainingHours > 0) {
        return '$days day${days > 1 ? 's' : ''} $remainingHours hours';
      }
      return '$days day${days > 1 ? 's' : ''}';
    }
  }
}

/// Result of express delivery check
class ExpressDeliveryResult {
  final bool isExpress;
  final bool isValidGap;
  final double? durationHours;
  final String? message;

  const ExpressDeliveryResult({
    required this.isExpress,
    required this.isValidGap,
    required this.durationHours,
    required this.message,
  });

  bool get canProceed => isValidGap;

  @override
  String toString() {
    return 'ExpressDeliveryResult(isExpress: $isExpress, isValidGap: $isValidGap, '
        'durationHours: $durationHours, message: $message)';
  }
}
