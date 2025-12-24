import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/custom_loading.dart';
import '../utils/ConsoleLog.dart';
import 'account_screen_controller.dart';

class EditProfileController extends GetxController {
  var nameController = TextEditingController().obs;
  var emailController = TextEditingController().obs;
  // final phoneController = TextEditingController();
  final AccountScreenController accountScreenController = Get.put(AccountScreenController());


  var isLoading = false.obs;
  var profileImage = Rx<File?>(null);
  var profileImageUrl = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      nameController.value.text = await AppSharedPreferences.getUserName() ?? '';
      emailController.value.text = await AppSharedPreferences.getEmail() ?? '';
      // phoneController.text = await AppSharedPreferences.getMobile() ?? '';
      // profileImageUrl.value = await AppSharedPreferences.getProfileImage() ?? '';
      // Load saved profile image path
      String? savedImagePath = await AppSharedPreferences.getProfileImage();
      if (savedImagePath != null && savedImagePath.isNotEmpty) {
        File imageFile = File(savedImagePath);
        if (await imageFile.exists()) {
          profileImage.value = imageFile;
          profileImageUrl.value = savedImagePath;
        }
      }

      ConsoleLog.printColor('Loaded profile image: $savedImagePath', color: 'cyan');
    } catch (e) {
      ConsoleLog.printError('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      // if (pickedFile != null) {
      //   profileImage.value = File(pickedFile.path);
      // }
      if (pickedFile != null) {
        // Copy image to permanent app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${appDir.path}/$fileName');

        // Copy the picked image to app directory
        await File(pickedFile.path).copy(savedImage.path);

        profileImage.value = savedImage;
        profileImageUrl.value = savedImage.path;
        ConsoleLog.printColor('Image saved to: ${savedImage.path}', color: 'green');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // void removeProfileImage() {
  //   profileImage.value = null;
  //   profileImageUrl.value = '';
  // }
  Future<void> removeProfileImage() async {
    try {
      // Delete the image file if it exists
      if (profileImage.value != null && await profileImage.value!.exists()) {
        await profileImage.value!.delete();
        ConsoleLog.printColor('Profile image file deleted', color: 'yellow');
      }

      profileImage.value = null;
      profileImageUrl.value = '';

      // Remove from SharedPreferences
      await AppSharedPreferences.removeProfileImage();

      // Update AccountScreenController
      accountScreenController.profileImagePath.value = '';

      Get.snackbar(
        'Success',
        'Profile image removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      ConsoleLog.printError('Error removing profile image: $e');
    }
  }

  // Future<void> updateProfile() async {
  //   if (nameController.text.trim().isEmpty) {
  //     Get.snackbar('Error', 'Please enter your name',
  //         snackPosition: SnackPosition.BOTTOM);
  //     return;
  //   }
  //
  //   if (emailController.text.trim().isNotEmpty) {
  //     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  //     if (!emailRegex.hasMatch(emailController.text.trim())) {
  //       Get.snackbar('Error', 'Please enter a valid email',
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //   }
  //
  //   // CustomLoading.show();
  //   CustomLoading().show(Get.context!);
  //   try {
  //     final userId = await AppSharedPreferences.getUserId();
  //
  //     Map<String, dynamic> params = {
  //       'user_id': userId,
  //       'name': nameController.text.trim(),
  //       'email': emailController.text.trim(),
  //     };
  //
  //     // If new image is selected, add it to params
  //     if (profileImage.value != null) {
  //       params['profile_image'] = profileImage.value;
  //     }
  //
  //     // final response = await ApiProvider().updateProfile(params);
  //     //
  //     // if (response['status'] == 'success' || response['status'] == true) {
  //       // Save updated data to SharedPreferences
  //       await AppSharedPreferences.setUserName(nameController.text.trim());
  //       await AppSharedPreferences.setEmail(emailController.text.trim());
  //
  //     //   if (response['data'] != null && response['data']['profile_image'] != null) {
  //     //     await AppSharedPreferences.setProfileImage(response['data']['profile_image']);
  //     //     profileImageUrl.value = response['data']['profile_image'];
  //     //   }
  //     //
  //     //   Get.back();
  //     //   Get.snackbar('Success', 'Profile updated successfully',
  //     //       snackPosition: SnackPosition.BOTTOM,
  //     //       backgroundColor: Colors.green,
  //     //       colorText: Colors.white);
  //     // } else {
  //     //   Get.snackbar('Error', response['message'] ?? 'Failed to update profile',
  //     //       snackPosition: SnackPosition.BOTTOM);
  //     // }
  //   } catch (e) {
  //     ConsoleLog.printError('Update profile error: $e');
  //     Get.snackbar('Error', 'Something went wrong. Please try again.',
  //         snackPosition: SnackPosition.BOTTOM);
  //   } finally {
  //     // CustomLoading.hide();
  //     CustomLoading().hide(Get.context!);
  //   }
  // }
  Future<void> updateProfile() async {
    if (nameController.value.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (emailController.value.text.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.value.text.trim())) {
        Get.snackbar('Error', 'Please enter a valid email',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    CustomLoading.showLoading();
    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // Save updated data to SharedPreferences (local storage)
      await AppSharedPreferences.setUserName(nameController.value.text.trim());
      await AppSharedPreferences.setEmail(emailController.value.text.trim());

      // Save profile image path
      if (profileImageUrl.value.isNotEmpty) {
        await AppSharedPreferences.setProfileImage(profileImageUrl.value);
        ConsoleLog.printColor('Profile image path saved: ${profileImageUrl.value}', color: 'green');
      }

      accountScreenController.name.value = nameController.value.text.trim();
      accountScreenController.email.value = emailController.value.text.trim();
      accountScreenController.profileImagePath.value = profileImageUrl.value;

      CustomLoading.hideLoading();
      // Show success message
      Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3)
      );

      ConsoleLog.printColor(
          'Profile updated - Name: ${nameController.value.text}, Email: ${emailController.value.text}, Image: ${profileImageUrl.value}',
          color: 'green'
      );
      // Get.back();
      Navigator.pop(Get.context!);
    } catch (e) {
      ConsoleLog.printError('Update profile error: $e');
      Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      CustomLoading.hideLoading();
    }
  }

  @override
  void onClose() {
    nameController.value.dispose();
    emailController.value.dispose();
    // phoneController.dispose();
    super.onClose();
  }
}