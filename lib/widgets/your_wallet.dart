import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Wallet")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("💵 Current Balance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              "\$${YourWalletWidget.walletBalance.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 36, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
