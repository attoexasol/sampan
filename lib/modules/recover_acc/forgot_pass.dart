import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/header_widget.dart';
import 'otp_screen.dart';


class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HeaderWidget(),
                const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Reset Password",
                          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold,),),
                        const SizedBox(height: 10),
                        const Text("6 digit OTP will be send to your email", style: TextStyle(color: Colors.black87, fontSize: 13,),),
                        const SizedBox(height: 20),

                        // Email Field
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(hintText: "your@email.com",),
                            validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              }
                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',);
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitButton(context),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
      ),

    );
  }

   _submitButton(BuildContext context) {
    Get.to(() => OtpScreen());
  }

}