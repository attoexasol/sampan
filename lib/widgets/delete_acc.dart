import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/service/customer_session_helper.dart';
import '../../data/service/local_store.dart';
import '../../data/service/network_caller.dart';
import '../../routes/app_routes.dart';
import '../../constants/colors.dart';
import 'delete_account_feedback_dialog.dart';

class DeleteAccountDialog {
  static Future<void> show(BuildContext context) async {
    // Show feedback dialog first
    final feedbackResult = await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountFeedbackDialog(),
    );

    // If user clicked "Keep My Account", just return
    if (feedbackResult == false || feedbackResult == null) {
      return;
    }

    // If user clicked "Continue", proceed with deletion confirmation
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Teal color for Cancel button
              ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final customerId = await CustomerSessionHelper.requireCustomerIdOrRedirect('delete-account');
      if (customerId == null) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await NetworkCaller.postRequest(
        url: "https://cleancloudapp.com/api/deleteCustomer",
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
        },
      );

      Get.back(); // close loading dialog

      if (response.isSuccess && (response.body?['Success'] == 'True')) {
        Get.snackbar(
          '✅ Account Deleted',
          'Your account has been permanently removed.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear all saved user data
        await LocalStore.instance.clearAll();
        Get.offAllNamed(Routes.LOGIN);
      } else {
        Get.snackbar(
          '❌ Failed',
          response.body?['Error'] ?? response.errorMessage ?? 'Delete failed.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
