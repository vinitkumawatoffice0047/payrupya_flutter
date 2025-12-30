import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:payrupya/models/check_fingpay_onboard_status_response_model.dart';
import 'package:payrupya/models/check_instantpay_bio_auth_status_response_model.dart';
import 'package:payrupya/models/check_instantpay_onboard_status_response_model.dart';
import 'package:payrupya/view/home_screen.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/check_fingpay_auth_status_response_model.dart';
import '../models/get_all_my_bank_list_response_model.dart';
import '../models/get_profile_data_response_model.dart';
import '../models/get_wallet_balance_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../view/aeps_choose_service_screen.dart';
import '../view/onboarding_screen.dart';
import 'aeps_controller.dart';
import 'login_controller.dart';
import 'session_manager.dart';

class PayrupyaHomeScreenController extends GetxController {
  // LoginController loginController = Get.put(LoginController());
  // final AepsController aepsController = Get.put(AepsController());
  LoginController get loginController => Get.find<LoginController>();
  AepsController get aepsController => Get.find<AepsController>();
  // HomeScreen homeScreen = Get.put(HomeScreen());
  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;
  RxString walletBalance = "".obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Services related variables
  RxList<dynamic> services = <dynamic>[].obs;
  RxBool isServicesLoading = false.obs;
  RxBool isInitialized = false.obs;

  // ✅ NEW: Loading states for AEPS APIs (to avoid CustomLoading during build)
  RxBool isFingpayOnboardCheckLoading = false.obs;
  RxBool isFingpay2FACheckLoading = false.obs;
  RxBool isInstantpayOnboardCheckLoading = false.obs;
  RxBool isInstantpay2FACheckLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // _initWalletFlow();
    // getLocationAndLoadData();
    // initializeHomeScreen();
  }

  // Initialize everything in sequence
  Future<void> initializeHomeScreen() async {
    // ✅ Prevent multiple initializations
    if (isInitialized.value) {
      ConsoleLog.printInfo("Already initialized, skipping...");
      return;
    }

    try {
      // 1. Get location first
      await getLocationAndLoadData();

      // 2. Then load services
      if (latitude.value != 0.0 && longitude.value != 0.0) {
        await loadAllowedServices();
      } else {
        // CustomLoading.hideLoading();
        ConsoleLog.printError("Location not available, cannot load services");
        CustomDialog.error(message: "Location not available. Please enable location services.");
      }
      isInitialized.value = true;
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Error initializing home screen: $e");
      // CustomDialog.error(message: "Error loading data: $e");
    }
    finally{
      CustomLoading.hideLoading();
    }
  }

  // Future<void> _initWalletFlow() async {
  //   await getLocationAndLoadData();       // 1️⃣ Pehle location
  //   _checkAndCallBalanceApi();  // 2️⃣ Phir API
  // }

  Future<void> getLocationAndLoadData() async {
    try {
      Position? position = await GlobalUtils.getLocation();
      if (position != null) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        ConsoleLog.printSuccess("Location updated: ${latitude.value}, ${longitude.value}");

        // Load auth credentials और balance
        await loadAuthCredentials();
        await getWalletBalance();
        await getProfileData();
        // await checkFingpayUserOnboardStatus();
        // await checkInstantpayUserOnboardStatus();
        await fetchMyBanks("true");
      } else {
        ConsoleLog.printError("Failed to get location");
      }
    } catch (e) {
      ConsoleLog.printError("Error in getLocationAndLoadData: $e");
    }
  }

  // void _checkAndCallBalanceApi() {
  //   ConsoleLog.printColor('🔍 CHECK -> Lat: ${latitude.value}, Lng: ${longitude.value}');
  //
  //   if (latitude.value == 0.0 || longitude.value == 0.0) {
  //     ConsoleLog.printColor('⚠️ API NOT CALLED: Location not ready');
  //     return;
  //   }
  //
  //   if (userAuthToken == null || userAuthToken!.isEmpty) {
  //     ConsoleLog.printColor('⚠️ API NOT CALLED: Token missing');
  //     return;
  //   }
  // }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  //region loadAuthCredentials
  // Load both token and signature properly
  Future<void> loadAuthCredentials() async {
    try {
      Map<String, String> authData = await AppSharedPreferences.getLoginAuth();
      userAuthToken.value = authData["token"] ?? "";
      userSignature.value = authData["signature"] ?? "";

      ConsoleLog.printInfo("Token: ${userAuthToken.value.isNotEmpty ? 'Found' : 'NOT FOUND'}");
      ConsoleLog.printInfo("Signature: ${userSignature.value.isNotEmpty ? 'Found' : 'NOT FOUND'}");

      // Debug: Print first 20 chars
      if (userAuthToken.value.isNotEmpty) {
        int tokenLength = userAuthToken.value.length;
        int previewLength = tokenLength > 20 ? 20 : tokenLength;
        if (previewLength > 0) {
          ConsoleLog.printColor("Token Preview: ${userAuthToken.value.substring(0, previewLength)}...", color: "cyan");
        }
      }

      if (userSignature.value.isNotEmpty) {
        int signatureLength = userSignature.value.length;
        int previewLength = signatureLength > 20 ? 20 : signatureLength;
        if (previewLength > 0) {
          ConsoleLog.printColor("Signature Preview: ${userSignature.value.substring(0, previewLength)}...", color: "cyan");
        }
      }

      // ✅ NEW: Debug full signature to verify
      ConsoleLog.printColor("=== AUTH DEBUG ===", color: "yellow");
      ConsoleLog.printColor("Full Token: ${userAuthToken.value}", color: "cyan");
      ConsoleLog.printColor("Full Signature: ${userSignature.value}", color: "cyan");
      ConsoleLog.printColor("=== END AUTH DEBUG ===", color: "yellow");
    } catch (e) {
      ConsoleLog.printError("Error loading auth credentials: $e");
    }
  }
  //endregion

  //region isTokenValid
  Future<bool> isTokenValid() async {
    // Reload credentials first
    await loadAuthCredentials();

    if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
      ConsoleLog.printError("❌ Token or Signature missing");
      ConsoleLog.printError("Token Length: ${userAuthToken.value.length}");
      ConsoleLog.printError("Signature Length: ${userSignature.value.length}");
      return false;
    }
    return true;
  }
  //endregion

  //region refreshToken
  Future<void> refreshToken(BuildContext context) async {
    ConsoleLog.printWarning("⚠️ Token expired, please login again");
    // ✅ Session ko properly end karo
    if (Get.isRegistered<SessionManager>()) {
      await SessionManager.instance.endSession();
      Get.delete<SessionManager>(force: true);
    }
    await AppSharedPreferences.clearSessionOnly();
    Get.offAll(() => OnboardingScreen());
    Fluttertoast.showToast(msg: "Session expired. Please login again.");
  }
  //endregion

  //region getWalletBalance
  Future<void> getWalletBalance() async {
    try {
      CustomLoading.showLoading();

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        CustomDialog.error(message: "Authentication required!");
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_WALLET_BALANCE,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("Get Wallet Balance Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("Get Wallet Balance Response: ${jsonEncode(response.data)}");

        GetWalletBalanceResponseModel apiResponse =
        GetWalletBalanceResponseModel.fromJson(response.data);
        CustomLoading.hideLoading();

        if (apiResponse.respCode == "RCS" && apiResponse.data != null) {
          walletBalance.value = apiResponse.data!.balance.toString();
          ConsoleLog.printSuccess("Wallet balance: ₹${walletBalance.value}");
        } else {
          // Error case properly handled
          ConsoleLog.printError("Get Wallet Balance Error: ${apiResponse.respDesc}");
          // CustomDialog.error(message: apiResponse.respDesc ?? "Failed to get wallet balance");
          // ✅ Check if it's an auth error
          if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
            ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
            ConsoleLog.printError("Please re-login to get fresh credentials");
          }
        }
      } else {
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        // CustomDialog.error(message: "Failed to get wallet balance");
      }
    } catch (e) {
      // Exception handled
      ConsoleLog.printError("GET WALLET BALANCE ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion

  //region getProfileData
  Future<void> getProfileData() async {
    try {
      CustomLoading.showLoading();

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        CustomDialog.error(message: "Authentication required!");
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_PROFILE_DATA,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("Get Profile Data Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("Get Profile Data Response: ${jsonEncode(response.data)}");

        GetProfileDataResponseModel apiResponse =
        GetProfileDataResponseModel.fromJson(response.data);
        CustomLoading.hideLoading();

        if (apiResponse.respCode == 'RCS') {
          // Initialize user data in AepsController
          aepsController.initializeUserData(
            aadhaar: apiResponse.data?.aadhaar ?? "",
            mobile: apiResponse.data?.mobile ?? "",
            email: apiResponse.data?.emailId ?? "",
            pan: apiResponse.data?.pan ?? "",
            firstName: apiResponse.data?.firstName ?? "",
            lastName: apiResponse.data?.lastName ?? "",
            shopName: apiResponse.data?.shopName ?? "",
            state: apiResponse.data?.shopState ?? "",
            city: apiResponse.data?.shopCity ?? "",
            pincode: apiResponse.data?.shopPincode ?? "",
            shopAddress: apiResponse.data?.shopAddr ?? "",
            gstin: apiResponse.data?.gstin ?? "",
          );
        } else {
          ConsoleLog.printError("Get Profile Data Error: ${apiResponse.respDesc}");
        }
        // if (apiResponse.respCode == "RCS" && apiResponse.data != null) {
        //   aepsController.firstNameController.value.text = apiResponse.data?.firstName ?? "";
        //   aepsController.lastNameController.value.text = apiResponse.data?.lastName ?? "";
        //   aepsController.shopNameController.value.text = apiResponse.data?.shopName ?? "";
        //   aepsController.emailController.value.text = apiResponse.data?.emailId ?? "";
        //   aepsController.mobileController.value.text = apiResponse.data?.mobile ?? "";
        //   aepsController.panController.value.text = apiResponse.data?.pan ?? "";
        //   aepsController.aadhaarController.value.text = apiResponse.data?.aadhaar ?? "";
        //   aepsController.gstController.value.text = apiResponse.data?.gstin ?? "";
        //   aepsController.stateController.value.text = apiResponse.data?.shopState ?? "";
        //   aepsController.cityController.value.text = apiResponse.data?.shopCity ?? "";
        //   aepsController.pincodeController.value.text = apiResponse.data?.shopPincode ?? "";
        //   aepsController.shopAddressController.value.text = apiResponse.data?.shopAddr ?? "";
        // } else {
        //   // Error case properly handled
        //   ConsoleLog.printError("Get Profile Data Error: ${apiResponse.respDesc}");
        //   CustomDialog.error(message: apiResponse.respDesc ?? "Failed to get profile data");
        //   // ✅ Check if it's an auth error
        //   if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
        //     ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
        //     ConsoleLog.printError("Please re-login to get fresh credentials");
        //   }
        // }
      } else {
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        // CustomDialog.error(message: "Failed to get profile data");
      }
    } catch (e) {
      // Exception handled
      ConsoleLog.printError("GET PROFILE DATA ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion

  //region checkFingpayUserOnboardStatus
  Future<void> checkFingpayUserOnboardStatus() async {
    try {
      // CustomLoading.showLoading();
      // ✅ Use RxBool instead of CustomLoading
      isFingpayOnboardCheckLoading.value = true;
      aepsController.isFingpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpayOnboardCheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
        // CustomDialog.error(message: "No Internet Connection!");
        // return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpayOnboardCheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;
        throw Exception("Authentication required!");
        // CustomDialog.error(message: "Authentication required!");
        // return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_CHECK_FINGPAY_USER_ONBOARD_STATUS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkFingpayUserOnboardStatus Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkFingpayUserOnboardStatus Response: ${jsonEncode(response.data)}");

        CheckFingpayOnboardStatusResponseModel apiResponse =
        CheckFingpayOnboardStatusResponseModel.fromJson(response.data);
        // CustomLoading.hideLoading();
        isFingpayOnboardCheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;

        if (apiResponse.needsOnboarding) {
          ConsoleLog.printWarning("⚠️ User not onboarded - Show onboarding form");
          aepsController.showFingpayOnboardingForm.value = true;
          aepsController.showFingpay2FAForm.value = false;
          aepsController.showFingpayOnboardAuthForm.value = false;
        } else if(apiResponse.isActiveUser) {
          ConsoleLog.printSuccess("✅ User onboarded - Check 2FA status");
          print("User ID: ${apiResponse.onboardData?.userId}");
          print("Agent ID: ${apiResponse.onboardData?.agentId}");
          // ✅ Call 2FA check after a small delay to avoid build issues
          await Future.delayed(Duration(milliseconds: 100));
          await checkFingpay2FAAuthStatus();
        }else{
          ConsoleLog.printError("checkFingpayUserOnboardStatus Error: ${apiResponse.respDesc}");
          throw Exception(apiResponse.respDesc ?? "Failed to check onboard status");
          // ConsoleLog.printError("checkFingpayUserOnboardStatus Error: ${apiResponse.respDesc}");
          // CustomDialog.error(message: apiResponse.respDesc ?? "Failed to checkFingpayUserOnboardStatus");
          // // ✅ Check if it's an auth error
          // if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
          //   ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
          //   ConsoleLog.printError("Please re-login to get fresh credentials");
          // }
        }
      } else {
        isFingpayOnboardCheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        throw Exception("Failed to check onboard status");
        // ConsoleLog.printError("API Error: ${response?.statusCode}");
        // CustomDialog.error(message: "Failed to checkFingpayUserOnboardStatus");
      }
    } catch (e) {
      isFingpayOnboardCheckLoading.value = false;
      aepsController.isFingpayLoading.value = false;
      ConsoleLog.printError("checkFingpayUserOnboardStatus ERROR: $e");
      rethrow; // ✅ Rethrow so FutureBuilder can catch it
      // // Exception handled
      // ConsoleLog.printError("checkFingpayUserOnboardStatus ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion

  //region checkFingpay2FAAuthStatus
  Future<void> checkFingpay2FAAuthStatus() async {
    try {
      // CustomLoading.showLoading();
      isFingpay2FACheckLoading.value = true;
      aepsController.isFingpayLoading.value = true;
      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpay2FACheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
        // CustomDialog.error(message: "No Internet Connection!");
        // return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpay2FACheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;
        throw Exception("Authentication required!");
        // CustomDialog.error(message: "Authentication required!");
        // return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_CHECK_FINGPAY_2FA_AUTH_STATUS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkFingpay2FAAuthStatus Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkFingpay2FAAuthStatus Response: ${jsonEncode(response.data)}");

        CheckFingpayAuthStatusResponseModel apiResponse =
        CheckFingpayAuthStatusResponseModel.fromJson(response.data);
        // CustomLoading.hideLoading();
        isFingpay2FACheckLoading.value = false;
        aepsController.isFingpayLoading.value = false;

        if (apiResponse.isSuccess) {
          // Update state based on response
          aepsController.isFingpay2FACompleted.value = apiResponse.is2FACompleted;
          aepsController.fingpayAuthData.value = apiResponse.authData;
          if (apiResponse.needs2FA) {
            // 2FA NOT completed today - Show 2FA form
            ConsoleLog.printWarning("⚠️ 2FA not completed - Show fingerprint authentication");
            aepsController.showFingpay2FAForm.value = true;
            aepsController.showFingpayOnboardingForm.value = false;
            aepsController.showFingpayOnboardAuthForm.value = false;
            aepsController.canProceedToFingpayServices.value = false;
          } else if (apiResponse.canProceedToTransaction) {
            // 2FA IS completed today - Navigate to Choose Service
            ConsoleLog.printSuccess("✅ 2FA completed - Navigate to Choose Service Screen");
            aepsController.showFingpay2FAForm.value = false;
            aepsController.showFingpayOnboardingForm.value = false;
            aepsController.showFingpayOnboardAuthForm.value = false;
            aepsController.canProceedToFingpayServices.value = true;

            // ✅ Navigate after build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS1'));
            });
            // Log vendor response details
            if (apiResponse.authData?.vendorResponse != null) {
              var vendorData = apiResponse.authData!.vendorResponse!.data;
              ConsoleLog.printSuccess("📱 Transaction ID: ${vendorData?.fingpayTransactionId}");
              ConsoleLog.printSuccess("📱 Mobile: ${vendorData?.mobileNumber}");
            }
          } else {
            ConsoleLog.printError("checkFingpay2FAAuthStatus Error: ${apiResponse.respDesc}");
            // CustomDialog.error(message: apiResponse.respDesc ?? "Failed to checkFingpay2FAAuthStatus");
            // ✅ Check if it's an auth error
            if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
              ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
              ConsoleLog.printError("Please re-login to get fresh credentials");
            }
          }
        }else {
          isFingpay2FACheckLoading.value = false;
          aepsController.isFingpayLoading.value = false;
          ConsoleLog.printError("API Error: ${response?.statusCode}");
          Fluttertoast.showToast(msg: "Failed to check 2FA status");
          // API returned error
          // Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Error checking 2FA status");
        }
      }
    } catch (e) {
      isFingpay2FACheckLoading.value = false;
      aepsController.isFingpayLoading.value = false;
      ConsoleLog.printError("checkFingpay2FAAuthStatus ERROR: $e");
      // // Exception handled
      // ConsoleLog.printError("checkFingpay2FAAuthStatus ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion

  //region checkInstantpayUserOnboardStatus
  Future<void> checkInstantpayUserOnboardStatus() async {
    try {
      // CustomLoading.showLoading();
      isInstantpayOnboardCheckLoading.value = true;
      aepsController.isInstantpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isInstantpayOnboardCheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        throw Exception("No Internet Connection!");
        // CustomDialog.error(message: "No Internet Connection!");
        // return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isInstantpayOnboardCheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        throw Exception("Authentication required!");
        // CustomDialog.error(message: "Authentication required!");
        // return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_CHECK_INSTANTPAY_USER_ONBOARD_STATUS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkInstantpayUserOnboardStatus Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkInstantpayUserOnboardStatus Response: ${jsonEncode(response.data)}");

        CheckInstantpayOnboardStatusResponseModel apiResponse =
        CheckInstantpayOnboardStatusResponseModel.fromJson(response.data);
        // CustomLoading.hideLoading();
        isInstantpayOnboardCheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;

        if (apiResponse.needsOnboarding) {
          ConsoleLog.printWarning("⚠️ User not onboarded - Show onboarding form");
          aepsController.showInstantpayOnboardingForm.value = true;
          aepsController.showInstantpay2FAForm.value = false;
          aepsController.showInstantpayOnboardAuthForm.value = false;
        } else if(apiResponse.isActiveUser) {
          print("User ID: ${apiResponse.onboardData?.userId}");
          print("Agent ID: ${apiResponse.onboardData?.agentId}");
          await Future.delayed(Duration(milliseconds: 100));
          await checkInstantpay2FAAuthStatus();
        }else{
          ConsoleLog.printError("checkInstantpayUserOnboardStatus Error: ${apiResponse.respDesc}");
          if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
            ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
            ConsoleLog.printError("Please re-login to get fresh credentials");
          }
          // ConsoleLog.printError("checkInstantpayUserOnboardStatus Error: ${apiResponse.respDesc}");
          // CustomDialog.error(message: apiResponse.respDesc ?? "Failed to checkInstantpayUserOnboardStatus");
          // // ✅ Check if it's an auth error
          // if (apiResponse.respDesc?.toLowerCase().contains('unauthorized') == true) {
          //   ConsoleLog.printError("❌ UNAUTHORIZED - Token or Signature is invalid!");
          //   ConsoleLog.printError("Please re-login to get fresh credentials");
          // }
        }
      } else {
        isInstantpayOnboardCheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        throw Exception("Failed to check onboard status");
        // ConsoleLog.printError("API Error: ${response?.statusCode}");
        // CustomDialog.error(message: "Failed to checkInstantpayUserOnboardStatus");
      }
    } catch (e) {
      isInstantpayOnboardCheckLoading.value = false;
      aepsController.isInstantpayLoading.value = false;
      ConsoleLog.printError("checkInstantpayUserOnboardStatus ERROR: $e");
      rethrow;
      // // Exception handled
      // ConsoleLog.printError("checkInstantpayUserOnboardStatus ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion

  //region checkInstantpay2FAAuthStatus
  Future<void> checkInstantpay2FAAuthStatus() async {
    try {
      // CustomLoading.showLoading();
      isInstantpay2FACheckLoading.value = true;
      aepsController.isInstantpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isInstantpay2FACheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        throw Exception("No Internet Connection!");
        // CustomDialog.error(message: "No Internet Connection!");
        // return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isInstantpay2FACheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        throw Exception("Authentication required!");
        // CustomDialog.error(message: "Authentication required!");
        // return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_CHECK_INSTANTPAY_2FA_AUTH_STATUS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkInstantpay2FAAuthStatus Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkInstantpay2FAAuthStatus Response: ${jsonEncode(response.data)}");

        CheckInstantpayBioAuthStatusResponseModel apiResponse =
        CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        // CustomLoading.hideLoading();
        isInstantpay2FACheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;

        if (apiResponse.isSuccess) {
          // Update state based on response
          aepsController.isInstantpay2FACompleted.value = apiResponse.is2FACompleted;
          aepsController.instantpayAuthData.value = apiResponse.authData;
          if (apiResponse.needs2FA) {
            // 2FA NOT completed today - Show 2FA form
            ConsoleLog.printWarning("⚠️ 2FA not completed - Show fingerprint authentication");
            aepsController.showInstantpay2FAForm.value = true;
            aepsController.showInstantpayOnboardingForm.value = false;
            aepsController.showInstantpayOnboardAuthForm.value = false;
            aepsController.canProceedToInstantpayServices.value = false;
          } else if (apiResponse.canProceedToTransaction) {
            // 2FA IS completed today - Navigate to Choose Service
            ConsoleLog.printSuccess("✅ 2FA completed - Navigate to Choose Service Screen");
            aepsController.showInstantpay2FAForm.value = false;
            aepsController.showInstantpayOnboardingForm.value = false;
            aepsController.showInstantpayOnboardAuthForm.value = false;
            aepsController.canProceedToInstantpayServices.value = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
            });

            // Log vendor response details
            if (apiResponse.authData?.vendorResponse != null) {
              var vendorData = apiResponse.authData!.vendorResponse!.data;
              ConsoleLog.printSuccess("📱 Pool Reference ID: ${vendorData?.poolReferenceId}");
              ConsoleLog.printSuccess("💰 Opening Balance: ${vendorData?.pool?.openingBalance}");
              ConsoleLog.printSuccess("💰 Closing Balance: ${vendorData?.pool?.closingBalance}");
            }
          }
        }else {
          // API returned error
          Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Error checking 2FA status");
        }
      } else {
        isInstantpay2FACheckLoading.value = false;
        aepsController.isInstantpayLoading.value = false;
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to check 2FA status");
        // ConsoleLog.printError("API Error: ${response?.statusCode}");
        // Fluttertoast.showToast(msg: "Failed to check 2FA status");
      }
    } catch (e) {
      isInstantpay2FACheckLoading.value = false;
      aepsController.isInstantpayLoading.value = false;
      ConsoleLog.printError("checkInstantpay2FAAuthStatus ERROR: $e");
      // // Exception handled
      // ConsoleLog.printError("checkInstantpay2FAAuthStatus ERROR: $e");
      // CustomDialog.error(message: "Error: $e");
    }
  }
  //endregion


  //region fetchMyBanks
  Future<void> fetchMyBanks(String allBanksList) async {
    try {
      CustomLoading.showLoading();

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        CustomDialog.error(message: "Authentication required!");
        return;
      }

      Map<String, dynamic> dict = {
        "request_id": generateRequestId(),
        "lat": latitude.value.toString(),
        "long": longitude.value.toString(),
        "all_banks_list": allBanksList
      };

      ConsoleLog.printColor("Fetching my banks list Data Request: ${jsonEncode(dict)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_ALL_MY_BANK_LIST,
        dict,
        userAuthToken.value,
        userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        // Parse using model
        GetAllMyBankListResponseModel getAllMyBanksResponse = GetAllMyBankListResponseModel.fromJson(data);
        CustomLoading.hideLoading();

        if (getAllMyBanksResponse.respCode == 'RCS' && getAllMyBanksResponse.data != null) {
          aepsController.myBankList.assignAll(getAllMyBanksResponse.data!);
          aepsController.filteredBankList.assignAll(getAllMyBanksResponse.data!);
          ConsoleLog.printSuccess("My Banks List loaded: ${aepsController.myBankList.length}");
        }
        else {
          Fluttertoast.showToast(msg: getAllMyBanksResponse.respDesc ?? "Failed to load banks list");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error fetching my bank list: $e");
      Fluttertoast.showToast(msg: "Error loading banks list");
    }
  }
  //endregion

  //region loadAllowedServices
  Future<void> loadAllowedServices() async {
    try {
      isServicesLoading.value = true;
      ConsoleLog.printInfo("Loading services...");

      // Check auth credentials
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Cannot load services - auth credentials missing");
        isServicesLoading.value = false;
        return;
      }

      // Check internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        isServicesLoading.value = false;
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": latitude.value,
        "long": longitude.value,
        "type": "REMITTANCE"
      };

      ConsoleLog.printColor("Services Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_SERVICE_TYPE,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("Services Response: ${jsonEncode(response.data)}");

        var responseData = response.data;
        if (responseData['Resp_code'] == 'RCS' && responseData['data'] != null) {
          services.value = responseData['data'];
          ConsoleLog.printSuccess("Services loaded: ${services.length}");
        } else {
          ConsoleLog.printError("Services Error: ${responseData['Resp_desc']}");
        }
      } else {
        ConsoleLog.printError("Services API Error: ${response?.statusCode}");
      }

    } catch (e) {
      ConsoleLog.printError("Error loading services: $e");
    } finally {
      isServicesLoading.value = false;
      CustomLoading.hideLoading();
      ConsoleLog.printInfo("Services loading completed");
    }
  }
  //endregion

  // ✅ NEW: Reset initialization state (useful for re-login)
  void resetInitialization() {
    isInitialized.value = false;
    walletBalance.value = "";
    services.clear();
  }
}