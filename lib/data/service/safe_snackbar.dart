import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows a snackbar using ScaffoldMessenger so it never throws "No Overlay widget found".
/// Does NOT use Get.snackbar. Falls back to debugPrint when no valid context exists.
class SafeSnackbar {
  SafeSnackbar._();

  static void show(String title, String message, {bool isError = true}) {
    BuildContext? context = Get.context;
    String? contextSource;
    if (context != null) {
      contextSource = 'Get.context';
    } else {
      context = Get.key?.currentContext;
      if (context != null) {
        contextSource = 'Get.key.currentContext';
      }
    }

    if (context == null) {
      debugPrint('[SafeSnackbar] no valid context found, printing only');
      debugPrint('[SafeSnackbar] $title: $message');
      return;
    }

    debugPrint('[SafeSnackbar] using $contextSource');

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('[SafeSnackbar] no valid context found, printing only (no Scaffold in tree)');
      debugPrint('[SafeSnackbar] $title: $message');
      return;
    }

    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('[SafeSnackbar] failed to show snackbar: $e');
      debugPrint('[SafeSnackbar] $title: $message');
    }
  }
}
