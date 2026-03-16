import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../data/service/network_caller.dart';
import '../data/service/utils.dart';

/// Dialog to pay for Dream Big Plan ($69). Pops with true on payment success.
class DreamBigPaymentDialog extends StatefulWidget {
  final String customerId;
  final double amount;

  const DreamBigPaymentDialog({
    super.key,
    required this.customerId,
    required this.amount,
  });

  static Future<bool?> show(BuildContext context, {required String customerId, required double amount}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DreamBigPaymentDialog(customerId: customerId, amount: amount),
    );
  }

  @override
  State<DreamBigPaymentDialog> createState() => _DreamBigPaymentDialogState();
}

class _DreamBigPaymentDialogState extends State<DreamBigPaymentDialog> {
  bool _isProcessing = false;
  CardFieldInputDetails? _cardFieldDetails;

  Future<void> _handlePayment() async {
    if (_cardFieldDetails == null || !_cardFieldDetails!.complete) {
      Get.snackbar(
        'Error',
        'Please enter complete card details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final amountInCents = (widget.amount * 100).toInt();
      final response = await NetworkCaller.postRequest(
        url: Urls.StripePayment,
        body: {
          'amount': amountInCents,
          'customerID': int.tryParse(widget.customerId) ?? 0,
        },
      );
      if (!response.isSuccess || response.body == null) {
        throw Exception(response.errorMessage ?? 'Failed to create payment intent');
      }
      final clientSecret = response.body!['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Client secret not found');
      }
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      final status = paymentIntent.status.toString().toLowerCase();
      if (status.contains('succeeded')) {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      if (status.contains('requiresaction') || status.contains('requires_action')) {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      if (status.contains('requirespaymentmethod') || status.contains('requires_payment_method')) {
        throw Exception('Payment failed. Please try a different payment method.');
      }
      throw Exception('Payment status: $status');
    } on StripeException catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.error.message?.isNotEmpty == true ? e.error.message! : 'Payment failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(AppSizes.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dream Big Plan',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                '\$${widget.amount.toStringAsFixed(2)} — 1 month',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSizes.lg),
              Container(
                padding: EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.credit_card, color: AppColors.primary, size: AppSizes.iconMd),
                        SizedBox(width: AppSizes.sm),
                        Text(
                          'Card Details',
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.lg),
                    CardField(
                      onCardChanged: (details) => setState(() => _cardFieldDetails = details),
                      enablePostalCode: false,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Secured by Stripe', style: TextStyle(fontSize: AppSizes.fontSm, color: Colors.grey)),
                ],
              ),
              SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isProcessing || _cardFieldDetails == null || !_cardFieldDetails!.complete)
                          ? null
                          : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Pay \$${widget.amount.toStringAsFixed(2)}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
