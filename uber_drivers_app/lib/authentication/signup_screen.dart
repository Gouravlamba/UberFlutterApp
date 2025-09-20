import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';
import 'package:uber_drivers_app/widgets/blocked_screen.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: Scaffold(
        body: Consumer<RegistrationProvider>(
          builder: (context, regProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Profile Image
                  GestureDetector(
                    onTap: () => regProvider.pickProfileImageFromGallery(),
                    child: CircleAvatar(
                      radius: 86,
                      backgroundImage: regProvider.profilePhoto != null
                          ? FileImage(File(regProvider.profilePhoto!.path))
                          : const AssetImage("assets/images/avatarman.png")
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Choose Profile Image",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // TextFields
                  _buildTextField(
                      "First Name", regProvider.firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField("Last Name", regProvider.lastNameController),
                  const SizedBox(height: 12),
                  _buildTextField("Email", regProvider.emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildTextField("Password", regProvider.passwordController,
                      obscureText: true),
                  const SizedBox(height: 12),
                  _buildTextField("Phone", regProvider.phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField("Date of Birth", regProvider.dobController),
                  const SizedBox(height: 12),
                  _buildTextField("Address", regProvider.addressController),

                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: regProvider.isLoading
                        ? null
                        : () async {
                            await regProvider.registerWithEmail(context);

                            if (!regProvider.isLoading) {
                              // After registration, check driver status
                              final authProvider =
                                  Provider.of<AuthenticationProvider>(context,
                                      listen: false);

                              bool isBlocked =
                                  await authProvider.checkIfDriverIsBlocked();
                              if (isBlocked) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const BlockedScreen()),
                                );
                                return;
                              }

                              bool isProfileComplete =
                                  await authProvider.checkDriverFieldsFilled();
                              if (isProfileComplete) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Dashboard()),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 12),
                    ),
                    child: regProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up"),
                  ),

                  const SizedBox(height: 12),

                  // Login TextButton
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Already have an account? Login Here",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------- Helper -----------------
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(color: Colors.grey, fontSize: 15),
    );
  }
}
