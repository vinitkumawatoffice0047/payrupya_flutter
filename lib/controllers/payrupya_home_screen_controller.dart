import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:payrupya/view/home_screen.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/get_wallet_balance_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import 'login_controller.dart';

class PayrupyaHomeScreenController extends GetxController {
  LoginController loginController = Get.put(LoginController());
  HomeScreen homeScreen = Get.put(HomeScreen());
  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;
  RxString walletBalance = "".obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Services related variables
  RxList<dynamic> services = <dynamic>[].obs;
  RxBool isServicesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // _initWalletFlow();
    // getLocationAndLoadData();
    initializeHomeScreen();
  }

  // Initialize everything in sequence
  Future<void> initializeHomeScreen() async {
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

    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Error initializing home screen: $e");
      CustomDialog.error(message: "Error loading data: $e");
    }finally{
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
        getWalletBalance();
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

    } catch (e) {
      ConsoleLog.printError("Error loading auth credentials: $e");
    }
  }
  //endregion

  //region getAllowedServiceByType
  Future<void> getWalletBalance() async {
    try {
      CustomLoading.showLoading();
      // if (latitude.value == 0.0 || longitude.value == 0.0) {
      //   ConsoleLog.printInfo("Latitude: ${latitude.value}");
      //   ConsoleLog.printInfo("Longitude: ${longitude.value}");
      //   return;
      // }

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
        ConsoleLog.printInfo("Loading hidden2");

        if (apiResponse.respCode == "RCS" && apiResponse.data != null) {
          walletBalance.value = apiResponse.data!.balance.toString();
          ConsoleLog.printSuccess("Wallet balance: ₹${walletBalance.value}");
        } else {
          // Error case properly handled
          ConsoleLog.printError("Get Wallet Balance Error: ${apiResponse.respDesc}");
          CustomDialog.error(message: apiResponse.respDesc ?? "Failed to get wallet balance");
        }
      } else {
        ConsoleLog.printError("API Error: ${response?.statusCode}");
        CustomDialog.error(message: "Failed to get wallet balance");
      }
    } catch (e) {
      // Exception handled
      ConsoleLog.printError("GET WALLET BALANCE ERROR: $e");
      CustomDialog.error(message: "Error: $e");
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
}