import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/service/local_store.dart';
import '../../data/service/network_caller.dart';

class DeliveryAddressDialog extends StatefulWidget {
  const DeliveryAddressDialog({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressDialog> createState() => _DeliveryAddressDialogState();
}

class _DeliveryAddressDialogState extends State<DeliveryAddressDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  bool _isLoading = false;
  String? _customerId;

  static const String _apiToken = "af547bb45f372a7b1171ba7a304fcd84ab319852";

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
    _loadSavedAddress();
  }

  Future<void> _loadCustomerId() async {
    final cid = await LocalStore.instance.getCustomerId();
    setState(() => _customerId = cid);
  }

  Future<void> _loadSavedAddress() async {
    final saved = await LocalStore.instance.getSavedAddress();
    if (saved != null) {
      _nameController.text = saved['name'] ?? '';
      _streetController.text = saved['street'] ?? '';
      _unitController.text = saved['unit'] ?? '';
      _cityController.text = saved['city'] ?? '';
      _postalController.text = saved['postal'] ?? '';
    }
  }

  String _composeAddress() {
    final parts = [
      _streetController.text.trim(),
      _unitController.text.trim(),
      _cityController.text.trim(),
      _postalController.text.trim(),
    ];
    return parts.where((e) => e.isNotEmpty).join(', ');
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (_customerId == null || _customerId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Customer ID not found — please login again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final fullAddress = _composeAddress();
    setState(() => _isLoading = true);

    final response = await NetworkCaller.postRequest(
      url: "https://cleancloudapp.com/api/getRoute",
      body: {
        "api_token": _apiToken,
        "customerAddress": fullAddress,
        "routeID": 1,
      },
    );

    setState(() => _isLoading = false);

    if (response.isSuccess && response.body?['Error'] == null) {
      await LocalStore.instance.saveAddress({
        'name': _nameController.text.trim(),
        'street': _streetController.text.trim(),
        'unit': _unitController.text.trim(),
        'city': _cityController.text.trim(),
        'postal': _postalController.text.trim(),
        'fullAddress': fullAddress,
      });

      Get.snackbar(
        '✅ Success',
        'Delivery address saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(); // close dialog only on success
    } else {
      // Keep dialog open — show red message
      final errorMsg = response.body?['Error'] ??
          response.errorMessage ??
          'Address not accepted by server';
      Get.snackbar(
        '❌ Failed',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Delivery Address',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update where we should pick up and deliver your laundry',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // Street
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: '123 Main Street',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // Unit / Apt
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit / Apt (Optional)',
                  hintText: 'Apt 4B',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // City + Postal
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Vancouver',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _postalController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        hintText: 'V5N 4P5',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Save Address'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _unitController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }
}
