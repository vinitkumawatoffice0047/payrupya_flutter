import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:payrupya/controllers/login_controller.dart';
import 'package:payrupya/controllers/payrupya_home_screen_controller.dart';

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/check_fingpay_auth_status_response_model.dart';
import '../models/check_instantpay_bio_auth_status_response_model.dart';
import '../models/get_all_my_bank_list_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/global_utils.dart';
import '../view/onboarding_screen.dart';
import 'session_manager.dart';

/// AEPS Controller for handling both AEPS One (Fingpay) and AEPS Three (Instantpay)
class AepsController extends GetxController {
  // ============== State Variables ==============
  
  // Loading states
  RxBool isFingpayLoading = false.obs;
  RxBool isInstantpayLoading = false.obs;
  RxBool isFingpayOnboardingLoading = false.obs;
  RxBool isInstantpayOnboardingLoading = false.obs;
  RxBool isFingpayTransactionLoading = false.obs;
  RxBool isInstantpayTransactionLoading = false.obs;
  RxBool isFingpayRegisterOnboardingLoading = false.obs;
  RxBool isInstantpayRegisterOnboardingLoading = false.obs;
  RxBool isFingpayVerifyOnboardingOTPLoading = false.obs;
  RxBool isInstantpayVerifyOnboardingOTPLoading = false.obs;
  RxBool isFingpay_e_KYC_OnboardingLoading = false.obs;
  RxBool isInstantpay_e_KYC_OnboardingLoading = false.obs;
  RxBool isFingpay2FA_ProcessLoading = false.obs;
  RxBool isInstantpay2FA_ProcessLoading = false.obs;
  RxBool isCheckBalanceFingpayLoading = false.obs;
  RxBool isCheckBalanceInstantpayLoading = false.obs;
  RxBool isCashWithdrawalFingpayLoading = false.obs;
  RxBool isCashWithdrawalInstantpayLoading = false.obs;
  RxBool isMiniStatementFingpayLoading = false.obs;
  RxBool isMiniStatementInstantpayLoading = false.obs;
  RxBool isAadhaarPayFingpayLoading = false.obs;
  RxBool isAadhaarPayInstantpayLoading = false.obs;
  RxBool isGetAepsBanklistLoading = false.obs;
  RxBool isGetRecentTransactionsLoading = false.obs;
  RxBool isCheckBalanceOrMiniStatementLoading = false.obs;
  RxBool isMarkFavoriteBankLoading = false.obs;
  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;

  // Onboarding states
  RxBool isFingpayOnboarded = false.obs;
  RxBool isInstantpayOnboarded = false.obs;
  RxBool isFingpayTwoFactorAuthenticated = false.obs;
  RxBool isInstantTwoFactorAuthenticated = false.obs;
  RxBool showFingpayOnboardingForm = false.obs;
  RxBool showInstantpayOnboardingForm = false.obs;
  RxBool showFingpay2FAForm = false.obs;
  RxBool showInstantpay2FAForm = false.obs;
  RxBool showFingpayOtpModal = false.obs;
  RxBool showInstantpayOtpModal = false.obs;
  RxBool showFingpayOnboardAuthForm = false.obs; // For Fingpay eKYC auth
  RxBool showInstantpayOnboardAuthForm = false.obs; // For Fingpay eKYC auth
  RxBool canProceedToFingpayServices = false.obs;
  RxBool canProceedToInstantpayServices = false.obs;

  // Fingpay 2FA States
  RxBool isFingpay2FACompleted = false.obs;
  Rxn<FingpayAuthData> fingpayAuthData = Rxn<FingpayAuthData>();

  // Instantpay 2FA States
  RxBool isInstantpay2FACompleted = false.obs;
  Rxn<InstantpayAuthData> instantpayAuthData = Rxn<InstantpayAuthData>();

  // Service Selection
  RxString selectedService = 'balanceCheck'.obs;
  RxBool showAmountInput = false.obs;

  // Bank related
  RxList<AepsBank> allBankList = <AepsBank>[].obs;
  RxList<AepsBank> favoritesList = <AepsBank>[].obs;
  RxString selectedBankName = ''.obs;
  RxString selectedBankId = ''.obs;
  RxString selectedBankIin = ''.obs;

  // My Bank List (for Fingpay)
  RxList<GetAllMyBankListData> myBankList = <GetAllMyBankListData>[].obs;
  Rx<GetAllMyBankListData?> selectedMyBank = Rx<GetAllMyBankListData?>(null);
  RxList<GetAllMyBankListData> filteredBankList = <GetAllMyBankListData>[].obs;
  final TextEditingController searchCtrl = TextEditingController();
  // RxList<MyBankAccount> myBankList = <MyBankAccount>[].obs;
  // Rx<MyBankAccount?> selectedMyBank = Rx<MyBankAccount?>(null);

  // Transaction data
  Rx<AepsConfirmData?> confirmationData = Rx<AepsConfirmData?>(null);
  Rx<AepsTransactionData?> transactionResult = Rx<AepsTransactionData?>(null);
  RxList<RecentTransaction> recentTransactions = <RecentTransaction>[].obs;

  // OTP Reference data
  Rx<AepsOnboardingData?> otpReference = Rx<AepsOnboardingData?>(null);

  // Modal states
  RxBool showConfirmationModal = false.obs;
  RxBool showResultModal = false.obs;

  // Device list
  final List<Map<String, String>> deviceList = [
    {'name': 'Select Device', 'value': ''},
    {'name': 'Mantra', 'value': 'MANTRA'},
    {'name': 'Mantra MFS110', 'value': 'MFS110'},
    {'name': 'Mantra Iris', 'value': 'MIS100V2'},
    {'name': 'Morpho L0', 'value': 'MORPHO'},
    {'name': 'Morpho L1', 'value': 'Idemia'},
    {'name': 'TATVIK', 'value': 'TATVIK'},
    {'name': 'Secugen', 'value': 'SecuGen Corp.'},
    {'name': 'Startek', 'value': 'STARTEK'},
  ];

  // ============== Form Controllers ==============

  // Authentication Form
  Rx<TextEditingController> aadhaarController = TextEditingController(text: "").obs;
  Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
  Rx<TextEditingController> selectedDeviceController = TextEditingController(text: "").obs;
  RxString selectedDevice = ''.obs;

  // Onboarding Form (Instantpay)
  Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
  Rx<TextEditingController> panController = TextEditingController(text: "").obs;
  Rx<TextEditingController> bankAccountController = TextEditingController(text: "").obs;
  Rx<TextEditingController> ifscController = TextEditingController(text: "").obs;

  // Onboarding Form (Fingpay - additional fields)
  Rx<TextEditingController> firstNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> lastNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> shopNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> gstController = TextEditingController(text: "").obs;
  Rx<TextEditingController> stateController = TextEditingController(text: "").obs;
  Rx<TextEditingController> cityController = TextEditingController(text: "").obs;
  Rx<TextEditingController> pincodeController = TextEditingController(text: "").obs;
  Rx<TextEditingController> shopAddressController = TextEditingController(text: "").obs;

  // OTP Controller
  Rx<TextEditingController> otpController = TextEditingController(text: "").obs;

  // Service Form
  Rx<TextEditingController> serviceAadhaarController = TextEditingController(text: "").obs;
  Rx<TextEditingController> serviceMobileController = TextEditingController(text: "").obs;
  Rx<TextEditingController> serviceAmountController = TextEditingController(text: "").obs;
  RxString serviceSelectedDevice = ''.obs;

  // Transaction PIN
  Rx<TextEditingController> txnPinController = TextEditingController(text: "").obs;

  // LoginController loginController = Get.put(LoginController());
  // PayrupyaHomeScreenController homeScreenController = Get.put(PayrupyaHomeScreenController());
  PayrupyaHomeScreenController get homeScreenController => Get.find<PayrupyaHomeScreenController>();

  // ============== Lifecycle ==============

  @override
  void onInit() {
    super.onInit();
    filteredBankList.assignAll(myBankList);
  }

  void filterBank(String query) {
    if (query.isEmpty) {
      filteredBankList.assignAll(myBankList);
    } else {
      filteredBankList.assignAll(
        myBankList.where(
              (bank) =>
          bank.bankName
              ?.toLowerCase()
              .contains(query.toLowerCase()) ??
              false,
        ),
      );
    }
  }

  // ============== Initialize User Data ==============

  void initializeUserData({
    required String aadhaar,
    required String mobile,
    required String email,
    required String pan,
    required String firstName,
    required String lastName,
    required String shopName,
    required String state,
    required String city,
    required String pincode,
    required String shopAddress,
    required String gstin,
  }) {
    aadhaarController.value.text = aadhaar;
    mobileController.value.text = mobile;
    emailController.value.text = email;
    panController.value.text = pan;
    firstNameController.value.text = firstName;
    lastNameController.value.text = lastName;
    shopNameController.value.text = shopName;
    stateController.value.text = state;
    cityController.value.text = city;
    pincodeController.value.text = pincode;
    shopAddressController.value.text = shopAddress;
    gstController.value.text = gstin;
  }

  // ============== API Calls ==============

  // Generate Request ID
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }

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

  // ============== API Integrations ==============

  //region registerOnboarding
  Future<void> registerFingpayOnboarding() async {
    try {
      isFingpayRegisterOnboardingLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpayRegisterOnboardingLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpayRegisterOnboardingLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "REGISTERUSER",
        "bank_id": selectedMyBank.value?.aepsBankid,
        "aadhar": aadhaarController.value,
        "gstin": gstController.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("registerOnboarding Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("registerOnboarding Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isFingpayRegisterOnboardingLoading.value = false;

        // Response Handling:
          // Resp_code == "RCS" → OTP Sent, save reference data:
            //   - primaryKeyId = res.data['primaryKeyId']
            //   - encodeFPTxnId = res.data['encodeFPTxnId']
          // Resp_code == "RLD" → Already registered, go to 2FA

        // if (apiResponse.isSuccess) {
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to process AEPS registration.");
        // }
      } else {
        isFingpayRegisterOnboardingLoading.value = false;
        ConsoleLog.printError("registerOnboarding API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to process AEPS registration.");
      }
    } catch (e) {
      isFingpayRegisterOnboardingLoading.value = false;
      ConsoleLog.printError("registerOnboarding ERROR: $e");
    }
  }
  //endregion

  //region verifyFingpayOnboardingOTP
  Future<void> verifyFingpayOnboardingOTP() async {
    try {
      isFingpayVerifyOnboardingOTPLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "VERIFYONBOARDOTP",
        "otp": otpController.value,
        "otp_ref_data": {
          "primaryKeyId": "",//reference['primaryKeyId'],
          "encodeFPTxnId": "",//reference['encodeFPTxnId'],
        },
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("verifyFingpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("verifyFingpayOnboardingOTP Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isFingpayVerifyOnboardingOTPLoading.value = false;

        // Resp_code == "RCS" → OTP Verified, proceed to eKYC (fingerprint)

        // if (apiResponse.isSuccess) {
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to verify OTP.");
        // }
      } else {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        ConsoleLog.printError("verifyFingpayOnboardingOTP API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send your request.");
      }
    } catch (e) {
      isFingpayVerifyOnboardingOTPLoading.value = false;
      ConsoleLog.printError("verifyFingpayOnboardingOTP ERROR: $e");
    }
  }
  //endregion

  //region resendFingpayOnboardingOTP
  Future<void> resendFingpayOnboardingOTP() async {
    try {
      isFingpayVerifyOnboardingOTPLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "RESENDOTP",
        "primaryKeyId": "", //reference['primaryKeyId'],
        "encodeFPTxnId": "", //reference['encodeFPTxnId'],
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("resendFingpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("resendFingpayOnboardingOTP Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isFingpayVerifyOnboardingOTPLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "OTP sent successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send OTP request.");
        // }
      } else {
        isFingpayVerifyOnboardingOTPLoading.value = false;
        ConsoleLog.printError("resendFingpayOnboardingOTP API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send OTP request.");
      }
    } catch (e) {
      isFingpayVerifyOnboardingOTPLoading.value = false;
      ConsoleLog.printError("resendFingpayOnboardingOTP ERROR: $e");
    }
  }
  //endregion

  //region eKYCProcessFingpayOnboarding
  Future<void> eKYCProcessFingpayOnboarding() async {
    try {
      isFingpay_e_KYC_OnboardingLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpay_e_KYC_OnboardingLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpay_e_KYC_OnboardingLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "PROCESSEKYC",
        "aadhar": aadhaarController.value,
        "account_no": selectedMyBank.value?.accountNo,
        "ifsc": selectedMyBank.value?.ifsc,
        "bank_id": selectedMyBank.value?.aepsBankid,
        "otp_ref_data": {
          "primaryKeyId": "", //reference['primaryKeyId'],
          "encodeFPTxnId": "", //reference['encodeFPTxnId'],
        },
        "encdata": ""//fingerprintData,  // Base64 fingerprint from device
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("eKYCProcessFingpayOnboarding Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("eKYCProcessFingpayOnboarding Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isFingpay_e_KYC_OnboardingLoading.value = false;

        // Resp_code == "RCS" → Onboarding Complete, go to 2FA

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "eKYC successfully completed!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send eKYC request.");
        // }
      } else {
        isFingpay_e_KYC_OnboardingLoading.value = false;
        ConsoleLog.printError("eKYCProcessFingpayOnboarding API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send eKYC request.");
      }
    } catch (e) {
      isFingpay_e_KYC_OnboardingLoading.value = false;
      ConsoleLog.printError("eKYCProcessFingpayOnboarding ERROR: $e");
    }
  }
  //endregion

  //region fingpayTwoFA_Process
  Future<void> fingpayTwoFA_Process() async {
    try {
      isFingpay2FA_ProcessLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpay2FA_ProcessLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpay2FA_ProcessLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,      // "MANTRA", "MORPHO", etc.
        "aadhar_no": aadhaarController.value,
        "skey": "TWOFACTORAUTH",
        "encdata": "",//fingerprintData,    // Base64 fingerprint
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_2FA_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("fingpayTwoFA_Process Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("fingpayTwoFA_Process Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isFingpay2FA_ProcessLoading.value = false;

        // Resp_code == "RCS" → 2FA Success, navigate to Choose Service Screen

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "2FA successfully completed!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send 2FA Request..");
        // }
      } else {
        isFingpay2FA_ProcessLoading.value = false;
        ConsoleLog.printError("fingpayTwoFA_Process API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
      }
    } catch (e) {
      isFingpay2FA_ProcessLoading.value = false;
      ConsoleLog.printError("fingpayTwoFA_Process ERROR: $e");
    }
  }
  //endregion

  //region getAepsBanklist
  Future<void> getAepsBanklist() async {
    try {
      isGetAepsBanklistLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isGetAepsBanklistLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isGetAepsBanklistLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_AEPS_BANK_LIST,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("getAepsBanklist Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("getAepsBanklist Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isGetAepsBanklistLoading.value = false;

        // Response: res.data = List of AEPS banks with bank_iin

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "AEPS Bank List loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load AEPS Bank List.");
        // }
      } else {
        isGetAepsBanklistLoading.value = false;
        ConsoleLog.printError("getAepsBanklist API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load AEPS Bank List.");
      }
    } catch (e) {
      isGetAepsBanklistLoading.value = false;
      ConsoleLog.printError("getAepsBanklist ERROR: $e");
    }
  }
  //endregion

  //region checkBalanceOrMiniStatement
  Future<void> checkBalanceOrMiniStatement(String skey) async {
    try {
      isCheckBalanceOrMiniStatementLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isCheckBalanceOrMiniStatementLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isCheckBalanceOrMiniStatementLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,
        "bank_iin": "",//selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "skey": skey,                    // BAP for Balance, SAP for Mini Statement
        "amount": "0",
        "request_type": "CONFIRM AEPS TXN REQUEST",
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkBalanceOrMiniStatement Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkBalanceOrMiniStatement Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isCheckBalanceOrMiniStatementLoading.value = false;

        // Resp_code == "RCS" → Show confirmation, then capture fingerprint

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Data loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load data.");
        // }
      } else {
        isCheckBalanceOrMiniStatementLoading.value = false;
        ConsoleLog.printError("checkBalanceOrMiniStatement API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load data.");
      }
    } catch (e) {
      isCheckBalanceOrMiniStatementLoading.value = false;
      ConsoleLog.printError("checkBalanceOrMiniStatement ERROR: $e");
    }
  }
  //endregion

  //region checkBalanceFingpay
  Future<void> checkBalanceFingpay() async {
    try {
      isCheckBalanceFingpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isCheckBalanceFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isCheckBalanceFingpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": "0",
        "skey": "BCSFNGPY",               // Balance Check Fingpay
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkBalanceFingpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkBalanceFingpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isCheckBalanceFingpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Balance loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Balance.");
        // }
      } else {
        isCheckBalanceFingpayLoading.value = false;
        ConsoleLog.printError("checkBalanceFingpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Balance.");
      }
    } catch (e) {
      isCheckBalanceFingpayLoading.value = false;
      ConsoleLog.printError("checkBalanceFingpay ERROR: $e");
    }
  }
  //endregion

  //region cashWithdrawalFingpay
  Future<void> cashWithdrawalFingpay(String withdrawalAmount) async {
    try {
      isCashWithdrawalFingpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isCashWithdrawalFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isCashWithdrawalFingpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": withdrawalAmount,
        "skey": "CWSFNGPY",               // Cash Withdrawal Fingpay
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("cashWithdrawalFingpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("cashWithdrawalFingpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isCashWithdrawalFingpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Cash withdrawal request successfully sent!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Cash withdrawal request.");
        // }
      } else {
        isCashWithdrawalFingpayLoading.value = false;
        ConsoleLog.printError("cashWithdrawalFingpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send Cash withdrawal request.");
      }
    } catch (e) {
      isCashWithdrawalFingpayLoading.value = false;
      ConsoleLog.printError("cashWithdrawalFingpay ERROR: $e");
    }
  }
  //endregion

  //region miniStatementFingpay
  Future<void> miniStatementFingpay() async {
    try {
      isMiniStatementFingpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isMiniStatementFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isMiniStatementFingpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": "0",
        "skey": "MSTFNGPY",               // Mini Statement Fingpay
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("miniStatementFingpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("miniStatementFingpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isMiniStatementFingpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Mini Statement successfully loaded!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Mini Statement.");
        // }
      } else {
        isMiniStatementFingpayLoading.value = false;
        ConsoleLog.printError("miniStatementFingpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Mini Statement.");
      }
    } catch (e) {
      isMiniStatementFingpayLoading.value = false;
      ConsoleLog.printError("miniStatementFingpay ERROR: $e");
    }
  }
  //endregion

  //region aadhaarPayFingpay
  Future<void> aadhaarPayFingpay(String paymentAmount) async {
    try {
      isAadhaarPayFingpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isAadhaarPayFingpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isAadhaarPayFingpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": paymentAmount,
        "skey": "ADRFNGPY",               // Aadhaar Pay Fingpay
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("aadhaarPayFingpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("aadhaarPayFingpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isAadhaarPayFingpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Aadhaar Pay request successfully sent!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Aadhaar Pay request.");
        // }
      } else {
        isAadhaarPayFingpayLoading.value = false;
        ConsoleLog.printError("aadhaarPayFingpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send Aadhaar Pay request.");
      }
    } catch (e) {
      isAadhaarPayFingpayLoading.value = false;
      ConsoleLog.printError("aadhaarPayFingpay ERROR: $e");
    }
  }
  //endregion

  //region checkUserOrSendOTPInstantpayOnboarding
  Future<void> checkUserOrSendOTPInstantpayOnboarding() async {
    try {
      isInstantpayOnboardingLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isInstantpayOnboardingLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isInstantpayOnboardingLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "mobile_no": mobileController.value,
        "email": emailController.value,
        "aadhar_no": aadhaarController.value,
        "pan_no": panController.value,
        "account_no": selectedMyBank.value?.accountNo,
        "ifsc": selectedMyBank.value?.ifsc,
        "req_type": "CHECKUSER",
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INSTANTPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkUserOrSendOTPInstantpayOnboarding Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkUserOrSendOTPInstantpayOnboarding Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isInstantpayOnboardingLoading.value = false;

        // Resp_code == "RCS" → OTP Sent, save:
        //   - aadhaar = res.data['aadhaar']
        //   - otpReferenceID = res.data['otpReferenceID']
        //   - hash = res.data['hash']
        // Resp_code == "RLD" → Already registered, go to 2FA

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "OTP sent successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to request OTP.");
        // }
      } else {
        isInstantpayOnboardingLoading.value = false;
        ConsoleLog.printError("checkUserOrSendOTPInstantpayOnboarding API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to request OTP.");
      }
    } catch (e) {
      isInstantpayOnboardingLoading.value = false;
      ConsoleLog.printError("checkUserOrSendOTPInstantpayOnboarding ERROR: $e");
    }
  }
  //endregion

  //region verifyInstantpayOnboardingOTP
  Future<void> verifyInstantpayOnboardingOTP() async {
    try {
      isInstantpayVerifyOnboardingOTPLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isInstantpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isInstantpayVerifyOnboardingOTPLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "REGISTERUSER",
        "mobile_no": mobileController.value,
        "email": emailController.value,
        "aadhar_no": aadhaarController.value,
        "pan_no": panController.value,
        "account_no": selectedMyBank.value?.accountNo,
        "ifsc": selectedMyBank.value?.ifsc,
        "otp": otpController.value,
        "otp_ref_data": {
          "aadhaar": "",//reference['aadhaar'],
          "otpReferenceID": "",//reference['otpReferenceID'],
          "hash": "",//reference['hash'],
        },
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INSTANTPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("verifyInstantpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("verifyInstantpayOnboardingOTP Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isInstantpayVerifyOnboardingOTPLoading.value = false;

        // Resp_code == "RCS" → Registration complete, go to 2FA

        // if (apiResponse.isSuccess) {
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to verify OTP.");
        // }
      } else {
        isInstantpayVerifyOnboardingOTPLoading.value = false;
        ConsoleLog.printError("verifyInstantpayOnboardingOTP API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send your request.");
      }
    } catch (e) {
      isInstantpayVerifyOnboardingOTPLoading.value = false;
      ConsoleLog.printError("verifyInstantpayOnboardingOTP ERROR: $e");
    }
  }
  //endregion

  //region instantpayTwoFA_Process
  Future<void> instantpayTwoFA_Process() async {
    try {
      isInstantpay2FA_ProcessLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isInstantpay2FA_ProcessLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isInstantpay2FA_ProcessLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,      // "MANTRA", "MORPHO", etc.
        "aadhar_no": aadhaarController.value,
        "skey": "TWOFACTORAUTH",
        "encdata": "",//fingerprintData,    // Base64 fingerprint
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INSTANTPAY_2FA_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("instantpayTwoFA_Process Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("instantpayTwoFA_Process Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isInstantpay2FA_ProcessLoading.value = false;

        // Resp_code == "RCS" → 2FA Success, go to Choose Service

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "2FA successfully completed!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send 2FA Request.");
        // }
      } else {
        isInstantpay2FA_ProcessLoading.value = false;
        ConsoleLog.printError("instantpayTwoFA_Process API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
      }
    } catch (e) {
      isInstantpay2FA_ProcessLoading.value = false;
      ConsoleLog.printError("instantpayTwoFA_Process ERROR: $e");
    }
  }
  //endregion

  //region checkBalanceInstantpay
  Future<void> checkBalanceInstantpay() async {
    try {
      isCheckBalanceInstantpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isCheckBalanceInstantpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isCheckBalanceInstantpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,
        "bank_iin": "",//selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "skey": "BAP",                    // Balance Enquiry
        "amount": "0",
        "request_type": "PROCESS AEPS TXN REQUEST",
        "encdata": "",//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("checkBalanceInstantpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("checkBalanceInstantpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isCheckBalanceInstantpayLoading.value = false;

        // Resp_code == "RCS" → Show confirmation, then capture fingerprint

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Balance loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Balance.");
        // }
      } else {
        isCheckBalanceInstantpayLoading.value = false;
        ConsoleLog.printError("checkBalanceInstantpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Balance.");
      }
    } catch (e) {
      isCheckBalanceInstantpayLoading.value = false;
      ConsoleLog.printError("checkBalanceInstantpay ERROR: $e");
    }
  }
  //endregion

  //region cashWithdrawalInstantpay
  Future<void> cashWithdrawalInstantpay(String withdrawalAmount) async {
    try {
      isCashWithdrawalInstantpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isCashWithdrawalInstantpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isCashWithdrawalInstantpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": withdrawalAmount,
        "skey": "WAP",               // Withdrawal
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("cashWithdrawalInstantpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("cashWithdrawalInstantpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isCashWithdrawalInstantpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Cash withdrawal request successfully sent!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Cash withdrawal request.");
        // }
      } else {
        isCashWithdrawalInstantpayLoading.value = false;
        ConsoleLog.printError("cashWithdrawalInstantpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send Cash withdrawal request.");
      }
    } catch (e) {
      isCashWithdrawalInstantpayLoading.value = false;
      ConsoleLog.printError("cashWithdrawalInstantpay ERROR: $e");
    }
  }
  //endregion

  //region miniStatementInstantpay
  Future<void> miniStatementInstantpay() async {
    try {
      isMiniStatementInstantpayLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isMiniStatementInstantpayLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isMiniStatementInstantpayLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": selectedDevice,
        "bank_iin": "", //selectedBankIIN,
        "aadhar_no": aadhaarController.value,//customerAadhaar,
        "mobile_no": mobileController.value,//customerMobile,
        "amount": "0",
        "skey": "SAP",               // Statement
        "encdata": ""//fingerprintData,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("miniStatementInstantpay Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("miniStatementInstantpay Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isMiniStatementInstantpayLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Mini Statement successfully loaded!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Mini Statement.");
        // }
      } else {
        isMiniStatementInstantpayLoading.value = false;
        ConsoleLog.printError("miniStatementInstantpay API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Mini Statement.");
      }
    } catch (e) {
      isMiniStatementInstantpayLoading.value = false;
      ConsoleLog.printError("miniStatementInstantpay ERROR: $e");
    }
  }
  //endregion

  //region getRecentTransactions
  Future<void> getRecentTransactions(String service_type) async {
    try {
      isGetRecentTransactionsLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isGetRecentTransactionsLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isGetRecentTransactionsLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "service_type": service_type,   // For Fingpay: "AEPS3", For Instantpay: "AEPS2"
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_RECENT_TXN_DATA,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("getRecentTransactions Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("getRecentTransactions Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isGetRecentTransactionsLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Recent Transactions loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Recent Transactions.");
        // }
      } else {
        isGetRecentTransactionsLoading.value = false;
        ConsoleLog.printError("getRecentTransactions API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Recent Transactions.");
      }
    } catch (e) {
      isGetRecentTransactionsLoading.value = false;
      ConsoleLog.printError("getRecentTransactions ERROR: $e");
    }
  }
  //endregion

  //region markFavBank
  Future<void> markFavBank(String action) async {
    try {
      isMarkFavoriteBankLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isMarkFavoriteBankLoading.value = false;
        throw Exception("No Internet Connection!");
      }

      ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
      ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");

      // Auth credentials check with reload
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        ConsoleLog.printError("Auth credentials are empty");
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isMarkFavoriteBankLoading.value = false;
        throw Exception("Authentication required!");
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "bank_iin": "", //bankIIN,
        "bank_id": "", //bankId,
        "action": "ADD",    // or "REMOVE"
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_MARK_FAV_BANK,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("getRecentTransactions Request: ${jsonEncode(body)}", color: "yellow");
      ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
      ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("getRecentTransactions Response: ${jsonEncode(response.data)}");

        // CheckInstantpayBioAuthStatusResponseModel apiResponse =
        // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
        isMarkFavoriteBankLoading.value = false;

        // if (apiResponse.isSuccess) {
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Recent Transactions loaded successfully!");
        // }else {
        //   // API returned error
        //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Recent Transactions.");
        // }
      } else {
        isMarkFavoriteBankLoading.value = false;
        ConsoleLog.printError("getRecentTransactions API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to load Recent Transactions.");
      }
    } catch (e) {
      isMarkFavoriteBankLoading.value = false;
      ConsoleLog.printError("getRecentTransactions ERROR: $e");
    }
  }
  //endregion

  // ============== Service Selection ==============

  void onServiceSelect(String service) {
    selectedService.value = service;
    showAmountInput.value = (service == 'cashWithdrawal' || service == 'aadhaarPay');
    
    // Reset modals
    showConfirmationModal.value = false;
    showResultModal.value = false;
    confirmationData.value = null;
    transactionResult.value = null;
  }

  // ============== Form Reset ==============

  void resetServiceForm() {
    serviceAadhaarController.value.clear();
    serviceMobileController.value.clear();
    serviceAmountController.value.clear();
    serviceSelectedDevice.value = '';
    selectedBankName.value = '';
    selectedBankId.value = '';
    selectedBankIin.value = '';
  }

  void resetOnboardingForm() {
    otpController.value.clear();
    bankAccountController.value.clear();
    ifscController.value.clear();
  }

  void resetSelectedBank() {
    selectedMyBank.value = null;
    filteredBankList.assignAll(myBankList);
    searchCtrl.clear();

    // ✅ Reset Fingpay states
    showFingpayOnboardingForm.value = false;
    showFingpay2FAForm.value = false;
    showFingpayOnboardAuthForm.value = false;
    showFingpayOtpModal.value = false;
    canProceedToFingpayServices.value = false;
  }

  // ✅ NEW: Reset Instantpay states when entering AEPS Three screen
  void resetInstantpayState() {
    showInstantpayOnboardingForm.value = false;
    showInstantpay2FAForm.value = false;
    showInstantpayOnboardAuthForm.value = false;
    showInstantpayOtpModal.value = false;
    canProceedToInstantpayServices.value = false;
    selectedDevice.value = '';
  }

  // ✅ NEW: Reset Fingpay states when entering AEPS One screen
  void resetFingpayState() {
    showFingpayOnboardingForm.value = false;
    showFingpay2FAForm.value = false;
    showFingpayOnboardAuthForm.value = false;
    showFingpayOtpModal.value = false;
    canProceedToFingpayServices.value = false;
    selectedMyBank.value = null;
    filteredBankList.assignAll(myBankList);
    searchCtrl.clear();
    selectedDevice.value = '';
  }

  @override
  void onClose() {
    // Screen close होते ही bank selection reset करें
    // resetSelectedBank();
    resetFingpayState();
    resetInstantpayState();
    super.onClose();
  }

  // ============== Bank Selection ==============

  void selectBank(AepsBank bank) {
    selectedBankName.value = bank.bankName ?? '';
    selectedBankId.value = bank.id ?? '';
    selectedBankIin.value = bank.bankIin ?? '';
  }

  void selectMyBank(GetAllMyBankListData bank) {
    selectedMyBank.value = bank;
  }
  // void selectMyBank(MyBankAccount bank) {
  //   selectedMyBank.value = bank;
  // }

  // ============== Modal Controls ==============

  void closeOtpModal() {
    showFingpayOtpModal.value = false;
    showInstantpayOtpModal.value = false;
    otpController.value.clear();
  }

  void closeConfirmationModal() {
    showConfirmationModal.value = false;
    confirmationData.value = null;
    txnPinController.value.clear();
  }

  void closeResultModal() {
    showResultModal.value = false;
    transactionResult.value = null;
  }

  // ============== Validation Helpers ==============

  bool validateAadhaar(String aadhaar) {
    return aadhaar.length == 12 && RegExp(r'^[0-9]+$').hasMatch(aadhaar);
  }

  bool validateMobile(String mobile) {
    return mobile.length == 10 && RegExp(r'^[0-9]+$').hasMatch(mobile);
  }

  bool validateOtp(String otp) {
    return otp.length == 6 && RegExp(r'^[0-9]+$').hasMatch(otp);
  }

  // ============== Device Selection ==============

  void onDeviceChange(String? value) {
    if (value != null) {
      selectedDevice.value = value;
    }
  }

  void onServiceDeviceChange(String? value) {
    if (value != null) {
      serviceSelectedDevice.value = value;
    }
  }

  // ============== Input Formatters ==============

  String formatAadhaarInput(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String formatMobileInput(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // ============== Status Helpers ==============

  String getTransactionStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return '#47D96C';
      case 'FAILED':
        return '#FF0000';
      case 'PENDING':
        return '#EA8F43';
      default:
        return '#EA8F43';
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return const Color(0xFF47D96C);
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return const Color(0xFFEA8F43);
      default:
        return const Color(0xFFEA8F43);
    }
  }

  String getStatusImage(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return 'assets/images/checked.png';
      case 'FAILED':
        return 'assets/images/cancel.png';
      case 'PENDING':
        return 'assets/images/clock.png';
      default:
        return 'assets/images/clock.png';
    }
  }
}

// ============== Model Classes (if not imported separately) ==============
// These should be in a separate file, included here for reference

class AepsBank {
  final String? id;
  final String? bankName;
  final String? bankIin;
  final String? isFav;

  AepsBank({this.id, this.bankName, this.bankIin, this.isFav});

  factory AepsBank.fromJson(Map<String, dynamic> json) {
    return AepsBank(
      id: json['id']?.toString(),
      bankName: json['bank_name'],
      bankIin: json['bank_iin'],
      isFav: json['is_fav']?.toString(),
    );
  }
}

class MyBankAccount {
  final String? id;
  final String? accountNo;
  final String? ifsc;
  final String? aepsBankId;
  final String? bankName;

  MyBankAccount({this.id, this.accountNo, this.ifsc, this.aepsBankId, this.bankName});

  factory MyBankAccount.fromJson(Map<String, dynamic> json) {
    return MyBankAccount(
      id: json['id']?.toString(),
      accountNo: json['account_no'],
      ifsc: json['ifsc'],
      aepsBankId: json['aeps_bankid'],
      bankName: json['bank_name'],
    );
  }
}

class AepsConfirmData {
  final String? commission;
  final String? tds;
  final String? totalcharge;
  final String? totalccf;
  final String? trasamt;
  final String? chargedamt;
  final String? txnpin;

  AepsConfirmData({
    this.commission,
    this.tds,
    this.totalcharge,
    this.totalccf,
    this.trasamt,
    this.chargedamt,
    this.txnpin,
  });

  factory AepsConfirmData.fromJson(Map<String, dynamic> json) {
    return AepsConfirmData(
      commission: json['commission']?.toString(),
      tds: json['tds']?.toString(),
      totalcharge: json['totalcharge']?.toString(),
      totalccf: json['totalccf']?.toString(),
      trasamt: json['trasamt']?.toString(),
      chargedamt: json['chargedamt']?.toString(),
      txnpin: json['txnpin']?.toString(),
    );
  }
}

class AepsTransactionData {
  final String? txnStatus;
  final String? txnDesc;
  final String? balance;
  final String? date;
  final String? txnid;
  final String? opid;
  final String? trasamt;
  final List<MiniStatementItem>? statement;

  AepsTransactionData({
    this.txnStatus,
    this.txnDesc,
    this.balance,
    this.date,
    this.txnid,
    this.opid,
    this.trasamt,
    this.statement,
  });

  factory AepsTransactionData.fromJson(Map<String, dynamic> json) {
    List<MiniStatementItem>? statementList;
    if (json['statement'] != null && json['statement'] is List) {
      var list = json['statement'] as List;
      if (list.isNotEmpty && list.first is Map) {
        statementList = list.map((e) => MiniStatementItem.fromJson(e)).toList();
      }
    }
    return AepsTransactionData(
      txnStatus: json['txn_status'],
      txnDesc: json['txn_desc'],
      balance: json['balance']?.toString(),
      date: json['date'],
      txnid: json['txnid'],
      opid: json['opid'],
      trasamt: json['trasamt']?.toString(),
      statement: statementList,
    );
  }
}

class MiniStatementItem {
  final String? date;
  final String? narration;
  final String? txnType;
  final String? amount;

  MiniStatementItem({this.date, this.narration, this.txnType, this.amount});

  factory MiniStatementItem.fromJson(Map<String, dynamic> json) {
    return MiniStatementItem(
      date: json['date'],
      narration: json['narration'],
      txnType: json['txnType'],
      amount: json['amount']?.toString(),
    );
  }
}

class AepsOnboardingData {
  final String? aadhaar;
  final String? otpReferenceID;
  final String? hash;
  final String? primaryKeyId;
  final String? encodeFPTxnId;

  AepsOnboardingData({
    this.aadhaar,
    this.otpReferenceID,
    this.hash,
    this.primaryKeyId,
    this.encodeFPTxnId,
  });

  factory AepsOnboardingData.fromJson(Map<String, dynamic> json) {
    return AepsOnboardingData(
      aadhaar: json['aadhaar'],
      otpReferenceID: json['otpReferenceID'],
      hash: json['hash'],
      primaryKeyId: json['primaryKeyId'],
      encodeFPTxnId: json['encodeFPTxnId'],
    );
  }
}

class RecentTransaction {
  final String? customerId;
  final String? requestDt;
  final String? recordType;
  final String? txnAmt;
  final String? portalStatus;
  final String? portalTxnId;

  RecentTransaction({
    this.customerId,
    this.requestDt,
    this.recordType,
    this.txnAmt,
    this.portalStatus,
    this.portalTxnId,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      customerId: json['customer_id'],
      requestDt: json['request_dt'],
      recordType: json['record_type'],
      txnAmt: json['txn_amt']?.toString(),
      portalStatus: json['portal_status'],
      portalTxnId: json['portal_txn_id'],
    );
  }
}
