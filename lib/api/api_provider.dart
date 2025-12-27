import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:e_commerce_app/api/web_api_constant.dart';
// import 'package:e_commerce_app/utils/ConsoleLog.dart';
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
import '../models/CartListApiResponseModel.dart';
import '../models/HomeDetailsApiResponseModel.dart';
import '../models/MyOrderApiResponseModel.dart';
import '../models/NotificationApiResponseModel.dart';
import '../models/OrderDetailsApiResponseModel.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../models/ProductApiResponseModel.dart';
import '../models/RazarPayDepositApiResponseModel.dart';
import '../models/SearchProductApiResponseModel.dart';
import '../models/SubCategoriesApiResponseModel.dart';
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
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:groticshop/DataProvider/web_api_constant.dart';
// import 'package:groticshop/Model/ProductModel/ProductApiResponseModel.dart';
// import 'package:groticshop/View/Dashboard/DashboardScreen.dart';
//
// import '../../Util/Print/print_log.dart';
// import '../Model/CartListModel/CartListApiResponseModel.dart';
// import '../Model/CategoriesModel/SubCategoriesApiResponseModel.dart';
// import '../Model/DepositRazarPayModel/RazarPayDepositApiResponseModel.dart';
// import '../Model/HomeDetails/HomeDetailsApiResponseModel.dart';
// import '../Model/MyOrdersModel/MyOrderApiResponseModel.dart';
// import '../Model/OrderDetailsModel/OrderDetailsApiResponseModel.dart';
// import '../Model/ProductDetailsModel/ProductDetailsApiResponseModel.dart';
// import '../Model/SearchModel/SearchProductApiResponseModel.dart';
// import '../Util/ConnectionValidator/connection_validator.dart';
// import '../Util/CustomLoading/custom_loading.dart';
// import '../Util/WillPopValidtion/will_pop_validation.dart';

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
        ),
      );

      ConsoleLog.printColor("=== API RESPONSE ===", color: "green");
      ConsoleLog.printColor("Response_realUri: ${response.realUri}", color: "yellow");
      ConsoleLog.printColor("Response_headers: ${response.headers}", color: "yellow");
      ConsoleLog.printColor("Status: ${jsonEncode(response.statusCode)}", color: "yellow");
      ConsoleLog.printColor("Response : ${jsonEncode(response.data)}", color: "yellow");
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
      return response;

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

  //Home Detail API (Get)
  Future<HomeDetailsResponseModel?> homePageAPI(context,String token) async {
    HomeDetailsResponseModel? result;
      try{
        Map<String, dynamic> dictParameter = {
        };
        CustomLoading.showLoading();
        final Response? response = await requestGetForApi(WebApiConstant.API_URL_HOME_DETAIL, dictParameter, token);
        ConsoleLog.printJsonResponse("$response", tag: "Home Detail Api (Get)");
        if(response != null && response.statusCode == 200){
          result = HomeDetailsResponseModel.fromJson(response.data);
          ConsoleLog.printSuccess("$result",);
        }
        CustomLoading.hideLoading();
        return result;
      }catch(e){
        CustomLoading.hideLoading();
        ConsoleLog.printError("Exception..........$e.........");
        Fluttertoast.showToast(msg: "Something went wrong");
        return result;
  }}

  //Home Product Details API (Post)
  Future<ProductDetailsResponseModel?> productDetailsAPI(context, String url, Map<String, dynamic> dictParameter, String token) async {
    ProductDetailsResponseModel? result;
    try{
      // CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Home Product Details Api (Post)");
      if(response != null && response.statusCode == 200){
        result = ProductDetailsResponseModel.fromJson(response.data);
        ConsoleLog.printSuccess("$result",);
      }
      // CustomLoading.hideLoading();
      return result;
    }catch(e){
      // CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Add to Cart API (Post)
  Future<Map<String, dynamic>?> addToCartApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
      Map<String, dynamic>? result;
      try{
        CustomLoading.showLoading();
        final Response? response = await requestPostForApi(url, dictParameter, token);
        ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Add to Cart Api (Post)");
        if(response != null && response.statusCode == 200){
          result = Map<String, dynamic>.from(response.data);
          ConsoleLog.printSuccess("$result",);
        }
        return result;
      }catch(e){
        ConsoleLog.printError("Exception..........$e.........");
        Fluttertoast.showToast(msg: "Something went wrong");
        return result;
      }
    }

  //Delete Cart API (Post)
  Future<Map<String, dynamic>?> deleteToCartApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Delete Cart API (Post)");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
        ConsoleLog.printJsonResponse("$response", color: "green", tag: "Delete Cart API (Post)");
      }
      return result;
    }catch(e){
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Get Cart List API (Get)
  Future<CartListScreenResponseModel?> getCartList(context,String token) async {
    CartListScreenResponseModel? result;
    try{
      Map<String, dynamic> dictParameter = {
      };
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_CART_LIST, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Get Cart List API (Get)");
      if(response != null && response.statusCode == 200){
        result = CartListScreenResponseModel.fromJson(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Category To Product Api (Post)
  Future<ProductDetailsResponseModel?> categoryToProductApi(context,Map<String, dynamic> dictParameter,String token) async {
    ProductDetailsResponseModel? result;
    try{
      final Response? response = await requestPostForApi(WebApiConstant.API_URL_CATEGORY_TO_PRODUCT, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Category To Product Api (Post)");
      if(response != null && response.statusCode == 200){
        result = ProductDetailsResponseModel.fromJson(response.data);
        ConsoleLog.printSuccess("$result");
      }
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Get Profile Api (Get)
  Future<Map<String, dynamic>?> getProfile(context,String token) async {
    Map<String, dynamic>? result;
    try{
      Map<String, dynamic> dictParameter = {
      };
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_PROFILE, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Get Profile Api (Get)");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Update Password Api (Post)
  Future<Map<String, dynamic>?> updateTPinApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Update Password Api (Post)");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      return result;
    }catch(e){
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Get Address Api (Get)
  Future<Map<String, dynamic>?> getAddress(context,String token) async {
    Map<String, dynamic>? result;
    try{
      Map<String, dynamic> dictParameter = {};
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_GET_ADDRESS, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........", color: "green", tag: "Get Address Api (Get)");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Change Address Api (Post)
  Future<Map<String, dynamic>?> addAddressApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      return result;
    }catch(e) {
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  // Buy Now Api (Post)
  Future<Map<String, dynamic>?> buyNowApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();

      return result;
    }catch(e) {
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  // My Order Api (Get)
  Future<MyOrderResponseApi?> myOrder(context,String token) async {
    MyOrderResponseApi? result;
    try{
      Map<String, dynamic> dictParameter = {
      };
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_MY_ORDER, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = MyOrderResponseApi.fromJson(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  // Delete Order Api (Post)
  Future<Map<String, dynamic>?> deleteOrderApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    Map<String, dynamic>? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = Map<String, dynamic>.from(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();

      return result;
    }catch(e){
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  // Search Product Api (Post)
  Future<SearchResponseApi?> searchProductApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
    SearchResponseApi? result;
    // if(await ConnectionValidator().check()){
    try{

      // CustomLoading.showLoading();
      final Response? response = await requestPostForApi(url, dictParameter, token);

      if(response != null && response.statusCode == 200){
        result = SearchResponseApi.fromJson(response.data);
      }
      // CustomLoading.hideLoading();

      return result;
    }catch(e) {
      ConsoleLog.printError("Exception1..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Search Product Api (Post)
  // Future<SearchResponseApi?> searchProductApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   SearchResponseApi? result;
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //     ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
  //     if(response != null && response.statusCode == 200){
  //       result = SearchResponseApi.fromJson(response.data);
  //       // ConsoleLog.printSuccess("$result");
  //     }
  //     // CustomLoading.hideLoading();
  //     return result;
  //   }catch(e) {
  //     ConsoleLog.printError("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  // }

  //Sub Category Api (Get)
  Future<CategoriesResponseApi?> getSubCategorisAPI(context, Map<String, dynamic> dictParameter,String token) async {
    CategoriesResponseApi? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_CATEGORY, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = CategoriesResponseApi.fromJson(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //RazorPay Deposit Api (Post) //Unused
  Future<DepositResponse?> loadRazorPayWallet(context,String token,Map<String, dynamic> dict) async {
    DepositResponse? result;
    // if(await ConnectionValidator().check()){
    if(await ConnectionValidator.isConnected()){
      try{
        CustomLoading.showLoading();
        final Response? response = await requestPostForApi(WebApiConstant.API_URL_RAZORPAY_DEPOSIT, dict, token);
        ConsoleLog.printColor("loadWalletResponse: ${response?.data}");
        if(response != null && response.statusCode == 200){
          result = DepositResponse.fromJson(response.data);
          ConsoleLog.printSuccess("$result");
        }
        CustomLoading.hideLoading();
        return result;
      }catch(e){
        CustomLoading.hideLoading();
        ConsoleLog.printError("Exception..........$e.........");
        Fluttertoast.showToast(msg: "Something went wrong");
        return result;
      }
    }else{
      CustomLoading.hideLoading();
      // Navigator.pushNamed(context, networkErrorScreenRoute);
      // Fluttertoast.showToast( msg: 'Please check network connection and try again !');
    }
    return null;
  }

  //Order Details Api (Get)
  Future<OrderDetailsResponse?> getOrderDetailsList(context,String token,Map<String, dynamic> dictParameter) async {
    OrderDetailsResponse? result;
    try{
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_OREDER_DETAILS_LIST, dictParameter, token);
      ConsoleLog.printColor("ResponseNew..........$response.........", color: "green");
      if(response != null && response.statusCode == 200){
        result = OrderDetailsResponse.fromJson(response.data);
        ConsoleLog.printSuccess("$result");
      }
      CustomLoading.hideLoading();
      return result;
    }catch(e){
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }

  //Notification API
  Future<NotificationResponse?> getNotification(context, String token) async {
    NotificationResponse? result;
    try {
      Map<String, dynamic> dictParameter = {};
      CustomLoading.showLoading();
      final Response? response = await requestGetForApi(WebApiConstant.API_URL_NOTIFICATION, dictParameter, token);
      ConsoleLog.printJsonResponse("ResponseNew..........$response.........");
      if (response != null && response.statusCode == 200) {
        result = NotificationResponse.fromJson(response.data);
      }
      CustomLoading.hideLoading();
      return result; // Added missing return statement
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError("Exception..........$e.........");
      Fluttertoast.showToast(msg: "Something went wrong");
      return result;
    }
  }






  // Future<SearchResponseApi?> searchProduct(
  //     BuildContext context,
  //     String searchText,
  //     String token
  //     ) async {
  //   try {
  //     CustomLoading.showLoading();
  //     final response = await dio.post(
  //       WebApiConstant.API_URL_SEARCH_PRODUCT,
  //       data: {
  //         'title': searchText,
  //       },
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //
  //     CustomLoading.hideLoading();
  //     if (response.statusCode == 200) {
  //       return SearchResponseApi.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     CustomLoading.hideLoading();
  //     print('API Error: $e');
  //   }
  //   return null;
  // }

  //
  // Future<DepositResponse?> loadwalleRazorPay(context,String token,Map<String, dynamic> dict) async {
  //   DepositResponse? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, WebApiConstant.API_URL_RAZORPAY_DEPOSIT, dict, token);
  //       log("loadwalletresponse: ${response?.data}");
  //       if(response != null && response.statusCode == 200){
  //         result = DepositResponse.fromJson(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     // Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  //
  //
  // Future<Map<String, dynamic>?> loginApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //     try{
  //      CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //      CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  //
  //
  // Future<Map<String, dynamic>?> registerApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //     try{
  //      CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //      CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  // Future<HomeDetailsResponseModel?> loadeHomePageAPI(context,String token) async {
  //   HomeDetailsResponseModel? result;
  //     try{
  //       Map<String, dynamic> dictParameter = {
  //       };
  //       CustomLoading.showLoading();
  //       final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_HOME_DETAIL, dictParameter, token);
  //       print("ResponseNew..........$response.........");
  //       if(response != null && response.statusCode == 200){
  //         result = HomeDetailsResponseModel.fromJson(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //
  //   return null;
  // }}
  // Future<ProductResponseModel?> productAPI(context,Map<String, dynamic> dictParameter,String token) async {
  //   ProductResponseModel? result;
  //     try{
  //
  //       // CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, WebApiConstant.API_URL_CATEGORY_TO_PRODUCT, dictParameter, token);
  //       print("ResponseNew..........$response.........");
  //       if(response != null && response.statusCode == 200){
  //         result = ProductResponseModel.fromJson(response.data);
  //       }
  //       // CustomLoading.hideLoading();
  //       return result;
  //
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //
  //   return null;
  // }}
  //
  //
  // Future<ProductDetailsResponseModel?> prodectDetails(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   ProductDetailsResponseModel? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = ProductDetailsResponseModel.fromJson(response.data);
  //       print(result);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  // Future<CartListScreenResponseModel?> getCartList(context,String token) async {
  //   CartListScreenResponseModel? result;
  //   try{
  //     Map<String, dynamic> dictParameter = {
  //     };
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_CART_LIST, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = CartListScreenResponseModel.fromJson(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  // }}
  // Future<OrderDetailsResponse?> getOrderDetailsList(context,String token,Map<String, dynamic> dictParameter) async {
  //   OrderDetailsResponse? result;
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_OREDER_DETAILS_LIST, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = OrderDetailsResponse.fromJson(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  // }}
  // Future<Map<String, dynamic>?> getProfile(context,String token) async {
  //   Map<String, dynamic>? result;
  //   try{
  //     Map<String, dynamic> dictParameter = {
  //     };
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_PROFILE, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  //   }}
  //
  // Future<Map<String, dynamic>?> addToCartApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     return result;
  //   }catch(e){
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> deleteToCartApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     return result;
  //   }catch(e){
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> updateTPinApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     return result;
  //   }catch(e){
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> addAddressApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     return result;
  //   }catch(e) {
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  // }
  // Future<Map<String, dynamic>?> changeAddress(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     return result;
  //   }catch(e) {
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  // }
  //
  //
  // Future<Map<String, dynamic>?> getAddress(context,String token) async {
  //   Map<String, dynamic>? result;
  //   try{
  //     Map<String, dynamic> dictParameter = {
  //     };
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_GET_ADDRESS, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  //   }}
  // Future<Map<String, dynamic>?> buyNowApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //
  //     return result;
  //   }catch(e) {
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  // }
  //
  // Future<MyOrderResponseApi?> myOrder(context,String token) async {
  //   MyOrderResponseApi? result;
  //   try{
  //     Map<String, dynamic> dictParameter = {
  //     };
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_MY_ORDER, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = MyOrderResponseApi.fromJson(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  //   }}
  //
  // Future<Map<String, dynamic>?> deleteOrderApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = Map<String, dynamic>.from(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //
  //     return result;
  //   }catch(e){
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  //   //}
  //   // else{
  //   //  CustomLoading.hideLoading();
  //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  //   //   Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   // }
  //   return null;
  // }
  //
  // Future<SearchResponseApi?> searchProductApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   SearchResponseApi? result;
  //   // if(await ConnectionValidator().check()){
  //   try{
  //
  //     CustomLoading.showLoading();
  //     final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //     if(response != null && response.statusCode == 200){
  //       result = SearchResponseApi.fromJson(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //
  //     return result;
  //   }catch(e) {
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //   }
  // }
  //
  // Future<CategoriesResponseApi?> getSubCategorisAPI(context, Map<String, dynamic> dictParameter,String token) async {
  //   CategoriesResponseApi? result;
  //   try{
  //     CustomLoading.showLoading();
  //     final Response? response = await requestGetForApi(context, WebApiConstant.API_URL_CATEGORY, dictParameter, token);
  //     print("ResponseNew..........$response.........");
  //     if(response != null && response.statusCode == 200){
  //       result = CategoriesResponseApi.fromJson(response.data);
  //     }
  //     CustomLoading.hideLoading();
  //     return result;
  //   }catch(e){
  //     CustomLoading.hideLoading();
  //     print("Exception..........$e.........");
  //     Fluttertoast.showToast(msg: "Something went wrong");
  //     return result;
  //
  //     return null;
  //   }}
  //
  //
  //
  // // Future<Map<String, dynamic>?> updateTPinApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  // //   Map<String, dynamic>? result;
  // //      try{
  // //       //CustomLoading.showLoading();
  // //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  // //
  // //       if(response != null && response.statusCode == 200){
  // //         result = Map<String, dynamic>.from(response.data);
  // //       }
  // //       CustomLoading.hideLoading();
  // //       return result;
  // //     }catch(e){
  // //       CustomLoading.hideLoading();
  // //       print("Exception..........$e.........");
  // //       Fluttertoast.showToast(msg: "Something went wrong");
  // //       return result;
  // //     }
  // // }
  //
  //
  //
  // // Future<Map<String, dynamic>?> registerApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  // //   Map<String, dynamic>? result;
  // //  // if(await ConnectionValidator().check()){
  // //     try{
  // //       CustomLoading.showLoading();
  // //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  // //
  // //       if(response != null && response.statusCode == 200){
  // //         result = Map<String, dynamic>.from(response.data);
  // //       }
  // //       CustomLoading.hideLoading();
  // //       return result;
  // //     }catch(e){
  // //       CustomLoading.hideLoading();
  // //       print("Exception..........$e.........");
  // //       Fluttertoast.showToast(msg: "Something went wrong");
  // //       return result;
  // //     }
  // //  // }
  // //   // else{
  // //   //   CustomLoading.hideLoading();
  // //   //   // Navigator.pushNamed(context, networkErrorScreenRoute);
  // //   //   // Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  // //   // }
  // //   return null;
  // // }
  //
  // Future<Map<String, dynamic>?> getAPIRequest(context,  Map<String, dynamic> dictParameter, String token,String url) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestGetForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> subscriptionApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //      CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //      CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //    CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> updateBankDetailsApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> withdrawalApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> fundTransferApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  // Future<Map<String, dynamic>?> fundMoveApi(context, String url, Map<String, dynamic> dictParameter, String token) async {
  //   Map<String, dynamic>? result;
  //   if(await ConnectionValidator().check()){
  //     try{
  //       CustomLoading.showLoading();
  //       final Response? response = await requestPostForApi(context, url, dictParameter, token);
  //
  //       if(response != null && response.statusCode == 200){
  //         result = Map<String, dynamic>.from(response.data);
  //       }
  //       CustomLoading.hideLoading();
  //       return result;
  //     }catch(e){
  //       CustomLoading.hideLoading();
  //       print("Exception..........$e.........");
  //       Fluttertoast.showToast(msg: "Something went wrong");
  //       return result;
  //     }
  //   }else{
  //     CustomLoading.hideLoading();
  //     // Navigator.pushNamed(context, networkErrorScreenRoute);
  //     Fluttertoast.showToast( msg: 'Please check network connection and try again !');
  //   }
  //   return null;
  // }
  //
  //
  //
  //
}
