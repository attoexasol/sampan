// Order History screen — fetches from CleanCloud API, shows All / Active / Completed
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../controller/order_history_controller.dart';
import '../data/models/api_order_model.dart';
import '../widgets/order_history_list_card.dart';
import '../widgets/order_detail_bottom_sheet.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final OrderHistoryController _ctrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<OrderHistoryController>()) {
      Get.put(OrderHistoryController(), permanent: false);
    }
    _ctrl = Get.find<OrderHistoryController>();
    _ctrl.fetchOrders();
  }

  String _orderNumberFor(ApiOrder order, int indexInFilteredList) {
    final date = order.displayDate ?? DateTime.now();
    final list = _ctrl.filteredOrders;
    final seq = (list.length - indexInFilteredList).toString().padLeft(3, '0');
    return 'ORD-${date.year}-$seq';
  }

  void _showOrderDetail(ApiOrder order, String orderNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailBottomSheet(
        order: order,
        orderNumber: orderNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForeground,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (_ctrl.fetchError.value != null) {
                return _buildErrorState();
              }
              final list = _ctrl.filteredOrders;
              if (list.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final order = list[index];
                  final orderNumber = _orderNumberFor(order, index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderHistoryListCard(
                      order: order,
                      orderNumber: orderNumber,
                      onTap: () => _showOrderDetail(order, orderNumber),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      return Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            _tab(0, 'All'),
            const SizedBox(width: 8),
            _tab(1, 'Active'),
            const SizedBox(width: 8),
            _tab(2, 'Completed'),
          ],
        ),
      );
    });
  }

  Widget _tab(int index, String label) {
    final selected = _ctrl.selectedFilterIndex.value == index;
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _ctrl.setFilterIndex(index),
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.primaryForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.mutedForeground.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found yet.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final message = _ctrl.fetchError.value ?? 'Something went wrong.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _ctrl.fetchOrders(),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
