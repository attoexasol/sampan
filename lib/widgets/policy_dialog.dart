// widgets/policy_dialog.dart
import 'package:flutter/material.dart';

class TermsPrivacyDialog extends StatelessWidget {
  const TermsPrivacyDialog({super.key, this.effectiveDate});

  /// e.g. "October 30, 2025". If null, shows placeholder.
  final String? effectiveDate;

  @override
  Widget build(BuildContext context) {
    // Same palette as your FAQ dialog
    const primary = Color(0xFF10B981);
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
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Terms of Service & Privacy Policy',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: text),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment:Alignment.center, child: _muted('Mantravadi Services Inc., doing business as Sampan Laundry & Dry Cleaning"}', muted)),
                const SizedBox(height: 8),
                _muted('Effective Date: ${effectiveDate ?? "[Month Day, Year]"}', muted),
                const SizedBox(height: 12),

                _h1('1. Introduction', primary),
                _p(
                    "This document governs your relationship with Mantravadi Services Inc., "
                        "doing business as Sampan Laundry & Dry Cleaning (“Sampan”, “we”, “our”, or “us”). "
                        "By using our app, website, or in-store services (collectively, the “Services”), "
                        "you agree to these Terms of Service and our Privacy Policy."
                ),
                _bullets([
                  "Self-service laundry facilities",
                  "Wash-and-fold, dry-cleaning, and garment care services",
                  "Pickup and delivery within designated service areas",
                  "Related web/app tools for ordering, payments, and scheduling",
                ]),

                _divider(border),

                _h1('2. Contact and Business Information', primary),
                _kv("Legal Entity", "Mantravadi Services Inc."),
                _kv("Operating Name", "Sampan Laundry & Dry Cleaning"),
                _kv("Business Address", "4866 Victoria Dr, Vancouver, BC V5N 4P5"),
                _kv("Email (Support)", "sampanservices@gmail.com"),
                _kv("Email (Claims & Privacy)", "sarath@sampanlaundry.com"),
                _kv("Phone", "(250) 304-4766"),
                _kv("GST/HST Number", "787618735 RT0001"),
                _kv("Open Hours", "Mon–Fri 9:30 AM – 10:00 PM; Sat & Sun 9:30 AM – 7:00 PM"),

                _divider(border),

                _h1('3. Scope of Services', primary),
                _p("We provide laundry, wash-and-fold, dry-cleaning, alterations, and pickup/delivery services within selected postal codes in British Columbia."),
                _p("All work is performed using commercially reasonable skill and care, following industry standards and garment care labels where available."),

                _divider(border),

                _h1('4. Orders, Payments, and Taxes', primary),
                _kv("Payments", "All payments are processed through Stripe or equivalent PCI-compliant processors."),
                _kv("Pricing", "Shown in Canadian dollars; may vary by weight, service type, or fabric condition."),
                _kv("Taxes", "Laundry and dry-cleaning services are exempt from BC PST; subject to 5% GST."),
                _kv("Refunds", "All sales are final. Refunds are not offered."),
                _kv("Missed Pickup Fee", "A ${10} fee applies if the driver cannot access your location or collect laundry."),
                _kv("Authorization", "By submitting an order, you authorize charges for applicable service, delivery, and incidental fees."),

                _divider(border),

                _h1('5. Handling and Risk Disclaimers', primary),
                _h2('5.1 Standard of Care'),
                _p("We follow garment labels and recognized methods. Where labels are missing/unclear, we apply professional judgment but cannot guarantee results."),
                _h2('5.2 Customer Responsibility'),
                _bullets([
                  "Empty all pockets (pens, coins, batteries, jewelry, etc.)",
                  "Separate delicate/special-care items and label them clearly",
                  "Provide accurate pickup/delivery instructions",
                ]),
                _h2('5.3 Risks and Exclusions'),
                _bullets([
                  "Color fading, bleeding, or shrinkage inherent to normal cleaning",
                  "Weak fabrics, loose dye, worn stitching, or invisible defects",
                  "Items without/with contradictory care labels",
                  "Loss/damage caused by foreign objects left in garments",
                  "Allergic reactions to detergents or cleaning agents",
                ]),

                _divider(border),

                _h1('6. Limitation of Liability', primary),
                _p("Our maximum liability for any lost or damaged item is limited to the processing charge paid for that item."),
                _p("We do not cover consequential or incidental damages (missed flights, events, loss of income, emotional distress) or damage from defects, wear, or user negligence."),

                _divider(border),

                _h1('7. Claims and Dispute Procedure', primary),
                _kv("Claim Window", "Report missing or damaged items within 24 hours of pickup/delivery completion to sarath@sampanlaundry.com."),
                _kv("Inspection", "We may request the item for review before deciding on a remedy."),
                _kv("Remedies", "If we are at fault, our sole obligation is to refund the cleaning charge for the affected item."),
                _kv("Abandoned Items", "Items unclaimed after 30 days may be considered abandoned and may be donated or recycled."),
                _kv("Lien Rights", "Under the Commercial Liens Act (SBC 2025, c.2), we may retain a lien over uncollected or unpaid items until charges are settled."),

                _divider(border),

                _h1('8. Self-Service Facilities', primary),
                _bullets([
                  "You operate machines at your own risk.",
                  "Sampan is not liable for misuse, overloading, or unattended items.",
                  "Follow posted safety and hygiene rules on-site.",
                ]),

                _divider(border),

                _h1('9. Privacy Policy (BC PIPA & Federal PIPEDA)', primary),
                _p("This section explains how we collect, use, and protect personal information in compliance with BC’s Personal Information Protection Act (PIPA) and Canada’s Personal Information Protection and Electronic Documents Act (PIPEDA)."),
                _h2('9.1 Information We Collect'),
                _bullets([
                  "Name, email, phone number, delivery addresses",
                  "Account/payment details via Stripe tokens (we do not store full card data)",
                  "Order history, service preferences, instructions/notes",
                  "Device and usage data (app diagnostics, IP, cookies)",
                  "CCTV footage (store security; typically retained 4 days)",
                ]),
                _h2('9.2 Purpose of Use'),
                _bullets([
                  "Processing and delivering orders",
                  "Communication and customer support",
                  "Service quality improvement",
                  "Legal, accounting, and security obligations",
                  "Marketing with consent (CASL compliant)",
                ]),
                _h2('9.3 Data Storage and Transfers'),
                _p("We use secure cloud providers. Some systems may store data outside Canada and be subject to lawful access by foreign authorities. Contracts with service providers require comparable protection standards."),
                _h2('9.4 Data Retention'),
                _bullets([
                  "Transaction records: up to 7 years (tax/audit)",
                  "Operational logs: up to 24 months",
                  "CCTV: ~4 days unless needed for investigation",
                  "Customer accounts: deleted upon verified request (subject to legal retention)",
                ]),
                _h2('9.5 Security Safeguards'),
                _p("We apply reasonable administrative, technical, and physical safeguards (e.g., encryption, access controls). No online system is entirely risk-free."),
                _h2('9.6 Access, Correction, and Consent'),
                _p("Under BC PIPA you may request access/correction to your personal information and withdraw marketing consent at any time. Contact: sarath@sampanlaundry.com."),
                _h2('9.7 Breach Reporting'),
                _p("If a breach poses a real risk of significant harm, we will notify the Office of the Privacy Commissioner of Canada (OPC) and affected individuals as required."),

                _divider(border),

                _h1('10. CASL Compliance (Electronic Messages)', primary),
                _p("We send marketing messages only with express or implied consent and include sender identification and an unsubscribe link."),

                _divider(border),

                _h1('11. Force Majeure', primary),
                _p("We are not liable for delays or non-performance caused by events beyond our reasonable control (e.g., natural disasters, utility failures, strikes, pandemics, or governmental restrictions)."),

                _divider(border),

                _h1('12. Dispute Resolution and Governing Law', primary),
                _p("These Terms are governed by the laws of British Columbia and Canada. Disputes may be heard in the Provincial Court (Small Claims) or Supreme Court of British Columbia, Vancouver Registry. Pre-dispute mandatory arbitration is excluded under BPCPA 2025 amendments."),

                _divider(border),

                _h1('13. Changes to These Terms and Policy', primary),
                _p("We may update these Terms or the Privacy Policy from time to time. Continued use of the Services constitutes acceptance of changes."),

                _divider(border),

                _h1('14. Interpretation and Severability', primary),
                _p("If any clause is held invalid, the remainder will continue in full force. Headings are for convenience and do not affect interpretation."),

                _divider(border),

                _h1('15. Contact for Legal or Privacy Matters', primary),
                _kv("Privacy Officer", "Mantravadi Services Inc. (Sampan Laundry & Dry Cleaning)"),
                _kv("Address", "4866 Victoria Dr, Vancouver, BC V5N 4P5"),
                _kv("Email", "sarath@sampanlaundry.com"),
                _kv("Phone", "(250) 304-4766"),
                _kv("Hours", "Mon–Fri 9:30 AM – 10:00 PM; Sat & Sun 9:30 AM – 7:00 PM"),

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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers (same style as your FAQ) ---
  static Widget _muted(String t, Color c) =>
      Text(t, style: TextStyle(color: c, fontSize: 13));

  static Widget _h1(String t, Color c) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(t, style: TextStyle(
        fontSize: 15.5, fontWeight: FontWeight.w700, color: c)),
  );

  static Widget _h2(String t) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 4),
    child: Text(t, style: const TextStyle(
        fontSize: 14.5, fontWeight: FontWeight.w700)),
  );

  static Widget _p(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 14, height: 1.45)),
  );

  static Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827), height: 1.45),
        children: [
          TextSpan(text: "$k: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: v),
        ],
      ),
    ),
  );

  static Widget _bullets(List<String> items) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 14, height: 1.45)),
            Expanded(child: Text(e, style: const TextStyle(fontSize: 14, height: 1.45))),
          ],
        ),
      )).toList(),
    ),
  );

  static Widget _divider(Color border) => Container(
    height: 1, margin: const EdgeInsets.symmetric(vertical: 10), color: border,
  );
}

/// Helper to show the dialog safely from anywhere (even with nested routers).
Future<void> showPolicyDialog(BuildContext context, {String? effectiveDate}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true, // important if you use nested navigators/shells
    barrierDismissible: true,
    builder: (_) => TermsPrivacyDialog(effectiveDate: effectiveDate),
  );
}
