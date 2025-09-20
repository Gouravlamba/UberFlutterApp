import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_users_app/authentication/register_screen.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import '../authentication/otp_screen.dart';
import '../models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isGoogleSignedIn = false;
  bool _isGoogleSignInLoading = false;
  String? _uid;
  String? _phoneNumber;

  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber!;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isGoogleSignedIn => _isGoogleSignedIn;
  bool get isGoogleSigInLoading => _isGoogleSignInLoading;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  GoogleSignIn googleSignIn = GoogleSignIn();

  // -------------------- Loaders --------------------
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startGoogleLoading() {
    _isGoogleSignInLoading = true;
    notifyListeners();
  }

  void stopGoogleLoading() {
    _isGoogleSignInLoading = false;
    notifyListeners();
  }

  // -------------------- Phone Auth --------------------
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
          commonMethods.displaySnackBar(e.toString(), context);
          throw Exception(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          stopLoading();
          _phoneNumber = phoneNumber;
          notifyListeners();

          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(verificationId: verificationId),
              ),
            );
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stopLoading();
        },
      );
    } on FirebaseException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      User? user = (await firebaseAuth.signInWithCredential(
        phoneAuthCredential,
      )).user;

      if (user != null) {
        _uid = user.uid;
        notifyListeners();
        onSuccess();
      }

      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // -------------------- Email & Password Auth --------------------
  Future<void> signUpWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    startLoading();
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user != null) {
        _uid = user.uid;

        // Save user to Realtime Database
        DatabaseReference usersRef = firebaseDatabase
            .ref()
            .child("users")
            .child(user.uid);

        await usersRef.set({
          "id": user.uid,
          "name": "",
          "email": email,
          "phone": "",
          "blockStatus": "no",
        });

        notifyListeners();
        commonMethods.displaySnackBar("Account created successfully!", context);
      }
    } on FirebaseAuthException catch (e) {
      commonMethods.displaySnackBar(e.message ?? "Signup failed", context);
    } finally {
      stopLoading();
    }
  }

  Future<void> loginWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    startLoading();
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user != null) {
        _uid = user.uid;
        await getUserDataFromFirebaseDatabase();
        notifyListeners();
      }
      commonMethods.displaySnackBar("Logged in successfully!", context);
    } on FirebaseAuthException catch (e) {
      commonMethods.displaySnackBar(e.message ?? "Login failed", context);
    } finally {
      stopLoading();
    }
  }

  // -------------------- Save / Fetch User --------------------
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    try {
      DatabaseReference usersRef = firebaseDatabase
          .ref()
          .child("users")
          .child(userModel.id);
      await usersRef.set(userModel.toMap()).then((value) {
        stopLoading();
        onSuccess();
      });
    } on FirebaseException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      DatabaseReference usersRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        _userModel = UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'],
          blockStatus: userData['blockStatus'],
        );

        _uid = _userModel!.id;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // -------------------- Checks --------------------
  Future<bool> checkUserExistByEmail(String email) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("email")
        .equalTo(email)
        .once();
    return snapshot.snapshot.exists;
  }

  Future<bool> checkUserExistByPhone(String phoneNumber) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("phone")
        .equalTo(phoneNumber.toString().trim())
        .once();
    return snapshot.snapshot.exists;
  }

  Future<bool> checkUserExistById() async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("id")
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once();
    return snapshot.snapshot.exists;
  }

  Future<bool> checkIfUserIsBlocked() async {
    try {
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map driverData = snapshot.value as Map;

        String blockStatus = driverData["blockStatus"] ?? 'no';

        if (blockStatus == 'yes') {
          await firebaseAuth.signOut();
          await googleSignIn.signOut();

          _uid = null;
          _isGoogleSignedIn = false;
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking block status: $e");
      return false;
    }
  }

  Future<bool> checkUserFieldsFilled() async {
    try {
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map userData = snapshot.value as Map;

        String id = userData["id"] ?? '';
        String name = userData["name"] ?? '';
        String email = userData["email"] ?? '';
        String phone = userData["phone"] ?? '';

        return id.isNotEmpty &&
            name.isNotEmpty &&
            email.isNotEmpty &&
            phone.isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking user fields: $e");
      return false;
    }
  }

  // -------------------- Google Sign-In --------------------
  Future<void> signInWithGoogle(
    BuildContext context,
    VoidCallback onSuccess, {
    String? clientId,
  }) async {
    startGoogleLoading();

    try {
      if (clientId != null) {
        googleSignIn = GoogleSignIn(
          clientId: clientId,
          scopes: ['email', 'profile'],
        );
      } else {
        googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        stopGoogleLoading();
        return; // Cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        _uid = user.uid;
        _isGoogleSignedIn = true;
        notifyListeners();
      }

      onSuccess();
      stopGoogleLoading();
    } on FirebaseAuthException catch (e) {
      stopGoogleLoading();
      commonMethods.displaySnackBar(
        e.message ?? "Failed to sign in with Google",
        context,
      );
    }
  }

  // -------------------- Sign Out --------------------
  Future<void> signOut(BuildContext context) async {
    startLoading();
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();

      _uid = null;
      _isGoogleSignedIn = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
        (route) => false,
      );
      stopLoading();
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.message ?? "Failed to sign out", context);
    }
  }
}
