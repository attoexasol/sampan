import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/service/local_store.dart';
import '../../data/service/network_caller.dart';
import '../constants/colors.dart';

class DeliveryAddressDialog extends StatefulWidget {
  const DeliveryAddressDialog({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressDialog> createState() => _DeliveryAddressDialogState();
}

class _DeliveryAddressDialogState extends State<DeliveryAddressDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

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
      _streetController.text = saved['street'] ?? '';
      _unitController.text = saved['unit'] ?? '';
      _cityController.text = saved['city'] ?? '';
      _postalController.text = saved['postal'] ?? '';
      _instructionsController.text = saved['instructions'] ?? '';
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
        'street': _streetController.text.trim(),
        'unit': _unitController.text.trim(),
        'city': _cityController.text.trim(),
        'postal': _postalController.text.trim(),
        'instructions': _instructionsController.text.trim(),
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title, subtitle, and close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update where we should pick up and deliver your laundry.',
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

            // Form content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Street Address
                        TextFormField(
                          controller: _streetController,
                          decoration: InputDecoration(
                            labelText: 'Street Address',
                            hintText: '123 Main Street',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Unit / Apt (Optional)
                        TextFormField(
                          controller: _unitController,
                          decoration: InputDecoration(
                            labelText: 'Unit / Apt (Optional)',
                            hintText: 'Apt 4B',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // City
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            hintText: 'Vancouver',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Postal Code
                        TextFormField(
                          controller: _postalController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code',
                            hintText: 'V5N 4P5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Delivery Instructions (Optional)
                        TextFormField(
                          controller: _instructionsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Delivery Instructions (Optional)',
                            hintText: 'e.g., Leave at front door, ring doorbell',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action buttons
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
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.foreground,
                        side: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Address button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Teal
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _unitController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
