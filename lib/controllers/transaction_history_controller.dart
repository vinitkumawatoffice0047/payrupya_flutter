import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payrupya/api/api_provider.dart';
import 'package:payrupya/api/web_api_constant.dart';
import 'package:payrupya/utils/ConsoleLog.dart';
import 'package:payrupya/utils/app_shared_preferences.dart';
import 'package:payrupya/utils/connection_validator.dart';
import 'package:payrupya/utils/global_utils.dart';
import 'package:payrupya/utils/CustomDialog.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:flutter_native_html_to_pdf/pdf_page_size.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_history_response_model_.dart';
import '../utils/custom_loading.dart';
import 'login_controller.dart';

class TransactionHistoryController extends GetxController {
  LoginController get loginController => Get.find<LoginController>();

  // Auth credentials
  RxString userAuthToken = "". obs;
  RxString userSignature = "".obs;

  // Transaction data
  RxList<TransactionData> allTransactions = <TransactionData>[].obs;
  RxList<TransactionData> filteredTransactions = <TransactionData>[]. obs;

  // Search & Filter
  Rx<TextEditingController> searchController = TextEditingController().obs;
  RxString searchQuery = ''.obs;
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 400);

  // ✅ Date range parameters
  Rx<DateTime> fromDate = DateTime.now().obs;
  Rx<DateTime> toDate = DateTime.now().obs;

  // Filter display options - ✅ REMOVED Date Range options
  RxString selectedServiceFilter = 'All'.obs;
  RxString selectedStatusFilter = 'All'.obs;

  RxList<String> services = <String>['All'].obs;
  RxList<String> statuses = <String>['All', 'PENDING', 'SUCCESS', 'FAILED']. obs;

  // Loading states
  RxBool isInitialLoading = false.obs;
  RxBool isFilterApplying = false.obs;

  // Selected transaction for details
  Rx<TransactionData? > selectedTransaction = Rx<TransactionData?>(null);

  // ✅ External loader
  static const String _kExternalLoaderRouteName = '__txn_external_loader__';
  bool externalLoaderVisible = false;

  final FlutterNativeHtmlToPdf htmlToPdf = FlutterNativeHtmlToPdf();
  bool pendingExternalReturnCleanup = false;

  // ✅ Date range filter state
  RxBool showCustomDateRange = false. obs;
  Rx<DateTime> customFromDate = DateTime.now().obs;
  Rx<DateTime> customToDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadAuthCredentials();
    _initializeDefaultDates();
  }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  //region loadAuthCredentials
  Future<void> loadAuthCredentials() async {
    try {
      Map<String, String> authData = await AppSharedPreferences.getLoginAuth();
      userAuthToken.value = authData["token"] ?? "";
      userSignature. value = authData["signature"] ??  "";

      ConsoleLog.printSuccess("Auth credentials loaded");
    } catch (e) {
      ConsoleLog.printError("Error loading auth credentials: $e");
    }
  }
  //endregion

  //region _initializeDefaultDates
  void _initializeDefaultDates() {
    DateTime now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, now.day);
    toDate.value = DateTime(now. year, now.month, now. day, 23, 59, 59);
  }
  //endregion

  //region _formatDateForAPI
  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
  //endregion

  //region fetchTransactionHistory
  Future<void> fetchTransactionHistory({bool reset = false, bool preserveDates = false}) async {
    try {
      if (reset) {
        isInitialLoading.value = true;
        allTransactions.clear();
        filteredTransactions.clear();

        selectedServiceFilter.value = 'All';
        selectedStatusFilter.value = 'All';
        searchQuery.value = '';
        searchController.value.clear();

        // Only reset dates if preserveDates is false
        if (!preserveDates) {
          _initializeDefaultDates();
        }
      }

      if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
        await loadAuthCredentials();
      }

      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        isInitialLoading.value = false;
        return;
      }

      if (reset) {
        CustomLoading.showLoading();
      }

      // ✅ CORRECT API PARAMETERS
      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude. value,
        "long": loginController.longitude.value,
        "from":  _formatDateForAPI(fromDate.value),
        "to": _formatDateForAPI(toDate.value),
      };

      ConsoleLog.printColor("FETCH TRANSACTION HISTORY REQ:  ${jsonEncode(body)}", color: "yellow");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_TRANSACTION_HISTORY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        TransactionHistoryResponseModel txnResponse =
        TransactionHistoryResponseModel.fromJson(response.data);

        if (txnResponse. respCode == "RCS" && txnResponse.data != null) {
          allTransactions.value = txnResponse.data!;

          // Extract unique services from transactions
          Set<String> uniqueServices = {'All'};
          for (var txn in allTransactions) {
            if (txn. recordType != null && txn.recordType! .isNotEmpty) {
              uniqueServices.add(txn.recordType!);
            }
          }
          services.value = uniqueServices. toList();

          // ✅ Apply filters immediately after fetching
          _applyFilters();

          ConsoleLog.printSuccess("Transactions loaded:  ${allTransactions.length}");
        } else {
          ConsoleLog. printError("API Error: ${txnResponse.respDesc}");
          Fluttertoast.showToast(
            msg: txnResponse.respDesc ??  "Failed to load transactions",
            backgroundColor: Colors.red,
          );
        }
      } else {
        ConsoleLog.printError("API Error: ${response?. statusCode}");
      }
    } catch (e) {
      ConsoleLog.printError("FETCH TRANSACTION ERROR: $e");
    } finally {
      isInitialLoading.value = false;
      isFilterApplying.value = false;
      CustomLoading.hideLoading();
    }
  }
  //endregion

  //region onSearchChanged
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      searchQuery.value = '';
      _applyFilters();
      return;
    }

    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      searchQuery.value = query;
      _applyFilters();
    });
  }
  //endregion

  //region updateCustomDateRange (✅ NEW)
  void updateCustomDateRange(DateTime from, DateTime to) {
    customFromDate.value = from;
    customToDate.value = to;
    // Set fromDate to start of day and toDate to end of day
    fromDate.value = DateTime(from.year, from.month, from.day);
    toDate.value = DateTime(to.year, to.month, to.day, 23, 59, 59);

    ConsoleLog.printInfo(
        "Custom date range set: ${DateFormat('dd-MM-yyyy').format(fromDate.value)} to ${DateFormat('dd-MM-yyyy').format(toDate.value)}"
    );

    // ✅ Apply filters and fetch new data - preserve dates
    fetchTransactionHistory(reset: true, preserveDates: true);
  }
//endregion

//region quickDateFilter (✅ Updated)
  void quickDateFilter(String period) {
    DateTime now = DateTime.now();

    switch (period) {
      case 'Today':
        fromDate.value = DateTime(now.year, now.month, now.day);
        toDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        customFromDate.value = fromDate.value;
        customToDate.value = toDate.value;
        break;
      case 'Last 7 Days':
        fromDate.value = DateTime(now.year, now.month, now.day).subtract(Duration(days: 7));
        toDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        customFromDate.value = fromDate.value;
        customToDate.value = toDate.value;
        break;
      case 'Last 30 Days':
        fromDate.value = DateTime(now.year, now.month, now.day).subtract(Duration(days: 30));
        toDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        customFromDate.value = fromDate.value;
        customToDate.value = toDate.value;
        break;
    }

    ConsoleLog.printInfo("Quick date filter: $period - From: ${DateFormat('dd-MM-yyyy').format(fromDate.value)}, To: ${DateFormat('dd-MM-yyyy').format(toDate.value)}");

    // Preserve dates when fetching - don't reset them
    fetchTransactionHistory(reset: true, preserveDates: true);
  }
//endregion

  //region _applyFilters (✅ FIXED - Proper status filtering)
  void _applyFilters() {
    List<TransactionData> result = List.from(allTransactions);

    // Search filter
    if (searchQuery. value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((txn) {
        return (txn.portalTxnId?.toLowerCase().contains(query) ?? false) ||
            (txn.recordType?.toLowerCase().contains(query) ?? false) ||
            (txn.txnAmt?.contains(query) ?? false) ||
            (txn.fullname?.toLowerCase().contains(query) ?? false) ||
            (txn.customerId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Service filter
    if (selectedServiceFilter.value != 'All') {
      result = result
          .where((txn) =>
      txn.recordType?. toUpperCase() ==
          selectedServiceFilter.value. toUpperCase())
          .toList();
    }

    // ✅ Status filter - Match with portal_status from API
    if (selectedStatusFilter.value != 'All') {
      String filterStatus = selectedStatusFilter.value. toUpperCase();
      result = result
          .where((txn) =>
      txn.portalStatus?.toUpperCase() == filterStatus)
          .toList();

      ConsoleLog.printInfo("Status filter applied: $filterStatus, Matching results: ${result.length}");
    }

    filteredTransactions.value = result;
    ConsoleLog.printInfo("Total filtered transactions: ${filteredTransactions. length}");
  }
  //endregion

  //region updateServiceFilter
  void updateServiceFilter(String service) {
    selectedServiceFilter.value = service;
    _applyFilters();
  }
  //endregion

  //region updateStatusFilter (✅ FIXED)
  void updateStatusFilter(String status) {
    ConsoleLog.printInfo("Status filter changed to: $status");
    selectedStatusFilter.value = status;
    _applyFilters();
  }
  //endregion

  //region resetFilters
  void resetFilters() {
    selectedServiceFilter.value = 'All';
    selectedStatusFilter.value = 'All';
    _initializeDefaultDates();
    searchQuery.value = '';
    searchController.value.clear();
    _applyFilters();
    ConsoleLog.printInfo("All filters reset to default");
  }
  //endregion

  //region showExternalSafeLoader
  void showExternalSafeLoader(BuildContext context) {
    if (externalLoaderVisible) {
      ConsoleLog.printWarning("External loader already visible, skipping.. .");
      return;
    }
    externalLoaderVisible = true;

    try {
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
                    color: Colors.black. withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const SizedBox(
                    height: 44,
                    width: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      ConsoleLog. printError("Error showing external loader: $e");
      externalLoaderVisible = false;
    }
  }
  //endregion

  //region hideExternalSafeLoader
  void hideExternalSafeLoader() {
    if (!externalLoaderVisible) {
      ConsoleLog.printWarning("External loader not visible, skipping hide.. .");
      return;
    }

    final ctx = Get.overlayContext ??  Get.context;
    if (ctx == null) {
      ConsoleLog.printError("Context not available for hiding loader");
      externalLoaderVisible = false;
      return;
    }

    try {
      Navigator.of(ctx, rootNavigator: true)
          .popUntil((route) => route.settings.name != _kExternalLoaderRouteName);
      externalLoaderVisible = false;
      ConsoleLog.printSuccess("External loader hidden");
    } catch (e) {
      ConsoleLog.printError("Error hiding external loader: $e");
      externalLoaderVisible = false;
    }
  }
  //endregion

  //region printReceipt (✅ FIXED - Better error handling)
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

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value. toString(),
        "long": loginController.longitude.value.toString(),
        "request_type": "DOWNLOAD",
        "txndata": [txnId],
      };

      ConsoleLog.printColor("GET RECEIPT API CALL for TXN:  $txnId");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_RECEIPT,
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
        hideExternalSafeLoader();
        shouldHideLoading = false;
        // ✅ Check if response has error (API server error)
        if (data['title'] != null || data['type'] != null) {
          ConsoleLog.printError("API Server Error: ${data['message']}");
          Fluttertoast.showToast(
            msg: "Receipt generation failed on server.  Please try again later.",
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          return;
        }

        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          String htmlContent = data['data']. toString();
          await convertHtmlToPdfAndSave(currentContext, htmlContent, txnId);
        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Receipt not found",
            backgroundColor: Colors.red,
          );
        }
      } else {
        hideExternalSafeLoader();
        shouldHideLoading = false;
        Fluttertoast.showToast(
          msg: "Failed to get receipt from server",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (shouldHideLoading && currentContext != null && currentContext.mounted) {
        hideExternalSafeLoader();
      }
      ConsoleLog.printError("PRINT RECEIPT ERROR: $e");
      Fluttertoast. showToast(
        msg:  "Error generating receipt",
        backgroundColor: Colors.red,
      );
    } finally {
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
      ConsoleLog.printInfo("Starting HTML to PDF conversion.. .");

      if (currentContext.mounted) {
        showExternalSafeLoader(currentContext);
      }

      if (Platform.isAndroid) {
        PermissionStatus status = await Permission.manageExternalStorage. request();

        if (! status.isGranted) {
          status = await Permission.storage.request();
        }

        if (! status.isGranted) {
          Fluttertoast.showToast(
            msg: "Storage permission required",
            backgroundColor: Colors.orange,
          );
          await openAppSettings();
          return;
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String targetPath = directory! .path;
      String fileName = "Payrupya_Receipt_$txnId";

      htmlContent = applyA4ReceiptMargins(htmlContent);

      final generatedPdfFile = await htmlToPdf.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: targetPath,
        targetName: fileName,
        pageSize: PdfPageSize.a4,
      );

      if (currentContext. mounted) {
        hideExternalSafeLoader();
        shouldHideLoading = false;
      }

      if (generatedPdfFile != null && await generatedPdfFile.exists()) {
        ConsoleLog.printSuccess("PDF Generated!");

        Fluttertoast.showToast(
          msg: "Receipt saved to Downloads",
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );

        try {
          await Future.delayed(Duration(milliseconds: 100));
          pendingExternalReturnCleanup = true;
          await OpenFilex.open(generatedPdfFile. path);
        } catch (openError) {
          ConsoleLog. printWarning("Could not open PDF:  $openError");
        }
      } else {
        throw Exception("PDF generation failed");
      }
    } catch (e) {
      if (shouldHideLoading && currentContext != null && currentContext. mounted) {
        hideExternalSafeLoader();
      }

      Fluttertoast.showToast(
        msg: "Failed to generate PDF",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      ConsoleLog.printError("PDF conversion error: $e");
    } finally {
      try {
        if (shouldHideLoading && currentContext != null && currentContext.mounted) {
          hideExternalSafeLoader();
        }
      } catch (e) {
        ConsoleLog.printWarning("Error in finally:  $e");
      }
    }
  }
  //endregion

  //region shareReceipt (✅ FIXED - Better error handling)
  Future<void> shareReceipt(BuildContext context, String txnId) async {
    try {
      if (txnId.isEmpty) {
        Fluttertoast.showToast(
          msg: "Transaction ID not found",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
        );
        return;
      }

      if (context.mounted) {
        showExternalSafeLoader(context);
      }

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "request_type": "DOWNLOAD",
        "txndata":  [txnId],
      };

      ConsoleLog.printColor("GET RECEIPT FOR SHARE:  $txnId");

      var response = await ApiProvider().requestPostForApi(
        WebApiConstant.API_URL_GET_RECEIPT,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      if (context.mounted) {
        hideExternalSafeLoader();
      }

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        hideExternalSafeLoader();

        // ✅ Check for API server errors
        if (data['title'] != null || data['type'] != null) {
          ConsoleLog.printError("API Server Error: ${data['message']}");
          Fluttertoast.showToast(
            msg: "Receipt generation failed on server",
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          return;
        }

        if (data['Resp_code'] == 'RCS' && data['data'] != null) {
          final htmlContent = data['data'].toString();

          Directory? directory;
          if (Platform.isAndroid) {
            PermissionStatus status = await Permission. manageExternalStorage.request();
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }

            if (!status.isGranted) {
              Fluttertoast.showToast(
                msg: "Storage permission required",
                backgroundColor: Colors.orange,
              );
              return;
            }

            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              directory = await getExternalStorageDirectory();
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          final fileName = "Payrupya_Receipt_$txnId";
          final targetPath = directory!.path;
          final fixedHtml = applyA4ReceiptMargins(htmlContent);

          showExternalSafeLoader(context);

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
            try {
              pendingExternalReturnCleanup = true;
              Share.shareXFiles(
                [XFile(pdfFile.path, mimeType: "application/pdf")],
              ).then((result) {
                if (result. status == ShareResultStatus.success) {
                  Fluttertoast.showToast(
                    msg: "Receipt shared successfully",
                    backgroundColor: Colors.green,
                  );
                }
              });
            } catch (shareError) {
              ConsoleLog.printError("Share error: $shareError");
            }
          }
        } else {
          hideExternalSafeLoader();
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to get receipt",
            backgroundColor:  Colors.red,
          );
        }
      }else{
        hideExternalSafeLoader();
        Fluttertoast.showToast(
          msg: "Failed to get receipt from server",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      try {
        if (context.mounted) {
          hideExternalSafeLoader();
        }
      } catch (hideError) {
        ConsoleLog.printWarning("Hide error: $hideError");
      }
      ConsoleLog.printError("SHARE ERROR: $e");
    } finally {
      hideExternalSafeLoader();
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
    . receipt-page { padding: 8mm; }
    table { width: 100% !important; max-width: 100% !important; border-collapse: collapse; }
  </style>
  ''';

    if (html.contains('</head>')) {
      html = html.replaceFirst('</head>', '$css</head>');
    } else if (html.toLowerCase().contains('<html')) {
      html = html.replaceFirst(
          RegExp(r'(<html[^>]*>)', caseSensitive: false),
          r'$1<head>' + css + r'</head>');
    } else {
      html = '<html><head>$css</head><body>$html</body></html>';
    }

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

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.value. dispose();
    super.onClose();
  }
}