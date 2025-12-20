import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/service/local_store.dart';
import '../../data/service/network_caller.dart';

class PaymentMethodsDialog extends StatefulWidget {
  const PaymentMethodsDialog({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsDialog> createState() => _PaymentMethodsDialogState();
}

class _PaymentMethodsDialogState extends State<PaymentMethodsDialog> {
  // UI state
  bool _isLoading = false;
  bool _addingNew = false;

  // Data
  String? _customerId;
  List<Map<String, dynamic>> _payments = [];

  // Form controllers
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController(); // MM/YY
  final cvvController = TextEditingController();

  // CleanCloud token (keep in one place)
  static const String _apiToken = "af547bb45f372a7b1171ba7a304fcd84ab319852";

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    // 1) load saved customer id
    final cid = await LocalStore.instance.getCustomerId();
    setState(() => _customerId = cid);

    // 2) load locally saved payments first (instant UI)
    final local = await LocalStore.instance.getPaymentMethods();
    setState(() => _payments = local);

    // 3) then fetch from server (if cid exists) and persist
    if (cid != null && cid.isNotEmpty) {
      await _fetchPayments();
    }
  }

  /// Fetch payment methods from CleanCloud and save to SharedPrefs
  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);

    final res = await NetworkCaller.postRequest(
      url: "https://cleancloudapp.com/api/getPayments",
      body: {
        "api_token": _apiToken,
        "customerID": _customerId,
      },
    );

    setState(() => _isLoading = false);

    if (res.isSuccess && res.body != null) {
      // API shape: { totalOrdersAmount, totalInvoicesAmount, payments: [] }
      final list = (res.body!['payments'] as List? ?? [])
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Normalize (in case API returns different field names)
      final normalized = list.map((p) {
        final last4 = (p['last4'] ?? p['cardLast4'] ?? '').toString();
        final type = (p['type'] ?? p['brand'] ?? 'Card').toString();
        final expMonth = (p['expMonth'] ?? p['expiryMonth'] ?? '').toString();
        final expYear = (p['expYear'] ?? p['expiryYear'] ?? '').toString();
        final expiry = (p['expiry'] ??
            ((expMonth.isNotEmpty && expYear.isNotEmpty)
                ? '$expMonth/$expYear'
                : ''))
            .toString();
        final def = (p['isDefault'] ?? p['default'] ?? false) == true;

        return {
          "type": type,
          "last4": last4,
          "expiry": expiry,
          "isDefault": def,
        };
      }).toList();

      setState(() => _payments = normalized);
      await LocalStore.instance.savePaymentMethods(normalized); // ✅ persist
    } else {
      Get.snackbar('Error', res.errorMessage ?? 'Failed to fetch payments',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Add new card locally & persist (replace with real tokenization later)
  Future<void> _addNewPayment() async {
    final number = cardNumberController.text.trim().replaceAll(' ', '');
    final expiry = expiryController.text.trim(); // MM/YY
    final cvv = cvvController.text.trim();

    if (number.isEmpty || expiry.isEmpty || cvv.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (number.length < 12) {
      Get.snackbar('Error', 'Enter a valid card number',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    // 👉 If CleanCloud had an "addPayment" endpoint, call it here.
    // For now we simulate success locally (many gateways require tokenization).
    await Future.delayed(const Duration(milliseconds: 600));

    final last4 = number.substring(number.length - 4);
    final newItem = {
      "type": "Visa", // you can detect brand from number if you want
      "last4": last4,
      "expiry": expiry,
      "isDefault": _payments.isEmpty, // first card default
    };

    // Update UI immediately
    setState(() {
      _payments.add(newItem);
      _addingNew = false;
      _isLoading = false;
    });

    // ✅ Persist to SharedPreferences so it survives app restarts
    await LocalStore.instance.appendPaymentMethod(newItem);

    // ✅ Clear form fields
    cardNumberController.clear();
    expiryController.clear();
    cvvController.clear();

    Get.snackbar('✅ Success', 'Payment method added',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  // ---------------- UI builders ----------------

  Widget _buildHeader() => const Text('Payment Methods');

  Widget _buildBody() {
    if (_isLoading && _payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_addingNew) return _buildAddCardForm();

    if (_payments.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No saved payment methods yet.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => _addingNew = true),
            icon: const Icon(Icons.add),
            label: const Text('Add New Payment Method'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._payments.map(_buildPaymentTile),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => setState(() => _addingNew = true),
          icon: const Icon(Icons.add),
          label: const Text('Add New Payment Method'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p['type']} •••• ${p['last4']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if ((p['expiry'] ?? '').toString().isNotEmpty)
                  Text('Expires ${p['expiry']}',
                      style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (p['isDefault'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Default',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Add Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _addingNew = false),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _addNewPayment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildHeader(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: SingleChildScrollView(child: _buildBody()),
      actions: [
        if (!_addingNew)
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }
}
