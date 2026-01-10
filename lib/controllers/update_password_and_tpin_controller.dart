import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/CustomDialog.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';

/// ============================================
/// UPDATE PASSWORD AND TPIN CONTROLLER
/// ============================================
/// Handles password and TPIN update functionality
/// Following the same patterns as ProfileController
/// ============================================

class UpdatePasswordAndTpinController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();

  // ============== Text Controllers ==============
  // Password Controllers
  Rx<TextEditingController> oldPasswordController = TextEditingController(text: "").obs;
  Rx<TextEditingController> newPasswordController = TextEditingController(text: "").obs;
  Rx<TextEditingController> confirmPasswordController = TextEditingController(text: "").obs;

  // TPIN Controllers
  Rx<TextEditingController> oldPinController = TextEditingController(text: "").obs;
  Rx<TextEditingController> newPinController = TextEditingController(text: "").obs;
  Rx<TextEditingController> confirmPinController = TextEditingController(text: "").obs;

  // ============== Observable Variables ==============
  // Password Visibility
  RxBool obscureOldPassword = true.obs;
  RxBool obscureNewPassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;

  // TPIN Visibility
  RxBool obscureOldPin = true.obs;
  RxBool obscureNewPin = true.obs;
  RxBool obscureConfirmPin = true.obs;

  // TPIN Status
  RxBool isPinEnabled = false.obs;

  // Reference ID for OTP verification
  String pinStatusReferenceId = '';
  Map<String, dynamic>? changePinStatusObject;

  // Loading States
  RxBool isUpdatingPassword = false.obs;
  RxBool isUpdatingPin = false.obs;
  RxBool isResettingPin = false.obs;
  RxBool isChangingPinStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    ConsoleLog.printColor("========== UpdatePasswordAndTpinController onInit CALLED ==========", color: "green");
    // Load TPIN status from profile if needed
    loadPinStatus();
  }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  //region loadPinStatus
  /// Load TPIN status from user profile (from cache)
  /// Public method so it can be called from screen
  Future<void> loadPinStatus() async {
    try {
      // Try to get from stored user data
      String userDataJson = await AppSharedPreferences().getString('userData');
      if (userDataJson.isNotEmpty) {
        Map<String, dynamic> userData = jsonDecode(userDataJson);
        isPinEnabled.value = userData['txnpin_status'] == '1' || userData['txnpin_status'] == 1;
        ConsoleLog.printInfo("TPIN Status loaded from cache: ${isPinEnabled.value}");
      }
    } catch (e) {
      ConsoleLog.printError("Error loading TPIN status: $e");
    }
  }
  //endregion

  //region _refreshProfileData
  /// Refresh profile data from API to sync PIN status
  Future<void> _refreshProfileData() async {
    try {
      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        ConsoleLog.printWarning("Token invalid, skipping profile refresh");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_PROFILE_DATA,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          Map<String, dynamic> userData = result['data'];
          
          // Update PIN status from fresh API response
          isPinEnabled.value = userData['txnpin_status'] == '1' || userData['txnpin_status'] == 1;
          
          // Save updated user data to preferences
          await AppSharedPreferences().setString(
            'userData',
            jsonEncode(userData),
          );
          
          ConsoleLog.printInfo("Profile data refreshed. TPIN Status: ${isPinEnabled.value}");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error refreshing profile data: $e");
      // If refresh fails, just load from cache
      await loadPinStatus();
    }
  }
  //endregion

  //region updatePassword
  /// Update user password
  Future<void> updatePassword() async {
    try {
      // Validation
      String oldPassword = oldPasswordController.value.text.trim();
      String newPassword = newPasswordController.value.text.trim();
      String confirmPassword = confirmPasswordController.value.text.trim();

      if (oldPassword.isEmpty) {
        CustomDialog.error(message: "Please enter old password");
        return;
      }

      if (newPassword.isEmpty) {
        CustomDialog.error(message: "Please enter new password");
        return;
      }

      if (newPassword.length < 6) {
        CustomDialog.error(message: "Password must be at least 6 characters long");
        return;
      }

      if (confirmPassword.isEmpty) {
        CustomDialog.error(message: "Please confirm new password");
        return;
      }

      if (newPassword != confirmPassword) {
        CustomDialog.error(message: "New password and confirm password do not match");
        return;
      }

      if (oldPassword == newPassword) {
        CustomDialog.error(message: "New password must be different from old password");
        return;
      }

      // Check Internet Connection
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      // Check if already updating
      if (isUpdatingPassword.value) {
        ConsoleLog.printWarning("Password update already in progress");
        return;
      }

      isUpdatingPassword.value = true;
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        isUpdatingPassword.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("UPDATE PASSWORD REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      // Make API call
      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_UPDATE_PASSWORD,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();
      isUpdatingPassword.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("UPDATE PASSWORD RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          // Success
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Password updated successfully',
            onContinue: () {
              Get.back();
              clearPasswordFields();
            },
          );
        } else if (result['Resp_code'] == 'VRF') {
          // OTP verification required
          String referenceId = result['data']?['referenceid'] ?? '';
          if (referenceId.isNotEmpty) {
            _showOtpDialogForPassword(referenceId, requestBody);
          } else {
            CustomDialog.error(
              message: result['Resp_desc'] ?? 'OTP verification required but reference ID not found',
            );
          }
        } else {
          // Error
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Failed to update password',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to update password. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      isUpdatingPassword.value = false;
      ConsoleLog.printError('Error in updatePassword: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region updatePin
  /// Update Transaction PIN (TPIN)
  Future<void> updatePin() async {
    try {
      // Validation
      String oldPin = oldPinController.value.text.trim();
      String newPin = newPinController.value.text.trim();
      String confirmPin = confirmPinController.value.text.trim();

      if (oldPin.isEmpty) {
        CustomDialog.error(message: "Please enter old PIN");
        return;
      }

      if (oldPin.length != 4) {
        CustomDialog.error(message: "Old PIN must be 4 digits");
        return;
      }

      if (newPin.isEmpty) {
        CustomDialog.error(message: "Please enter new PIN");
        return;
      }

      if (newPin.length != 4) {
        CustomDialog.error(message: "New PIN must be 4 digits");
        return;
      }

      if (confirmPin.isEmpty) {
        CustomDialog.error(message: "Please confirm new PIN");
        return;
      }

      if (newPin != confirmPin) {
        CustomDialog.error(message: "New PIN and confirm PIN do not match");
        return;
      }

      if (oldPin == newPin) {
        CustomDialog.error(message: "New PIN must be different from old PIN");
        return;
      }

      // Check Internet Connection
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      // Check if already updating
      if (isUpdatingPin.value) {
        ConsoleLog.printWarning("PIN update already in progress");
        return;
      }

      isUpdatingPin.value = true;
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        isUpdatingPin.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'old_tpin': oldPin,
        'new_tpin': newPin,
        'confirm_tpin': confirmPin,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("UPDATE TPIN REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      // Make API call
      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_UPDATE_TPIN,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();
      isUpdatingPin.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("UPDATE TPIN RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          // Success
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Transaction PIN updated successfully',
            onContinue: () {
              Get.back();
              clearPinFields();
            },
          );
        } else if (result['Resp_code'] == 'VRF') {
          // OTP verification required
          String referenceId = result['data']?['referenceid'] ?? '';
          if (referenceId.isNotEmpty) {
            _showOtpDialogForPin(referenceId, requestBody);
          } else {
            CustomDialog.error(
              message: result['Resp_desc'] ?? 'OTP verification required but reference ID not found',
            );
          }
        } else {
          // Error
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Failed to update Transaction PIN',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to update Transaction PIN. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      isUpdatingPin.value = false;
      ConsoleLog.printError('Error in updatePin: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region resetPin
  /// Reset Transaction PIN (TPIN) - Forgot PIN scenario
  Future<void> resetPin() async {
    try {
      // Validation
      String newPin = newPinController.value.text.trim();
      String confirmPin = confirmPinController.value.text.trim();

      if (newPin.isEmpty) {
        CustomDialog.error(message: "Please enter new PIN");
        return;
      }

      if (newPin.length != 4) {
        CustomDialog.error(message: "PIN must be 4 digits");
        return;
      }

      if (confirmPin.isEmpty) {
        CustomDialog.error(message: "Please confirm new PIN");
        return;
      }

      if (newPin != confirmPin) {
        CustomDialog.error(message: "New PIN and confirm PIN do not match");
        return;
      }

      // Check Internet Connection
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      // Check if already resetting
      if (isResettingPin.value) {
        ConsoleLog.printWarning("PIN reset already in progress");
        return;
      }

      isResettingPin.value = true;
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        isResettingPin.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'new_tpin': newPin,
        'confirm_tpin': confirmPin,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("RESET TPIN REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      // Make API call
      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_RESET_TPIN,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();
      isResettingPin.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("RESET TPIN RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          // Success
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Transaction PIN reset successfully',
            onContinue: () {
              Get.back();
              clearPinFields();
            },
          );
        } else if (result['Resp_code'] == 'VRF') {
          // OTP verification required
          String referenceId = result['data']?['referenceid'] ?? '';
          if (referenceId.isNotEmpty) {
            _showOtpDialogForResetPin(referenceId, requestBody);
          } else {
            CustomDialog.error(
              message: result['Resp_desc'] ?? 'OTP verification required but reference ID not found',
            );
          }
        } else {
          // Error
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Failed to reset Transaction PIN',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to reset Transaction PIN. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      isResettingPin.value = false;
      ConsoleLog.printError('Error in resetPin: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region _showOtpDialogForPassword
  /// Show OTP dialog for password update verification
  void _showOtpDialogForPassword(String referenceId, Map<String, dynamic> requestBody) {
    final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            width: Get.width - 50,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Verify OTP',
                  style: GoogleFonts.albertSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Enter OTP to update your password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: const Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OTP Input Fields
                SizedBox(
                  width: double.infinity,
                  child: OtpInputFields(
                    key: _otpKey,
                    length: 6,
                    onCompleted: (otp) {
                      // Auto verify when all 6 digits are entered
                      Get.back();
                      _verifyOtpForPassword(otp, referenceId, requestBody);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Cancel',
                        onPressed: () {
                          Get.back();
                          clearPasswordFields();
                        },
                        buttonType: ButtonType.outlined,
                        borderColor: const Color(0xFF0054D3),
                        borderRadius: 12,
                        textColor: const Color(0xFF0054D3),
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0054D3),
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Verify',
                        onPressed: () {
                          final otp = _otpKey.currentState?.currentOtp ?? '';
                          if (otp.length == 6) {
                            Get.back();
                            _verifyOtpForPassword(otp, referenceId, requestBody);
                          } else {
                            CustomDialog.error(message: 'Please enter 6-digit OTP');
                          }
                        },
                        backgroundGradient: GlobalUtils.blueBtnGradientColor,
                        borderColor: const Color(0xFF71A9FF),
                        borderRadius: 12,
                        textColor: Colors.white,
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  //endregion

  //region _showOtpDialogForPin
  /// Show OTP dialog for PIN update verification
  void _showOtpDialogForPin(String referenceId, Map<String, dynamic> requestBody) {
    final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            width: Get.width - 50,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Verify OTP',
                  style: GoogleFonts.albertSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Enter OTP to update your Transaction PIN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: const Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OTP Input Fields
                SizedBox(
                  width: double.infinity,
                  child: OtpInputFields(
                    key: _otpKey,
                    length: 6,
                    onCompleted: (otp) {
                      // Auto verify when all 6 digits are entered
                      Get.back();
                      _verifyOtpForPin(otp, referenceId, requestBody);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Cancel',
                        onPressed: () {
                          Get.back();
                          clearPinFields();
                        },
                        buttonType: ButtonType.outlined,
                        borderColor: const Color(0xFF0054D3),
                        borderRadius: 12,
                        textColor: const Color(0xFF0054D3),
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0054D3),
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Verify',
                        onPressed: () {
                          final otp = _otpKey.currentState?.currentOtp ?? '';
                          if (otp.length == 6) {
                            Get.back();
                            _verifyOtpForPin(otp, referenceId, requestBody);
                          } else {
                            CustomDialog.error(message: 'Please enter 6-digit OTP');
                          }
                        },
                        backgroundGradient: GlobalUtils.blueBtnGradientColor,
                        borderColor: const Color(0xFF71A9FF),
                        borderRadius: 12,
                        textColor: Colors.white,
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  //endregion

  //region _showOtpDialogForResetPin
  /// Show OTP dialog for PIN reset verification
  void _showOtpDialogForResetPin(String referenceId, Map<String, dynamic> requestBody) {
    final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            width: Get.width - 50,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Verify OTP',
                  style: GoogleFonts.albertSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Enter OTP to reset your Transaction PIN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: const Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OTP Input Fields
                SizedBox(
                  width: double.infinity,
                  child: OtpInputFields(
                    key: _otpKey,
                    length: 6,
                    onCompleted: (otp) {
                      // Auto verify when all 6 digits are entered
                      Get.back();
                      _verifyOtpForResetPin(otp, referenceId, requestBody);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Cancel',
                        onPressed: () {
                          Get.back();
                          clearPinFields();
                        },
                        buttonType: ButtonType.outlined,
                        borderColor: const Color(0xFF0054D3),
                        borderRadius: 12,
                        textColor: const Color(0xFF0054D3),
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0054D3),
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: 'Verify',
                        onPressed: () {
                          final otp = _otpKey.currentState?.currentOtp ?? '';
                          if (otp.length == 6) {
                            Get.back();
                            _verifyOtpForResetPin(otp, referenceId, requestBody);
                          } else {
                            CustomDialog.error(message: 'Please enter 6-digit OTP');
                          }
                        },
                        backgroundGradient: GlobalUtils.blueBtnGradientColor,
                        borderColor: const Color(0xFF71A9FF),
                        borderRadius: 12,
                        textColor: Colors.white,
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        height: GlobalUtils.screenWidth * (50 / 393),
                        showShadow: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  //endregion

  //region _verifyOtpForPassword
  /// Verify OTP for password update
  Future<void> _verifyOtpForPassword(String otp, String referenceId, Map<String, dynamic> requestBody) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        CustomDialog.error(message: 'Please enter valid 6-digit OTP');
        return;
      }

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      Map<String, dynamic> verifyRequestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VERIFY',
        'referenceid': referenceId,
        'otp': otp,
        'old_password': requestBody['old_password'],
        'new_password': requestBody['new_password'],
        'confirm_password': requestBody['confirm_password'],
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_UPDATE_PASSWORD,
        verifyRequestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS') {
          Get.back(); // Close OTP dialog
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Password updated successfully',
            onContinue: () {
              Get.back();
              clearPasswordFields();
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'OTP verification failed',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to verify OTP');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in _verifyOtpForPassword: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region _verifyOtpForPin
  /// Verify OTP for PIN update
  Future<void> _verifyOtpForPin(String otp, String referenceId, Map<String, dynamic> requestBody) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        CustomDialog.error(message: 'Please enter valid 6-digit OTP');
        return;
      }

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      Map<String, dynamic> verifyRequestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VERIFY',
        'referenceid': referenceId,
        'otp': otp,
        'old_tpin': requestBody['old_tpin'],
        'new_tpin': requestBody['new_tpin'],
        'confirm_tpin': requestBody['confirm_tpin'],
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_UPDATE_TPIN,
        verifyRequestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS') {
          Get.back(); // Close OTP dialog
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Transaction PIN updated successfully',
            onContinue: () {
              Get.back();
              clearPinFields();
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'OTP verification failed',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to verify OTP');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in _verifyOtpForPin: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region _verifyOtpForResetPin
  /// Verify OTP for PIN reset
  Future<void> _verifyOtpForResetPin(String otp, String referenceId, Map<String, dynamic> requestBody) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        CustomDialog.error(message: 'Please enter valid 6-digit OTP');
        return;
      }

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      Map<String, dynamic> verifyRequestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VERIFY',
        'referenceid': referenceId,
        'otp': otp,
        'new_tpin': requestBody['new_tpin'],
        'confirm_tpin': requestBody['confirm_tpin'],
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_RESET_TPIN,
        verifyRequestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS') {
          Get.back(); // Close OTP dialog
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Transaction PIN reset successfully',
            onContinue: () {
              Get.back();
              clearPinFields();
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'OTP verification failed',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to verify OTP');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in _verifyOtpForResetPin: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region clearPasswordFields
  /// Clear all password fields
  void clearPasswordFields() {
    oldPasswordController.value.clear();
    newPasswordController.value.clear();
    confirmPasswordController.value.clear();
    obscureOldPassword.value = true;
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;
  }
  //endregion

  //region clearPinFields
  /// Clear all PIN fields
  void clearPinFields() {
    oldPinController.value.clear();
    newPinController.value.clear();
    confirmPinController.value.clear();
    obscureOldPin.value = true;
    obscureNewPin.value = true;
    obscureConfirmPin.value = true;
  }
  //endregion

  //region changePinStatus
  /// Change Transaction PIN status (toggle ON/OFF)
  /// Similar to Profile Controller's changeWalletOtpStatus
  Future<void> changePinStatus(bool newValue) async {
    try {
      // If turning ON, directly update (usually no OTP required for ON)
      // If turning OFF, OTP verification required
      
      // Check if already changing
      if (isChangingPinStatus.value) {
        ConsoleLog.printWarning("PIN status change already in progress");
        return;
      }

      isChangingPinStatus.value = true;
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        isChangingPinStatus.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        isPinEnabled.value = !newValue; // Revert toggle
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VALIDATE',
        'txnpin_status': newValue ? 'true' : 'false',
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("CHANGE PIN STATUS REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_CHANGE_TXN_PIN_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();
      isChangingPinStatus.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("CHANGE PIN STATUS RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'VRF') {
          // OTP verification required (usually when turning OFF)
          changePinStatusObject = requestBody;
          
          // Extract referenceid - handle different response structures
          // Angular code: this.referenceId = res.data?.referenceid;
          String extractedReferenceId = '';
          
          // Log full response for debugging
          ConsoleLog.printColor("FULL VRF RESPONSE DATA: ${jsonEncode(result['data'])}", color: "magenta");
          
          if (result['data'] != null) {
            if (result['data'] is Map<String, dynamic>) {
              // Most common case: data is a Map
              extractedReferenceId = result['data']?['referenceid']?.toString() ?? 
                                     result['data']?['reference_id']?.toString() ?? 
                                     result['data']?['ReferenceId']?.toString() ?? '';
            } else if (result['data'] is String) {
              // If data is string, try to parse it
              try {
                Map<String, dynamic> dataMap = jsonDecode(result['data']);
                extractedReferenceId = dataMap['referenceid']?.toString() ?? 
                                       dataMap['reference_id']?.toString() ?? 
                                       dataMap['ReferenceId']?.toString() ?? '';
              } catch (e) {
                ConsoleLog.printError("Error parsing data string: $e");
              }
            }
          }
          
          // Alternative: check if referenceid is directly in result
          if (extractedReferenceId.isEmpty) {
            extractedReferenceId = result['referenceid']?.toString() ?? 
                                   result['reference_id']?.toString() ?? 
                                   result['ReferenceId']?.toString() ?? '';
          }
          
          pinStatusReferenceId = extractedReferenceId;

          ConsoleLog.printColor("EXTRACTED REFERENCE ID: $pinStatusReferenceId", color: "cyan");
          
          if (pinStatusReferenceId.isEmpty) {
            // Revert toggle if referenceId not found
            isPinEnabled.value = !newValue;
            CustomDialog.error(
              message: 'OTP sent but reference ID not found in response. Please check logs and try again.',
            );
            return;
          }

          CustomDialog.success(
            message: result['Resp_desc'] ?? 'OTP sent successfully',
            onContinue: () {
              // CustomDialog.success already calls Get.back() to close success dialog
              // So we don't need to call Get.back() here again
              // Just show OTP dialog after a small delay to ensure success dialog is closed
              Future.delayed(const Duration(milliseconds: 300), () {
                _showOtpDialogForPinStatus();
              });
            },
          );
        } else if (result['Resp_code'] == 'RCS') {
          // Status changed directly (usually when turning ON)
          // Update toggle value immediately to reflect the change
          isPinEnabled.value = newValue;
          
          // Refresh profile data from API to sync toggle value
          await _refreshProfileData();
          
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Status changed successfully',
          );
        } else {
          // Error - revert toggle
          isPinEnabled.value = !newValue;
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to change status',
          );
        }
      } else {
        // Error - revert toggle
        isPinEnabled.value = !newValue;
        CustomDialog.error(message: 'Failed to change status');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      isChangingPinStatus.value = false;
      isPinEnabled.value = !newValue; // Revert toggle on error
      ConsoleLog.printError('Error in changePinStatus: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region _showOtpDialogForPinStatus
  /// Show OTP dialog for PIN status change verification
  void _showOtpDialogForPinStatus() {
    final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          // Don't allow back button or background tap to close dialog
          // Only Cancel button should close it
          return false; // Prevent dialog from closing on back button
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: GestureDetector(
            // Prevent taps on dialog background from propagating
            onTap: () {},
            child: Container(
              width: Get.width - 50,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Verify OTP',
                  style: GoogleFonts.albertSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Enter OTP to change Transaction PIN status',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: const Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OTP Input Fields
                SizedBox(
                  width: double.infinity,
                  child: OtpInputFields(
                    key: _otpKey,
                    length: 6,
                    onCompleted: (otp) {
                      // Auto verify when all 6 digits are entered
                      verifyPinStatusOtp(otp, _otpKey);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button - Matching Profile Controller style
                    InkWell(
                      onTap: () {
                        // Reset toggle to previous state
                        isPinEnabled.value = !isPinEnabled.value;
                        Get.back();
                        // Refresh PIN status from cache
                        loadPinStatus();
                      },
                      child: Container(
                        width: 120,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.albertSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B707E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Verify Button
                    InkWell(
                      onTap: () {
                        final otp = _otpKey.currentState?.currentOtp ?? '';
                        if (otp.length == 6) {
                          verifyPinStatusOtp(otp, _otpKey);
                        } else {
                          CustomDialog.error(
                            message: 'Please enter complete 6-digit OTP',
                          );
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: GlobalUtils.blueBtnGradientColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Verify',
                            style: GoogleFonts.albertSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Don't allow background tap to dismiss
      barrierColor: Colors.black54, // Semi-transparent background
    );
    
    // Auto focus on first OTP field after dialog is shown
    Future.delayed(const Duration(milliseconds: 300), () {
      _otpKey.currentState?.focusFirst();
    });
  }
  //endregion

  //region verifyPinStatusOtp
  /// Verify OTP for PIN status change
  /// Takes otpKey parameter to clear OTP fields on invalid OTP
  Future<void> verifyPinStatusOtp(String otp, GlobalKey<OtpInputFieldsState>? otpKey) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        CustomDialog.error(message: 'Please enter valid 6-digit OTP');
        return;
      }

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VERIFY',
        'referenceid': pinStatusReferenceId,
        'otp': otp,
        'txnpin_status': changePinStatusObject?['txnpin_status'],
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("VERIFY PIN STATUS OTP REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_CHANGE_TXN_PIN_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("VERIFY PIN STATUS OTP RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          // Success - Status changed via OTP verification
          // Close OTP dialog first
          Get.back();
          
          // Update toggle value based on what was requested in changePinStatusObject
          if (changePinStatusObject != null && changePinStatusObject!['txnpin_status'] != null) {
            final requestedStatus = changePinStatusObject!['txnpin_status'] == 'true';
            isPinEnabled.value = requestedStatus;
            ConsoleLog.printInfo("PIN Status updated to: ${isPinEnabled.value} after OTP verification");
          }
          
          // Refresh profile data from API to sync toggle value
          await _refreshProfileData();
          
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Status changed successfully',
          );
        } else {
          // OTP verification failed - keep dialog open and clear OTP fields
          // Don't revert toggle yet, allow user to try again
          if (otpKey?.currentState != null) {
            otpKey!.currentState!.clear();
            Future.delayed(const Duration(milliseconds: 300), () {
              otpKey.currentState?.focusFirst();
            });
          }
          
          // Show error dialog without onContinue to prevent navigation
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Invalid OTP. Please try again.',
          );
        }
      } else {
        // Error - keep dialog open and clear OTP fields
        if (otpKey?.currentState != null) {
          otpKey!.currentState!.clear();
          Future.delayed(const Duration(milliseconds: 300), () {
            otpKey.currentState?.focusFirst();
          });
        }
        CustomDialog.error(message: 'Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in verifyPinStatusOtp: $e');
      
      // Error - keep dialog open and clear OTP fields
      if (otpKey?.currentState != null) {
        otpKey!.currentState!.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          otpKey.currentState?.focusFirst();
        });
      }
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  @override
  void onClose() {
    // Dispose text controllers
    oldPasswordController.value.dispose();
    newPasswordController.value.dispose();
    confirmPasswordController.value.dispose();
    oldPinController.value.dispose();
    newPinController.value.dispose();
    confirmPinController.value.dispose();
    super.onClose();
  }
}
