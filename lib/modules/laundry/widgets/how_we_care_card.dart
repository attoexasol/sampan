// lib/modules/laundry/widgets/how_we_care_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class HowWeCareCard extends StatefulWidget {
  const HowWeCareCard({super.key});

  @override
  State<HowWeCareCard> createState() => _HowWeCareCardState();
}

class _HowWeCareCardState extends State<HowWeCareCard> {
  bool _isExpanded = false;

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
            'How We Care For Your Clothes',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Professionals, Not Gig Workers Card
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professionals, Not Gig Workers',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'Your laundry is in expert hands — always',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.foreground,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'Our in-house team is skilled, reliable, and treats your clothes with personal care. We fit into your life, not the other way around.',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Our Cleaning Process - Expandable Section
          ExpansionTile(
            title: Text(
              'Our Cleaning Process',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Washing Process Card
                    _buildProcessCard(
                      icon: Icons.water_drop,
                      title: 'Washing Process',
                      items: [
                        'Washed in tap cold water by default — gentle on fabrics and eco-friendly',
                        'Warm/hot water available at no extra charge',
                        'Every load gets an extra rinse',
                        'No bleach or fabric softener unless requested under Custom Options',
                      ],
                      iconColor: Colors.blue.shade700,
                      backgroundColor: Colors.blue.shade50,
                      borderColor: Colors.blue.shade200,
                    ),
                    SizedBox(height: AppSizes.md),
                    // 2. Drying Process Card
                    _buildProcessCard(
                      icon: Icons.local_fire_department,
                      title: 'Drying Process',
                      items: [
                        'Default: Regular heat (160°F)',
                        'Low heat or hang dry available via customization',
                      ],
                      iconColor: Colors.orange.shade700,
                      backgroundColor: Colors.orange.shade50,
                      borderColor: Colors.orange.shade200,
                    ),
                    SizedBox(height: AppSizes.md),
                    // 3. Smart Sorting Card
                    _buildProcessCard(
                      icon: Icons.auto_awesome,
                      title: 'Smart Sorting',
                      items: [
                        'We automatically separate obvious whites from colors — no need to ask',
                        'Obviously, we don\'t mix your laundry with anyone else 😉',
                      ],
                      iconColor: Colors.pink.shade700,
                      backgroundColor: Colors.pink.shade50,
                      borderColor: Colors.pink.shade200,
                    ),
                    SizedBox(height: AppSizes.md),
                    // 4. Delicate Care Card
                    _buildProcessCard(
                      icon: Icons.checkroom,
                      title: 'Delicate Care',
                      items: [
                        'Delicates require pre-separation by you to receive special handling',
                        'When you pre-separate delicate items, we process them with specialized care using gentle wash cycles and low-heat drying at 140°F',
                        'Items mixed with regular laundry receive our standard wash and dry treatment alongside other garments',
                      ],
                      iconColor: Colors.purple.shade700,
                      backgroundColor: Colors.purple.shade50,
                      borderColor: Colors.purple.shade200,
                    ),
                    SizedBox(height: AppSizes.md),
                    // 5. Pocket Check - Included! Card
                    _buildProcessCard(
                      icon: Icons.check_circle,
                      title: 'Pocket Check - Included!',
                      items: [
                        'We check all pockets as part of our standard service to protect your belongings and our equipment.',
                      ],
                      iconColor: Colors.green.shade700,
                      backgroundColor: Colors.green.shade50,
                      borderColor: Colors.green.shade200,
                      isBoldTitle: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    bool isBoldTitle = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: isBoldTitle ? FontWeight.bold : FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(
              left: AppSizes.iconMd + AppSizes.sm + AppSizes.sm,
              bottom: AppSizes.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: AppSizes.xs),
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
}
