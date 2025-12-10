import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:payrupya/controllers/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/forgot_password_models.dart';
import '../models/location_api_models.dart';
import '../models/signup_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/global_utils.dart';
import '../view/login_screen.dart';
import '../view/otp_verification_screen.dart';

class SignupController extends GetxController {
  LoginController loginController = Get.put(LoginController());

  // Text Controllers
  Rx<TextEditingController> firstNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> lastNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
  Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
  Rx<TextEditingController> passwordController = TextEditingController(text: "").obs;
  Rx<TextEditingController> permanentAddressController = TextEditingController(text: "").obs;
  Rx<TextEditingController> shopNameController = TextEditingController(text: "").obs;
  Rx<TextEditingController> panController = TextEditingController(text: "").obs;
  Rx<TextEditingController> gstinController = TextEditingController(text: "").obs;
  Rx<TextEditingController> shopAddressController = TextEditingController(text: "").obs;
  Rx<TextEditingController> aadharController = TextEditingController(text: "").obs;

  // Validation flags
  RxBool isChecked = false.obs;
  RxBool isValidName = false.obs;
  RxBool isValidEmail = false.obs;
  RxBool isMobileNo = false.obs;
  RxBool isPassword = true.obs;
  RxBool isMobileVerified = false.obs;
  RxBool isEmailVerified = false.obs;

  // Dropdown selections
  RxString selectedGender = ''.obs;
  RxString selectedState = ''.obs;
  RxString selectedCity = ''.obs;
  RxString selectedPincode = ''.obs;
  RxString referenceId = ''.obs;

  // Lists for dropdowns
  RxList<String> stateList = <String>[].obs;
  RxList<String> cityList = <String>[].obs;
  RxList<String> pincodeList = <String>[].obs;

  // OTP Storage
  String mobileOtp = "";
  String emailOtp = "";

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getLocation();
    // Fetch states when controller initializes
    Future.delayed(Duration(seconds: 2), () {
      if (Get.context != null) {
        fetchStates(Get.context!);
      }
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

  // Generate Request ID
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }

  // Send Mobile OTP
  Future<void> sendMobileOtp(BuildContext context) async {
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

      ConsoleLog.printInfo("Sending mobile OTP: $dict");

      // // Navigate to OTP screen
      // Get.to(() => OtpVerificationScreen(
      //   phoneNumber: mobile,
      //   isEmail: false,
      // ));

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_SEND_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        // Parse using model
        ForgotPasswordSendOtpResponseModel otpResponse =
        ForgotPasswordSendOtpResponseModel.fromJson(data);

        if (otpResponse.respCode == 'RCS') {
          mobileOtp = otpResponse.otp?.toString() ?? "";
          referenceId.value = otpResponse.data?.referenceid ?? "";
          // mobileOtp = data['otp']?.toString() ?? "";
          // referenceId.value = data['data']?['referenceid']?.toString() ?? "";
          ConsoleLog.printColor("===>>>>> referenceId ${referenceId.value}");
          ConsoleLog.printSuccess("Mobile OTP sent successfully");
          // Fluttertoast.showToast(msg: otpResponse.respDesc ?? "OTP sent successfully");
          // Fluttertoast.showToast(msg: data['Resp_desc'] ?? "OTP sent successfully");

          // Navigate to OTP screen with phone number
          Get.to(() => OtpVerificationScreen(
            phoneNumber: mobile,
            isEmail: false,
            referenceId: referenceId.value, // Pass referenceId
          ));
          Fluttertoast.showToast(
            msg: "OTP sent successfully on $mobile",
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg: otpResponse.respDesc ?? "Failed to send OTP",
            // msg: data['Resp_desc'] ?? "Failed to send OTP",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Error sending mobile OTP: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Resend OTP for signup (similar to forgot password)
  Future<void> resendMobileOtp(BuildContext context) async {
    try {
      String mobile = mobileController.value.text.trim();

      if (mobile.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter mobile number first");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        // "referenceid": referenceId.value,
        // "requestfor": "SIGNUP", // Change to SIGNUP
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Resending OTP for signup: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_SEND_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        // Parse using resend model
        ForgotPasswordResendOtpResponseModel resendResponse =
        ForgotPasswordResendOtpResponseModel.fromJson(data);
        if (resendResponse.respCode == 'RCS') {
          String newReferenceId = resendResponse.data?.referenceid ?? "";
          referenceId.value = newReferenceId;
          ConsoleLog.printSuccess("OTP resent successfully");
          Fluttertoast.showToast(msg: resendResponse.respDesc ?? "OTP sent successfully");
        } else {
          Fluttertoast.showToast(
            msg: resendResponse.respDesc ?? "Failed to resend OTP",
            toastLength: Toast.LENGTH_LONG,
          );
        }
        // if (data['Resp_code'] == 'RCS') {
        //   String newReferenceId = data['data']?['referenceid']?.toString() ?? "";
        //   referenceId.value = newReferenceId;
        //   ConsoleLog.printSuccess("OTP resent successfully");
        //   Fluttertoast.showToast(msg: "OTP sent successfully");
        // } else {
        //   Fluttertoast.showToast(
        //     msg: data['Resp_desc'] ?? "Failed to resend OTP",
        //     toastLength: Toast.LENGTH_LONG,
        //   );
        // }
      }
    } catch (e) {
      ConsoleLog.printError("Error resending OTP: $e");
      Fluttertoast.showToast(msg: "Technical issue, please try again!");
    }
  }

  // Verify Mobile OTP
  Future<void> verifyMobileOtp(BuildContext context, String otp, String referenceId) async {
    try {
      String mobile = mobileController.value.text.trim();

      if (otp.isEmpty || otp.length != 6) {
        Fluttertoast.showToast(msg: "Please enter 6-digit OTP");
        return;
      }

      if (referenceId.isEmpty) {
        Fluttertoast.showToast(msg: "Reference ID not found. Please resend OTP");
        return;
      }

      Map<String, dynamic> dict = {
        "login": mobile,
        "referenceid": referenceId,
        "otp": otp.trim(),
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Verifying mobile OTP: $dict");
      isMobileVerified.value = true;

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_FORGOT_PASSWORD_VERIFY_OTP,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        // Parse using verify model
        ForgotPasswordVerifyOtpResponseModel verifyResponse = ForgotPasswordVerifyOtpResponseModel.fromJson(data);
        if (verifyResponse.respCode == 'RCS' && verifyResponse.data?.otpVerified == true) {
          isMobileVerified.value = true;
          ConsoleLog.printSuccess("Mobile verified successfully");
          Fluttertoast.showToast(msg: verifyResponse.respDesc ?? "Mobile number verified successfully");
          Get.back(); // Close OTP screen
        } else {
          Fluttertoast.showToast(msg: verifyResponse.respDesc ?? "Invalid OTP");
        }
        // if (data['Resp_code'] == 'RCS') {
        //   isMobileVerified.value = true;
        //   ConsoleLog.printSuccess("Mobile verified successfully");
        //   Fluttertoast.showToast(msg: "Mobile number verified successfully");
        //
        //   Get.back(); // Close OTP screen
        // } else {
        //   Fluttertoast.showToast(msg: data['Resp_desc'] ?? "Invalid OTP");
        // }
      }
    } catch (e) {
      ConsoleLog.printError("Error verifying mobile OTP: $e");
      Fluttertoast.showToast(msg: "Error verifying OTP");
    }
  }

  // // Send Email OTP
  // Future<void> sendEmailOtp(BuildContext context) async {
  //   try {
  //     String email = emailController.value.text.trim();
  //
  //     if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
  //       Fluttertoast.showToast(msg: "Please enter valid email");
  //       return;
  //     }
  //
  //     Map<String, dynamic> dict = {
  //       "request_id": generateRequestId(),
  //       "email": email,
  //     };
  //
  //     ConsoleLog.printInfo("Sending email OTP: $dict");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_SEND_EMAIL_OTP,
  //       dict,
  //       "",
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       var data = response.data;
  //       if (data['Resp_code'] == 'RCS') {
  //         emailOtp = data['otp']?.toString() ?? "";
  //         ConsoleLog.printSuccess("Email OTP sent successfully");
  //         Fluttertoast.showToast(msg: data['Resp_desc'] ?? "OTP sent successfully");
  //
  //         // Navigate to OTP screen
  //         Get.to(() => OtpVerificationScreen(
  //           phoneNumber: email,
  //           isEmail: true,
  //         ));
  //       } else {
  //         Fluttertoast.showToast(msg: data['Resp_desc'] ?? "Failed to send OTP");
  //       }
  //     }
  //   } catch (e) {
  //     ConsoleLog.printError("Error sending email OTP: $e");
  //     Fluttertoast.showToast(msg: "Error sending OTP");
  //   }
  // }
  //
  // // Verify Email OTP
  // Future<void> verifyEmailOtp(BuildContext context, String otp) async {
  //   try {
  //     Map<String, dynamic> dict = {
  //       "request_id": generateRequestId(),
  //       "email": emailController.value.text.trim(),
  //       "otp": otp,
  //     };
  //
  //     ConsoleLog.printInfo("Verifying email OTP: $dict");
  //
  //     var response = await ApiProvider().requestPostForApi(
  //       context,
  //       WebApiConstant.API_URL_VERIFY_EMAIL_OTP,
  //       dict,
  //       "",
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       var data = response.data;
  //       if (data['Resp_code'] == 'RCS') {
  //         isEmailVerified.value = true;
  //         ConsoleLog.printSuccess("Email verified successfully");
  //         Fluttertoast.showToast(msg: "Email verified successfully");
  //         Get.back(); // Close OTP screen
  //       } else {
  //         Fluttertoast.showToast(msg: data['Resp_desc'] ?? "Invalid OTP");
  //       }
  //     }
  //   } catch (e) {
  //     ConsoleLog.printError("Error verifying email OTP: $e");
  //     Fluttertoast.showToast(msg: "Error verifying OTP");
  //   }
  // }

  // Fetch States
  Future<void> fetchStates(BuildContext context) async {
    try {
      if (loginController.latitude.value == 0.0 || loginController.longitude.value == 0.0) {
        ConsoleLog.printInfo("Latitude: ${loginController.latitude.value}");
        ConsoleLog.printInfo("Longitude: ${loginController.longitude.value}");
        // Fluttertoast.showToast(msg: "Please enable location service");
        return;
      }

      Map<String, dynamic> dict = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
      };

      ConsoleLog.printInfo("Fetching states with params: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_STATES,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;

        // Parse using model
        GetStatesResponseModel statesResponse = GetStatesResponseModel.fromJson(data);

        if (statesResponse.respCode == 'RCS' && statesResponse.data != null) {
          stateList.value = statesResponse.data!
              .map((state) => state.stateName ?? "")
              .where((name) => name.isNotEmpty)
              .toList();
          ConsoleLog.printSuccess("States loaded: ${stateList.length}");
        } else {
          Fluttertoast.showToast(msg: statesResponse.respDesc ?? "Failed to load states");
        }
        // if (data['Resp_code'] == 'RCS' && data['data'] != null) {
        //   List<dynamic> states = data['data'];
        //   stateList.value = states
        //       .map((state) => state['state_name'].toString())
        //       .toList();
        //   ConsoleLog.printSuccess("States loaded: ${stateList.length}");
        // } else {
        //   Fluttertoast.showToast(msg: "Failed to load states");
        // }
      }
    } catch (e) {
      ConsoleLog.printError("Error fetching states: $e");
      Fluttertoast.showToast(msg: "Error loading states");
    }
  }

  // Fetch Cities
  Future<void> fetchCities(BuildContext context) async {
    try {
      if (selectedState.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please select state first");
        return;
      }

      Map<String, dynamic> dict = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "state_name": selectedState.value,
      };

      ConsoleLog.printInfo("Fetching cities with params: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_CITIES,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        // Parse using model
        GetCitiesResponseModel citiesResponse = GetCitiesResponseModel.fromJson(data);

        if (citiesResponse.respCode == 'RCS' && citiesResponse.data != null) {
          cityList.value = citiesResponse.data!
              .map((city) => city.city ?? "")
              .where((name) => name.isNotEmpty)
              .toList();
          ConsoleLog.printSuccess("Cities loaded: ${cityList.length}");

          // Clear previous selections
          selectedCity.value = '';
          selectedPincode.value = '';
          pincodeList.clear();
        } else {
          Fluttertoast.showToast(msg: citiesResponse.respDesc ?? "Failed to load cities");
          cityList.clear();
          selectedCity.value = '';
          selectedPincode.value = '';
          pincodeList.clear();
        }
      }
      //   if (data['Resp_code'] == 'RCS' && data['data'] != null) {
      //     List<dynamic> cities = data['data'];
      //     cityList.value = cities
      //         .map((city) => city['city'].toString())
      //         .toList();
      //     ConsoleLog.printSuccess("Cities loaded: ${cityList.length}");
      //
      //     // Clear previous selections
      //     selectedCity.value = '';
      //     selectedPincode.value = '';
      //     pincodeList.clear();
      //   } else {
      //     Fluttertoast.showToast(msg: "Failed to load cities");
      //     cityList.clear();
      //     selectedCity.value = '';
      //     selectedPincode.value = '';
      //     pincodeList.clear();
      //   }
      // }
    } catch (e) {
      ConsoleLog.printError("Error fetching cities: $e");
      Fluttertoast.showToast(msg: "Error loading cities");
      cityList.clear();
      selectedCity.value = '';
      selectedPincode.value = '';
      pincodeList.clear();
    }
  }

  // Fetch Pincodes
  Future<void> fetchPincodes(BuildContext context) async {
    try {
      if (selectedState.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please select state first");
        return;
      }

      if (selectedCity.value.isEmpty) {
        Fluttertoast.showToast(msg: "Please select city first");
        return;
      }

      Map<String, dynamic> dict = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "state_name": selectedState.value,
        "city": selectedCity.value,
      };

      ConsoleLog.printInfo("Fetching pincodes with params: $dict");

      var response = await ApiProvider().requestPostForApi(
        context,
        WebApiConstant.API_URL_GET_PINCODES,
        dict,
        "",
      );

      if (response != null && response.statusCode == 200) {
        var data = response.data;
        // Parse using model
        GetPincodesResponseModel pincodesResponse = GetPincodesResponseModel.fromJson(data);

        if (pincodesResponse.respCode == 'RCS' && pincodesResponse.data != null) {
          pincodeList.value = pincodesResponse.data!
              .map((pincode) => pincode.pincode ?? "")
              .where((code) => code.isNotEmpty)
              .toList();
          ConsoleLog.printSuccess("Pincodes loaded: ${pincodeList.length}");

          // Clear previous selection
          selectedPincode.value = '';
        } else {
          Fluttertoast.showToast(msg: pincodesResponse.respDesc ?? "Failed to load pincodes");
          pincodeList.clear();
          selectedPincode.value = '';
        }
      }
      //   if (data['Resp_code'] == 'RCS' && data['data'] != null) {
      //     List<dynamic> pincodes = data['data'];
      //     pincodeList.value = pincodes
      //         .map((pincode) => pincode['pincode'].toString())
      //         .toList();
      //     ConsoleLog.printSuccess("Pincodes loaded for ${selectedCity.value}: ${pincodeList.length}");
      //
      //     // Clear previous selection
      //     selectedPincode.value = '';
      //   } else {
      //     Fluttertoast.showToast(msg: "Failed to load pincodes");
      //     pincodeList.clear();
      //     selectedPincode.value = '';
      //   }
      // }
    } catch (e) {
      ConsoleLog.printError("Error fetching pincodes: $e");
      Fluttertoast.showToast(msg: "Error loading pincodes");
      pincodeList.clear();
      selectedPincode.value = '';
    }
  }

  // Validation method
  bool validateFields() {
    if (firstNameController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter first name");
      return false;
    }

    if (lastNameController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter last name");
      return false;
    }

    if (emailController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter email");
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.value.text.trim())) {
      Fluttertoast.showToast(msg: "Please enter valid email");
      return false;
    }

    if (mobileController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter mobile number");
      return false;
    }

    if (mobileController.value.text.trim().length != 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      return false;
    }

    if (!isMobileVerified.value) {
      Fluttertoast.showToast(msg: "Please verify your mobile number first");
      return false;
    }

    if (selectedGender.value.isEmpty) {
      Fluttertoast.showToast(msg: "Please select gender");
      return false;
    }

    if (permanentAddressController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter permanent address");
      return false;
    }

    if (shopNameController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter shop name");
      return false;
    }

    if (panController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter PAN number");
      return false;
    }

    // PAN format validation (example: ABCDE1234F)
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
        .hasMatch(panController.value.text.trim().toUpperCase())) {
      Fluttertoast.showToast(msg: "Please enter valid PAN number");
      return false;
    }

    // Aadhar validation (12 digits)
    if (aadharController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter Aadhar number");
      return false;
    }

    // Aadhar format validation (12 digits, doesn't start with 0 or 1)
    String aadharNumber = aadharController.value.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^[2-9]{1}[0-9]{11}$')
        .hasMatch(aadharNumber)) {
      Fluttertoast.showToast(msg: "Please enter valid 12-digit Aadhar number");
      return false;
    }

    if (selectedState.value.isEmpty) {
      Fluttertoast.showToast(msg: "Please select state");
      return false;
    }

    if (selectedCity.value.isEmpty) {
      Fluttertoast.showToast(msg: "Please select city");
      return false;
    }

    if (selectedPincode.value.isEmpty) {
      Fluttertoast.showToast(msg: "Please select pincode");
      return false;
    }

    if (shopAddressController.value.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter shop address");
      return false;
    }

    if (!isChecked.value) {
      Fluttertoast.showToast(msg: WebApiConstant.TermsConditionError);
      return false;
    }

    return true;
  }

  // Validate and Register
  Future<void> validateAndRegister(BuildContext context) async {
    if (!validateFields()) {
      return;
    }
    await registerUser(context);
  }

  // Register User
  Future<void> registerUser(BuildContext context) async {
    try {
      Map<String, dynamic> dict = {
        "request_id": generateRequestId(),
        "lat": loginController.latitude.value.toString(),
        "long": loginController.longitude.value.toString(),
        "first_name": firstNameController.value.text.trim(),
        "last_name": lastNameController.value.text.trim(),
        "gender": selectedGender.value,
        "email": emailController.value.text.trim(),
        "mobile": mobileController.value.text.trim(),
        "permanent_address": permanentAddressController.value.text.trim(),
        "shop_name": shopNameController.value.text.trim(),
        "pan": panController.value.text.trim().toUpperCase(),
        // "aadhar": aadharController.value.text.trim().replaceAll(RegExp(r'[^0-9]'), ''), // Aadhar field will add in future
        "gstin": gstinController.value.text.trim().toUpperCase(),
        "state_name": selectedState.value,
        "city": selectedCity.value,
        "pincode": selectedPincode.value,
        "shop_address": shopAddressController.value.text.trim(),
        "term_and_condition": "true",
      };

      ConsoleLog.printInfo("Registration data: $dict");

      var response = await ApiProvider().signupApi(
        context,
        WebApiConstant.API_URL_SIGNUP,
        dict,
        "",
      );

      ConsoleLog.printJsonResponse(response, tag: "Signup Response");

      if (response != null) {
        // Parse using model
        SignupApiResponseModel signupResponse = SignupApiResponseModel.fromJson(response);

        if (signupResponse.respCode == 'RCS') {
          Fluttertoast.showToast(
            msg: signupResponse.respDesc ?? "Registration successful",
            toastLength: Toast.LENGTH_LONG,
          );

          // Save mobile number
          await SharedPreferences.getInstance().then((prefs) {
            prefs.setString(
              AppSharedPreferences.mobileNo,
              mobileController.value.text.trim(),
            );
          });

          // Navigate to login screen
          Get.offAll(() => LoginScreen());
        } else {
          Fluttertoast.showToast(
            msg: signupResponse.respDesc ?? "Registration failed",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Registration failed. Please try again.");
      }
      // if (response != null) {
      //   if (response['Resp_code'] == 'RCS') {
      //     Fluttertoast.showToast(
      //       msg: response["Resp_desc"] ?? "Registration successful",
      //       toastLength: Toast.LENGTH_LONG,
      //     );
      //
      //     // Save mobile number
      //     await SharedPreferences.getInstance().then((prefs) {
      //       prefs.setString(
      //         AppSharedPreferences.mobileNo,
      //         mobileController.value.text.trim(),
      //       );
      //     });
      //
      //     // Navigate to login screen
      //     Get.offAll(() => LoginScreen());
      //   } else {
      //     Fluttertoast.showToast(
      //       msg: response["Resp_desc"] ?? "Registration failed",
      //       toastLength: Toast.LENGTH_LONG,
      //     );
      //   }
      // } else {
      //   Fluttertoast.showToast(msg: "Registration failed. Please try again.");
      // }
    } catch (e) {
      ConsoleLog.printError("Registration Exception: $e");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  @override
  void onClose() {
    firstNameController.value.dispose();
    lastNameController.value.dispose();
    emailController.value.dispose();
    mobileController.value.dispose();
    passwordController.value.dispose();
    permanentAddressController.value.dispose();
    shopNameController.value.dispose();
    panController.value.dispose();
    gstinController.value.dispose();
    shopAddressController.value.dispose();
    aadharController.value.dispose();
    super.onClose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../api/api_provider.dart';
// import '../api/web_api_constant.dart';
// import '../utils/app_shared_preferences.dart';
// import '../view/login_screen.dart';
//
// class SignupController extends GetxController {
//   Rx<TextEditingController> firstNameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> lastNameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> nameController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> lnameController = TextEditingController().obs;
//   Rx<TextEditingController> emailController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> mobileController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> passwordController = TextEditingController(text: "").obs;
//   Rx<TextEditingController> tPinCtrl = TextEditingController().obs;
//   Rx<TextEditingController> referralCtrl = TextEditingController().obs;
//   RxBool isChecked = true.obs;
//   RxBool isValidName = true.obs;
//   RxBool isValidEmail = true.obs;
//   RxBool isMobileNo = true.obs;
//   RxBool isPassword = true.obs;
//
//   Future<void> registerUser(BuildContext context) async{
//     try {
//       Map<String, dynamic> dict = {
//         "user_name": nameController.value.text.toString().trim(),
//         "email": emailController.value.text.toString().trim(),
//         "phone": mobileController.value.text.toString().trim(),
//         "sponsor_id": referralCtrl.value.text.toString().trim(),
//         "password": passwordController.value.text.toString().trim(),
//       };
//       print(dict);
//
//       var response = await ApiProvider().signupApi(
//           context, WebApiConstant.API_URL_SIGNUP, dict, "");
//       print("$response.......");
//       if (response != null) {
//         if (response['error'] != true) {
//           Fluttertoast.showToast(msg: response["message"] ?? "");
//           await SharedPreferences.getInstance().then((value) {
//             value.setString(AppSharedPreferences.mobileNo, mobileController.value.text.toString().trim());
//           });
//           Get.offAll(LoginScreen());
//         } else {
//           Fluttertoast.showToast(msg: response["message"] ?? "");
//         }
//       }
//     }catch(_){
//       print("Exception...");
//       Fluttertoast.showToast(msg: WebApiConstant.ApiError);
//     }
//   }
// }


