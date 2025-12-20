import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class OrdersTab extends GetView<HomeController> {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Demo orders
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text('#${index + 1}'),
              ),
              title: Text('Order #100${index + 1}'),
              subtitle: const Text('Status: In Progress'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to order details
              },
            ),
          );
        },
      ),
    );
  }
}
