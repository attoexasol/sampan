// API response model for getOrders (CleanCloud)

class ApiOrder {
  final String id;
  final double total;
  final String status; // "0", "1", "2" etc. "2" = Completed
  final DateTime? createdDate;
  final DateTime? completedDate;
  final String? deliveryDate;
  final String? deliveryTime;
  final double weight; // lbs
  final int pieces;
  final String? receiptLink;
  final String? sectionIDs;
  final dynamic services; // may be null from API

  ApiOrder({
    required this.id,
    required this.total,
    required this.status,
    this.createdDate,
    this.completedDate,
    this.deliveryDate,
    this.deliveryTime,
    this.weight = 0,
    this.pieces = 0,
    this.receiptLink,
    this.sectionIDs,
    this.services,
  });

  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v * 1000);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final totalRaw = json['total'];
    double totalVal = 0.0;
    if (totalRaw != null) {
      if (totalRaw is num) totalVal = totalRaw.toDouble();
      else totalVal = double.tryParse(totalRaw.toString()) ?? 0.0;
    }

    final weightRaw = json['weight'];
    double weightVal = 0.0;
    if (weightRaw != null) {
      if (weightRaw is num) weightVal = weightRaw.toDouble();
      else weightVal = double.tryParse(weightRaw.toString()) ?? 0.0;
    }

    final piecesRaw = json['pieces'];
    int piecesVal = 0;
    if (piecesRaw != null) {
      if (piecesRaw is int) piecesVal = piecesRaw;
      else piecesVal = int.tryParse(piecesRaw.toString()) ?? 0;
    }

    return ApiOrder(
      id: json['id']?.toString() ?? '',
      total: totalVal,
      status: json['status']?.toString() ?? '0',
      createdDate: parseDate(json['createdDate'] ?? json['created_at']),
      completedDate: parseDate(json['completedDate'] ?? json['completed_at']),
      deliveryDate: json['deliveryDate']?.toString(),
      deliveryTime: json['deliveryTime']?.toString(),
      weight: weightVal,
      pieces: piecesVal,
      receiptLink: json['receiptLink']?.toString(),
      sectionIDs: json['sectionIDs']?.toString(),
      services: json['services'],
    );
  }

  /// Status display label
  String get statusLabel {
    switch (status) {
      case '2':
        return 'Completed';
      case '1':
        return 'Processing';
      case '0':
        return 'Pending';
      default:
        return 'Completed';
    }
  }

  /// Date for display (created or completed)
  DateTime? get displayDate => completedDate ?? createdDate;
}

class OrderHistoryResponse {
  final bool success;
  final List<ApiOrder> orders;

  OrderHistoryResponse({required this.success, required this.orders});

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    final ordersList = json['Orders'] as List? ?? [];
    final orders = ordersList
        .map((e) => ApiOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    orders.sort((a, b) {
      final da = a.displayDate ?? DateTime(0);
      final db = b.displayDate ?? DateTime(0);
      return db.compareTo(da); // newest first
    });
    return OrderHistoryResponse(
      success: json['Success'] == 'True',
      orders: orders,
    );
  }
}
