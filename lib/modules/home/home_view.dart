import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/book_tab.dart';
import 'widgets/orders_tab.dart';
import 'widgets/account_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentTab.value,
        children: const [
          BookTab(),
          OrdersTab(),
          AccountTab(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTab.value,
        onTap: controller.changeTab,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Book',),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      )),
    );
  }
}
