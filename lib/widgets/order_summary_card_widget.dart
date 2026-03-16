// // lib/widgets/order_summary_card_widget.dart
// import 'package:flutter/material.dart';
// import '../constants/colors.dart';
// import '../constants/sizes.dart';
//
// class OrderSummaryCard extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   final double subTotal;
//   final double deliveryFee;
//   final double tax;
//   final double grandTotal;
//   final bool showBorder;
//
//   const OrderSummaryCard({
//     Key? key,
//     required this.items,
//     required this.subTotal,
//     required this.deliveryFee,
//     required this.tax,
//     required this.grandTotal,
//     this.showBorder = true,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.lg),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//         border: showBorder
//             ? Border.all(color: AppColors.primary, width: 2)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Summary',
//             style: TextStyle(
//               fontSize: AppSizes.fontXl,
//               fontWeight: FontWeight.bold,
//               color: AppColors.foreground,
//             ),
//           ),
//           SizedBox(height: AppSizes.md),
//
//           // Items List
//           ...items.map((item) => Padding(
//             padding: EdgeInsets.only(bottom: AppSizes.sm),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     '${item['title']} (${item['qty']})',
//                     style: TextStyle(fontSize: AppSizes.fontMd),
//                   ),
//                 ),
//                 Text(
//                   '\$${(item['lineTotal'] as num).toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: AppSizes.fontMd,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           )),
//
//           Divider(height: AppSizes.lg),
//
//           // Totals
//           _buildSummaryRow('Subtotal', subTotal),
//           _buildSummaryRow(
//             'Delivery',
//             deliveryFee,
//             isFree: deliveryFee == 0,
//           ),
//           _buildSummaryRow('Tax (GST)', tax),
//
//           Divider(height: AppSizes.lg),
//
//           _buildSummaryRow(
//             'Total',
//             grandTotal,
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, double amount,
//       {bool isTotal = false, bool isFree = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? AppSizes.fontLg : AppSizes.fontMd,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//               color: AppColors.foreground,
//             ),
//           ),
//           Text(
//             isFree ? 'FREE' : '\$${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: isTotal ? AppSizes.fontXl : AppSizes.fontMd,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
//               color: isTotal ? AppColors.primary : AppColors.foreground,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class EmptyOrderSummaryCard extends StatelessWidget {
//   const EmptyOrderSummaryCard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.xl),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(
//               Icons.shopping_cart_outlined,
//               size: 50,
//               color: AppColors.mutedForeground,
//             ),
//             SizedBox(height: AppSizes.md),
//             Text(
//               'No items selected',
//               style: TextStyle(
//                 fontSize: AppSizes.fontLg,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.foreground,
//               ),
//             ),
//             SizedBox(height: AppSizes.xs),
//             Text(
//               'Add items to see your order summary',
//               style: TextStyle(
//                 fontSize: AppSizes.fontMd,
//                 color: AppColors.mutedForeground,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










// lib/widgets/order_summary_card_widget.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class OrderSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double deliveryFee;
  final double tax;
  final double grandTotal;
  final bool showBorder;

  // Express / Rush delivery
  final double expressFee;
  final bool isExpressDelivery;
  final bool isRushDelivery;

  // Pickup/Delivery scheduling info
  final String? pickupDate;
  final String? pickupTimeSlot;
  final String? deliveryDate;
  final String? deliveryTimeSlot;

  // For order history display
  final String? orderId;
  final String? status;
  final DateTime? createdAt;
  final bool isHistoryCard;
  final VoidCallback? onTap;

  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subTotal,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
    this.showBorder = true,
    this.expressFee = 0.0,
    this.isExpressDelivery = false,
    this.isRushDelivery = false,
    this.pickupDate,
    this.pickupTimeSlot,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.orderId,
    this.status,
    this.createdAt,
    this.isHistoryCard = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasScheduleInfo = (pickupDate != null && pickupDate!.isNotEmpty) ||
        (deliveryDate != null && deliveryDate!.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: showBorder
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Order ID and Status (for history)
            if (isHistoryCard && orderId != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.package,
                          size: AppSizes.iconSm, color: AppColors.primary),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        orderId!,
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (status != null) _buildStatusBadge(status!),
                ],
              ),
              if (createdAt != null) ...[
                SizedBox(height: AppSizes.xs),
                Text(
                  _formatCreatedAt(createdAt!),
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
              Divider(height: AppSizes.lg),
            ] else ...[
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(height: AppSizes.md),
            ],

            // Schedule Section (Pickup & Delivery)
            if (hasScheduleInfo) ...[
              _buildScheduleSection(),
              Divider(height: AppSizes.lg),
            ],

            // Items List
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['title']} (${item['qty']})',
                      style: TextStyle(fontSize: AppSizes.fontMd),
                    ),
                  ),
                  Text(
                    '\$${(item['lineTotal'] as num).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),

            Divider(height: AppSizes.lg),

            // Totals
            _buildSummaryRow('Subtotal', subTotal),
            _buildSummaryRow(
              'Delivery',
              deliveryFee,
              isFree: deliveryFee == 0,
            ),
            if (isRushDelivery)
              _buildSummaryRow('Rush (2× price)', 0, isExpress: true, isRushLabel: true),
            if (isExpressDelivery && expressFee > 0 && !isRushDelivery)
              _buildSummaryRow(
                'Express Fee (5%)',
                expressFee,
                isExpress: true,
              ),
            _buildSummaryRow('Tax (GST)', tax),

            Divider(height: AppSizes.lg),

            _buildSummaryRow(
              'Total',
              grandTotal,
              isTotal: true,
            ),

            // Tap indicator for history cards
            if (isHistoryCard && onTap != null) ...[
              SizedBox(height: AppSizes.sm),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    SizedBox(width: AppSizes.xs),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the schedule section showing pickup and delivery info
  Widget _buildScheduleSection() {
    final showRushOrExpress = isRushDelivery || isExpressDelivery;
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: showRushOrExpress
            ? Colors.orange.shade50
            : AppColors.primaryLighter.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: showRushOrExpress
              ? Colors.orange.shade300
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          if (isRushDelivery) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Rush',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.sm),
          ],
          if (isExpressDelivery && !isRushDelivery) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Express Delivery',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.sm),
          ],
          
          // Pickup Row
          if (pickupDate != null && pickupDate!.isNotEmpty)
            _buildScheduleRow(
              icon: LucideIcons.truck,
              label: 'Pickup',
              date: pickupDate!,
              time: pickupTimeSlot,
              iconColor: AppColors.primary,
            ),

          if (pickupDate != null && pickupDate!.isNotEmpty &&
              deliveryDate != null && deliveryDate!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Row(
                children: [
                  SizedBox(width: AppSizes.iconSm + AppSizes.sm),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isExpressDelivery 
                          ? Colors.orange.shade200 
                          : AppColors.border,
                    ),
                  ),
                ],
              ),
            ),

          // Delivery Row with rush/express icon
          if (deliveryDate != null && deliveryDate!.isNotEmpty)
            _buildScheduleRow(
              icon: (isRushDelivery || isExpressDelivery) ? Icons.bolt : LucideIcons.home,
              label: 'Delivery',
              date: deliveryDate!,
              time: deliveryTimeSlot,
              iconColor: (isRushDelivery || isExpressDelivery) ? Colors.orange.shade700 : Colors.green,
              showExpressBadge: isRushDelivery || isExpressDelivery,
              badgeLabel: isRushDelivery ? 'Rush' : null,
            ),
        ],
      ),
    );
  }

  /// Build a single schedule row (pickup or delivery)
  Widget _buildScheduleRow({
    required IconData icon,
    required String label,
    required String date,
    String? time,
    required Color iconColor,
    bool showExpressBadge = false,
    String? badgeLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: iconColor),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  if (showExpressBadge) ...[
                    SizedBox(width: 6),
                    Icon(Icons.bolt, size: 12, color: Colors.orange.shade700),
                    SizedBox(width: 2),
                    Text(
                      badgeLabel ?? 'Express',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              if (time != null && time.isNotEmpty) ...[
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(LucideIcons.clock,
                        size: 12, color: AppColors.mutedForeground),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build status badge for order history
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'processing':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      default: // pending
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _formatCreatedAt(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, bool isFree = false, bool isExpress = false, bool isRushLabel = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isExpress || isRushLabel) ...[
                Icon(
                  Icons.bolt,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? AppSizes.fontLg : AppSizes.fontMd,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: (isExpress || isRushLabel) ? Colors.orange.shade700 : AppColors.foreground,
                ),
              ),
            ],
          ),
          Text(
            isRushLabel ? 'Included' : (isFree ? 'FREE' : '\$${amount.toStringAsFixed(2)}'),
            style: TextStyle(
              fontSize: isTotal ? AppSizes.fontXl : AppSizes.fontMd,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal 
                  ? AppColors.primary 
                  : ((isExpress || isRushLabel) ? Colors.orange.shade700 : AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyOrderSummaryCard extends StatelessWidget {
  const EmptyOrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: AppColors.mutedForeground,
            ),
            SizedBox(height: AppSizes.md),
            Text(
              'No items selected',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              'Add items to see your order summary',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}












