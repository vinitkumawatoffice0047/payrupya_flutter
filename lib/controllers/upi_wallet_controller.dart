import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/add_beneficiary_response_model.dart';
import '../models/add_sender_response_model.dart';
import '../models/add_sender_upi_response_model.dart';
import '../models/check_sender_response_model.dart' hide SenderData;
import '../models/check_sender_upi_response_model.dart';
import '../models/confirm_transfer_response_model.dart';
import '../models/delete_beneficiary_response_model.dart';
import '../models/get_all_banks_response_model.dart';
import '../models/get_allowed_service_by_type_response_model.dart';
import '../models/get_beneficiary_list_response_model.dart';
import '../models/get_beneficiary_list_upi_response_model.dart';
import '../models/transfer_money_response_model.dart';
import '../models/verify_upi_vpa_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';
import '../utils/transfer_success_dialog.dart';
import '../utils/transfer_success_dialog_upi.dart';
import '../view/onboarding_screen.dart';
import '../view/transaction_confirmation_upi_screen.dart';
import 'login_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart'; // optional

//region BeneficiarySortOption enum
enum BeneficiarySortOption {
  nameAsc,      // A to Z
  nameDesc,     // Z to A
  vpaAsc,       // VPA A to Z
  vpaDesc       // VPA A to Z
  // bankAsc,      // Bank A to Z
  // bankDesc,     // Bank Z to A
  // recent,       // Recently Added (if having any timestamp)
}
//endregion

class UPIWalletController extends GetxController {
  static const String _kExternalLoaderRouteName = '__dmt_external_loader__';
  bool externalLoaderVisible = false;
  bool pendingExternalReturnCleanup = false;

  // Payment Mode & VPA
  RxString selectedPaymentMode = 'Phonepay'.obs;
  RxString selectedVPA = ''.obs;
  RxBool verifyButton = false.obs;

  // VPA Providers Map
  Map<String, List<String>> vpaProviders = {
    'Paytm': ['paytm', 'ptyes'],
    'Googlepay': ['okaxis', 'oksbi', 'okhdfcbank'],
    'Phonepe': ['ybl', 'ibl', 'axl'],
  };

  //region getVPAListForMode
  List<String> getVPAListForMode(String mode) {
    return vpaProviders[mode] ?? [];
  }

  //region showExternalSafeLoader
  void showExternalSafeLoader(BuildContext context) {
    if (externalLoaderVisible) return;
    externalLoaderVisible = true;

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
  //endregion

  //region hideExternalSafeLoader
  void hideExternalSafeLoader() {
    if (!externalLoaderVisible) return;

    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    // Pop only our loader dialog route (if it is on top).
    Navigator.of(ctx, rootNavigator: true)
        .popUntil((route) => route.settings.name != _kExternalLoaderRouteName);

    externalLoaderVisible = false;
  }
  //endregion

  //region forceHideExternalSafeLoader
  void forceHideExternalSafeLoader() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx != null) {
      Navigator.of(ctx, rootNavigator: true)
          .popUntil((route) => route.settings.name != _kExternalLoaderRouteName);
    }
    externalLoaderVisible = false;
  }
  //endregion

  LoginController loginController = Get.put(LoginController());
  final FlutterNativeHtmlToPdf htmlToPdf = FlutterNativeHtmlToPdf();

  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;
  RxString checkSenderRespCode = "".obs;

  //region onInit
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
  //endregion

  //region didChangeAppLifecycleState
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from an external intent (PDF viewer / WhatsApp share),
    // make sure our loading dialog is not stuck on screen.
    if (state == AppLifecycleState.resumed && pendingExternalReturnCleanup) {
      pendingExternalReturnCleanup = false;
      forceHideExternalSafeLoader();
    }
  }
  //endregion

  //region checkAndLoadService
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

  // Text Controllers
  Rx<TextEditingController> senderMobileController = TextEditingController().obs;
  Rx<TextEditingController> senderNameController = TextEditingController().obs;
  Rx<TextEditingController> senderAddressController = TextEditingController().obs;
  Rx<TextEditingController> senderPincodeController = TextEditingController().obs;
  Rx<TextEditingController> senderCityController = TextEditingController().obs;
  Rx<TextEditingController> senderStateController = TextEditingController().obs;
  Rx<TextEditingController> senderOtpController = TextEditingController().obs;

  Rx<TextEditingController> beneNameController = TextEditingController().obs;
  Rx<TextEditingController> beneVPAController = TextEditingController().obs;
  Rx<TextEditingController> upiMobileController = TextEditingController().obs;
  RxBool isVPAVerified = false.obs;
  Rx<TextEditingController> beneAccountController = TextEditingController().obs;
  Rx<TextEditingController> beneIfscController = TextEditingController().obs;
  Rx<TextEditingController> beneMobileController = TextEditingController().obs;
  Rx<TextEditingController> transferAmountController = TextEditingController().obs;
  Rx<TextEditingController> transferConfirmAmountController = TextEditingController().obs;
  Rx<TextEditingController> transferModeController = TextEditingController().obs;
  Rx<TextEditingController> txnPinController = TextEditingController().obs;
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
  RxList<BeneficiaryUPIData> beneficiaryList = <BeneficiaryUPIData>[].obs;
  RxList<BeneficiaryUPIData> filteredBeneficiaryList = <BeneficiaryUPIData>[].obs;

  // Banks List
  RxList<BankData> banksList = <BankData>[].obs;

  // Search
  RxString searchQuery = ''.obs;
  Rx<BeneficiarySortOption> currentSortOption = BeneficiarySortOption.nameAsc.obs;
  RxString currentSortLabel = 'Name A-Z'.obs;
  // Rx<BeneficiarySortOption> currentSortOption = BeneficiarySortOption.recent.obs;
  // RxString currentSortLabel = 'Recently Added'.obs;

  RxString serviceCode = ''.obs;
  RxBool isServiceLoaded = false.obs;

  // Transfer Confirmation Data
  Rx<Map<String, dynamic>?> confirmationData = Rx<Map<String, dynamic>?>(null);
  RxBool showConfirmation = false.obs;

  final GlobalKey<OtpInputFieldsState> deleteOtpKey = GlobalKey<OtpInputFieldsState>();

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
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
    await AppSharedPreferences.clearSessionOnly();
    Get.offAll(() => OnboardingScreen());
    Fluttertoast.showToast(msg: "Session expired. Please login again.");
  }
  //endregion

  //region getAllowedServiceByType
  Future<void> getAllowedServiceByType(BuildContext context) async {
    try {
      if (loginController.latitude.value == 0.0 || loginController.longitude.value == 0.0) {
        ConsoleLog.printInfo("Latitude: ${loginController.latitude.value}");
        ConsoleLog.printInfo("Longitude: ${loginController.longitude.value}");
        return;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      CustomLoading.showLoading();

      isServiceLoaded.value = false;

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value,
        "long": loginController.longitude.value,
        "type": "REMITTANCE"
      };

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_SERVICE_TYPE,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("Get Allowed Service By Type Api Request: ${jsonEncode(body)}", color: "yellow");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("GET ALLOWED SERVICE RESP: ${jsonEncode(response.data)}");

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
            CustomLoading.hideLoading();
          } else if (apiResponse.data![0].serviceCode != null) {
            // Fallback to first service
            serviceCode.value = apiResponse.data![0].serviceCode!;
            ConsoleLog.printSuccess("✅ Using first service: ${serviceCode.value}");
            CustomLoading.hideLoading();
          } else {
            ConsoleLog.printWarning("⚠️ Using default service code: DMTRZP");
            CustomLoading.hideLoading();
          }

          isServiceLoaded.value = true;

          // ✅ Debug: Print all services
          ConsoleLog.printInfo("=== Available Services ===");
          for (var service in apiResponse.data!) {
            ConsoleLog.printInfo("${service.serviceName} (${service.serviceCode}) - ${service.serviceType}");
          }
        } else {
          ConsoleLog.printWarning("⚠️ No services found or empty response");
          CustomLoading.hideLoading();
        }
      } else {
        ConsoleLog.printError("❌ API Error: ${response?.statusCode}");
      }
    } catch (e) {
      ConsoleLog.printError("❌ GET ALLOWED SERVICE ERROR: $e");
    }
  }
  //endregion

  //region checkSender
  Future<void> checkSenderUPI(BuildContext context, String mobile) async {
    try {
      // ✅ Validate token first
      if (!await isTokenValid()) {
        await refreshToken(context);
        return;
      }

      if (mobile.isEmpty || mobile.length != 10) {
        Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number",
          gravity: ToastGravity.TOP,
        );
        return;
      }

      // Wait for service code if empty
      if (serviceCode.value.isEmpty) {
        ConsoleLog.printWarning("Service code not loaded, waiting...");
        Fluttertoast.showToast(
          msg: "Please wait, initializing services...",
          backgroundColor: Colors.orange,
          gravity: ToastGravity.TOP,
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
            gravity: ToastGravity.TOP,
          );
          return;
        }
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": mobile,
        "service": "UPI",
        "request_type": "CHECK REMITTER",
      };

      ConsoleLog.printColor("CHECK SENDER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_CHECK_SENDER_UPI,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response == null) {
        CustomDialog.error(message: "No response from server");
        return;
      }

      ConsoleLog.printColor("CHECK SENDER RESPONSE: ${response?.data}");

      if (response.statusCode == 200) {
        CustomLoading.hideLoading();
        CheckSenderUPIResponseModel checkSenderResponse =
        CheckSenderUPIResponseModel.fromJson(response.data);

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
          Fluttertoast.showToast(msg: "Sender verified successfully", gravity: ToastGravity.TOP);

          // Fetch beneficiary list
          await getBeneficiaryList(context, mobile);

        } else if (checkSenderResponse.respCode == "RNF") {
          // Sender not found - need to register
          currentSender.value = checkSenderResponse.data;
          isSenderVerified.value = false;

          // Store identifier from response (needed for registration)
          identifier.value = checkSenderResponse.data?.identifier ?? '';

          ConsoleLog.printWarning("Sender not found");
          Fluttertoast.showToast(msg: "Please register sender first", gravity: ToastGravity.TOP);

        } else if (checkSenderResponse.respCode == "ERR") {
          ConsoleLog.printError("Error: ${checkSenderResponse.respDesc}");

          if (checkSenderResponse.respDesc?.toLowerCase().contains('unauthorized') ?? false) {
            // Token is invalid
            await refreshToken(context);
          } else {
            CustomDialog.error(
              message: checkSenderResponse.respDesc ?? "Failed to check sender",
            );
          }
        } else {
          CustomDialog.error(
            message: checkSenderResponse.respDesc ?? "Unexpected response",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("CHECK SENDER ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region addSender
  Future<void> addSenderUPI(BuildContext context, String otp) async {
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

      // if (identifier.value.isEmpty) {
      //   Fluttertoast.showToast(msg: "Identifier not found. Please check sender first.");
      //   return;
      // }

      if (selectedState.value.isEmpty || selectedCity.value.isEmpty || selectedPincode.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please select state, city and pincode");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": mobile,
        "service": "UPI",
        "request_type": "REMITTER REGISTRATION",
        "identifier": identifier.value,
        "sender_otp": otp,
        "sender_name": name,
        "sender_address": address,
        "sender_pincode": pincode,
        "sender_city": selectedCity.value,
        "sender_state": selectedState.value,
      };

      ConsoleLog.printColor("ADD SENDER UPI REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_ADD_SENDER_UPI,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("ADD SENDER UPI RESPONSE: ${jsonEncode(response?.data)}");
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
            message: "Failed to parse server response",
          );
          return;
        }
        AddSenderUPIResponseModel addSenderResponse =
        AddSenderUPIResponseModel.fromJson(responseData);
        // var data = response.data;

        if (addSenderResponse.respCode == 'RCS') {
          isSenderVerified.value = true;

          ConsoleLog.printSuccess("Sender UPI registered successfully");
          ConsoleLog.printInfo("Identifier: ${addSenderResponse.data?.senderid?.identifier}");
          Fluttertoast.showToast(msg: "Sender UPI registered successfully");

          // Clear form
          senderOtpController.value.clear();

          // Refresh sender details
          await checkSenderUPI(context, mobile);

        } else if (addSenderResponse.respCode == 'ERR') {
          String errorMsg = addSenderResponse.respDesc ?? "Failed to add sender";

          // Check if "already registered"
          if (errorMsg.toLowerCase().contains('already registered')) {
            ConsoleLog.printInfo("Sender already registered");
            Fluttertoast.showToast(msg: "You are already registered");

            // Navigate to wallet (user is verified)
            isSenderVerified.value = true;
            await checkSenderUPI(context, mobile);

          } else {
            // Real error - show error dialog
            ConsoleLog.printError("ADD SENDER UPI ERROR: $errorMsg");

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
          CustomDialog.error(message: errorMsg);
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
      CustomLoading.hideLoading();
      ConsoleLog.printError("ADD SENDER ERROR: $e");
      String errorMessage = "Technical issue occurred";
      if (e.toString().contains('not a subtype')) {
        errorMessage = "Response format error. Please try again.";
      }
      // CustomDialog.error(context: context, message: "Technical issue!");
    }
  }
  //endregion

  //region getBeneficiaryList
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

      ConsoleLog.printColor("GET BENEFICIARY LIST UPI REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_UPI_BENEFICIARY_LIST,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        GetBeneficiaryListUPIResponseModel beneListResponse =
        GetBeneficiaryListUPIResponseModel.fromJson(response.data);

        if (beneListResponse.respCode == "RCS" && beneListResponse.data != null) {
          beneficiaryList.value = beneListResponse.data!;
          filteredBeneficiaryList.value = beneListResponse.data!;

          // Current sort after loading
          applySortOption(currentSortOption.value);

          ConsoleLog.printSuccess("UPI Beneficiaries loaded: ${beneficiaryList.length}");

        } else {
          beneficiaryList.clear();
          filteredBeneficiaryList.clear();
        }
      }else if (response?.statusCode == 401) {
        await refreshToken(context);
      }
    } catch (e) {
      ConsoleLog.printError("GET BENEFICIARY LIST UPI ERROR: $e");
    }
  }
  //endregion

  //region isValidVPA
  /// UPI VPA validation
  /// Format: username@bankname
  /// Example: 9876543210@paytm, user123@ybl
  bool isValidVPA(String? vpa) {
    if (vpa == null || vpa.isEmpty) return false;

    final trimmed = vpa.trim();

    // VPA regex: alphanumeric + dots/underscores + @ + provider name
    final regExp = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');
    return regExp.hasMatch(trimmed);
  }
  //endregion

  //region verifyUPIVPA
  Future<void> verifyUPIVPA(BuildContext context) async {
    try {
      String vpa = beneVPAController.value.text.trim();
      String beneName = beneNameController.value.text.trim();

      // Validate VPA is not empty
      if (vpa.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter UPI ID");
        return;
      }

      // Validate VPA format
      if (!isValidVPA(vpa)) {
        Fluttertoast.showToast(msg: "Please enter valid UPI ID format (e.g., 9876543210@ybl)");
        return;
      }

      // Validate beneficiary name
      if (beneName.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter beneficiary name");
        return;
      }

      // Check sender details
      if (senderId.value.isEmpty || senderMobileNo.value.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      // // Show warning alert if TPIN is required
      // if (txnPin.value == "1") {
      //   bool? confirmed = await _showVerificationAlert(context);
      //   if (confirmed != true) return;
      // }

      verifyButton.value = true;
      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value,
        "long": loginController.longitude.value,
        "sender": senderMobileNo.value,
        "sendername": senderName.value,
        "reqfor": "UPIVALIDATE",
        "handleradio": selectedPaymentMode.value,
        "custom_vpa": vpa,
        "request_type": "CONFIRM",
        "vpa_mobile": vpa,
        "mode": selectedPaymentMode.value,
        "benename": beneName.isNotEmpty ? beneName : "",
        // "txnpin": "1234", // Dummy TPIN for verification
      };

      ConsoleLog.printColor("VERIFY UPI VPA REQ: ${jsonEncode(body)}");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INIT_UPI_TRANSACT_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        VerifyUPIVPAResponseModel responseModel =
        VerifyUPIVPAResponseModel.fromJson(response.data);

        ConsoleLog.printColor("VERIFY UPI VPA RESPONSE: ${jsonEncode(responseModel)}");

        if (responseModel.isSuccess) {
          // SUCCESS: Show verification charges modal
          if (responseModel.data != null) {
            ConsoleLog.printColor("Charges Summary: ${responseModel.data!.chargesSummary}");
              // await _initiateVPAVerification(context, vpa, beneName);
            await showVerificationChargesModal(
                context,
                responseModel.data!.toJson(),
                vpa,
                beneName
            );
          } else {
            verifyButton.value = false;
            CustomDialog.error(message: "Invalid response data");
          }
        } else if (responseModel.isError) {
          // ERROR: Show error message
          verifyButton.value = false;
          CustomDialog.error(message: responseModel.respDesc);
        } else {
          // ✅ Unknown response code
          verifyButton.value = false;
          CustomDialog.error(
              message: responseModel.respDesc.isNotEmpty
                  ? responseModel.respDesc
                  : "VPA verification failed"
          );
        }
      } else {
        verifyButton.value = false;
        CustomDialog.error(message: "Verification failed. Please try again.");
      }
    } catch (e) {
      CustomLoading.hideLoading();
      verifyButton.value = false;
      ConsoleLog.printError("VERIFY VPA ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region showVerificationChargesModal
  Future<void> showVerificationChargesModal(
      BuildContext context,
      Map<String, dynamic> chargesData,
      String vpa,
      String beneName,
      ) async {
    // Parse charges
    String commission = (chargesData['commission'] ?? '0').toString();
    String tds = (chargesData['tds'] ?? '0').toString();
    String totalCharge = (chargesData['totalcharge'] ?? '0').toString();
    String totalCcf = (chargesData['totalccf'] ?? '0').toString();
    String trasamt = (chargesData['trasamt'] ?? '1').toString();
    String chargedAmt = (chargesData['chargedamt'] ?? '1').toString();
    String txnPinStatus = (chargesData['txn_pin_status'] ?? '0').toString();

    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verification Charges',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0F0F0F),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () {
                        Get.back();
                        verifyButton.value = false;
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Charges Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      buildChargeRow('Total Charge', '₹$chargedAmt'),
                      buildChargeRow('Tras Amount', '₹$trasamt'),
                      buildChargeRow('Charged Amount', '₹$totalCharge'),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Info Text
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF0054D3), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This amount will be deducted for VPA verification',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Color(0xFF0054D3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          verifyButton.value = false;
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        onPressed: () async {
                          Get.back();
                          await initiateVPAVerification(context, vpa, beneName, txnPinController.value.text.trim());
                        },
                        backgroundGradient: GlobalUtils.blueBtnGradientColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        borderRadius: 12,
                        borderColor: Color(0xFF71A9FF),
                        showShadow: false,
                        elevation: 0,
                        textColor: Colors.white,
                        animation: ButtonAnimation.fade,
                        animationDuration: const Duration(milliseconds: 150),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
    );
  }
  //endregion

  //region buildChargeRow
  Widget buildChargeRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? Color(0xFF0054D3) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  //endregion

  //region initiateVPAVerification (TRANSACT Request)
  Future<void> initiateVPAVerification(
      BuildContext context,
      String vpa,
      String beneName,
      String tpin
      ) async {
    try {
      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "sendername": senderName.value,
        "reqfor": "UPIVALIDATE",
        "handleradio": selectedPaymentMode.value,
        "custom_vpa": vpa,
        "request_type": "TRANSACT", // Changed from CONFIRM to TRANSACT
        "vpa_mobile": vpa,
        "mode": selectedPaymentMode.value,
        "benename": beneName.isNotEmpty ? beneName : "",
        "txnpin": tpin,
      };

      ConsoleLog.printColor("INITIATE VPA VERIFICATION REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_INIT_UPI_TRANSACT_PROCESS,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        ConsoleLog.printColor("INITIATE VPA VERIFICATION RESP: $data");

        if (data['Resp_code'] == 'RCS') {
          String txnStatus = data['data']?['txn_status'] ?? '';
          String txnDesc = data['Resp_desc'] ?? '';
          String fetchedName = data['data']?['benename'] ?? '';

          if (txnStatus == 'SUCCESS') {
            isVPAVerified.value = true;
            verifyButton.value = false;

            if (fetchedName.isNotEmpty) {
              beneNameController.value.text = fetchedName;
            }

            Fluttertoast.showToast(
              msg: "VPA verified successfully!",
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP,
            );
          } else if (txnStatus == 'PENDING') {
            verifyButton.value = false;
            CustomDialog.error(message: txnDesc);
          } else {
            verifyButton.value = false;
            CustomDialog.error(message: txnDesc);
          }
        } else {
          verifyButton.value = false;
          CustomDialog.error(
            message: data['Resp_desc'] ?? "Verification failed",
          );
        }
      } else {
        verifyButton.value = false;
      }
    } catch (e) {
      CustomLoading.hideLoading();
      verifyButton.value = false;
      ConsoleLog.printError("INITIATE VPA VERIFICATION ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region addUPIBeneficiary
  Future<void> addUPIBeneficiary(BuildContext context) async {
    try {
      String beneName = beneNameController.value.text.trim();
      String vpa = beneVPAController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();

      // Validation
      if (beneName.isEmpty) {
        Fluttertoast.showToast(msg: "Beneficiary name required!");
        return;
      }

      if (vpa.isEmpty) {
        Fluttertoast.showToast(msg: "UPI VPA/UPI ID required!");
        return;
      }

      if (!isValidVPA(vpa)) {
        Fluttertoast.showToast(msg: "Please enter valid VPA!");
        return;
      }

      if (senderId.value.isEmpty || senderMobileNo.value.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "sendername": senderName.value,
        "handleradio": selectedPaymentMode.value,
        "custom_vpa": vpa,
        "benename": beneName,
        "is_verified": isVPAVerified.value ? '1' : '0',
      };

      // Add IFSC if provided
      if (ifsc.isNotEmpty) {
        body['ifsc'] = ifsc;
      }

      ConsoleLog.printColor("ADD UPI BENEFICIARY REQ: $body", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_ADD_UPI_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("ADD UPI BENEFICIARY RESP: ${jsonEncode(response.data)}", color: "green");

        var data = response.data;

        if (data['Resp_code'] == "RCS") {
          ConsoleLog.printSuccess("✅ UPI Beneficiary added successfully");

          Fluttertoast.showToast(
            msg: "Beneficiary added successfully!",
            backgroundColor: Colors.green,
          );

          // Refresh beneficiary list
          await getBeneficiaryList(context, senderMobileNo.value);

          // Reset form
          resetAddBeneficiaryForm();

          // Close screen
          Get.back();

        } else if (data['Resp_code'] == "ERR") {
          String errorMsg = data['Resp_desc'] ?? "Failed to add beneficiary";

          ConsoleLog.printError("❌ ADD UPI BENEFICIARY ERROR: $errorMsg");

          CustomDialog.error(message: errorMsg);
        } else {
          CustomDialog.error(
            message: data['Resp_desc'] ?? "Unexpected response",
          );
        }
      } else if (response?.statusCode == 401) {
        await refreshToken(context);
      } else {
        CustomDialog.error(message: "No response from server");
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("❌ ADD UPI BENEFICIARY ERROR: $e");
      CustomDialog.error(message: "Technical issue occurred!");
    }
  }
  //endregion

  //region resetAddBeneficiaryForm
  void resetAddBeneficiaryForm() {
    beneNameController.value.clear();
    beneVPAController.value.clear();
    beneIfscController.value.clear();
    upiMobileController.value.clear();
    isVPAVerified.value = false;
    selectedPaymentMode.value = 'Paytm';
    selectedVPA.value = '';
    verifyButton.value = false;
  }
//endregion

  // Step 1: Request OTP for deletion
  //region deleteUPIBeneficiaryRequestOtp
  Future<void> deleteBeneficiaryRequestOtpUPI(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "request_type": "VERIFY",
      };

      ConsoleLog.printColor("DELETE UPI BENE REQUEST OTP: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_UPI_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'VRF') {
          // OTP sent successfully
          ConsoleLog.printSuccess("OTP sent for beneficiary deletion");

          // Show OTP dialog
          showDeleteOtpDialogUPI(context, beneId);

        } else {
          CustomDialog.error(
            message: data['Resp_desc'] ?? "Failed to send OTP",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("DELETE UPI BENEFICIARY REQUEST OTP ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region resendDeleteBeneficiaryOtpUPI
  Future<void> resendDeleteBeneficiaryOtpUPI(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "request_type": "VERIFY",
      };

      ConsoleLog.printColor("RESEND UPI DELETE BENE OTP: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_UPI_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

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
      CustomLoading.hideLoading();
      ConsoleLog.printError("RESEND UPI DELETE BENEFICIARY OTP ERROR: $e");
      Fluttertoast.showToast(
        msg: "Failed to resend OTP",
        backgroundColor: Colors.red,
      );
    }
  }
  //endregion

  // Step 2: Validate OTP and delete beneficiary
  //region deleteBeneficiaryValidate
  Future<void> deleteBeneficiaryValidateUPI(BuildContext context, String beneId, String otp) async {
    try {
      if (otp.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter OTP");
        return;
      }

      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "beneid": beneId,
        "otp": otp,
        "request_type": "VALIDATE",
      };

      ConsoleLog.printColor("DELETE UPI BENE VALIDATE: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_UPI_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        DeleteBeneficiaryResponseModel deleteResponse =
        DeleteBeneficiaryResponseModel.fromJson(response.data);

        if (deleteResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Beneficiary deleted successfully");
          Fluttertoast.showToast(msg: "Beneficiary deleted successfully");

          // Remove from list
          beneficiaryList.removeWhere((bene) => bene.upiBeneId == beneId);
          filteredBeneficiaryList.removeWhere((bene) => bene.upiBeneId == beneId);

          Get.back(); // Close OTP dialog

        } else {
          CustomDialog.error(
            message: deleteResponse.respDesc ?? "Failed to delete beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("DELETE UPI BENEFICIARY VALIDATE ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region showDeleteOtpDialog
  void showDeleteOtpDialogUPI(BuildContext context, String beneId) {
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
                                await resendDeleteBeneficiaryOtpUPI(context, beneId);
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
                            deleteBeneficiaryValidateUPI(context, beneId, otp);
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
  //endregion






  //region addBeneficiary
  Future<void> addBeneficiaryUPI(BuildContext context) async {
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

      CustomLoading.showLoading();

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
        WebApiConstant.API_URL_ADD_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        CustomLoading.hideLoading();
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
            message: addBeneResponse.respDesc ?? "Failed to add beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("ADD BENEFICIARY ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  // Step 1: Request OTP for deletion
  //region deleteBeneficiaryRequestOtp
  Future<void> deleteBeneficiaryRequestOtp(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

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
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'VRF') {
          // OTP sent successfully
          ConsoleLog.printSuccess("OTP sent for beneficiary deletion");

          // Show OTP dialog
          showDeleteOtpDialog(context, beneId);

        } else {
          CustomDialog.error(
            message: data['Resp_desc'] ?? "Failed to send OTP",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("DELETE BENEFICIARY REQUEST OTP ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region resendDeleteBeneficiaryOtp
  Future<void> resendDeleteBeneficiaryOtp(BuildContext context, String beneId) async {
    try {
      if (senderMobileNo.isEmpty) {
        Fluttertoast.showToast(msg: "Sender details not found");
        return;
      }

      CustomLoading.showLoading();

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
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

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
      CustomLoading.hideLoading();
      ConsoleLog.printError("RESEND DELETE BENEFICIARY OTP ERROR: $e");
      Fluttertoast.showToast(
        msg: "Failed to resend OTP",
        backgroundColor: Colors.red,
      );
    }
  }
  //endregion

  // Step 2: Validate OTP and delete beneficiary
  //region deleteBeneficiaryValidate
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

      CustomLoading.showLoading();

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
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        DeleteBeneficiaryResponseModel deleteResponse =
        DeleteBeneficiaryResponseModel.fromJson(response.data);

        if (deleteResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Beneficiary deleted successfully");
          Fluttertoast.showToast(msg: "Beneficiary deleted successfully");

          // Remove from list
          beneficiaryList.removeWhere((bene) => bene.upiBeneId == beneId);
          filteredBeneficiaryList.removeWhere((bene) => bene.upiBeneId == beneId);

          Get.back(); // Close OTP dialog

        } else {
          CustomDialog.error(
            message: deleteResponse.respDesc ?? "Failed to delete beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("DELETE BENEFICIARY VALIDATE ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region showDeleteOtpDialog
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
                            deleteBeneficiaryValidateUPI(context, beneId, otp);
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
  //endregion

  // Step 1: Confirm transaction and get charges
  //region confirmTransfer
  Future<void> confirmTransfer(BuildContext transferMoneyContext, BeneficiaryUPIData beneficiary) async {
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

      CustomLoading.showLoading();

      // Step 1: CONFIRM - Get charges
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileNo.value,
        "sendername": senderName.value,
        "vpa_mobile": beneficiary.vpa,
        "benename": beneficiary.benename,
        "mode": "UPI",
        "amount": amount,
        "request_type": "CONFIRM",
        "reqfor": "UPITRANSFER",
      };

      ConsoleLog.printColor("CONFIRM UPI TRANSFER REQ: ${jsonEncode(body)}");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_UPI_TRANSFER_MONEY, // Uses process_remit_action_new
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        ConfirmTransferResponseModel confirmResponse = ConfirmTransferResponseModel.fromJson(response.data);

        if (confirmResponse.respCode == 'RCS' && confirmResponse.data != null) {
          var chargesData = confirmResponse.data!;

          // Log parsed data
          ConsoleLog.printSuccess("Transfer details fetched:");
          ConsoleLog.printInfo("Beneficiary Name: ${beneficiary.benename}");
          ConsoleLog.printInfo("UPI ID: ${beneficiary.vpa}");
          // ConsoleLog.printInfo("Mode: $mode");
          // ConsoleLog.printInfo("Amount: ${chargesData.trasamt!}");
          // ConsoleLog.printInfo("Charged Amount: ${chargesData.chargedamt!.toString()}");
          // ConsoleLog.printInfo("Total Charge: ${chargesData.totalcharge!.toString()}");
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

          Get.to(()=>TransactionConfirmationUPIScreen());
          // Show confirmation dialog
          // showTransferConfirmationDialog(transferMoneyContext, beneficiary, chargesData);


        } else {
          showConfirmation.value = false;
          ConsoleLog.printError("Error: ${confirmResponse.respDesc}");
          CustomDialog.error(
            message: confirmResponse.respDesc ?? "Failed to confirm transfer",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      showConfirmation.value = false;
      ConsoleLog.printError("CONFIRM TRANSFER ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region initiateTransfer
  Future<void> initiateTransfer(BuildContext context, BeneficiaryUPIData beneficiary, String tpin) async {
    try {
      // String tpin = tpinController.value.text.trim();
      // String tpin = txnPinController.value.text.trim();
      String amount = transferAmountController.value.text.trim();

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
      CustomLoading.showLoading();

      // INITIATE TXN
      Map<String, dynamic> body = Map.from(confirmationData.value!['body']);
      body['request_id'] = generateRequestId();
      body['lat'] = loginController.latitude.value.toString();
      body['long'] = loginController.longitude.value.toString();
      body['sender'] = senderMobileNo.value;
      body['sendername'] = senderName.value;
      body['vpa_mobile'] = beneficiary.vpa;
      body['benename'] = beneficiary.benename;
      body['mode'] = "UPI";
      body['amount'] = amount;
      body['request_type'] = 'TRANSACT';
      body['reqfor'] = 'UPITRANSFER';
      if(txnPin.value == "1"){
        body['txnpin'] = tpin;
      }

      ConsoleLog.printColor("INITIATE TRANSFER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_UPI_TRANSFER_MONEY, // Uses process_remit_action_new
        body,
        userAuthToken.value,
        userSignature.value,
      );

      // Hide loading safely
      try {
        if (dialogContext.mounted) {
          CustomLoading.hideLoading();
        }
      } catch (e) {
        ConsoleLog.printWarning("Context unmounted while hiding loading");
      }

      if (response != null && response.statusCode == 200) {
        // var data = response.data;
        TransferMoneyResponseModel transferResponse =
        TransferMoneyResponseModel.fromJson(response.data);
        ConsoleLog.printColor("INITIATE UPI TRANSFER RESPONSE: ${response.data}");
        CustomLoading.hideLoading();
        if (transferResponse.respCode == 'RCS' && transferResponse.data != null) {
          ConsoleLog.printSuccess("UPI Payment Transfer successful: ${transferResponse.data!.txnid}");

          // Clear form
          transferAmountController.value.clear();
          transferConfirmAmountController.value.clear();
          txnPinController.value.clear();
          confirmationData.value = null;
          showConfirmation.value = false;

          // Success dialog (no context issues)
          Get.dialog(
            TransferSuccessDialogUPI(
              transferData: transferResponse.data!,
              onClose: () async {
                Get.back(); // Close dialog

                // Small delay to ensure smooth transition
                await Future.delayed(Duration(milliseconds: 100));

                // Pop Transaction Confirmation Screen
                Get.back();
                // Pop Transfer Money Screen
                // Get.back();

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
                      // Get.back();
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
      // Safely hide loading
      try {
        if (context.mounted) {
          CustomLoading.hideLoading();
        }
      } catch (hideError) {
        ConsoleLog.printWarning("Could not hide loading: $hideError");
      }
      ConsoleLog.printError("INITIATE TRANSFER ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
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
  //endregion

  //region printReceipt
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
        showExternalSafeLoader(currentContext);
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
        WebApiConstant.API_URL_GET_RECEIPT, // Fetch/TxnReceipt
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (currentContext.mounted) {
        hideExternalSafeLoader();
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
            message: data['Resp_desc'] ?? "Receipt not found",
          );
        }
      } else {
        CustomDialog.error(
          message: "Failed to get receipt from server",
        );
      }
    } catch (e) {
      if (shouldHideLoading && currentContext != null && currentContext.mounted) {
        hideExternalSafeLoader();
      }
      ConsoleLog.printError("PRINT RECEIPT ERROR: $e");
      CustomDialog.error(
        message: "Error: ${e.toString()}",
      );
    }finally {
      // Extra safety to hide loading
      try {
        if (shouldHideLoading && currentContext != null && currentContext.mounted) {
          hideExternalSafeLoader();
        }
      } catch (e) {
        ConsoleLog.printWarning("Error in finally block: $e");
      }
    }
  }
  //endregion

  //region convertHtmlToPdfAndSave
  Future<void> convertHtmlToPdfAndSave(
      BuildContext context, String htmlContent, String txnId) async {
    BuildContext? currentContext = context;
    bool shouldHideLoading = true;
    try {
      ConsoleLog.printInfo("Starting HTML to PDF conversion...");

      // Show loading
      if (currentContext.mounted) {
        showExternalSafeLoader(currentContext);
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
      final generatedPdfFile = await htmlToPdf.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: targetPath,
        targetName: fileName,
        pageSize: PdfPageSize.a4, // optional
      );

      if (currentContext.mounted) {
        hideExternalSafeLoader();
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

        try {
          // Use Future.delayed to ensure loading is hidden before opening PDF
          await Future.delayed(Duration(milliseconds: 100));

          pendingExternalReturnCleanup = true;

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
        hideExternalSafeLoader();
      }

      Fluttertoast.showToast(
        msg: "Failed to generate PDF: ${e.toString()}",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );

    } finally {
      // EXTRA SAFETY: Always try to hide loading in finally block
      try {
        if (shouldHideLoading && currentContext.mounted) {
          hideExternalSafeLoader();
        }
      } catch (e) {
        ConsoleLog.printWarning("Error in finally block: $e");
      }
    }
  }
  //endregion

  //region shareToWhatsApp
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

      showExternalSafeLoader(context);

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
        WebApiConstant.API_URL_GET_RECEIPT,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (dialogContext.mounted) {
        hideExternalSafeLoader();
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

          showExternalSafeLoader(context);

          // Generate PDF
          final pdfFile = await htmlToPdf.convertHtmlToPdf(
            html: fixedHtml,
            targetDirectory: targetPath,
            targetName: fileName,
            pageSize: PdfPageSize.a4,
          );

          if (context.mounted) {
            hideExternalSafeLoader();
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
              pendingExternalReturnCleanup = true;
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
          hideExternalSafeLoader();
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
  //endregion

  //region applyA4ReceiptMargins
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
  //endregion

  //region searchTransaction
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

      CustomLoading.showLoading();

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
        "${WebApiConstant.BASE_URL}Fetch/search_txn",
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        if (data['Resp_code'] == 'RCS') {
          // Show transaction details
          showTransactionDetailsDialog(context, data['data']);
        } else {
          CustomDialog.error(
            message: data['Resp_desc'] ?? "Transaction not found",
          );
        }
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("SEARCH TRANSACTION ERROR: $e");
      CustomDialog.error(message: "Technical issue!");
    }
  }
  //endregion

  //region showTransactionDetailsDialog
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
  //endregion

  //region getAllBanks
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
  //endregion

  //region searchBeneficiaries
  void searchBeneficiaries(String query) {
    // Store original query (not converted)
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredBeneficiaryList.value = beneficiaryList;
    } else {
      // Convert query to lowercase ONCE for comparison
      String lowerQuery = query.toLowerCase();
      // ✅ Remove special characters for flexible matching
      // This helps match "9875462130@ybl" even if user types "9875462130", "@ybl", etc.
      String cleanQuery = query.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      String cleanLowerQuery = cleanQuery.toLowerCase();

      filteredBeneficiaryList.value = beneficiaryList.where((bene) {
        // Convert each field to lowercase and compare
        bool nameMatch = (bene.benename?.toLowerCase().contains(lowerQuery) ?? false);
        // ✅ VPA SEARCH - Enhanced multi-strategy matching
        bool vpaMatch = false;
        if (bene.vpa != null && bene.vpa!.isNotEmpty) {
          String vpaLower = bene.vpa!.toLowerCase();

          // Strategy 1: Direct contains (matches "9875462130@ybl" when searching "9875")
          vpaMatch = vpaLower.contains(lowerQuery);

          // // Strategy 2: Clean match (matches "9875462130@ybl" when searching "9875462130ybl")
          // if (!vpaMatch && cleanQuery.isNotEmpty) {
          //   vpaMatch = vpaClean.contains(cleanLowerQuery);
          // }

          // // Strategy 3: Starts with (matches "9875462130@ybl" when searching "987")
          // if (!vpaMatch) {
          //   vpaMatch = vpaLower.startsWith(lowerQuery);
          // }
        }
        // bool accountMatch = (bene.accountNumber?.contains(query) ?? false); // Account numbers are exact
        // bool bankMatch = (bene.bankName?.toLowerCase().contains(lowerQuery) ?? false);
        // bool ifscMatch = (bene.ifsc?.toLowerCase().contains(lowerQuery) ?? false);

        return nameMatch || vpaMatch;
      }).toList();
    }

    // Apply current sort after search
    applySortOption(currentSortOption.value);
  }
  //endregion

  //region sortBeneficiaries
  void sortBeneficiaries(BeneficiarySortOption option) {
    currentSortOption.value = option;
    applySortOption(option);

    // Update sort label
    switch (option) {
      // case BeneficiarySortOption.recent:
      //   currentSortLabel.value = 'Recently Added';
      //   break;
      case BeneficiarySortOption.nameAsc:
        currentSortLabel.value = 'Name A-Z';
        break;
      case BeneficiarySortOption.nameDesc:
        currentSortLabel.value = 'Name Z-A';
        break;
      case BeneficiarySortOption.vpaAsc:
        currentSortLabel.value = 'VPA A-Z';
        break;
      case BeneficiarySortOption.vpaDesc:
        currentSortLabel.value = 'VPA Z-A';
        break;
    }
  }
  //endregion

  //region applySortOption
  void applySortOption(BeneficiarySortOption option) {
    List<BeneficiaryUPIData> listToSort = List.from(filteredBeneficiaryList);

    switch (option) {
      // case BeneficiarySortOption.recent:
      //   listToSort.sort((a, b) =>
      //       (b.updatedOn ?? '').compareTo(a.updatedOn ?? '')
      //   );
      //   break;

      case BeneficiarySortOption.nameAsc:
        listToSort.sort((a, b) =>
            (a.benename ?? '').toLowerCase().compareTo((b.benename ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.nameDesc:
        listToSort.sort((a, b) =>
            (b.benename ?? '').toLowerCase().compareTo((a.benename ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.vpaAsc:
        listToSort.sort((a, b) =>
            (a.vpa ?? '').toLowerCase().compareTo((b.vpa ?? '').toLowerCase())
        );
        break;

      case BeneficiarySortOption.vpaDesc:
        listToSort.sort((a, b) =>
            (b.vpa ?? '').toLowerCase().compareTo((a.vpa ?? '').toLowerCase())
        );
        break;
      // case BeneficiarySortOption.recent:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
    }
    filteredBeneficiaryList.value = listToSort;
  }
  //endregion

  //region showSortOptionsDialog
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
                    // buildSortOption(
                    //   context,
                    //   'Recently Added',
                    //   Icons.access_time,
                    //   BeneficiarySortOption.recent,
                    //   currentSortOption.value == BeneficiarySortOption.recent,
                    // ),
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
                      'VPA A-Z',
                      Icons.badge,
                      BeneficiarySortOption.vpaAsc,
                      currentSortOption.value == BeneficiarySortOption.vpaAsc,
                    ),
                    buildSortOption(
                      context,
                      'VPA Z-A',
                      Icons.badge,
                      BeneficiarySortOption.vpaDesc,
                      currentSortOption.value == BeneficiarySortOption.vpaDesc,
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
  //endregion

  //region buildSortOption
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
  //endregion

  //region getAllBeneficiaryDetails
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
      WebApiConstant.API_URL_GET_ALL_BENEFICIARY_DETAILS,
      body,
      userAuthToken.value,
      userSignature.value,
    );

    if (response != null && response.statusCode == 200) {
    }
  }
  //endregion

  //region onClose
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
    deleteOtpController.value.dispose();
    beneVPAController.value.dispose();
    upiMobileController.value.dispose();
    beneIfscController.value.dispose();
    super.onClose();
  }
//endregion
}
