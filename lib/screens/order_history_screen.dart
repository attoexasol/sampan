// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../data/models/order_history_model.dart';
import '../data/service/local_store.dart';
import '../widgets/order_summary_card_widget.dart';
import '../widgets/header_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderHistoryItem> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    final orders = await LocalStore.instance.getOrderHistory();

    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to remove this order from history?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalStore.instance.deleteOrderFromHistory(orderId);
      await _loadOrders();
      Get.snackbar(
        'Deleted',
        'Order removed from history',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _showOrderDetails(OrderHistoryItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusLg),
            topRight: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSizes.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Icon(LucideIcons.package,
                              size: AppSizes.iconSm, color: AppColors.primary),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            order.id,
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: OrderSummaryCard(
                  items: order.items,
                  subTotal: order.subTotal,
                  deliveryFee: order.deliveryFee,
                  tax: order.tax,
                  grandTotal: order.grandTotal,
                  pickupDate: order.pickupDate,
                  pickupTimeSlot: order.pickupTimeSlot,
                  deliveryDate: order.deliveryDate,
                  deliveryTimeSlot: order.deliveryTimeSlot,
                  orderId: order.id,
                  status: order.status,
                  createdAt: order.createdAt,
                  isHistoryCard: false,
                  showBorder: true,
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteOrder(order.id);
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        label: Text('Delete', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement reorder functionality
                          Get.snackbar(
                            'Coming Soon',
                            'Reorder feature will be available soon!',
                            backgroundColor: AppColors.primary,
                            colorText: Colors.white,
                          );
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text('Reorder', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_orders.isNotEmpty)
            IconButton(
              onPressed: _loadOrders,
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _buildEmptyState()
          : _buildOrderList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.packageX,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Your order history will appear here once you complete your first order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.mutedForeground,
              ),
            ),
            SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed('/'),
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text('Start Shopping', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.xl,
                  vertical: AppSizes.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.md),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: _buildOrderHistoryCard(order),
          );
        },
      ),
    );
  }

  Widget _buildOrderHistoryCard(OrderHistoryItem order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.package,
                            size: AppSizes.iconSm, color: AppColors.primary),
                        SizedBox(width: AppSizes.xs),
                        Text(
                          order.id,
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),

                SizedBox(height: AppSizes.xs),
                Text(
                  _formatCreatedAt(order.createdAt),
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),

                Divider(height: AppSizes.lg),

                // Schedule Info
                Row(
                  children: [
                    Expanded(
                      child: _buildScheduleInfo(
                        icon: LucideIcons.truck,
                        label: 'Pickup',
                        value: order.formattedPickup,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildScheduleInfo(
                        icon: LucideIcons.home,
                        label: 'Delivery',
                        value: order.formattedDelivery,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                Divider(height: AppSizes.lg),

                // Items Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.totalItemsCount} item${order.totalItemsCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '\$${order.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.sm),

                // Tap for details
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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
}