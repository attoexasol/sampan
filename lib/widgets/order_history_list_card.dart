// Reusable order summary card for Order History list (API orders)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../data/models/api_order_model.dart';

/// Status badge color: active = blue/orange, completed = green, cancelled = red
Color statusBadgeColor(ApiOrder order) {
  switch (order.statusCategory) {
    case OrderStatusCategory.completed:
      return Colors.green;
    case OrderStatusCategory.cancelled:
      return Colors.red;
    case OrderStatusCategory.active:
    default:
      return const Color(0xFFF59E0B); // amber/orange
  }
}

/// Payment badge: Paid = green, Unpaid = red, Partially Paid = orange
Color paymentBadgeColor(ApiOrder order) {
  final p = order.paymentLabel;
  if (p == 'Unpaid') return Colors.red;
  if (p == 'Partially Paid') return Colors.orange;
  return Colors.green;
}

class OrderHistoryListCard extends StatelessWidget {
  const OrderHistoryListCard({
    super.key,
    required this.order,
    required this.orderNumber,
    required this.onTap,
  });

  final ApiOrder order;
  final String orderNumber;
  final VoidCallback onTap;

  static String formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMd().format(d);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = statusBadgeColor(order);
    final payColor = paymentBadgeColor(order);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cardForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(order.displayDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBadge(order.statusLabel, statusColor),
                  const SizedBox(width: 8),
                  _buildBadge(order.paymentLabel, payColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (order.weight > 0 || order.pieces > 0)
                    Text(
                      _serviceSummary(order),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
              if (order.pickupDeliverySummary != '—') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.delivery_dining, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.pickupDeliverySummary,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _serviceSummary(ApiOrder o) {
    final parts = <String>[];
    if (o.weight > 0) parts.add('${o.weight.toStringAsFixed(0)} lbs');
    if (o.pieces > 0) parts.add('${o.pieces} pcs');
    return parts.isEmpty ? '—' : parts.join(' • ');
  }
}
