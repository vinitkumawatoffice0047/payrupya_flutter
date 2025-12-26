import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// Import your existing files - adjust paths as needed
// import '../api/api_provider.dart';
// import '../api/web_api_constant.dart';
// import '../utils/app_shared_preferences.dart';
// import '../utils/ConsoleLog.dart';
// import '../utils/custom_loading.dart';
// import '../utils/global_utils.dart';
// import '../controllers/login_controller.dart';
// import '../models/aeps_response_models.dart';

/// AEPS Controller for handling both AEPS One (Fingpay) and AEPS Three (Instantpay)
class AepsController extends GetxController {
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
  RxBool showOnboardAuthForm = false.obs; // For Fingpay eKYC auth

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
  RxList<MyBankAccount> myBankList = <MyBankAccount>[].obs;
  Rx<MyBankAccount?> selectedMyBank = Rx<MyBankAccount?>(null);

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
  final aadhaarController = TextEditingController();
  final mobileController = TextEditingController();
  final selectedDeviceController = TextEditingController();
  RxString selectedDevice = ''.obs;

  // Onboarding Form (Instantpay)
  final emailController = TextEditingController();
  final panController = TextEditingController();
  final bankAccountController = TextEditingController();
  final ifscController = TextEditingController();

  // Onboarding Form (Fingpay - additional fields)
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
  // Uncomment and adjust based on your existing code structure
  // final ApiProvider _apiProvider = ApiProvider();
  // final LoginController _loginController = Get.find<LoginController>();

  // ============== Lifecycle ==============

  @override
  void onInit() {
    super.onInit();
    // Initialize user data from login controller
    // _initializeUserData();
  }

  @override
  void onClose() {
    // Dispose all controllers
    aadhaarController.dispose();
    mobileController.dispose();
    selectedDeviceController.dispose();
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
  }

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
    serviceAadhaarController.clear();
    serviceMobileController.clear();
    serviceAmountController.clear();
    serviceSelectedDevice.value = '';
    selectedBankName.value = '';
    selectedBankId.value = '';
    selectedBankIin.value = '';
  }

  void resetOnboardingForm() {
    otpController.clear();
    bankAccountController.clear();
    ifscController.clear();
  }

  // ============== Bank Selection ==============

  void selectBank(AepsBank bank) {
    selectedBankName.value = bank.bankName ?? '';
    selectedBankId.value = bank.id ?? '';
    selectedBankIin.value = bank.bankIin ?? '';
  }

  void selectMyBank(MyBankAccount bank) {
    selectedMyBank.value = bank;
  }

  // ============== Modal Controls ==============

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
