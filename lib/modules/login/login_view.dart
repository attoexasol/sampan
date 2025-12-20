import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../widgets/elevated_icon_button.dart';
import '../recover_acc/forgot_pass.dart';
import '../signup/signup_binding.dart';
import '../signup/signup_view.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48.h),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to your Sampan Laundry account',
                    textAlign: TextAlign.center,
                  ),
                  // SizedBox(height: 24.h),
                  //
                  // // Social login (placeholders)
                  // Elevated_Icon_Button(
                  //   onTap: () {},
                  //   icon: Icon(FontAwesomeIcons.google, size: 20.r),
                  //   buttonName: "Continue with Google",
                  // ),
                  // SizedBox(height: 10.h),
                  // Elevated_Icon_Button(
                  //   onTap: () {},
                  //   icon: Icon(FontAwesomeIcons.apple, size: 20.r),
                  //   buttonName: "Continue with Apple",
                  // ),
                  // SizedBox(height: 10.h),
                  // Elevated_Icon_Button(
                  //   onTap: () {},
                  //   icon: Icon(FontAwesomeIcons.facebookF, size: 20.r),
                  //   buttonName: "Continue with Facebook",
                  // ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Or log in with email",
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  // ----------- FORM ------------
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        // Email field
                        TextFormField(
                          controller: controller.emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Email is required';
                            if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password with toggle
                        Obx(() => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword.value,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'Password is required';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.to(() => ForgetPasswordScreen()),
                      child: const Text(
                        "Forget Password?",
                        style: TextStyle(color: Color(0xff1bbc9c)),
                      ),
                    ),
                  ),

                  // Login button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Log In'),
                    ),
                  )),
                  const SizedBox(height: 16),

                  Elevated_Icon_Button(
                    onTap: controller.navigateToHome,
                    icon: Icon(FontAwesomeIcons.arrowLeft, size: 20.r),
                    buttonName: "Back to Order",
                  ),
                  SizedBox(height: 10.h),

                  TextButton(
                    onPressed: () =>
                        Get.to(() => const SignupView(), binding: SignupBinding()),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
