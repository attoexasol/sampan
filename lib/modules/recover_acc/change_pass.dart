import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../widgets/header_widget.dart';


class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _conPassController = TextEditingController();

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
                      const Text("Change Password",
                      style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold,),),
                    const SizedBox(height: 20),

                    // Password
                    TextFormField(
                      controller: _newPassController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "New Password",
                      ),
                    ),
                    const SizedBox(height: 10),
                        TextFormField(
                      controller: _conPassController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
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
          ]
      ),
      ),

    ),

    );
  }

  void _submitButton(BuildContext context) {
   // Navigator.pushNamed(context, OTP_page.name);
  }

}