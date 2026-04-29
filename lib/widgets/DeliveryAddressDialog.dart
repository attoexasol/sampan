import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/service/local_store.dart';
import '../../data/service/network_caller.dart';
import '../../data/service/customer_session_helper.dart';
import '../../data/service/safe_snackbar.dart';
import '../../data/service/utils.dart';
import '../constants/colors.dart';
import '../controller/profile_controller.dart';

class DeliveryAddressDialog extends StatefulWidget {
  const DeliveryAddressDialog({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressDialog> createState() => _DeliveryAddressDialogState();
}

class _DeliveryAddressDialogState extends State<DeliveryAddressDialog> {
  final _formKey = GlobalKey<FormState>();

  static const TextStyle _hintStyle = TextStyle(color: Colors.grey);

  // Controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  bool _isLoading = false;
  String? _customerId;

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

  /// Parse "Street, Unit, City, State ZIP" or "Street, City, State ZIP" into fields.
  void _parseAndPrefillAddress(String addressStr) {
    if (addressStr.trim().isEmpty) return;
    final parts = addressStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return;
    if (parts.length == 1) {
      _streetController.text = parts[0];
      return;
    }
    String street = parts[0];
    String unit = '';
    String city = '';
    String postal = '';
    final part1 = parts.length > 1 ? parts[1] : '';
    final isUnit = part1.toLowerCase().contains('apt') ||
        part1.toLowerCase().contains('unit') ||
        part1.contains('#');
    if (parts.length >= 4 && isUnit) {
      unit = part1;
      city = parts[2];
      final lastPart = parts[3];
      final zipMatch = RegExp(r'\b\d{5}(?:-\d{4})?\b').firstMatch(lastPart);
      postal = zipMatch != null ? lastPart.substring(zipMatch.start, zipMatch.end) : lastPart;
    } else if (parts.length >= 3) {
      city = parts.length >= 4 ? parts[2] : parts[1];
      final lastPart = parts.length >= 4 ? parts[3] : parts[2];
      final zipMatch = RegExp(r'\b\d{5}(?:-\d{4})?\b').firstMatch(lastPart);
      postal = zipMatch != null ? lastPart.substring(zipMatch.start, zipMatch.end) : lastPart;
      if (parts.length >= 4 && !isUnit) unit = parts[1];
    } else if (parts.length == 2) {
      city = parts[1];
    }
    _streetController.text = street;
    _unitController.text = unit;
    _cityController.text = city;
    _postalController.text = postal;
  }

  Future<void> _loadSavedAddress() async {
    final savedAddress = await LocalStore.instance.getCustomerAddress();
    final savedInstructions = await LocalStore.instance.getDeliveryInstructions();
    if (savedAddress != null && savedAddress.trim().isNotEmpty) {
      _parseAndPrefillAddress(savedAddress);
    } else {
      final saved = await LocalStore.instance.getSavedAddress();
      if (saved != null) {
        _streetController.text = saved['street'] ?? '';
        _unitController.text = saved['unit'] ?? '';
        _cityController.text = saved['city'] ?? '';
        _postalController.text = saved['postal'] ?? '';
      }
    }
    if (savedInstructions != null) _instructionsController.text = savedInstructions;
    else {
      final saved = await LocalStore.instance.getSavedAddress();
      if (saved != null && saved['instructions'] != null) {
        _instructionsController.text = saved['instructions'] ?? '';
      }
    }
    if (mounted) setState(() {});
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
    debugPrint('[DeliveryAddress] _saveAddress tapped');

    // Use the Form's own validators — shows inline "Required" inside the dialog.
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      debugPrint('[DeliveryAddress] Form validation failed — required fields empty');
      SafeSnackbar.show(
        'Missing fields',
        'Please fill in Street, City, and Postal Code.',
        isError: true,
      );
      return;
    }

    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final postal = _postalController.text.trim();

    final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('delivery-address');
    if (cid == null) {
      debugPrint('[DeliveryAddress] Aborting — no valid customerId');
      return;
    }
    final apiToken = await LocalStore.instance.getApiToken();
    if (apiToken == null || apiToken.isEmpty) {
      debugPrint('[DeliveryAddress] Aborting — no apiToken in LocalStore');
      SafeSnackbar.show(
        'Session expired',
        'Please sign in again.',
        isError: true,
      );
      return;
    }

    final unit = _unitController.text.trim();
    final customerAddress = unit.isEmpty
        ? '$street, $city, $postal'
        : '$street, $unit, $city, $postal';
    final instructions = _instructionsController.text.trim();

    setState(() => _isLoading = true);
    debugPrint('[DeliveryAddress] POST /updateCustomer body=customerAddress="$customerAddress"');

    // 1) POST /updateCustomer — persist concatenated customerAddress
    final response = await NetworkCaller.postRequest(
      url: Urls.updateCustomerAddress,
      body: {
        'api_token': apiToken,
        'customerID': cid,
        'customerAddress': customerAddress,
      },
    );

    final addressOk = response.isSuccess &&
        (response.body?['Success']?.toString().toLowerCase() == 'true');
    if (!addressOk) {
      setState(() => _isLoading = false);
      final errorMsg = response.body?['Error']?.toString() ??
          response.errorMessage ??
          'Address not accepted by server';
      debugPrint('[DeliveryAddress] /updateCustomer failed: $errorMsg');
      SafeSnackbar.show('Failed', errorMsg, isError: true);
      return;
    }

    // 2) POST /addMessage — send delivery instructions as a customer message.
    // Soft-fail: do not block the address save if this secondary call fails.
    bool instructionsOk = true;
    String? instructionsError;
    if (instructions.isNotEmpty) {
      debugPrint('[DeliveryAddress] POST /addMessage with instructions');
      final msgResponse = await NetworkCaller.postRequest(
        url: Urls.PreferencesMsg,
        body: {
          'api_token': apiToken,
          'customerID': cid,
          'message': instructions,
        },
      );
      instructionsOk = msgResponse.isSuccess &&
          (msgResponse.body?['Success']?.toString().toLowerCase() == 'true');
      if (!instructionsOk) {
        instructionsError = msgResponse.body?['Error']?.toString() ??
            msgResponse.errorMessage ??
            'Could not save delivery instructions';
        debugPrint('[DeliveryAddress] /addMessage failed: $instructionsError');
      }
    }

    setState(() => _isLoading = false);

    await LocalStore.instance.saveSession(
      address: customerAddress,
      instructions: instructions,
    );
    await LocalStore.instance.saveAddress({
      'street': street,
      'unit': unit,
      'city': city,
      'postal': postal,
      'instructions': instructions,
      'fullAddress': customerAddress,
    });

    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().refreshProfile();
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    final successMsg = instructionsOk
        ? 'Delivery address saved successfully!'
        : 'Address saved, but instructions could not be sent: $instructionsError';
    SafeSnackbar.show(
      instructionsOk ? 'Success' : 'Partial Success',
      successMsg,
      isError: !instructionsOk,
    );
    debugPrint('[DeliveryAddress] Save complete (instructionsOk=$instructionsOk)');
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
                            hintStyle: _hintStyle,
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
                            hintStyle: _hintStyle,
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
                            hintStyle: _hintStyle,
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
                            hintStyle: _hintStyle,
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
                            hintStyle: _hintStyle,
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
