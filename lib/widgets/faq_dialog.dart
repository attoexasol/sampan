// widgets/faq_dialog.dart
import 'package:flutter/material.dart';

class FaqDialog extends StatelessWidget {
  const FaqDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors you can tweak to match your theme
    const primary = Color(0xFF10B981); // teal/green
    const border  = Color(0xFFE5E7EB);
    const text    = Color(0xFF111827);
    const muted   = Color(0xFF6B7280);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _mutedLine("Everyday FAQs to help you understand our services.", muted),

                const SizedBox(height: 14),
                _sectionHeader("Services & Pricing", primary),

                _qa(
                  "What laundry services do you offer?",
                  "We offer Wash & Fold (everyday laundry), Dry Cleaning, Launder & Press "
                      "(shirts/pants), and specialty cleaning (bedding, blankets, duvets).",
                ),
                _qa(
                  "How do you charge?",
                  "Wash & Fold is priced per pound (e.g., 2.49/lb) with a minimum weight. "
                      "Dry Cleaning / Launder & Press are charged per item. Final pricing is shown "
                      "at checkout.",
                ),
                _qa(
                  "Do you offer dry cleaning?",
                  "Yes — shirts, dresses, suits, coats, and more.",
                ),
                _qa(
                  "What about alterations?",
                  "Basic repairs like buttons/hems/loose seams are available (fees apply).",
                ),
                _qa(
                  "Can you clean specialty items?",
                  "Yes — bedding/blankets/duvets/pillows/rugs (fees & processing time vary).",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Pickup & Delivery", primary),
                _qa(
                  "What are your pickup & delivery hours?",
                  "Mon–Fri: 8 AM–12 PM, 12–3 PM, 3–6 PM | Sat: 9 AM–1 PM | Sun: 12–3 PM.",
                ),
                _qa(
                  "What if I miss a scheduled pickup?",
                  "No worries — reschedule from the app (no fee if you update 2 hours before "
                      "the slot).",
                ),
                _qa(
                  "How quickly will I get my laundry back?",
                  "Standard next-business-day turnaround. Rush options may be available.",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Location & Hours", primary),
                _qa(
                  "Where are you located?",
                  "1234 Green Street, Vancouver, BC V6A 0A5",
                ),
                _qa(
                  "What are your store hours?",
                  "Monday–Friday: 7:30 AM – 7:00 PM\nSaturday & nSunday: 9:30 AM – 7:00 PM",
                ),
                _qa(
                  "Can I self-drop laundry at the store?",
                  "Yes — you can drop off during open hours. We’ll notify you when it’s ready.",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Payment & Policies", primary),
                _qa(
                  "What payment methods do you accept?",
                  "Credit/debit cards, Apple Pay, Google Pay. Orders are securely processed "
                      "through the app.",
                ),
                _qa(
                  "Do you charge before cleaning?",
                  "We pre-authorize your card and charge when the order is completed.",
                ),
                _qa(
                  "Is tipping available?",
                  "Optional at checkout. 100% of tips go to our team.",
                ),
                _qa(
                  "What’s your refund policy?",
                  "If there’s a service issue, please contact support within 24 hours of delivery. "
                      "We’ll make it right with re-clean or a credit where appropriate.",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Quality & Care", primary),
                _qa(
                  "How do you handle delicate items?",
                  "We follow garment labels. You can add care notes in the app — gentle wash, "
                      "hang dry, low heat, etc.",
                ),
                _qa(
                  "What about lost or damaged items?",
                  "We take great care, but if something happens, contact support within 24 hours. "
                      "Our team will investigate and resolve according to policy.",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Satisfaction", primary),
                _qa(
                  "Are you eco-friendly?",
                  "Yes — high-efficiency machines, eco-friendly detergents, and optimized routes to reduce emissions.",
                ),
                _qa(
                  "What detergent do you use?",
                  "Sensitive-skin, fragrance-free options available. You can choose in app.",
                ),

                const SizedBox(height: 12),
                _divider(border),

                _sectionHeader("Still Have Questions?", primary),
                _qa(
                  "We’re happy to help!",
                  "• Chat: Support in the app\n• 📧Email: support@sampanlaundry.com\n• ☎ Phone: (236) 555-3044",
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // small helpers
  static Widget _mutedLine(String text, Color muted) => Text(
    text,
    style: TextStyle(color: muted, fontSize: 13),
  );

  static Widget _sectionHeader(String title, Color primary) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 8),
    child: Text(
      title,
      style: TextStyle(
          fontSize: 15.5, fontWeight: FontWeight.w700, color: primary),
    ),
  );

  static Widget _qa(String question, String answer) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• $question",
            style: const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
      ],
    ),
  );

  static Widget _divider(Color border) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 10),
    color: border,
  );
}

/// Call this from anywhere, e.g. onTap of “FAQs”
Future<void> showFaqDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,          // 👈 force the app’s root navigator
    barrierDismissible: true,
    builder: (_) => const FaqDialog(),
  );
}

