import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_provider.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/custom_loading.dart';
import '../utils/CustomDialog.dart';
import '../utils/ConsoleLog.dart';
import '../api/web_api_constant.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final FlutterNativeHtmlToPdf htmlToPdf = FlutterNativeHtmlToPdf();
  
  // Observable Variables
  var isLoading = false.obs;
  var userData = Rxn<Map<String, dynamic>>();
  var activityLog = <Map<String, dynamic>>[].obs;
  var loginOtpEnabled = false.obs;
  var walletOtpEnabled = false.obs;
  var downloadCertificateShow = false.obs;
  
  // Reference ID for OTP verification
  String referenceId = '';
  Map<String, dynamic>? changeTxnStatusObject;
  Map<String, dynamic>? changeLoginStatusObject;

  @override
  void onInit() {
    super.onInit();
    // Don't call API directly in onInit() as it can cause build phase errors
    // Call from screen's initState() using addPostFrameCallback instead
  }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  // Get User Profile Details
  Future<void> getUserDetail() async {
    try {
      CustomLoading.showLoading();

      // Load auth credentials first
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        ConsoleLog.printError("❌ Invalid token or signature");
        CustomDialog.error(message: "Session expired. Please login again.");
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

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("GET USER DETAIL RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          userData.value = result['data'];
          loginOtpEnabled.value = result['data']['twofa_status'] == '1';
          walletOtpEnabled.value = result['data']['txnpin_status'] == '1';

          // Check if download certificate should be shown (role_id == 4)
          if (result['data']['role_id'] == '4') {
            downloadCertificateShow.value = true;
          } else {
            downloadCertificateShow.value = false;
          }

          // Save user data to preferences
          await AppSharedPreferences().setString(
            'userData',
            jsonEncode(result['data']),
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to fetch profile details',
          );
        }
      } else {
        CustomDialog.error(
          message: 'Failed to fetch profile details',
        );
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in getUserDetail: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }

  // Get Activity Log
  Future<void> getActivity() async {
    try {
      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'activity_type': 'Login',
        'limit': 10,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_ACTIVITY_LOG,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          activityLog.value = List<Map<String, dynamic>>.from(
              result['data'] ?? []
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError('Error in getActivity: $e');
    }
  }

  // Change Transaction PIN Status
  Future<void> changeWalletOtpStatus(bool newValue) async {
    try {
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        walletOtpEnabled.value = !newValue;
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VALIDATE',
        'txnpin_status': newValue ? 'true' : 'false',
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_CHANGE_TXN_PIN_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'VRF') {
          changeTxnStatusObject = requestBody;
          referenceId = result['data']?['referenceid'] ?? '';

          CustomDialog.success(
            message: result['Resp_desc'] ?? 'OTP sent successfully',
            onContinue: () {
              Get.back();
              _showOtpDialog(isForWallet: true);
            },
          );
        } else if (result['Resp_code'] == 'RCS') {
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Status changed successfully',
          );
          await getUserDetail();
        } else {
          walletOtpEnabled.value = !newValue;
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to change status',
          );
        }
      } else {
        walletOtpEnabled.value = !newValue;
        CustomDialog.error(message: 'Failed to change status');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      walletOtpEnabled.value = !newValue;
      ConsoleLog.printError('Error in changeWalletOtpStatus: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }

  // Change Login OTP Status
  Future<void> changeLoginOtpStatus(bool newValue) async {
    try {
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        loginOtpEnabled.value = !newValue;
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'request_type': 'VALIDATE',
        'twofa_status': newValue ? 'true' : 'false',
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_CHANGE_LOGIN_OTP_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'VRF') {
          changeLoginStatusObject = requestBody;
          referenceId = result['data']?['referenceid'] ?? '';

          CustomDialog.success(
            message: result['Resp_desc'] ?? 'OTP sent successfully',
            onContinue: () {
              Get.back();
              _showOtpDialog(isForWallet: false);
            },
          );
        } else if (result['Resp_code'] == 'RCS') {
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Status changed successfully',
          );
          await getUserDetail();
        } else {
          loginOtpEnabled.value = !newValue;
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to change status',
          );
        }
      } else {
        loginOtpEnabled.value = !newValue;
        CustomDialog.error(message: 'Failed to change status');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      loginOtpEnabled.value = !newValue;
      ConsoleLog.printError('Error in changeLoginOtpStatus: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }

  // Verify OTP for Status Change
  Future<void> verifyOtp(String otp, {required bool isForWallet}) async {
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
        'referenceid': referenceId,
        'otp': otp,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      if (isForWallet) {
        requestBody['txnpin_status'] = changeTxnStatusObject?['txnpin_status'];
      } else {
        requestBody['twofa_status'] = changeLoginStatusObject?['twofa_status'];
      }

      final response = await _apiProvider.requestPostForApi(
        isForWallet
            ? WebApiConstant.API_URL_CHANGE_TXN_PIN_STATUS
            : WebApiConstant.API_URL_CHANGE_LOGIN_OTP_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS') {
          Get.back(); // Close OTP dialog
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Status changed successfully',
            onContinue: () {
              Get.back();
              getUserDetail();
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'OTP verification failed',
            onContinue: () {
              Get.back();
              getUserDetail();
            },
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to verify OTP');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in verifyOtp: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }

  // Download Certificate
  Future<void> downloadCertificate() async {
    try {
      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_DOWNLOAD_CERTIFICATE,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("DOWNLOAD CERTIFICATE RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          // Get HTML content from response
          String htmlContent = result['data'].toString();
          
          // Clean HTML content - remove debug comments if present
          htmlContent = htmlContent.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '').trim();
          
          ConsoleLog.printInfo("HTML Content length: ${htmlContent.length}");

          try {
            // Storage permission check for Android (to save to Downloads)
            Directory? directory;
            if (Platform.isAndroid) {
              // Request storage permissions
              PermissionStatus status = await Permission.manageExternalStorage.request();
              if (!status.isGranted) {
                status = await Permission.storage.request();
              }

              if (!status.isGranted) {
                CustomLoading.hideLoading();
                CustomDialog.error(
                  message: 'Storage permission is required to download certificate.\nPlease grant permission in settings.',
                  onContinue: () async {
                    await openAppSettings();
                  },
                );
                return;
              }

              // Try Downloads folder first
              directory = Directory('/storage/emulated/0/Download');
              if (!await directory.exists()) {
                ConsoleLog.printWarning("Downloads folder not accessible, using external storage");
                directory = await getExternalStorageDirectory();
              }
            } else {
              // For iOS, use documents directory
              directory = await getApplicationDocumentsDirectory();
            }

            final targetPath = directory!.path;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'Payrupya_Certificate_$timestamp';
            
            ConsoleLog.printInfo("Target Directory: $targetPath");
            ConsoleLog.printInfo("File Name: $fileName");

            // Convert HTML to PDF
            CustomLoading.showLoading();
            final generatedPdfFile = await htmlToPdf.convertHtmlToPdf(
              html: htmlContent,
              targetDirectory: targetPath,
              targetName: fileName,
              pageSize: PdfPageSize.a4,
            );

            CustomLoading.hideLoading();

            if (generatedPdfFile != null && await generatedPdfFile.exists()) {
              ConsoleLog.printSuccess("✅ Certificate PDF generated successfully!");
              ConsoleLog.printSuccess("Path: ${generatedPdfFile.path}");

              // Show success message
              Fluttertoast.showToast(
                msg: "Certificate saved to Downloads",
                backgroundColor: Colors.green,
                toastLength: Toast.LENGTH_LONG,
              );

              // Open the PDF file
              try {
                await Future.delayed(const Duration(milliseconds: 300));
                final openResult = await OpenFilex.open(generatedPdfFile.path);
                
                if (openResult.type != ResultType.done) {
                  ConsoleLog.printWarning("Could not open PDF: ${openResult.message}");
                  // Still show success as file is saved
                  CustomDialog.success(
                    message: 'Certificate downloaded successfully!\nSaved to Downloads folder.\n\nYou can open it from your Downloads.',
                  );
                } else {
                  ConsoleLog.printSuccess("✅ Certificate opened successfully");
                }
              } catch (e) {
                ConsoleLog.printError("Error opening PDF: $e");
                // Still show success as file is saved
                CustomDialog.success(
                  message: 'Certificate downloaded successfully!\nSaved to Downloads folder.\n\nYou can open it from your Downloads.',
                );
              }
            } else {
              CustomDialog.error(message: 'Failed to generate certificate PDF');
            }
          } catch (e) {
            CustomLoading.hideLoading();
            ConsoleLog.printError('Error downloading certificate: $e');
            CustomDialog.error(
              message: 'Unable to download certificate. Please try again.\nError: ${e.toString()}',
            );
          }
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to download certificate',
          );
        }
      } else {
        CustomDialog.error(message: 'Failed to download certificate');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in downloadCertificate: $e');
      CustomDialog.error(
        message: 'Unable to download certificate. Please try again.',
      );
    }
  }

  // Show OTP Dialog
  void _showOtpDialog({required bool isForWallet}) {
    final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          // Reset toggle to previous state if cancelled
          if (isForWallet) {
            walletOtpEnabled.value = !walletOtpEnabled.value;
          } else {
            loginOtpEnabled.value = !loginOtpEnabled.value;
          }
          // Refresh user detail to sync toggle state
          Future.microtask(() => getUserDetail());
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
                Icon(
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
                    color: Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  isForWallet
                      ? 'Enter OTP to change Wallet Balance Deduction OTP status'
                      : 'Enter OTP to change Login OTP status',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OTP Input Fields - Wrapped to prevent overflow
                SizedBox(
                  width: double.infinity,
                  child: OtpInputFields(
                    key: _otpKey,
                    length: 6,
                    onCompleted: (otp) {
                      // Auto verify when all 6 digits are entered
                      verifyOtp(otp, isForWallet: isForWallet);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    InkWell(
                      onTap: () {
                        // Reset toggle to previous state
                        if (isForWallet) {
                          walletOtpEnabled.value = !walletOtpEnabled.value;
                        } else {
                          loginOtpEnabled.value = !loginOtpEnabled.value;
                        }
                        Get.back();
                        getUserDetail();
                      },
                      child: Container(
                        width: 120,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.albertSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B707E),
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
                          verifyOtp(otp, isForWallet: isForWallet);
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
      barrierDismissible: false,
    );
    
    // Auto focus on first OTP field after dialog is shown
    Future.delayed(Duration(milliseconds: 300), () {
      _otpKey.currentState?.focusFirst();
    });
  }
}