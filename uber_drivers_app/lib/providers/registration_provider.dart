import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/global/global.dart';
import 'package:uber_drivers_app/methods/common_method.dart';

class RegistrationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ----------------- State Variables -----------------
  bool _isLoading = false;
  bool _isFetchLoading = false;
  XFile? _profilePhoto;
  bool _isPhotoAdded = false;

  bool _isFormValidBasic = false;
  bool _isFormValidCninc = false;
  bool _isFormValidDrivingLicense = false;
  bool _isVehicleBasicFormValid = false;

  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  XFile? _cnicWithSelfieImage;

  XFile? _drivingLicenseFrontImage;
  XFile? _drivingLicenseBackImage;

  XFile? _vehicleImage;
  XFile? _vehicleRegistrationFrontImage;
  XFile? _vehicleRegistrationBackImage;

  String? _selectedVehicle;

  final bool _isDataFetched = false;
  final double _driverEarnings = 0.0;
  Timer? _debounce;

  CommonMethods commonMethods = CommonMethods();

  // ----------------- Controllers -----------------
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController drivingLicenseController =
      TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController productionYearController =
      TextEditingController();

  final RegExp licenseRegExp = RegExp(r'^[A-Z]{2}-\d{2}-\d{4}$');

  // ----------------- Getters -----------------
  XFile? get profilePhoto => _profilePhoto;
  bool get isPhotoAdded => _isPhotoAdded;
  bool get isFormValidBasic => _isFormValidBasic;
  bool get isLoading => _isLoading;
  bool get isFetchLoading => _isFetchLoading;

  XFile? get cnincFrontImage => _cnicFrontImage;
  XFile? get cnincBackImage => _cnicBackImage;
  bool get isFormValidCninc => _isFormValidCninc;

  bool get isFormValidDrivingLicense => _isFormValidDrivingLicense;
  XFile? get cnicWithSelfieImage => _cnicWithSelfieImage;

  XFile? get drivingLicenseFrontImage => _drivingLicenseFrontImage;
  XFile? get drivingLicenseBackImage => _drivingLicenseBackImage;

  bool get isVehicleBasicFormValid => _isVehicleBasicFormValid;
  String? get selectedVehicle => _selectedVehicle;

  XFile? get vehicleImage => _vehicleImage;
  bool get isVehiclePhotoAdded => _vehicleImage != null;
  XFile? get vehicleRegistrationFrontImage => _vehicleRegistrationFrontImage;
  XFile? get vehicleRegistrationBackImage => _vehicleRegistrationBackImage;

  bool get isDataFetched => _isDataFetched;
  double get driverEarnings => _driverEarnings;

  // ----------------- Loading Helpers -----------------
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startFetchLoading() {
    _isFetchLoading = true;
    notifyListeners();
  }

  void stopFetchLoading() {
    _isFetchLoading = false;
    notifyListeners();
  }

  // ----------------- Form Validations -----------------
  void checkBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidBasic = firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          _profilePhoto != null;
      notifyListeners();
    });
  }

  void checkCNICFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidCninc = _cnicFrontImage != null &&
          _cnicBackImage != null &&
          cnicController.text.isNotEmpty &&
          cnicController.text.length == 13;
      notifyListeners();
    });
  }

  void checkDrivingLicenseFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidDrivingLicense = _drivingLicenseFrontImage != null &&
          _drivingLicenseBackImage != null &&
          drivingLicenseController.text.isNotEmpty &&
          licenseRegExp.hasMatch(drivingLicenseController.text);
      notifyListeners();
    });
  }

  void checkVehicleBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isVehicleBasicFormValid = _selectedVehicle != null &&
          brandController.text.isNotEmpty &&
          colorController.text.isNotEmpty &&
          numberPlateController.text.isNotEmpty &&
          productionYearController.text.isNotEmpty;
      notifyListeners();
    });
  }

  void setSelectedVehicle(String vehicle) {
    _selectedVehicle = vehicle;
    checkVehicleBasicFormValidity();
    notifyListeners();
  }

  // ----------------- Image Pickers -----------------
  Future<void> pickProfileImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _profilePhoto = image;
      _isPhotoAdded = true;
      checkBasicFormValidity();
      notifyListeners();
    }
  }

  // ----------------- Email Authentication -----------------
  Future<void> registerWithEmail(BuildContext context) async {
    if (!isFormValidBasic) {
      commonMethods.displaySnackBar("Fill all required fields!", context);
      return;
    }
    try {
      startLoading();
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user data to Firebase Database
      await saveUserData(userCredential.user, context);

      stopLoading();
      commonMethods.displaySnackBar("Registration successful!", context);
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.message ?? "Failed to register", context);
    }
  }

  Future<void> loginWithEmail(BuildContext context) async {
    try {
      startLoading();
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      stopLoading();
      commonMethods.displaySnackBar("Login successful!", context);
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.message ?? "Login failed", context);
    }
  }

  Future<void> saveUserData(User? user, BuildContext context) async {
    if (user == null) return;
    DatabaseReference usersRef =
        _database.ref().child("drivers").child(user.uid);

    Map driverDataMap = {
      "photo": _profilePhoto != null ? _profilePhoto!.path : "",
      "name":
          "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "dob": dobController.text.trim(),
      "address": addressController.text.trim(),
      "id": user.uid,
      "blockStatus": "no",
    };
    await usersRef.set(driverDataMap);
  }

  // ----------------- Dispose -----------------
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    cnicController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    drivingLicenseController.dispose();
    brandController.dispose();
    colorController.dispose();
    numberPlateController.dispose();
    productionYearController.dispose();
    super.dispose();
  }
}
