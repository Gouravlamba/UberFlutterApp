import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../methods/common_method.dart';
import '../models/driver.dart';
import '../pages/auth/register_screen.dart';
import '../pages/auth/otp_screen.dart';

class AuthenticationProvider extends ChangeNotifier {
  final CommonMethods commonMethods = CommonMethods();

  bool _isLoading = false;
  bool _isSuccessful = false;

  String? _uid;
  String? _phoneNumber;
  Driver? _driverModel;

  // Firebase instances
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  // ----------------- Getters -----------------
  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String get phoneNumber => _phoneNumber ?? '';
  String? get uid => _uid;
  Driver? get driverModel => _driverModel;

  // ----------------- Loading Helpers -----------------
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  // ----------------- Phone Sign-In -----------------
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    startLoading();
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
          stopLoading();
        },
        verificationFailed: (FirebaseAuthException e) {
          stopLoading();
          commonMethods.displaySnackBar(e.message ?? e.toString(), context);
        },
        codeSent: (String verificationId, int? resendToken) {
          stopLoading();
          _phoneNumber = phoneNumber;
          notifyListeners();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stopLoading();
        },
      );
    } catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final User? user =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (user != null) {
        _uid = user.uid;
        _isSuccessful = true;
        notifyListeners();
        onSuccess();
      }
    } on FirebaseException catch (e) {
      commonMethods.displaySnackBar(e.message ?? e.toString(), context);
    } finally {
      stopLoading();
    }
  }

  // ----------------- Email & Password Authentication -----------------
  Future<User?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _uid = userCredential.user!.uid;
        _isSuccessful = true;
        notifyListeners();
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Login failed: ${e.message}");
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }

  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _uid = userCredential.user!.uid;
        _isSuccessful = true;
        notifyListeners();
        return userCredential.user;
      }
    } catch (e) {
      debugPrint("Register failed: $e");
    }
    return null;
  }

  // ----------------- Driver Checks -----------------
  Future<bool> checkIfDriverIsBlocked() async {
    try {
      final driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);
      final snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final driverData = snapshot.value as Map;
        if (driverData["status"] == "blocked") {
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error checking block status: $e");
    }
    return false;
  }

  Future<bool> checkDriverFieldsFilled() async {
    try {
      final driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);
      final snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final driverData = snapshot.value as Map;

        // Check required fields
        if ((driverData["firstName"] ?? "").isNotEmpty &&
            (driverData["lastName"] ?? "").isNotEmpty &&
            (driverData["phone"] ?? "").isNotEmpty &&
            (driverData["carDetails"] ?? "").isNotEmpty) {
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error checking driver fields: $e");
    }
    return false;
  }

  // ----------------- Sign-Out -----------------
  Future<void> signOut(BuildContext context) async {
    startLoading();
    try {
      await firebaseAuth.signOut();
      _uid = null;
      _isSuccessful = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
        (route) => false,
      );
    } catch (e) {
      commonMethods.displaySnackBar("Sign out failed: $e", context);
    } finally {
      stopLoading();
    }
  }

  // ----------------- Firebase Database Helpers -----------------
  Future<void> saveUserDataToFirebase({
    required BuildContext context,
    required Driver driverModel,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    try {
      final usersRef =
          firebaseDatabase.ref().child("drivers").child(driverModel.id);
      await usersRef.set(driverModel.toMap());
      _driverModel = driverModel;
      _uid = driverModel.id;
      notifyListeners();
      onSuccess();
    } catch (e) {
      commonMethods.displaySnackBar("Error saving data: $e", context);
    } finally {
      stopLoading();
    }
  }

  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      final driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);
      final snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final driverData = snapshot.value as Map;
        _driverModel =
            Driver.fromMap(driverData); // Ensure Driver has fromMap()
        _uid = _driverModel!.id;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch user data: $e");
    }
  }
}
