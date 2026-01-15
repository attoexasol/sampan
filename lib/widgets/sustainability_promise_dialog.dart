import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SustainabilityPromiseDialog extends StatelessWidget {
  const SustainabilityPromiseDialog({super.key});

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
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Globe icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLighter,
                    ),
                    child: const Icon(
                      Icons.public,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title
                  Expanded(
                    child: Text(
                      'Our Sustainability Promise',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
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

            // Scrollable content
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Introduction paragraph
                        Text(
                          'Every load at Sampan Laundry is a quiet act of sustainability. Thanks to our next-generation Maytag high-efficiency machines, we\'re helping the planet breathe easier — one wash at a time.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.foreground,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Our High-Efficiency Machines Save section
                        Text(
                          'Our High-Efficiency Machines Save:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Water savings
                        _buildSavingsItem(
                          icon: Icons.water_drop,
                          iconColor: Colors.blue,
                          text: 'Up to 70% less water than old top-loaders, using precision sensors that fill only what\'s needed.',
                        ),
                        const SizedBox(height: 12),

                        // Detergent savings
                        _buildSavingsItem(
                          icon: Icons.cleaning_services,
                          iconColor: AppColors.primary,
                          text: '75% less detergent, with advanced rinsing that keeps chemicals out of local waterways and leaves your clothes softer on skin.',
                        ),
                        const SizedBox(height: 12),

                        // Gas savings
                        _buildSavingsItem(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                          text: 'Up to 40% less gas for heating water, thanks to intelligent temperature control.',
                        ),
                        const SizedBox(height: 12),

                        // Electricity savings
                        _buildSavingsItem(
                          icon: Icons.bolt,
                          iconColor: Colors.amber,
                          text: '30% less electricity, with high-speed extraction that shortens drying time.',
                        ),
                        const SizedBox(height: 24),

                        // What It Means in Everyday Terms section
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'What It Means in Everyday Terms (Per Load)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildBulletPoint('Each load saves enough water for a 10-minute shower.'),
                        const SizedBox(height: 8),
                        _buildBulletPoint('The energy saved could charge your phone 100 times or light a bulb all night.'),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Across our community, we\'ve kept thousands of liters of soap out of local streams.'),
                        const SizedBox(height: 24),

                        // Your Eco-Friendly Dry Cleaners section
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your Eco-Friendly Dry Cleaners',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Advanced K4 Cleaning System',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'We employ an environmentally-friendly cleaning method known as K4, which is a non-toxic and biodegradable system. This innovative approach relies on a special blend of solvents and surfactants to efficiently eliminate dirt, stains, and odors from garments, all while maintaining the fabric\'s integrity and being gentle on the environment.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.foreground,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Why K4 Matters:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildBulletPoint('Non-toxic – Safe for you and the environment'),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Biodegradable – Breaks down naturally without harming ecosystems'),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Gentle on fabrics – Preserves garment quality and longevity'),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Effective cleaning – Removes tough stains without harsh chemicals'),
                        const SizedBox(height: 16),

                        // Contact info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'We understand that some clients may have environmental or chemical sensitivities. If you have any concerns about the products we use, please contact us at sampanservices@gmail.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.foreground,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Closing statement
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Clean Clothes. Clear Conscience.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'By choosing eco-smart machines, you\'re not just doing laundry — you\'re helping conserve water, reduce energy, and protect the planet. Every spin, every rinse, every dry cycle here is designed for efficiency — proof that sustainability and spotless laundry can go hand in hand.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.foreground,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Close button at bottom
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground,
              height: 1.5,
            ),
          ),
        ),
      ],
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
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
