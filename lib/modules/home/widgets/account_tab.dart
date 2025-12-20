import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class AccountTab extends GetView<HomeController> {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Text(
                      'SM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sarath Mantravadi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('sarathmantravadi@gmail.com'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuItem(
            context,
            'Payment Methods',
            Icons.credit_card,
                () {},
          ),
          _buildMenuItem(
            context,
            'Manage Addresses',
            Icons.location_on,
                () {},
          ),
          _buildMenuItem(
            context,
            'Preferences',
            Icons.settings,
                () {},
          ),
          _buildMenuItem(
            context,
            'Contact Support',
            Icons.help,
                () {},
          ),
          const SizedBox(height: 24),
          _buildMenuItem(
            context,
            'Logout',
            Icons.logout,
                () => Get.offAllNamed('/login'),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
