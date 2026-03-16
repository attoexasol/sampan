// Order detail bottom sheet for API orders (ApiOrder)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../data/models/api_order_model.dart';
import 'order_history_list_card.dart';

const String _receiptBase = 'https://cleancloudapp.com/';

class OrderDetailBottomSheet extends StatelessWidget {
  const OrderDetailBottomSheet({
    super.key,
    required this.order,
    required this.orderNumber,
  });

  final ApiOrder order;
  final String orderNumber;

  static String formatDateTime(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMd().add_jm().format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _row('Order ID', orderNumber),
                  _row('Created', formatDateTime(order.createdDate)),
                  _row('Status', order.statusLabel),
                  _row('Payment', order.paymentLabel),
                  _row('Total', '\$${order.total.toStringAsFixed(2)}'),
                  if (order.notes != null && order.notes!.trim().isNotEmpty)
                    _row('Notes', order.notes!),
                  if (order.pickupDeliverySummary != '—')
                    _row('Pickup / Delivery', order.pickupDeliverySummary),
                  const SizedBox(height: 16),
                  if (order.weight > 0 || order.pieces > 0) ...[
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (order.weight > 0)
                      _summaryRow(Icons.local_laundry_service, 'Weight', '${order.weight.toStringAsFixed(1)} lbs'),
                    if (order.pieces > 0)
                      _summaryRow(Icons.checkroom, 'Pieces', '${order.pieces}'),
                    const SizedBox(height: 16),
                  ],
                  if (order.receiptLink != null && order.receiptLink!.trim().isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openReceipt(context),
                        icon: const Icon(Icons.receipt),
                        label: const Text('View Receipt'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.cardForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.cardForeground,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReceipt(BuildContext context) async {
    final link = order.receiptLink?.trim();
    if (link == null || link.isEmpty) return;
    final url = _receiptBase + link;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
