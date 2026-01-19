import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/order_summary_card_widget.dart';
import '../../models/product_model.dart';
import '../../modules/schedule/schedule_binding.dart';
import '../../modules/schedule/schedule_view.dart';
import 'laundry_controller.dart';

class LaundryView extends StatelessWidget {
  const LaundryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaundryController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    _buildHowItWorksCard(),
                    SizedBox(height: AppSizes.md),
                    _buildPremiumBagCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildSubscriptionsCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildPayAsYouGoCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildBulkyItemsSection(controller),
                    SizedBox(height: AppSizes.md),
                    _buildExpressServiceCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildSpecialInstructionsCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildOrderSummaryCard(controller),
                    SizedBox(height: AppSizes.md),
                    _buildHowWeCareCard(),
                    SizedBox(height: AppSizes.md),
                    _buildMoreAboutServicesCard(),
                    SizedBox(height: AppSizes.xl),
                    _buildActionButtons(controller),
                    SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
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
            'Laundry',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHowItWorksIcon(Icons.access_time, 'Select', 'Pick a time'),
              _buildHowItWorksIcon(Icons.local_laundry_service, 'Wash', "We'll pick up"),
              _buildHowItWorksIcon(Icons.eco, 'Enjoy', 'Cleaned & Delivered'),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'Learn more about how it works',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksIcon(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            color: Colors.white,
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontMd,
            color: AppColors.foreground,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBagCard(LaundryController controller) {
    return Obx(() => Container(
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
          Row(
            children: [
              Text(
                'Premium Bag Service',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.mutedForeground),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            "When you use a Premium Bag, you'll get all your clothes washed, dried, and folded for a flat price.",
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildBulletPoint('Up to 15 lbs of clothes'),
          _buildBulletPoint('One-time use only'),
          _buildBulletPoint('Delivery in a single wash'),
          SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'One-Time Bag - \$${LaundryController.premiumBagPrice.toStringAsFixed(2)}/bag',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          OutlinedButton(
            onPressed: () => controller.togglePremiumBag(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: controller.isPremiumBagSelected.value ? AppColors.primary : AppColors.border),
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              controller.isPremiumBagSelected.value ? 'Added' : 'Add',
              style: TextStyle(
                color: controller.isPremiumBagSelected.value ? AppColors.primary : AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Learn more about benefits',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSubscriptionsCard(LaundryController controller) {
    return Obx(() => Container(
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
          Row(
            children: [
              Text(
                'Subscriptions',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.mutedForeground),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'A great option for regular laundry, save money on every wash by paying a monthly fee.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildBulletPoint('Up to 15 lbs per wash'),
          _buildBulletPoint('Multiple washes per month'),
          _buildBulletPoint('Cancel anytime'),
          SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Green Bag Plus - \$${LaundryController.subscriptionPrice.toStringAsFixed(0)}/per bag',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          OutlinedButton(
            onPressed: () => controller.toggleSubscription(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: controller.isSubscriptionSelected.value ? AppColors.primary : AppColors.border),
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              controller.isSubscriptionSelected.value ? 'Added' : 'Add',
              style: TextStyle(
                color: controller.isSubscriptionSelected.value ? AppColors.primary : AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Learn more about benefits',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPayAsYouGoCard(LaundryController controller) {
    return Obx(() => Container(
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
          Row(
            children: [
              Text(
                'Pay As You Go',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.mutedForeground),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'The Pay As You Go option is \$${LaundryController.payAsYouGoPrice.toStringAsFixed(2)} per pound. Just load your clothes, and the machine will weigh it for an accurate price.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          _buildBulletPoint('Up to 15 lbs of clothes'),
          _buildBulletPoint('One-time use only'),
          _buildBulletPoint('No minimum'),
          SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Pay Per Pound - \$${LaundryController.payAsYouGoPrice.toStringAsFixed(2)}/lb',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          OutlinedButton(
            onPressed: () => controller.togglePayAsYouGo(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: controller.isPayAsYouGoSelected.value ? AppColors.primary : AppColors.border),
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              controller.isPayAsYouGoSelected.value ? 'Added' : 'Add',
              style: TextStyle(
                color: controller.isPayAsYouGoSelected.value ? AppColors.primary : AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Learn more about benefits',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBulkyItemsSection(LaundryController controller) {
    return Obx(() {
      if (controller.isLoadingBulkyItems.value) {
        return Container(
          padding: EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
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
            Row(
              children: [
                Text(
                  'Bulky Items',
                  style: TextStyle(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(width: AppSizes.xs),
                Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.mutedForeground),
              ],
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              "We'll pick up, wash, dry, and fold your selected items. Price per item.",
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.mutedForeground,
              ),
            ),
            SizedBox(height: AppSizes.md),
            ...controller.bulkyItems.map((product) => _buildBulkyItemCard(controller, product)),
          ],
        ),
      );
    });
  }

  Widget _buildBulkyItemCard(LaundryController controller, Product product) {
    return Obx(() {
      final qty = controller.getBulkyItemQuantity(product.id);
      
      return Container(
        margin: EdgeInsets.only(bottom: AppSizes.sm),
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    'Per item, up to 1.5 kg',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => controller.decrementBulkyItem(product),
              icon: Icon(Icons.remove_circle_outline, color: AppColors.primary),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                '$qty',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ),
            IconButton(
              onPressed: () => controller.incrementBulkyItem(product),
              icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildExpressServiceCard(LaundryController controller) {
    return Obx(() => Container(
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
          Row(
            children: [
              Text(
                'Want It Sooner?',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              const Spacer(),
              Checkbox(
                value: controller.isExpressServiceSelected.value,
                onChanged: (_) => controller.toggleExpressService(),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Get your clothes back in 24 hours. This is an additional charge of \$${LaundryController.expressServicePrice.toStringAsFixed(2)} per order.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            '\$${LaundryController.expressServicePrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSpecialInstructionsCard(LaundryController controller) {
    return Container(
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
          Row(
            children: [
              Text(
                'Special Instruction Note',
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Icon(Icons.info_outline, size: AppSizes.iconSm, color: AppColors.mutedForeground),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            'Add a note for your order.',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          TextField(
            controller: controller.specialInstructionsController,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'Type here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: EdgeInsets.all(AppSizes.md),
            ),
          ),
          Obx(() => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.specialInstructions.value.length}/100',
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.mutedForeground,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(LaundryController controller) {
    return Obx(() {
      final orderCtrl = controller.orderCtrl;
      
      return Container(
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
              'Order Summary',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            SizedBox(height: AppSizes.md),
            if (!orderCtrl.hasAnySelection)
              Text(
                'Your order items will appear here when you add them.',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              OrderSummaryCard(
                items: orderCtrl.items.values.map((item) => item.toJson()).toList(),
                subTotal: orderCtrl.subTotal,
                deliveryFee: orderCtrl.deliveryFee,
                tax: orderCtrl.tax,
                grandTotal: orderCtrl.grandTotal,
              ),
              SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => const ScheduleView(),
                      binding: ScheduleBinding(),
                      arguments: {'orderSummary': controller.getOrderSummarySnapshot()},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Proceed to Schedule',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildHowWeCareCard() {
    return Container(
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
      child: ExpansionTile(
      title: Text(
        'How We Care For Your Clothes',
        style: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professionals, Not Gig Workers',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                'Our cleaning process ensures your clothes receive professional care.',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Cleaning Process',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              SizedBox(height: AppSizes.md),
              _buildProcessItem(Icons.local_laundry_service, 'Washing Process', [
                'High-efficiency machines',
                'K4 cleaning system',
                'Biodegradable detergents',
              ]),
              _buildProcessItem(Icons.dry_cleaning, 'Drying Process', [
                'Low heat drying',
                'Air-drying for delicates',
              ]),
              _buildProcessItem(Icons.local_shipping, 'Delivery Process', [
                'Professional folding',
                'Contactless delivery',
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessItem(IconData icon, String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                ...items.map((item) => Padding(
                  padding: EdgeInsets.only(top: AppSizes.xs),
                  child: Text(
                    '• $item',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAboutServicesCard() {
    return Container(
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
      child: ExpansionTile(
      title: Text(
        'More About Our Services',
        style: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
      children: [
        ExpansionTile(
          title: Text('Premium Bag Service Details'),
          children: [
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Text(
                'Details about our premium bag service.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Subscriptions: What to Know'),
          children: [
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Text(
                'Information about subscription plans.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Pay-As-You-Go: How It Works'),
          children: [
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Text(
                'Details about pay-as-you-go pricing.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Bulky Items: Good to Know'),
          children: [
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Text(
                'Information about bulky item cleaning.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }

  Widget _buildActionButtons(LaundryController controller) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.border),
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text('Back'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
