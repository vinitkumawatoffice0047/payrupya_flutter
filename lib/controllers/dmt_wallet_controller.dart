// lib/controllers/dmt_wallet_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/add_beneficiary_response_model.dart';
import '../models/add_sender_response_model.dart';
import '../models/check_sender_response_model.dart';
import '../models/confirm_transfer_response_model.dart';
import '../models/delete_beneficiary_response_model.dart';
import '../models/get_all_banks_response_model.dart';
import '../models/get_allowed_service_by_type_response_model.dart';
import '../models/get_beneficiary_list_response_model.dart';
import '../models/transfer_money_response_model.dart';
import '../models/verify_account_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';
import '../utils/transfer_success_dialog.dart';
import '../view/login_screen.dart';
import '../view/onboarding_screen.dart';
import '../view/transaction_confirmation_screen.dart';
import 'login_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart'; // optional
import 'package:printing/printing.dart';

// ============================================
// SORT OPTIONS ENUM
// ============================================
enum BeneficiarySortOption {
  nameAsc,      // A to Z
  nameDesc,     // Z to A
  bankAsc,      // Bank A to Z
  bankDesc,     // Bank Z to A
  recent,       // Recently Added (if having any timestamp)
}

class DmtWalletController extends GetxController {
  static const String _kExternalLoaderRouteName = '__dmt_external_loader__';
  bool _externalLoaderVisible = false;
  bool _pendingExternalReturnCleanup = false;

  void _showExternalSafeLoader(BuildContext context) {
    if (_externalLoaderVisible) return;
    _externalLoaderVisible = true;

    // Use root navigator + a named route so we can safely dismiss only this dialog.
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      routeSettings: const RouteSettings(name: _kExternalLoaderRouteName),
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const SizedBox(
                  height: 44,
                  width: 44,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideExternalSafeLoader() {
    if (!_externalLoaderVisible) return;

    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    // Pop only our loader dialog route (if it is on top).
    Navigator.of(ctx, rootNavigator: true)
        .popUntil((route) => route.settings.name != _kExternalLoaderRouteName);

    _externalLoaderVisible = false;
  }

  void _forceHideExternalSafeLoader() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx != null) {
      Navigator.of(ctx, rootNavigator: true)
          .popUntil((route) => route.settings.name != _kExternalLoaderRouteName);
    }
    _externalLoaderVisible = false;
  }

  LoginController loginController = Get.put(LoginController());
  final FlutterNativeHtmlToPdf _htmlToPdf = FlutterNativeHtmlToPdf();

  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;
  RxString checkSenderRespCode = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadAuthCredentials();

    // LOAD SERVICE ON INIT
    // Listen for location changes
    ever(loginController.latitude, (_) {
      checkAndLoadService();
    });

    ever(loginController.longitude, (_) {
      checkAndLoadService();
    });
    // getAllowedServiceByType(Get.context!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from an external intent (PDF viewer / WhatsApp share),
    // make sure our loading dialog is not stuck on screen.
    if (state == AppLifecycleState.resumed && _pendingExternalReturnCleanup) {
      _pendingExternalReturnCleanup = false;
      _forceHideExternalSafeLoader();
    }
  }

  // Load service when location is available
  void checkAndLoadService() {
    if (loginController.latitude.value != 0.0 &&
        loginController.longitude.value != 0.0 &&
        serviceCode.value.isEmpty &&
        !isServiceLoaded.value) {

      ConsoleLog.printInfo("Location available, loading service...");

      if (Get.context != null) {
        getAllowedServiceByType(Get.context!);
      }
    }
  }

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

  // Text Controllers
  Rx<TextEditingController> senderMobileController = TextEditingController().obs;
  Rx<TextEditingController> senderNameController = TextEditingController().obs;
  Rx<TextEditingController> senderAddressController = TextEditingController().obs;
  Rx<TextEditingController> senderPincodeController = TextEditingController().obs;
  Rx<TextEditingController> senderOtpController = TextEditingController().obs;
  
  Rx<TextEditingController> beneNameController = TextEditingController().obs;
  Rx<TextEditingController> beneAccountController = TextEditingController().obs;
  Rx<TextEditingController> beneIfscController = TextEditingController().obs;
  Rx<TextEditingController> beneMobileController = TextEditingController().obs;
  
  Rx<TextEditingController> transferAmountController = TextEditingController().obs;
  Rx<TextEditingController> transferConfirmAmountController = TextEditingController().obs;
  Rx<TextEditingController> transferModeController = TextEditingController().obs;
  Rx<TextEditingController> txnPinController = TextEditingController().obs;
  // Rx<TextEditingController> tpinController = TextEditingController().obs;

  Rx<TextEditingController> deleteOtpController = TextEditingController().obs;

  // Observable variables
  RxString selectedState = ''.obs;
  RxString selectedCity = ''.obs;
  RxString selectedPincode = ''.obs;
  RxString selectedBank = ''.obs;
  RxString selectedBankId = ''.obs;
  RxString selectedIfsc = ''.obs;
  RxString selectedTransferMode = 'IMPS'.obs;
  
  RxString referenceId = ''.obs;
  RxString identifier = ''.obs;
  RxBool isSenderVerified = false.obs;
  RxBool isMobileVerified = false.obs;
  RxBool isAccountVerified = false.obs;
  
  // Sender Data
  Rx<SenderData?> currentSender = Rx<SenderData?>(null);
  RxString senderId = ''.obs;
  RxString senderName = ''.obs;
  RxString senderMobileNo = ''.obs;
  RxString consumedLimit = '0'.obs;
  RxString availableLimit = '0'.obs;
  RxString txnPin = ''.obs;

  // Beneficiary List
  RxList<BeneficiaryData> beneficiaryList = <BeneficiaryData>[].obs;
  RxList<BeneficiaryData> filteredBeneficiaryList = <BeneficiaryData>[].obs;
  
  // Banks List
  RxList<BankData> banksList = <BankData>[].obs;
  
  // Search
  RxString searchQuery = ''.obs;
  // Rx<BeneficiarySortOption> currentSortOption = BeneficiarySortOption.nameAsc.obs;
  Rx<BeneficiarySortOption> currentSortOption = BeneficiarySortOption.recent.obs;
  // RxString currentSortLabel = 'Name A-Z'.obs;
  RxString currentSortLabel = 'Recently Added'.obs;

  RxString serviceCode = ''.obs;
  RxBool isServiceLoaded = false.obs;

  // Transfer Confirmation Data
  Rx<Map<String, dynamic>?> confirmationData = Rx<Map<String, dynamic>?>(null);
  RxBool showConfirmation = false.obs;

  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }

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

  Future<void> refreshToken(BuildContext context) async {
    ConsoleLog.printWarning("⚠️ Token expired, please login again");
    await AppSharedPreferences.clearAll();
    Get.offAll(() => OnboardingScreen());
    Fluttertoast.showToast(msg: "Session expired. Please login again.");
  }

  // ============================================
  // 0. GET ALL BANKS LIST
  // ============================================
  Future<void> getAllowedServiceByType(BuildContext context) async {
    try {
      // ✅ Validate token first
      // if (!await isTokenValid()) {
      //   await refreshToken(context);
      //   return;
      // }
      // if (!await isTokenValid()) {
      //   await refreshToken(context);
      //   return await getAllowedServiceByType(context);
      // }

      // if (mobile.isEmpty || mobile.length != 10) {
      //   Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      //   return;
      // }

      if (loginController.latitude.value == 0.0 || loginController.longitude.value == 0.0) {
        ConsoleLog.printInfo("Latitude: ${loginController.latitude.value}");
        ConsoleLog.printInfo("Longitude: ${loginController.longitude.value}");
        return;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(context: context, message: "No Internet Connection!");
        return;
      }

      CustomLoading().show(context);

      isServiceLoaded.value = false;

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value,
        "long": loginController.longitude.value,
        "type": "REMITTANCE"
      };

      // Map<String, dynamic> body = {"request_id":generateRequestId(),"lat":26.9767144,"long":75.753097,"type":"REMITTANCE"};

      var response = await ApiProvider().requestPostForApi(
          context,
          WebApiConstant.API_URL_GET_SERVICE_TYPE,
          body,
          userAuthToken.value,
          userSignature.value,
      );
      
      ConsoleLog.printColor("Get Allowed Service By Type Api Request: ${jsonEncode(body)}", color: "yellow");
      
      // var response = await ApiProvider().postApiRequest(
      //   dictParameter: body,
      //   signature: userSignature.value,
      //   token: userAuthToken.value,
      //   url: WebApiConstant.API_URL_GET_SERVICE_TYPE,
      //   // extraHeaders:
      // );

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("GET ALLOWED SERVICE RESP: ${response.data}");

        GetAllowedServiceByTypeResponseModel apiResponse =
        GetAllowedServiceByTypeResponseModel.fromJson(response.data);

        if (apiResponse.respCode == "RCS" &&
            apiResponse.data != null &&
            apiResponse.data!.isNotEmpty) {

          // ✅ Find DMT service specifically
          var dmtService = apiResponse.data!.firstWhere(
                (service) => service.serviceType == "REMITTANCE" ||
                (service.serviceName?.toUpperCase().contains("DMT") ?? false),
            orElse: () => ServiceData(),
          );

          if (dmtService.serviceCode != null && dmtService.serviceCode!.isNotEmpty) {
            serviceCode.value = dmtService.serviceCode!;
            ConsoleLog.printSuccess("✅ Service Code Loaded: ${serviceCode.value}");
            CustomLoading().hide(context);
          } else if (apiResponse.data![0].serviceCode != null) {
            // Fallback to first service
            serviceCode.value = apiResponse.data![0].serviceCode!;
            ConsoleLog.printSuccess("✅ Using first service: ${serviceCode.value}");
            CustomLoading().hide(context);
          } else {
            // Default fallback
            // serviceCode.value = "DMTRZP";
            // await getAllowedServiceByType(context);
            ConsoleLog.printWarning("⚠️ Using default service code: DMTRZP");
            CustomLoading().hide(context);
          }

          isServiceLoaded.value = true;

          // ✅ Debug: Print all services
          ConsoleLog.printInfo("=== Available Services ===");
          for (var service in apiResponse.data!) {
            ConsoleLog.printInfo("${service.serviceName} (${service.serviceCode}) - ${service.serviceType}");
          }
        } else {
          ConsoleLog.printWarning("⚠️ No services found or empty response");
          // Set default
          // serviceCode.value = "DMTRZP";
          // await getAllowedServiceByType(context);
          // isServiceLoaded.value = true;
          CustomLoading().hide(context);
        }
      } else {
        ConsoleLog.printError("❌ API Error: ${response?.statusCode}");
        // Set default
        // serviceCode.value = "DMTRZP";
        // await getAllowedServiceByType(context);
        // isServiceLoaded.value = true;
      }
    } catch (e) {
      ConsoleLog.printError("❌ GET ALLOWED SERVICE ERROR: $e");
      // Set default
      // serviceCode.value = "DMTRZP";
      // await getAllowedServiceByType(context);
      // isServiceLoaded.value = true;
    }
  }
  // ============================================
  // 1. CHECK SENDER (REMITTER)
  // ============================================
  Future<void> checkSender(BuildContext context, String mobile) async {
    try {
      // ✅ Validate token first
      if (!await isTokenValid()) {
        await refreshToken(context);
        return;
      }

      if (mobile.isEmpty || mobile.length != 10) {
        Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
        return;
      }

      // Wait for service code if empty
      if (serviceCode.value.isEmpty) {
        ConsoleLog.printWarning("Service code not loaded, waiting...");
        Fluttertoast.showToast(
          msg: "Please wait, initializing services...",
          backgroundColor: Colors.orange,
        );

        // Wait up to 5 seconds
        int waitCount = 0;
        while (serviceCode.value.isEmpty && waitCount < 10) {
          await Future.delayed(Duration(milliseconds: 500));
          waitCount++;
        }

        if (serviceCode.value.isEmpty) {
          Fluttertoast.showToast(
            msg: "Service not ready. Please try again.",
            backgroundColor: Colors.red,
          );
          return;
        }
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(context: context, message: "No Internet Connection!");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": mobile,
        "service": serviceCode.value,
        "request_type": "CHECK REMITTER",
      };

      ConsoleLog.printColor("CHECK SENDER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_CHECK_SENDER,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response == null) {
        CustomDialog.error(context: context, message: "No response from server");
        return;
      }

      ConsoleLog.printColor("CHECK SENDER RESPONSE: ${response?.data}");

      if (response.statusCode == 200) {
        CustomLoading().hide(context);
        CheckSenderResponseModel checkSenderResponse =
            CheckSenderResponseModel.fromJson(response.data);

        checkSenderRespCode.value = checkSenderResponse.respCode ?? "";

        if (checkSenderResponse.respCode == "RCS") {
          // Sender exists
          currentSender.value = checkSenderResponse.data;
          isSenderVerified.value = true;

          senderId.value = checkSenderResponse.data?.senderdetail?.senderid ?? '';
          senderName.value = checkSenderResponse.data?.senderdetail?.sendername ?? '';
          senderMobileNo.value = checkSenderResponse.data?.senderdetail?.sendermobile ?? '';
          consumedLimit.value = (checkSenderResponse.data?.senderdetail?.consumed_limit ?? '0').toString();
          double? availLimit = checkSenderResponse.data?.senderdetail?.availabel_limit;
          availableLimit.value = (availLimit?.toString() ?? '0');
          txnPin.value = checkSenderResponse.data?.txnpin ?? '';

          ConsoleLog.printSuccess("Sender found: ${currentSender.value?.name}");
          Fluttertoast.showToast(msg: "Sender verified successfully");
          
          // Fetch beneficiary list
          await getBeneficiaryList(context, mobile);
          
        } else if (checkSenderResponse.respCode == "RNF") {
          // Sender not found - need to register
          currentSender.value = checkSenderResponse.data;
          isSenderVerified.value = false;

          // Store identifier from response (needed for registration)
          identifier.value = checkSenderResponse.data?.identifier ?? '';

          ConsoleLog.printWarning("Sender not found");
          Fluttertoast.showToast(msg: "Please register sender first");
          
        } else if (checkSenderResponse.respCode == "ERR") {
          ConsoleLog.printError("Error: ${checkSenderResponse.respDesc}");

          if (checkSenderResponse.respDesc?.toLowerCase().contains('unauthorized') ?? false) {
            // Token is invalid
            await refreshToken(context);
          } else {
            CustomDialog.error(
              context: context,
              message: checkSenderResponse.respDesc ?? "Failed to check sender",
            );
          }
        } else {
          CustomDialog.error(
            context: context,
            message: checkSenderResponse.respDesc ?? "Unexpected response",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("CHECK SENDER ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 2. ADD SENDER (REGISTER REMITTER)
  // ============================================
  Future<void> addSender(BuildContext context, String otp) async {
    try {
      if (!await isTokenValid()) {
        await refreshToken(context);
        return;
      }

      String mobile = senderMobileController.value.text.trim();
      String name = senderNameController.value.text.trim();
      String address = senderAddressController.value.text.trim();
      // var pincode = senderPincodeController.value;
      String pincode = selectedPincode.value;

      if (mobile.isEmpty || name.isEmpty || address.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields");
        return;
      }

      if (otp.isEmpty || otp.length != 6) {
        Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
        return;
      }

      if (identifier.value.isEmpty) {
        Fluttertoast.showToast(msg: "Identifier not found. Please check sender first.");
        return;
      }

      if (selectedState.value.isEmpty || selectedCity.value.isEmpty || selectedPincode.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please select state, city and pincode");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": mobile,
        "service": serviceCode.value,
        "request_type": "REMITTER REGISTRATION",
        "identifier": identifier.value,
        "sender_otp": otp,
        "sender_name": name,
        "sender_address": address,
        "sender_pincode": pincode,
        "sender_city": selectedCity.value,
        "sender_state": selectedState.value,
      };

      ConsoleLog.printColor("ADD SENDER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_SENDER,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("ADD SENDER RESPONSE: ${response?.data}");
        Map<String, dynamic> responseData;
        try {
          if (response.data is String) {
            responseData = jsonDecode(response.data as String);
          } else {
            responseData = response.data;
          }
        } catch (e) {
          ConsoleLog.printError("Error parsing response: $e");
          CustomDialog.error(
            context: context,
            message: "Failed to parse server response",
          );
          return;
        }
        AddSenderResponseModel addSenderResponse =
        AddSenderResponseModel.fromJson(responseData);
        // var data = response.data;

        if (addSenderResponse.respCode == 'RCS') {
          isSenderVerified.value = true;

          ConsoleLog.printSuccess("Sender registered successfully");
          ConsoleLog.printInfo("Identifier: ${addSenderResponse.data?.senderid?.identifier}");
          Fluttertoast.showToast(msg: "Sender registered successfully");

          // Clear form
          senderOtpController.value.clear();

          // Refresh sender details
          await checkSender(context, mobile);

        } else if (addSenderResponse.respCode == 'ERR') {
          String errorMsg = addSenderResponse.respDesc ?? "Failed to add sender";

          // Check if "already registered"
          if (errorMsg.toLowerCase().contains('already registered')) {
            ConsoleLog.printInfo("Sender already registered");
            Fluttertoast.showToast(msg: "You are already registered");

            // Navigate to wallet (user is verified)
            isSenderVerified.value = true;
            await checkSender(context, mobile);

          } else {
            // Real error - show error dialog
            ConsoleLog.printError("ADD SENDER ERROR: $errorMsg");

            Get.dialog(
              AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Registration Failed',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
                content: Text(
                  errorMsg,
                  style: GoogleFonts.albertSans(fontSize: 14, color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'OK',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0054D3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          // Unexpected response
          String errorMsg = addSenderResponse.respDesc ?? "Unexpected response";
          CustomDialog.error(context: context, message: errorMsg);
        }
      } else if (response?.statusCode == 401) {
        await refreshToken(context);
      } else {
        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Connection Error', style: GoogleFonts.albertSans(color: Colors.black),),
            content: Text('No response from server', style: GoogleFonts.albertSans(color: Colors.black),),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK', style: GoogleFonts.albertSans(color: Colors.black)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("ADD SENDER ERROR: $e");
      String errorMessage = "Technical issue occurred";
      if (e.toString().contains('not a subtype')) {
        errorMessage = "Response format error. Please try again.";
      }
      // CustomDialog.error(context: context, message: "Technical issue!");
    }
  }
  // // ============================================
  // // 2. ADD SENDER (REGISTER REMITTER)
  // // ============================================
  // Future<void> addSender(BuildContext context) async {
  //   try {
  //     if (!await isTokenValid()) {
  //       await refreshToken(context);
  //       return;
  //     }
  //
  //     String mobile = senderMobileController.value.text.trim();
  //     String name = senderNameController.value.text.trim();
  //     String address = senderAddressController.value.text.trim();
  //
  //     if (mobile.isEmpty || name.isEmpty || address.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please fill all required fields");
  //       return;
  //     }
  //
  //     if (selectedState.value.isEmpty || selectedCity.value.isEmpty || selectedPincode.value.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please select state, city and pincode");
  //       return;
  //     }
  //
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": mobile,
  //       "name": name,
  //       "address": address,
  //       "state": selectedState.value,
  //       "city": selectedCity.value,
  //       "pincode": selectedPincode.value,
  //       "service": serviceCode.value,
  //       "request_type": "REMITTER REGISTRATION",
  //     };
  //
  //     ConsoleLog.printColor("ADD SENDER REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_ADD_SENDER,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //     ConsoleLog.printColor("ADD SENDER RESPONSE: ${response?.data}");
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       AddSenderResponseModel addSenderResponse =
  //           AddSenderResponseModel.fromJson(response.data);
  //
  //       if (addSenderResponse.respCode == "RCS") {
  //         referenceId.value = addSenderResponse.data?.referenceid ?? "";
  //
  //         ConsoleLog.printSuccess("Sender registered, OTP sent");
  //         Fluttertoast.showToast(msg: "OTP sent successfully");
  //
  //         // Navigate to OTP screen or show OTP dialog
  //
  //       } else {
  //         CustomDialog.error(
  //           context: context,
  //           message: addSenderResponse.respDesc ?? "Failed to add sender",
  //         );
  //       }
  //     }else if (response?.statusCode == 401) {
  //       await refreshToken(context);
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("ADD SENDER ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // // ============================================
  // // 3. VERIFY SENDER OTP
  // // ============================================
  // Future<void> verifySenderOtp(BuildContext context, String otp) async {
  //   try {
  //     if (otp.isEmpty || otp.length != 6) {
  //       Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
  //       return;
  //     }
  //
  //     if (referenceId.value.isEmpty) {
  //       Fluttertoast.showToast(msg: "Reference ID not found");
  //       return;
  //     }
  //
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": senderMobileController.value.text.trim(),
  //       "otp": otp,
  //       "referenceid": referenceId.value,
  //       "service": serviceCode.value,
  //       "request_type": "VERIFY OTP",
  //     };
  //
  //     ConsoleLog.printColor("VERIFY SENDER OTP REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_VERIFY_SENDER_OTP,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       var data = response.data;
  //
  //       if (data['Resp_code'] == 'RCS') {
  //         isSenderVerified.value = true;
  //         ConsoleLog.printSuccess("Sender OTP verified successfully");
  //         // Fluttertoast.showToast(msg: "Sender verified successfully");
  //
  //         // Refresh sender details
  //         // await checkSender(context, senderMobileController.value.text.trim());
  //
  //       } else {
  //         CustomDialog.error(
  //           context: context,
  //           message: data['Resp_desc'] ?? "Invalid OTP",
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("VERIFY SENDER OTP ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // // ============================================
  // // 4. GET BENEFICIARY LIST
  // // ============================================
  // Future<void> getBeneficiaryList(BuildContext context, String senderMobile) async {
  //   try {
  //     if (!await isTokenValid()) {
  //       await refreshToken(context);
  //       return;
  //     }
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": senderMobile,
  //       "service": serviceCode.value,
  //       "start": "0",
  //       "limit": "100",
  //       "searchby": "",
  //     };
  //
  //     ConsoleLog.printColor("GET BENEFICIARY LIST REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_GET_BENEFICIARY_LIST,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       GetBeneficiaryListResponseModel beneListResponse =
  //           GetBeneficiaryListResponseModel.fromJson(response.data);
  //
  //       if (beneListResponse.respCode == "RCS" && beneListResponse.data != null) {
  //         beneficiaryList.value = beneListResponse.data!;
  //         filteredBeneficiaryList.value = beneListResponse.data!;
  //
  //         ConsoleLog.printSuccess("Beneficiaries loaded: ${beneficiaryList.length}");
  //
  //       } else {
  //         beneficiaryList.clear();
  //         filteredBeneficiaryList.clear();
  //       }
  //     }else if (response?.statusCode == 401) {
  //       await refreshToken(context);
  //     }
  //   } catch (e) {
  //     ConsoleLog.printError("GET BENEFICIARY LIST ERROR: $e");
  //   }
  // }

  // ============================================
  // 4. GET BENEFICIARY LIST
  // ============================================
  Future<void> getBeneficiaryList(BuildContext context, String senderMobile) async {
    try {
      if (!await isTokenValid()) {
        await refreshToken(context);
        return;
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobile,
      };

      ConsoleLog.printColor("GET BENEFICIARY LIST REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_BENEFICIARY_LIST,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        GetBeneficiaryListResponseModel beneListResponse =
        GetBeneficiaryListResponseModel.fromJson(response.data);

        if (beneListResponse.respCode == "RCS" && beneListResponse.data != null) {
          beneficiaryList.value = beneListResponse.data!;
          filteredBeneficiaryList.value = beneListResponse.data!;

          // Current sort after loading
          applySortOption(currentSortOption.value);

          ConsoleLog.printSuccess("Beneficiaries loaded: ${beneficiaryList.length}");

        } else {
          beneficiaryList.clear();
          filteredBeneficiaryList.clear();
        }
      }else if (response?.statusCode == 401) {
        await refreshToken(context);
      }
    } catch (e) {
      ConsoleLog.printError("GET BENEFICIARY LIST ERROR: $e");
    }
  }

  /// Bank account number:
  /// - Sirf digits allowed
  /// - Length: 9 se 18 digits (India me common range)
  bool isValidAccountNumber(String? accountNumber) {
    if (accountNumber == null) return false;

    final trimmed = accountNumber.trim();

    // Regex: 9–18 digits
    final regExp = RegExp(r'^[0-9]{9,18}$');
    return regExp.hasMatch(trimmed);
  }

  /// IFSC code validation (Indian):
  /// - 4 capital letters (bank code)
  /// - 1 zero (0)
  /// - 6 alphanumeric (branch code)
  /// Example: SBIN0001234
  bool isValidIFSC(String? ifsc) {
    if (ifsc == null) return false;

    final trimmed = ifsc.trim().toUpperCase();

    // Regex: 4 letters + 0 + 6 alphanumeric
    final regExp = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    return regExp.hasMatch(trimmed);
  }

  // ============================================
  // NEW: GET BENEFICIARY NAME FROM ACCOUNT
  // ============================================
  Future<void> getBeneficiaryName(BuildContext context) async {
    try {
      String accountNumber = beneAccountController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();
      String beneName = beneNameController.value.text.trim();

      // Validation
      if (accountNumber.isEmpty) {
        Fluttertoast.showToast(msg: "Account number required!");
        return;
      }
      if (!isValidAccountNumber(accountNumber)) {
        Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
        return;
      }

      if (ifsc.isEmpty) {
        Fluttertoast.showToast(msg: "IFSC code required!");
        return;
      }
      if (!isValidIFSC(ifsc)) {
        Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
        return;
      }

      if (selectedBank.value.isEmpty || selectedBank.value == "Select Bank") {
        Fluttertoast.showToast(msg: "Please select bank first", backgroundColor: Colors.red);
        return;
      }

      ConsoleLog.printColor("===>>> senderId.value.isEmpty: ${senderId.value.isEmpty}, senderMobileNo.value.isEmpty: ${senderMobileNo.value.isEmpty}\n");

      if (senderId.value.isEmpty || senderMobileNo.value.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "senderid": senderId.value,
        "sender": senderMobileNo.value,
        "request_type": "INITIATE BENEVALIDATION",
        "service": serviceCode.value,
        "account": accountNumber,
        "banksel": selectedBank.value,
        "bankifsc": ifsc,
        "benename": beneName.isNotEmpty ? beneName : "",
      };

      ConsoleLog.printColor("GET BENEFICIARY NAME REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_SENDER,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'RCS') {
          if (data['data']?['txn_status'] == 'SUCCESS') {
            isAccountVerified.value = true;

            // Auto-fill beneficiary name
            if (data['data']?['benename'] != null &&
                data['data']['benename'].toString().isNotEmpty) {
              String fetchedName = data['data']['benename'].toString();
              beneNameController.value.text = fetchedName;

              ConsoleLog.printSuccess("✅ Beneficiary name fetched: $fetchedName");
              // Fluttertoast.showToast(
              //   msg: "Name fetched: $fetchedName",
              //   backgroundColor: Colors.green,
              //   toastLength: Toast.LENGTH_LONG,
              //   gravity: ToastGravity.TOP,
              // );
            }
          } else if (data['data']?['txn_status'] == 'FAILED') {
            isAccountVerified.value = false;
            CustomDialog.error(
              context: context,
              message: data['Resp_desc'] ?? "Failed to fetch name",
            );
          }
        } else {
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Unable to fetch beneficiary name",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("GET BENEFICIARY NAME ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 5. VERIFY ACCOUNT (INITIATE BENEVALIDATION)
  // ============================================
  Future<void> verifyAccount(BuildContext context) async {
    try {
      String accountNumber = beneAccountController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();
      String beneName = beneNameController.value.text.trim();
      // String beneName = selectedBank.value.trim();

      // if(selectedBank.value.isEmpty || selectedBank.value == "Select Bank"){
      //   Fluttertoast.showToast(msg: "Please select bank");
      //   return;
      // }
      //
      // if (accountNumber.trim().isEmpty) {
      //   Fluttertoast.showToast(msg: "Account number required!");
      //   return;
      // }
      // if (!isValidAccountNumber(accountNumber)) {
      //   Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
      //   return;
      // }
      //
      // if (ifsc.trim().isEmpty) {
      //   Fluttertoast.showToast(msg: "IFSC code required!");
      //   return;
      // }
      // if (!isValidIFSC(ifsc)) {
      //   Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
      //   return;
      // }

      // if (accountNumber.isEmpty || ifsc.isEmpty) {
      //   Fluttertoast.showToast(msg: "Please enter account number and IFSC");
      //   return;
      // }

      ConsoleLog.printColor(
          "========>>>>>> Selected Bank: ${selectedBank.value}, \nIFSC: $ifsc, \nAccount: $accountNumber, \nName: $beneName, \nSender: ${currentSender.value?.mobile}, \nSender ID: ${senderId.value}, \nSender Name: ${currentSender.value?.name}"
      );
      if (senderId.value.isEmpty || currentSender.value?.mobile == null) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "senderid": senderId.value,
        "sender": currentSender.value!.mobile,
        "request_type": "INITIATE BENEVALIDATION",
        "service": serviceCode.value,
        "account": accountNumber,
        "banksel": selectedBank.value,
        "bankifsc": ifsc,
        "benename": beneName.isNotEmpty ? beneName : "",
      };

      ConsoleLog.printColor("VERIFY ACCOUNT REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_SENDER, // ✅ Uses process_remit_action_new
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        CustomLoading().hide(context);
        var data = response.data;

        if (data['Resp_code'] == 'RCS') {
          if (data['data']?['txn_status'] == 'SUCCESS') {
            isAccountVerified.value = true;

            // Auto-fill beneficiary name
            if (data['data']?['benename'] != null) {
              beneNameController.value.text = data['data']['benename'];
            }

            ConsoleLog.printSuccess("Account verified: ${data['data']?['benename']}");
            Fluttertoast.showToast(msg: "Account verified successfully");

          } else if (data['data']?['txn_status'] == 'PENDING') {
            Fluttertoast.showToast(msg: "Verification pending");
          } else if (data['data']?['txn_status'] == 'FAILED') {
            isAccountVerified.value = false;
            CustomDialog.error(
              context: context,
              message: data['Resp_desc'] ?? "Verification failed",
            );
          }
        } else {
          isAccountVerified.value = false;
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Account verification failed",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("VERIFY ACCOUNT ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // // ============================================
  // // 6. ADD BENEFICIARY
  // // ============================================
  // Future<void> addBeneficiary(BuildContext context) async {
  //   try {
  //     String beneName = beneNameController.value.text.trim();
  //     String accountNumber = beneAccountController.value.text.trim();
  //     String ifsc = beneIfscController.value.text.trim();
  //     String mobile = beneMobileController.value.text.trim();
  //
  //     if (beneName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please fill all required fields");
  //       return;
  //     }
  //
  //     if (!isAccountVerified.value) {
  //       Fluttertoast.showToast(msg: "Please verify account first");
  //       return;
  //     }
  //
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": currentSender.value?.mobile ?? "",
  //       "bene_name": beneName,
  //       "account_number": accountNumber,
  //       "ifsc": ifsc,
  //       "mobile": mobile,
  //       "bank_id": selectedBankId.value,
  //       "service": serviceCode.value,
  //       "request_type": "ADD BENEFICIARY",
  //     };
  //
  //     ConsoleLog.printColor("ADD BENEFICIARY REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_ADD_BENEFICIARY,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       AddBeneficiaryResponseModel addBeneResponse = 
  //           AddBeneficiaryResponseModel.fromJson(response.data);
  //
  //       if (addBeneResponse.respCode == "RCS") {
  //         ConsoleLog.printSuccess("Beneficiary added successfully");
  //         Fluttertoast.showToast(msg: "Beneficiary added successfully");
  //        
  //         // Refresh beneficiary list
  //         await getBeneficiaryList(context, currentSender.value?.mobile ?? "");
  //        
  //         // Clear form
  //         beneNameController.value.clear();
  //         beneAccountController.value.clear();
  //         beneIfscController.value.clear();
  //         beneMobileController.value.clear();
  //         isAccountVerified.value = false;
  //        
  //         Get.back();
  //        
  //       } else {
  //         CustomDialog.error(
  //           context: context,
  //           message: addBeneResponse.respDesc ?? "Failed to add beneficiary",
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("ADD BENEFICIARY ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // ============================================
  // 6. ADD BENEFICIARY
  // ============================================
  Future<void> addBeneficiary(BuildContext context) async {
    try {
      String beneName = beneNameController.value.text.trim();
      String accountNumber = beneAccountController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();

      if (beneName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields");
        return;
      }

      if (!isAccountVerified.value) {
        Fluttertoast.showToast(msg: "Please verify account first");
        return;
      }

      ConsoleLog.printColor('======>>>>> senderId.value.isEmpty: ${senderId.value.isEmpty}, senderId.value: ${senderId.value} \n senderMobileNo.value: ${senderMobileNo.value}');

      if (senderId.value.isEmpty || senderMobileNo.value.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);
      
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "senderid": senderId.value,                           
        "sender": senderMobileNo.value,
        "senderdata": {                                       
          "sendermobile": senderMobileNo.value,
        },
        "request_type": "ADD BENEDATA",                       
        "service": serviceCode.value,
        "account": accountNumber,                             
        "banksel": selectedBank.value,                        
        "bankifsc": ifsc,                                     
        "benename": beneName,                                 
        "is_verified": isAccountVerified.value ? '1' : '0',   
      };

      ConsoleLog.printColor("ADD BENEFICIARY REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        CustomLoading().hide(context);
        AddBeneficiaryResponseModel addBeneResponse =
        AddBeneficiaryResponseModel.fromJson(response.data);

        if (addBeneResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Beneficiary added successfully");
          Fluttertoast.showToast(msg: "Beneficiary added successfully");

          // Refresh beneficiary list
          await getBeneficiaryList(context, senderMobileNo.value);

          // Clear form
          selectedBank.value = "Select Bank";
          beneNameController.value.clear();
          beneAccountController.value.clear();
          beneIfscController.value.clear();
          beneMobileController.value.clear();
          isAccountVerified.value = false;

          Get.back();

        } else {
          CustomDialog.error(
            context: context,
            message: addBeneResponse.respDesc ?? "Failed to add beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("ADD BENEFICIARY ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // // ============================================
  // // 6. DELETE BENEFICIARY
  // // ============================================
  // Future<void> deleteBeneficiary(BuildContext context, String beneId) async {
  //   try {
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": currentSender.value?.mobile ?? "",
  //       "bene_id": beneId,
  //       "service": serviceCode.value,
  //       "request_type": "DELETE BENEFICIARY",
  //     };
  //
  //     ConsoleLog.printColor("DELETE BENEFICIARY REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_DELETE_BENEFICIARY,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       DeleteBeneficiaryResponseModel deleteResponse =
  //           DeleteBeneficiaryResponseModel.fromJson(response.data);
  //
  //       if (deleteResponse.respCode == "RCS" && deleteResponse.data?.deleted == true) {
  //         ConsoleLog.printSuccess("Beneficiary deleted successfully");
  //         Fluttertoast.showToast(msg: "Beneficiary deleted successfully");
  //
  //         // Remove from list
  //         beneficiaryList.removeWhere((bene) => bene.beneId == beneId);
  //         filteredBeneficiaryList.removeWhere((bene) => bene.beneId == beneId);
  //
  //       } else {
  //         CustomDialog.error(
  //           context: context,
  //           message: deleteResponse.respDesc ?? "Failed to delete beneficiary",
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("DELETE BENEFICIARY ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // ============================================
  // 7. DELETE BENEFICIARY - ✅ COMPLETELY REWRITTEN (2-STEP PROCESS)
  // ============================================

  // Step 1: Request OTP for deletion
  Future<void> deleteBeneficiaryRequestOtp(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "request_type": "VERIFY",                             // ✅ FIXED
      };

      ConsoleLog.printColor("DELETE BENE REQUEST OTP: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'VRF') {
          // OTP sent successfully
          ConsoleLog.printSuccess("OTP sent for beneficiary deletion");

          // Show OTP dialog
          showDeleteOtpDialog(context, beneId);

        } else {
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Failed to send OTP",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("DELETE BENEFICIARY REQUEST OTP ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
// Resend OTP (without opening new dialog)
// ============================================
  Future<void> resendDeleteBeneficiaryOtp(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "request_type": "VERIFY",
      };

      ConsoleLog.printColor("RESEND DELETE BENE OTP: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'VRF') {
          ConsoleLog.printSuccess("OTP resent for beneficiary deletion");
          Fluttertoast.showToast(msg: "OTP sent successfully");
          // NO dialog opening here!

        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to send OTP",
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("RESEND DELETE BENEFICIARY OTP ERROR: $e");
      Fluttertoast.showToast(
        msg: "Failed to resend OTP",
        backgroundColor: Colors.red,
      );
    }
  }

  // Step 2: Validate OTP and delete beneficiary
  Future<void> deleteBeneficiaryValidate(BuildContext context, String beneId, String otp) async {
    try {
      if (otp.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter OTP");
        return;
      }

      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "otp": otp,
        "request_type": "VALIDATE",
      };

      ConsoleLog.printColor("DELETE BENE VALIDATE: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        DeleteBeneficiaryResponseModel deleteResponse =
        DeleteBeneficiaryResponseModel.fromJson(response.data);

        if (deleteResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Beneficiary deleted successfully");
          Fluttertoast.showToast(msg: "Beneficiary deleted successfully");

          // Remove from list
          beneficiaryList.removeWhere((bene) => bene.beneId == beneId);
          filteredBeneficiaryList.removeWhere((bene) => bene.beneId == beneId);

          Get.back(); // Close OTP dialog

        } else {
          CustomDialog.error(
            context: context,
            message: deleteResponse.respDesc ?? "Failed to delete beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("DELETE BENEFICIARY VALIDATE ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  final GlobalKey<OtpInputFieldsState> deleteOtpKey = GlobalKey<OtpInputFieldsState>();

  void showDeleteOtpDialog(BuildContext context, String beneId) {
    deleteOtpController.value.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
          color: Colors.black54,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enter Verification Code',
                          style: GoogleFonts.albertSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff0F0F0F),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            // setState(() => showOtpDialog = false);
                          },
                          child: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        children: [
                          TextSpan(text: 'We sent a verification code to '),
                          TextSpan(
                            text: '+91 ${senderMobileController.value.text}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
              
                    // OTP Input Fields
                    OtpInputFields(
                      key: deleteOtpKey,
                      length: 6,
                      onChanged: (otp) {
                        deleteOtpController.value.text = otp;
                      },
                    ),
              
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await resendDeleteBeneficiaryOtp(context, beneId);
                            deleteOtpKey.currentState?.clear();
                            deleteOtpKey.currentState?.focusFirst();
                            Fluttertoast.showToast(msg: "OTP sent successfully");
                          },
                          child: Text(
                            'Click to resend',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E5BFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
              
                    // Verify Button
                    GlobalUtils.CustomButton(
                      text: "VERIFY",
                      onPressed: () async {
                        String otp = deleteOtpController.value.text.trim();
                        if (otp.isEmpty || otp.length != 6) {
                          Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
                          return;
                        }
                        deleteBeneficiaryValidate(context, beneId, otp);
                      },
                      textStyle: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      width: GlobalUtils.screenWidth * 0.9,
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
              ),
            ),
          ),
                ),
        );}
    );
  }

  // // ============================================
  // // 7. VERIFY ACCOUNT
  // // ============================================
  // Future<void> verifyAccount(BuildContext context) async {
  //   try {
  //     String accountNumber = beneAccountController.value.text.trim();
  //     String ifsc = beneIfscController.value.text.trim();
  //
  //     if (accountNumber.isEmpty || ifsc.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please enter account number and IFSC");
  //       return;
  //     }
  //
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "account_number": accountNumber,
  //       "ifsc": ifsc,
  //       "bank_id": selectedBankId.value,
  //     };
  //
  //     ConsoleLog.printColor("VERIFY ACCOUNT REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_VERIFY_ACCOUNT,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       VerifyAccountResponseModel verifyResponse =
  //           VerifyAccountResponseModel.fromJson(response.data);
  //
  //       if (verifyResponse.respCode == "RCS" && verifyResponse.data?.verified == true) {
  //         isAccountVerified.value = true;
  //
  //         // Auto-fill beneficiary name
  //         if (verifyResponse.data?.beneName != null) {
  //           beneNameController.value.text = verifyResponse.data!.beneName!;
  //         }
  //
  //         ConsoleLog.printSuccess("Account verified: ${verifyResponse.data?.beneName}");
  //         Fluttertoast.showToast(msg: "Account verified successfully");
  //
  //       } else {
  //         isAccountVerified.value = false;
  //         CustomDialog.error(
  //           context: context,
  //           message: verifyResponse.respDesc ?? "Account verification failed",
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("VERIFY ACCOUNT ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // // ============================================
  // // 8. TRANSFER MONEY
  // // ============================================
  // Future<void> transferMoney(BuildContext context, BeneficiaryData beneficiary) async {
  //   try {
  //     String amount = transferAmountController.value.text.trim();
  //     String tpin = tpinController.value.text.trim();
  //
  //     if (amount.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please enter amount");
  //       return;
  //     }
  //
  //     double amountValue = double.tryParse(amount) ?? 0;
  //     if (amountValue <= 0) {
  //       Fluttertoast.showToast(msg: "Please enter valid amount");
  //       return;
  //     }
  //
  //     if (tpin.isEmpty) {
  //       Fluttertoast.showToast(msg: "Please enter TPIN");
  //       return;
  //     }
  //
  //     CustomLoading().show(context);
  //
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //       "sender": currentSender.value?.mobile ?? "",
  //       "bene_id": beneficiary.beneId,
  //       "amount": amount,
  //       "tpin": tpin,
  //       "service": serviceCode.value,
  //       "request_type": "TRANSFER",
  //     };
  //
  //     ConsoleLog.printColor("TRANSFER MONEY REQ: $body");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_TRANSFER_MONEY,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     CustomLoading().hide(context);
  //
  //     if (response != null && response.statusCode == 200) {
  //       CustomLoading().hide(context);
  //       TransferMoneyResponseModel transferResponse =
  //           TransferMoneyResponseModel.fromJson(response.data);
  //
  //       if (transferResponse.respCode == "RCS") {
  //         ConsoleLog.printSuccess("Transfer successful: ${transferResponse.data?.txnId}");
  //
  //         // Show success dialog
  //         showSuccessDialog(context, transferResponse.data);
  //
  //         // Clear form
  //         transferAmountController.value.clear();
  //         tpinController.value.clear();
  //
  //       } else {
  //         CustomDialog.error(
  //           context: context,
  //           message: transferResponse.respDesc ?? "Transfer failed",
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     CustomLoading().hide(context);
  //     ConsoleLog.printError("TRANSFER MONEY ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue!");
  //   }
  // }

  // ============================================
  // 8. TRANSFER MONEY - COMPLETELY REWRITTEN (2-STEP PROCESS)
  // ============================================

  // Step 1: Confirm transaction and get charges
  Future<void> confirmTransfer(BuildContext transferMoneyContext, BeneficiaryData beneficiary) async {
    try {
      String amount = transferAmountController.value.text.trim();
      String confirmAmount = transferConfirmAmountController.value.text.trim();
      String mode = selectedTransferMode.value; // IMPS or NEFT

      if (amount.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter amount");
        return;
      }

      double amountValue = double.tryParse(amount) ?? 0;
      if (amountValue <= 0) {
        Fluttertoast.showToast(msg: "Please enter valid amount");
        return;
      }

      if (confirmAmount.isEmpty) {
        Fluttertoast.showToast(msg: "Please confirm amount");
        return;
      }

      double confirmAmountValue = double.tryParse(confirmAmount) ?? 0;
      if (confirmAmountValue <= 0) {
        Fluttertoast.showToast(msg: "Please enter valid amount");
        return;
      }

      // if (senderId.value.isEmpty || currentSender.value?.mobile == null) {
      if (senderId.value.isEmpty || senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(transferMoneyContext);

      // Step 1: CONFIRM - Get charges
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "senderid": senderId.value,
        "sender": /*currentSender.value!.mobile*/senderMobileNo.value,
        "service": serviceCode.value,
        "request_type": "CONFIRM",
        "amount": amount,
        "cnfamount": confirmAmount,
        "mode": mode, // (IMPS/NEFT)
        "sendername": senderName.value,
        "beneid": beneficiary.beneId,
        "benename": beneficiary.name,
        "account": beneficiary.accountNo,
        "banksel": beneficiary.bankName,
        "bankifsc": beneficiary.ifsc,
      };

      ConsoleLog.printColor("CONFIRM TRANSFER REQ: ${jsonEncode(body)}");

      var response = await ApiProvider().requestPostForApi(
        transferMoneyContext,
        WebApiConstant.API_URL_ADD_SENDER, // Uses process_remit_action_new
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(transferMoneyContext);

      if (response != null && response.statusCode == 200) {
        ConfirmTransferResponseModel confirmResponse = ConfirmTransferResponseModel.fromJson(response.data);

        if (confirmResponse.respCode == 'RCS' && confirmResponse.data != null) {
          var chargesData = confirmResponse.data!;

          // Log parsed data
          ConsoleLog.printSuccess("Transfer details fetched:");
          ConsoleLog.printInfo("Beneficiary Name: ${senderName.value}");
          ConsoleLog.printInfo("Account Number: ${beneficiary.accountNo!}");
          ConsoleLog.printInfo("Mode: $mode");
          ConsoleLog.printInfo("Amount: ${chargesData.trasamt!}");
          ConsoleLog.printInfo("Charged Amount: ${chargesData.chargedamt!.toString()}");
          ConsoleLog.printInfo("Total Charge: ${chargesData.totalcharge!.toString()}");
          ConsoleLog.printInfo("TPIN Status: ${chargesData.txnPinStatus}");
          ConsoleLog.printInfo("TPIN: ${txnPin.value}");
          // Store confirmation data
          confirmationData.value = {
            'body': body,
            'charges': chargesData,  // Store model object
            'beneficiary': beneficiary,
          };

          showConfirmation.value = true;

          print("DEBUG: About to navigate");
          print("confirmationData: ${confirmationData.value != null}");
          print("showConfirmation: ${showConfirmation.value}");

          ConsoleLog.printSuccess("Transfer charges fetched");

          // Get.to(()=>TransactionConfirmationScreen());
          // Show confirmation dialog
          // showTransferConfirmationDialog(transferMoneyContext, beneficiary, chargesData);


        } else {
          showConfirmation.value = false;
          ConsoleLog.printError("Error: ${confirmResponse.respDesc}");
          CustomDialog.error(
            context: transferMoneyContext,
            message: confirmResponse.respDesc ?? "Failed to confirm transfer",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(transferMoneyContext);
      showConfirmation.value = false;
      ConsoleLog.printError("CONFIRM TRANSFER ERROR: $e");
      CustomDialog.error(context: transferMoneyContext, message: "Technical issue!");
    }
  }

  // Initiate transaction with TPIN
  Future<void> initiateTransfer(BuildContext context) async {
    try {
      // String tpin = tpinController.value.text.trim();
      String tpin = txnPinController.value.text.trim();

      if(txnPin.value == "1"){
        if (tpin.isEmpty) {
          Fluttertoast.showToast(msg: "Please enter TPIN");
          return;
        }

        if (confirmationData.value == null) {
          Fluttertoast.showToast(msg: "Confirmation data not found");
          return;
        }
      }

      BuildContext? dialogContext = context;
      CustomLoading().show(dialogContext);

      // INITIATE TXN
      Map<String, dynamic> body = Map.from(confirmationData.value!['body']);
      body['request_id'] = generateRequestId();
      body['request_type'] = 'INITIATE TXN';
      body['txnpin'] = tpin;

      ConsoleLog.printColor("INITIATE TRANSFER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_SENDER, // Uses process_remit_action_new
        body,
        userAuthToken.value,
        userSignature.value,
      );

      // Hide loading safely
      try {
        if (dialogContext.mounted) {
          CustomLoading().hide(dialogContext);
        }
      } catch (e) {
        ConsoleLog.printWarning("Context unmounted while hiding loading");
      }

      if (response != null && response.statusCode == 200) {
        // var data = response.data;
        TransferMoneyResponseModel transferResponse =
        TransferMoneyResponseModel.fromJson(response.data);
        ConsoleLog.printColor("INITIATE TRANSFER RESPONSE: ${response.data}");
        if (transferResponse.respCode == 'RCS' && transferResponse.data != null) {
          ConsoleLog.printSuccess("Transfer successful: ${transferResponse.data!.txnid}");

          // Clear form
          transferAmountController.value.clear();
          transferConfirmAmountController.value.clear();
          txnPinController.value.clear();
          confirmationData.value = null;
          showConfirmation.value = false;

          // Success dialog (no context issues)
          Get.dialog(
            TransferSuccessDialog(
              transferData: transferResponse.data!,
              onClose: () async {
                Get.back(); // Close dialog

                // Small delay to ensure smooth transition
                await Future.delayed(Duration(milliseconds: 100));

                // Pop Transaction Confirmation Screen
                Get.back();
                // Pop Transfer Money Screen
                Get.back();

                // Navigate back to WalletScreen (pop TransactionConfirmation and TransferMoney screens)
                // This will pop exactly 2 screens: TransactionConfirmationScreen and TransferMoneyScreen
                // int poppedCount = 0;
                // Get.until((route) {
                //   if (poppedCount < 2) {
                //     poppedCount++;
                //     return false; // Keep popping
                //   }
                //   return true; // Stop popping, we're now at WalletScreen
                // });

                // Show success message
                Fluttertoast.showToast(
                  msg: "Transaction successful!",
                  backgroundColor: Colors.green,
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
            barrierDismissible: false,
          );

        } else if (transferResponse.respCode == 'ERR') {
          // Error
          ConsoleLog.printError("Transfer Error: ${transferResponse.respDesc}");

          showConfirmation.value = false;
          confirmationData.value = null;

          // Use Get.dialog instead of CustomDialog to avoid context issues
          Get.dialog(
            WillPopScope(
              onWillPop: () async {
                // Ensure we go back to the right screen
                return true;
              },
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Transfer Failed',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  transferResponse.respDesc ?? "Transaction failed",
                  style: GoogleFonts.albertSans(fontSize: 14, color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      // Go back to Transfer Money screen (close confirmation screen too)
                      Get.back();
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0054D3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Unexpected response
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Unexpected Response',
                style: GoogleFonts.albertSans(fontWeight: FontWeight.w600, color: Colors.black),
              ),
              content: Text(
                transferResponse.respDesc ?? "Unexpected response from server",
                style: GoogleFonts.albertSans(fontSize: 14, color: Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('OK', style: GoogleFonts.albertSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                ),
              ],
            ),
          );
        }
      } else {
        // No response
        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Connection Error', style: GoogleFonts.albertSans(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
            content: Text('No response from server', style: GoogleFonts.albertSans(
              color: Colors.black,
            )),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK', style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                )),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // ✅ Safely hide loading
      try {
        if (context.mounted) {
          CustomLoading().hide(context);
        }
      } catch (hideError) {
        ConsoleLog.printWarning("Could not hide loading: $hideError");
      }
      ConsoleLog.printError("INITIATE TRANSFER ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
      // Use Get.dialog for error
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Error', style: GoogleFonts.albertSans(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          )),
          content: Text('Technical issue occurred. Please try again.',
            style: GoogleFonts.albertSans(
              color: Colors.black,
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK', style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  // String _applyA4ReceiptMargins(String html) {
  //   const css = '''
  // <style>
  //   @page { size: A4; margin: 12mm 10mm; }  /* 👈 A4 margins */
  //   html, body { width: 100%; }
  //   * { box-sizing: border-box; }
  //   body { margin: 0; padding: 0; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  //   .receipt-page { padding: 8mm; }        /* 👈 inner padding */
  //   table { width: 100% !important; max-width: 100% !important; border-collapse: collapse; }
  // </style>
  // ''';
  //
  //   // If full HTML exists, inject CSS into <head>
  //   if (html.contains('</head>')) {
  //     html = html.replaceFirst('</head>', '$css</head>');
  //   } else if (html.toLowerCase().contains('<html')) {
  //     html = html.replaceFirst(RegExp(r'(<html[^>]*>)', caseSensitive: false), r'$1<head>' + css + r'</head>');
  //   } else {
  //     // If server sends only fragment, wrap it
  //     html = '<html><head>$css</head><body>$html</body></html>';
  //   }
  //
  //   // Add wrapper padding inside body
  //   if (html.toLowerCase().contains('<body')) {
  //     html = html.replaceFirst(RegExp(r'(<body[^>]*>)', caseSensitive: false), r'$1<div class="receipt-page">');
  //     html = html.replaceFirst(RegExp(r'(</body>)', caseSensitive: false), r'</div>$1');
  //   }
  //
  //   return html;
  // }


// ============================================
// PRINT RECEIPT
// ============================================
  Future<void> printReceipt(BuildContext context, String txnId) async {
    BuildContext? currentContext = context;
    bool shouldHideLoading = true;
    try {
      if (txnId.isEmpty) {
        Fluttertoast.showToast(
          msg: "Transaction ID not found",
          backgroundColor: Colors.red,
        );
        return;
      }

      if (currentContext.mounted) {
        _showExternalSafeLoader(currentContext);
      }

      // API Call - Fetch/TxnReceipt
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "request_type": "DOWNLOAD",
        "txndata": [txnId], // Array format mandatory
      };

      ConsoleLog.printColor("GET RECEIPT API CALL");
      ConsoleLog.printInfo("Request: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_RECEIPT, // Fetch/TxnReceipt
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (currentContext.mounted) {
        _hideExternalSafeLoader();
        shouldHideLoading = false;
      }

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        ConsoleLog.printSuccess("Response Code: ${data['Resp_code']}");

        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          String htmlContent = data['data'].toString();

          ConsoleLog.printSuccess("HTML received (${htmlContent.length} chars)");

          // Convert HTML to PDF
          await convertHtmlToPdfAndSave(context, htmlContent, txnId);

        } else {
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Receipt not found",
          );
        }
      } else {
        CustomDialog.error(
          context: context,
          message: "Failed to get receipt from server",
        );
      }
    } catch (e) {
      if (shouldHideLoading && currentContext != null && currentContext.mounted) {
        _hideExternalSafeLoader();
      }
      ConsoleLog.printError("PRINT RECEIPT ERROR: $e");
      CustomDialog.error(
        context: context,
        message: "Error: ${e.toString()}",
      );
    }finally {
      // ✅ Extra safety to hide loading
      try {
        if (shouldHideLoading && currentContext != null && currentContext.mounted) {
          _hideExternalSafeLoader();
        }
      } catch (e) {
        ConsoleLog.printWarning("Error in finally block: $e");
      }
    }
  }

// ============================================
// CONVERT HTML TO PDF & SAVE
// ============================================
  Future<void> convertHtmlToPdfAndSave(
      BuildContext context, String htmlContent, String txnId) async {
    BuildContext? currentContext = context;
    bool shouldHideLoading = true;
    try {
      ConsoleLog.printInfo("Starting HTML to PDF conversion...");

      // Show loading
      if (currentContext.mounted) {
        _showExternalSafeLoader(currentContext);
      }

      // Storage permission (only needed when saving to public Downloads on Android)
      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.manageExternalStorage.request();

        // Fallback for devices / targets where manageExternalStorage isn't granted
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: "Storage permission required to save PDF in Downloads",
            backgroundColor: Colors.orange,
          );
          await openAppSettings();
          return;
        }
      }

      // CustomLoading().show(context);

      //Get directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Try Downloads folder first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          ConsoleLog.printWarning(" Downloads folder not accessible");
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String targetPath = directory!.path;
      String fileName = "Payrupya_Receipt_$txnId";

      ConsoleLog.printInfo("Target: $targetPath");
      ConsoleLog.printInfo("File: $fileName.pdf");

      htmlContent = applyA4ReceiptMargins(htmlContent);
      // Convert HTML to PDF using flutter_native_html_to_pdf
      final generatedPdfFile = await _htmlToPdf.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: targetPath,
        targetName: fileName,
        pageSize: PdfPageSize.a4, // optional
      );

      if (currentContext.mounted) {
        _hideExternalSafeLoader();
        shouldHideLoading = false; // Already hidden
      }

      if (generatedPdfFile != null && await generatedPdfFile.exists()) {
        ConsoleLog.printSuccess("PDF Generated!");
        ConsoleLog.printSuccess("Path: ${generatedPdfFile.path}");

        Fluttertoast.showToast(
          msg: "Receipt saved to Downloads",
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );

        //Open/Share PDF
        // try {
        //   // await Printing.sharePdf(
        //   //   bytes: await generatedPdfFile.readAsBytes(),
        //   //   filename: "$fileName.pdf",
        //   // );
        //   OpenFilex.open(generatedPdfFile.path).then((result) {
        //     ConsoleLog.printInfo("OpenFile result: ${result.message}");
        //
        //     if (result.type != ResultType.done) {
        //       Fluttertoast.showToast(
        //         msg: "Receipt saved at: ${Platform.isAndroid ? 'Downloads' : 'Documents'}",
        //         toastLength: Toast.LENGTH_LONG,
        //       );
        //     }
        //   // final result = await OpenFilex.open(generatedPdfFile.path);
        //   }).catchError((openError) {
        //     ConsoleLog.printWarning("Could not open PDF: $openError");
        //     Fluttertoast.showToast(
        //       msg: "Receipt saved at: ${Platform.isAndroid ? 'Downloads' : 'Documents'}",
        //       toastLength: Toast.LENGTH_LONG,
        //     );
        //   });
        // } catch (openError) {
        //   ConsoleLog.printWarning("Could not open PDF: $openError");
        //
        //   Fluttertoast.showToast(
        //     msg: "Receipt saved at: ${Platform.isAndroid ? 'Downloads' : 'Documents'}",
        //     toastLength: Toast.LENGTH_LONG,
        //   );
        // }
        try {
          // ✅ Use Future.delayed to ensure loading is hidden before opening PDF
          await Future.delayed(Duration(milliseconds: 100));

          _pendingExternalReturnCleanup = true;

          final openResult = await OpenFilex.open(generatedPdfFile.path);

          ConsoleLog.printInfo("OpenFile result: ${openResult.message}");

          if (openResult.type != ResultType.done) {
            Fluttertoast.showToast(
              msg: "Receipt saved at: ${Platform.isAndroid ? 'Downloads' : 'Documents'}",
              toastLength: Toast.LENGTH_LONG,
            );
          }

        } catch (openError) {
          ConsoleLog.printWarning("Could not open PDF: $openError");
          Fluttertoast.showToast(
            msg: "Receipt saved at: ${Platform.isAndroid ? 'Downloads' : 'Documents'}",
            toastLength: Toast.LENGTH_LONG,
          );
        }

      } else {
        throw Exception("PDF generation failed");
      }

    } catch (e) {
      if (shouldHideLoading && currentContext.mounted) {
        _hideExternalSafeLoader();
      }

      Fluttertoast.showToast(
        msg: "Failed to generate PDF: ${e.toString()}",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );

    } finally {
      // ✅ EXTRA SAFETY: Always try to hide loading in finally block
      try {
        if (shouldHideLoading && currentContext.mounted) {
          _hideExternalSafeLoader();
        }
      } catch (e) {
        ConsoleLog.printWarning("Error in finally block: $e");
      }
    }
  }

// ============================================
// ONLY PDF TO WHATSAPP (NO TEXT)
// ============================================
  Future<void> shareToWhatsApp(
      BuildContext context, String txnId, String mobileNumber) async {
    try {
      BuildContext? dialogContext = context;

      if (txnId.isEmpty) {
        Fluttertoast.showToast(
          msg: "Transaction ID not found",
          backgroundColor: Colors.red,
        );
        return;
      }

      if (mobileNumber.isEmpty) {
        Fluttertoast.showToast(
          msg: "Mobile number not found",
          backgroundColor: Colors.red,
        );
        return;
      }

      _showExternalSafeLoader(context);

      // Fetch receipt HTML from API
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "request_type": "DOWNLOAD",
        "txndata": [txnId],
      };

      ConsoleLog.printColor("GET RECEIPT FOR WHATSAPP SHARE");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_RECEIPT,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (dialogContext.mounted) {
        _hideExternalSafeLoader();
      }

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          final htmlContent = data['data'].toString();

          // Convert HTML -> PDF in PUBLIC directory
          Directory? directory;
          if (Platform.isAndroid) {
            // Storage permission check
            PermissionStatus status = await Permission.manageExternalStorage.request();
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }

            if (!status.isGranted) {
              Fluttertoast.showToast(
                msg: "Storage permission required",
                backgroundColor: Colors.orange,
              );
              await openAppSettings();
              return;
            }

            // Save to Downloads
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              directory = await getExternalStorageDirectory();
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          final fileName = "Payrupya_Receipt_$txnId";
          final targetPath = directory!.path;

          // Apply A4 margins
          final fixedHtml = applyA4ReceiptMargins(htmlContent);

          _showExternalSafeLoader(context);

          // Generate PDF
          final pdfFile = await _htmlToPdf.convertHtmlToPdf(
            html: fixedHtml,
            targetDirectory: targetPath,
            targetName: fileName,
            pageSize: PdfPageSize.a4,
          );

          if (context.mounted) {
            _hideExternalSafeLoader();
          }

          if (pdfFile != null && await pdfFile.exists()) {
            ConsoleLog.printSuccess("PDF generated: ${pdfFile.path}");

            // Format mobile number for WhatsApp
            String formattedNumber = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');

            // Add country code if not present (assuming India +91)
            if (formattedNumber.length == 10) {
              formattedNumber = '91$formattedNumber';
            }

            ConsoleLog.printInfo("Formatted Number: $formattedNumber");
            ConsoleLog.printInfo("PDF Path: ${pdfFile.path}");

            try {
              //SOLUTION: Share ONLY PDF file without any text
              // Remove text parameter completely - this will share only the file
              _pendingExternalReturnCleanup = true;
              Share.shareXFiles(
                [XFile(pdfFile.path, mimeType: "application/pdf")],
              ).then((result) {
                if (result.status == ShareResultStatus.success) {
                  ConsoleLog.printSuccess("✅ PDF shared successfully");
                  Fluttertoast.showToast(
                    msg: "Receipt shared successfully",
                    backgroundColor: Colors.green,
                  );
                } else if (result.status == ShareResultStatus.dismissed) {
                  ConsoleLog.printInfo("Share dismissed by user");
                }
              }).catchError((shareError) {
                ConsoleLog.printError("Share error: $shareError");
                Fluttertoast.showToast(
                  msg: "Failed to share PDF",
                  backgroundColor: Colors.red,
                );
              });
            } catch (shareError) {
              ConsoleLog.printError("Share error: $shareError");
              Fluttertoast.showToast(
                msg: "Failed to share PDF",
                backgroundColor: Colors.red,
              );
            }

          } else {
            Fluttertoast.showToast(
              msg: "PDF generation failed",
              backgroundColor: Colors.red,
            );
          }

        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to get receipt",
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to fetch receipt",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      try {
        if (context.mounted) {
          _hideExternalSafeLoader();
        }
      } catch (hideError) {
        ConsoleLog.printWarning("Could not hide loading: $hideError");
      }
      ConsoleLog.printError("SHARE ERROR: $e");
      Fluttertoast.showToast(
        msg: "Failed to share: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    }
  }

  String applyA4ReceiptMargins(String html) {
    const css = '''
  <style>
    @page { size: A4; margin: 12mm 10mm; }
    html, body { width: 100%; }
    * { box-sizing: border-box; }
    body { margin: 0; padding: 0; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .receipt-page { padding: 8mm; }
    table { width: 100% !important; max-width: 100% !important; border-collapse: collapse; }
  </style>
  ''';

    // Inject CSS into HTML
    if (html.contains('</head>')) {
      html = html.replaceFirst('</head>', '$css</head>');
    } else if (html.toLowerCase().contains('<html')) {
      html = html.replaceFirst(
          RegExp(r'(<html[^>]*>)', caseSensitive: false),
          r'$1<head>' + css + r'</head>');
    } else {
      html = '<html><head>$css</head><body>$html</body></html>';
    }

    // Add wrapper padding
    if (html.toLowerCase().contains('<body')) {
      html = html.replaceFirst(
          RegExp(r'(<body[^>]*>)', caseSensitive: false),
          r'$1<div class="receipt-page">');
      html = html.replaceFirst(
          RegExp(r'(</body>)', caseSensitive: false), r'</div>$1');
    }

    return html;
  }



  // Show confirmation dialog with charges
  // void showTransferConfirmationDialog(BuildContext context, BeneficiaryData beneficiary, ConfirmTransferData charges) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Confirm Transfer'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Beneficiary: ${beneficiary.name}'),
  //             Text('Account: ${beneficiary.accountNo}'),
  //             Text('Bank: ${beneficiary.bankName}'),
  //             SizedBox(height: 16),
  //             Text('Amount: ₹${charges.trasamt}'),
  //             Text('Charged Amount: ₹${charges.chargedamt}'),
  //             // Text('Charges: ₹${charges.totalcharge}'),
  //             Text('Total Charge: ₹${(charges.totalcharge)}'),
  //             SizedBox(height: 16),
  //             TextField(
  //               controller: tpinController.value,
  //               keyboardType: TextInputType.number,
  //               obscureText: true,
  //               maxLength: 4,
  //               decoration: InputDecoration(
  //                 labelText: 'Enter TPIN',
  //                 counterText: '',
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               confirmationData.value = null;
  //               showConfirmation.value = false;
  //               Get.back();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Get.back();
  //               initiateTransfer(context);
  //             },
  //             child: Text('Confirm'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // // Show success dialog
  // void showTransferSuccessDialog(BuildContext context, Map<String, dynamic>? data) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         title: Icon(Icons.check_circle, color: Colors.green, size: 60),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Transfer Successful!',
  //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //             SizedBox(height: 16),
  //             Text('Amount: ₹${data?['amount'] ?? transferAmountController.value.text}'),
  //             Text('UTR: ${data?['utr'] ?? "N/A"}'),
  //             Text('Transaction ID: ${data?['txn_id'] ?? "N/A"}'),
  //             if (data?['txn_desc'] != null)
  //               Text('Status: ${data!['txn_desc']}'),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Get.back();
  //               Get.back(); // Go back to beneficiary list
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // ============================================
  // 9. SEARCH TRANSACTION - ✅ NEW
  // ============================================
  Future<void> searchTransaction(BuildContext context, String txnId) async {
    try {
      if (txnId.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter transaction ID");
        return;
      }

      if (senderId.value.isEmpty || senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "senderid": senderId.value,
        "sender": senderMobileNo.value,
        "request_type": "SEARCH TXN",
        "service": serviceCode.value,
        "txnid": txnId,
      };

      ConsoleLog.printColor("SEARCH TXN REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        "${WebApiConstant.BASE_URL}Fetch/search_txn",
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide(context);

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'RCS') {
          // Show transaction details
          showTransactionDetailsDialog(context, data['data']);
        } else {
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Transaction not found",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide(context);
      ConsoleLog.printError("SEARCH TRANSACTION ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  void showTransactionDetailsDialog(BuildContext context, Map<String, dynamic> txnData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction ID: ${txnData['txn_id']}'),
              Text('Amount: ₹${txnData['amount']}'),
              Text('Status: ${txnData['status']}'),
              Text('UTR: ${txnData['utr'] ?? "N/A"}'),
              Text('Date: ${txnData['created_at']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Close', style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  // // ============================================
  // // 9. GET ALL BANKS LIST
  // // ============================================
  // Future<void> getAllBanks(BuildContext context) async {
  //   try {
  //     if (loginController.latitude.value == 0.0 || loginController.longitude.value == 0.0) {
  //       ConsoleLog.printInfo("Latitude: ${loginController.latitude.value}");
  //       ConsoleLog.printInfo("Longitude: ${loginController.longitude.value}");
  //       return;
  //     }
  //     Map<String, dynamic> body = {
  //       "request_id": generateRequestId(),
  //       "lat": loginController.latitude.value.toString(),
  //       "long": loginController.longitude.value.toString(),
  //     };
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_GET_ALL_BANKS,
  //       body,
  //       userAuthToken.value,
  //       userSignature.value,
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       GetAllBanksResponseModel banksResponse =
  //           GetAllBanksResponseModel.fromJson(response.data);
  //
  //       if (banksResponse.respCode == "RCS" && banksResponse.data != null) {
  //         banksList.value = banksResponse.data!;
  //         ConsoleLog.printSuccess("Banks loaded: ${banksList.length}");
  //       }
  //     }
  //   } catch (e) {
  //     ConsoleLog.printError("GET ALL BANKS ERROR: $e");
  //   }
  // }

  // ============================================
  // 10. GET ALL BANKS LIST - ✅ CORRECT
  // ============================================
  Future<void> getAllBanks(BuildContext context) async {
    try {
      if (loginController.latitude.value == 0.0 || loginController.longitude.value == 0.0) {
        ConsoleLog.printInfo("Latitude: ${loginController.latitude.value}");
        ConsoleLog.printInfo("Longitude: ${loginController.longitude.value}");
        return;
      }
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_ALL_BANKS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        GetAllBanksResponseModel banksResponse =
        GetAllBanksResponseModel.fromJson(response.data);

        if (banksResponse.respCode == "RCS" && banksResponse.data != null) {
          banksList.value = banksResponse.data!;
          ConsoleLog.printSuccess("Banks loaded: ${banksList.length}");
        }
      }
    } catch (e) {
      ConsoleLog.printError("GET ALL BANKS ERROR: $e");
    }
  }

  // ============================================
  // 11. SEARCH BENEFICIARIES
  // ============================================
  // void searchBeneficiaries(String query) {
  //   searchQuery.value = query.toLowerCase();
  //
  //   if (query.isEmpty) {
  //     filteredBeneficiaryList.value = beneficiaryList;
  //   } else {
  //     filteredBeneficiaryList.value = beneficiaryList.where((bene) {
  //       return (bene.name?.toLowerCase().contains(query) ?? false) ||
  //           (bene.name?.toUpperCase().contains(query) ?? false) ||
  //           (bene.accountNo?.contains(query) ?? false) ||
  //           (bene.bankName?.toLowerCase().contains(query) ?? false) ||
  //           (bene.bankName?.toUpperCase().contains(query) ?? false);
  //     }).toList();
  //   }
  //
  //   // Current sort after search
  //   applySortOption(currentSortOption.value);
  // }
  void searchBeneficiaries(String query) {
    // Store original query (not converted)
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredBeneficiaryList.value = beneficiaryList;
    } else {
      // Convert query to lowercase ONCE for comparison
      String lowerQuery = query.toLowerCase();

      filteredBeneficiaryList.value = beneficiaryList.where((bene) {
        // Convert each field to lowercase and compare
        bool nameMatch = (bene.name?.toLowerCase().contains(lowerQuery) ?? false);
        bool accountMatch = (bene.accountNo?.contains(query) ?? false); // Account numbers are exact
        bool bankMatch = (bene.bankName?.toLowerCase().contains(lowerQuery) ?? false);
        bool ifscMatch = (bene.ifsc?.toLowerCase().contains(lowerQuery) ?? false);

        return nameMatch || accountMatch || bankMatch || ifscMatch;
      }).toList();
    }

    // Apply current sort after search
    applySortOption(currentSortOption.value);
  }

  // ============================================
  // 12. SORT BENEFICIARIES
  // ============================================
  void sortBeneficiaries(BeneficiarySortOption option) {
    currentSortOption.value = option;
    applySortOption(option);

    // Update sort label
    switch (option) {
      case BeneficiarySortOption.recent:
        currentSortLabel.value = 'Recently Added';
        break;
      case BeneficiarySortOption.nameAsc:
        currentSortLabel.value = 'Name A-Z';
        break;
      case BeneficiarySortOption.nameDesc:
        currentSortLabel.value = 'Name Z-A';
        break;
      case BeneficiarySortOption.bankAsc:
        currentSortLabel.value = 'Bank A-Z';
        break;
      case BeneficiarySortOption.bankDesc:
        currentSortLabel.value = 'Bank Z-A';
        break;
    }
  }

  void applySortOption(BeneficiarySortOption option) {
    List<BeneficiaryData> listToSort = List.from(filteredBeneficiaryList);

    switch (option) {
      case BeneficiarySortOption.recent:
        listToSort.sort((a, b) =>
            (b.updatedOn ?? '').compareTo(a.updatedOn ?? '')
        );
        break;

      case BeneficiarySortOption.nameAsc:
        listToSort.sort((a, b) =>
            (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.nameDesc:
        listToSort.sort((a, b) =>
            (b.name ?? '').toLowerCase().compareTo((a.name ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.bankAsc:
        listToSort.sort((a, b) =>
            (a.bankName ?? '').toLowerCase().compareTo((b.bankName ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.bankDesc:
        listToSort.sort((a, b) =>
            (b.bankName ?? '').toLowerCase().compareTo((a.bankName ?? '').toLowerCase())
        );
        break;
    }

    filteredBeneficiaryList.value = listToSort;
  }

  // ============================================
  // 13. SHOW SORT OPTIONS DIALOG
  // ============================================
  void showSortOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1B1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Obx(() => Column(
                  children: [
                    buildSortOption(
                      context,
                      'Recently Added',
                      Icons.access_time,
                      BeneficiarySortOption.recent,
                      currentSortOption.value == BeneficiarySortOption.recent,
                    ),
                    buildSortOption(
                      context,
                      'Name A-Z',
                      Icons.sort_by_alpha,
                      BeneficiarySortOption.nameAsc,
                      currentSortOption.value == BeneficiarySortOption.nameAsc,
                    ),
                    buildSortOption(
                      context,
                      'Name Z-A',
                      Icons.sort_by_alpha,
                      BeneficiarySortOption.nameDesc,
                      currentSortOption.value == BeneficiarySortOption.nameDesc,
                    ),
                    buildSortOption(
                      context,
                      'Bank A-Z',
                      Icons.account_balance,
                      BeneficiarySortOption.bankAsc,
                      currentSortOption.value == BeneficiarySortOption.bankAsc,
                    ),
                    buildSortOption(
                      context,
                      'Bank Z-A',
                      Icons.account_balance,
                      BeneficiarySortOption.bankDesc,
                      currentSortOption.value == BeneficiarySortOption.bankDesc,
                    ),
                  ],
                )),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSortOption(
      BuildContext context,
      String label,
      IconData icon,
      BeneficiarySortOption option,
      bool isSelected,
      ) {
    return InkWell(
      onTap: () {
        sortBeneficiaries(option);
        Get.back();
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE3F2FD) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF0054D3) : Colors.grey[600],
              size: 22,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Color(0xFF0054D3) : Color(0xff1B1C1C),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Color(0xFF0054D3),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 11. GET ALL BENEFICIARY DETAILS
  // ============================================

  Future<void> getAllBeneficiaryDetails(
      BuildContext context,
      {int start = 0, int limit = 100, String searchBy = ""}
      ) async {
    Map<String, dynamic> body = {
      "request_id": generateRequestId(),
      "lat": loginController.latitude.value.toString(),
      "long": loginController.longitude.value.toString(),
      "start": start.toString(),
      "limit": limit.toString(),
      "searchby": searchBy,
    };

    var response = await ApiProvider().requestPostForApi(
      context,
      WebApiConstant.API_URL_GET_ALL_BENEFICIARY_DETAILS,
      body,
      userAuthToken.value,
      userSignature.value,
    );

    if (response != null && response.statusCode == 200) {
    }
  }

  // // ============================================
  // // SHOW SUCCESS DIALOG
  // // ============================================
  // void showSuccessDialog(BuildContext context, TransferData? data) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         title: Icon(Icons.check_circle, color: Colors.green, size: 60),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Transfer Successful!',
  //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //             SizedBox(height: 16),
  //             Text('Amount: ₹${data?.amount}'),
  //             Text('UTR: ${data?.utr ?? "N/A"}'),
  //             Text('Transaction ID: ${data?.txnId}'),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Get.back();
  //               Get.back();
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void onClose() {
    senderMobileController.value.dispose();
    senderNameController.value.dispose();
    senderAddressController.value.dispose();
    senderPincodeController.value.dispose();
    senderOtpController.value.dispose();
    beneNameController.value.dispose();
    beneAccountController.value.dispose();
    beneIfscController.value.dispose();
    beneMobileController.value.dispose();
    transferAmountController.value.dispose();
    transferModeController.value.dispose();
    txnPinController.value.dispose();
    // tpinController.value.dispose();
    deleteOtpController.value.dispose();
    super.onClose();
  }
}
