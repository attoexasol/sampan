import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../widgets/elevated_icon_button.dart';
import 'signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xffe3f1f0)
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Text(
                            'Create Your Account',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your details to get started with Sampan Laundry Service',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(height: 10.h),
                          Elevated_Icon_Button(
                            onTap: () {},
                            icon: Icon(FontAwesomeIcons.google, size: 20.r),
                            buttonName: "Continue with Google",
                          ),
                          SizedBox(height: 10.h),
                          Elevated_Icon_Button(
                            onTap: () {},
                            icon: Icon(FontAwesomeIcons.apple, size: 20.r),
                            buttonName: "Continue with Apple",
                          ),
                          SizedBox(height: 10.h),
                          Elevated_Icon_Button(
                            onTap: () {},
                            icon: Icon(FontAwesomeIcons.facebookF, size: 20.r),
                            buttonName: "Continue with Facebook",
                          ),
                          SizedBox(height: 10.h),
                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or sign up with email',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Personal Information
                          _buildSectionTitle(context, 'Personal Information'),

                              TextFormField(
                                controller: controller.firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller.lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),

                          const SizedBox(height: 24),

                          // Contact Information
                          _buildSectionTitle(context, 'Contact Information'),
                          TextFormField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (!GetUtils.isEmail(value!)) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),

                          // Security
                          _buildSectionTitle(context, 'Security'),
                              Obx(() => TextFormField(
                                controller: controller.passwordController,
                                obscureText: controller.obscurePassword.value,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  if (value!.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              )),
                              const SizedBox(height: 16),
                              Obx(() => TextFormField(
                                controller: controller.confirmPasswordController,
                                obscureText: controller.obscureConfirmPassword.value,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureConfirmPassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: controller.toggleConfirmPasswordVisibility,
                                  ),
                                ),
                                validator: controller.validateConfirmPassword,
                              )),

                          const SizedBox(height: 24),

                          // Address
                          _buildSectionTitle(context, 'Address'),
                          TextFormField(
                            controller: controller.streetController,
                            decoration: const InputDecoration(
                              labelText: 'Street Address',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                              TextFormField(
                                controller: controller.cityController,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller.stateController,
                                decoration: const InputDecoration(
                                  labelText: 'State',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller.zipCodeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'ZIP Code',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                              ),

                          const SizedBox(height: 24),

                          // Submit Button
                          Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Create Account'),
                          )),
                          const SizedBox(height: 12),

                          Elevated_Icon_Button(
                            onTap: controller.navigateToHome,
                            icon: Icon(FontAwesomeIcons.arrowLeft, size: 20.r),
                            buttonName: "Back to Order",
                          ),

                          const SizedBox(height: 16),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: controller.navigateToLogin,
                                child: const Text('Log in'),
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
      ),
    );
  }


  Widget _buildSocialButton(
      BuildContext context,
      String text,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
