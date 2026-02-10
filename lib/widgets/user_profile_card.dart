// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:sampan/constants/colors.dart';
// import 'package:sampan/constants/sizes.dart';
//
// import '../controller/profile_controller.dart';
//
//
// class EnvironmentalImpactCard extends StatelessWidget {
//   EnvironmentalImpactCard({super.key});
//
//   final ProfileController controller = Get.put(ProfileController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.lg),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6.r,
//             offset: Offset(0, 2.h),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🌱 Profile Section
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: AppSizes.iconLg,
//                 backgroundColor: AppColors.primary,
//                 child: Obx(() {
//                   final initials = controller.name.value.isNotEmpty
//                       ? controller.name.value
//                       .split(' ')
//                       .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
//                       .take(2)
//                       .join()
//                       : 'U';
//                   return Text(
//                     initials,
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: AppSizes.fontLg,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   );
//                 }),
//               ),
//               SizedBox(width: AppSizes.md),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() => Text(
//                     controller.name.value.isEmpty
//                         ? 'User'
//                         : controller.name.value,
//                     style: TextStyle(
//                       fontSize: AppSizes.fontXl,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.foreground,
//                     ),
//                   )),
//                   SizedBox(height: AppSizes.xs),
//                   Obx(() => Text(
//                     controller.email.value.isEmpty
//                         ? 'your@email.com'
//                         : controller.email.value,
//                     style: TextStyle(
//                       color: AppColors.mutedForeground,
//                       fontSize: AppSizes.fontMd,
//                     ),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//
//           SizedBox(height: AppSizes.md),
//           Divider(color: AppColors.border),
//           SizedBox(height: AppSizes.md),
//
//           Text(
//             'Your Environmental Impact',
//             style: TextStyle(
//               fontSize: AppSizes.fontLg,
//               fontWeight: FontWeight.w600,
//               color: AppColors.foreground,
//             ),
//           ),
//
//           // 🌿 The rest of your existing widget remains unchanged...
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/constants/sizes.dart';

import '../controller/profile_controller.dart';

class EnvironmentalImpactCard extends StatelessWidget {
  EnvironmentalImpactCard({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌱 Profile Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with initials
              CircleAvatar(
                radius: AppSizes.iconLg,
                backgroundColor: AppColors.primary,
                child: Obx(() {
                  final initials = controller.name.value.isNotEmpty
                      ? controller.name.value
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                      .take(2)
                      .join()
                      : 'U';
                  return Text(
                    initials,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),

              SizedBox(width: AppSizes.md),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final nameText = controller.userName.value.trim().isNotEmpty
                          ? controller.userName.value.trim()
                          : 'User Name';
                      return Text(
                        nameText,
                        style: TextStyle(
                          fontSize: AppSizes.fontXl,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      );
                    }),
                    SizedBox(height: AppSizes.xs),
                    Obx(() {
                      final emailText = controller.userEmail.value.trim().isNotEmpty
                          ? controller.userEmail.value.trim()
                          : 'example@gmail.com';
                      return Text(
                        emailText,
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: AppSizes.fontMd,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // ✏️ Edit button - Update Profile
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: () => _showEditDialog(context),
              ),
            ],
          ),

          SizedBox(height: AppSizes.md),
          Divider(color: AppColors.border),
          SizedBox(height: AppSizes.md),

          // Section Title
          Text(
            'Your Environmental Impact',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),

          // ✅ Keep your remaining environmental UI here
        ],
      ),
    );
  }

  // ✅ Edit Profile Popup Dialog
  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.name.value);
    final emailCtrl = TextEditingController(text: controller.email.value);

    Get.defaultDialog(
      title: "Edit Profile",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
      content: Column(
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
          ),
        ],
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        controller.updateProfile(nameCtrl.text.trim(), emailCtrl.text.trim());
        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
