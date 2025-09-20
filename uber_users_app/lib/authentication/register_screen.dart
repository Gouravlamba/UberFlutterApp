import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/user_information_screen.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/blocked_screen.dart';
import 'package:uber_users_app/pages/home_page.dart';

const String googleWebClientId =
    '1008573484807-n42blu1ngrc3i2ra2nofg2sjcbuan4fd.apps.googleusercontent.com';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  bool useEmailAuth = false; // Toggle between Phone <-> Email login/signup
  bool isLoginMode = true; // Toggle Login <-> Signup when using Email

  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'IN',
    e164Key: '',
  );

  CommonMethods commonMethods = CommonMethods();

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                useEmailAuth
                    ? (isLoginMode ? "Login with Email" : "Sign Up with Email")
                    : "Enter Your Mobile Number",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // ========== Email Auth Form ==========
              if (useEmailAuth)
                Form(
                  key: _emailFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val != null && val.contains("@")
                            ? null
                            : "Enter valid email",
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val != null && val.length >= 6
                            ? null
                            : "Password must be 6+ chars",
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  if (_emailFormKey.currentState!.validate()) {
                                    if (isLoginMode) {
                                      authProvider.loginWithEmail(
                                        context,
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                                    } else {
                                      authProvider.signUpWithEmail(
                                        context,
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                                    }
                                  }
                                },
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isLoginMode ? "Login" : "Sign Up",
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => isLoginMode = !isLoginMode);
                        },
                        child: Text(
                          isLoginMode
                              ? "Don’t have an account? Sign Up"
                              : "Already have an account? Login",
                        ),
                      ),
                    ],
                  ),
                )
              // ========== Phone Auth Form ==========
              else
                Column(
                  children: [
                    TextFormField(
                      controller: phoneController,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '9876543210',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        prefixIcon: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                borderRadius: BorderRadius.zero,
                                bottomSheetHeight: 400,
                              ),
                              onSelect: (value) {
                                setState(() => selectedCountry = value);
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Text(
                              ' +${selectedCountry.phoneCode}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        suffixIcon: phoneController.text.length > 9
                            ? Container(
                                height: 20,
                                width: 20,
                                margin: const EdgeInsets.all(10.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : sendPhoneNumber,
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
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Or",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 15),

              /// Google Sign-In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isGoogleSigInLoading
                      ? null
                      : () async {
                          try {
                            await authProvider.signInWithGoogle(
                              context,
                              () async {
                                bool userExits = await authProvider
                                    .checkUserExistById();
                                bool userExistInDatabase = await authProvider
                                    .checkUserExistByEmail(
                                      authProvider
                                              .firebaseAuth
                                              .currentUser
                                              ?.email ??
                                          "",
                                    );

                                if (userExits && userExistInDatabase) {
                                  bool isBlocked = await authProvider
                                      .checkIfUserIsBlocked();
                                  if (isBlocked) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BlockedScreen(),
                                      ),
                                    );
                                  } else {
                                    await authProvider
                                        .getUserDataFromFirebaseDatabase();
                                    navigate(isSingedIn: true);
                                  }
                                } else {
                                  navigate(isSingedIn: false);
                                }
                              },
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Google Sign-In failed: $e"),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: authProvider.isGoogleSigInLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.g_mobiledata,
                              color: Colors.black,
                              size: 28,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Continue with Google",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 15),
              // Switch between Phone <-> Email
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() => useEmailAuth = !useEmailAuth);
                  },
                  child: Text(
                    useEmailAuth
                        ? "Use Phone Number Instead"
                        : "Use Email Instead",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                "By proceeding, you consent to get calls, WhatsApp or SMS messages, including by automated means, from Uber and its affiliates to the number provided.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final authRepo = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    String phoneNumber = phoneController.text.trim();

    if (phoneNumber.isEmpty ||
        phoneNumber.length != 10 ||
        !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phoneNumber)) {
      commonMethods.displaySnackBar(
        "Please enter a valid mobile number.",
        context,
      );
      return;
    }

    String fullPhoneNumber = '+${selectedCountry.phoneCode}$phoneNumber';
    authRepo.signInWithPhone(context: context, phoneNumber: fullPhoneNumber);
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserInformationScreen()),
      );
    }
  }
}
