import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/sp/sp_manager.dart';
import 'package:pingmexx/utils/widgethelper/validation_helper.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';
import '../data/repo/firestore_service.dart';
import '../data/bean/user/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final TextEditingController nameController = TextEditingController(text: "Mahi");
  final TextEditingController emailController = TextEditingController(text: "mahi@yopmail.com");
  final TextEditingController passwordController = TextEditingController(text: "123456789");
  final TextEditingController confirmPasswordController = TextEditingController(text: "123456789");

  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;
  RxString selectedGender = ''.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  RxString imageUploadProgress = ''.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Gender options
  final List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void onInit() {
    super.onInit();
    // checkAutoLogin();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Dispose controllers to prevent memory leaks
  void _disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Check if user is already logged in
  Future<void> checkAutoLogin() async {
    try {
      // Check if user is logged in via SharedPreferences
      bool isLoggedIn = await SPManager.isLoggedIn();
      
      if (isLoggedIn) {
        // Check if Firebase user is still authenticated
        User? firebaseUser = _auth.currentUser;
        
        if (firebaseUser != null) {
          // User is still authenticated, navigate to chat list
          UserModel? savedUser = await SPManager.getUserData();
          
          if (savedUser != null) {
            // _showWelcomeMessage(savedUser.name ?? 'User');
          } else {
            // Saved user data not found, fetch from Firestore
            await _fetchAndSaveUserData(firebaseUser.uid);
          }
        } else {
          // Firebase user not found, clear saved data
          await SPManager.clearUserData();
        }
      }
    } catch (e) {
      printLog(msg: 'Auto login check failed: $e');
    }
  }

  Future<void> _fetchAndSaveUserData(String uid) async {
    try {
      UserModel? user = await FirestoreService.getUserById(uid);
      if (user != null) {
        await SPManager.saveUserData(user);
        Get.offAllNamed(RoutersConst.home);
      } else {
        await SPManager.clearUserData();
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      await SPManager.clearUserData();
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Select gender
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        if (await _validateImageSize(image)) {
          _processSelectedImage(image);
          _showSuccessMessage('Image selected successfully');
        }
      }
    } catch (e) {
      print('Image picker error: $e');
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        if (await _validateImageSize(image)) {
          _processSelectedImage(image);
          _showSuccessMessage('Photo captured successfully');
        }
      }
    } catch (e) {
      print('Camera capture error: $e');
      _showErrorMessage('Failed to capture photo: $e');
    }
  }

  // Validate image size
  Future<bool> _validateImageSize(XFile image) async {
    final fileSize = await image.length();
    if (fileSize > 5 * 1024 * 1024) { // 5MB limit
      _showErrorMessage('Image size too large. Please select an image smaller than 5MB.');
      return false;
    }
    return true;
  }

  // Process selected image
  Future<void> _processSelectedImage(XFile image) async {
    if (kIsWeb) {
      // For web, use bytes
      selectedImageBytes.value = await image.readAsBytes();
      selectedImage.value = null;
      print('Web image bytes length: ${selectedImageBytes.value?.length}');
    } else {
      // For mobile, use File
      selectedImage.value = File(image.path);
      selectedImageBytes.value = null;
      print('Mobile image path: ${selectedImage.value?.path}');
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    getSnackBar(
      title: 'Success',
      subTitle: message,
      isSuccess: true,
    );
  }

  // Show error message
  void _showErrorMessage(String message) {
    getSnackBar(
      title: 'Error',
      subTitle: message,
      isSuccess: false,
    );
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF202C33),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImageFromCamera();
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImageFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build image picker option widget
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImageToStorage(String userId) async {
    if (selectedImage.value == null && selectedImageBytes.value == null) return null;

    try {
      imageUploadProgress.value = 'Uploading image...';
      
      // Create reference to Firebase Storage
      String fileName = 'profile_images/$userId.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      
      // Set metadata for the image
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': userId,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      // Upload file or bytes
      UploadTask uploadTask;
      if (kIsWeb && selectedImageBytes.value != null) {
        uploadTask = storageRef.putData(selectedImageBytes.value!, metadata);
      } else if (selectedImage.value != null) {
        uploadTask = storageRef.putFile(selectedImage.value!, metadata);
      } else {
        throw Exception('No image data available');
      }

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        imageUploadProgress.value = 'Uploading... ${progress.toStringAsFixed(1)}%';
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      imageUploadProgress.value = '';
      return downloadURL;
    } catch (e) {
      imageUploadProgress.value = '';
      throw Exception('Failed to upload image: $e');
    }
  }

  // Validate form and registration requirements
  bool _validateRegistrationForm() {
    if (!formKey.currentState!.validate()) return false;
    
    if (selectedGender.value.isEmpty) {
      _showErrorMessage('Please select your gender');
      return false;
    }
    return true;
  }

  // Register user with email and password
  Future<void> registerUser() async {
    if (!_validateRegistrationForm()) return;

    try {
      isLoading.value = true;
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user account');
      }

      // Upload profile image if selected
      String? profileImageUrl;
      if (selectedImage.value != null || selectedImageBytes.value != null) {
        profileImageUrl = await uploadImageToStorage(firebaseUser.uid);
      }

      // Update Firebase Auth profile
      await _updateFirebaseProfile(firebaseUser, profileImageUrl);

      // Create and save user model
      UserModel userModel = _createUserModel(firebaseUser, profileImageUrl);
      await FirestoreService.createUser(userModel);
      await SPManager.saveUserData(userModel);

      // Send email verification
      await firebaseUser.sendEmailVerification();

      _showSuccessMessage('Account created successfully! Please verify your email.');

      // Clear form and navigate
      clearForm();
      Get.offAllNamed(RoutersConst.home);

    } on FirebaseAuthException catch (e) {
      _showErrorMessage(_getFirebaseErrorMessage(e.code));
    } on FirebaseException catch (e) {
      _showErrorMessage('Firebase service error: ${e.message}');
    } catch (e) {
      _showErrorMessage('An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update Firebase Auth profile
  Future<void> _updateFirebaseProfile(User firebaseUser, String? profileImageUrl) async {
    await firebaseUser.updateDisplayName(nameController.text.trim());
    if (profileImageUrl != null) {
      await firebaseUser.updatePhotoURL(profileImageUrl);
    }
  }

  // Create user model for registration
  UserModel _createUserModel(User firebaseUser, String? profileImageUrl) {
    return UserModel(
      uid: firebaseUser.uid,
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      profileImage: profileImageUrl,
      gender: selectedGender.value,
      bio: 'Hey there! I am using PingMeXX',
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  // Get user-friendly error messages
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred during registration.';
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedGender.value = '';
    selectedImage.value = null;
    selectedImageBytes.value = null;
    imageUploadProgress.value = '';
  }

  // Form validation methods using ValidationHelper
  String? validateName(String? value) => ValidationHelper.validateName(value);

  String? validateEmail(String? value) => ValidationHelper.validateEmail(value);

  String? validatePassword(String? value) => ValidationHelper.validateSimplePassword(value);

  String? validateConfirmPassword(String? value) => 
      ValidationHelper.validateConfirmPassword(value, passwordController.text);

  // Logout user
  Future<void> logoutUser() async {
    try {
      isLoading.value = true;

      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear all shared preferences
      await SPManager.clearUserData();

      // Clear form data
      clearForm();

      print('User logged out successfully');
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Failed to logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}