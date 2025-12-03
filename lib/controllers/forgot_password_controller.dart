import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:payrupya/controllers/login_controller.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../utils/ConsoleLog.dart';
import '../utils/global_utils.dart';

class ForgotPasswordController extends GetxController {
  // Text Controllers
  Rx<TextEditingController> mobileController = TextEditingController().obs;
  Rx<TextEditingController> otpController = TextEditingController().obs;
  Rx<TextEditingController> newPasswordController = TextEditingController().obs;
  Rx<TextEditingController> confirmPasswordController = TextEditingController().obs;
  LoginController loginController = Get.put(LoginController());

  // State Management
  RxBool isOTPBlock = false.obs;
  RxBool changePass = false.obs;
  RxString referenceId = ''.obs;

  // // Location (you can get from GPS or set default)
  // String lat = "0.0";
  // String long = "0.0";

  // Generate Request ID
  String generateRequestId() {
    return GlobalUtils.generateRandomId(8);
  }

  // Step 1: Send OTP
  Future<void> sendOTP(BuildContext context) async {
    try {
      String mobile = mobileController.value.text.trim();

      if (mobile.isEmpty || mobile.length != 10) {
        Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Sending OTP for password reset: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_SEND_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          referenceId.value = data['data']?['referenceid']?.toString() ?? "";
          isOTPBlock.value = true;
          ConsoleLog.printSuccess("OTP sent successfully");
          Fluttertoast.showToast(
            msg: "OTP sent successfully on $mobile",
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to send OTP",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error sending OTP: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOTP(BuildContext context) async {
    try {
      String mobile = mobileController.value.text.trim();
      String otp = otpController.value.text.trim();

      if (otp.isEmpty || otp.length != 6) {
        Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
        return;
      }

      if (referenceId.value.isEmpty) {
        Fluttertoast.showToast(msg: "Reference ID not found. Please resend OTP");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        "referenceid": referenceId.value,
        "otp": otp,
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Verifying OTP: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_VERIFY_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          isOTPBlock.value = false;
          changePass.value = true;
          ConsoleLog.printSuccess("OTP verified successfully");
          Fluttertoast.showToast(
            msg: "OTP verified successfully",
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Invalid OTP",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error verifying OTP: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Step 3: Change Password
  Future<void> changePassword(BuildContext context) async {
    try {
      String mobile = mobileController.value.text.trim();
      String newPassword = newPasswordController.value.text.trim();
      String confirmPassword = confirmPasswordController.value.text.trim();

      if (newPassword.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter new password");
        return;
      }

      if (newPassword.length < 6) {
        Fluttertoast.showToast(msg: "Password must be at least 6 characters");
        return;
      }

      if (confirmPassword.isEmpty) {
        Fluttertoast.showToast(msg: "Please confirm password");
        return;
      }

      if (newPassword != confirmPassword) {
        Fluttertoast.showToast(msg: "Passwords do not match");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "newpass": newPassword,
        "confirmpass": confirmPassword,
      };

      ConsoleLog.printInfo("Changing password: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_CHANGE,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          ConsoleLog.printSuccess("Password changed successfully");
          
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  "Success",
                  style: TextStyle(color: Colors.green),
                ),
                content: Text("Password changed successfully!", style: TextStyle(
                  color: Colors.black,
                ),),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      resetController();
                      Get.back(); // Go back to login screen
                    },
                    child: Text("OK", style: TextStyle(
                      color: Colors.black,
                    ),),
                  ),
                ],
              );
            },
          );
        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to change password",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error changing password: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Resend OTP
  Future<void> resendOTP(BuildContext context) async {
    try {
      String mobile = mobileController.value.text.trim();

      if (referenceId.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter mobile number first");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        "referenceid": referenceId.value,
        "requestfor": "RESETPASS",
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Resending OTP: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_RESEND_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        if (data['Resp_code'] == 'RCS') {
          referenceId.value = data['data']?['referenceid']?.toString() ?? "";
          ConsoleLog.printSuccess("OTP resent successfully");
          Fluttertoast.showToast(msg: "OTP sent successfully");
        } else {
          Fluttertoast.showToast(
            msg: data['Resp_desc'] ?? "Failed to resend OTP",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error resending OTP: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Reset Controller
  void resetController() {
    mobileController.value.clear();
    otpController.value.clear();
    newPasswordController.value.clear();
    confirmPasswordController.value.clear();
    isOTPBlock.value = false;
    changePass.value = false;
    referenceId.value = '';
  }

  @override
  void onClose() {
    mobileController.value.dispose();
    otpController.value.dispose();
    newPasswordController.value.dispose();
    confirmPasswordController.value.dispose();
    super.onClose();
  }
}
