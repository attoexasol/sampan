import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/constants/sizes.dart';
import 'package:sampan/widgets/OrderHistoryCard.dart';
import 'package:sampan/widgets/header_widget.dart';
import 'package:sampan/widgets/helpsupport.dart';
import 'package:sampan/widgets/invitefriends.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/profile_controller.dart';
import '../widgets/DeliveryAddressDialog.dart';
import '../widgets/GiftCardDialog.dart';
import '../widgets/delete_acc.dart';
import '../widgets/faq_dialog.dart';
import '../widgets/feature_card.dart';
import '../widgets/invite_friends.dart';
import '../widgets/payment_information.dart';
import '../widgets/policy_dialog.dart';
import '../widgets/preferences.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/your_wallet.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  static const bool kPublishedAndroid = false;
  static const bool kPublishedIOS = false;

  static const String kAndroidPackageId = 'com.yourcompany.yourapp'; // change later
  static const String kAppleAppId = '1234567890';


  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ProfileController controller = Get.put(ProfileController());

                    // change later
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔹 User Profile Card


    EnvironmentalImpactCard(),

                    SizedBox(height: AppSizes.sm),
                    Container(
                        width: AppSizes.screenWidth*.95,
                        child: OrderHistoryCard(onTap: (){})),
                    SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        FeatureCard(
                          icon: Icons.phone_outlined,
                          label: 'Contact Store',
                          onTap: callStore,
                        ),
                        FeatureCard(
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp Us',
                          onTap: openWhatsApp,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        FeatureCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Your Wallet',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const YourWalletWidget()),
                            );
                          },
                        ),
                        FeatureCard(
                          icon: Icons.card_giftcard,
                          label: 'Buy Gift Card',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => const GiftCardDialog(),
                            );
                          },
                        ),

                      ],
                    ),

                    SizedBox(height: AppSizes.sm),
                    SizedBox(
                      width: AppSizes.screenWidth*.95,
                        child: InviteFriendsCard(onTap: () => InviteFriendsWidget.showInviteDialog(context),)),

                    _buildSectionTitle('Settings'),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.credit_card_outlined,
                            label: 'Payment Methods',
                            onTap: () => Get.dialog(const PaymentMethodsDialog()),
                          ),

                          _buildDivider(),

                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            label: 'Delivery Address',
                            onTap: () => Get.dialog(const DeliveryAddressDialog()),
                          ),

                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            label: 'Your Preferences',
                            onTap: () {
                              Get.to(() => const PreferencesScreen());
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.lg),

                    SizedBox(height: AppSizes.lg),

                    _buildSectionTitle('Connect With Us'),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            label: 'FAQs',
                            onTap: () async {
                              // Optional but helpful: keep UI clean before opening
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              FocusScope.of(context).unfocus();
                              print("showFaqDialog called");
                              await showFaqDialog(context);     // 👈 now shows reliably
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.description_outlined,
                            label: 'Policy of the Application',
                            onTap: () async {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              FocusScope.of(context).unfocus();
                              await showPolicyDialog(context, effectiveDate: "October 30, 2025"); // optional
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.star_outline,
                            label: 'Rate Our App',
                            onTap: () => openStoreRating(context),

                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.lg),

                    _buildCard(
                      child: Column(
                        children: [

                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            label: 'Delete Account',
                            onTap: () => DeleteAccountDialog.show(context),
                            isDanger: true,
                          ),

                          _buildDivider(),
                          InkWell(
                            onTap: controller.logout,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.md),
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: AppSizes.iconMd),
                                  SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppSizes.fontLg,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.xl * 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Standard Card Wrapper
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.sm),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  // 🔹 Clickable Card (Order History, Invite Friends)
  Widget _buildClickableCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _buildCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconMd),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontLg,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Menu Item Row
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconMd,
              color: isDanger ? Colors.red : AppColors.foreground,
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppSizes.fontLg,
                  color: isDanger ? Colors.red : AppColors.foreground,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }

  // 🔹 Divider with consistent padding
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Divider(
        height: 1,
        color: AppColors.border,
      ),
    );
  }

  Future<void> openStoreRating(BuildContext context) async {
    if ((Platform.isAndroid && !AccountScreen.kPublishedAndroid) ||
        (Platform.isIOS && !AccountScreen.kPublishedIOS)) {
      _showNotPublishedDialog(context);
      return;
    }

    if (Platform.isAndroid) {
      final marketUri = Uri.parse('market://details?id=${AccountScreen.kAndroidPackageId}');
      final webUri   = Uri.parse('https://play.google.com/store/apps/details?id=${AccountScreen.kAndroidPackageId}');
      final ok = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      if (!ok) await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (Platform.isIOS) {
      final iosUri = Uri.parse('itms-apps://itunes.apple.com/app/id${AccountScreen.kAppleAppId}?action=write-review');
      final ok = await launchUrl(iosUri, mode: LaunchMode.externalApplication);
      if (!ok) {
        final httpsUri = Uri.parse('https://apps.apple.com/app/id${AccountScreen.kAppleAppId}?action=write-review');
        await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
      }
    }
  }


  void _showNotPublishedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Ratings not available yet'),
        content: const Text(
            "We haven’t launched on the store yet. "
                "You’ll be able to rate us once we’re live.\n\n"
                "Meanwhile, you can send feedback directly—this really helps!"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              final mail = Uri.parse(
                'mailto:support@yourcompany.com?subject=App%20Feedback&body=Hi%20team,%20here%20is%20my%20feedback...',
              );
              await launchUrl(mail);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }

  void openWhatsApp() async {
    final phone = "+12503044766";
    final message = Uri.encodeComponent("Hello! I want to contact you.");
    final whatsappUrl = Uri.parse("https://wa.me/$phone?text=$message");

    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> callStore() async {
    final phoneNumber = "tel:+12503044766";
    final uri = Uri.parse(phoneNumber);
    if (!await launchUrl(uri)) {
      throw "Could not launch $phoneNumber";
    }
  }
}
