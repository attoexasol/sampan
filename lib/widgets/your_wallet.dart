import 'package:flutter/material.dart';
import 'package:sampan/data/models/referral_response_model.dart';
import 'package:sampan/data/service/customer_session_helper.dart';
import 'package:sampan/data/service/referral_service.dart';

class YourWalletWidget extends StatefulWidget {
  const YourWalletWidget({super.key});

  static double walletBalance = 0.0;

  // ✅ Function to update wallet & show alert
  static void addReward(BuildContext context, double reward) {
    walletBalance += reward;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🎁 Congratulations!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You earned \$${reward.toStringAsFixed(2)}!"),
            const SizedBox(height: 10),
            Text("Your total wallet balance is now \$${walletBalance.toStringAsFixed(2)}."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  State<YourWalletWidget> createState() => _YourWalletWidgetState();
}

class _YourWalletWidgetState extends State<YourWalletWidget> {
  bool _loading = true;
  bool _loadFailed = false;
  ReferralResponseModel? _referral;

  @override
  void initState() {
    super.initState();
    _loadReferralAmount();
  }

  Future<void> _loadReferralAmount() async {
    final customerId = await CustomerSessionHelper.getValidCustomerId();
    if (customerId == null || customerId.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
      return;
    }

    final model = await ReferralService.fetchReferral(customerId);
    if (!mounted) return;
    setState(() {
      _referral = model;
      _loading = false;
      _loadFailed = model == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Wallet")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "Unable to load wallet amount",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _loadFailed = false;
                            });
                            _loadReferralAmount();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Referral Reward Amount",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _referral != null && _referral!.isSuccess
                                    ? _referral!.existingCustomerRewardText
                                    : r"$0.00",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Current referral reward configured for your account",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
