// lib/modules/laundry/widgets/more_about_services_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class MoreAboutServicesCard extends StatelessWidget {
  const MoreAboutServicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More About Our Services',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildExpandableRow(
            title: 'Premium Bag Service: Details',
            child: _buildPremiumBagSection(),
          ),
          SizedBox(height: AppSizes.sm),
          _buildExpandableRow(
            title: 'Subscriptions: What to Know',
            child: _buildSubscriptionsSection(),
          ),
          SizedBox(height: AppSizes.sm),
          _buildExpandableRow(
            title: 'Pay-As-You-Go: How It Works',
            child: _buildPayAsYouGoSection(),
          ),
          SizedBox(height: AppSizes.sm),
          _buildExpandableRow(
            title: 'Bulky Items: Good to Know',
            child: _buildBulkyItemsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableRow({
    required String title,
    required Widget child,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      childrenPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: AppColors.border),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: AppColors.border),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      iconColor: AppColors.mutedForeground,
      collapsedIconColor: AppColors.mutedForeground,
      children: [
        child,
      ],
    );
  }

  Widget _buildPremiumBagSection() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitsCard(
            title: 'Service Benefits:',
            items: [
              'Same-day (12h) turnaround for urgent needs',
              'Free pickup & delivery always',
              'Priority pickup & delivery windows',
              'Concierge access for special requests',
              'Discounted add-ons and bulky items',
            ],
            backgroundColor: AppColors.primaryLighter,
            titleColor: AppColors.primary,
          ),
          SizedBox(height: AppSizes.md),
          _buildIncludedExcludedCard(
            title: 'What\'s Included:',
            content: 'Regular clothes, delicates, and linens included. If you separate delicates, we will wash them separately.',
            isIncluded: true,
          ),
          SizedBox(height: AppSizes.md),
          _buildIncludedExcludedCard(
            title: 'What\'s Excluded:',
            content: 'Comforters, duvets, blankets, pillows, sleeping bags, rugs & mats, shoes, dry-clean only items',
            isIncluded: false,
          ),
          SizedBox(height: AppSizes.md),
          _buildFirstOrderEssentials([
            _buildEssentialItem(
              icon: Icons.flash_on,
              iconColor: Colors.orange,
              title: 'Same-Day Service',
              description: '12-hour turnaround guaranteed for when you need it fast',
            ),
            _buildEssentialItem(
              icon: Icons.home,
              iconColor: Colors.orange,
              title: 'Bags Delivered at Pickup',
              description: 'Our driver brings your laundry bags right to your door',
            ),
            _buildEssentialItem(
              icon: Icons.notifications,
              iconColor: Colors.orange,
              title: 'Concierge Support',
              description: 'Direct access to our team for special requests and scheduling',
            ),
            _buildEssentialItem(
              icon: Icons.inventory_2,
              iconColor: Colors.brown,
              title: 'Track Your Order',
              description: 'Use the app to see when your driver is on the way',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitsCard(
            title: 'Plan Benefits:',
            items: [
              'Free pickup & delivery always',
              'Unlimited rollover of bag credits',
              'Cancel anytime with 30 days\' notice',
              'No math. No guessing. Easy to plan',
            ],
            backgroundColor: AppColors.primaryLighter,
            titleColor: AppColors.primary,
          ),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildIncludedExcludedCard(
                  title: 'What\'s Included:',
                  content: 'Regular clothes, delicates, and linens included. If you separate delicates, we will wash them separately.',
                  isIncluded: true,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildIncludedExcludedCard(
                  title: 'What\'s Excluded:',
                  content: 'Comforters, duvets, blankets, pillows, sleeping bags, rugs & mats, shoes, dry-clean only items',
                  isIncluded: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          _buildFirstOrderEssentials([
            _buildEssentialItem(
              icon: Icons.home,
              iconColor: Colors.orange,
              title: 'Bags Delivered at Pickup',
              description: 'Our driver brings your laundry bags right to your door',
            ),
            _buildEssentialItem(
              icon: Icons.checkroom,
              iconColor: Colors.green,
              title: 'Sort Ahead of Time',
              description: 'Have everything sorted and ready to go before your pickup window',
            ),
            _buildEssentialItem(
              icon: Icons.inventory_2,
              iconColor: Colors.brown,
              title: 'Track Your Order',
              description: 'Use the app to see when your driver is on the way',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPayAsYouGoSection() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitsCard(
            title: 'Plan Benefits:',
            items: [
              'No commitment required',
              '\$10.99 pickup & delivery fee',
              'Same professional cleaning quality',
              'Perfect for occasional use',
            ],
            backgroundColor: Colors.green.shade50,
            titleColor: Colors.green.shade700,
          ),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildIncludedExcludedCard(
                  title: 'What\'s Included:',
                  content: 'Regular clothes, delicates, and linens included. If you separate delicates, we will wash them separately.',
                  isIncluded: true,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildIncludedExcludedCard(
                  title: 'What\'s Excluded:',
                  content: 'Comforters, duvets, blankets, pillows, sleeping bags, rugs & mats, shoes, dry-clean only items',
                  isIncluded: false,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          _buildFirstOrderEssentials([
            _buildEssentialItem(
              icon: Icons.shopping_bag,
              iconColor: Colors.blue,
              title: 'Fill It in Your Own Bags',
              description: 'Use any bags you have - we\'ll return them in plastic bags after cleaning',
            ),
            _buildEssentialItem(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.amber.shade700,
              title: 'Minimum Charge',
              description: '\$55.99 minimum (20 lbs x \$2.25 + \$10.99 pickup fee). \$10.99 pickup & delivery fee applies.',
            ),
            _buildEssentialItem(
              icon: Icons.scale,
              iconColor: Colors.amber.shade700,
              title: 'Weigh & Adjust',
              description: 'We weigh in-store and adjust final charge if over 20 lbs',
            ),
            _buildEssentialItem(
              icon: Icons.inventory_2,
              iconColor: Colors.brown,
              title: 'Track Your Order',
              description: 'Use the app to see when your driver is on the way',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBulkyItemsSection() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFirstOrderEssentials([
            _buildEssentialItem(
              icon: Icons.shopping_bag,
              iconColor: Colors.blue,
              title: 'Fill Your Bags',
              description: 'Pack your laundry tightly for maximum value',
            ),
            _buildEssentialItem(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.amber.shade700,
              title: 'Minimum Charge',
              description: '\$45 minimum applies to all orders. \$10.99 pickup & delivery fee applies.',
            ),
            _buildEssentialItem(
              icon: Icons.receipt,
              iconColor: Colors.green,
              title: 'Priced Per Item',
              description: 'Bulky items are charged per piece, not by weight',
            ),
            _buildEssentialItem(
              icon: Icons.inventory_2,
              iconColor: Colors.brown,
              title: 'Track Your Order',
              description: 'Use the app to see when your driver is on the way',
            ),
          ]),
        ],
      ),
    );
  }

  // Helper: Build Benefits Card
  Widget _buildBenefitsCard({
    required String title,
    required List<String> items,
    required Color backgroundColor,
    required Color titleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: titleColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: AppSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 4, right: AppSizes.xs),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: titleColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper: Build Included/Excluded Card
  Widget _buildIncludedExcludedCard({
    required String title,
    required String content,
    required bool isIncluded,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isIncluded ? Colors.white : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isIncluded ? AppColors.border : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: isIncluded ? AppColors.foreground : Colors.red.shade700,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            content,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.mutedForeground,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build First Order Essentials Section
  Widget _buildFirstOrderEssentials(List<Widget> items) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Order Essentials:',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          ...items,
        ],
      ),
    );
  }

  // Helper: Build Essential Item
  Widget _buildEssentialItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
