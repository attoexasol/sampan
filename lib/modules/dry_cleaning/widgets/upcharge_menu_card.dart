import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class UpchargeMenuCard extends StatelessWidget {
  const UpchargeMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcharge Menu (Tentative)',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Additional charges that may apply',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildSection('Fabric & Material', [
            'Silk, Linen, Rayon, Cashmere, Wool, Velvet, Satin — \$5 each',
          ]),
          SizedBox(height: AppSizes.md),
          _buildSection('Design & Brand', [
            'Designer label — \$5',
            'Embellishments (beading, sequins, embroidery, logos) — \$5-10',
          ]),
          SizedBox(height: AppSizes.md),
          _buildSection('Structure & Construction', [
            'Extra lining — \$5-15',
            'Zip-out lining — \$15',
            'Leather or Fur trim — \$5 each',
          ]),
          SizedBox(height: AppSizes.md),
          _buildSection('Condition & Care', [
            'Special Care (delicate handling) — \$10',
            'Lint removal - Light \$5, Medium \$7.50, Heavy \$10',
          ]),
          SizedBox(height: AppSizes.lg),
          Text(
            'Common Add-Ons for Popular Items',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildItemCard('2-Piece Suit', [
            'Designer: \$5',
            'Embellishments: \$5 or Special Care: \$10',
            'Zip-out lining: \$15',
            'Leather trim: \$5',
            'Maximum possible: \$35',
          ]),
          SizedBox(height: AppSizes.md),
          _buildItemCard('Plain Pants', [
            'Designer: \$5',
            'One material (e.g., Silk, Linen, Rayon, Cashmere, Corduroy): \$5',
            'Lined: \$5',
            'Maximum possible: \$15',
          ]),
          SizedBox(height: AppSizes.md),
          _buildItemCard('Sports Jacket', [
            'Designer: \$5',
            'Embellishments: \$10',
            'Zip-out lining: \$15',
            'Maximum possible: \$30',
          ]),
          SizedBox(height: AppSizes.md),
          _buildItemCard('Shirts', [
            'Designer: \$5',
            'One material (Silk, Linen, Satin): \$5',
            'Special Care: \$10',
            'Maximum possible: \$15',
          ]),
          SizedBox(height: AppSizes.md),
          _buildItemCard('Medium Sweater', [
            'Premium fibers (Merino, Angora, Cashmere, Silk): \$5 each',
            'Lint removal: up to \$10',
            'Maximum possible: \$30',
          ]),
          SizedBox(height: AppSizes.md),
          _buildItemCard('Outdoor Jacket (Heavy)', [
            'Designer: \$5',
            'Embellishments: \$10',
            'Zip-out lining: \$15',
            'Maximum possible: \$30',
          ]),
          SizedBox(height: AppSizes.lg),
          Text(
            'Example:',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'A 2-piece designer suit with a zip-out lining and leather trim → base price + \$5 (designer) + \$15 (zip-out) + \$5 (leather) = \$25 extra.',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.mutedForeground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'Note:',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'These are tentative prices and may change without prior notice. Final amounts are confirmed after inspection.',
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.mutedForeground,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
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
        SizedBox(height: AppSizes.xs),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(left: AppSizes.md, bottom: AppSizes.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.mutedForeground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildItemCard(String title, List<String> items) {
    return Column(
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
        SizedBox(height: AppSizes.xs),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(left: AppSizes.md, bottom: AppSizes.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.mutedForeground,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
