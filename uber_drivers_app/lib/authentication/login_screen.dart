import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationProvider extends ChangeNotifier {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Image
  XFile? profilePhoto;

  // State
  bool isLoading = false;

  // ---------------- PICK PROFILE IMAGE ----------------
  Future<void> pickProfileImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      profilePhoto = pickedImage;
      notifyListeners();
    }
  }

  // ---------------- REGISTER WITH EMAIL ----------------
  Future<void> registerWithEmail(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String? photoUrl;
      if (profilePhoto != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("profile_photos")
            .child("${userCred.user!.uid}.jpg");
        await ref.putFile(File(profilePhoto!.path));
        photoUrl = await ref.getDownloadURL();
      }

      await _firestore.collection("drivers").doc(userCred.user!.uid).set({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "dob": dobController.text.trim(),
        "address": addressController.text.trim(),
        "profileImage": photoUrl ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- LOGIN WITH EMAIL ----------------
  Future<void> loginWithEmail(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _auth.signOut();
  }
}
