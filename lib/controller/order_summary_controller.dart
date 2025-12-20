import 'package:get/get.dart';

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

  /// Calculate totals
  double get subTotal => items.values.fold(0.0, (sum, it) => sum + it.lineTotal);

  double get deliveryFee => subTotal >= 80 ? 0.0 : 10.99;

  double get tax => subTotal * gstRate;

  double get grandTotal => subTotal + deliveryFee + tax;

  /// Get snapshot for navigation
  Map<String, dynamic> snapshot() => {
    'items': items.values.map((e) => e.toJson()).toList(),
    'totals': {
      'subTotal': subTotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'grandTotal': grandTotal,
      'gstRate': gstRate,
    },
  };

  void clearAll() {
    items.clear();
  }
}