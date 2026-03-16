import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/service/local_store.dart';
import '../../data/service/customer_session_helper.dart';
import '../../data/service/network_caller.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();

  String? _customerId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  /// 🔹 Load valid customer ID from central session
  Future<void> _loadCustomerId() async {
    final cid = await CustomerSessionHelper.getValidCustomerId();
    setState(() => _customerId = cid);
  }

  /// 🔹 Save Preferences (as JSON)
  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('preferences');
    if (cid == null) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Correct: CleanCloud expects "customerID"
      final response = await NetworkCaller.postRequest(
        url: "https://cleancloudapp.com/api/addMessage",
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": cid,
          "message": _notesController.text.trim(),
        },
      );

      setState(() => _isLoading = false);

      if (response.isSuccess && (response.body?['Success'] == 'True')) {
        _notesController.clear();
        Get.snackbar(
          '✅ Success',
          'Your message was saved successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await LocalStore.instance.saveApiResponse(response.body ?? {});
      } else {
        Get.snackbar(
          '❌ Failed',
          response.body?['Error'] ??
              response.errorMessage ??
              'Unable to save note.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer Notes & Instructions',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "These notes will be automatically included in all your future orders. Add delivery instructions, preferences, or other important details.",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Your notes (delivery instructions, etc.)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Example: Please leave packages at the side door.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePreferences,
                icon: _isLoading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(_isLoading ? 'Saving...' : 'Save Preferences'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
