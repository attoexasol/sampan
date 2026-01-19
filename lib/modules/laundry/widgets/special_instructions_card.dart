// lib/modules/laundry/widgets/special_instructions_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class SpecialInstructionsCard extends StatelessWidget {
  final TextEditingController controller;
  final bool saveForFuture;
  final ValueChanged<bool>? onSaveForFutureChanged;

  const SpecialInstructionsCard({
    super.key,
    required this.controller,
    this.saveForFuture = false,
    this.onSaveForFutureChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = false.obs;
    final saveForFutureValue = saveForFuture.obs;

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
            'Special Instructions or Notes',
            style: GoogleFonts.outfit(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.md),
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any special instructions for this order...',
              hintStyle: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: AppSizes.fontMd,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.all(AppSizes.md),
            ),
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'These notes will be included with your order.',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Obx(() => OutlinedButton.icon(
                onPressed: () {
                  saveForFutureValue.value = !saveForFutureValue.value;
                  onSaveForFutureChanged?.call(saveForFutureValue.value);
                },
                icon: Icon(
                  Icons.bookmark_border,
                  size: 16,
                  color: saveForFutureValue.value
                      ? AppColors.primary
                      : AppColors.mutedForeground,
                ),
                label: Text(
                  'Save for Future Orders',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: saveForFutureValue.value
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: saveForFutureValue.value
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Learn more about benefits',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Obx(() => AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded.value ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                )),
              ],
            ),
          ),
          Obx(() => AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: isExpanded.value
                ? Padding(
                    padding: EdgeInsets.only(top: AppSizes.sm),
                    child: Text(
                      'Your notes will be saved and can be reused for future laundry orders. You can edit or remove them anytime from your account settings.',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          )),
        ],
      ),
    );
  }
}
