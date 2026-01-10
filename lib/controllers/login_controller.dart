import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:payrupya/controllers/payrupya_home_screen_controller.dart';
import 'package:payrupya/controllers/saved_credentials_service.dart';
import 'package:payrupya/controllers/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/login_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/save_credential_dialog.dart';
import '../view/other_users_screen.dart';
import '../view/payrupya_main_screen.dart';

import '../view/other_users_screen.dart';
import '../view/payrupya_main_screen.dart';
import '../view/login_otp_verification_screen.dart';
import 'biometric_service.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
  Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
  Rx<TextEditingController> passwordController = TextEditingController(text: "").obs;
  RxBool isValidUserID = true.obs;
  RxBool isValidPassword = true.obs;
  RxString mobile = "".obs;
  RxString email = "".obs;
  RxString name = "".obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  
  // OTP Verification Variables
  RxString loginOtpReferenceId = "".obs;
  RxString loginMobileNumber = "".obs;

  // ============================================
  // NEW: Biometric Login Variables
  // ============================================
  late BiometricService biometricService;
  RxBool isBiometricLoading = false.obs;


  // @override
  // void initState(){
  //   super.initState();
  //   AppSharedPreferences().getString(AppSharedPreferences.email).then((value){
  //     email = value;
  //     ConsoleLog.printColor("Email: $email");
  //   });
  //   AppSharedPreferences().getString(AppSharedPreferences.userName).then((value){
  //     name = value;
  //     ConsoleLog.printColor("Name: $name");
  //   });
  // }
  @override
  void onInit() {
    super.onInit();
    _initServices();
    getLocationAndLoadData();
    // GlobalUtils.getLocation(latitude.value, longitude.value);
    init();
  }

  // ============================================
  // NEW: Initialize Biometric & Session Manager
  // ============================================
  void _initServices() {
    // Initialize BiometricService
    if (!Get.isRegistered<BiometricService>()) {
      biometricService = Get.put(BiometricService(), permanent: true);
    } else {
      biometricService = Get.find<BiometricService>();
    }

    // Initialize SessionManager
    if (!Get.isRegistered<SessionManager>()) {
      Get.put(SessionManager(), permanent: true);
    }
  }

  Future<void> getLocationAndLoadData() async {
    try {
      Position? position = await GlobalUtils.getLocation();
      if (position != null) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        ConsoleLog.printSuccess("Location updated: ${latitude.value}, ${longitude.value}");

        // Load auth credentials और balance
        // await init();
      } else {
        ConsoleLog.printError("Failed to get location");
      }
    } catch (e) {
      ConsoleLog.printError("Error in getLocationAndLoadData: $e");
    }
  }

  void init() async{
    // await askLocationPermission();
    // await getUserLocation();

    SharedPreferences.getInstance().then((value) {
      value.setBool(AppSharedPreferences.isIntro, true);
    });
    AppSharedPreferences().getString(AppSharedPreferences.mobileNo).then((value){
      mobile.value = value;
      ConsoleLog.printColor("Mobile: ${mobile.value}");
    });
    AppSharedPreferences().getString(AppSharedPreferences.email).then((value){
      email.value = value;
      ConsoleLog.printColor("Email: ${email.value}");
    });
    AppSharedPreferences().getString(AppSharedPreferences.userName).then((value){
      name.value = value;
      ConsoleLog.printColor("Name: $name");
    });
  }



  // // ======================================================
  // // PERMISSION HANDLER (Popup Guaranteed)
  // // ======================================================
  // Future<void> askLocationPermission() async {
  //   var status = await Permission.location.status;
  //
  //   print("Current Permission Status: $status");
  //
  //   if (status.isDenied) {
  //     // Request permission
  //     status = await Permission.location.request();
  //     print("After Request Status: $status");
  //   }
  //
  //   if (status.isPermanentlyDenied) {
  //     // Show dialog to user
  //     await showDialog(
  //       context: Get.context!,
  //       builder: (context) => AlertDialog(
  //         title: Text("Location Permission Required"),
  //         content: Text("Please enable Location Permission from Settings to continue."),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               openAppSettings();
  //             },
  //             child: Text("Open Settings"),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   if (status.isGranted) {
  //     print("Location Permission Granted!");
  //     await getUserLocation();
  //   }
  // }
  //
  // // ======================================================
  // // GET USER LOCATION (After Permission)
  // // ======================================================
  // Future<void> getUserLocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       CustomDialog.error(
  //         context: Get.context!,
  //         message: "GPS is OFF. Please enable GPS.",
  //       );
  //       return;
  //     }
  //
  //     Position pos = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     latitude.value = pos.latitude;
  //     longitude.value = pos.longitude;
  //
  //     print("LAT: ${latitude.value}, LONG: ${longitude.value}");
  //   } catch (e) {
  //     print("LOCATION ERROR: $e");
  //   }
  // }


  // ============================================
  // BIOMETRIC LOGIN - Direct, No Dialog
  // ============================================
  Future<void> loginWithBiometric(BuildContext context) async {
    // Check if biometric is available and enabled
    if (!biometricService.canUseBiometricLogin()) {
      Fluttertoast.showToast(
        msg: "Please login with password first to enable ${biometricService.getBiometricTypeName()}",
        backgroundColor: Colors.orange,
      );
      return;
    }

    isBiometricLoading.value = true;

    try {
      // Authenticate
      final success = await biometricService.authenticate(
        reason: 'Login to PayRupya',
      );

      if (!success) {
        isBiometricLoading.value = false;
        return;
      }

      // Get saved credentials
      final credentials = await biometricService.getSavedCredentials();

      if (credentials == null) {
        isBiometricLoading.value = false;
        Fluttertoast.showToast(
          msg: "No saved credentials. Please login with password.",
          backgroundColor: Colors.orange,
        );
        return;
      }

      // Set credentials and login
      mobileController.value.text = credentials['mobile']!;
      passwordController.value.text = credentials['password']!;

      // Call login API
      await loginApi(context, fromBiometric: true);

    } catch (e) {
      ConsoleLog.printError("Biometric login error: $e");
      Fluttertoast.showToast(
        msg: "Authentication failed",
        backgroundColor: Colors.red,
      );
    } finally {
      isBiometricLoading.value = false;
    }
  }

  // ============================================
  // LOGIN API
  // ============================================
  Future<void> loginApi(BuildContext context, {bool fromBiometric = false, bool fromSavedCredential = false}) async {
    String mobile = mobileController.value.text.trim();
    String password = passwordController.value.text.trim();

    // Validation
    if (mobile.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter mobile number");
      return;
    }

    if (mobile.length != 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      return;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter password");
      return;
    }

    // Check Internet
    bool isConnected = await ConnectionValidator.isConnected();
    if (!isConnected) {
      Fluttertoast.showToast(msg: "No Internet Connection!");
      return;
    }

    // Show Loader
    CustomLoading.showLoading();

    Map<String, dynamic> requestBody = {
      "login": mobile,
      "password": password,
      "request_id": GlobalUtils.generateRandomId(8),
      "lat": latitude.value.toString(),
      "long": longitude.value.toString(),
    };

    ConsoleLog.printColor("LOGIN REQ: $requestBody");

    try {
      var response = await ApiProvider().loginApi(
        context,
        WebApiConstant.API_URL_LOGIN,
        requestBody,
        "",
      );

      CustomLoading.hideLoading();

      if (response == null) {
        Fluttertoast.showToast(msg: "No response from server");
        return;
      }

      try {
        String respCode = response["Resp_code"] ?? "";
        String respDesc = response["Resp_desc"] ?? "";

        if (respCode == "RCS") {
          if (response["data"] == null || response["data"] is! Map) {
            Fluttertoast.showToast(msg: "Login failed: Invalid response");
            return;
          }

          LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);

          String token = loginResponse.data?.tokenid ?? "";
          String signature = loginResponse.data?.requestId ?? "";

          if (token.isEmpty) {
            Fluttertoast.showToast(msg: "Login failed: Invalid token");
            return;
          }

          // Save auth data
          await AppSharedPreferences.saveLoginAuth(token: token, signature: signature);
          await AppSharedPreferences.setUserId(loginResponse.data?.userdata?.accountidf ?? "");
          await AppSharedPreferences.setMobileNo(loginResponse.data?.userdata?.mobile ?? "");
          await AppSharedPreferences.setEmail(loginResponse.data?.userdata?.email ?? "");
          await AppSharedPreferences.setUserName(loginResponse.data?.userdata?.contactPerson ?? "");
          await AppSharedPreferences.saveUserRole(loginResponse.data?.userdata?.roleidf ?? "");

          // Update observables
          name.value = loginResponse.data?.userdata?.contactPerson ?? "";
          email.value = loginResponse.data?.userdata?.email ?? "";
          this.mobile.value = loginResponse.data?.userdata?.mobile ?? "";

          // ============================================
          // SAVE CREDENTIALS FOR BIOMETRIC (No Dialog!)
          // ============================================
          if (!fromBiometric && biometricService.isBiometricAvailable.value) {
            await biometricService.saveCredentialsForBiometric(mobile, password);
            ConsoleLog.printSuccess("✅ Biometric auto-enabled for future logins");
          }

          // ============================================
          // SHOW SAVE CREDENTIALS DIALOG (NEW FEATURE)
          // Only show if:
          // 1. Not from biometric login
          // 2. Not from saved credential auto-fill
          // 3. Credential is not already saved
          // ============================================
          if (!fromBiometric && !fromSavedCredential) {
            final isAlreadySaved = await SavedCredentialsService.instance.isCredentialSaved(mobile);

            if (!isAlreadySaved && context.mounted) {
              // Show save credentials dialog
              final shouldSave = await SaveCredentialDialog.show(context, mobile);

              if (shouldSave == true) {
                await SavedCredentialsService.instance.saveCredential(mobile, password);
                ConsoleLog.printSuccess("✅ Credentials saved for quick login");
              }
            }
          }

          // Start session
          if (Get.isRegistered<SessionManager>()) {
            await SessionManager.instance.startSession();
          }

          ConsoleLog.printSuccess("✅ Login successful: ${loginResponse.data?.userdata?.contactPerson}");

          Fluttertoast.showToast(
            msg: "Welcome ${loginResponse.data?.userdata?.contactPerson}!",
            toastLength: Toast.LENGTH_LONG,
          );

          Get.offAll(() => PayrupyaMainScreen());

        } else if (respCode == "TFA") {
          // ✅ TWO FACTOR AUTHENTICATION - OTP Required
          ConsoleLog.printColor("🔐 TFA Response: OTP required", color: "yellow");
          ConsoleLog.printColor("TFA Full Response: $response", color: "cyan");
          
          // Extract reference ID from response - handle both Map and direct access
          String? referenceId;
          
          // Try multiple ways to get reference ID
          if (response["data"] != null) {
            if (response["data"] is Map) {
              referenceId = response["data"]["referenceid"]?.toString();
            } else if (response["data"] is String) {
              // Sometimes data might be a string
              try {
                Map<String, dynamic> dataMap = Map<String, dynamic>.from(response["data"]);
                referenceId = dataMap["referenceid"]?.toString();
              } catch (e) {
                ConsoleLog.printError("Error parsing data as Map: $e");
              }
            }
          }
          
          // Alternative: try direct access to referenceid in response
          if ((referenceId == null || referenceId.isEmpty) && response["referenceid"] != null) {
            referenceId = response["referenceid"]?.toString();
          }
          
          ConsoleLog.printInfo("Extracted Reference ID: $referenceId");
          
          if (referenceId == null || referenceId.isEmpty) {
            ConsoleLog.printError("❌ No reference ID in TFA response");
            ConsoleLog.printError("Response keys: ${response.keys.toList()}");
            if (response["data"] != null) {
              ConsoleLog.printError("Data type: ${response["data"].runtimeType}");
              ConsoleLog.printError("Data content: ${response["data"]}");
            }
            Fluttertoast.showToast(
              msg: "OTP verification failed: Invalid response",
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
            );
            return;
          }
          
          // Store reference ID and mobile number for OTP verification
          loginOtpReferenceId.value = referenceId;
          loginMobileNumber.value = mobile;
          
          ConsoleLog.printSuccess("✅ Reference ID stored: $referenceId");
          ConsoleLog.printInfo("Mobile: $mobile");
          
          // Navigate to OTP verification screen
          Get.to(() => LoginOtpVerificationScreen(
            mobile: mobile,
            referenceId: referenceId ?? "",
          ));
          
        } else if (respCode == "ERR") {
          String errorMessage = respDesc;
          if (respDesc.toLowerCase().contains('invalid')) {
            errorMessage = "Invalid mobile number or password";
          }
          Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.red);
        } else {
          Fluttertoast.showToast(msg: respDesc.isNotEmpty ? respDesc : "Login failed");
        }

      } catch (parseError) {
        ConsoleLog.printError("Parse error: $parseError");
        Fluttertoast.showToast(msg: "Login failed");
      }
    } catch (e, stackTrace) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("LOGIN ERROR: $e");
      Fluttertoast.showToast(msg: "Technical issue. Please try again.");
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  Future<void> logout({bool clearBiometric = false, bool clearSavedCredentials = false}) async {
    try {
      CustomLoading.showLoading();

      // End session
      if (Get.isRegistered<SessionManager>()) {
        await SessionManager.instance.endSession();
      }

      // ✅ FIX: Reset Home Screen Controller State
      if (Get.isRegistered<PayrupyaHomeScreenController>()) {
        Get.find<PayrupyaHomeScreenController>().resetInitialization();
      }

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppSharedPreferences.isLogin, false);
      await prefs.remove(AppSharedPreferences.token);
      await prefs.remove(AppSharedPreferences.signature);

      // Clear biometric if requested
      if (clearBiometric) {
        await biometricService.disableBiometric();
      }

      // Clear saved credentials if requested
      if (clearSavedCredentials) {
        await SavedCredentialsService.instance.clearAllCredentials();
      }

      // Clear fields
      name.value = "";
      email.value = "";
      mobile.value = "";
      mobileController.value.clear();
      passwordController.value.clear();

      CustomLoading.hideLoading();
      ConsoleLog.printSuccess("✅ Logout successful");

    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Logout error: $e");
    }
  }

  @override
  void onClose() {
    mobileController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }


  /*// ======================================================
  // LOGIN API CALL
  // ======================================================
  // LOGIN API CALL WITH MODEL INTEGRATION
  Future<void> loginApi(BuildContext context) async {
    String mobile = mobileController.value.text.trim();
    String password = passwordController.value.text.trim();

    ConsoleLog.printColor("Mobile: $mobile");
    ConsoleLog.printColor("Password: ${password.replaceAll(RegExp(r'.'), '*')}");


    // Validation
    if (mobile.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter mobile number");
      return;
    }

    if (mobile.length != 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      return;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter password");
      return;
    }

    // Check Internet
    ConsoleLog.printInfo("Checking internet connection...");
    bool isConnected = await ConnectionValidator.isConnected();
    ConsoleLog.printInfo("Is Connected: $isConnected");

    if (!isConnected) {
      Fluttertoast.showToast(msg: "No Internet Connection!");
      return;
    }

    // Show Loader
    CustomLoading.showLoading();

    Map<String, dynamic> requestBody = {
      "login": mobile,
      "password": password,
      "request_id": GlobalUtils.generateRandomId(8),
      "lat": latitude.value.toString(),
      "long": longitude.value.toString(),
    };

    ConsoleLog.printColor("LOGIN REQ: $requestBody");

    try {
      var response = await ApiProvider().loginApi(
        context,
        WebApiConstant.API_URL_LOGIN,
        requestBody,
        "",
      );

      CustomLoading.hideLoading();
      ConsoleLog.printColor("LOGIN RESPONSE: $response");

      if (response == null) {
        Fluttertoast.showToast(msg: "No response from server");
        return;
      }

      // ✅ CRITICAL FIX: Handle both success and error responses safely
      try {
        // Check response code first
        String respCode = response["Resp_code"] ?? "";
        String respDesc = response["Resp_desc"] ?? "";

        ConsoleLog.printColor("Response Code: $respCode", color: "yellow");
        ConsoleLog.printColor("Response Desc: $respDesc", color: "yellow");

        if (respCode == "RCS") {
          // ✅ SUCCESS CASE - data will be a Map
          if (response["data"] == null) {
            ConsoleLog.printError("❌ No data in response");
            Fluttertoast.showToast(msg: "Login failed: No data received");
            return;
          }

          // Check if data is a Map (success case)
          if (response["data"] is! Map) {
            ConsoleLog.printError("❌ Invalid data format");
            Fluttertoast.showToast(msg: "Login failed: Invalid response format");
            return;
          }

          // Parse response using model
          LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);

          // ✅ Extract token and signature
          String token = loginResponse.data?.tokenid ?? "";
          String signature = loginResponse.data?.requestId ?? "";

          if (token.isEmpty) {
            ConsoleLog.printError("❌ Token is empty in response");
            Fluttertoast.showToast(msg: "Login failed: Invalid token");
            return;
          }

          if (signature.isEmpty) {
            ConsoleLog.printWarning("⚠️ No separate signature field found, using request_id");
            signature = loginResponse.data?.requestId ?? "";
          }

          // ✅ Save to SharedPreferences
          await AppSharedPreferences.saveLoginAuth(
            token: token,
            signature: signature,
          );

          // ✅ Save user details
          await AppSharedPreferences.setUserId(
              loginResponse.data?.userdata?.accountidf ?? ""
          );
          await AppSharedPreferences.setMobileNo(
              loginResponse.data?.userdata?.mobile ?? ""
          );
          await AppSharedPreferences.setEmail(
              loginResponse.data?.userdata?.email ?? ""
          );
          await AppSharedPreferences.setUserName(
              loginResponse.data?.userdata?.contactPerson ?? ""
          );
          await AppSharedPreferences.saveUserRole(
              loginResponse.data?.userdata?.roleidf ?? ""
          );

          ConsoleLog.printSuccess("✅ Login successful for user: ${loginResponse.data?.userdata?.contactPerson}");
          ConsoleLog.printInfo("Token: $token");
          ConsoleLog.printInfo("Signature: $signature");
          ConsoleLog.printInfo("User ID: ${loginResponse.data?.userdata?.accountidf}");

          // ✅ Navigate to Main Screen
          Fluttertoast.showToast(
            msg: "Login successful! Welcome ${loginResponse.data?.userdata?.contactPerson}",
            toastLength: Toast.LENGTH_LONG,
          );
          Get.offAll(() => PayrupyaMainScreen());

        } else if (respCode == "TFA") {
          // ✅ TWO FACTOR AUTHENTICATION - OTP Required
          ConsoleLog.printColor("🔐 TFA Response: OTP required", color: "yellow");
          ConsoleLog.printColor("TFA Full Response: $response", color: "cyan");
          
          // Extract reference ID from response - handle both Map and direct access
          String? referenceId;
          
          // Try multiple ways to get reference ID
          if (response["data"] != null) {
            if (response["data"] is Map) {
              referenceId = response["data"]["referenceid"]?.toString();
            } else if (response["data"] is String) {
              // Sometimes data might be a string
              try {
                Map<String, dynamic> dataMap = Map<String, dynamic>.from(response["data"]);
                referenceId = dataMap["referenceid"]?.toString();
              } catch (e) {
                ConsoleLog.printError("Error parsing data as Map: $e");
              }
            }
          }
          
          // Alternative: try direct access to referenceid in response
          if ((referenceId == null || referenceId.isEmpty) && response["referenceid"] != null) {
            referenceId = response["referenceid"]?.toString();
          }
          
          ConsoleLog.printInfo("Extracted Reference ID: $referenceId");
          
          if (referenceId == null || referenceId.isEmpty) {
            ConsoleLog.printError("❌ No reference ID in TFA response");
            ConsoleLog.printError("Response keys: ${response.keys.toList()}");
            if (response["data"] != null) {
              ConsoleLog.printError("Data type: ${response["data"].runtimeType}");
              ConsoleLog.printError("Data content: ${response["data"]}");
            }
            Fluttertoast.showToast(
              msg: "OTP verification failed: Invalid response",
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
            );
            return;
          }
          
          // Store reference ID and mobile number for OTP verification
          loginOtpReferenceId.value = referenceId;
          loginMobileNumber.value = mobile;
          
          ConsoleLog.printSuccess("✅ Reference ID stored: $referenceId");
          ConsoleLog.printInfo("Mobile: $mobile");
          
          // Navigate to OTP verification screen
          Get.to(() => LoginOtpVerificationScreen(
            mobile: mobile,
            referenceId: referenceId,
          ));
          
        } else if (respCode == "ERR") {
          // ✅ ERROR CASE - data might be a List or null
          ConsoleLog.printError("❌ Login failed: $respDesc");

          // Show user-friendly error message
          String errorMessage = respDesc;

          // Handle specific error messages
          if (respDesc.toLowerCase().contains('invalid mobile')) {
            errorMessage = "Invalid mobile number or password";
          } else if (respDesc.toLowerCase().contains('invalid password')) {
            errorMessage = "Invalid mobile number or password";
          } else if (respDesc.toLowerCase().contains('user not found')) {
            errorMessage = "User not found. Please register first.";
          } else if (respDesc.toLowerCase().contains('account blocked')) {
            errorMessage = "Your account has been blocked. Contact support.";
          }

          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
          );

        } else {
          // Unknown response code
          ConsoleLog.printError("❌ Unexpected response code: $respCode");
          Fluttertoast.showToast(
            msg: respDesc.isNotEmpty ? respDesc : "Login failed: Unexpected error",
            toastLength: Toast.LENGTH_LONG,
          );
        }

      } catch (parseError) {
        ConsoleLog.printError("❌ PARSE ERROR: $parseError");

        // Try to show error message from response if available
        if (response is Map && response.containsKey("Resp_desc")) {
          Fluttertoast.showToast(
            msg: response["Resp_desc"] ?? "Login failed",
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(msg: "Login failed: Unable to parse response");
        }
      }
      // // Parse response using model
      // LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);
      //
      // // SUCCESS RESPONSE
      // if (loginResponse.respCode == "RCS") {
      //   // ✅ ADD THIS DEBUG CODE
      //   ConsoleLog.printColor("=== LOGIN RESPONSE DEBUG ===", color: "green");
      //   ConsoleLog.printColor("Full Response: ${response}", color: "yellow");
      //   ConsoleLog.printColor("Token: ${loginResponse.data?.tokenid}", color: "cyan");
      //   ConsoleLog.printColor("Request ID: ${loginResponse.data?.requestId}", color: "cyan");
      //
      //   // Check if there's a signature field
      //   if (response.containsKey('signature')) {
      //     ConsoleLog.printColor("Signature Field: ${response['signature']}", color: "cyan");
      //   }
      //   if (response.containsKey('data') && response['data'] != null) {
      //     if (response['data'].containsKey('signature')) {
      //       ConsoleLog.printColor("Data.Signature: ${response['data']['signature']}", color: "cyan");
      //     }
      //   }
      //   ConsoleLog.printColor("=== END DEBUG ===", color: "green");
      //
      //   // Extract data using model properties
      //   String tokenId = loginResponse.data?.tokenid ?? "";
      //   String requestId = loginResponse.data?.requestId ?? "";
      //   String signature = loginResponse.data?.signature ?? "";
      //
      //   // ✅ If signature is empty, use requestId as fallback
      //   if (signature.isEmpty) {
      //     signature = requestId;
      //     ConsoleLog.printWarning("⚠️ No separate signature field found, using request_id");
      //   }
      //
      //   UserData? userData = loginResponse.data?.userdata;
      //
      //   // // Save auth exactly like Ionic
      //   // if (tokenId.isNotEmpty && signature.isNotEmpty) {
      //   //   await AppSharedPreferences.saveLoginAuth(
      //   //     token: tokenId,
      //   //     signature: signature,
      //   //   );
      //   // }
      //
      //   if (userData != null) {
      //     String userId = userData.accountidf ?? "";
      //     String mobileNo = userData.mobile ?? "";
      //     String userName = userData.contactPerson ?? "";
      //     String userEmail = userData.email ?? "";
      //     String userRole = userData.roleidf ?? "";
      //
      //     ConsoleLog.printSuccess("Login successful for user: $userName");
      //     ConsoleLog.printInfo("Token: $tokenId");
      //     ConsoleLog.printInfo("Request ID: $requestId");
      //     ConsoleLog.printInfo("Signature: $signature");
      //     ConsoleLog.printInfo("User ID: $userId");
      //     ConsoleLog.printInfo("Mobile: $mobileNo");
      //     ConsoleLog.printInfo("Email: $userEmail");
      //     ConsoleLog.printInfo("Role: $userRole");
      //
      //     // Save User Data
      //     SharedPreferences pref = await SharedPreferences.getInstance();
      //     pref.setBool(AppSharedPreferences.isLogin, true);
      //     pref.setString(AppSharedPreferences.token, tokenId);
      //     pref.setString(AppSharedPreferences.signature, signature);
      //     pref.setString(AppSharedPreferences.userID, userId);
      //     pref.setString(AppSharedPreferences.mobileNo, mobileNo);
      //     pref.setString(AppSharedPreferences.userName, userName);
      //     pref.setString(AppSharedPreferences.email, userEmail);
      //     pref.setString(AppSharedPreferences.userRole, userRole);
      //
      //     // Update Observables
      //     name.value = userName;
      //     email.value = userEmail;
      //     this.mobile.value = mobileNo;
      //
      //     Fluttertoast.showToast(
      //       msg: loginResponse.respDesc ?? "Login Successful",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.TOP,
      //     );
      //
      //     // Navigate based on user role
      //     if (userRole == "1") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Admin"));
      //     } else if (userRole == "2") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Super Distributor"));
      //     } else if (userRole == "3") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Distributor"));
      //     } else if (userRole == "4") {
      //       Get.offAll(() => PayrupyaMainScreen(), transition: Transition.fadeIn);
      //     } else {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Other"));
      //     }
      //   } else {
      //     CustomDialog.error(context: context, message: "User data not found!");
      //   }
      // }
      // // OTP REQUIRED CASE (TFA)
      // else if (loginResponse.respCode == "TFA") {
      //   Fluttertoast.showToast(msg: "OTP Required");
      //   // Get.to(() => OtpScreen(referenceId: response["data"]["referenceid"]));
      // }
      // // ERROR MESSAGE
      // else {
      //   ConsoleLog.printError("Login Failed: ${loginResponse.respDesc}");
      //   CustomDialog.error(
      //     context: context,
      //     message: loginResponse.respDesc ?? "Login failed!",
      //   );
      // }
    } catch (e, stackTrace) {
      ConsoleLog.printError("❌ LOGIN ERROR: $e");
      ConsoleLog.printError("STACK TRACE: $stackTrace");

      Fluttertoast.showToast(
        msg: "Technical issue occurred! Please try again.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // // Toggle password visibility
  // void togglePasswordVisibility() {
  //   obscurePassword.value = !obscurePassword.value;
  // }

  @override
  void onClose() {
    mobileController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }*/







  // Future<void> loginApi(BuildContext context) async {
  //   String mobile = mobileController.value.text.trim();
  //   String password = passwordController.value.text.trim();
  //
  //   if (mobile.isEmpty || password.isEmpty) {
  //     CustomDialog.error(context: context, message: "Please enter mobile and password");
  //     return;
  //   }
  //
  //   // Check Internet with detailed logging
  //   ConsoleLog.printInfo("Checking internet connection...");
  //   bool isConnected = await ConnectionValidator.isConnected();
  //   ConsoleLog.printInfo("Is Connected: $isConnected");
  //
  //   if (!isConnected) {
  //     CustomDialog.error(context: context, message: "No Internet Connection!");
  //     return;
  //   }
  //
  //   // Show Loader
  //   CustomLoading().show(context);
  //
  //   Map<String, dynamic> body = {
  //     "login": mobile,
  //     "password": password,
  //     "request_id": GlobalUtils.generateRandomId(8),
  //     "lat": latitude.value.toString(),
  //     "long": longitude.value.toString(),
  //   };
  //
  //   ConsoleLog.printColor("LOGIN REQ: $body");
  //
  //   try {
  //     var response = await ApiProvider().loginApi(
  //       context,
  //       WebApiConstant.API_URL_LOGIN,
  //       body,
  //       "",
  //     );
  //
  //     CustomLoading().hide;
  //     ConsoleLog.printColor("LOGIN RESPONSE: $response");
  //
  //     if (response == null) {
  //       CustomDialog.error(context: context, message: "Server not responding!");
  //       return;
  //     }
  //
  //     // Parse response using model
  //     LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);
  //
  //     // SUCCESS RESPONSE
  //     if (response['Resp_code'] == "RCS") {
  //       var data = response["data"];
  //
  //       var userData = data["userdata"];
  //
  //       // Safe String Extraction with null checks
  //       String tokenId = data["tokenid"]?.toString() ?? "";
  //       String userId = userData["accountidf"]?.toString() ?? "";
  //       String mobileNo = userData["mobile"]?.toString() ?? "";
  //       String userName = userData["contact_person"]?.toString() ?? "";
  //       String userEmail = userData["email"]?.toString() ?? "";
  //       String userRole = userData["roleidf"]?.toString() ?? "";
  //
  //       ConsoleLog.printSuccess("Login successful for user: $userName");
  //       ConsoleLog.printInfo("User ID: $userId");
  //       ConsoleLog.printInfo("Mobile: $mobileNo");
  //       ConsoleLog.printInfo("Email: $userEmail");
  //       ConsoleLog.printInfo("Role: $userRole");
  //
  //       // Save User Data
  //       SharedPreferences pref = await SharedPreferences.getInstance();
  //       pref.setBool(AppSharedPreferences.isLogin, true);
  //       pref.setString(AppSharedPreferences.token, tokenId);
  //       pref.setString(AppSharedPreferences.userID, userId);
  //       pref.setString(AppSharedPreferences.mobileNo, mobileNo);
  //       pref.setString(AppSharedPreferences.userName, userName);
  //       pref.setString(AppSharedPreferences.email, userEmail);
  //       pref.setString(AppSharedPreferences.userRole, userRole);
  //
  //       // Update Observables
  //       name.value = userName;
  //       email.value = userEmail;
  //       this.mobile.value = mobileNo;
  //
  //       Fluttertoast.showToast(
  //         msg: response["Resp_desc"] ?? "Login Successful",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.TOP,
  //       );
  //
  //       if(userRole == "1"){
  //         OtherUsersScreen(UserName: "Admin",);
  //         //Admin
  //       }else if(userRole == "2"){
  //         OtherUsersScreen(UserName: "Super Distributor",);
  //         //SuperDistributor
  //       }else if(userRole == "3"){
  //         OtherUsersScreen(UserName: "Distributor",);
  //         //Distributor
  //       }else if(userRole == "4"){
  //         Get.offAll(PayrupyaMainScreen(), transition: Transition.fadeIn);
  //         // OtherUsersScreen(UserName: "Retailer",);
  //         //Retailor
  //       }else{
  //         OtherUsersScreen(UserName: "Other",);
  //         //Other
  //       }
  //       // Get.offAll(MainScreen(selectedIndex: 0));
  //       // Get.offAll(PayrupyaMainScreen());
  //     }
  //
  //     // OTP REQUIRED CASE (TFA)
  //     else if (response['Resp_code'] == "TFA") {
  //       Fluttertoast.showToast(msg: "OTP Required");
  //       // Get.to(() => OtpScreen(referenceId: response["data"]["referenceid"]));
  //     }
  //
  //     // ERROR MESSAGE
  //     else {
  //       ConsoleLog.printError("Login Failed: ${response['Resp_desc']}");
  //       CustomDialog.error(
  //         context: context,
  //         message: response["Resp_desc"] ?? "Login failed!",
  //       );
  //     }
  //   } catch (e) {
  //     CustomLoading().hide;
  //     ConsoleLog.printError("LOGIN ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue, please try again!");
  //   }
  // }

  // ============================================
  // VERIFY LOGIN OTP
  // ============================================
  Future<void> verifyLoginOtp(BuildContext context, String otp, String mobile, String referenceId) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        Fluttertoast.showToast(msg: "Please enter valid 6-digit OTP");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> requestBody = {
        "login": mobile,
        "referenceid": referenceId,
        "otp": otp,
        "request_id": GlobalUtils.generateRandomId(8),
        "lat": latitude.value.toString(),
        "long": longitude.value.toString(),
        "versionNew": 1,
      };

      ConsoleLog.printColor("VERIFY LOGIN OTP REQ: $requestBody");

      var response = await ApiProvider().verifyLoginOtpApi(
        context,
        WebApiConstant.API_URL_VERIFY_LOGIN_OTP,
        requestBody,
        "",
      );

      CustomLoading.hideLoading();

      if (response == null) {
        Fluttertoast.showToast(msg: "No response from server");
        return;
      }

      String respCode = response["Resp_code"] ?? "";
      String respDesc = response["Resp_desc"] ?? "";

      ConsoleLog.printColor("VERIFY LOGIN OTP Response Code: $respCode", color: "yellow");
      ConsoleLog.printColor("VERIFY LOGIN OTP Response Desc: $respDesc", color: "yellow");

      if (respCode == "RCS") {
        if (response["data"] == null || response["data"] is! Map) {
          Fluttertoast.showToast(msg: "Login failed: Invalid response");
          return;
        }

        LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);

        String token = loginResponse.data?.tokenid ?? "";
        String signature = loginResponse.data?.requestId ?? "";

        if (token.isEmpty) {
          Fluttertoast.showToast(msg: "Login failed: Invalid token");
          return;
        }

        // Save to SharedPreferences
        await AppSharedPreferences.saveLoginAuth(
          token: token,
          signature: signature,
        );

        // Save user details
        await AppSharedPreferences.setUserId(
            loginResponse.data?.userdata?.accountidf ?? ""
        );
        await AppSharedPreferences.setMobileNo(
            loginResponse.data?.userdata?.mobile ?? ""
        );
        await AppSharedPreferences.setEmail(
            loginResponse.data?.userdata?.email ?? ""
        );
        await AppSharedPreferences.setUserName(
            loginResponse.data?.userdata?.contactPerson ?? ""
        );
        await AppSharedPreferences.saveUserRole(
            loginResponse.data?.userdata?.roleidf ?? ""
        );

        // Start session
        if (Get.isRegistered<SessionManager>()) {
          await SessionManager.instance.startSession();
        }

        ConsoleLog.printSuccess("✅ Login successful after OTP verification: ${loginResponse.data?.userdata?.contactPerson}");

        Fluttertoast.showToast(
          msg: "Login successful! Welcome ${loginResponse.data?.userdata?.contactPerson}",
          toastLength: Toast.LENGTH_LONG,
        );
        
        // Navigate to Main Screen
        Get.offAll(() => PayrupyaMainScreen());
      } else {
        Fluttertoast.showToast(
          msg: respDesc.isNotEmpty ? respDesc : "OTP verification failed",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("VERIFY LOGIN OTP ERROR: $e");
      Fluttertoast.showToast(msg: "Technical issue. Please try again.");
    }
  }

  // ============================================
  // RESEND LOGIN OTP
  // ============================================
  Future<void> resendLoginOtp(BuildContext context, String mobile, String referenceId) async {
    try {
      CustomLoading.showLoading();

      Map<String, dynamic> requestBody = {
        "login": mobile,
        "referenceid": referenceId,
        "requestfor": "LOGIN",
        "request_id": GlobalUtils.generateRandomId(8),
        "lat": latitude.value.toString(),
        "long": longitude.value.toString(),
        "versionNew": 1,
      };

      ConsoleLog.printColor("RESEND LOGIN OTP REQ: $requestBody");

      var response = await ApiProvider().resendLoginOtpApi(
        context,
        WebApiConstant.API_URL_RESEND_LOGIN_OTP,
        requestBody,
        "",
      );

      CustomLoading.hideLoading();

      if (response == null) {
        Fluttertoast.showToast(msg: "No response from server");
        return;
      }

      String respCode = response["Resp_code"] ?? "";
      String respDesc = response["Resp_desc"] ?? "";

      ConsoleLog.printColor("RESEND LOGIN OTP Response Code: $respCode", color: "yellow");

      if (respCode == "RCS") {
        // Update reference ID if new one is provided
        String? newReferenceId = response["data"]?["referenceid"]?.toString();
        if (newReferenceId != null && newReferenceId.isNotEmpty) {
          loginOtpReferenceId.value = newReferenceId;
        }

        Fluttertoast.showToast(
          msg: "OTP sent successfully",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: respDesc.isNotEmpty ? respDesc : "Failed to resend OTP",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("RESEND LOGIN OTP ERROR: $e");
      Fluttertoast.showToast(msg: "Technical issue. Please try again.");
    }
  }
}
