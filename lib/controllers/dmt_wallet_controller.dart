// lib/controllers/dmt_wallet_controller.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/add_beneficiary_response_model.dart';
import '../models/add_sender_response_model.dart';
import '../models/check_sender_response_model.dart';
import '../models/delete_beneficiary_response_model.dart';
import '../models/get_all_banks_response_model.dart';
import '../models/get_beneficiary_list_response_model.dart';
import '../models/transfer_money_response_model.dart';
import '../models/verify_account_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../view/login_screen.dart';
import 'login_controller.dart';

class DmtWalletController extends GetxController {
  LoginController loginController = Get.put(LoginController());

  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadAuthCredentials();
  }

  // Load both token and signature
  Future<void> loadAuthCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String token = prefs.getString(AppSharedPreferences.token) ?? '';
      String signature = prefs.getString(AppSharedPreferences.signature) ?? '';

      userAuthToken.value = token;
      userSignature.value = signature;

      ConsoleLog.printInfo("Token: ${token.isNotEmpty ? 'Found' : 'NOT FOUND'}");
      ConsoleLog.printInfo("Signature: ${signature.isNotEmpty ? 'Found' : 'NOT FOUND'}");

    } catch (e) {
      ConsoleLog.printError("Error loading auth credentials: $e");
    }
  }


  // Text Controllers
  Rx<TextEditingController> senderMobileController = TextEditingController().obs;
  Rx<TextEditingController> senderNameController = TextEditingController().obs;
  Rx<TextEditingController> senderAddressController = TextEditingController().obs;
  Rx<TextEditingController> senderPincodeController = TextEditingController().obs;
  
  Rx<TextEditingController> beneNameController = TextEditingController().obs;
  Rx<TextEditingController> beneAccountController = TextEditingController().obs;
  Rx<TextEditingController> beneIfscController = TextEditingController().obs;
  Rx<TextEditingController> beneMobileController = TextEditingController().obs;
  
  Rx<TextEditingController> transferAmountController = TextEditingController().obs;
  Rx<TextEditingController> tpinController = TextEditingController().obs;

  // Observable variables
  RxString selectedState = ''.obs;
  RxString selectedCity = ''.obs;
  RxString selectedPincode = ''.obs;
  RxString selectedBank = ''.obs;
  RxString selectedBankId = ''.obs;
  RxString selectedIfsc = ''.obs;
  
  RxString referenceId = ''.obs;
  RxBool isSenderVerified = false.obs;
  RxBool isMobileVerified = false.obs;
  RxBool isAccountVerified = false.obs;
  
  // Sender Data
  Rx<SenderData?> currentSender = Rx<SenderData?>(null);
  
  // Beneficiary List
  RxList<BeneficiaryData> beneficiaryList = <BeneficiaryData>[].obs;
  RxList<BeneficiaryData> filteredBeneficiaryList = <BeneficiaryData>[].obs;
  
  // Banks List
  RxList<BankData> banksList = <BankData>[].obs;
  
  // Search
  RxString searchQuery = ''.obs;

  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }

  Future<bool> isTokenValid() async {
    // Check if token exists and is not expired
    if (userAuthToken.value.isEmpty || userSignature.value.isEmpty) {
      ConsoleLog.printError("❌ Token or Signature missing");
      return false;
    }

    // You can add timestamp-based expiry check here if needed
    return true;
  }

  Future<void> refreshToken(BuildContext context) async {
    ConsoleLog.printWarning("⚠️ Token expired, please login again");

    // Clear stored credentials
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login
    Get.offAll(() => LoginScreen());
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
        "service": "DMT",
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

      CustomLoading().hide;
      if (response == null) {
        CustomDialog.error(context: context, message: "No response from server");
        return;
      }

      ConsoleLog.printColor("CHECK SENDER RESPONSE: ${response?.data}");

      if (response.statusCode == 200) {
        CheckSenderResponseModel checkSenderResponse = 
            CheckSenderResponseModel.fromJson(response.data);

        if (checkSenderResponse.respCode == "RCS") {
          // Sender exists
          currentSender.value = checkSenderResponse.data;
          isSenderVerified.value = true;
          
          ConsoleLog.printSuccess("Sender found: ${currentSender.value?.name}");
          Fluttertoast.showToast(msg: "Sender verified successfully");
          
          // Fetch beneficiary list
          await getBeneficiaryList(context, mobile);
          
        } else if (checkSenderResponse.respCode == "RNF") {
          // Sender not found - need to register
          currentSender.value = checkSenderResponse.data;
          isSenderVerified.value = false;
          
          ConsoleLog.printWarning("Sender not found");
          Fluttertoast.showToast(msg: "Please register sender first");
          
        } else if (checkSenderResponse.respCode == "ERR") {
          ConsoleLog.printError("Error: ${checkSenderResponse.respDesc}");

          if (checkSenderResponse.respDesc?.toLowerCase().contains('unauthorized') ?? false) {
            CustomDialog.error(
              context: context,
              message: "Authentication failed. Please login again.",
            );
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
      CustomLoading().hide;
      ConsoleLog.printError("CHECK SENDER ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 2. ADD SENDER (REGISTER REMITTER)
  // ============================================
  Future<void> addSender(BuildContext context) async {
    try {
      String mobile = senderMobileController.value.text.trim();
      String name = senderNameController.value.text.trim();
      String address = senderAddressController.value.text.trim();

      if (mobile.isEmpty || name.isEmpty || address.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields");
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
        "name": name,
        "address": address,
        "state": selectedState.value,
        "city": selectedCity.value,
        "pincode": selectedPincode.value,
        "service": "DMT",
        "request_type": "REGISTER REMITTER",
      };

      ConsoleLog.printColor("ADD SENDER REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_SENDER,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;
      ConsoleLog.printColor("ADD SENDER RESPONSE: ${response?.data}");

      if (response != null && response.statusCode == 200) {
        AddSenderResponseModel addSenderResponse = 
            AddSenderResponseModel.fromJson(response.data);

        if (addSenderResponse.respCode == "RCS") {
          referenceId.value = addSenderResponse.data?.referenceid ?? "";
          
          ConsoleLog.printSuccess("Sender registered, OTP sent");
          Fluttertoast.showToast(msg: "OTP sent successfully");
          
          // Navigate to OTP screen or show OTP dialog
          
        } else {
          CustomDialog.error(
            context: context,
            message: addSenderResponse.respDesc ?? "Failed to add sender",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("ADD SENDER ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 3. VERIFY SENDER OTP
  // ============================================
  Future<void> verifySenderOtp(BuildContext context, String otp) async {
    try {
      if (otp.isEmpty || otp.length != 6) {
        Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
        return;
      }

      if (referenceId.value.isEmpty) {
        Fluttertoast.showToast(msg: "Reference ID not found");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobileController.value.text.trim(),
        "otp": otp,
        "referenceid": referenceId.value,
        "service": "DMT",
        "request_type": "VERIFY OTP",
      };

      ConsoleLog.printColor("VERIFY SENDER OTP REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_VERIFY_SENDER_OTP,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        
        if (data['Resp_code'] == 'RCS') {
          isSenderVerified.value = true;
          ConsoleLog.printSuccess("Sender OTP verified successfully");
          Fluttertoast.showToast(msg: "Sender verified successfully");
          
          // Refresh sender details
          await checkSender(context, senderMobileController.value.text.trim());
          
        } else {
          CustomDialog.error(
            context: context,
            message: data['Resp_desc'] ?? "Invalid OTP",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("VERIFY SENDER OTP ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 4. GET BENEFICIARY LIST
  // ============================================
  Future<void> getBeneficiaryList(BuildContext context, String senderMobile) async {
    try {
      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": senderMobile,
        "service": "DMT",
        "start": "0",
        "limit": "100",
        "searchby": "",
      };

      ConsoleLog.printColor("GET BENEFICIARY LIST REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_BENEFICIARY_LIST,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        GetBeneficiaryListResponseModel beneListResponse = 
            GetBeneficiaryListResponseModel.fromJson(response.data);

        if (beneListResponse.respCode == "RCS" && beneListResponse.data != null) {
          beneficiaryList.value = beneListResponse.data!;
          filteredBeneficiaryList.value = beneListResponse.data!;
          
          ConsoleLog.printSuccess("Beneficiaries loaded: ${beneficiaryList.length}");
          
        } else {
          beneficiaryList.clear();
          filteredBeneficiaryList.clear();
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("GET BENEFICIARY LIST ERROR: $e");
    }
  }

  // ============================================
  // 5. ADD BENEFICIARY
  // ============================================
  Future<void> addBeneficiary(BuildContext context) async {
    try {
      String beneName = beneNameController.value.text.trim();
      String accountNumber = beneAccountController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();
      String mobile = beneMobileController.value.text.trim();

      if (beneName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields");
        return;
      }

      if (!isAccountVerified.value) {
        Fluttertoast.showToast(msg: "Please verify account first");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": currentSender.value?.mobile ?? "",
        "bene_name": beneName,
        "account_number": accountNumber,
        "ifsc": ifsc,
        "mobile": mobile,
        "bank_id": selectedBankId.value,
        "service": "DMT",
        "request_type": "ADD BENEFICIARY",
      };

      ConsoleLog.printColor("ADD BENEFICIARY REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_ADD_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        AddBeneficiaryResponseModel addBeneResponse = 
            AddBeneficiaryResponseModel.fromJson(response.data);

        if (addBeneResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Beneficiary added successfully");
          Fluttertoast.showToast(msg: "Beneficiary added successfully");
          
          // Refresh beneficiary list
          await getBeneficiaryList(context, currentSender.value?.mobile ?? "");
          
          // Clear form
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
      CustomLoading().hide;
      ConsoleLog.printError("ADD BENEFICIARY ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 6. DELETE BENEFICIARY
  // ============================================
  Future<void> deleteBeneficiary(BuildContext context, String beneId) async {
    try {
      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": currentSender.value?.mobile ?? "",
        "bene_id": beneId,
        "service": "DMT",
        "request_type": "DELETE BENEFICIARY",
      };

      ConsoleLog.printColor("DELETE BENEFICIARY REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_DELETE_BENEFICIARY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        DeleteBeneficiaryResponseModel deleteResponse = 
            DeleteBeneficiaryResponseModel.fromJson(response.data);

        if (deleteResponse.respCode == "RCS" && deleteResponse.data?.deleted == true) {
          ConsoleLog.printSuccess("Beneficiary deleted successfully");
          Fluttertoast.showToast(msg: "Beneficiary deleted successfully");
          
          // Remove from list
          beneficiaryList.removeWhere((bene) => bene.beneId == beneId);
          filteredBeneficiaryList.removeWhere((bene) => bene.beneId == beneId);
          
        } else {
          CustomDialog.error(
            context: context,
            message: deleteResponse.respDesc ?? "Failed to delete beneficiary",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("DELETE BENEFICIARY ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 7. VERIFY ACCOUNT
  // ============================================
  Future<void> verifyAccount(BuildContext context) async {
    try {
      String accountNumber = beneAccountController.value.text.trim();
      String ifsc = beneIfscController.value.text.trim();

      if (accountNumber.isEmpty || ifsc.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter account number and IFSC");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "account_number": accountNumber,
        "ifsc": ifsc,
        "bank_id": selectedBankId.value,
      };

      ConsoleLog.printColor("VERIFY ACCOUNT REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_VERIFY_ACCOUNT,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        VerifyAccountResponseModel verifyResponse = 
            VerifyAccountResponseModel.fromJson(response.data);

        if (verifyResponse.respCode == "RCS" && verifyResponse.data?.verified == true) {
          isAccountVerified.value = true;
          
          // Auto-fill beneficiary name
          if (verifyResponse.data?.beneName != null) {
            beneNameController.value.text = verifyResponse.data!.beneName!;
          }
          
          ConsoleLog.printSuccess("Account verified: ${verifyResponse.data?.beneName}");
          Fluttertoast.showToast(msg: "Account verified successfully");
          
        } else {
          isAccountVerified.value = false;
          CustomDialog.error(
            context: context,
            message: verifyResponse.respDesc ?? "Account verification failed",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("VERIFY ACCOUNT ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 8. TRANSFER MONEY
  // ============================================
  Future<void> transferMoney(BuildContext context, BeneficiaryData beneficiary) async {
    try {
      String amount = transferAmountController.value.text.trim();
      String tpin = tpinController.value.text.trim();

      if (amount.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter amount");
        return;
      }

      double amountValue = double.tryParse(amount) ?? 0;
      if (amountValue <= 0) {
        Fluttertoast.showToast(msg: "Please enter valid amount");
        return;
      }

      if (tpin.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter TPIN");
        return;
      }

      CustomLoading().show(context);

      Map<String, dynamic> body = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "sender": currentSender.value?.mobile ?? "",
        "bene_id": beneficiary.beneId,
        "amount": amount,
        "tpin": tpin,
        "service": "DMT",
        "request_type": "TRANSFER",
      };

      ConsoleLog.printColor("TRANSFER MONEY REQ: $body");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_TRANSFER_MONEY,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      CustomLoading().hide;

      if (response != null && response.statusCode == 200) {
        TransferMoneyResponseModel transferResponse = 
            TransferMoneyResponseModel.fromJson(response.data);

        if (transferResponse.respCode == "RCS") {
          ConsoleLog.printSuccess("Transfer successful: ${transferResponse.data?.txnId}");
          
          // Show success dialog
          showSuccessDialog(context, transferResponse.data);
          
          // Clear form
          transferAmountController.value.clear();
          tpinController.value.clear();
          
        } else {
          CustomDialog.error(
            context: context,
            message: transferResponse.respDesc ?? "Transfer failed",
          );
        }
      }
    } catch (e) {
      CustomLoading().hide;
      ConsoleLog.printError("TRANSFER MONEY ERROR: $e");
      CustomDialog.error(context: context, message: "Technical issue!");
    }
  }

  // ============================================
  // 9. GET ALL BANKS LIST
  // ============================================
  Future<void> getAllBanks(BuildContext context) async {
    try {
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
  // 10. SEARCH BENEFICIARIES
  // ============================================
  void searchBeneficiaries(String query) {
    searchQuery.value = query.toLowerCase();
    
    if (query.isEmpty) {
      filteredBeneficiaryList.value = beneficiaryList;
    } else {
      filteredBeneficiaryList.value = beneficiaryList.where((bene) {
        return (bene.beneName?.toLowerCase().contains(query) ?? false) ||
               (bene.accountNumber?.contains(query) ?? false) ||
               (bene.bankName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  // ============================================
  // SHOW SUCCESS DIALOG
  // ============================================
  void showSuccessDialog(BuildContext context, TransferData? data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Transfer Successful!', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Amount: ₹${data?.amount}'),
              Text('UTR: ${data?.utr ?? "N/A"}'),
              Text('Transaction ID: ${data?.txnId}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void onClose() {
    senderMobileController.value.dispose();
    senderNameController.value.dispose();
    senderAddressController.value.dispose();
    senderPincodeController.value.dispose();
    beneNameController.value.dispose();
    beneAccountController.value.dispose();
    beneIfscController.value.dispose();
    beneMobileController.value.dispose();
    transferAmountController.value.dispose();
    tpinController.value.dispose();
    super.onClose();
  }
}
