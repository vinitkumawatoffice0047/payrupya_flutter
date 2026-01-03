// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:payrupya/controllers/login_controller.dart';
// import 'package:payrupya/controllers/payrupya_home_screen_controller.dart';
//
// import '../api/api_provider.dart';
// import '../api/web_api_constant.dart';
// import '../models/check_fingpay_auth_status_response_model.dart';
// import '../models/check_instantpay_bio_auth_status_response_model.dart';
// import '../models/get_all_my_bank_list_response_model.dart';
// import '../utils/ConsoleLog.dart';
// import '../utils/app_shared_preferences.dart';
// import '../utils/connection_validator.dart';
// import '../utils/global_utils.dart';
// import '../view/onboarding_screen.dart';
// import 'session_manager.dart';
//
// /// AEPS Controller for handling both AEPS One (Fingpay) and AEPS Three (Instantpay)
// class AepsController extends GetxController {
//   // ============== State Variables ==============
//
//   // ============== Loading States ==============
//   RxBool isFingpayLoading = false.obs;
//   RxBool isInstantpayLoading = false.obs;
//   RxBool isFingpayOnboardingLoading = false.obs;
//   RxBool isInstantpayOnboardingLoading = false.obs;
//   RxBool isFingpayTransactionLoading = false.obs;
//   RxBool isInstantpayTransactionLoading = false.obs;
//   RxBool isFingpayRegisterOnboardingLoading = false.obs;
//   RxBool isInstantpayRegisterOnboardingLoading = false.obs;
//   RxBool isFingpayVerifyOnboardingOTPLoading = false.obs;
//   RxBool isInstantpayVerifyOnboardingOTPLoading = false.obs;
//   RxBool isFingpay_e_KYC_OnboardingLoading = false.obs;
//   RxBool isInstantpay_e_KYC_OnboardingLoading = false.obs;
//   RxBool isFingpay2FA_ProcessLoading = false.obs;
//   RxBool isInstantpay2FA_ProcessLoading = false.obs;
//
//
//   RxBool isCheckBalanceFingpayLoading = false.obs;
//   RxBool isCheckBalanceInstantpayLoading = false.obs;
//   RxBool isCashWithdrawalFingpayLoading = false.obs;
//   RxBool isCashWithdrawalInstantpayLoading = false.obs;
//   RxBool isMiniStatementFingpayLoading = false.obs;
//   RxBool isMiniStatementInstantpayLoading = false.obs;
//   RxBool isAadhaarPayFingpayLoading = false.obs;
//   RxBool isAadhaarPayInstantpayLoading = false.obs;
//
//   RxBool isGetAepsBanklistLoading = false.obs;
//   RxBool isGetRecentTransactionsLoading = false.obs;
//   RxBool isCheckBalanceOrMiniStatementLoading = false.obs;
//   RxBool isMarkFavoriteBankLoading = false.obs;
//   RxBool isBiometricScanning = false.obs;
//
//   // ============== Auth Credentials ==============
//   RxString userAuthToken = "".obs;
//   RxString userSignature = "".obs;
//
//   // ============== Fingpay States ==============
//   RxBool isFingpayOnboarded = false.obs;
//   RxBool isFingpayTwoFactorAuthenticated = false.obs;
//   RxBool showFingpayOnboardingForm = false.obs;
//   RxBool showFingpay2FAForm = false.obs;
//   RxBool showFingpayOtpModal = false.obs;
//   RxBool showFingpayOnboardAuthForm = false.obs; // For Fingpay eKYC auth
//   RxBool canProceedToFingpayServices = false.obs;
//   RxBool isFingpay2FACompleted = false.obs;
//
//   // ============== Instantpay States ==============
//   RxBool isInstantpayOnboarded = false.obs;
//   RxBool isInstantTwoFactorAuthenticated = false.obs;
//   RxBool showInstantpayOnboardingForm = false.obs;
//   RxBool showInstantpay2FAForm = false.obs;
//   RxBool showInstantpayOtpModal = false.obs;
//   RxBool showInstantpayOnboardAuthForm = false.obs; // For Fingpay eKYC auth
//   RxBool canProceedToInstantpayServices = false.obs;
//   RxBool isInstantpay2FACompleted = false.obs;
//
//   // Fingpay 2FA States
//   Rxn<FingpayAuthData> fingpayAuthData = Rxn<FingpayAuthData>();
//
//   // Instantpay 2FA States
//   Rxn<InstantpayAuthData> instantpayAuthData = Rxn<InstantpayAuthData>();
//
//   // ============== Service Selection ==============
//   RxString selectedService = 'balanceCheck'.obs;
//   RxBool showAmountInput = false.obs;
//   RxString currentAepsType = 'fingpay'.obs; // 'fingpay' or 'instantpay'
//
//   // Bank related
//   RxList<AepsBank> allBankList = <AepsBank>[].obs;
//   RxList<AepsBank> favoritesList = <AepsBank>[].obs;
//   RxList<AepsBank> filteredBankList  = <AepsBank>[].obs;
//   RxString selectedBankName = ''.obs;
//   RxString selectedBankId = ''.obs;
//   RxString selectedBankIin = ''.obs;
//
//   // My Bank List (for Fingpay)
//   RxList<GetAllMyBankListData> myBankList = <GetAllMyBankListData>[].obs;
//   Rx<GetAllMyBankListData?> selectedMyBank = Rx<GetAllMyBankListData?>(null);
//   RxList<GetAllMyBankListData> filteredMyBankList = <GetAllMyBankListData>[].obs;
//   final TextEditingController searchCtrl = TextEditingController();
//   // RxList<MyBankAccount> myBankList = <MyBankAccount>[].obs;
//   // Rx<MyBankAccount?> selectedMyBank = Rx<MyBankAccount?>(null);
//
//   // Transaction data
//   Rx<AepsConfirmData?> confirmationData = Rx<AepsConfirmData?>(null);
//   Rx<AepsTransactionData?> transactionResult = Rx<AepsTransactionData?>(null);
//   RxList<RecentTransaction> recentTransactions = <RecentTransaction>[].obs;
//
//   // OTP Reference data
//   Rx<AepsOnboardingData?> otpReference = Rx<AepsOnboardingData?>(null);
//
//   // Modal states
//   RxBool showConfirmationModal = false.obs;
//   RxBool showResultModal = false.obs;
//
//   // Device list
//   final List<Map<String, String>> deviceList = [
//     {'name': 'Select Device', 'value': ''},
//     {'name': 'Mantra', 'value': 'MANTRA'},
//     {'name': 'Mantra MFS110', 'value': 'MFS110'},
//     {'name': 'Mantra Iris', 'value': 'MIS100V2'},
//     {'name': 'Morpho L0', 'value': 'MORPHO'},
//     {'name': 'Morpho L1', 'value': 'Idemia'},
//     {'name': 'TATVIK', 'value': 'TATVIK'},
//     {'name': 'Secugen', 'value': 'SecuGen Corp.'},
//     {'name': 'Startek', 'value': 'STARTEK'},
//   ];
//
//   // ============== Form Controllers ==============
//
//   // Authentication Form
//   Rx<TextEditingController> aadhaarController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> selectedDeviceController = TextEditingController(text: "").obs;
//   RxString selectedDevice = ''.obs;
//
//   // Onboarding Form (Instantpay)
//   Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> panController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> bankAccountController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> ifscController = TextEditingController(text: "").obs;
//
//   // Onboarding Form (Fingpay - additional fields)
//   Rx<TextEditingController> firstNameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> lastNameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> shopNameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> gstController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> stateController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> cityController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> pincodeController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> shopAddressController = TextEditingController(text: "").obs;
//
//   // OTP Controller
//   Rx<TextEditingController> otpController = TextEditingController(text: "").obs;
//
//   // Service Form
//   Rx<TextEditingController> serviceAadhaarController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> serviceMobileController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> serviceAmountController = TextEditingController(text: "").obs;
//   RxString serviceSelectedDevice = ''.obs;
//
//   // Transaction PIN
//   Rx<TextEditingController> txnPinController = TextEditingController(text: "").obs;
//
//   // LoginController loginController = Get.put(LoginController());
//   // PayrupyaHomeScreenController homeScreenController = Get.put(PayrupyaHomeScreenController());
//   PayrupyaHomeScreenController get homeScreenController => Get.find<PayrupyaHomeScreenController>();
//
//   // ============== Lifecycle ==============
//
//   @override
//   void onInit() {
//     super.onInit();
//     filteredMyBankList.assignAll(myBankList);
//   }
//
//   void filterBank(String query) {
//     if (query.isEmpty) {
//       filteredMyBankList.assignAll(myBankList);
//     } else {
//       filteredMyBankList.assignAll(
//         myBankList.where(
//               (bank) =>
//           bank.bankName
//               ?.toLowerCase()
//               .contains(query.toLowerCase()) ??
//               false,
//         ),
//       );
//     }
//   }
//
//   // ============== Initialize User Data ==============
//
//   void initializeUserData({
//     required String aadhaar,
//     required String mobile,
//     required String email,
//     required String pan,
//     required String firstName,
//     required String lastName,
//     required String shopName,
//     required String state,
//     required String city,
//     required String pincode,
//     required String shopAddress,
//     required String gstin,
//   }) {
//     aadhaarController.value.text = aadhaar;
//     mobileController.value.text = mobile;
//     emailController.value.text = email;
//     panController.value.text = pan;
//     firstNameController.value.text = firstName;
//     lastNameController.value.text = lastName;
//     shopNameController.value.text = shopName;
//     stateController.value.text = state;
//     cityController.value.text = city;
//     pincodeController.value.text = pincode;
//     shopAddressController.value.text = shopAddress;
//     gstController.value.text = gstin;
//   }
//
//   // ============== API Calls ==============
//
//   // Generate Request ID
//   String generateRequestId() {
//     return GlobalUtils.generateRandomId(6);
//   }
//
//   //region loadAuthCredentials
//   // Load both token and signature properly
//   Future<void> loadAuthCredentials() async {
//     try {
//       Map<String, String> authData = await AppSharedPreferences.getLoginAuth();
//       userAuthToken.value = authData["token"] ?? "";
//       userSignature.value = authData["signature"] ?? "";
//
//       ConsoleLog.printInfo("Token: ${userAuthToken.value.isNotEmpty ? 'Found' : 'NOT FOUND'}");
//       ConsoleLog.printInfo("Signature: ${userSignature.value.isNotEmpty ? 'Found' : 'NOT FOUND'}");
//
//       // Debug: Print first 20 chars
//       if (userAuthToken.value.isNotEmpty) {
//         int tokenLength = userAuthToken.value.length;
//         int previewLength = tokenLength > 20 ? 20 : tokenLength;
//         if (previewLength > 0) {
//           ConsoleLog.printColor("Token Preview: ${userAuthToken.value.substring(0, previewLength)}...", color: "cyan");
//         }
//       }
//
//       if (userSignature.value.isNotEmpty) {
//         int signatureLength = userSignature.value.length;
//         int previewLength = signatureLength > 20 ? 20 : signatureLength;
//         if (previewLength > 0) {
//           ConsoleLog.printColor("Signature Preview: ${userSignature.value.substring(0, previewLength)}...", color: "cyan");
//         }
//       }
//
//     } catch (e) {
//       ConsoleLog.printError("Error loading auth credentials: $e");
//     }
//   }
//   //endregion
//
//   //region isTokenValid
//   Future<bool> isTokenValid() async {
//     // Reload credentials first
//     await loadAuthCredentials();
//
//     if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//       ConsoleLog.printError("❌ Token or Signature missing");
//       ConsoleLog.printError("Token Length: ${userAuthToken.value.length}");
//       ConsoleLog.printError("Signature Length: ${userSignature.value.length}");
//       return false;
//     }
//     return true;
//   }
//   //endregion
//
//   //region refreshToken
//   Future<void> refreshToken(BuildContext context) async {
//     ConsoleLog.printWarning("⚠️ Token expired, please login again");
//     // ✅ Session ko properly end karo
//     if (Get.isRegistered<SessionManager>()) {
//       await SessionManager.instance.endSession();
//       Get.delete<SessionManager>(force: true);
//     }
//     await AppSharedPreferences.clearSessionOnly();
//     Get.offAll(() => OnboardingScreen());
//     Fluttertoast.showToast(msg: "Session expired. Please login again.");
//   }
//   //endregion
//
//   // ============== API Integrations ==============
//
//   //region registerOnboarding
//   Future<void> registerFingpayOnboarding() async {
//     try {
//       isFingpayRegisterOnboardingLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isFingpayRegisterOnboardingLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isFingpayRegisterOnboardingLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "req_type": "REGISTERUSER",
//         "bank_id": selectedMyBank.value?.aepsBankid,
//         "aadhar": aadhaarController.value,
//         "gstin": gstController.value,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("registerOnboarding Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("registerOnboarding Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isFingpayRegisterOnboardingLoading.value = false;
//
//         // Response Handling:
//           // Resp_code == "RCS" → OTP Sent, save reference data:
//             //   - primaryKeyId = res.data['primaryKeyId']
//             //   - encodeFPTxnId = res.data['encodeFPTxnId']
//           // Resp_code == "RLD" → Already registered, go to 2FA
//
//         // if (apiResponse.isSuccess) {
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to process AEPS registration.");
//         // }
//       } else {
//         isFingpayRegisterOnboardingLoading.value = false;
//         ConsoleLog.printError("registerOnboarding API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to process AEPS registration.");
//       }
//     } catch (e) {
//       isFingpayRegisterOnboardingLoading.value = false;
//       ConsoleLog.printError("registerOnboarding ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region verifyFingpayOnboardingOTP
//   Future<void> verifyFingpayOnboardingOTP() async {
//     try {
//       isFingpayVerifyOnboardingOTPLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "req_type": "VERIFYONBOARDOTP",
//         "otp": otpController.value,
//         "otp_ref_data": {
//           "primaryKeyId": "",//reference['primaryKeyId'],
//           "encodeFPTxnId": "",//reference['encodeFPTxnId'],
//         },
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("verifyFingpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("verifyFingpayOnboardingOTP Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//
//         // Resp_code == "RCS" → OTP Verified, proceed to eKYC (fingerprint)
//
//         // if (apiResponse.isSuccess) {
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to verify OTP.");
//         // }
//       } else {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         ConsoleLog.printError("verifyFingpayOnboardingOTP API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send your request.");
//       }
//     } catch (e) {
//       isFingpayVerifyOnboardingOTPLoading.value = false;
//       ConsoleLog.printError("verifyFingpayOnboardingOTP ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region resendFingpayOnboardingOTP
//   Future<void> resendFingpayOnboardingOTP() async {
//     try {
//       isFingpayVerifyOnboardingOTPLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "req_type": "RESENDOTP",
//         "primaryKeyId": "", //reference['primaryKeyId'],
//         "encodeFPTxnId": "", //reference['encodeFPTxnId'],
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("resendFingpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("resendFingpayOnboardingOTP Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "OTP sent successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send OTP request.");
//         // }
//       } else {
//         isFingpayVerifyOnboardingOTPLoading.value = false;
//         ConsoleLog.printError("resendFingpayOnboardingOTP API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send OTP request.");
//       }
//     } catch (e) {
//       isFingpayVerifyOnboardingOTPLoading.value = false;
//       ConsoleLog.printError("resendFingpayOnboardingOTP ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region eKYCProcessFingpayOnboarding
//   Future<void> eKYCProcessFingpayOnboarding() async {
//     try {
//       isFingpay_e_KYC_OnboardingLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isFingpay_e_KYC_OnboardingLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isFingpay_e_KYC_OnboardingLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "req_type": "PROCESSEKYC",
//         "aadhar": aadhaarController.value,
//         "account_no": selectedMyBank.value?.accountNo,
//         "ifsc": selectedMyBank.value?.ifsc,
//         "bank_id": selectedMyBank.value?.aepsBankid,
//         "otp_ref_data": {
//           "primaryKeyId": "", //reference['primaryKeyId'],
//           "encodeFPTxnId": "", //reference['encodeFPTxnId'],
//         },
//         "encdata": ""//fingerprintData,  // Base64 fingerprint from device
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("eKYCProcessFingpayOnboarding Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("eKYCProcessFingpayOnboarding Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isFingpay_e_KYC_OnboardingLoading.value = false;
//
//         // Resp_code == "RCS" → Onboarding Complete, go to 2FA
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "eKYC successfully completed!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send eKYC request.");
//         // }
//       } else {
//         isFingpay_e_KYC_OnboardingLoading.value = false;
//         ConsoleLog.printError("eKYCProcessFingpayOnboarding API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send eKYC request.");
//       }
//     } catch (e) {
//       isFingpay_e_KYC_OnboardingLoading.value = false;
//       ConsoleLog.printError("eKYCProcessFingpayOnboarding ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region fingpayTwoFA_Process
//   Future<void> fingpayTwoFA_Process() async {
//     try {
//       isFingpay2FA_ProcessLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isFingpay2FA_ProcessLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isFingpay2FA_ProcessLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "device": selectedDevice.value,      // "MANTRA", "MORPHO", etc.
//         "aadhar_no": aadhaarController.value,
//         "skey": "TWOFACTORAUTH",
//         "encdata": "",//fingerprintData,    // Base64 fingerprint
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_2FA_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("fingpayTwoFA_Process Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("fingpayTwoFA_Process Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isFingpay2FA_ProcessLoading.value = false;
//
//         // Resp_code == "RCS" → 2FA Success, navigate to Choose Service Screen
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "2FA successfully completed!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send 2FA Request..");
//         // }
//       } else {
//         isFingpay2FA_ProcessLoading.value = false;
//         ConsoleLog.printError("fingpayTwoFA_Process API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
//       }
//     } catch (e) {
//       isFingpay2FA_ProcessLoading.value = false;
//       ConsoleLog.printError("fingpayTwoFA_Process ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region getAepsBanklist
//   Future<void> getAepsBanklist() async {
//     try {
//       isGetAepsBanklistLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isGetAepsBanklistLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isGetAepsBanklistLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_GET_AEPS_BANK_LIST,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("getAepsBanklist Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("getAepsBanklist Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isGetAepsBanklistLoading.value = false;
//
//         // Response: res.data = List of AEPS banks with bank_iin
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "AEPS Bank List loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load AEPS Bank List.");
//         // }
//       } else {
//         isGetAepsBanklistLoading.value = false;
//         ConsoleLog.printError("getAepsBanklist API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load AEPS Bank List.");
//       }
//     } catch (e) {
//       isGetAepsBanklistLoading.value = false;
//       ConsoleLog.printError("getAepsBanklist ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region checkBalanceOrMiniStatement
//   Future<void> checkBalanceOrMiniStatement(String skey) async {
//     try {
//       isCheckBalanceOrMiniStatementLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isCheckBalanceOrMiniStatementLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isCheckBalanceOrMiniStatementLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "device": selectedDevice.value,
//         "bank_iin": "",//selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "skey": skey,                    // BAP for Balance, SAP for Mini Statement
//         "amount": "0",
//         "request_type": "CONFIRM AEPS TXN REQUEST",
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("checkBalanceOrMiniStatement Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("checkBalanceOrMiniStatement Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isCheckBalanceOrMiniStatementLoading.value = false;
//
//         // Resp_code == "RCS" → Show confirmation, then capture fingerprint
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Data loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load data.");
//         // }
//       } else {
//         isCheckBalanceOrMiniStatementLoading.value = false;
//         ConsoleLog.printError("checkBalanceOrMiniStatement API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load data.");
//       }
//     } catch (e) {
//       isCheckBalanceOrMiniStatementLoading.value = false;
//       ConsoleLog.printError("checkBalanceOrMiniStatement ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region checkBalanceFingpay
//   Future<void> checkBalanceFingpay() async {
//     try {
//       isCheckBalanceFingpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isCheckBalanceFingpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isCheckBalanceFingpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": "0",
//         "skey": "BCSFNGPY",               // Balance Check Fingpay
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("checkBalanceFingpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("checkBalanceFingpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isCheckBalanceFingpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Balance loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Balance.");
//         // }
//       } else {
//         isCheckBalanceFingpayLoading.value = false;
//         ConsoleLog.printError("checkBalanceFingpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Balance.");
//       }
//     } catch (e) {
//       isCheckBalanceFingpayLoading.value = false;
//       ConsoleLog.printError("checkBalanceFingpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region cashWithdrawalFingpay
//   Future<void> cashWithdrawalFingpay(String withdrawalAmount) async {
//     try {
//       isCashWithdrawalFingpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isCashWithdrawalFingpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isCashWithdrawalFingpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": withdrawalAmount,
//         "skey": "CWSFNGPY",               // Cash Withdrawal Fingpay
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("cashWithdrawalFingpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("cashWithdrawalFingpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isCashWithdrawalFingpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Cash withdrawal request successfully sent!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Cash withdrawal request.");
//         // }
//       } else {
//         isCashWithdrawalFingpayLoading.value = false;
//         ConsoleLog.printError("cashWithdrawalFingpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send Cash withdrawal request.");
//       }
//     } catch (e) {
//       isCashWithdrawalFingpayLoading.value = false;
//       ConsoleLog.printError("cashWithdrawalFingpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region miniStatementFingpay
//   Future<void> miniStatementFingpay() async {
//     try {
//       isMiniStatementFingpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isMiniStatementFingpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isMiniStatementFingpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": "0",
//         "skey": "MSTFNGPY",               // Mini Statement Fingpay
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("miniStatementFingpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("miniStatementFingpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isMiniStatementFingpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Mini Statement successfully loaded!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Mini Statement.");
//         // }
//       } else {
//         isMiniStatementFingpayLoading.value = false;
//         ConsoleLog.printError("miniStatementFingpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Mini Statement.");
//       }
//     } catch (e) {
//       isMiniStatementFingpayLoading.value = false;
//       ConsoleLog.printError("miniStatementFingpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region aadhaarPayFingpay
//   Future<void> aadhaarPayFingpay(String paymentAmount) async {
//     try {
//       isAadhaarPayFingpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isAadhaarPayFingpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isAadhaarPayFingpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": paymentAmount,
//         "skey": "ADRFNGPY",               // Aadhaar Pay Fingpay
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("aadhaarPayFingpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("aadhaarPayFingpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isAadhaarPayFingpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Aadhaar Pay request successfully sent!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Aadhaar Pay request.");
//         // }
//       } else {
//         isAadhaarPayFingpayLoading.value = false;
//         ConsoleLog.printError("aadhaarPayFingpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send Aadhaar Pay request.");
//       }
//     } catch (e) {
//       isAadhaarPayFingpayLoading.value = false;
//       ConsoleLog.printError("aadhaarPayFingpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region checkUserOrSendOTPInstantpayOnboarding
//   Future<void> checkUserOrSendOTPInstantpayOnboarding() async {
//     try {
//       isInstantpayOnboardingLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isInstantpayOnboardingLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isInstantpayOnboardingLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "mobile_no": mobileController.value,
//         "email": emailController.value,
//         "aadhar_no": aadhaarController.value,
//         "pan_no": panController.value,
//         "account_no": selectedMyBank.value?.accountNo,
//         "ifsc": selectedMyBank.value?.ifsc,
//         "req_type": "CHECKUSER",
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_INSTANTPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("checkUserOrSendOTPInstantpayOnboarding Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("checkUserOrSendOTPInstantpayOnboarding Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isInstantpayOnboardingLoading.value = false;
//
//         // Resp_code == "RCS" → OTP Sent, save:
//         //   - aadhaar = res.data['aadhaar']
//         //   - otpReferenceID = res.data['otpReferenceID']
//         //   - hash = res.data['hash']
//         // Resp_code == "RLD" → Already registered, go to 2FA
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "OTP sent successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to request OTP.");
//         // }
//       } else {
//         isInstantpayOnboardingLoading.value = false;
//         ConsoleLog.printError("checkUserOrSendOTPInstantpayOnboarding API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to request OTP.");
//       }
//     } catch (e) {
//       isInstantpayOnboardingLoading.value = false;
//       ConsoleLog.printError("checkUserOrSendOTPInstantpayOnboarding ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region verifyInstantpayOnboardingOTP
//   Future<void> verifyInstantpayOnboardingOTP() async {
//     try {
//       isInstantpayVerifyOnboardingOTPLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isInstantpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isInstantpayVerifyOnboardingOTPLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "req_type": "REGISTERUSER",
//         "mobile_no": mobileController.value,
//         "email": emailController.value,
//         "aadhar_no": aadhaarController.value,
//         "pan_no": panController.value,
//         "account_no": selectedMyBank.value?.accountNo,
//         "ifsc": selectedMyBank.value?.ifsc,
//         "otp": otpController.value,
//         "otp_ref_data": {
//           "aadhaar": "",//reference['aadhaar'],
//           "otpReferenceID": "",//reference['otpReferenceID'],
//           "hash": "",//reference['hash'],
//         },
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_INSTANTPAY_AEPS_PROCESS_ONBOARDING,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("verifyInstantpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("verifyInstantpayOnboardingOTP Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isInstantpayVerifyOnboardingOTPLoading.value = false;
//
//         // Resp_code == "RCS" → Registration complete, go to 2FA
//
//         // if (apiResponse.isSuccess) {
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to verify OTP.");
//         // }
//       } else {
//         isInstantpayVerifyOnboardingOTPLoading.value = false;
//         ConsoleLog.printError("verifyInstantpayOnboardingOTP API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send your request.");
//       }
//     } catch (e) {
//       isInstantpayVerifyOnboardingOTPLoading.value = false;
//       ConsoleLog.printError("verifyInstantpayOnboardingOTP ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region instantpayTwoFA_Process
//   Future<void> instantpayTwoFA_Process() async {
//     try {
//       isInstantpay2FA_ProcessLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isInstantpay2FA_ProcessLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isInstantpay2FA_ProcessLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "device": selectedDevice.value,      // "MANTRA", "MORPHO", etc.
//         "aadhar_no": aadhaarController.value,
//         "skey": "TWOFACTORAUTH",
//         "encdata": "",//fingerprintData,    // Base64 fingerprint
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_INSTANTPAY_2FA_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("instantpayTwoFA_Process Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("instantpayTwoFA_Process Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isInstantpay2FA_ProcessLoading.value = false;
//
//         // Resp_code == "RCS" → 2FA Success, go to Choose Service
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "2FA successfully completed!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send 2FA Request.");
//         // }
//       } else {
//         isInstantpay2FA_ProcessLoading.value = false;
//         ConsoleLog.printError("instantpayTwoFA_Process API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
//       }
//     } catch (e) {
//       isInstantpay2FA_ProcessLoading.value = false;
//       ConsoleLog.printError("instantpayTwoFA_Process ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region checkBalanceInstantpay
//   Future<void> checkBalanceInstantpay() async {
//     try {
//       isCheckBalanceInstantpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isCheckBalanceInstantpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isCheckBalanceInstantpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "device": selectedDevice.value,
//         "bank_iin": "",//selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "skey": "BAP",                    // Balance Enquiry
//         "amount": "0",
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "encdata": "",//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("checkBalanceInstantpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("checkBalanceInstantpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isCheckBalanceInstantpayLoading.value = false;
//
//         // Resp_code == "RCS" → Show confirmation, then capture fingerprint
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Balance loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Balance.");
//         // }
//       } else {
//         isCheckBalanceInstantpayLoading.value = false;
//         ConsoleLog.printError("checkBalanceInstantpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Balance.");
//       }
//     } catch (e) {
//       isCheckBalanceInstantpayLoading.value = false;
//       ConsoleLog.printError("checkBalanceInstantpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region cashWithdrawalInstantpay
//   Future<void> cashWithdrawalInstantpay(String withdrawalAmount) async {
//     try {
//       isCashWithdrawalInstantpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isCashWithdrawalInstantpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isCashWithdrawalInstantpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": withdrawalAmount,
//         "skey": "WAP",               // Withdrawal
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("cashWithdrawalInstantpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("cashWithdrawalInstantpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isCashWithdrawalInstantpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Cash withdrawal request successfully sent!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to send Cash withdrawal request.");
//         // }
//       } else {
//         isCashWithdrawalInstantpayLoading.value = false;
//         ConsoleLog.printError("cashWithdrawalInstantpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to send Cash withdrawal request.");
//       }
//     } catch (e) {
//       isCashWithdrawalInstantpayLoading.value = false;
//       ConsoleLog.printError("cashWithdrawalInstantpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region miniStatementInstantpay
//   Future<void> miniStatementInstantpay() async {
//     try {
//       isMiniStatementInstantpayLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isMiniStatementInstantpayLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isMiniStatementInstantpayLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "request_type": "PROCESS AEPS TXN REQUEST",
//         "device": selectedDevice,
//         "bank_iin": "", //selectedBankIIN,
//         "aadhar_no": aadhaarController.value,//customerAadhaar,
//         "mobile_no": mobileController.value,//customerMobile,
//         "amount": "0",
//         "skey": "SAP",               // Statement
//         "encdata": ""//fingerprintData,
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("miniStatementInstantpay Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("miniStatementInstantpay Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isMiniStatementInstantpayLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Mini Statement successfully loaded!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Mini Statement.");
//         // }
//       } else {
//         isMiniStatementInstantpayLoading.value = false;
//         ConsoleLog.printError("miniStatementInstantpay API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Mini Statement.");
//       }
//     } catch (e) {
//       isMiniStatementInstantpayLoading.value = false;
//       ConsoleLog.printError("miniStatementInstantpay ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region getRecentTransactions
//   Future<void> getRecentTransactions(String service_type) async {
//     try {
//       isGetRecentTransactionsLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isGetRecentTransactionsLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isGetRecentTransactionsLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "service_type": service_type,   // For Fingpay: "AEPS3", For Instantpay: "AEPS2"
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_GET_RECENT_TXN_DATA,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("getRecentTransactions Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("getRecentTransactions Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isGetRecentTransactionsLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Recent Transactions loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Recent Transactions.");
//         // }
//       } else {
//         isGetRecentTransactionsLoading.value = false;
//         ConsoleLog.printError("getRecentTransactions API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Recent Transactions.");
//       }
//     } catch (e) {
//       isGetRecentTransactionsLoading.value = false;
//       ConsoleLog.printError("getRecentTransactions ERROR: $e");
//     }
//   }
//   //endregion
//
//   //region markFavBank
//   Future<void> markFavBank(String action) async {
//     try {
//       isMarkFavoriteBankLoading.value = true;
//
//       // Check Internet
//       bool isConnected = await ConnectionValidator.isConnected();
//       if (!isConnected) {
//         isMarkFavoriteBankLoading.value = false;
//         throw Exception("No Internet Connection!");
//       }
//
//       ConsoleLog.printInfo("======>>>>> Token: ${userAuthToken.value}");
//       ConsoleLog.printInfo("======>>>>> Signature: ${userSignature.value}");
//
//       // Auth credentials check with reload
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         ConsoleLog.printError("Auth credentials are empty");
//         await loadAuthCredentials();
//       }
//
//       if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
//         isMarkFavoriteBankLoading.value = false;
//         throw Exception("Authentication required!");
//       }
//
//       Map<String, dynamic> body = {
//         "request_id": generateRequestId(),
//         "lat": homeScreenController.latitude.value,
//         "long": homeScreenController.longitude.value,
//         "bank_iin": "", //bankIIN,
//         "bank_id": "", //bankId,
//         "action": "ADD",    // or "REMOVE"
//       };
//
//       var response = await ApiProvider().requestPostForApi(
//         WebApiConstant.API_URL_MARK_FAV_BANK,
//         body,
//         userAuthToken.value,
//         userSignature.value,
//       );
//
//       ConsoleLog.printColor("getRecentTransactions Request: ${jsonEncode(body)}", color: "yellow");
//       ConsoleLog.printInfo("Token available: ${userAuthToken.value.isNotEmpty}");
//       ConsoleLog.printInfo("Signature available: ${userSignature.value.isNotEmpty}");
//
//       if (response != null && response.statusCode == 200) {
//         ConsoleLog.printColor("getRecentTransactions Response: ${jsonEncode(response.data)}");
//
//         // CheckInstantpayBioAuthStatusResponseModel apiResponse =
//         // CheckInstantpayBioAuthStatusResponseModel.fromJson(response.data);
//         isMarkFavoriteBankLoading.value = false;
//
//         // if (apiResponse.isSuccess) {
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Recent Transactions loaded successfully!");
//         // }else {
//         //   // API returned error
//         //   Fluttertoast.showToast(msg: apiResponse.respDesc ?? "Failed to load Recent Transactions.");
//         // }
//       } else {
//         isMarkFavoriteBankLoading.value = false;
//         ConsoleLog.printError("getRecentTransactions API Error: ${response?.statusCode}");
//         Fluttertoast.showToast(msg: "Failed to load Recent Transactions.");
//       }
//     } catch (e) {
//       isMarkFavoriteBankLoading.value = false;
//       ConsoleLog.printError("getRecentTransactions ERROR: $e");
//     }
//   }
//   //endregion
//
//   // ============== Service Selection ==============
//
//   void onServiceSelect(String service) {
//     selectedService.value = service;
//     showAmountInput.value = (service == 'cashWithdrawal' || service == 'aadhaarPay');
//
//     // Reset modals
//     showConfirmationModal.value = false;
//     showResultModal.value = false;
//     confirmationData.value = null;
//     transactionResult.value = null;
//   }
//
//   // ============== Form Reset ==============
//
//   void resetServiceForm() {
//     serviceAadhaarController.value.clear();
//     serviceMobileController.value.clear();
//     serviceAmountController.value.clear();
//     serviceSelectedDevice.value = '';
//     selectedBankName.value = '';
//     selectedBankId.value = '';
//     selectedBankIin.value = '';
//   }
//
//   void resetOnboardingForm() {
//     otpController.value.clear();
//     bankAccountController.value.clear();
//     ifscController.value.clear();
//   }
//
//   void resetSelectedBank() {
//     selectedMyBank.value = null;
//     filteredMyBankList.assignAll(myBankList);
//     searchCtrl.clear();
//
//     // ✅ Reset Fingpay states
//     showFingpayOnboardingForm.value = false;
//     showFingpay2FAForm.value = false;
//     showFingpayOnboardAuthForm.value = false;
//     showFingpayOtpModal.value = false;
//     canProceedToFingpayServices.value = false;
//   }
//
//   // ✅ NEW: Reset Instantpay states when entering AEPS Three screen
//   void resetInstantpayState() {
//     showInstantpayOnboardingForm.value = false;
//     showInstantpay2FAForm.value = false;
//     showInstantpayOnboardAuthForm.value = false;
//     showInstantpayOtpModal.value = false;
//     canProceedToInstantpayServices.value = false;
//     selectedDevice.value = '';
//   }
//
//   // ✅ NEW: Reset Fingpay states when entering AEPS One screen
//   void resetFingpayState() {
//     showFingpayOnboardingForm.value = false;
//     showFingpay2FAForm.value = false;
//     showFingpayOnboardAuthForm.value = false;
//     showFingpayOtpModal.value = false;
//     canProceedToFingpayServices.value = false;
//     selectedMyBank.value = null;
//     filteredMyBankList.assignAll(myBankList);
//     searchCtrl.clear();
//     selectedDevice.value = '';
//   }
//
//   @override
//   void onClose() {
//     // Screen close होते ही bank selection reset करें
//     // resetSelectedBank();
//     resetFingpayState();
//     resetInstantpayState();
//     super.onClose();
//   }
//
//   // ============== Bank Selection ==============
//
//   void selectBank(AepsBank bank) {
//     selectedBankName.value = bank.bankName ?? '';
//     selectedBankId.value = bank.id ?? '';
//     selectedBankIin.value = bank.bankIin ?? '';
//   }
//
//   void selectMyBank(GetAllMyBankListData bank) {
//     selectedMyBank.value = bank;
//   }
//   // void selectMyBank(MyBankAccount bank) {
//   //   selectedMyBank.value = bank;
//   // }
//
//   // ============== Modal Controls ==============
//
//   void closeOtpModal() {
//     showFingpayOtpModal.value = false;
//     showInstantpayOtpModal.value = false;
//     otpController.value.clear();
//   }
//
//   void closeConfirmationModal() {
//     showConfirmationModal.value = false;
//     confirmationData.value = null;
//     txnPinController.value.clear();
//   }
//
//   void closeResultModal() {
//     showResultModal.value = false;
//     transactionResult.value = null;
//   }
//
//   // ============== Validation Helpers ==============
//
//   bool validateAadhaar(String aadhaar) {
//     return aadhaar.length == 12 && RegExp(r'^[0-9]+$').hasMatch(aadhaar);
//   }
//
//   bool validateMobile(String mobile) {
//     return mobile.length == 10 && RegExp(r'^[0-9]+$').hasMatch(mobile);
//   }
//
//   bool validateOtp(String otp) {
//     return otp.length == 6 && RegExp(r'^[0-9]+$').hasMatch(otp);
//   }
//
//   // ============== Device Selection ==============
//
//   void onDeviceChange(String? value) {
//     if (value != null) {
//       selectedDevice.value = value;
//     }
//   }
//
//   void onServiceDeviceChange(String? value) {
//     if (value != null) {
//       serviceSelectedDevice.value = value;
//     }
//   }
//
//   // ============== Input Formatters ==============
//
//   String formatAadhaarInput(String value) {
//     return value.replaceAll(RegExp(r'[^0-9]'), '');
//   }
//
//   String formatMobileInput(String value) {
//     return value.replaceAll(RegExp(r'[^0-9]'), '');
//   }
//
//   // ============== Status Helpers ==============
//
//   String getTransactionStatusColor(String? status) {
//     switch (status?.toUpperCase()) {
//       case 'SUCCESS':
//         return '#47D96C';
//       case 'FAILED':
//         return '#FF0000';
//       case 'PENDING':
//         return '#EA8F43';
//       default:
//         return '#EA8F43';
//     }
//   }
//
//   Color getStatusColor(String? status) {
//     switch (status?.toUpperCase()) {
//       case 'SUCCESS':
//         return const Color(0xFF47D96C);
//       case 'FAILED':
//         return Colors.red;
//       case 'PENDING':
//         return const Color(0xFFEA8F43);
//       default:
//         return const Color(0xFFEA8F43);
//     }
//   }
//
//   String getStatusImage(String? status) {
//     switch (status?.toUpperCase()) {
//       case 'SUCCESS':
//         return 'assets/images/checked.png';
//       case 'FAILED':
//         return 'assets/images/cancel.png';
//       case 'PENDING':
//         return 'assets/images/clock.png';
//       default:
//         return 'assets/images/clock.png';
//     }
//   }
// }
//
// // ============== Model Classes (if not imported separately) ==============
// // These should be in a separate file, included here for reference
//
// class AepsBank {
//   final String? id;
//   final String? bankName;
//   final String? bankIin;
//   final String? isFav;
//
//   AepsBank({this.id, this.bankName, this.bankIin, this.isFav});
//
//   factory AepsBank.fromJson(Map<String, dynamic> json) {
//     return AepsBank(
//       id: json['id']?.toString(),
//       bankName: json['bank_name'],
//       bankIin: json['bank_iin'],
//       isFav: json['is_fav']?.toString(),
//     );
//   }
// }
//
// class MyBankAccount {
//   final String? id;
//   final String? accountNo;
//   final String? ifsc;
//   final String? aepsBankId;
//   final String? bankName;
//
//   MyBankAccount({this.id, this.accountNo, this.ifsc, this.aepsBankId, this.bankName});
//
//   factory MyBankAccount.fromJson(Map<String, dynamic> json) {
//     return MyBankAccount(
//       id: json['id']?.toString(),
//       accountNo: json['account_no'],
//       ifsc: json['ifsc'],
//       aepsBankId: json['aeps_bankid'],
//       bankName: json['bank_name'],
//     );
//   }
// }
//
// class AepsConfirmData {
//   final String? commission;
//   final String? tds;
//   final String? totalcharge;
//   final String? totalccf;
//   final String? trasamt;
//   final String? chargedamt;
//   final String? txnpin;
//
//   AepsConfirmData({
//     this.commission,
//     this.tds,
//     this.totalcharge,
//     this.totalccf,
//     this.trasamt,
//     this.chargedamt,
//     this.txnpin,
//   });
//
//   factory AepsConfirmData.fromJson(Map<String, dynamic> json) {
//     return AepsConfirmData(
//       commission: json['commission']?.toString(),
//       tds: json['tds']?.toString(),
//       totalcharge: json['totalcharge']?.toString(),
//       totalccf: json['totalccf']?.toString(),
//       trasamt: json['trasamt']?.toString(),
//       chargedamt: json['chargedamt']?.toString(),
//       txnpin: json['txnpin']?.toString(),
//     );
//   }
// }
//
// class AepsTransactionData {
//   final String? txnStatus;
//   final String? txnDesc;
//   final String? balance;
//   final String? date;
//   final String? txnid;
//   final String? opid;
//   final String? trasamt;
//   final List<MiniStatementItem>? statement;
//
//   AepsTransactionData({
//     this.txnStatus,
//     this.txnDesc,
//     this.balance,
//     this.date,
//     this.txnid,
//     this.opid,
//     this.trasamt,
//     this.statement,
//   });
//
//   factory AepsTransactionData.fromJson(Map<String, dynamic> json) {
//     List<MiniStatementItem>? statementList;
//     if (json['statement'] != null && json['statement'] is List) {
//       var list = json['statement'] as List;
//       if (list.isNotEmpty && list.first is Map) {
//         statementList = list.map((e) => MiniStatementItem.fromJson(e)).toList();
//       }
//     }
//     return AepsTransactionData(
//       txnStatus: json['txn_status'],
//       txnDesc: json['txn_desc'],
//       balance: json['balance']?.toString(),
//       date: json['date'],
//       txnid: json['txnid'],
//       opid: json['opid'],
//       trasamt: json['trasamt']?.toString(),
//       statement: statementList,
//     );
//   }
// }
//
// class MiniStatementItem {
//   final String? date;
//   final String? narration;
//   final String? txnType;
//   final String? amount;
//
//   MiniStatementItem({this.date, this.narration, this.txnType, this.amount});
//
//   factory MiniStatementItem.fromJson(Map<String, dynamic> json) {
//     return MiniStatementItem(
//       date: json['date'],
//       narration: json['narration'],
//       txnType: json['txnType'],
//       amount: json['amount']?.toString(),
//     );
//   }
// }
//
// class AepsOnboardingData {
//   final String? aadhaar;
//   final String? otpReferenceID;
//   final String? hash;
//   final String? primaryKeyId;
//   final String? encodeFPTxnId;
//
//   AepsOnboardingData({
//     this.aadhaar,
//     this.otpReferenceID,
//     this.hash,
//     this.primaryKeyId,
//     this.encodeFPTxnId,
//   });
//
//   factory AepsOnboardingData.fromJson(Map<String, dynamic> json) {
//     return AepsOnboardingData(
//       aadhaar: json['aadhaar'],
//       otpReferenceID: json['otpReferenceID'],
//       hash: json['hash'],
//       primaryKeyId: json['primaryKeyId'],
//       encodeFPTxnId: json['encodeFPTxnId'],
//     );
//   }
// }
//
// class RecentTransaction {
//   final String? customerId;
//   final String? requestDt;
//   final String? recordType;
//   final String? txnAmt;
//   final String? portalStatus;
//   final String? portalTxnId;
//
//   RecentTransaction({
//     this.customerId,
//     this.requestDt,
//     this.recordType,
//     this.txnAmt,
//     this.portalStatus,
//     this.portalTxnId,
//   });
//
//   factory RecentTransaction.fromJson(Map<String, dynamic> json) {
//     return RecentTransaction(
//       customerId: json['customer_id'],
//       requestDt: json['request_dt'],
//       recordType: json['record_type'],
//       txnAmt: json['txn_amt']?.toString(),
//       portalStatus: json['portal_status'],
//       portalTxnId: json['portal_txn_id'],
//     );
//   }
// }



















import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/get_all_my_bank_list_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/global_utils.dart';
import '../utils/pid_data_converter.dart';
import '../view/onboarding_screen.dart';
import 'aeps_biometric_service.dart';
import 'payrupya_home_screen_controller.dart';
import 'package:payrupya/models/check_fingpay_auth_status_response_model.dart';
import 'package:payrupya/models/check_instantpay_bio_auth_status_response_model.dart';
import 'package:android_intent_plus/android_intent.dart';

// Import your project files - adjust paths as needed
// import '../api/api_provider.dart';
// import '../api/web_api_constant.dart';
// import '../models/check_fingpay_auth_status_response_model.dart';
// import '../models/check_instantpay_bio_auth_status_response_model.dart';
// import '../models/get_all_my_bank_list_response_model.dart';
// import '../utils/ConsoleLog.dart';
// import '../utils/app_shared_preferences.dart';
// import '../utils/connection_validator.dart';
// import '../utils/global_utils.dart';
// import '../view/onboarding_screen.dart';
// import 'session_manager.dart';
// import 'payrupya_home_screen_controller.dart';
// import 'aeps_biometric_service.dart';

/// ============================================
/// AEPS CONTROLLER - COMPLETE IMPLEMENTATION
/// ============================================
/// Handles both Fingpay (AEPS One) and Instantpay (AEPS Three)
/// with full biometric integration
/// ============================================

class AepsController extends GetxController {
  // ============== Dependencies ==============
  // Uncomment and adjust based on your project structure
  PayrupyaHomeScreenController get homeScreenController => Get.find<PayrupyaHomeScreenController>();
  // Fingpay 2FA Auth Data
  Rxn<FingpayAuthData> fingpayAuthData = Rxn<FingpayAuthData>();

  // Instantpay 2FA Auth Data
  Rxn<InstantpayAuthData> instantpayAuthData = Rxn<InstantpayAuthData>();
  // AepsBiometricService get biometricService => Get.find<AepsBiometricService>();

  // ============== Loading States ==============
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
  RxBool isFingpay2FA_ProcessLoading = false.obs;
  RxBool isInstantpay2FA_ProcessLoading = false.obs;
  RxBool isGetAepsBanklistLoading = false.obs;
  RxBool isGetRecentTransactionsLoading = false.obs;
  RxBool isMarkFavoriteBankLoading = false.obs;
  RxBool isBiometricScanning = false.obs;

  // ============== Auth Credentials ==============
  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;

  // ============== Fingpay States ==============
  RxBool isFingpayOnboarded = false.obs;
  RxBool isFingpayTwoFactorAuthenticated = false.obs;
  RxBool showFingpayOnboardingForm = false.obs;
  RxBool showFingpay2FAForm = false.obs;
  RxBool showFingpayOtpModal = false.obs;
  RxBool showFingpayOnboardAuthForm = false.obs;
  RxBool canProceedToFingpayServices = false.obs;
  RxBool isFingpay2FACompleted = false.obs;

  // ============== Instantpay States ==============
  RxBool isInstantpayOnboarded = false.obs;
  RxBool isInstantTwoFactorAuthenticated = false.obs;
  RxBool showInstantpayOnboardingForm = false.obs;
  RxBool showInstantpay2FAForm = false.obs;
  RxBool showInstantpayOtpModal = false.obs;
  RxBool showInstantpayOnboardAuthForm = false.obs;
  RxBool canProceedToInstantpayServices = false.obs;
  RxBool isInstantpay2FACompleted = false.obs;

  // ============== Service Selection ==============
  RxString selectedService = 'balanceCheck'.obs;
  RxBool showAmountInput = false.obs;
  RxString currentAepsType = 'fingpay'.obs; // 'fingpay' or 'instantpay'

  // ============== Bank Lists ==============
  RxList<AepsBank> allBankList = <AepsBank>[].obs;
  RxList<AepsBank> favoritesList = <AepsBank>[].obs;
  RxList<AepsBank> filteredBankList = <AepsBank>[].obs;
  RxString selectedBankName = ''.obs;
  RxString selectedBankId = ''.obs;
  RxString selectedBankIin = ''.obs;

  // My Bank List (for Fingpay onboarding)
  RxList<GetAllMyBankListData> myBankList = <GetAllMyBankListData>[].obs;
  Rx<GetAllMyBankListData?> selectedMyBank = Rx<GetAllMyBankListData?>(null);
  RxList<GetAllMyBankListData> filteredMyBankList = <GetAllMyBankListData>[].obs;

  // ============== Transaction Data ==============
  Rx<AepsConfirmData?> confirmationData = Rx<AepsConfirmData?>(null);
  Rx<AepsTransactionData?> transactionResult = Rx<AepsTransactionData?>(null);
  RxList<RecentTransaction> recentTransactions = <RecentTransaction>[].obs;

  // ============== OTP/Onboarding Reference ==============
  Rx<AepsOnboardingData?> otpReference = Rx<AepsOnboardingData?>(null);

  // ============== Modal States ==============
  RxBool showConfirmationModal = false.obs;
  RxBool showResultModal = false.obs;
  RxBool showBiometricModal = false.obs;

  // ============== Device List ==============
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
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController bankAccountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController shopAddressController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController serviceAadhaarController = TextEditingController();
  final TextEditingController serviceMobileController = TextEditingController();
  final TextEditingController serviceAmountController = TextEditingController();
  final TextEditingController txnPinController = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  RxString selectedDevice = ''.obs;
  RxString serviceSelectedDevice = ''.obs;

  // ============== Biometric Data ==============
  RxString lastPidData = ''.obs;
  RxBool biometricSuccess = false.obs;
  RxString biometricError = ''.obs;

  // Method Channel for Biometric
  static const MethodChannel _biometricChannel = MethodChannel('aeps_biometric_channel');

  // ============== WADH Constants ==============
  static const String WADH_FOR_EKYC = 'E0jzJ/P8UopUHAieZn8CKqS4WPMi5ZSYXgfnlfkWjrc=';
  static const String WADH_EMPTY = '';

  // ============== Service Keys ==============
  // Fingpay (AEPS One)
  static const String SKEY_FINGPAY_BALANCE = 'BCSFNGPY';
  static const String SKEY_FINGPAY_WITHDRAWAL = 'CWSFNGPY';
  static const String SKEY_FINGPAY_STATEMENT = 'MSTFNGPY';
  static const String SKEY_FINGPAY_AADHAAR_PAY = 'ADRFNGPY';

  // Instantpay (AEPS Three)
  static const String SKEY_INSTANTPAY_BALANCE = 'BAP';
  static const String SKEY_INSTANTPAY_WITHDRAWAL = 'WAP';
  static const String SKEY_INSTANTPAY_STATEMENT = 'SAP';

  // Common
  static const String SKEY_TWO_FACTOR_AUTH = 'TWOFACTORAUTH';

  // ============== Lifecycle ==============

  @override
  void onInit() {
    super.onInit();
    loadAuthCredentials();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    aadhaarController.dispose();
    mobileController.dispose();
    emailController.dispose();
    panController.dispose();
    bankAccountController.dispose();
    ifscController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    shopNameController.dispose();
    gstController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    shopAddressController.dispose();
    otpController.dispose();
    serviceAadhaarController.dispose();
    serviceMobileController.dispose();
    serviceAmountController.dispose();
    txnPinController.dispose();
    searchCtrl.dispose();
  }

  // ============== Auth Credentials ==============

  // Future<void> loadAuthCredentials() async {
  //   try {
  //     // Load from your AppSharedPreferences
  //     // Map<String, String> authData = await AppSharedPreferences.getLoginAuth();
  //     // userAuthToken.value = authData["token"] ?? "";
  //     // userSignature.value = authData["signature"] ?? "";
  //
  //     print("✅ Auth credentials loaded");
  //   } catch (e) {
  //     print("❌ Error loading auth credentials: $e");
  //   }
  // }
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

  // ============== Reset Methods ==============

  /// ✅ Reset Fingpay State
  void resetFingpayState() {
    isFingpayOnboarded.value = false;
    isFingpayTwoFactorAuthenticated.value = false;
    showFingpayOnboardingForm.value = false;
    showFingpay2FAForm.value = false;
    showFingpayOtpModal.value = false;
    showFingpayOnboardAuthForm.value = false;
    canProceedToFingpayServices.value = false;
    isFingpay2FACompleted.value = false;
    otpReference.value = null;
    fingpayAuthData.value = null;
    lastPidData.value = '';
    biometricSuccess.value = false;
    biometricError.value = '';
    selectedDevice.value = '';
    otpController.clear();
    ConsoleLog.printInfo("🔄 Fingpay state reset");
  }

  /// ✅ Reset Instantpay State
  void resetInstantpayState() {
    isInstantpayOnboarded.value = false;
    isInstantTwoFactorAuthenticated.value = false;
    showInstantpayOnboardingForm.value = false;
    showInstantpay2FAForm.value = false;
    showInstantpayOtpModal.value = false;
    showInstantpayOnboardAuthForm.value = false;
    canProceedToInstantpayServices.value = false;
    isInstantpay2FACompleted.value = false;
    otpReference.value = null;
    instantpayAuthData.value = null;
    lastPidData.value = '';
    biometricSuccess.value = false;
    biometricError.value = '';
    selectedDevice.value = '';
    otpController.clear();
    ConsoleLog.printInfo("🔄 Instantpay state reset");
  }

  /// ✅ Reset All AEPS State
  void resetAllAepsState() {
    resetFingpayState();
    resetInstantpayState();
    selectedService.value = 'balanceCheck';
    showAmountInput.value = false;
    showConfirmationModal.value = false;
    showResultModal.value = false;
    showBiometricModal.value = false;
    ConsoleLog.printInfo("🔄 All AEPS state reset");
  }

  void resetServiceForm() {
    serviceAadhaarController.clear();
    serviceMobileController.clear();
    serviceAmountController.clear();
    serviceSelectedDevice.value = '';
    selectedBankName.value = '';
    selectedBankId.value = '';
    selectedBankIin.value = '';
  }

  void resetBiometricState() {
    lastPidData.value = '';
    biometricSuccess.value = false;
    isBiometricScanning.value = false;
    showBiometricModal.value = false;
  }

  // ============== Utility Methods ==============

  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }

  String getSkey() {
    if (currentAepsType.value == 'fingpay') {
      switch (selectedService.value) {
        case 'balanceCheck': return SKEY_FINGPAY_BALANCE;
        case 'cashWithdrawal': return SKEY_FINGPAY_WITHDRAWAL;
        case 'miniStatement': return SKEY_FINGPAY_STATEMENT;
        case 'aadhaarPay': return SKEY_FINGPAY_AADHAAR_PAY;
        default: return SKEY_FINGPAY_BALANCE;
      }
    } else {
      switch (selectedService.value) {
        case 'balanceCheck': return SKEY_INSTANTPAY_BALANCE;
        case 'cashWithdrawal': return SKEY_INSTANTPAY_WITHDRAWAL;
        case 'miniStatement': return SKEY_INSTANTPAY_STATEMENT;
        default: return SKEY_INSTANTPAY_BALANCE;
      }
    }
  }

  String getWadh({bool forEkyc = false}) {
    return forEkyc ? WADH_FOR_EKYC : WADH_EMPTY;
  }

  void onServiceSelect(String service) {
    selectedService.value = service;
    showAmountInput.value = (service == 'cashWithdrawal' || service == 'aadhaarPay');
    showConfirmationModal.value = false;
    showResultModal.value = false;
  }

  /// Add onDeviceChange method
  void onDeviceChange(String? value) {
    selectedDevice.value = value ?? '';
    ConsoleLog.printInfo("Device selected: ${selectedDevice.value}");
  }

  /// Add serviceDeviceChange method
  void onServiceDeviceChange(String? value) {
    serviceSelectedDevice.value = value ?? '';
    ConsoleLog.printInfo("Service Device selected: ${serviceSelectedDevice.value}");
  }


  // ============== Bank Selection ==============

  void filterBank(String query) {
    if (query.isEmpty) {
      filteredBankList.assignAll(allBankList);
    } else {
      filteredBankList.assignAll(
        allBankList.where((bank) =>
        bank.bankName?.toLowerCase().contains(query.toLowerCase()) ?? false
        ),
      );
    }
  }

  void filterMyBank(String query) {
    if (query.isEmpty) {
      filteredMyBankList.assignAll(myBankList);
    } else {
      filteredMyBankList.assignAll(
        myBankList.where((bank) =>
        bank.bankName?.toLowerCase().contains(query.toLowerCase()) ?? false
        ),
      );
    }
  }

  void selectBank(AepsBank bank) {
    selectedBankName.value = bank.bankName ?? '';
    selectedBankId.value = bank.id ?? '';
    selectedBankIin.value = bank.bankIin ?? '';
  }

  // ============== Biometric Scan Methods ==============

  Future<BiometricResult> scanFingerprint({
    required String device,
    bool forEkyc = false,
  }) async {
    if (isBiometricScanning.value) {
      return BiometricResult(
        success: false,
        errorCode: 'BUSY',
        errorMessage: 'Scan already in progress',
      );
    }

    if (device.isEmpty) {
      return BiometricResult(
        success: false,
        errorCode: 'NO_DEVICE',
        errorMessage: 'Please select a biometric device',
      );
    }

    try {
      isBiometricScanning.value = true;
      biometricError.value = '';
      biometricSuccess.value = false;

      final wadh = forEkyc ? WADH_FOR_EKYC : WADH_EMPTY;

      ConsoleLog.printInfo('📱 Starting fingerprint scan...');
      ConsoleLog.printInfo('   Device: $device');
      ConsoleLog.printInfo('   Type: ${forEkyc ? "eKYC" : "2FA/Transaction"}');

      final result = await _biometricChannel.invokeMethod('scanFingerprint', {
        'device': device,
        'wadh': wadh,
      });

      isBiometricScanning.value = false;

      if (result != null && result is Map) {
        if (result['success'] == true) {
          final pidData = result['pidData'] as String? ?? '';
          lastPidData.value = pidData;
          biometricSuccess.value = true;

          ConsoleLog.printSuccess('✅ Fingerprint captured! Length: ${pidData.length}');

          return BiometricResult(
            success: true,
            pidData: pidData,
            device: device,
          );
        }
      }

      return BiometricResult(
        success: false,
        errorCode: 'UNKNOWN',
        errorMessage: 'Failed to capture fingerprint',
      );

    } on PlatformException catch (e) {
      isBiometricScanning.value = false;
      biometricError.value = e.message ?? '';
      biometricSuccess.value = false;

      ConsoleLog.printError('❌ Platform Error: ${e.code} - ${e.message}');

      // Handle different error types
      switch (e.code) {
        case 'DEVICE_NOT_INSTALLED':
        // Show dialog with Play Store download link
          String deviceName = selectedDevice.value;
          if (e.details != null && e.details is Map) {
            deviceName = (e.details as Map)['device'] ?? selectedDevice.value;
          }
          _showRdServiceInstallDialog(deviceName);
          break;

        case 'DEVICE_NOT_CONNECTED':
        // ✅ NEW: Show device not connected dialog
          _showDeviceNotConnectedDialog();
          break;

        case 'DEVICE_NOT_READY':
        case 'CAPTURE_FAILED':
        case 'POOR_QUALITY':
        case 'CAPTURE_TIMEOUT':
        // Show toast with error message
          String message = _getBiometricErrorMessage(e.code, e.message ?? '');
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red.shade600,
          );
          break;

        default:
        // Show generic error toast
          String message = _getBiometricErrorMessage(e.code, e.message ?? '');
          Fluttertoast.showToast(msg: message);
          break;
      }

      return BiometricResult(
        success: false,
        errorCode: e.code,
        errorMessage: _getBiometricErrorMessage(e.code, e.message ?? ''),
      );
    }
  }

  /// Show dialog when biometric device is not connected
  void _showDeviceNotConnectedDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        actionsPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.usb_off, color: Colors.red.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Device Not Connected',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your biometric device is not connected.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please check:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem('Device is properly connected via USB/OTG'),
                  _buildCheckItem('RD Service app is running'),
                  _buildCheckItem('Device LED is blinking (if applicable)'),
                  _buildCheckItem('USB OTG is enabled in settings'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Open the RD Service app first to verify device connection',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK', style: GoogleFonts.albertSans(color: Colors.black, fontWeight: FontWeight.w800)
                ),
              ),
              GlobalUtils.CustomButton(
                onPressed: () {
                  Get.back();
                  // Open RD Service app
                  _openRdServiceApp();
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                text: 'Open RD Service',
                textStyle: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                height: GlobalUtils.screenWidth * (60 / 393),
                backgroundGradient: GlobalUtils.blueBtnGradientColor,
                borderColor: Color(0xFF71A9FF),
                showShadow: false,
                textColor: Colors.white,
                animation: ButtonAnimation.fade,
                animationDuration: const Duration(milliseconds: 150),
                buttonType: ButtonType.elevated,
                borderRadius: 16,
              ),
            ],
          ),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     Get.back();
          //     // Open RD Service app
          //     _openRdServiceApp();
          //   },
          //   icon: const Icon(Icons.open_in_new, size: 18),
          //   label: const Text('Open RD Service'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xFF2E5BFF),
          //     foregroundColor: Colors.white,
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //   ),
          // ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Open RD Service app based on selected device
  void _openRdServiceApp() async {
    final Map<String, String> devicePackages = {
      'MANTRA': 'com.mantra.rdservice',
      'MFS110': 'com.mantra.mfs110.rdservice',
      'MIS100V2': 'com.mantra.mis100v2.rdservice',
      'MORPHO': 'com.scl.rdservice',
      'Morpho L1': 'com.scl.rdservice',
      'Idemia': 'com.idemia.l1rdservice',
      'SecuGen Corp.': 'com.secugen.rdservice',
      'STARTEK': 'com.acpl.registersdk',
      'TATVIK': 'com.aborygen.rdservice',
    };

    final packageName = devicePackages[selectedDevice.value];

    if (packageName == null) {
      Fluttertoast.showToast(msg: 'Please open RD Service app manually');
      return;
    }

    try {
      // Method 1: Try using url_launcher with package scheme
      final Uri appUri = Uri.parse('package:$packageName');

      // Method 2: Try Android app scheme (more reliable)
      final Uri launchUri = Uri.parse('android-app://$packageName');

      // Method 3: Try market URI to at least show the app in Play Store
      final Uri marketUri = Uri.parse('market://details?id=$packageName');

      // Try to launch the app directly
      bool launched = false;

      // First try: Direct app launch via platform channel
      launched = await _launchAppViaChannel(packageName);

      if (!launched) {
        // Fallback: Open in Play Store
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          Fluttertoast.showToast(
            msg: 'Opening Play Store. Please launch the app after installation.',
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(msg: 'Please open RD Service app manually');
        }
      }
    } catch (e) {
      ConsoleLog.printError('Error launching RD Service: $e');
      Fluttertoast.showToast(msg: 'Please open RD Service app manually');
    }
    // if (packageName != null) {
    //   try {
    //     // Try to open the app using package name
    //     final intent = AndroidIntent(
    //       action: 'android.intent.action.MAIN',
    //       package: packageName,
    //     );
    //     intent.launch().catchError((e) {
    //       ConsoleLog.printError('Failed to open RD Service: $e');
    //       Fluttertoast.showToast(msg: 'Could not open RD Service app');
    //     });
    //   } catch (e) {
    //     ConsoleLog.printError('Error launching RD Service: $e');
    //     Fluttertoast.showToast(msg: 'Please open RD Service app manually');
    //   }
    // } else {
    //   Fluttertoast.showToast(msg: 'Please open RD Service app manually');
    // }
  }

  /// Launch app via platform channel
  Future<bool> _launchAppViaChannel(String packageName) async {
    try {
      const channel = MethodChannel('aeps_biometric_channel');
      final result = await channel.invokeMethod('launchApp', {
        'package': packageName,
      });
      return result == true;
    } catch (e) {
      ConsoleLog.printError('Platform channel launch failed: $e');
      return false;
    }
  }

  /// Get user-friendly error message for biometric errors
  String _getBiometricErrorMessage(String code, String message) {
    switch (code) {
    // Device Installation Errors
      case 'DEVICE_NOT_INSTALLED':
        return 'RD Service app not installed. Please download from Play Store.';

    // ✅ NEW: Device Connection Errors
      case 'DEVICE_NOT_CONNECTED':
        return 'Biometric device not connected. Please connect your device and try again.';
      case 'DEVICE_NOT_READY':
        return 'Device is not ready. Please wait and try again.';
      case 'DEVICE_NOT_REGISTERED':
        return 'Device is not registered. Please register in RD Service app.';

    // Capture Errors
      case 'CAPTURE_FAILED':
        return 'Fingerprint capture failed. Please try again.';
      case 'CAPTURE_TIMEOUT':
        return 'Capture timeout. Please place finger on device and try again.';
      case 'POOR_QUALITY':
        return 'Poor fingerprint quality. Clean your finger and try again.';

    // User Actions
      case 'CANCELLED':
        return 'Scan cancelled. Please try again.';
      case 'NO_DATA':
        return 'No fingerprint data received. Please try again.';

    // Device Errors
      case 'UNKNOWN_DEVICE':
        return 'Unknown device selected. Please choose a valid device.';
      case 'NO_DEVICE':
        return 'No device selected. Please select a biometric device.';

    // Legacy RD Error Codes (direct from RD Service)
      case '100':
      case '700':
        return 'Device not found. Please connect your biometric device.';
      case '710':
      case '720':
        return 'Device not ready. Please connect device and try again.';
      case '730':
        return 'Poor quality fingerprint. Clean finger and retry.';
      case '740':
        return 'Capture timeout. Please try again.';

    // Validation Errors
      case 'VALIDATION_ERROR':
        return 'Failed to validate fingerprint data. Please try again.';

      default:
        return message.isNotEmpty ? message : 'Biometric scan failed. Please retry.';
    }
  }

  /// Show RD Service installation dialog with Play Store link
  void _showRdServiceInstallDialog(String device) {
    // Device info with package names
    final Map<String, Map<String, String>> deviceInfo = {
      'MANTRA': {
        'package': 'com.mantra.rdservice',
        'name': 'Mantra MFS100 RD Service',
      },
      'MFS110': {
        'package': 'com.mantra.mfs110.rdservice',
        'name': 'Mantra MFS110 RD Service',
      },
      'MIS100V2': {
        'package': 'com.mantra.mis100v2.rdservice',
        'name': 'Mantra Iris MIS100V2 RD Service',
      },
      'MORPHO': {
        'package': 'com.scl.rdservice',
        'name': 'Morpho SCL RD Service',
      },
      'Idemia': {
        'package': 'com.idemia.l1rdservice',
        'name': 'Idemia L1 RD Service',
      },
      'SecuGen Corp.': {
        'package': 'com.secugen.rdservice',
        'name': 'SecuGen RD Service',
      },
      'STARTEK': {
        'package': 'com.acpl.registersdk',
        'name': 'Startek FM220 RD Service',
      },
      'TATVIK': {
        'package': 'com.aborygen.rdservice',
        'name': 'Tatvik TMF20 RD Service',
      },
    };

    final info = deviceInfo[device];
    final packageName = info?['package'] ?? '';
    final deviceName = info?['name'] ?? '$device RD Service';
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';

    // Show GetX Snackbar with Download button
    // ✅ Use Get.dialog instead of Get.snackbar to avoid Overlay errors
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'RD Service Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To use fingerprint authentication, please install:',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.fingerprint, color: Colors.blue.shade700, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'from Google Play Store',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'After installation:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            _buildInstallStep('1', 'Open the RD Service app'),
            _buildInstallStep('2', 'Connect your biometric device'),
            _buildInstallStep('3', 'Come back here and try again'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await _openPlayStore(packageName);
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    // Get.snackbar(
    //   'RD Service Not Installed',
    //   'Please install $deviceName to continue',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.orange.shade100,
    //   colorText: Colors.orange.shade900,
    //   duration: const Duration(seconds: 6),
    //   margin: const EdgeInsets.all(16),
    //   borderRadius: 12,
    //   icon: Icon(
    //     Icons.warning_amber_rounded,
    //     color: Colors.orange.shade700,
    //     size: 28,
    //   ),
    //   mainButton: TextButton(
    //     onPressed: () async {
    //       Get.back(); // Close snackbar
    //       await _openPlayStore(packageName);
    //     },
    //     child: Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //       decoration: BoxDecoration(
    //         color: const Color(0xFF2E5BFF),
    //         borderRadius: BorderRadius.circular(8),
    //       ),
    //       child: const Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Icon(Icons.download, color: Colors.white, size: 16),
    //           SizedBox(width: 6),
    //           Text(
    //             'Download',
    //             style: TextStyle(
    //               color: Colors.white,
    //               fontWeight: FontWeight.w600,
    //               fontSize: 13,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  /// Helper method to build installation steps
  Widget _buildInstallStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }


  // /// Show RD Service installation dialog (Alternative - More prominent)
  // void _showRdServiceInstallDialogFull(String device) {
  //   final Map<String, Map<String, String>> deviceInfo = {
  //     'MANTRA': {'package': 'com.mantra.rdservice', 'name': 'Mantra MFS100 RD Service'},
  //     'MFS110': {'package': 'com.mantra.mfs110.rdservice', 'name': 'Mantra MFS110 RD Service'},
  //     'MIS100V2': {'package': 'com.mantra.mis100v2.rdservice', 'name': 'Mantra Iris RD Service'},
  //     'MORPHO': {'package': 'com.scl.rdservice', 'name': 'Morpho SCL RD Service'},
  //     'Idemia': {'package': 'com.idemia.l1rdservice', 'name': 'Idemia L1 RD Service'},
  //     'SecuGen Corp.': {'package': 'com.secugen.rdservice', 'name': 'SecuGen RD Service'},
  //     'STARTEK': {'package': 'com.acpl.registersdk', 'name': 'Startek FM220 RD Service'},
  //     'TATVIK': {'package': 'com.aborygen.rdservice', 'name': 'Tatvik TMF20 RD Service'},
  //   };
  //
  //   final info = deviceInfo[device];
  //   final packageName = info?['package'] ?? '';
  //   final deviceName = info?['name'] ?? '$device RD Service';
  //
  //   Get.dialog(
  //     AlertDialog(
  //       // contentPadding: EdgeInsets.all(0),
  //       actionsPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Colors.orange.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
  //           ),
  //           const SizedBox(width: 12),
  //           const Expanded(
  //             child: Text('RD Service Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'To use fingerprint authentication, please install:',
  //             style: TextStyle(fontSize: 14, color: Colors.grey[700]),
  //           ),
  //           const SizedBox(height: 16),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.blue.shade100),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.fingerprint, color: Colors.blue.shade700, size: 32),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(deviceName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
  //                       const SizedBox(height: 2),
  //                       Text('from Google Play Store', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Text('After installation:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800])),
  //           const SizedBox(height: 8),
  //           _buildStepRow('1', 'Open the RD Service app'),
  //           _buildStepRow('2', 'Connect your biometric device'),
  //           _buildStepRow('3', 'Come back here and try again'),
  //         ],
  //       ),
  //       actions: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             TextButton(
  //               onPressed: () => Get.back(),
  //               child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
  //             ),
  //             GlobalUtils.CustomButton(
  //               onPressed: () async {
  //                 Get.back();
  //                 await _openPlayStore(packageName);
  //               },
  //               icon: const Icon(Icons.download, size: 18),
  //               text: 'Download Now',
  //               textStyle: GoogleFonts.albertSans(
  //                 fontSize: 16,
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               height: GlobalUtils.screenWidth * (60 / 393),
  //               backgroundGradient: GlobalUtils.blueBtnGradientColor,
  //               borderColor: Color(0xFF71A9FF),
  //               showShadow: false,
  //               textColor: Colors.white,
  //               animation: ButtonAnimation.fade,
  //               animationDuration: const Duration(milliseconds: 150),
  //               buttonType: ButtonType.elevated,
  //               borderRadius: 16,
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //     barrierDismissible: true,
  //   );
  // }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(number, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// Open Play Store for package
  Future<void> _openPlayStore(String packageName) async {
    try {
      // Try Play Store URL first
      final playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

      if (await canLaunchUrl(playStoreUrl)) {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to market URI
        final marketUrl = Uri.parse('market://details?id=$packageName');
        if (await canLaunchUrl(marketUrl)) {
          await launchUrl(marketUrl);
        } else {
          Fluttertoast.showToast(msg: 'Could not open Play Store');
        }
      }
    } catch (e) {
      ConsoleLog.printError('Error opening Play Store: $e');
      Fluttertoast.showToast(msg: 'Error opening Play Store');
    }
  }

  /// Scan fingerprint for 2FA authentication
  /// Uses MethodChannel to call native Android code
  Future<bool> scanFingerprintFor2FA() async {
    if (selectedDevice.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a biometric device');
      return false;
    }

    isBiometricScanning.value = true;
    showBiometricModal.value = true;

    try {
      // ✅ REAL biometric call - NOT MOCK DATA
      final result = await scanFingerprint(
        device: selectedDevice.value,
        forEkyc: false, // Empty WADH for 2FA
      );

      isBiometricScanning.value = false;

      if (result.success && result.pidData != null && result.pidData!.isNotEmpty) {
        lastPidData.value = result.pidData!;
        biometricSuccess.value = true;
        showBiometricModal.value = false;
        ConsoleLog.printSuccess("✅ 2FA Fingerprint captured: ${result.pidData!.length} chars");
        return true;
      } else {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        showBiometricModal.value = false;
        return false;
      }
    } catch (e) {
      isBiometricScanning.value = false;
      showBiometricModal.value = false;
      ConsoleLog.printError("❌ scanFingerprintFor2FA Error: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
      return false;
    }
  }

  /// Scan fingerprint for eKYC (Fingpay onboarding)
  /// Uses WADH_FOR_EKYC for eKYC authentication
  Future<bool> scanFingerprintForEkyc() async {
    if (selectedDevice.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a biometric device');
      return false;
    }

    isBiometricScanning.value = true;
    showBiometricModal.value = true;

    try {
      // ✅ REAL biometric call with eKYC WADH
      final result = await scanFingerprint(
        device: selectedDevice.value,
        forEkyc: true, // Uses WADH_FOR_EKYC
      );

      isBiometricScanning.value = false;

      if (result.success && result.pidData != null && result.pidData!.isNotEmpty) {
        lastPidData.value = result.pidData!;
        biometricSuccess.value = true;
        showBiometricModal.value = false;
        ConsoleLog.printSuccess("✅ eKYC Fingerprint captured: ${result.pidData!.length} chars");
        return true;
      } else {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        showBiometricModal.value = false;
        return false;
      }
    } catch (e) {
      isBiometricScanning.value = false;
      showBiometricModal.value = false;
      ConsoleLog.printError("❌ scanFingerprintForEkyc Error: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
      return false;
    }
  }

  /// Scan fingerprint for AEPS transaction
  Future<bool> scanFingerprintForTransaction() async {
    if (serviceSelectedDevice.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a biometric device');
      return false;
    }

    isBiometricScanning.value = true;
    showBiometricModal.value = true;

    try {
      // ✅ REAL biometric call for transaction
      final result = await scanFingerprint(
        device: serviceSelectedDevice.value,
        forEkyc: false, // Empty WADH for transactions
      );

      isBiometricScanning.value = false;

      if (result.success && result.pidData != null && result.pidData!.isNotEmpty) {
        lastPidData.value = result.pidData!;
        biometricSuccess.value = true;
        showBiometricModal.value = false;
        ConsoleLog.printSuccess("✅ Transaction Fingerprint captured: ${result.pidData!.length} chars");
        return true;
      } else {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        showBiometricModal.value = false;
        return false;
      }
    } catch (e) {
      isBiometricScanning.value = false;
      showBiometricModal.value = false;
      ConsoleLog.printError("❌ scanFingerprintForTransaction Error: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
      return false;
    }
  }

  // ============== FINGPAY API Methods ==============

    /// ✅ Initialize User Data from Profile API
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
    aadhaarController.text = aadhaar;
    mobileController.text = mobile;
    emailController.text = email;
    panController.text = pan;
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    shopNameController.text = shopName;
    stateController.text = state;
    cityController.text = city;
    pincodeController.text = pincode;
    shopAddressController.text = shopAddress;
    gstController.text = gstin;

    ConsoleLog.printSuccess("✅ User data initialized for AEPS");
    ConsoleLog.printInfo("   Aadhaar: ${aadhaar.isNotEmpty ? '****${aadhaar.substring(aadhaar.length - 4)}' : 'Not set'}");
    ConsoleLog.printInfo("   Mobile: ${mobile.isNotEmpty ? '****${mobile.substring(mobile.length - 4)}' : 'Not set'}");
  }

  /// Fingpay 2FA Process with biometric
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

      // First scan fingerprint
      bool scanSuccess = await scanFingerprintFor2FA();
      if (!scanSuccess) {
        isFingpay2FA_ProcessLoading.value = false;
        return;
      }

      // ✅ FIX: Encode PID Data to Base64 (consistent with Ionic App)
      // Ionic App sends: encdata: authData (where authData comes from fingerprint plugin)
      // Flutter 'pidData' is typically XML. We need to Base64 encode it.
      String encData = "";
      if (lastPidData.value.isNotEmpty) {
        encData = base64Encode(utf8.encode(lastPidData.value));
      }

      // Make API call
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,
        "skey": SKEY_TWO_FACTOR_AUTH,
        "encdata": encData,
        // "encdata": PidDataConverter.convertPidToEncdata(lastPidData.value ?? ''),
        // "encdata": base64Encode(utf8.encode(lastPidData.value ?? '')),  // Base64 encoded
        // "encdata": lastPidData.value,
      };

      print('📤 Fingpay 2FA Request: ${jsonEncode(body)}');

      // Uncomment to make actual API call
      // var response = await ApiProvider().requestPostForApi(
      //   WebApiConstant.API_URL_FINGPAY_2FA_PROCESS,
      //   body,
      //   userAuthToken.value,
      //   userSignature.value,
      // );

      // Simulated response
      await Future.delayed(Duration(seconds: 1));
      Map<String, dynamic> response = {
        'Resp_code': 'RCS',
        'Resp_desc': '2FA authentication successful',
      };

      isFingpay2FA_ProcessLoading.value = false;

      if (response['Resp_code'] == 'RCS') {
        isFingpay2FACompleted.value = true;
        canProceedToFingpayServices.value = true;
        showFingpay2FAForm.value = false;
        Fluttertoast.showToast(msg: '2FA authentication successful!');

        // Navigate to choose service screen
        // Get.to(() => AepsChooseServiceScreen(aepsType: 'AEPS1'));
      } else {
        Fluttertoast.showToast(msg: response['Resp_desc'] ?? 'Failed to complete 2FA');
      }
    } catch (e) {
      isFingpay2FA_ProcessLoading.value = false;
      print('❌ fingpayTwoFA_Process ERROR: $e');
      Fluttertoast.showToast(msg: 'Error during 2FA: $e');
    }
  }

  /// Fingpay eKYC Process with biometric
  Future<void> eKYCProcessFingpayOnboarding() async {
    try {
      isFingpay_e_KYC_OnboardingLoading.value = true;

      // First scan fingerprint with eKYC WADH
      bool scanSuccess = await scanFingerprintForEkyc();
      if (!scanSuccess) {
        isFingpay_e_KYC_OnboardingLoading.value = false;
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "req_type": "PROCESSEKYC",
        "aadhar": aadhaarController.text,
        "account_no": selectedMyBank.value?.accountNo ?? "",
        "ifsc": selectedMyBank.value?.ifsc ?? "",
        "bank_id": selectedMyBank.value?.aepsBankid ?? "",
        "otp_ref_data": {
          "primaryKeyId": otpReference.value?.primaryKeyId ?? "",
          "encodeFPTxnId": otpReference.value?.encodeFPTxnId ?? "",
        },
        "encdata": PidDataConverter.convertPidToEncdata(lastPidData.value ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(lastPidData.value ?? '')),  // Base64 encoded
        // "encdata": lastPidData.value,
      };

      print('📤 Fingpay eKYC Request: ${jsonEncode(body)}');

      // Make API call
      // var response = await ApiProvider().requestPostForApi(...)

      isFingpay_e_KYC_OnboardingLoading.value = false;

      // On success, proceed to 2FA
      showFingpayOnboardAuthForm.value = false;
      showFingpay2FAForm.value = true;
      Fluttertoast.showToast(msg: 'eKYC completed! Please complete 2FA.');

    } catch (e) {
      isFingpay_e_KYC_OnboardingLoading.value = false;
      print('❌ eKYCProcessFingpayOnboarding ERROR: $e');
    }
  }

  /// Fingpay Transaction with biometric
  Future<void> processFingpayTransaction() async {
    try {
      isFingpayTransactionLoading.value = true;

      // First scan fingerprint
      bool scanSuccess = await scanFingerprintForTransaction();
      if (!scanSuccess) {
        isFingpayTransactionLoading.value = false;
        return;
      }

      String amount = '0';
      if (selectedService.value == 'cashWithdrawal' || selectedService.value == 'aadhaarPay') {
        amount = serviceAmountController.text;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": serviceSelectedDevice.value,
        "bank_iin": selectedBankIin.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "amount": amount,
        "skey": getSkey(),
        "encdata": PidDataConverter.convertPidToEncdata(lastPidData.value ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(lastPidData.value ?? '')),  // Base64 encoded
        // "encdata": lastPidData.value,
      };

      print('📤 Fingpay Transaction Request: ${jsonEncode(body)}');

      // Make API call
      // var response = await ApiProvider().requestPostForApi(
      //   WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
      //   body,
      //   userAuthToken.value,
      //   userSignature.value,
      // );

      // Simulated response
      await Future.delayed(Duration(seconds: 2));

      isFingpayTransactionLoading.value = false;

      // Handle response and show result
      transactionResult.value = AepsTransactionData(
        txnStatus: 'SUCCESS',
        txnDesc: 'Transaction completed successfully',
        balance: '25000.00',
        txnId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );
      showResultModal.value = true;

    } catch (e) {
      isFingpayTransactionLoading.value = false;
      print('❌ processFingpayTransaction ERROR: $e');
      Fluttertoast.showToast(msg: 'Transaction failed: $e');
    }
  }

  // ============== INSTANTPAY API Methods ==============

  /// Instantpay 2FA Process with biometric
  Future<void> instantpayTwoFA_Process() async {
    try {
      isInstantpay2FA_ProcessLoading.value = true;

      // First scan fingerprint
      bool scanSuccess = await scanFingerprintFor2FA();
      if (!scanSuccess) {
        isInstantpay2FA_ProcessLoading.value = false;
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,
        "skey": SKEY_TWO_FACTOR_AUTH,
        "encdata": PidDataConverter.convertPidToEncdata(lastPidData.value ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(lastPidData.value ?? '')),  // Base64 encoded
        // "encdata": lastPidData.value,
      };

      print('📤 Instantpay 2FA Request: ${jsonEncode(body)}');

      // Make API call
      // var response = await ApiProvider().requestPostForApi(
      //   WebApiConstant.API_URL_INSTANTPAY_2FA_PROCESS,
      //   body,
      //   userAuthToken.value,
      //   userSignature.value,
      // );

      await Future.delayed(Duration(seconds: 1));

      isInstantpay2FA_ProcessLoading.value = false;

      // On success
      isInstantpay2FACompleted.value = true;
      canProceedToInstantpayServices.value = true;
      showInstantpay2FAForm.value = false;
      Fluttertoast.showToast(msg: '2FA authentication successful!');

    } catch (e) {
      isInstantpay2FA_ProcessLoading.value = false;
      print('❌ instantpayTwoFA_Process ERROR: $e');
    }
  }

  /// ✅ Register Fingpay Onboarding - Step 1
  Future<void> registerFingpayOnboarding() async {
    try {
      isFingpayRegisterOnboardingLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        isFingpayRegisterOnboardingLoading.value = false;
        Fluttertoast.showToast(msg: "No Internet Connection!");
        return;
      }

      // Auth credentials check
      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        await loadAuthCredentials();
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        isFingpayRegisterOnboardingLoading.value = false;
        Fluttertoast.showToast(msg: "Authentication required!");
        return;
      }

      // Validate required fields
      if (selectedMyBank.value == null) {
        isFingpayRegisterOnboardingLoading.value = false;
        Fluttertoast.showToast(msg: "Please select a bank");
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "REGISTERUSER",
        "bank_id": selectedMyBank.value?.aepsBankid ?? "",
        "aadhar": aadhaarController.text,
        "gstin": gstController.text,
      };

      ConsoleLog.printColor("📤 registerFingpayOnboarding Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isFingpayRegisterOnboardingLoading.value = false;

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("📥 registerFingpayOnboarding Response: ${jsonEncode(response.data)}", color: "green");

        var data = response.data;
        String respCode = data['Resp_code'] ?? '';
        String respDesc = data['Resp_desc'] ?? '';

        if (respCode == 'RCS') {
          // OTP Sent successfully - save reference data
          otpReference.value = AepsOnboardingData(
            primaryKeyId: data['data']?['primaryKeyId']?.toString(),
            encodeFPTxnId: data['data']?['encodeFPTxnId']?.toString(),
          );

          showFingpayOtpModal.value = true;
          Fluttertoast.showToast(msg: "OTP sent successfully!");
          ConsoleLog.printSuccess("✅ OTP sent - primaryKeyId: ${otpReference.value?.primaryKeyId}");

        } else if (respCode == 'RLD') {
          // Already registered - go to 2FA
          showFingpayOnboardingForm.value = false;
          showFingpay2FAForm.value = true;
          Fluttertoast.showToast(msg: "Already registered. Please complete 2FA.");
          ConsoleLog.printWarning("⚠️ User already registered, redirecting to 2FA");

        } else if (respCode == 'RCF') {
          Fluttertoast.showToast(msg: respDesc.isNotEmpty ? respDesc : "Registration failed");
          ConsoleLog.printError("❌ Registration failed: $respDesc");

        } else {
          Fluttertoast.showToast(msg: respDesc.isNotEmpty ? respDesc : "Unknown error");
        }
      } else {
        ConsoleLog.printError("❌ API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Registration failed. Please try again.");
      }
    } catch (e) {
      isFingpayRegisterOnboardingLoading.value = false;
      ConsoleLog.printError("❌ registerFingpayOnboarding ERROR: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  /// ✅ Verify Fingpay Onboarding OTP - Step 2
  Future<void> verifyFingpayOnboardingOTP() async {
    try {
      isFingpayVerifyOnboardingOTPLoading.value = true;

      if (otpController.text.length != 6) {
        Fluttertoast.showToast(msg: "Please enter valid 6-digit OTP");
        isFingpayVerifyOnboardingOTPLoading.value = false;
        return;
      }

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
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "VERIFYONBOARDOTP",
        "otp": otpController.text,
        "otp_ref_data": {
          "primaryKeyId": otpReference.value?.primaryKeyId ?? "",
          "encodeFPTxnId": otpReference.value?.encodeFPTxnId ?? "",
        },
      };

      ConsoleLog.printColor("📤 verifyFingpayOnboardingOTP Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isFingpayVerifyOnboardingOTPLoading.value = false;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        String respCode = data['Resp_code'] ?? '';

        if (respCode == 'RCS') {
          // OTP verified - move to eKYC
          showFingpayOtpModal.value = false;
          showFingpayOnboardingForm.value = false;
          showFingpayOnboardAuthForm.value = true;
          otpController.clear();
          Fluttertoast.showToast(msg: "OTP verified! Complete eKYC.");
          ConsoleLog.printSuccess("✅ OTP verified successfully");
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? "OTP verification failed");
          ConsoleLog.printError("❌ OTP verification failed: ${data['Resp_desc']}");
        }
      }
    } catch (e) {
      isFingpayVerifyOnboardingOTPLoading.value = false;
      ConsoleLog.printError("❌ verifyFingpayOnboardingOTP ERROR: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  /// ✅ Resend Fingpay Onboarding OTP
  Future<void> resendFingpayOnboardingOTP() async {
    try {
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
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "RESENDOTP",
        "otp_ref_data": {
          "primaryKeyId": otpReference.value?.primaryKeyId ?? "",
          "encodeFPTxnId": otpReference.value?.encodeFPTxnId ?? "",
        },
      };

      ConsoleLog.printColor("📤 resendFingpayOnboardingOTP Request", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          Fluttertoast.showToast(msg: "OTP resent successfully!");
          ConsoleLog.printSuccess("✅ OTP resent");
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? "Failed to resend OTP");
        }
      }
    } catch (e) {
      ConsoleLog.printError("❌ resendFingpayOnboardingOTP ERROR: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  /// Instantpay Transaction with biometric
  Future<void> processInstantpayTransaction() async {
    try {
      isInstantpayTransactionLoading.value = true;

      // First get confirmation (no biometric yet)
      String amount = '0';
      if (selectedService.value == 'cashWithdrawal') {
        amount = serviceAmountController.text;
      }

      Map<String, dynamic> confirmBody = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value,
        "long": homeScreenController.longitude.value,
        "device": serviceSelectedDevice.value,
        "bank_iin": selectedBankIin.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "skey": getSkey(),
        "amount": amount,
        "request_type": "CONFIRM AEPS TXN REQUEST",
      };

      print('📤 Instantpay Confirm Request: ${jsonEncode(confirmBody)}');

      // Make confirmation API call
      // var confirmResponse = await ApiProvider().requestPostForApi(...)

      // Show confirmation modal
      confirmationData.value = AepsConfirmData(
        commission: '2.50',
        totalCharge: '5.00',
        chargedAmt: amount,
        tds: "",
        txnPin: ""
      );
      showConfirmationModal.value = true;

    } catch (e) {
      isInstantpayTransactionLoading.value = false;
      print('❌ processInstantpayTransaction ERROR: $e');
    }
  }

  /// Complete Instantpay transaction after confirmation
  // Future<void> confirmInstantpayTransaction() async {
  //   try {
  //     showConfirmationModal.value = false;
  //     isInstantpayTransactionLoading.value = true;
  //
  //     // Scan fingerprint
  //     bool scanSuccess = await scanFingerprintForTransaction();
  //     if (!scanSuccess) {
  //       isInstantpayTransactionLoading.value = false;
  //       return;
  //     }
  //
  //     String amount = '0';
  //     if (selectedService.value == 'cashWithdrawal') {
  //       amount = serviceAmountController.text;
  //     }
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": "26.912434",
  //       "long": "75.787270",
  //       "device": serviceSelectedDevice.value,
  //       "bank_iin": selectedBankIin.value,
  //       "aadhar_no": serviceAadhaarController.text,
  //       "mobile_no": serviceMobileController.text,
  //       "skey": getSkey(),
  //       "amount": amount,
  //       "request_type": "PROCESS AEPS TXN REQUEST",
  //       "encdata": lastPidData.value,
  //     };
  //
  //     print('📤 Instantpay Transaction Request: ${jsonEncode(body)}');
  //
  //     // Make API call
  //     // var response = await ApiProvider().requestPostForApi(
  //     //   WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
  //     //   body,
  //     //   userAuthToken.value,
  //     //   userSignature.value,
  //     // );
  //
  //     await Future.delayed(Duration(seconds: 2));
  //
  //     isInstantpayTransactionLoading.value = false;
  //
  //     // Show result
  //     transactionResult.value = AepsTransactionData(
  //       txnStatus: 'SUCCESS',
  //       txnDesc: 'Transaction completed successfully',
  //       balance: '18500.00',
  //       txnId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
  //     );
  //     showResultModal.value = true;
  //
  //   } catch (e) {
  //     isInstantpayTransactionLoading.value = false;
  //     print('❌ confirmInstantpayTransaction ERROR: $e');
  //   }
  // }


  /// ✅ FIX 9: Complete Fingpay 2FA with Biometric
  Future<bool> completeFingpay2FAWithBiometric() async {
    try {
      isFingpay2FA_ProcessLoading.value = true;

      // Validate device selection
      if (selectedDevice.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a biometric device');
        isFingpay2FA_ProcessLoading.value = false;
        return false;
      }

      // ✅ FIX: Use aadhaarController.text instead of aadhaarController.value.text
      if (aadhaarController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter Aadhaar number');
        isFingpay2FA_ProcessLoading.value = false;
        return false;
      }

      // Scan fingerprint (empty WADH for 2FA)
      final result = await scanFingerprint(
        device: selectedDevice.value,
        forEkyc: false,
      );

      if (!result.success) {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        isFingpay2FA_ProcessLoading.value = false;
        return false;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }
      // ✅ FIX: Encode PID Data to Base64 (consistent with Ionic App)
      // Ionic App sends: encdata: authData (where authData comes from fingerprint plugin)
      // Flutter 'pidData' is typically XML. We need to Base64 encode it.
      String encData = "";
      if (lastPidData.value.isNotEmpty) {
        encData = base64Encode(utf8.encode(lastPidData.value));
      }

      // String encData = PidDataConverter.convertPidToEncdata(lastPidData.value); //*****

      // // Result se encdata generate karein
      // String finalEncData = PidDataConverter.convertPidToEncdata(result.pidData ?? '');
      // Make 2FA API call
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,  // ✅ FIXED
        "skey": "TWOFACTORAUTH",
        "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),
        // "encdata": encData,
        // "encdata": finalEncData,
        // "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(result.pidData ?? '')),  // Base64 encoded
        // "encdata": result.pidData,
      };

      ConsoleLog.printColor("Fingpay 2FA Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_2FA_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );


      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("Fingpay 2FA Response: ${jsonEncode(response.data)}");
        isFingpay2FA_ProcessLoading.value = false;

        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          isFingpay2FACompleted.value = true;
          canProceedToFingpayServices.value = true;
          showFingpay2FAForm.value = false;
          Fluttertoast.showToast(msg: '2FA completed successfully!');
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? '2FA failed');
          return false;
        }
      }else {
        isFingpay2FA_ProcessLoading.value = false;
        ConsoleLog.printError("fingpayTwoFA_Process API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
        return false;
      }

      Fluttertoast.showToast(msg: 'API Error');
      return false;

    } catch (e) {
      isFingpay2FA_ProcessLoading.value = false;
      ConsoleLog.printError("Fingpay 2FA Error: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
      return false;
    }
  }

  /// ✅ FIX 10: Complete Instantpay 2FA with Biometric
  Future<bool> completeInstantpay2FAWithBiometric() async {
    try {
      isInstantpay2FA_ProcessLoading.value = true;

      if (selectedDevice.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a biometric device');
        isInstantpay2FA_ProcessLoading.value = false;
        return false;
      }

      // ✅ FIX: Use aadhaarController.text
      if (aadhaarController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter Aadhaar number');
        isInstantpay2FA_ProcessLoading.value = false;
        return false;
      }

      final result = await scanFingerprint(
        device: selectedDevice.value,
        forEkyc: false,
      );

      if (!result.success) {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Scan failed');
        isInstantpay2FA_ProcessLoading.value = false;
        return false;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }
      // String finalEncData = PidDataConverter.convertPidToEncdata(result.pidData ?? '');
      // ✅ FIX: Encode PID Data to Base64
      String encData = "";
      if (result.pidData!.isNotEmpty) {
        encData = base64Encode(utf8.encode(result.pidData!));
      }//UIDAI_ERROR810 Missing biometric data as specified in Uses

      // ✅ FIX: Use PidDataConverter
      // String encData = PidDataConverter.convertPidToEncdata(lastPidData.value); //add_info data missing

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,  // ✅ FIXED
        "skey": "TWOFACTORAUTH",
        "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),
        // "encdata": encData, //UIDAI_ERROR810 Missing biometric data as specified in Uses
        // "encdata": finalEncData,
        // "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(lastPidData.value ?? '')),  //UIDAI_ERROR810 Missing biometric data as specified in Uses
        // "encdata": result.pidData,
      };

      ConsoleLog.printColor("Instantpay 2FA Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INSTANTPAY_2FA_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );


      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("instantpayTwoFA_Process Response: ${jsonEncode(response.data)}");
        isInstantpay2FA_ProcessLoading.value = false;

        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          isInstantpay2FACompleted.value = true;
          canProceedToInstantpayServices.value = true;
          showInstantpay2FAForm.value = false;
          Fluttertoast.showToast(msg: '2FA completed!');
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? '2FA failed');
          return false;
        }
      }else {
        isInstantpay2FA_ProcessLoading.value = false;
        ConsoleLog.printError("instantpayTwoFA_Process API Error: ${response?.statusCode}");
        Fluttertoast.showToast(msg: "Failed to send 2FA Request.");
        return false;
      }

      return false;

    } catch (e) {
      isInstantpay2FA_ProcessLoading.value = false;
      ConsoleLog.printError("Instantpay 2FA Error: $e");
      return false;
    }
  }

  /// ✅ FIX 11: Complete Fingpay eKYC with Biometric
  Future<bool> completeFingpayEkycWithBiometric() async {
    try {
      isFingpay_e_KYC_OnboardingLoading.value = true;

      if (selectedDevice.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select device');
        isFingpay_e_KYC_OnboardingLoading.value = false;
        return false;
      }

      // Scan with eKYC WADH
      final result = await scanFingerprint(
        device: selectedDevice.value,
        forEkyc: true, // Uses WADH_FOR_EKYC
      );

      if (!result.success) {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Scan failed');
        isFingpay_e_KYC_OnboardingLoading.value = false;
        return false;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "PROCESSEKYC",
        "aadhar": aadhaarController.text,  // ✅ FIXED
        "account_no": selectedMyBank.value?.accountNo ?? "",
        "ifsc": selectedMyBank.value?.ifsc ?? "",
        "bank_id": selectedMyBank.value?.aepsBankid ?? "",
        "otp_ref_data": {
          "primaryKeyId": otpReference.value?.primaryKeyId ?? "",
          "encodeFPTxnId": otpReference.value?.encodeFPTxnId ?? "",
        },
        "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(result.pidData ?? '')),  // Base64 encoded
        // "encdata": result.pidData,
      };

      ConsoleLog.printColor("Fingpay eKYC Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_AEPS_PROCESS_ONBOARDING,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isFingpay_e_KYC_OnboardingLoading.value = false;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          showFingpayOnboardAuthForm.value = false;
          showFingpay2FAForm.value = true;
          Fluttertoast.showToast(msg: 'eKYC completed! Complete 2FA now.');
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? 'eKYC failed');
          return false;
        }
      }

      return false;

    } catch (e) {
      isFingpay_e_KYC_OnboardingLoading.value = false;
      ConsoleLog.printError("Fingpay eKYC Error: $e");
      return false;
    }
  }

  // ============== AEPS Choose Service Methods ==============

  /// ✅ Fetch AEPS Bank List
  Future<void> fetchAepsBankList() async {
    try {
      isGetAepsBanklistLoading.value = true;

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
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
      };

      ConsoleLog.printColor("📤 fetchAepsBankList Request", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_AEPS_BANK_LIST,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isGetAepsBanklistLoading.value = false;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          // Parse bank list
          List<dynamic> bankData = data['data'];
          allBankList.clear();

          for (var bank in bankData) {
            allBankList.add(AepsBank(
              id: bank['id']?.toString() ?? '',
              bankName: bank['bank_name'] ?? '',
              bankIin: bank['bank_iin'] ?? '',
              isFav: bank['is_fav'] ?? '0',
            ));
          }

          // Initialize filtered list
          filteredBankList.assignAll(allBankList);

          // Set favorites
          favoritesList.assignAll(allBankList.where((b) => b.isFav == '1'));

          ConsoleLog.printSuccess("✅ Bank list loaded: ${allBankList.length} banks");
        }
      }
    } catch (e) {
      isGetAepsBanklistLoading.value = false;
      ConsoleLog.printError("❌ fetchAepsBankList Error: $e");
    }
  }

  /// ✅ Filter AEPS Bank List
  void filterAepsBankList(String query) {
    if (query.isEmpty) {
      filteredBankList.assignAll(allBankList);
    } else {
      filteredBankList.assignAll(
        allBankList.where((bank) =>
        bank.bankName!.toLowerCase().contains(query.toLowerCase()) ||
            bank.bankIin!.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }

  /// ✅ Fetch Recent Transactions
  Future<void> fetchRecentTransactions(String serviceType) async {
    try {
      isGetRecentTransactionsLoading.value = true;

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
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "service_type": serviceType,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_RECENT_TXN_DATA,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isGetRecentTransactionsLoading.value = false;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          List<dynamic> txnData = data['data'];
          recentTransactions.clear();

          for (var txn in txnData) {
            recentTransactions.add(RecentTransaction(
              requestDt: txn['request_dt'],
              recordType: txn['record_type'],
              txnAmt: txn['txn_amt']?.toString(),
              portalStatus: txn['portal_status'],
              portalTxnId: txn['portal_txn_id'],
            ));
          }

          ConsoleLog.printSuccess("✅ Recent transactions loaded: ${recentTransactions.length}");
        }
      }
    } catch (e) {
      isGetRecentTransactionsLoading.value = false;
      ConsoleLog.printError("❌ fetchRecentTransactions Error: $e");
    }
  }

  /// ✅ Mark Favorite Bank
  Future<void> markFavoriteBank({
    required String bankId,
    required String action,
  }) async {
    try {
      isMarkFavoriteBankLoading.value = true;

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
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "bank_id": bankId,
        "action": action,
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_MARK_FAV_BANK,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isMarkFavoriteBankLoading.value = false;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          // Update local list
          final index = allBankList.indexWhere((b) => b.id == bankId);
          if (index != -1) {
            allBankList[index] = AepsBank(
              id: allBankList[index].id,
              bankName: allBankList[index].bankName,
              bankIin: allBankList[index].bankIin,
              isFav: action == 'ADD' ? '1' : '0',
            );
            filteredBankList.assignAll(allBankList);
          }
          ConsoleLog.printSuccess("✅ Bank favorite updated");
        }
      }
    } catch (e) {
      isMarkFavoriteBankLoading.value = false;
      ConsoleLog.printError("❌ markFavoriteBank Error: $e");
    }
  }

  /// ✅ Confirm Instantpay Transaction (Step 1 - Get Charges)
  Future<bool> confirmInstantpayTransaction({required String skey}) async {
    try {
      isInstantpayTransactionLoading.value = true;

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "CONFIRM AEPS TXN REQUEST",
        "skey": skey,
        "bank_iin": selectedBankIin.value,
        "bank_id": selectedBankId.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "txn_amt": serviceAmountController.text.isEmpty ? "0" : serviceAmountController.text,
      };

      ConsoleLog.printColor("📤 confirmInstantpayTransaction Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isInstantpayTransactionLoading.value = false;

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("📥 confirmInstantpayTransaction Response: ${jsonEncode(response.data)}", color: "green");

        var data = response.data;
        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          confirmationData.value = AepsConfirmData(
            commission: data['data']['commission']?.toString() ?? '0',
            tds: data['data']['tds']?.toString() ?? '0',
            totalCharge: data['data']['totalcharge']?.toString() ?? '0',
            chargedAmt: data['data']['chargedamt']?.toString() ?? '0',
            txnPin: data['data']['txnpin']?.toString() ?? '0',
          );
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? 'Confirmation failed');
          return false;
        }
      }
      return false;
    } catch (e) {
      isInstantpayTransactionLoading.value = false;
      ConsoleLog.printError("❌ confirmInstantpayTransaction Error: $e");
      return false;
    }
  }

  /// ✅ Process Instantpay Transaction with Biometric (Step 2)
  Future<bool> processInstantpayTransactionWithBiometric({required String skey}) async {
    try {
      isInstantpayTransactionLoading.value = true;

      // Validate device
      if (serviceSelectedDevice.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a biometric device');
        isInstantpayTransactionLoading.value = false;
        return false;
      }

      // Scan fingerprint
      final result = await scanFingerprint(
        device: serviceSelectedDevice.value,
        forEkyc: false,
      );

      if (!result.success) {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        isInstantpayTransactionLoading.value = false;
        return false;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "req_type": "PROCESS AEPS TXN REQUEST",
        "skey": skey,
        "bank_iin": selectedBankIin.value,
        "bank_id": selectedBankId.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "txn_amt": serviceAmountController.text.isEmpty ? "0" : serviceAmountController.text,
        "device": serviceSelectedDevice.value,
        "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(result.pidData ?? '')),  // Base64 encoded
        // "encdata": result.pidData,
      };

      ConsoleLog.printColor("📤 processInstantpayTransaction Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_AEPS_START_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isInstantpayTransactionLoading.value = false;

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("📥 processInstantpayTransaction Response: ${jsonEncode(response.data)}", color: "green");

        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          transactionResult.value = AepsTransactionData(
            txnStatus: data['data']?['txn_status'] ?? 'Success',
            txnDesc: data['data']?['txn_desc'] ?? 'Transaction completed',
            balance: data['data']?['balance']?.toString(),
            txnId: data['data']?['txnid']?.toString(),
            opId: data['data']?['opid']?.toString(),
          );
          Fluttertoast.showToast(msg: 'Transaction successful!');
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? 'Transaction failed');
          return false;
        }
      }
      return false;
    } catch (e) {
      isInstantpayTransactionLoading.value = false;
      ConsoleLog.printError("❌ processInstantpayTransaction Error: $e");
      return false;
    }
  }

  /// ✅ Process Fingpay Transaction with Biometric (Direct)
  Future<bool> processFingpayTransactionWithBiometric({required String skey}) async {
    try {
      isFingpayTransactionLoading.value = true;

      // Validate device
      if (serviceSelectedDevice.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a biometric device');
        isFingpayTransactionLoading.value = false;
        return false;
      }

      // Scan fingerprint
      final result = await scanFingerprint(
        device: serviceSelectedDevice.value,
        forEkyc: false,
      );

      if (!result.success) {
        Fluttertoast.showToast(msg: result.errorMessage ?? 'Fingerprint scan failed');
        isFingpayTransactionLoading.value = false;
        return false;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return false;
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
        return false;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": homeScreenController.latitude.value.toString(),
        "long": homeScreenController.longitude.value.toString(),
        "skey": skey,
        "bank_iin": selectedBankIin.value,
        "bank_id": selectedBankId.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "txn_amt": serviceAmountController.text.isEmpty ? "0" : serviceAmountController.text,
        "device": serviceSelectedDevice.value,
        "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
        // "encdata": base64Encode(utf8.encode(result.pidData ?? '')),  // Base64 encoded
        // "encdata": result.pidData,
      };

      ConsoleLog.printColor("📤 processFingpayTransaction Request: ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_FINGPAY_TRANSACTION_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      isFingpayTransactionLoading.value = false;

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("📥 processFingpayTransaction Response: ${jsonEncode(response.data)}", color: "green");

        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          transactionResult.value = AepsTransactionData(
            txnStatus: data['data']?['txn_status'] ?? 'Success',
            txnDesc: data['data']?['txn_desc'] ?? 'Transaction completed',
            balance: data['data']?['balance']?.toString(),
            txnId: data['data']?['txnid']?.toString(),
            opId: data['data']?['opid']?.toString(),
          );
          Fluttertoast.showToast(msg: 'Transaction successful!');
          return true;
        } else {
          Fluttertoast.showToast(msg: data['Resp_desc'] ?? 'Transaction failed');
          return false;
        }
      }
      return false;
    } catch (e) {
      isFingpayTransactionLoading.value = false;
      ConsoleLog.printError("❌ processFingpayTransaction Error: $e");
      return false;
    }
  }

  // ============== Status Helpers ==============

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

// ============== Model Classes ==============

// ============== ADD THIS CLASS AT BOTTOM OF FILE ==============

/// Biometric scan result model
class BiometricResult {
  final bool success;
  final String? pidData;
  final String? device;
  final String? errorCode;
  final String? errorMessage;

  BiometricResult({
    required this.success,
    this.pidData,
    this.device,
    this.errorCode,
    this.errorMessage,
  });

  @override
  String toString() {
    if (success) {
      return 'BiometricResult(success: true, pidLength: ${pidData?.length ?? 0})';
    } else {
      return 'BiometricResult(success: false, error: $errorCode - $errorMessage)';
    }
  }
}


class BiometricResultMock {
  final bool success;
  final String? pidData;
  final String? errorMessage;

  BiometricResultMock({required this.success, this.pidData, this.errorMessage});
}

// AEPS Bank Model
class AepsBank {
  final String id;
  final String bankName;
  final String bankIin;
  final String isFav;

  AepsBank({
    required this.id,
    required this.bankName,
    required this.bankIin,
    required this.isFav,
  });
}


class MyBankAccount {
  final String? id;
  final String? accountNo;
  final String? ifsc;
  final String? aepsBankid;
  final String? bankName;

  MyBankAccount({this.id, this.accountNo, this.ifsc, this.aepsBankid, this.bankName});

  factory MyBankAccount.fromJson(Map<String, dynamic> json) {
    return MyBankAccount(
      id: json['id']?.toString(),
      accountNo: json['account_no'],
      ifsc: json['ifsc'],
      aepsBankid: json['aeps_bankid'],
      bankName: json['bank_name'],
    );
  }
}

/// AEPS Confirmation Data Model
class AepsConfirmData {
  final String commission;
  final String tds;
  final String totalCharge;
  final String chargedAmt;
  final String txnPin;

  AepsConfirmData({
    required this.commission,
    required this.tds,
    required this.totalCharge,
    required this.chargedAmt,
    required this.txnPin,
  });
}


/// AEPS Transaction Data Model
class AepsTransactionData {
  final String txnStatus;
  final String txnDesc;
  final String? balance;
  final String? txnId;
  final String? opId;

  AepsTransactionData({
    required this.txnStatus,
    required this.txnDesc,
    this.balance,
    this.txnId,
    this.opId,
  });
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

/// AEPS Onboarding Data Model
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
}


/// Recent Transaction Model
class RecentTransaction {
  final String? requestDt;
  final String? recordType;
  final String? txnAmt;
  final String? portalStatus;
  final String? portalTxnId;

  RecentTransaction({
    this.requestDt,
    this.recordType,
    this.txnAmt,
    this.portalStatus,
    this.portalTxnId,
  });
}
