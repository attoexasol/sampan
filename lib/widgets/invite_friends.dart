import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sampan/widgets/your_wallet.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsWidget {
  static String referralCode = "EARNU15";
  static String referralLink =
      "https://play.google.com/store/apps/details?id=com.sampan.app?ref=$referralCode";
  static String shareText =
      "🎉 Join Sampan and earn \$15! Use my referral link: $referralLink";

  /// ✅ Show Invite Dialog (AlertDialog version)
  static void showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Invite Friends & Earn \$15",
                style: TextStyle(fontWeight: FontWeight.bold,),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Share Sampan with friends and you'll both get \$15 credit on your next order!",
              style: TextStyle(color: Colors.grey,),
            ),
            const SizedBox(height: 20),
            _inviteOption(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: "Share via WhatsApp",
              onTap: () => _shareViaWhatsApp(context),
            ),
            _inviteOption(
              icon: Icons.sms,
              title: "Text Message",
              subtitle: "Share via SMS",
              onTap: () => _shareViaSMS(context),
            ),
            _inviteOption(
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: "Share via Email",
              onTap: () => _shareViaEmail(context),
            ),
            _inviteOption(
              icon: Icons.link,
              title: "Copy Link",
              subtitle: "Copy referral message",
              onTap: () => _copyReferralLink(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _inviteOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  /// ✅ Share Methods + Reward Popup
  static Future<void> _shareViaWhatsApp(BuildContext context) async {
    final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(shareText)}");
    await launchUrl(url, mode: LaunchMode.externalApplication);
    Navigator.pop(context);
    YourWalletWidget.addReward(context, 15);
  }

  static Future<void> _shareViaSMS(BuildContext context) async {
    final url = Uri.parse("sms:?body=${Uri.encodeComponent(shareText)}");
    await launchUrl(url);
    Navigator.pop(context);
    YourWalletWidget.addReward(context, 15);
  }

  static Future<void> _shareViaEmail(BuildContext context) async {
    final url = Uri.parse("mailto:?subject=Join Sampan & Earn!&body=$shareText");
    await launchUrl(url);
    Navigator.pop(context);
    YourWalletWidget.addReward(context, 15);
  }

  static void _copyReferralLink(BuildContext context) {
    Fluttertoast.showToast(msg: "Referral link copied!");
    Navigator.pop(context);
    YourWalletWidget.addReward(context, 15);
  }
}
