import 'package:flutter/material.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/constants/sizes.dart';

class HelpSupportSection extends StatelessWidget {
  final List<_HelpItem> items = const [
    _HelpItem(icon: Icons.help_outline, label: 'FAQs'),
    _HelpItem(icon: Icons.description_outlined, label: 'Terms & Privacy'),
    _HelpItem(icon: Icons.star_border, label: 'Rate Our App'),
  ];

  const HelpSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.only(
                  topLeft: index == 0
                      ? Radius.circular(AppSizes.radiusLg)
                      : Radius.zero,
                  topRight: index == 0
                      ? Radius.circular(AppSizes.radiusLg)
                      : Radius.zero,
                  bottomLeft: index == items.length - 1
                      ? Radius.circular(AppSizes.radiusLg)
                      : Radius.zero,
                  bottomRight: index == items.length - 1
                      ? Radius.circular(AppSizes.radiusLg)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                    horizontal: AppSizes.lg,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: AppSizes.iconLg,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedForeground,
                        size: AppSizes.iconLg,
                      ),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: AppSizes.lg),
                  child: Divider(
                    height: 1,
                    thickness: 0.6,
                    color: AppColors.border,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String label;
  const _HelpItem({required this.icon, required this.label});
}
