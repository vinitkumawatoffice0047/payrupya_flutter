import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// Add these imports based on your project structure
// import '../api/api_provider.dart';
// import '../api/web_api_constant.dart';
// import '../utils/app_shared_preferences.dart';
// import '../utils/ConsoleLog.dart';
// import '../utils/custom_loading.dart';
// import '../utils/global_utils.dart';
// import '../controllers/login_controller.dart';
// import 'aeps_controller.dart';
// import '../models/aeps_response_models.dart';

/// AEPS API Service - Contains all API methods for AEPS functionality
/// This extends the base AepsController to add API functionality
mixin AepsApiService {
  
  // ============== API URLs ==============
  // Add these to your WebApiConstant class:
  
  static const String API_URL_CHECK_ONBOARD_STATUS = "Fetch/checkUserOnboardStatus";
  static const String API_URL_CHECK_FINGPAY_ONBOARD_STATUS = "Fetch/checkFingpayUserOnboardStatus";
  static const String API_URL_CHECK_BIO_AUTH_STATUS = "Fetch/checkBioAuthStatus";
  static const String API_URL_CHECK_FINGPAY_AUTH_STATUS = "Fetch/checkFingpayAuthStatus";
  
  static const String API_URL_INSTANTPAY_ONBOARDING = "Action/instantpayAepsProcessOnboarding";
  static const String API_URL_FINGPAY_ONBOARDING = "Action/fingpayAepsProcessOnboarding";
  
  static const String API_URL_START_2FA_PROCESS = "Action/start_2faauth_process";
  static const String API_URL_FINGPAY_2FA_PROCESS = "Action/fingpayTwofaProcess";
  
  static const String API_URL_GET_AEPS_BANK_LIST = "Fetch/getAepsBanklist";
  static const String API_URL_GET_MY_BANK_LIST = "Fetch/getAllMyBankList";
  
  static const String API_URL_AEPS_TRANSACTION_PROCESS = "Action/aepsStartTransactionProcess";
  static const String API_URL_FINGPAY_TRANSACTION_PROCESS = "Action/fingpayTransactionProcess";
  
  static const String API_URL_MARK_FAV_BANK = "Action/markFavBank";
  static const String API_URL_GET_RECENT_TXN = "Fetch/getRecentTxnData";
}

/// Complete AEPS Controller with API methods
/// Use this class in your Flutter app
class AepsControllerFull extends GetxController with AepsApiService {
  
  // ============== State Variables ==============
  
  // Loading states
  RxBool isLoading = false.obs;
  RxBool isOnboardingLoading = false.obs;
  RxBool isTransactionLoading = false.obs;

  // Onboarding states
  RxBool isOnboarded = false.obs;
  RxBool isTwoFactorAuthenticated = false.obs;
  RxBool showOnboardingForm = false.obs;
  RxBool showAuthenticationForm = false.obs;
  RxBool showOtpModal = false.obs;
  RxBool showOnboardAuthForm = false.obs;

  // Service Selection
  RxString selectedService = 'balanceCheck'.obs;
  RxBool showAmountInput = false.obs;

  // Bank related
  RxList<Map<String, dynamic>> allBankList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> favoritesList = <Map<String, dynamic>>[].obs;
  RxString selectedBankName = ''.obs;
  RxString selectedBankId = ''.obs;
  RxString selectedBankIin = ''.obs;

  // My Bank List (for Fingpay)
  RxList<Map<String, dynamic>> myBankList = <Map<String, dynamic>>[].obs;
  Rx<Map<String, dynamic>?> selectedMyBank = Rx<Map<String, dynamic>?>(null);

  // Transaction data
  Rx<Map<String, dynamic>?> confirmationData = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> transactionResult = Rx<Map<String, dynamic>?>(null);
  RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;

  // OTP Reference data
  Rx<Map<String, dynamic>?> otpReference = Rx<Map<String, dynamic>?>(null);

  // Modal states
  RxBool showConfirmationModal = false.obs;
  RxBool showResultModal = false.obs;

  // AEPS Type - 'fingpay' or 'instantpay'
  RxString aepsType = 'instantpay'.obs;

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
  final aadhaarController = TextEditingController();
  final mobileController = TextEditingController();
  RxString selectedDevice = ''.obs;

  // Onboarding Form (Common)
  final emailController = TextEditingController();
  final panController = TextEditingController();
  final bankAccountController = TextEditingController();
  final ifscController = TextEditingController();

  // Onboarding Form (Fingpay additional)
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final shopNameController = TextEditingController();
  final gstController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final shopAddressController = TextEditingController();

  // OTP Controller
  final otpController = TextEditingController();

  // Service Form
  final serviceAadhaarController = TextEditingController();
  final serviceMobileController = TextEditingController();
  final serviceAmountController = TextEditingController();
  RxString serviceSelectedDevice = ''.obs;

  // Transaction PIN
  final txnPinController = TextEditingController();

  // ============== Dependencies ==============
  // These should be your existing services
  // final ApiProvider _apiProvider = Get.find<ApiProvider>();
  // final LoginController _loginController = Get.find<LoginController>();

  // For demo, using placeholder values
  String get authToken => ''; // Get from AppSharedPreferences
  String get signature => ''; // Get from AppSharedPreferences  
  String get latitude => '26.912434'; // Get from LoginController
  String get longitude => '75.787270'; // Get from LoginController

  // ============== API Methods ==============

  /// Generate random request ID
  String generateRequestId(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(DateTime.now().microsecond % chars.length))
    );
  }

  /// Check Onboard Status for Instantpay (AEPS Three)
  Future<Map<String, dynamic>?> checkOnboardStatus() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
      };

      // Make API call using your existing API provider
      // Response? response = await _apiProvider.requestPostForApi(
      //   WebApiConstant.BASE_URL + AepsApiService.API_URL_CHECK_ONBOARD_STATUS,
      //   body,
      //   authToken,
      //   signature,
      // );

      // For now, return mock response structure
      // Replace with actual API call
      print('Check Onboard Status Request: $body');
      
      isLoading.value = false;
      return null; // Return actual response
      
    } catch (e) {
      isLoading.value = false;
      print('Check Onboard Status Error: $e');
      return null;
    }
  }

  /// Check Onboard Status for Fingpay (AEPS One)
  Future<Map<String, dynamic>?> checkFingpayOnboardStatus() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
      };

      print('Check Fingpay Onboard Status Request: $body');
      
      isLoading.value = false;
      return null;
      
    } catch (e) {
      isLoading.value = false;
      print('Check Fingpay Onboard Status Error: $e');
      return null;
    }
  }

  /// Instantpay Onboarding Process
  Future<Map<String, dynamic>?> instantpayOnboarding({
    required String reqType, // 'CHECKUSER' or 'REGISTERUSER'
    String? otp,
  }) async {
    try {
      isOnboardingLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "mobile_no": mobileController.text,
        "email": emailController.text,
        "aadhar_no": aadhaarController.text,
        "pan_no": panController.text,
        "account_no": bankAccountController.text,
        "ifsc": ifscController.text,
        "req_type": reqType,
      };

      if (reqType == 'REGISTERUSER' && otp != null && otpReference.value != null) {
        body["otp"] = otp;
        body["otp_ref_data"] = {
          "aadhaar": otpReference.value!['aadhaar'],
          "otpReferenceID": otpReference.value!['otpReferenceID'],
          "hash": otpReference.value!['hash'],
        };
      }

      print('Instantpay Onboarding Request: $body');
      
      isOnboardingLoading.value = false;
      return null;
      
    } catch (e) {
      isOnboardingLoading.value = false;
      print('Instantpay Onboarding Error: $e');
      return null;
    }
  }

  /// Fingpay Onboarding Process
  Future<Map<String, dynamic>?> fingpayOnboarding({
    required String reqType, // 'REGISTERUSER', 'VERIFYONBOARDOTP', 'PROCESSEKYC', 'RESENDOTP'
    String? otp,
    String? encdata,
  }) async {
    try {
      isOnboardingLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "req_type": reqType,
      };

      if (reqType == 'REGISTERUSER') {
        body["bank_id"] = selectedMyBank.value?['aeps_bankid'];
        body["aadhar"] = aadhaarController.text;
        body["gstin"] = gstController.text;
      }

      if (reqType == 'VERIFYONBOARDOTP' && otp != null && otpReference.value != null) {
        body["otp"] = otp;
        body["otp_ref_data"] = {
          "primaryKeyId": otpReference.value!['primaryKeyId'],
          "encodeFPTxnId": otpReference.value!['encodeFPTxnId'],
        };
      }

      if (reqType == 'PROCESSEKYC' && encdata != null && otpReference.value != null) {
        body["aadhar"] = aadhaarController.text;
        body["account_no"] = selectedMyBank.value?['account_no'];
        body["ifsc"] = selectedMyBank.value?['ifsc'];
        body["bank_id"] = selectedMyBank.value?['aeps_bankid'];
        body["encdata"] = encdata;
        body["otp_ref_data"] = {
          "primaryKeyId": otpReference.value!['primaryKeyId'],
          "encodeFPTxnId": otpReference.value!['encodeFPTxnId'],
        };
      }

      if (reqType == 'RESENDOTP' && otpReference.value != null) {
        body["primaryKeyId"] = otpReference.value!['primaryKeyId'];
        body["encodeFPTxnId"] = otpReference.value!['encodeFPTxnId'];
      }

      print('Fingpay Onboarding Request: $body');
      
      isOnboardingLoading.value = false;
      return null;
      
    } catch (e) {
      isOnboardingLoading.value = false;
      print('Fingpay Onboarding Error: $e');
      return null;
    }
  }

  /// Two Factor Authentication for Instantpay
  Future<Map<String, dynamic>?> instantpay2FAProcess(String encdata) async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,
        "skey": "TWOFACTORAUTH",
        "encdata": encdata,
      };

      print('Instantpay 2FA Request: $body');
      
      isLoading.value = false;
      return null;
      
    } catch (e) {
      isLoading.value = false;
      print('Instantpay 2FA Error: $e');
      return null;
    }
  }

  /// Two Factor Authentication for Fingpay
  Future<Map<String, dynamic>?> fingpay2FAProcess(String encdata) async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "device": selectedDevice.value,
        "aadhar_no": aadhaarController.text,
        "skey": "TWOFACTORAUTH",
        "encdata": encdata,
      };

      print('Fingpay 2FA Request: $body');
      
      isLoading.value = false;
      return null;
      
    } catch (e) {
      isLoading.value = false;
      print('Fingpay 2FA Error: $e');
      return null;
    }
  }

  /// Get AEPS Bank List
  Future<void> fetchAepsBankList() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
      };

      print('Fetch AEPS Bank List Request: $body');
      
      // On success, update bank lists
      // allBankList.value = response['data'];
      // favoritesList.value = allBankList.where((bank) => bank['is_fav'] == '1').toList();
      
      isLoading.value = false;
      
    } catch (e) {
      isLoading.value = false;
      print('Fetch AEPS Bank List Error: $e');
    }
  }

  /// Get My Bank List (for Fingpay)
  Future<void> fetchMyBankList() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "all_banks_list": "true",
      };

      print('Fetch My Bank List Request: $body');
      
      isLoading.value = false;
      
    } catch (e) {
      isLoading.value = false;
      print('Fetch My Bank List Error: $e');
    }
  }

  /// AEPS Transaction Process for Instantpay
  Future<Map<String, dynamic>?> aepsTransactionProcess({
    required String skey, // 'BAP', 'WAP', 'SAP'
    required String requestType, // 'CONFIRM AEPS TXN REQUEST' or 'PROCESS AEPS TXN REQUEST'
    String? encdata,
  }) async {
    try {
      isTransactionLoading.value = true;
      
      String amount = '0';
      if (selectedService.value == 'cashWithdrawal' || selectedService.value == 'aadhaarPay') {
        amount = serviceAmountController.text;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "device": serviceSelectedDevice.value,
        "bank_iin": selectedBankIin.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "skey": skey,
        "amount": amount,
        "request_type": requestType,
      };

      if (requestType == 'PROCESS AEPS TXN REQUEST' && encdata != null) {
        body["encdata"] = encdata;
      }

      print('AEPS Transaction Request: $body');
      
      isTransactionLoading.value = false;
      return null;
      
    } catch (e) {
      isTransactionLoading.value = false;
      print('AEPS Transaction Error: $e');
      return null;
    }
  }

  /// AEPS Transaction Process for Fingpay
  Future<Map<String, dynamic>?> fingpayTransactionProcess({
    required String skey, // 'BCSFNGPY', 'CWSFNGPY', 'MSTFNGPY', 'ADRFNGPY'
    required String encdata,
  }) async {
    try {
      isTransactionLoading.value = true;
      
      String amount = '0';
      if (selectedService.value == 'cashWithdrawal' || selectedService.value == 'aadhaarPay') {
        amount = serviceAmountController.text;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "request_type": "PROCESS AEPS TXN REQUEST",
        "device": serviceSelectedDevice.value,
        "bank_iin": selectedBankIin.value,
        "aadhar_no": serviceAadhaarController.text,
        "mobile_no": serviceMobileController.text,
        "amount": amount,
        "skey": skey,
        "encdata": encdata,
      };

      print('Fingpay Transaction Request: $body');
      
      isTransactionLoading.value = false;
      return null;
      
    } catch (e) {
      isTransactionLoading.value = false;
      print('Fingpay Transaction Error: $e');
      return null;
    }
  }

  /// Mark Bank as Favorite
  Future<void> markFavoriteBank({required String action}) async {
    try {
      if (selectedBankIin.value.isEmpty) {
        Fluttertoast.showToast(msg: 'Please select a bank first');
        return;
      }
      
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "bank_iin": selectedBankIin.value,
        "bank_id": selectedBankId.value,
        "action": action, // 'ADD' or 'REMOVE'
      };

      print('Mark Favorite Bank Request: $body');
      
      isLoading.value = false;
      
    } catch (e) {
      isLoading.value = false;
      print('Mark Favorite Bank Error: $e');
    }
  }

  /// Get Recent Transactions
  Future<void> fetchRecentTransactions(String serviceType) async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(6),
        "lat": latitude,
        "long": longitude,
        "service_type": serviceType, // 'AEPS2' for Instantpay, 'AEPS3' for Fingpay
      };

      print('Fetch Recent Transactions Request: $body');
      
      isLoading.value = false;
      
    } catch (e) {
      isLoading.value = false;
      print('Fetch Recent Transactions Error: $e');
    }
  }

  // ============== Helper Methods ==============

  /// Get skey based on service and AEPS type
  String getSkey() {
    if (aepsType.value == 'fingpay') {
      switch (selectedService.value) {
        case 'balanceCheck':
          return 'BCSFNGPY';
        case 'cashWithdrawal':
          return 'CWSFNGPY';
        case 'miniStatement':
          return 'MSTFNGPY';
        case 'aadhaarPay':
          return 'ADRFNGPY';
        default:
          return 'BCSFNGPY';
      }
    } else {
      switch (selectedService.value) {
        case 'balanceCheck':
          return 'BAP';
        case 'cashWithdrawal':
          return 'WAP';
        case 'miniStatement':
          return 'SAP';
        default:
          return 'BAP';
      }
    }
  }

  /// Service Selection
  void onServiceSelect(String service) {
    selectedService.value = service;
    showAmountInput.value = (service == 'cashWithdrawal' || service == 'aadhaarPay');
    showConfirmationModal.value = false;
    showResultModal.value = false;
  }

  /// Reset Service Form
  void resetServiceForm() {
    serviceAadhaarController.clear();
    serviceMobileController.clear();
    serviceAmountController.clear();
    serviceSelectedDevice.value = '';
    selectedBankName.value = '';
    selectedBankId.value = '';
    selectedBankIin.value = '';
  }

  /// Select Bank
  void selectBank(Map<String, dynamic> bank) {
    selectedBankName.value = bank['bank_name'] ?? '';
    selectedBankId.value = bank['id']?.toString() ?? '';
    selectedBankIin.value = bank['bank_iin'] ?? '';
  }

  /// Close Modals
  void closeOtpModal() {
    showOtpModal.value = false;
    otpController.clear();
  }

  void closeConfirmationModal() {
    showConfirmationModal.value = false;
    confirmationData.value = null;
    txnPinController.clear();
  }

  void closeResultModal() {
    showResultModal.value = false;
    transactionResult.value = null;
  }

  /// Get Status Color
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

  @override
  void onClose() {
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
    super.onClose();
  }
}
