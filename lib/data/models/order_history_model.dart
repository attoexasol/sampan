// lib/models/order_history_model.dart
import 'dart:convert';

class OrderHistoryItem {
  final String id;
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double deliveryFee;
  final double tax;
  final double grandTotal;
  final String? pickupDate;
  final String? pickupTimeSlot;
  final String? deliveryDate;
  final String? deliveryTimeSlot;
  final String status; // pending, processing, completed, cancelled
  final DateTime createdAt;

  OrderHistoryItem({
    required this.id,
    required this.items,
    required this.subTotal,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
    this.pickupDate,
    this.pickupTimeSlot,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Generate a unique order ID
  static String generateOrderId() {
    final now = DateTime.now();
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'subTotal': subTotal,
    'deliveryFee': deliveryFee,
    'tax': tax,
    'grandTotal': grandTotal,
    'pickupDate': pickupDate,
    'pickupTimeSlot': pickupTimeSlot,
    'deliveryDate': deliveryDate,
    'deliveryTimeSlot': deliveryTimeSlot,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ?? [],
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      pickupDate: json['pickupDate'],
      pickupTimeSlot: json['pickupTimeSlot'],
      deliveryDate: json['deliveryDate'],
      deliveryTimeSlot: json['deliveryTimeSlot'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Get formatted pickup info
  String get formattedPickup {
    if (pickupDate == null || pickupDate!.isEmpty) return 'Not scheduled';
    return '$pickupDate${pickupTimeSlot != null && pickupTimeSlot!.isNotEmpty ? ' • $pickupTimeSlot' : ''}';
  }

  /// Get formatted delivery info
  String get formattedDelivery {
    if (deliveryDate == null || deliveryDate!.isEmpty) return 'Not scheduled';
    return '$deliveryDate${deliveryTimeSlot != null && deliveryTimeSlot!.isNotEmpty ? ' • $deliveryTimeSlot' : ''}';
  }

  /// Get total items count
  int get totalItemsCount {
    int count = 0;
    for (var item in items) {
      count += (item['qty'] as num?)?.toInt() ?? 1;
    }
    return count;
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'processing':
        return 'blue';
      case 'cancelled':
        return 'red';
      default:
        return 'orange';
    }
  }

  /// Copy with new values
  OrderHistoryItem copyWith({
    String? id,
    List<Map<String, dynamic>>? items,
    double? subTotal,
    double? deliveryFee,
    double? tax,
    double? grandTotal,
    String? pickupDate,
    String? pickupTimeSlot,
    String? deliveryDate,
    String? deliveryTimeSlot,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderHistoryItem(
      id: id ?? this.id,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      grandTotal: grandTotal ?? this.grandTotal,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}