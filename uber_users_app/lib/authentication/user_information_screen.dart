import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/home_page.dart';
import '../models/user_model.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  CommonMethods commonMethods = CommonMethods();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    gmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );

    final currentUser = authProvider.firebaseAuth.currentUser;

    // Phone Login
    if (!authProvider.isGoogleSignedIn && currentUser?.phoneNumber != null) {
      phoneController.text = authProvider.phoneNumber;
      gmailController.text = '';
    }
    // Google Login
    else if (authProvider.isGoogleSignedIn) {
      gmailController.text = currentUser?.email ?? '';
      phoneController.text = '';
    }
    // Email/Password Login
    else if (currentUser != null && currentUser.email != null) {
      gmailController.text = currentUser.email!;
      phoneController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile Setup', style: TextStyle()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25.0,
                horizontal: 35,
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      // Name
                      myTextFormField(
                        hintText: 'Enter Your Full Name',
                        icon: Icons.account_circle,
                        textInputType: TextInputType.name,
                        maxLines: 1,
                        maxLength: 25,
                        textEditingController: nameController,
                        enabled: true,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      myTextFormField(
                        hintText: 'Enter Your Email Address',
                        icon: Icons.email,
                        textInputType: TextInputType.emailAddress,
                        maxLines: 1,
                        maxLength: 40,
                        textEditingController: gmailController,
                        enabled:
                            (authProvider.isGoogleSignedIn ||
                                gmailController.text.isNotEmpty)
                            ? false
                            : true,
                      ),
                      const SizedBox(height: 20),

                      // Phone
                      myTextFormField(
                        hintText: 'Enter your phone number',
                        icon: Icons.phone,
                        textInputType: TextInputType.number,
                        maxLines: 1,
                        maxLength: 13,
                        textEditingController: phoneController,
                        enabled:
                            (!authProvider.isGoogleSignedIn &&
                                phoneController.text.isNotEmpty)
                            ? false
                            : true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Continue Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : saveUserDataToFireStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myTextFormField({
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    required int maxLines,
    required int maxLength,
    required TextEditingController textEditingController,
    required bool enabled,
  }) {
    return TextFormField(
      enabled: enabled,
      cursorColor: Colors.grey,
      controller: textEditingController,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.black,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        hintText: hintText,
        alignLabelWithHint: true,
        border: InputBorder.none,
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  // Store user data to Realtime Database
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (nameController.text.trim().length < 3) {
      commonMethods.displaySnackBar(
        'Name must be at least 3 characters',
        context,
      );
      return;
    }
    if (gmailController.text.trim().isEmpty ||
        !gmailController.text.contains("@")) {
      commonMethods.displaySnackBar('Enter a valid email address', context);
      return;
    }

    UserModel userModel = UserModel(
      id: authProvider.uid!,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: gmailController.text.trim(),
      blockStatus: "no",
    );

    authProvider.saveUserDataToFirebase(
      context: context,
      userModel: userModel,
      onSuccess: () async {
        navigateToHomeScreen();
      },
    );
  }

  void navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }
}
