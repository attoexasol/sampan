import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sampan/screens/account_screen.dart';
import 'package:sampan/widgets/header_widget.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart' ;
import '../controller/products_controller.dart';
import '../controller/order_summary_controller.dart';
import '../data/service/products_service.dart';
import '../modules/schedule/schedule_controller.dart';
import '../modules/schedule/schedule_view.dart';
import '../widgets/laundry_how_it_works.dart';
import '../widgets/service_card.dart';
import '../widgets/specialty_service_card.dart';
import 'service_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BookScreen(),
    const ScheduleView(),
    const AccountScreen(),
  ];


  @override
  void initState() {
    super.initState();

    // ✅ Register ScheduleController so GetView can find it
    Get.lazyPut<ScheduleController>(() => ScheduleController());

    // ✅ Register OrderSummaryController for ScheduleView when accessed via bottom nav
    if (!Get.isRegistered<OrderSummaryController>()) {
      Get.lazyPut<OrderSummaryController>(() => OrderSummaryController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ðŸŒ„ Background pattern (small & repeating)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                image: DecorationImage(
                  image: AssetImage('assets/images/laundry-background-pattern.png'),
                  repeat: ImageRepeat.repeat, // repeats pattern
                  fit: BoxFit.none,            // keeps pattern small
                  opacity: 0.06,               // subtle
                ),
              ),
            ),
          ),

          // ðŸ§¾ Active screen content
          _screens[_currentIndex],
        ],
      ),

      // ðŸ§­ Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: LucideIcons.clipboard,
                  label: 'Select',
                  index: 0,
                ),
                _buildNavItem(
                  icon: LucideIcons.package,
                  label: 'Schedule',
                  index: 1,
                ),
                _buildNavItem(
                  icon: LucideIcons.user,
                  label: 'Account',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.mutedForeground,
              size: AppSizes.iconMd,
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.mutedForeground,
                fontSize: AppSizes.fontSm,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  State<BookScreen> createState() => _BookScreenState();
}


class _BookScreenState extends State<BookScreen> {
  Map<String, bool> services = {
    'weekly': false,
    'payasyougo': false,
    'eliteexpress': false,
  };

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.find<ProductsController>();

    return SafeArea(
      child: Obx(() {
        if (productsCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSizes.lg),
          child: Column(
            children: [
              const HeaderWidget(),

              Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'What needs cleaning?',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.md),

                    // Laundry & Dry Cleaning
                    Row(
                      children: [
                        Expanded(
                          child: ServiceCard(
                            icon: LucideIcons.shirt,
                            title: 'Laundry',
                            subtitle: 'Wash & Fold, Bulky Items',
                            isSelected: false,
                            onTap: () => Get.to(() => ServiceProductsScreen(
                              category: ProductCategory.laundry,
                            )),
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: ServiceCard(
                            icon: LucideIcons.wind,
                            title: 'Dry Cleaning',
                            subtitle: 'Professional Care',
                            isSelected: false,
                            onTap: () => Get.to(() => ServiceProductsScreen(
                              category: ProductCategory.dryCleaning,
                            )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.xl),

                    // Specialty Services
                    Text(
                      'Specialty Services',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    SizedBox(height: AppSizes.md),

                    Row(
                      children: [
                        Expanded(
                          child: SpecialtyServiceCard(
                            icon: LucideIcons.scissors,
                            title: 'Alterations',
                            onTap: () => Get.to(() => ServiceProductsScreen(
                              category: ProductCategory.alterations,
                            )),
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: SpecialtyServiceCard(
                            icon: LucideIcons.wind,
                            title: 'Steaming',
                            onTap: () => Get.to(() => ServiceProductsScreen(
                              category: ProductCategory.alterations,
                            )),
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: SpecialtyServiceCard(
                            icon: LucideIcons.shieldCheck,
                            title: 'Shoe Care',
                            onTap: () => Get.to(() => ServiceProductsScreen(
                              category: ProductCategory.alterations,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}