import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../data/service/local_store.dart';

class Elevated_Icon_Button extends StatelessWidget {
  const Elevated_Icon_Button({
    super.key,
    required this.onTap,
    required this.icon,
    required this.buttonName,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String buttonName;

  @override
  Widget build(BuildContext context) {
    const Color activeBg = Color(0xff1bbc9c);
    const Color inactiveBg = Colors.white;

    return SizedBox(
     // height: 40.h,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(
          buttonName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ButtonStyle(
          // background color: white → green on hover/press
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final isActive = states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) || states.contains(WidgetState.focused);
            return isActive ? activeBg : inactiveBg;
          }),

          // foreground (text + icon) color
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final isActive = states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) || states.contains(WidgetState.focused);
            return isActive ? Colors.white : Colors.black;
          }),

          // border, shape, etc.
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: Colors.grey),
            ),
          ),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }



  Future<void> logout(dynamic name, var email) async {
    await LocalStore.instance.clearAll(); // clears everything
    name.value = 'User Name';
    email.value = 'example@gmail.com';

    // Optionally navigate to login
    Get.offAllNamed('/login');
    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }


}



