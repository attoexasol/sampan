import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../../data/service/network_caller.dart';
import '../../data/service/local_store.dart';
import '../data/service/utils.dart';

class PaymentMethodDialog extends StatefulWidget {
  final double totalAmount;
  final String orderId;

  const PaymentMethodDialog({
    super.key,
    required this.totalAmount,
    required this.orderId,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    try {
      setState(() => _isProcessing = true);

      final customerId = await LocalStore.instance.getCustomerId();
      if (customerId == null) {
        Get.snackbar("Error", "Customer ID not found. Please login again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // 1️⃣ Create Payment Method via Stripe
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 2️⃣ Send card token to CleanCloud
      final addCardResponse = await NetworkCaller.postRequest(
        url: Urls.addCard,
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
          "type": 1, // 1 = Stripe
          "paymentMethodID": paymentMethod.id,
        },
      );

      if (!(addCardResponse.isSuccess &&
          (addCardResponse.body?["Success"] == "True"))) {
        throw Exception(addCardResponse.body?["Error"] ?? "Failed to add card");
      }

      // 3️⃣ Charge customer via CleanCloud
      final chargeResponse = await NetworkCaller.postRequest(
        url: Urls.chargeCard,
        body: {
          "api_token": "af547bb45f372a7b1171ba7a304fcd84ab319852",
          "customerID": customerId,
          "orderID": widget.orderId,
          "type": 1,
          "amount": widget.totalAmount.toString(),
          "currency": "usd",
        },
      );

      if (chargeResponse.isSuccess &&
          (chargeResponse.body?["Success"] == "True")) {
        Get.back();
        Get.snackbar("✅ Payment Successful", "Your order has been confirmed!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw Exception(
            chargeResponse.body?["Error"] ?? "Payment could not be processed");
      }
    } catch (e) {
      Get.snackbar("❌ Payment Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text("Payment Information"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Enter your card details below to complete your payment.",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          CardField(
            enablePostalCode: false,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _handlePayment,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isProcessing
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text("Pay Now"),
        ),
      ],
    );
  }
}
