import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:payrupya/controllers/upi_wallet_controller.dart';
import '../controllers/dmt_wallet_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/session_manager.dart';
import '../models/get_city_state_by_pincode_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/connection_validator.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../utils/will_pop_validation.dart';
import '../view/onboarding_screen.dart';
import 'web_api_constant.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiResponse {
  final int code;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? json['statusCode'] ?? 500,
      message: json['message'] ?? json['respDesc'] ?? 'Unknown error',
      data: json['data'] ?? json,
    );
  }
}

class ApiProvider {
  Dio dio = Dio();
  LoginController loginController = Get.put(LoginController());
  DmtWalletController dmtController = Get.put(DmtWalletController());
  UPIWalletController upiWalletController = Get.put(UPIWalletController());
  RxString userAuthToken = "".obs;
  RxString userSignature = "".obs;

  Map<String, String> headers = {
    "Content-Type": "application/json",
    // "Authorization": 'Bearer $authToken',
  };
  // String authKey = "DREAD*RK&Y&*T9KeykhfdiT";

  //Get API Request Method
  Future<Response?> requestGetForApi(String url, Map<String, dynamic> dictParameter, String token) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        // "Authkey": authKey,
      };

      ConsoleLog.printColor("Headers: $headers", color: "yellow");
      ConsoleLog.printColor("Url:  $url", color: "yellow");
      ConsoleLog.printColor("Token:  $token", color: "yellow");
      ConsoleLog.printColor("DictParameter: $dictParameter", color: "yellow");

      BaseOptions options = BaseOptions(
        baseUrl: WebApiConstant.BASE_URL,
        receiveTimeout: Duration(seconds: 30),
        connectTimeout: Duration(seconds: 30),
        headers: headers,
      );

      dio.options = options;
      dictParameter['demo'] = true;
      Response response = await dio.get(url, queryParameters: dictParameter);
      // ConsoleLog.printJsonResponse("Response111: $response", color: "yellow", tag: "Response");
      ConsoleLog.printColor("Response_headers1: ${response.headers}", color: "yellow");
      Map<String, dynamic>? result = Map<String, dynamic>.from(response.data);
      if (result["errorCode"] == 7) {
        ConsoleLog.printError("authentication failed");
        // onLogout();
        return response;
      } else {
        return response;
      }
    } catch (error) {
      ConsoleLog.printError("Exception_Main: $error");
      return null;
    }
  }

  // Future<ApiResponse> postApiRequest({
  //   required String url,
  //   required String token,
  //   required Map<String, dynamic> dictParameter,
  //   required String signature,
  //   // Map<String, String>? extraHeaders,
  // }) async {
  //   try {
  //     var headers = {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //       "X-Signature": signature,
  //       // ...?extraHeaders, // ← optional extra headers
  //     };
  //
  //     ConsoleLog.printColor("=== NEW API REQUEST ===", color: "blue");
  //     ConsoleLog.printColor("URL: $url", color: "cyan");
  //     ConsoleLog.printColor("Json Headers: ${jsonEncode(headers)}", color: "cyan");
  //     ConsoleLog.printColor("Json Body: ${jsonEncode(dictParameter)}", color: "yellow");
  //     ConsoleLog.printColor("=== END REQUEST ===", color: "blue");
  //
  //     Response  response = await dio.post(
  //       url,
  //       data: dictParameter,
  //       options: Options(
  //         headers: headers,
  //         followRedirects: false,
  //         validateStatus: (status) => true,
  //       ),
  //     );
  //
  //     ConsoleLog.printColor("=== API RESPONSE ===", color: "green");
  //     ConsoleLog.printColor("Status: ${jsonEncode(response.statusCode)}", color: "yellow");
  //     ConsoleLog.printColor("Data: ${jsonEncode(response.data)}", color: "yellow");
  //     ConsoleLog.printColor("=== END RESPONSE ===", color: "green");
  //
  //     return ApiResponse.fromJson(response.data);
  //   } catch (e) {
  //     ConsoleLog.printError("API Exception: $e");
  //     return ApiResponse(code: 500, message: e.toString());
  //   }
  // }

  //Post API Request Method
  Future<Response?> requestPostForApi(String url, Map<dynamic, dynamic> dictParameter, String token, [String signature = ""]) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        // "Authkey": authKey,
      };

      // // Authorization header
      // if (token.isNotEmpty) {
      //   headers["Authorization"] = "Bearer $token";
      // }
      //
      // // X-Signature header
      // if (signature.isNotEmpty) {
      //   headers["X-Signature"] = signature;
      // }
      // Standard Authorization header (for good practice)
      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
        // headers["Bearer"] = token;  // ✅ Backend expects this key directly
      }

      // X-Signature header
      if (signature.isNotEmpty) {
        headers["X-Signature"] = signature;
        // headers["xsignature"] = signature;  // ✅ Backend expects this key directly
      }

      // dictParameter["versionNew"] = 1;
      ConsoleLog.printColor("=== API REQUEST ===", color: "blue");
      ConsoleLog.printColor("URL: $url", color: "yellow");
      ConsoleLog.printColor("Json Headers: ${jsonEncode(headers)}", color: "cyan");
      ConsoleLog.printColor("Json Body: ${jsonEncode(dictParameter)}", color: "yellow");
      ConsoleLog.printColor("=== END REQUEST ===", color: "blue");

      BaseOptions options = BaseOptions(
        baseUrl: WebApiConstant.BASE_URL,
        receiveTimeout: Duration(seconds: 30),
        connectTimeout: Duration(seconds: 30),
        headers: headers,
        responseType: ResponseType.plain,  // ✅ ADD THIS LINE
      );
      dio.options = options;
      Response response = await dio.post(
        url,
        // "$url?demo=true",
        data: dictParameter,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true,
          headers: headers,
          responseType: ResponseType.plain,  // ✅ ADD THIS LINE
        ),
      );

      ConsoleLog.printColor("=== API RESPONSE ===", color: "green");
      ConsoleLog.printColor("Response_realUri: ${response.realUri}", color: "yellow");
      ConsoleLog.printColor("Response_headers: ${response.headers}", color: "yellow");
      ConsoleLog.printColor("Status: ${jsonEncode(response.statusCode)}", color: "yellow");
      // ConsoleLog.printColor("Response : ${jsonEncode(response.data)}", color: "yellow");

      // ✅ SAFE RESPONSE PARSING - Parse string to JSON Map
      dynamic parsedData;

      if (response.data == null) {
        ConsoleLog.printError("❌ Response data is null");
        parsedData = {"Resp_code": "ERR", "Resp_desc": "Empty response from server"};
      } else if (response.data is String) {
        String dataStr = response.data.toString().trim();

        // Check for HTML error page (PHP error, 500 error, etc.)
        if (dataStr.startsWith('<') || dataStr.startsWith('<!')) {
          ConsoleLog.printError("❌ Server returned HTML instead of JSON!");
          ConsoleLog.printError("Status Code: ${response.statusCode}");
          // Log first 500 chars for debugging
          int previewLen = dataStr.length > 500 ? 500 : dataStr.length;
          ConsoleLog.printError("HTML Preview: ${dataStr.substring(0, previewLen)}");

          parsedData = {
            "Resp_code": "ERR",
            "Resp_desc": "Server error - received HTML (Status: ${response.statusCode})",
          };
        } else if (dataStr.isEmpty) {
          ConsoleLog.printError("❌ Empty response from server");
          parsedData = {"Resp_code": "ERR", "Resp_desc": "Empty response"};
        } else {
          // Try to parse as JSON
          try {
            parsedData = jsonDecode(dataStr);
            ConsoleLog.printColor("Response : ${jsonEncode(parsedData)}", color: "yellow");
          } catch (e) {
            ConsoleLog.printError("❌ Failed to parse JSON: $e");
            int rawLen = dataStr.length > 300 ? 300 : dataStr.length;
            ConsoleLog.printError("Raw: ${dataStr.substring(0, rawLen)}...");
            parsedData = {
              "Resp_code": "ERR",
              "Resp_desc": "Invalid JSON response",
            };
          }
        }
      } else if (response.data is Map) {
        // Already a Map (shouldn't happen with ResponseType.plain)
        parsedData = response.data;
        ConsoleLog.printColor("Response : ${jsonEncode(parsedData)}", color: "yellow");
      } else {
        ConsoleLog.printError("❌ Unknown response type: ${response.data.runtimeType}");
        parsedData = {"Resp_code": "ERR", "Resp_desc": "Unknown format"};
      }

      ConsoleLog.printColor("=== END RESPONSE ===", color: "green");

      // Create new Response with parsed Map data
      Response parsedResponse = Response(
        requestOptions: response.requestOptions,
        data: parsedData,  // ✅ Now it's a Map, not String
        statusCode: response.statusCode,
        headers: response.headers,
      );

      // Check for auth error
      if (parsedData is Map<String, dynamic> && parsedData["errorCode"] == 7) {
        ConsoleLog.printError("❌ Authentication failed - Error Code 7");
        logoutUser();
      }

      return parsedResponse;  // ✅ Return parsed response
      /*// ✅ NEW (safe):
      try {
        if (response.data is Map || response.data is List) {
          ConsoleLog.printColor("Response : ${jsonEncode(response.data)}", color: "yellow");
        } else {
          String dataStr = response.data.toString();
          if (dataStr.trim().startsWith('<')) {
            ConsoleLog.printError("❌ Server returned HTML! Preview: ${dataStr.substring(0, 200)}...");
          } else {
            ConsoleLog.printColor("Response (raw): $dataStr", color: "yellow");
          }
        }
      } catch (e) {
        ConsoleLog.printColor("Response (raw): ${response.data}", color: "red");
      }
      ConsoleLog.printColor("=== END RESPONSE ===", color: "green");

      // ConsoleLog.printJsonResponse("Response21: ${response.data}", color: "yellow", tag: "Response");
      // // Parse response if it's a string
      // dynamic parsedData = response.data;
      // if (response.data is String) {
      //   try {
      //     parsedData = jsonDecode(response.data);
      //     ConsoleLog.printInfo("Parsed JSON string to Map");
      //   } catch (e) {
      //     ConsoleLog.printError("Failed to parse JSON: $e");
      //   }
      // }

      // Safe access to errorCode
      // if (parsedData is Map) {
      //   ConsoleLog.printColor("Response1: ${parsedData["errorCode"]}", color: "yellow");
      //
      //   // Update response.data with parsed data
      //   if (response.data is String) {
      //     response.data = parsedData;
      //   }
      // }

      // ConsoleLog.printColor("Response_headers: ${jsonEncode(response.headers)}", color: "yellow");
      // ConsoleLog.printColor("Response_realUri: ${response.realUri}", color: "yellow");
      // ConsoleLog.printColor("Response: ${jsonEncode(response.data)}", color: "yellow");
      // ConsoleLog.printColor("Status: ${response.statusCode}", color: "yellow");


      // if(response.data != null && response.data["status"] == "error"){
      //   response.data["data"] = null;
      //   return response;
      // }else {

      // Map<String, dynamic>? result = Map<String, dynamic>.from(response.data);
      // if (result["errorCode"] == 7) {
      //   ConsoleLog.printColor("authentication failed",color: "red");
      //   // onLogout();
      //   logoutUser();
      //   return response;
      // } else {
      //   return response;
      // }
      if (response.data is Map<String, dynamic>) {
        Map<String, dynamic>? result = Map<String, dynamic>.from(response.data);
        if (result["errorCode"] == 7) {
          ConsoleLog.printError("❌ Authentication failed - Error Code 7");
          logoutUser();
          return response;
        }
      }
      return response;*/

      // }
    } catch (error) {
      ConsoleLog.printError("API Exception: $error");
      return null;
    }
  }

  //Other API Request Method
  Future<Response?> requestMultipartApi(String url, formData, String token) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
        // "Authkey": authKey,
      };

      print("Headers: $headers");
      print("Url:  $url");
      print("Token:  $token");
      print("formData: $formData");

      BaseOptions options = BaseOptions(
        baseUrl: WebApiConstant.BASE_URL,
        receiveTimeout: Duration(seconds: 30),
        connectTimeout: Duration(seconds: 30),
        headers: headers,
      );

      dio.options = options;
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true,
          headers: headers,
        ),
      );

      ConsoleLog.printJsonResponse("Response: $response", color: "yellow", tag: "Response");

      return response;
    } catch (error) {
      print("Exception_Main: $error");
      return null;
    }
  }

  // Multipart Request Method for File Uploads (using Dio)
  Future<Response?> postMultipartRequest(
      String url,
      Map<String, dynamic> dictParameter,
      File file,
      String fileFieldName,
      String token,
      [String signature = ""]
      ) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "multipart/form-data",
      };

      // Authorization header
      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      // X-Signature header
      if (signature.isNotEmpty) {
        headers["X-Signature"] = signature;
      }

      // Prepare FormData
      FormData formData = FormData();

      // Add all text fields
      dictParameter.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add file
      String fileName = file.path.split('/').last;
      formData.files.add(
        MapEntry(
          fileFieldName,
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ),
      );

      ConsoleLog.printColor("=== MULTIPART API REQUEST ===", color: "blue");
      ConsoleLog.printColor("URL: $url", color: "yellow");
      ConsoleLog.printColor("Headers: ${jsonEncode(headers)}", color: "cyan");
      ConsoleLog.printColor("Fields: ${jsonEncode(dictParameter)}", color: "yellow");
      ConsoleLog.printColor("File: $fileName (${fileFieldName})", color: "yellow");
      ConsoleLog.printColor("=== END REQUEST ===", color: "blue");

      BaseOptions options = BaseOptions(
        baseUrl: WebApiConstant.BASE_URL,
        receiveTimeout: Duration(seconds: 60), // Increased for file upload
        connectTimeout: Duration(seconds: 60),
        headers: headers,
        responseType: ResponseType.plain,
      );

      dio.options = options;

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true,
          headers: headers,
          responseType: ResponseType.plain,
        ),
        onSendProgress: (sent, total) {
          // Optional: Show upload progress
          double progress = (sent / total) * 100;
          ConsoleLog.printColor("Upload Progress: ${progress.toStringAsFixed(2)}%", color: "cyan");
        },
      );

      ConsoleLog.printColor("=== MULTIPART API RESPONSE ===", color: "green");
      ConsoleLog.printColor("Response_realUri: ${response.realUri}", color: "yellow");
      ConsoleLog.printColor("Response_headers: ${response.headers}", color: "yellow");
      ConsoleLog.printColor("Status: ${jsonEncode(response.statusCode)}", color: "yellow");

      // Parse response (same as postRequest)
      dynamic parsedData;

      if (response.data == null) {
        ConsoleLog.printError("❌ Response data is null");
        parsedData = {"Resp_code": "ERR", "Resp_desc": "Empty response from server"};
      } else if (response.data is String) {
        String dataStr = response.data.toString().trim();

        if (dataStr.startsWith('<') || dataStr.startsWith('<!')) {
          ConsoleLog.printError("❌ Server returned HTML instead of JSON!");
          ConsoleLog.printError("Status Code: ${response.statusCode}");
          int previewLen = dataStr.length > 500 ? 500 : dataStr.length;
          ConsoleLog.printError("HTML Preview: ${dataStr.substring(0, previewLen)}");

          parsedData = {
            "Resp_code": "ERR",
            "Resp_desc": "Server error - received HTML (Status: ${response.statusCode})",
          };
        } else if (dataStr.isEmpty) {
          ConsoleLog.printError("❌ Empty response from server");
          parsedData = {"Resp_code": "ERR", "Resp_desc": "Empty response"};
        } else {
          try {
            parsedData = jsonDecode(dataStr);
            ConsoleLog.printColor("Response : ${jsonEncode(parsedData)}", color: "yellow");
          } catch (e) {
            ConsoleLog.printError("❌ Failed to parse JSON: $e");
            int rawLen = dataStr.length > 300 ? 300 : dataStr.length;
            ConsoleLog.printError("Raw: ${dataStr.substring(0, rawLen)}...");
            parsedData = {
              "Resp_code": "ERR",
              "Resp_desc": "Invalid JSON response",
            };
          }
        }
      } else if (response.data is Map) {
        parsedData = response.data;
        ConsoleLog.printColor("Response : ${jsonEncode(parsedData)}", color: "yellow");
      } else {
        ConsoleLog.printError("❌ Unknown response type: ${response.data.runtimeType}");
        parsedData = {"Resp_code": "ERR", "Resp_desc": "Unknown format"};
      }

      ConsoleLog.printColor("=== END RESPONSE ===", color: "green");

      // Create new Response with parsed Map data
      Response parsedResponse = Response(
        requestOptions: response.requestOptions,
        data: parsedData,
        statusCode: response.statusCode,
        headers: response.headers,
      );

      // Check for auth error
      if (parsedData is Map<String, dynamic> && parsedData["errorCode"] == 7) {
        ConsoleLog.printError("❌ Authentication failed - Error Code 7");
        logoutUser();
      }

      return parsedResponse;
    } catch (error) {
      ConsoleLog.printError("Multipart API Exception: $error");
      return null;
    }
  }


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
    // ✅ Session ko properly end karo
    if (Get.isRegistered<SessionManager>()) {
      await SessionManager.instance.endSession();
      Get.delete<SessionManager>(force: true);
    }
    await AppSharedPreferences.clearSessionOnly();
    Get.offAll(() => OnboardingScreen());
    Fluttertoast.showToast(msg: "Session expired. Please login again.");
  }
  //endregion

  //region getCityStateByPinCode
  Future<void> getCityStateByPinCode(BuildContext context, String pinCode) async {
    try {
      // Validate token first
      if (!await isTokenValid()) {
        await refreshToken(context);
        return;
      }

      // Check Internet
      bool isConnected = await ConnectionValidator.isConnected();
      if (!isConnected) {
        CustomDialog.error(message: "No Internet Connection!");
        return;
      }

      CustomLoading.showLoading();

      Map<String, dynamic> body = {
        "request_id": GlobalUtils.generateRandomId(6),
        "lat": loginController.latitude.value,
        "long": loginController.longitude.value,
        "pincode": pinCode
      };

      var response = await requestPostForApi(
        WebApiConstant.API_URL_GET_CITY_STATE_BY_PINCODE,
        body,
        userAuthToken.value,
        userSignature.value,
      );

      ConsoleLog.printColor("Get Cit State by PinCode Api Request: ${jsonEncode(body)}", color: "yellow");

      if (response != null && response.statusCode == 200) {
        ConsoleLog.printColor("GET CITY STATE BY PINCODE RESP: ${jsonEncode(response.data)}");

        GetCityStateByPincodeResponseModel apiResponse =
        GetCityStateByPincodeResponseModel.fromJson(response.data);

        CustomLoading.hideLoading();
        if (apiResponse.respCode == "RCS" &&
            apiResponse.data != null) {
          GlobalUtils.CityName.value = apiResponse.data!.city ?? "";
          GlobalUtils.StateName.value = apiResponse.data!.statename ?? "";
          ConsoleLog.printSuccess("======>>>>>> City Name: ${GlobalUtils.CityName.value}, State Name: ${GlobalUtils.StateName.value}");
          dmtController.senderCityController.value.text = GlobalUtils.CityName.toString();
          dmtController.senderStateController.value.text = GlobalUtils.StateName.toString();
          upiWalletController.senderCityController.value.text = GlobalUtils.CityName.toString();
          upiWalletController.senderStateController.value.text = GlobalUtils.StateName.toString();
        }/* else {
          GlobalUtils.CityName.value = "";
          GlobalUtils.StateName.value = "";
          ConsoleLog.printWarning("⚠️ No data found!");
        }*/
      } else {
        ConsoleLog.printError("❌ API Error: ${response?.statusCode}");
      }
    } catch (e) {
      ConsoleLog.printError("❌ GET CITY STATE BY PINCODE ERROR: $e");
    }
  }
  //endregion











  //Signup API (Post)
  Future<Map<String, dynamic>?> signupApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try {
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Signup Api (Post");
      if (response != null && response.statusCode == 200) {
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result",);
      }
      CustomLoading.hideLoading();
      return result;
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
      return result;
    }
  }

  //Login API (Post)
  Future<Map<String, dynamic>?> loginApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try {
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Login Api (Post)");
      if (response != null && response.statusCode == 200) {
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result",);
      }
      CustomLoading.hideLoading();
      return result;
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Verify Login OTP API (Post)
  Future<Map<String, dynamic>?> verifyLoginOtpApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try {
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Verify Login OTP Api (Post)");
      if (response != null && response.statusCode == 200) {
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result",);
      }
      CustomLoading.hideLoading();
      return result;
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Resend Login OTP API (Post)
  Future<Map<String, dynamic>?> resendLoginOtpApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try {
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Resend Login OTP Api (Post)");
      if (response != null && response.statusCode == 200) {
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result",);
      }
      CustomLoading.hideLoading();
      return result;
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }
}
