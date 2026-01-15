import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DeleteAccountFeedbackDialog extends StatefulWidget {
  const DeleteAccountFeedbackDialog({super.key});

  @override
  State<DeleteAccountFeedbackDialog> createState() => _DeleteAccountFeedbackDialogState();
}

class _DeleteAccountFeedbackDialogState extends State<DeleteAccountFeedbackDialog> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();
  final int _maxFeedbackLength = 500;

  final List<String> _reasons = [
    'Too expensive',
    'Not using the service anymore',
    'Quality of service issues',
    'Found a better alternative',
    'App/technical issues',
    'Moving out of service area',
    'Privacy concerns',
    'Other reason',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable content
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Title: "Why are you leaving?"
                      Text(
                        'Why are you leaving?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Reason list with radio buttons
                      ..._reasons.map((reason) => _buildReasonOption(reason)),

                      const SizedBox(height: 32),

                      // Section 2: "Tell us more (optional)"
                      Text(
                        'Tell us more (optional)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Instructional text
                      Text(
                        'Your feedback is invaluable and will help us serve our customers better.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Text area
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB), // Light grey background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _feedbackController,
                              maxLines: 6,
                              maxLength: _maxFeedbackLength,
                              decoration: InputDecoration(
                                hintText: 'What could we have done differently?',
                                hintStyle: TextStyle(
                                  color: AppColors.mutedForeground.withOpacity(0.6),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                counterText: '', // Hide default counter
                              ),
                              style: TextStyle(
                                color: AppColors.foreground,
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                setState(() {}); // Update character counter
                              },
                            ),
                            // Character counter positioned at bottom right
                            Positioned(
                              bottom: 8,
                              right: 12,
                              child: Text(
                                '${_feedbackController.text.length}/$_maxFeedbackLength',
                                style: TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
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
                  // "Keep My Account" button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
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
                        'Keep My Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // "Continue" button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'reason': _selectedReason,
                          'feedback': _feedbackController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899), // Pink/red color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Continue',
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

  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedReason = reason;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button - Match React: light teal/green outline
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primary // Teal/green when selected
                        : AppColors.primary.withOpacity(0.5), // Light teal outline
                    width: 2,
                  ),
                  color: isSelected 
                      ? AppColors.primary 
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Reason text
              Expanded(
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
