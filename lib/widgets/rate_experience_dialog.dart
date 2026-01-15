import 'package:flutter/material.dart';
import '../constants/colors.dart';

class RateExperienceDialog extends StatefulWidget {
  const RateExperienceDialog({super.key});

  @override
  State<RateExperienceDialog> createState() => _RateExperienceDialogState();
}

class _RateExperienceDialogState extends State<RateExperienceDialog> {
  int? _selectedRating;

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
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Star icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700), // Yellow outline
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.star_outline,
                      color: Color(0xFFFFD700), // Yellow
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate Your Experience',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your feedback helps us improve our service.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.mutedForeground,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Rating section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How would you rate our service?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isSelected = _selectedRating != null && starIndex <= _selectedRating!;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = starIndex;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Icon(
                            isSelected ? Icons.star : Icons.star_outline,
                            size: 40,
                            color: isSelected 
                                ? const Color(0xFFFFD700) // Yellow when selected
                                : AppColors.mutedForeground, // Dark gray when not selected
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                ],
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
                  // "Maybe Later" button
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
                        'Maybe Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // "Submit Rating" button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedRating != null
                          ? () {
                              // Handle rating submission
                              Navigator.pop(context, _selectedRating);
                              // You can add logic here to submit the rating
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Teal/mint green
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.mutedForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Submit Rating',
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

            // Feedback information section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Light grey background
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your feedback matters!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Helps us improve our services'),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Guides our team training'),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Shapes future features'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
