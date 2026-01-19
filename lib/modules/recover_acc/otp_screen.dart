import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../widgets/header_widget.dart';
import 'change_pass.dart';


class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpTEcontroller = TextEditingController();

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
                        const Text("OTP Screen",
                          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold,),),
                        const SizedBox(height: 5),
                        const Text("6 digit OTP has send to your email", style: TextStyle(color: Colors.black87, fontSize: 13,),),
                        const SizedBox(height: 20),

                        // Email Field
                        PinCodeTextField(
                          length: 6,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: Colors.white,
                              selectedColor: Color(0xff17b797),
                              inactiveColor: Colors.grey
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          controller: _otpTEcontroller,
                          appContext: context,
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
    Get.to(() => ChangePassword());
  }

}