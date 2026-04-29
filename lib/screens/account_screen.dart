import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/constants/sizes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/profile_controller.dart';
import '../data/service/customer_session_helper.dart';
import '../widgets/DeliveryAddressDialog.dart';
import '../widgets/GiftCardDialog.dart';
import '../widgets/delete_acc.dart';
import '../widgets/faq_dialog.dart';
import '../widgets/invite_friends.dart';
import '../widgets/payment_information.dart';
import '../widgets/policy_dialog.dart';
import '../widgets/preferences.dart';
import '../widgets/rate_experience_dialog.dart';
import '../widgets/sustainability_promise_dialog.dart';
import '../widgets/your_wallet.dart';
import '../screens/order_history_screen.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/signup/signup_binding.dart';
import '../modules/signup/signup_view.dart';

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
  final ProfileController controller = Get.find<ProfileController>();

                    // change later
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background pattern - Match React app-container
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background, // bg-background
                  image: const DecorationImage(
                  image: AssetImage('assets/images/laundry-background-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.none,
                  opacity: 0.06, // Match home_screen opacity
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
                  // Header - Match React: p-6, text-2xl, font-bold
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24), // p-6 = 24px
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24, // text-2xl = 24px
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),

              // Main Content - Match React: p-4, space-y-4
              Padding(
                padding: const EdgeInsets.all(16), // p-4 = 16px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Card
                    _buildProfileCard(),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Your Environmental Impact Card
                    _buildEnvironmentalImpactCard(),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Order History Card
                    _buildOrderHistoryCard(),

                    const SizedBox(height: 16), // space-y-4 = 16px
                    Obx(() {
                      if (controller.isLoggedIn.value) {
                        return const SizedBox.shrink();
                      }
                      return _buildAccountCard(
                        onLogin: () {
                          Get.to(
                            () => const LoginView(),
                            binding: LoginBinding(),
                          );
                        },
                        onCreateAccount: () {
                          Get.to(
                            () => const SignupView(),
                            binding: SignupBinding(),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    // Feature Cards (2x2 Grid)
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                          icon: Icons.phone_outlined,
                          label: 'Contact Store',
                          onTap: callStore,
                        ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp Us',
                            iconColor: const Color(0xFF25D366), // WhatsApp green
                          onTap: openWhatsApp,
                            isFontAwesome: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildFeatureCard(
                    //       icon: Icons.account_balance_wallet_outlined,
                    //       label: 'Your Wallet',
                    //       onTap: () async {
                    //         final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('your-wallet');
                    //         if (cid == null || !mounted) return;
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(builder: (_) => const YourWalletWidget()),
                    //         );
                    //       },
                    //     ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: _buildFeatureCard(
                    //       icon: Icons.card_giftcard,
                    //       label: 'Buy Gift Card',
                    //       onTap: () async {
                    //         final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('gift-card');
                    //         if (cid == null || !mounted) return;
                    //         showDialog(
                    //           context: context,
                    //           builder: (_) => const GiftCardDialog(),
                    //         );
                    //       },
                    //     ),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Invite Friends Card
                    _buildInviteFriendsCard(),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Settings Section
                    _buildSectionTitle('Settings'),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            label: 'Profile & Account',
                            onTap: () {
                              _showEditProfileDialog(context);
                            },
                          ),
                          _buildDivider(),
                          // _buildMenuItem(
                          //   icon: Icons.credit_card_outlined,
                          //   label: 'Payment Methods',
                          //   onTap: () async {
                          //     final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('payment-methods');
                          //     if (cid == null || !mounted) return;
                          //     Get.dialog(const PaymentMethodsDialog());
                          //   },
                          // ),
                          // _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            label: 'Delivery Address',
                            onTap: () async {
                              final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('delivery-address');
                              if (cid == null || !mounted) return;
                              Get.dialog(const DeliveryAddressDialog());
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            label: 'Your Preferences',
                            onTap: () async {
                              final cid = await CustomerSessionHelper.requireCustomerIdOrRedirect('preferences');
                              if (cid == null || !mounted) return;
                              Get.to(() => const PreferencesScreen());
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Help & Support Section
                    _buildSectionTitle('Help & Support'),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            label: 'FAQs',
                            onTap: () async {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              FocusScope.of(context).unfocus();
                              await showFaqDialog(context);
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.description_outlined,
                            label: 'Terms & Privacy',
                            onTap: () async {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              FocusScope.of(context).unfocus();
                              await showPolicyDialog(context, effectiveDate: "October 30, 2025");
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

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Log Out & Delete Account
                    _buildCard(
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.logout,
                            label: 'Log Out',
                            onTap: controller.logout,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            label: 'Delete Account',
                            onTap: () => DeleteAccountDialog.show(context),
                            isDanger: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16), // space-y-4 = 16px

                    // Our Sustainability Promise Card
                    _buildSustainabilityCard(),

                    SizedBox(height: AppSizes.xl * 2),
                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 User Profile Card - Match React: p-6, h-16 w-16 avatar, gap-4, text-xl
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24), // p-6 = 24px
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12), // rounded-lg = 0.75rem = 12px
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // shadow-sm
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
                              child: Row(
                                children: [
          // Avatar - Match React: h-16 w-16 = 64px (radius 32)
          CircleAvatar(
            radius: 32, // h-16 w-16 = 64px diameter = 32px radius
            backgroundColor: AppColors.primary,
            child: Obx(() {
              final displayName = controller.userName.value;
              final initials = displayName.isEmpty
                  ? 'U'
                  : displayName
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                      .take(2)
                      .join();
              final initialText = initials.isEmpty ? 'U' : initials;
              return Text(
                initialText,
                style: TextStyle(
                  color: AppColors.primaryForeground,
                  fontSize: 20, // text-xl = 20px
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
          const SizedBox(width: 16), // gap-4 = 16px
          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                      final nameText = controller.userName.value.trim().isNotEmpty
                          ? controller.userName.value.trim()
                          : 'User Name';
                      return Text(
                        nameText,
                        style: TextStyle(
                          fontSize: 20, // text-xl = 20px
                          fontWeight: FontWeight.w600, // font-semibold
                          color: AppColors.cardForeground,
                        ),
                      );
                    }),
                const SizedBox(height: 4),
                Obx(() {
                      final emailText = controller.userEmail.value.trim().isNotEmpty
                          ? controller.userEmail.value.trim()
                          : 'example@gmail.com';
                      return Text(
                        emailText,
                        style: TextStyle(
                          fontSize: 14, // text-sm = 14px
                          color: AppColors.mutedForeground,
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Order History Card - Navigate to full Order History screen (API)
  Widget _buildOrderHistoryCard() {
    return InkWell(
      onTap: () {
        Get.to(() => const OrderHistoryScreen());
      },
      borderRadius: BorderRadius.circular(12), // rounded-lg
      child: Container(
        padding: const EdgeInsets.all(24), // p-6 = 24px
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12), // rounded-lg = 12px
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // shadow-sm
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 20, // h-5 w-5 = 20px
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12), // gap-3 = 12px
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                  Text(
                    'Your Order History',
                                    style: TextStyle(
                      fontSize: 16, // font-semibold base size
                      fontWeight: FontWeight.w600, // font-semibold
                      color: AppColors.cardForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View past orders and receipts',
                    style: TextStyle(
                      fontSize: 14, // text-sm = 14px
                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
            Icon(
              Icons.chevron_right,
              size: 20, // h-5 w-5 = 20px
              color: AppColors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildAccountCard({
    required VoidCallback onLogin,
    required VoidCallback onCreateAccount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create an account or login to save your preferences and track your orders.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Invite Friends Card - Match React: p-6, h-5 w-5 icons, gap-3
  Widget _buildInviteFriendsCard() {
    return InkWell(
      onTap: () async {
        final customerId = await CustomerSessionHelper.requireCustomerIdOrRedirect('invite-friends');
        if (customerId == null) return;
        if (!mounted) return;
        InviteFriendsWidget.showInviteDialog(context, customerId: customerId);
      },
      borderRadius: BorderRadius.circular(12), // rounded-lg
      child: Container(
        padding: const EdgeInsets.all(24), // p-6 = 24px
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12), // rounded-lg = 12px
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // shadow-sm
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 20, // h-5 w-5 = 20px
              color: AppColors.primary,
            ),
            const SizedBox(width: 12), // gap-3 = 12px
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 16, // font-semibold base size
                      fontWeight: FontWeight.w600, // font-semibold
                      color: AppColors.cardForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share and earn rewards together',
                    style: TextStyle(
                      fontSize: 14, // text-sm = 14px
                      color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20, // h-5 w-5 = 20px
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Standard Card Wrapper - Match React: rounded-lg, shadow-sm, border
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // space-y-2 = 8px
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12), // rounded-lg = 0.75rem = 12px
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // shadow-sm
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // overflow-hidden
      child: child,
      ),
    );
  }

  // 🔹 Section Title - Match React: text-lg, font-semibold, px-2
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8, // px-2 = 8px
        vertical: 8, // space-y-2 = 8px
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, // text-lg = 18px
          fontWeight: FontWeight.w600, // font-semibold
          color: AppColors.foreground,
        ),
      ),
    );
  }

  // 🔹 Menu Item Row - Match React: p-4, h-5 w-5 icons, gap-3, font-medium
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16), // p-4 = 16px
          child: Row(
            children: [
              Icon(
                icon,
                size: 20, // h-5 w-5 = 20px
                color: isDanger ? AppColors.destructive : AppColors.foreground,
              ),
              const SizedBox(width: 12), // gap-3 = 12px
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500, // font-medium
                    fontSize: 16, // base font size
                    color: isDanger ? AppColors.destructive : AppColors.foreground,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20, // h-5 w-5 = 20px
                color: AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Divider - Match React: mx-4 separator
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // mx-4 = 16px
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border,
      ),
    );
  }

  // 🔹 Our Sustainability Promise Card
  Widget _buildSustainabilityCard() {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const SustainabilityPromiseDialog(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3), // Light green border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Header with globe icon and title
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLighter,
                  ),
                  child: const Icon(
                    Icons.public,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Our Sustainability Promise',
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subtitle with water drop icon
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'What It Means in Everyday Terms',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bullet points
            _buildSustainabilityBulletPoint('Each wash saves enough water for a 10-minute shower.'),
            const SizedBox(height: 8),
            _buildSustainabilityBulletPoint('The energy saved could charge your phone 100 times or light a bulb all night.'),
            const SizedBox(height: 8),
            _buildSustainabilityBulletPoint('Across our community, we\'ve kept thousands of liters of soap out of local streams.'),
            const SizedBox(height: 16),

            // Call to action
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Learn more about our impact',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSustainabilityBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                    Text(
          '• ',
                      style: TextStyle(
            fontSize: 14,
            color: AppColors.foreground,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground,
            ),
                      ),
                    ),
                  ],
    );
  }

  // 🔹 Your Environmental Impact Card
  Widget _buildEnvironmentalImpactCard() {
    return Container(
      padding: const EdgeInsets.all(24), // p-6 = 24px
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12), // rounded-lg = 12px
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // shadow-sm
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Environmental Impact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),

          // Initial call to action
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLighter,
                ),
                child: const Icon(
                  Icons.public,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Place your first order and we\'ll show your impact!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),

          // Impact metrics header
          Center(
            child: Text(
              'EVERY ORDER (MIN. 20 LBS) SAVES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Impact metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Water saving
              _buildImpactMetric(
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                text: '2 showers',
              ),
              // Detergent saving
              _buildImpactMetric(
                icon: Icons.cleaning_services,
                iconColor: const Color(0xFFEC4899), // Pink
                text: '1 soap bottle',
              ),
              // Emissions saving
              _buildImpactMetric(
                icon: Icons.directions_car,
                iconColor: Colors.red,
                text: '10 km drive',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.foreground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🔹 Feature Card - Square-ish card for Contact Store, WhatsApp, Wallet, Gift Card
  Widget _buildFeatureCard({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    bool isFontAwesome = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12), // rounded-lg
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // shadow-sm
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.circular(12),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
              isFontAwesome
                  ? FaIcon(
              icon,
                      color: iconColor ?? AppColors.primary,
                      size: 32, // Larger icon for feature cards
                    )
                  : Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 32, // Larger icon for feature cards
            ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.name.value);
    final emailCtrl = TextEditingController(text: controller.email.value);
    final phoneCtrl = TextEditingController(text: controller.phone.value);

    showDialog(
      context: context,
      builder: (dialogContext) => _ProfileEditDialog(
        nameController: nameCtrl,
        emailController: emailCtrl,
        phoneController: phoneCtrl,
        onSave: (name, email, phone) async {
          final ok = await controller.updateProfile(
            name,
            email,
            phone,
            showFeedback: false,
          );
          if (!context.mounted) return;
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (!ok) {
            messenger?.showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          messenger?.showSnackBar(
            const SnackBar(
              content: Text('Your profile information has been updated.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  Future<void> openStoreRating(BuildContext context) async {
    // Show Rate Your Experience dialog
    final rating = await showDialog<int>(
      context: context,
      builder: (context) => const RateExperienceDialog(),
    );

    // If user submitted a rating, proceed to store rating
    if (rating != null && rating > 0) {
    if ((Platform.isAndroid && !AccountScreen.kPublishedAndroid) ||
        (Platform.isIOS && !AccountScreen.kPublishedIOS)) {
        // Show thank you message if not published
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your $rating-star rating!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

      // Open store rating if published
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

class _ProfileEditDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final Future<void> Function(String, String, String) onSave;

  const _ProfileEditDialog({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.onSave,
  });

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title, subtitle, and close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile & Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your personal information and account details',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.mutedForeground,
            onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      TextFormField(
                        controller: widget.nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Sarath Mantravadi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Address (read-only — account email cannot be changed here)
                      TextFormField(
                        controller: widget.emailController,
                        readOnly: true,
                        enableInteractiveSelection: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'sarathmantravadi@gmail.com',
                          filled: true,
                          fillColor: AppColors.border.withValues(alpha: 0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      TextFormField(
                        controller: widget.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1 (555) 123-4567',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.foreground,
                        side: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Changes button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await widget.onSave(
                                widget.nameController.text.trim(),
                                widget.emailController.text.trim(),
                                widget.phoneController.text.trim(),
                              );
                              setState(() => _isLoading = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Teal
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
          ),
        ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openStoreRating(BuildContext context) async {
    // Show Rate Your Experience dialog
    final rating = await showDialog<int>(
      context: context,
      builder: (context) => const RateExperienceDialog(),
    );

    // If user submitted a rating, proceed to store rating
    if (rating != null && rating > 0) {
      if ((Platform.isAndroid && !AccountScreen.kPublishedAndroid) ||
          (Platform.isIOS && !AccountScreen.kPublishedIOS)) {
        // Show thank you message if not published
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your $rating-star rating!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Open store rating if published
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
