import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../controller/order_history_controller.dart';
import '../data/models/api_order_model.dart';

const String _receiptBase = 'https://cleancloudapp.com/';

class OrderHistoryDialog extends StatefulWidget {
  const OrderHistoryDialog({Key? key}) : super(key: key);

  @override
  State<OrderHistoryDialog> createState() => _OrderHistoryDialogState();
}

class _OrderHistoryDialogState extends State<OrderHistoryDialog> {
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

  static String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMMd().format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Order History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete history of your laundry services and eco contributions',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.mutedForeground,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Order List
            Flexible(
              child: Obx(() {
                if (_ctrl.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final totalImpact = _ctrl.totalEnvironmentalImpact;
                final orderList = _ctrl.orders;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ...orderList.asMap().entries.map(
                            (e) => _buildOrderCard(e.value, e.key),
                          ),
                      const SizedBox(height: 20),
                      _buildTotalEnvironmentalImpact(totalImpact),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),

            // Close Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ApiOrder order, int index) {
    final orderId = order.id;
    final isExpanded = _ctrl.isExpanded(orderId);
    final orderNumber = _ctrl.orderNumberFor(order, index);
    final environmental = _ctrl.environmentalForOrder(order);
    final servicesMap = _ctrl.getServicesForOrder(orderId);
    final hasDetails = servicesMap.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primaryLighter.withOpacity(0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primary : AppColors.border,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _ctrl.toggleExpanded(orderId),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.displayDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (order.weight > 0)
                  _buildSummaryIcon(Icons.local_laundry_service, '${order.weight.toStringAsFixed(0)} lbs'),
                if (order.pieces > 0)
                  _buildSummaryIcon(Icons.checkroom, '${order.pieces} items'),
              ],
            ),
          ),

          if (isExpanded) ...[
            Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDetails)
                    ..._buildServicesSectionFromMap(servicesMap),
                  if (!hasDetails)
                    Padding(
                      padding: const EdgeInsets.only(left: 28, top: 4, bottom: 16),
                      child: Text(
                        'Order details unavailable',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  if (hasDetails) const SizedBox(height: 16),
                  _buildEnvironmentalContribution(environmental),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openReceipt(order),
                          icon: const Icon(Icons.receipt),
                          label: const Text('View Receipt'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar(
                              'Reorder',
                              'Reorder coming soon',
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Reorder', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openReceipt(ApiOrder order) async {
    final link = order.receiptLink?.trim();
    if (link == null || link.isEmpty) {
      Get.snackbar(
        'Receipt',
        'Receipt not available',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final url = _receiptBase + link;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open receipt',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildSummaryIcon(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildServicesSectionFromMap(
      Map<String, List<Map<String, dynamic>>> services) {
    final List<Widget> widgets = [];
    const categories = [
      ('laundry', 'Laundry Services', Icons.local_laundry_service),
      ('dryCleaning', 'Dry Cleaning', Icons.dry_cleaning),
      ('steaming', 'Steaming Services', Icons.air),
      ('alterations', 'Alterations', Icons.content_cut),
      ('shoeCare', 'Shoe Care', Icons.shopping_bag),
    ];
    for (final c in categories) {
      final items = services[c.$1];
      if (items != null && items.isNotEmpty) {
        widgets.add(_buildServiceCategory(c.$2, c.$3, items));
      }
    }
    return widgets;
  }

  List<Widget> _buildServicesSection(Map<String, dynamic> services) {
    final List<Widget> widgets = [];
    if (services['laundry'] != null) {
      widgets.add(_buildServiceCategory(
        'Laundry Services',
        Icons.local_laundry_service,
        List<Map<String, dynamic>>.from(
          (services['laundry'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      ));
    }
    if (services['dryCleaning'] != null) {
      widgets.add(_buildServiceCategory(
        'Dry Cleaning',
        Icons.dry_cleaning,
        List<Map<String, dynamic>>.from(
          (services['dryCleaning'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      ));
    }
    if (services['steaming'] != null) {
      widgets.add(_buildServiceCategory(
        'Steaming Services',
        Icons.air,
        List<Map<String, dynamic>>.from(
          (services['steaming'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      ));
    }
    if (services['alterations'] != null) {
      widgets.add(_buildServiceCategory(
        'Alterations',
        Icons.content_cut,
        List<Map<String, dynamic>>.from(
          (services['alterations'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      ));
    }
    if (services['shoeCare'] != null) {
      widgets.add(_buildServiceCategory(
        'Shoe Care',
        Icons.shopping_bag,
        List<Map<String, dynamic>>.from(
          (services['shoeCare'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildServiceCategory(
      String title, IconData icon, List<Map<String, dynamic>> items) {
    double priceFrom(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            final name = item['name']?.toString() ?? '—';
            final value = item['value']?.toString();
            final price = priceFrom(item['price']);
            return Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (value != null && value.isNotEmpty)
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalContribution(Map<String, double> environmental) {
    final w = environmental['water'] ?? 0.0;
    final d = environmental['detergent'] ?? 0.0;
    final g = environmental['gas'] ?? 0.0;
    final e = environmental['energy'] ?? 0.0;
    final c = environmental['co2'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Environmental Contribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.water_drop,
                  Colors.blue,
                  'Water Saved',
                  '${w.toStringAsFixed(1)} gal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.cleaning_services,
                  const Color(0xFFEC4899),
                  'Detergent Saved',
                  '${d.toStringAsFixed(1)} fl oz',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.local_fire_department,
                  Colors.orange,
                  'Gas Saved',
                  '${g.toStringAsFixed(2)} therms',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.bolt,
                  Colors.amber,
                  'Energy Saved',
                  '${e.toStringAsFixed(1)} kWh',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.eco, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CO₂ Avoided: ${c.toStringAsFixed(2)} kg',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalMetric(IconData icon, Color color, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildTotalEnvironmentalImpact(Map<String, double> total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Your Total Environmental Impact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTotalMetric('Total Water Saved', '${total['water']!.toStringAsFixed(1)} gal'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTotalMetric('Total Detergent Saved', '${total['detergent']!.toStringAsFixed(1)} fl oz'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTotalMetric('Total Gas Saved', '${total['gas']!.toStringAsFixed(2)} therms'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTotalMetric('Total Energy Saved', '${total['energy']!.toStringAsFixed(1)} kWh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.eco, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total CO₂ Avoided: ${total['co2']!.toStringAsFixed(2)} kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green[700], size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Equivalent to planting 0.2 trees or 38 km of driving avoided!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
