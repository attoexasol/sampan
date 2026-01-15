import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';

class OrderHistoryDialog extends StatefulWidget {
  const OrderHistoryDialog({Key? key}) : super(key: key);

  @override
  State<OrderHistoryDialog> createState() => _OrderHistoryDialogState();
}

class _OrderHistoryDialogState extends State<OrderHistoryDialog> {
  // Track which orders are expanded
  final Set<String> _expandedOrders = {};

  // Mock order data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2024-003',
      'date': 'March 28, 2024',
      'status': 'Completed',
      'total': 156.75,
      'summary': {
        'laundry': {'lbs': 24, 'items': 0},
        'dryCleaning': {'items': 3},
        'steaming': {'items': 1},
        'alterations': {'items': 1},
        'shoeCare': {'pairs': 1},
      },
      'services': {
        'laundry': [
          {'name': 'Total Pounds Washed', 'value': '24 lbs', 'price': 54.00},
        ],
        'dryCleaning': [
          {'name': 'Essential Shirts x 2', 'price': 14.00},
          {'name': 'Two-Piece Suit x 1', 'price': 34.00},
        ],
        'steaming': [
          {'name': 'Casual Dress x 1', 'price': 8.00},
        ],
        'alterations': [
          {'name': 'Hem Pants x 1', 'price': 21.75},
        ],
        'shoeCare': [
          {'name': 'Shoe Renew Standard x 1', 'price': 30.00},
        ],
      },
      'environmental': {
        'water': 57.6,
        'detergent': 6.0,
        'gas': 0.48,
        'energy': 2.4,
        'co2': 3.26,
      },
    },
    {
      'id': 'ORD-2024-002',
      'date': 'March 21, 2024',
      'status': 'Completed',
      'total': 89.50,
      'summary': {
        'laundry': {'lbs': 20, 'items': 0},
        'dryCleaning': {'items': 3},
      },
      'services': {
        'laundry': [
          {'name': 'Total Pounds Washed', 'value': '20 lbs', 'price': 45.00},
        ],
        'dryCleaning': [
          {'name': 'Essential Shirts x 3', 'price': 21.00},
          {'name': 'Blazer x 1', 'price': 23.50},
        ],
      },
      'environmental': {
        'water': 48.0,
        'detergent': 5.0,
        'gas': 0.40,
        'energy': 2.0,
        'co2': 2.72,
      },
    },
    {
      'id': 'ORD-2024-001',
      'date': 'March 14, 2024',
      'status': 'Completed',
      'total': 127.25,
      'summary': {
        'laundry': {'lbs': 26, 'items': 0},
        'dryCleaning': {'items': 1},
        'steaming': {'items': 3},
        'alterations': {'items': 1},
      },
      'services': {
        'laundry': [
          {'name': 'Total Pounds Washed', 'value': '26 lbs', 'price': 58.50},
        ],
        'dryCleaning': [
          {'name': 'Wool Coat x 1', 'price': 42.00},
        ],
        'steaming': [
          {'name': 'Formal Dress x 1', 'price': 12.00},
          {'name': 'Blouse x 2', 'price': 10.00},
        ],
        'alterations': [
          {'name': 'Take In Jacket x 1', 'price': 5.75},
        ],
      },
      'environmental': {
        'water': 62.4,
        'detergent': 6.5,
        'gas': 0.52,
        'energy': 2.6,
        'co2': 3.54,
      },
    },
  ];

  // Calculate total environmental impact
  Map<String, double> get _totalEnvironmentalImpact {
    double totalWater = 0;
    double totalDetergent = 0;
    double totalGas = 0;
    double totalEnergy = 0;
    double totalCo2 = 0;

    for (var order in _orders) {
      final env = order['environmental'] as Map<String, dynamic>;
      totalWater += env['water'] as double;
      totalDetergent += env['detergent'] as double;
      totalGas += env['gas'] as double;
      totalEnergy += env['energy'] as double;
      totalCo2 += env['co2'] as double;
    }

    return {
      'water': totalWater,
      'detergent': totalDetergent,
      'gas': totalGas,
      'energy': totalEnergy,
      'co2': totalCo2,
    };
  }

  void _toggleOrder(String orderId) {
    setState(() {
      if (_expandedOrders.contains(orderId)) {
        _expandedOrders.remove(orderId);
      } else {
        _expandedOrders.add(orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalImpact = _totalEnvironmentalImpact;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Order Cards
                    ..._orders.map((order) => _buildOrderCard(order)),
                    const SizedBox(height: 20),

                    // Total Environmental Impact
                    _buildTotalEnvironmentalImpact(totalImpact),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final isExpanded = _expandedOrders.contains(orderId);
    final summary = order['summary'] as Map<String, dynamic>;
    final services = order['services'] as Map<String, dynamic>;
    final environmental = order['environmental'] as Map<String, dynamic>;

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
          // Order Summary (Always Visible)
          InkWell(
            onTap: () => _toggleOrder(orderId),
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
                          orderId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['date'] as String,
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
                          order['status'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(order['total'] as double).toStringAsFixed(2)}',
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

          // Summary Icons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (summary['laundry'] != null)
                  _buildSummaryIcon(Icons.local_laundry_service, '${summary['laundry']['lbs']} lbs'),
                if (summary['dryCleaning'] != null)
                  _buildSummaryIcon(Icons.dry_cleaning, '${summary['dryCleaning']['items']} items'),
                if (summary['steaming'] != null)
                  _buildSummaryIcon(Icons.air, '${summary['steaming']['items']} items'),
                if (summary['alterations'] != null)
                  _buildSummaryIcon(Icons.content_cut, '${summary['alterations']['items']} items'),
                if (summary['shoeCare'] != null)
                  _buildSummaryIcon(Icons.shopping_bag, '${summary['shoeCare']['pairs']} pairs'),
              ],
            ),
          ),

          // Expanded Content
          if (isExpanded) ...[
            Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services Breakdown
                  ..._buildServicesSection(services),
                  const SizedBox(height: 16),

                  // Environmental Contribution
                  _buildEnvironmentalContribution(environmental),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.snackbar(
                              'Receipt',
                              'Receipt for ${orderId}',
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                            );
                          },
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
                              'Reorder ${orderId}',
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
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

  List<Widget> _buildServicesSection(Map<String, dynamic> services) {
    final List<Widget> widgets = [];

    if (services['laundry'] != null) {
      widgets.add(_buildServiceCategory(
        'Laundry Services',
        Icons.local_laundry_service,
        services['laundry'] as List,
      ));
    }
    if (services['dryCleaning'] != null) {
      widgets.add(_buildServiceCategory(
        'Dry Cleaning',
        Icons.dry_cleaning,
        services['dryCleaning'] as List,
      ));
    }
    if (services['steaming'] != null) {
      widgets.add(_buildServiceCategory(
        'Steaming Services',
        Icons.air,
        services['steaming'] as List,
      ));
    }
    if (services['alterations'] != null) {
      widgets.add(_buildServiceCategory(
        'Alterations',
        Icons.content_cut,
        services['alterations'] as List,
      ));
    }
    if (services['shoeCare'] != null) {
      widgets.add(_buildServiceCategory(
        'Shoe Care',
        Icons.shopping_bag,
        services['shoeCare'] as List,
      ));
    }

    return widgets;
  }

  Widget _buildServiceCategory(String title, IconData icon, List<dynamic> items) {
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
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['value'] != null)
                      Flexible(
                        child: Text(
                          item['value'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalContribution(Map<String, dynamic> environmental) {
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
                  '${environmental['water'].toStringAsFixed(1)} gal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.cleaning_services,
                  const Color(0xFFEC4899),
                  'Detergent Saved',
                  '${environmental['detergent'].toStringAsFixed(1)} fl oz',
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
                  '${environmental['gas'].toStringAsFixed(2)} therms',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnvironmentalMetric(
                  Icons.bolt,
                  Colors.amber,
                  'Energy Saved',
                  '${environmental['energy'].toStringAsFixed(1)} kWh',
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
                    'CO₂ Avoided: ${environmental['co2'].toStringAsFixed(2)} kg',
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
