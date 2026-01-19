import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class DryCleaningHowItWorksCard extends StatelessWidget {
  const DryCleaningHowItWorksCard({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Dry Cleaning',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'How It Works',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          _buildStep(
            number: '1',
            title: 'Select Items',
            description: 'The total count matters more. Don\'t stress about exact type.',
            example: '(Ex: Marked 4 shirts but send a pant, coat, jacket, and shirt? — we\'ll fix it.)',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '2',
            title: 'Fair Pricing',
            description: 'Base Price + Upcharges only if required\n(we\'re trying to reduce your cost)',
            highlightedText: ['Base Price', 'Upcharges'],
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '3',
            title: 'Pickup & Return',
            description: 'Use your bag → returned on hangers in clear poly covers.',
          ),
          SizedBox(height: AppSizes.md),
          _buildStep(
            number: '4',
            title: 'Billing',
            description: 'Minimum Charged Upfront. Adjusted, if needed, before delivery.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    String? example,
    List<String>? highlightedText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.md),
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
              SizedBox(height: 4),
              _buildDescription(description, highlightedText),
              if (example != null) ...[
                SizedBox(height: AppSizes.sm),
                Container(
                  padding: EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    example,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String text, List<String>? highlightedText) {
    if (highlightedText == null || highlightedText.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.mutedForeground,
        ),
      );
    }

    final parts = text.split(RegExp(r'(' + highlightedText.map((e) => RegExp.escape(e)).join('|') + ')'));
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.mutedForeground,
        ),
        children: parts.map((part) {
          final isHighlighted = highlightedText.contains(part);
          return TextSpan(
            text: part,
            style: isHighlighted
                ? TextStyle(
                    fontWeight: FontWeight.w700,
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }
}
