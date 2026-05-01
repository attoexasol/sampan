import 'package:get/get.dart';
import '../data/service/express_delivery_service.dart';
import '../data/service/rush_order_service.dart';

class SummaryItem {
  final String key;          // unique id (e.g., 'elite', 'sub', 'payg', 'pillow')
  final String title;        // display title
  final String subtitle;     // small line under title
  final double unitPrice;    // per piece/bag/line
  int qty;                   // quantity for items (1 for one-off services)
  final bool isService;      // if true => show as single line item

  SummaryItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.unitPrice,
    this.qty = 1,
    this.isService = true,
  });

  double get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'subtitle': subtitle,
    'unitPrice': unitPrice,
    'qty': qty,
    'isService': isService,
    'lineTotal': lineTotal,
  };
}


class OrderSummaryController extends GetxController {
  final data = <String, dynamic>{}.obs;

  void setFromMap(Map<String, dynamic> map) => data.value = map;
  Map<String, dynamic> get value => data;
  bool get isEmpty => data.isEmpty;

  /// Selected items with quantities
  final RxMap<String, SummaryItem> items = <String, SummaryItem>{}.obs;

  /// GST / tax
  final double gstRate = 0.05;

  /// Express delivery state (automatically set based on schedule)
  final RxBool isExpressDelivery = false.obs;
  final RxDouble expressDurationHours = 0.0.obs;

  /// Rush delivery: slot within service rush window (12h laundry, 24h dry cleaning). 2x price, no express fee.
  final RxBool isRushDelivery = false.obs;

  bool get hasAnySelection => items.isNotEmpty;

  /// Toggle or update item quantity
  void updateItem({
    required String key,
    required String title,
    required String subtitle,
    required double price,
    required int qty,
  }) {
    if (qty <= 0) {
      items.remove(key);
    } else {
      items[key] = SummaryItem(
        key: key,
        title: title,
        subtitle: subtitle,
        unitPrice: price,
        qty: qty,
        isService: false,
      );
    }
  }

  /// Get item quantity
  int getItemQty(String key) => items[key]?.qty ?? 0;

  /// Increment item
  void incrementItem({
    required String key,
    required String title,
    required String subtitle,
    required double price,
  }) {
    final currentQty = getItemQty(key);
    updateItem(
      key: key,
      title: title,
      subtitle: subtitle,
      price: price,
      qty: currentQty + 1,
    );
  }

  /// Decrement item
  void decrementItem(String key) {
    final currentQty = getItemQty(key);
    if (currentQty > 0) {
      final item = items[key]!;
      updateItem(
        key: key,
        title: item.title,
        subtitle: item.subtitle,
        price: item.unitPrice,
        qty: currentQty - 1,
      );
    }
  }

  /// Base subtotal (before rush multiplier)
  double get baseSubTotal => items.values.fold(0.0, (sum, it) => sum + it.lineTotal);

  /// Subtotal: 2x when Rush, else 1x
  double get subTotal {
    final base = baseSubTotal;
    return isRushDelivery.value ? base * RushOrderService.rushPriceMultiplier : base;
  }

  double get deliveryFee {
    final base = baseSubTotal;
    return base >= 80 ? 0.0 : 10.99;
  }

  /// Express fee: 0 when Rush; otherwise 5% of base subtotal if express delivery
  double get expressFee {
    if (isRushDelivery.value) return 0.0;
    return ExpressDeliveryService.instance.calculateExpressFee(
      baseSubTotal,
      isExpressDelivery.value,
    );
  }

  double get tax => subTotal * gstRate;

  double get grandTotal => subTotal + deliveryFee + expressFee + tax;

  /// Set rush and express delivery state from schedule. Call with serviceType from ScheduleController.
  void setRushAndExpressDelivery({
    required String? serviceType,
    required DateTime? pickupDate,
    required String? pickupTimeSlot,
    required DateTime? deliveryDate,
    required String? deliveryTimeSlot,
  }) {
    final rushType = RushOrderService.instance.serviceTypeFromString(serviceType);
    final rushResult = RushOrderService.instance.evaluateDeliverySlot(
      serviceType: rushType,
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );
    final expressResult = ExpressDeliveryService.instance.checkExpressDelivery(
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );

    isRushDelivery.value = rushResult.isRush;
    isExpressDelivery.value = !rushResult.isRush && expressResult.isExpress;
    expressDurationHours.value = expressResult.durationHours ?? rushResult.durationHours ?? 0.0;
  }

  /// Set express delivery state based on schedule (legacy; prefer setRushAndExpressDelivery)
  void setExpressDelivery({
    required DateTime? pickupDate,
    required String? pickupTimeSlot,
    required DateTime? deliveryDate,
    required String? deliveryTimeSlot,
  }) {
    final result = ExpressDeliveryService.instance.checkExpressDelivery(
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
    );
    isRushDelivery.value = false;
    isExpressDelivery.value = result.isExpress;
    expressDurationHours.value = result.durationHours ?? 0.0;
  }

  /// Reset express and rush state
  void resetExpressDelivery() {
    isExpressDelivery.value = false;
    isRushDelivery.value = false;
    expressDurationHours.value = 0.0;
  }

  /// Get snapshot for navigation
  Map<String, dynamic> snapshot() => {
    'items': items.values.map((e) => e.toJson()).toList(),
    'totals': {
      'subTotal': subTotal,
      'deliveryFee': deliveryFee,
      'expressFee': expressFee,
      'tax': tax,
      'grandTotal': grandTotal,
      'gstRate': gstRate,
      'isExpressDelivery': isExpressDelivery.value,
      'isRushDelivery': isRushDelivery.value,
      'expressDurationHours': expressDurationHours.value,
    },
  };

  /// Clears every piece of cart/order state so the summary UI
  /// (totals, items, express/rush badges) collapses back to its empty state.
  /// Call this after a successful checkout / payment.
  void clearAll() {
    items.clear();
    data.clear();
    isExpressDelivery.value = false;
    isRushDelivery.value = false;
    expressDurationHours.value = 0.0;
  }
}