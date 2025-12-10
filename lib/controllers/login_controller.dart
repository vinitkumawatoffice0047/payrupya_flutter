import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/login_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../view/other_users_screen.dart';
import '../view/payrupya_main_screen.dart';

import '../view/other_users_screen.dart';
import '../view/payrupya_main_screen.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
  Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
  Rx<TextEditingController> passwordController = TextEditingController(text: "").obs;
  RxBool isValidUserID = true.obs;
  RxBool isValidPassword = true.obs;
  RxString mobile = "".obs;
  RxString email = "".obs;
  RxString name = "".obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;


  // @override
  // void initState(){
  //   super.initState();
  //   AppSharedPreferences().getString(AppSharedPreferences.email).then((value){
  //     email = value;
  //     ConsoleLog.printColor("Email: $email");
  //   });
  //   AppSharedPreferences().getString(AppSharedPreferences.userName).then((value){
  //     name = value;
  //     ConsoleLog.printColor("Name: $name");
  //   });
  // }
  @override
  void onInit() {
    super.onInit();
    getLocation();
    init();
  }

  void init() async{
    // await askLocationPermission();
    // await getUserLocation();

    SharedPreferences.getInstance().then((value) {
      value.setBool(AppSharedPreferences.isIntro, true);
    });
    AppSharedPreferences().getString(AppSharedPreferences.mobileNo).then((value){
      mobile.value = value;
      ConsoleLog.printColor("Mobile: ${mobile.value}");
    });
    AppSharedPreferences().getString(AppSharedPreferences.email).then((value){
      email.value = value;
      ConsoleLog.printColor("Email: ${email.value}");
    });
    AppSharedPreferences().getString(AppSharedPreferences.userName).then((value){
      name.value = value;
      ConsoleLog.printColor("Name: $name");
    });
  }

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission permanently denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude.value = position.latitude;
    longitude.value = position.longitude;

    ConsoleLog.printInfo("Lat: ${latitude.value}, Lng: ${longitude.value}");
  }


  // ======================================================
  // PERMISSION HANDLER (Popup Guaranteed)
  // ======================================================
  Future<void> askLocationPermission() async {
    var status = await Permission.location.status;

    print("Current Permission Status: $status");

    if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
      print("After Request Status: $status");
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to user
      await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text("Location Permission Required"),
          content: Text("Please enable Location Permission from Settings to continue."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text("Open Settings"),
            ),
          ],
        ),
      );
    }

    if (status.isGranted) {
      print("Location Permission Granted!");
      await getUserLocation();
    }
  }

  // ======================================================
  // GET USER LOCATION (After Permission)
  // ======================================================
  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomDialog.error(
          context: Get.context!,
          message: "GPS is OFF. Please enable GPS.",
        );
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = pos.latitude;
      longitude.value = pos.longitude;

      print("LAT: ${latitude.value}, LONG: ${longitude.value}");
    } catch (e) {
      print("LOCATION ERROR: $e");
    }
  }


  // ======================================================
  // LOGIN API CALL
  // ======================================================
  // LOGIN API CALL WITH MODEL INTEGRATION
  Future<void> loginApi(BuildContext context) async {
    String mobile = mobileController.value.text.trim();
    String password = passwordController.value.text.trim();

    ConsoleLog.printColor("Mobile: $mobile");
    ConsoleLog.printColor("Password: ${password.replaceAll(RegExp(r'.'), '*')}");


    // Validation
    if (mobile.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter mobile number");
      return;
    }

    if (mobile.length != 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      return;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter password");
      return;
    }

    // Check Internet
    ConsoleLog.printInfo("Checking internet connection...");
    bool isConnected = await ConnectionValidator.isConnected();
    ConsoleLog.printInfo("Is Connected: $isConnected");

    if (!isConnected) {
      Fluttertoast.showToast(msg: "No Internet Connection!");
      return;
    }

    // Show Loader
    CustomLoading().show(context);

    Map<String, dynamic> requestBody = {
      "login": mobile,
      "password": password,
      "request_id": GlobalUtils.generateRandomId(8),
      "lat": latitude.value.toString(),
      "long": longitude.value.toString(),
    };

    ConsoleLog.printColor("LOGIN REQ: $requestBody");

    try {
      var response = await ApiProvider().loginApi(
        context,
        WebApiConstant.API_URL_LOGIN,
        requestBody,
        "",
      );

      CustomLoading().hide(context);
      ConsoleLog.printColor("LOGIN RESPONSE: $response");

      if (response == null) {
        Fluttertoast.showToast(msg: "No response from server");
        return;
      }

      // ✅ CRITICAL FIX: Handle both success and error responses safely
      try {
        // Check response code first
        String respCode = response["Resp_code"] ?? "";
        String respDesc = response["Resp_desc"] ?? "";

        ConsoleLog.printColor("Response Code: $respCode", color: "yellow");
        ConsoleLog.printColor("Response Desc: $respDesc", color: "yellow");

        if (respCode == "RCS") {
          // ✅ SUCCESS CASE - data will be a Map
          if (response["data"] == null) {
            ConsoleLog.printError("❌ No data in response");
            Fluttertoast.showToast(msg: "Login failed: No data received");
            return;
          }

          // Check if data is a Map (success case)
          if (response["data"] is! Map) {
            ConsoleLog.printError("❌ Invalid data format");
            Fluttertoast.showToast(msg: "Login failed: Invalid response format");
            return;
          }

          // Parse response using model
          LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);

          // ✅ Extract token and signature
          String token = loginResponse.data?.tokenid ?? "";
          String signature = loginResponse.data?.requestId ?? "";

          if (token.isEmpty) {
            ConsoleLog.printError("❌ Token is empty in response");
            Fluttertoast.showToast(msg: "Login failed: Invalid token");
            return;
          }

          if (signature.isEmpty) {
            ConsoleLog.printWarning("⚠️ No separate signature field found, using request_id");
            signature = loginResponse.data?.requestId ?? "";
          }

          // ✅ Save to SharedPreferences
          await AppSharedPreferences.saveLoginAuth(
            token: token,
            signature: signature,
          );

          // ✅ Save user details
          await AppSharedPreferences.setUserId(
              loginResponse.data?.userdata?.accountidf ?? ""
          );
          await AppSharedPreferences.setMobileNo(
              loginResponse.data?.userdata?.mobile ?? ""
          );
          await AppSharedPreferences.setEmail(
              loginResponse.data?.userdata?.email ?? ""
          );
          await AppSharedPreferences.setUserName(
              loginResponse.data?.userdata?.contactPerson ?? ""
          );
          await AppSharedPreferences.saveUserRole(
              loginResponse.data?.userdata?.roleidf ?? ""
          );

          ConsoleLog.printSuccess("✅ Login successful for user: ${loginResponse.data?.userdata?.contactPerson}");
          ConsoleLog.printInfo("Token: $token");
          ConsoleLog.printInfo("Signature: $signature");
          ConsoleLog.printInfo("User ID: ${loginResponse.data?.userdata?.accountidf}");

          // ✅ Navigate to Main Screen
          Fluttertoast.showToast(
            msg: "Login successful! Welcome ${loginResponse.data?.userdata?.contactPerson}",
            toastLength: Toast.LENGTH_LONG,
          );
          Get.offAll(() => PayrupyaMainScreen());

        } else if (respCode == "ERR") {
          // ✅ ERROR CASE - data might be a List or null
          ConsoleLog.printError("❌ Login failed: $respDesc");

          // Show user-friendly error message
          String errorMessage = respDesc;

          // Handle specific error messages
          if (respDesc.toLowerCase().contains('invalid mobile')) {
            errorMessage = "Invalid mobile number or password";
          } else if (respDesc.toLowerCase().contains('invalid password')) {
            errorMessage = "Invalid mobile number or password";
          } else if (respDesc.toLowerCase().contains('user not found')) {
            errorMessage = "User not found. Please register first.";
          } else if (respDesc.toLowerCase().contains('account blocked')) {
            errorMessage = "Your account has been blocked. Contact support.";
          }

          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
          );

        } else {
          // Unknown response code
          ConsoleLog.printError("❌ Unexpected response code: $respCode");
          Fluttertoast.showToast(
            msg: respDesc.isNotEmpty ? respDesc : "Login failed: Unexpected error",
            toastLength: Toast.LENGTH_LONG,
          );
        }

      } catch (parseError) {
        ConsoleLog.printError("❌ PARSE ERROR: $parseError");

        // Try to show error message from response if available
        if (response is Map && response.containsKey("Resp_desc")) {
          Fluttertoast.showToast(
            msg: response["Resp_desc"] ?? "Login failed",
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(msg: "Login failed: Unable to parse response");
        }
      }
      // // Parse response using model
      // LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);
      //
      // // SUCCESS RESPONSE
      // if (loginResponse.respCode == "RCS") {
      //   // ✅ ADD THIS DEBUG CODE
      //   ConsoleLog.printColor("=== LOGIN RESPONSE DEBUG ===", color: "green");
      //   ConsoleLog.printColor("Full Response: ${response}", color: "yellow");
      //   ConsoleLog.printColor("Token: ${loginResponse.data?.tokenid}", color: "cyan");
      //   ConsoleLog.printColor("Request ID: ${loginResponse.data?.requestId}", color: "cyan");
      //
      //   // Check if there's a signature field
      //   if (response.containsKey('signature')) {
      //     ConsoleLog.printColor("Signature Field: ${response['signature']}", color: "cyan");
      //   }
      //   if (response.containsKey('data') && response['data'] != null) {
      //     if (response['data'].containsKey('signature')) {
      //       ConsoleLog.printColor("Data.Signature: ${response['data']['signature']}", color: "cyan");
      //     }
      //   }
      //   ConsoleLog.printColor("=== END DEBUG ===", color: "green");
      //
      //   // Extract data using model properties
      //   String tokenId = loginResponse.data?.tokenid ?? "";
      //   String requestId = loginResponse.data?.requestId ?? "";
      //   String signature = loginResponse.data?.signature ?? "";
      //
      //   // ✅ If signature is empty, use requestId as fallback
      //   if (signature.isEmpty) {
      //     signature = requestId;
      //     ConsoleLog.printWarning("⚠️ No separate signature field found, using request_id");
      //   }
      //
      //   UserData? userData = loginResponse.data?.userdata;
      //
      //   // // Save auth exactly like Ionic
      //   // if (tokenId.isNotEmpty && signature.isNotEmpty) {
      //   //   await AppSharedPreferences.saveLoginAuth(
      //   //     token: tokenId,
      //   //     signature: signature,
      //   //   );
      //   // }
      //
      //   if (userData != null) {
      //     String userId = userData.accountidf ?? "";
      //     String mobileNo = userData.mobile ?? "";
      //     String userName = userData.contactPerson ?? "";
      //     String userEmail = userData.email ?? "";
      //     String userRole = userData.roleidf ?? "";
      //
      //     ConsoleLog.printSuccess("Login successful for user: $userName");
      //     ConsoleLog.printInfo("Token: $tokenId");
      //     ConsoleLog.printInfo("Request ID: $requestId");
      //     ConsoleLog.printInfo("Signature: $signature");
      //     ConsoleLog.printInfo("User ID: $userId");
      //     ConsoleLog.printInfo("Mobile: $mobileNo");
      //     ConsoleLog.printInfo("Email: $userEmail");
      //     ConsoleLog.printInfo("Role: $userRole");
      //
      //     // Save User Data
      //     SharedPreferences pref = await SharedPreferences.getInstance();
      //     pref.setBool(AppSharedPreferences.isLogin, true);
      //     pref.setString(AppSharedPreferences.token, tokenId);
      //     pref.setString(AppSharedPreferences.signature, signature);
      //     pref.setString(AppSharedPreferences.userID, userId);
      //     pref.setString(AppSharedPreferences.mobileNo, mobileNo);
      //     pref.setString(AppSharedPreferences.userName, userName);
      //     pref.setString(AppSharedPreferences.email, userEmail);
      //     pref.setString(AppSharedPreferences.userRole, userRole);
      //
      //     // Update Observables
      //     name.value = userName;
      //     email.value = userEmail;
      //     this.mobile.value = mobileNo;
      //
      //     Fluttertoast.showToast(
      //       msg: loginResponse.respDesc ?? "Login Successful",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.TOP,
      //     );
      //
      //     // Navigate based on user role
      //     if (userRole == "1") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Admin"));
      //     } else if (userRole == "2") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Super Distributor"));
      //     } else if (userRole == "3") {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Distributor"));
      //     } else if (userRole == "4") {
      //       Get.offAll(() => PayrupyaMainScreen(), transition: Transition.fadeIn);
      //     } else {
      //       Get.offAll(() => OtherUsersScreen(UserName: "Other"));
      //     }
      //   } else {
      //     CustomDialog.error(context: context, message: "User data not found!");
      //   }
      // }
      // // OTP REQUIRED CASE (TFA)
      // else if (loginResponse.respCode == "TFA") {
      //   Fluttertoast.showToast(msg: "OTP Required");
      //   // Get.to(() => OtpScreen(referenceId: response["data"]["referenceid"]));
      // }
      // // ERROR MESSAGE
      // else {
      //   ConsoleLog.printError("Login Failed: ${loginResponse.respDesc}");
      //   CustomDialog.error(
      //     context: context,
      //     message: loginResponse.respDesc ?? "Login failed!",
      //   );
      // }
    } catch (e, stackTrace) {
      ConsoleLog.printError("❌ LOGIN ERROR: $e");
      ConsoleLog.printError("STACK TRACE: $stackTrace");

      Fluttertoast.showToast(
        msg: "Technical issue occurred! Please try again.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // // Toggle password visibility
  // void togglePasswordVisibility() {
  //   obscurePassword.value = !obscurePassword.value;
  // }

  @override
  void onClose() {
    mobileController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }
  // Future<void> loginApi(BuildContext context) async {
  //   String mobile = mobileController.value.text.trim();
  //   String password = passwordController.value.text.trim();
  //
  //   if (mobile.isEmpty || password.isEmpty) {
  //     CustomDialog.error(context: context, message: "Please enter mobile and password");
  //     return;
  //   }
  //
  //   // Check Internet with detailed logging
  //   ConsoleLog.printInfo("Checking internet connection...");
  //   bool isConnected = await ConnectionValidator.isConnected();
  //   ConsoleLog.printInfo("Is Connected: $isConnected");
  //
  //   if (!isConnected) {
  //     CustomDialog.error(context: context, message: "No Internet Connection!");
  //     return;
  //   }
  //
  //   // Show Loader
  //   CustomLoading().show(context);
  //
  //   Map<String, dynamic> body = {
  //     "login": mobile,
  //     "password": password,
  //     "request_id": GlobalUtils.generateRandomId(8),
  //     "lat": latitude.value.toString(),
  //     "long": longitude.value.toString(),
  //   };
  //
  //   ConsoleLog.printColor("LOGIN REQ: $body");
  //
  //   try {
  //     var response = await ApiProvider().loginApi(
  //       context,
  //       WebApiConstant.API_URL_LOGIN,
  //       body,
  //       "",
  //     );
  //
  //     CustomLoading().hide;
  //     ConsoleLog.printColor("LOGIN RESPONSE: $response");
  //
  //     if (response == null) {
  //       CustomDialog.error(context: context, message: "Server not responding!");
  //       return;
  //     }
  //
  //     // Parse response using model
  //     LoginApiResponseModel loginResponse = LoginApiResponseModel.fromJson(response);
  //
  //     // SUCCESS RESPONSE
  //     if (response['Resp_code'] == "RCS") {
  //       var data = response["data"];
  //
  //       var userData = data["userdata"];
  //
  //       // Safe String Extraction with null checks
  //       String tokenId = data["tokenid"]?.toString() ?? "";
  //       String userId = userData["accountidf"]?.toString() ?? "";
  //       String mobileNo = userData["mobile"]?.toString() ?? "";
  //       String userName = userData["contact_person"]?.toString() ?? "";
  //       String userEmail = userData["email"]?.toString() ?? "";
  //       String userRole = userData["roleidf"]?.toString() ?? "";
  //
  //       ConsoleLog.printSuccess("Login successful for user: $userName");
  //       ConsoleLog.printInfo("User ID: $userId");
  //       ConsoleLog.printInfo("Mobile: $mobileNo");
  //       ConsoleLog.printInfo("Email: $userEmail");
  //       ConsoleLog.printInfo("Role: $userRole");
  //
  //       // Save User Data
  //       SharedPreferences pref = await SharedPreferences.getInstance();
  //       pref.setBool(AppSharedPreferences.isLogin, true);
  //       pref.setString(AppSharedPreferences.token, tokenId);
  //       pref.setString(AppSharedPreferences.userID, userId);
  //       pref.setString(AppSharedPreferences.mobileNo, mobileNo);
  //       pref.setString(AppSharedPreferences.userName, userName);
  //       pref.setString(AppSharedPreferences.email, userEmail);
  //       pref.setString(AppSharedPreferences.userRole, userRole);
  //
  //       // Update Observables
  //       name.value = userName;
  //       email.value = userEmail;
  //       this.mobile.value = mobileNo;
  //
  //       Fluttertoast.showToast(
  //         msg: response["Resp_desc"] ?? "Login Successful",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.TOP,
  //       );
  //
  //       if(userRole == "1"){
  //         OtherUsersScreen(UserName: "Admin",);
  //         //Admin
  //       }else if(userRole == "2"){
  //         OtherUsersScreen(UserName: "Super Distributor",);
  //         //SuperDistributor
  //       }else if(userRole == "3"){
  //         OtherUsersScreen(UserName: "Distributor",);
  //         //Distributor
  //       }else if(userRole == "4"){
  //         Get.offAll(PayrupyaMainScreen(), transition: Transition.fadeIn);
  //         // OtherUsersScreen(UserName: "Retailer",);
  //         //Retailor
  //       }else{
  //         OtherUsersScreen(UserName: "Other",);
  //         //Other
  //       }
  //       // Get.offAll(MainScreen(selectedIndex: 0));
  //       // Get.offAll(PayrupyaMainScreen());
  //     }
  //
  //     // OTP REQUIRED CASE (TFA)
  //     else if (response['Resp_code'] == "TFA") {
  //       Fluttertoast.showToast(msg: "OTP Required");
  //       // Get.to(() => OtpScreen(referenceId: response["data"]["referenceid"]));
  //     }
  //
  //     // ERROR MESSAGE
  //     else {
  //       ConsoleLog.printError("Login Failed: ${response['Resp_desc']}");
  //       CustomDialog.error(
  //         context: context,
  //         message: response["Resp_desc"] ?? "Login failed!",
  //       );
  //     }
  //   } catch (e) {
  //     CustomLoading().hide;
  //     ConsoleLog.printError("LOGIN ERROR: $e");
  //     CustomDialog.error(context: context, message: "Technical issue, please try again!");
  //   }
  // }
}
