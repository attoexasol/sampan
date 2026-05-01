import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global ScaffoldMessengerKey wired into GetMaterialApp.
///
/// Using this key (instead of `ScaffoldMessenger.of(context)` or
/// `Get.snackbar`) lets us reliably show snackbars during/after route
/// transitions like `Get.offAll`, where `Get.context` may transiently point
/// to a `_Theater` element and trigger "No Overlay widget found".
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Shows a snackbar using ScaffoldMessenger so it never throws "No Overlay widget found".
/// Does NOT use Get.snackbar. Falls back to debugPrint when no valid context exists.
class SafeSnackbar {
  SafeSnackbar._();

  static void show(String title, String message, {bool isError = true}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: isError ? Colors.red : Colors.green,
    );
  }

  /// Show a success snackbar (green).
  static void success(String message, {String? title}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  /// Show an error/failure snackbar (red).
  static void error(String message, {String? title}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void _showSnackBar({
    String? title,
    required String message,
    required Color backgroundColor,
  }) {
    final text = title == null ? message : '$title — $message';

    final SnackBar snack = SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    // Preferred: use the global key — it doesn't depend on a context being mounted.
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(snack);
      debugPrint('[SafeSnackbar] shown via rootScaffoldMessengerKey: $text');
      return;
    }

    // Fallback chain: nearest ScaffoldMessenger from the current Get context.
    final BuildContext? context = Get.context ?? Get.key?.currentContext;
    if (context != null) {
      final ctxMessenger = ScaffoldMessenger.maybeOf(context);
      if (ctxMessenger != null) {
        try {
          ctxMessenger
            ..clearSnackBars()
            ..showSnackBar(snack);
          debugPrint('[SafeSnackbar] shown via ScaffoldMessenger.maybeOf(context): $text');
          return;
        } catch (e) {
          debugPrint('[SafeSnackbar] context messenger failed: $e');
        }
      }
    }

    debugPrint('[SafeSnackbar] no valid messenger, printing only: $text');
  }
}
