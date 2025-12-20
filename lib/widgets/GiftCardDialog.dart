import 'package:flutter/material.dart';

class GiftCardDialog extends StatefulWidget {
  const GiftCardDialog({Key? key}) : super(key: key);

  @override
  State<GiftCardDialog> createState() => _GiftCardDialogState();
}

class _GiftCardDialogState extends State<GiftCardDialog> {
  final TextEditingController customAmountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  double? selectedAmount = 50;
  final List<double> presetAmounts = [25, 50, 100, 150];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Send a Gift Card",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Give the gift of clean laundry! Our gift cards can be used for any of our services - laundry, dry cleaning, alterations, and more.",
              style: TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),

            const Text("Select Amount",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: presetAmounts.map((amount) {
                final isSelected = selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAmount = amount;
                      customAmountController.clear();
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? const Color(0xFFE9F9F2) : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4ED6A1)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      "\$${amount.toInt()}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2E7D5A)
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "\$ ",
                labelText: "Custom Amount",
                hintText: "Enter amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    selectedAmount = double.tryParse(value);
                  }
                });
              },
            ),

            const SizedBox(height: 20),
            const Text("Recipient Details",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter recipient’s name",
                labelText: "Recipient’s Name",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter recipient’s email",
                labelText: "Recipient’s Email",
                helperText:
                "The gift card will be sent to this email address",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Personal Message (Optional)",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLength: 250,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add a personal message for the recipient...",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Gift Card Amount",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        "\$${selectedAmount?.toStringAsFixed(0) ?? '0'}",
                        style: const TextStyle(
                          color: Color(0xFF2E7D5A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Never expires\n• Can be used for all services\n• Delivered instantly via email",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ED6A1),
                    ),
                    onPressed: () {
                      // Add your API/payment logic here
                    },
                    child: const Text("Continue to Payment",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
