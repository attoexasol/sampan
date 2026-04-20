import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../recover_acc/forgot_pass.dart';
import '../signup/signup_binding.dart';
import '../signup/signup_view.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: AppSizes.fontXxl,
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.sm),
                        Text(
                          'Log in to your Sampan Laundry Service account',
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.xl),

                        Obx(() => Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: controller.isLoading.value
                                ? null
                                : () {
                                    debugPrint('[GOOGLE_AUTH] Button clicked');
                                    controller.loginWithGoogle();
                                  },
                            splashColor: Colors.black.withOpacity(0.08),
                            highlightColor: Colors.black.withOpacity(0.06),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.google, size: AppSizes.iconMd, color: AppColors.foreground),
                                  SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(color: AppColors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        SizedBox(height: AppSizes.md),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            splashColor: Colors.black.withOpacity(0.08),
                            highlightColor: Colors.black.withOpacity(0.06),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.apple, size: AppSizes.iconMd, color: AppColors.foreground),
                                  SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Continue with Apple',
                                    style: TextStyle(color: AppColors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.md),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            splashColor: Colors.black.withOpacity(0.08),
                            highlightColor: Colors.black.withOpacity(0.06),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.facebookF, size: AppSizes.iconMd, color: AppColors.foreground),
                                  SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Continue with Facebook',
                                    style: TextStyle(color: AppColors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),

                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                              child: Text(
                                'Or log in with email',
                                style: TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: AppSizes.fontSm,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),
                        SizedBox(height: AppSizes.lg),

                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        SizedBox(height: AppSizes.xs),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
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
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Email is required';
                            if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: AppSizes.md),

                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        SizedBox(height: AppSizes.xs),
                        Obx(() => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword.value,
                          decoration: InputDecoration(
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
                        SizedBox(height: AppSizes.sm),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.to(() => ForgetPasswordScreen()),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: AppSizes.fontSm,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),

                        Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                        SizedBox(height: AppSizes.lg),

                        OutlinedButton(
                          onPressed: controller.navigateToHome,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 18, color: AppColors.foreground),
                              SizedBox(width: AppSizes.xs),
                              Text(
                                'Back to Order',
                                style: TextStyle(color: AppColors.foreground),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.mutedForeground),
                            ),
                            TextButton(
                              onPressed: () => Get.to(() => const SignupView(), binding: SignupBinding()),
                              child: Text(
                                'Sign up',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
