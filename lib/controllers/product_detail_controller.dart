import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';

class ProductDetailController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  // var productDetail = Rxn<ProductDetailsData>();
  var productDetail = Rxn<ProductDetailsResponseData>();
  String? userAccessToken;
  // Current slug being loaded - to prevent wrong data loading
  String? currentLoadingSlug;
  RxString? title = "".obs;
  RxInt? product_id = 0.obs;
  RxString? description = "".obs;
  RxString? price = "".obs;
  RxString? disc_price = "".obs;
  RxInt? stock = 0.obs;
  RxList<String> banner = <String>[].obs;
  RxList<String> images = <String>[].obs;


  @override
  void onInit() {
    super.onInit();
    loadToken();
    // AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
    //   userAccessToken = value;
    // });
  }

  // Load token separately to avoid blocking
  Future<void> loadToken() async {
    if (userAccessToken == null || userAccessToken!.isEmpty) {
      userAccessToken = await AppSharedPreferences().getString(AppSharedPreferences.token);
    }
  }

  // Clear previous data before loading new product
  void clearProductData() {
    productDetail.value = null;
    product_id?.value = 0;
    title?.value = "";
    price?.value = "";
    disc_price?.value = "";
    description?.value = "";
    stock?.value = 0;
    images.clear();
    banner.clear();
    errorMessage.value = '';
  }


  Future<void> getProductDetails(BuildContext context, String slug, {bool showLoading = true}) async{
    // Prevent loading same slug multiple times
    if (currentLoadingSlug == slug && isLoading.value) {
      ConsoleLog.printColor("Already loading slug: $slug", color: "yellow");
      return;
    }
    currentLoadingSlug = slug;

    // Clear previous data
    clearProductData();

    if (showLoading) {
      isLoading.value = true;
    }
    Map<String, dynamic> dict = {
      "slug":slug,
    };
    try {
      // Ensure token is loaded
      await loadToken();
      ConsoleLog.printColor("Fetching product details for slug: $slug", color: "cyan");
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().productDetailsAPI(
          context, WebApiConstant.API_URL_HOME_PRODUCT_DETAILS, dict, userAccessToken ?? "");

      // Verify this is still the slug we want
      if (currentLoadingSlug != slug) {
        ConsoleLog.printColor("Slug changed during loading, ignoring response", color: "yellow");
        return;
      }

      ConsoleLog.printColor("Response.....$response", color: "green");
      // if (response != null) {
      //   if (response.error != true && response.errorCode == 0) {
      //     if (response.data?.images != null) {
      //       banner.value = response.data?.images ?? [];
      //     }
      //   } else {
      //     Fluttertoast.showToast(msg: response.message ?? "");
      //   }
      //   productDetail.value = response.data;
      //   product_id!.value=response.data?.id! ??0 ;
      //   title!.value=response.data?.title! ??"" ;
      //   price!.value= response.data?.price!.toString() ??"" ;
      //   disc_price!.value=response.data?.discPrice!.toString() ?? "" ;
      //   description!.value=response.data?.discription! ?? "" ;
      //   stock!.value=response.data?.stock??0;
      //   images.value=response.data?.images??[];
      // }
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          if (response.data != null) {
            // Set all data
            productDetail.value = response.data;
            product_id?.value = response.data?.id ?? 0;
            title?.value = response.data?.title ?? "";
            price?.value = response.data?.price?.toString() ?? "";
            disc_price?.value = response.data?.discPrice?.toString() ?? "";
            description?.value = response.data?.discription ?? "";
            stock?.value = response.data?.stock ?? 0;
            images.value = response.data?.images ?? [];
            banner.value = response.data?.images ?? [];

            ConsoleLog.printSuccess("Product loaded: ${response.data?.title}");
          } else {
            errorMessage.value = "Product data not found";
          }
        } else {
          errorMessage.value = response.message ?? "Failed to load product";
          Fluttertoast.showToast(msg: response.message ?? "Failed to load product");
        }
      } else {
        errorMessage.value = "No response from server";
      }
    } catch (e) {
      ConsoleLog.printError("Exception in getProductDetails: $e");
      errorMessage.value = "Error loading product: $e";
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
      currentLoadingSlug = null;
    }
  }

  // Future<void> getProductDetails(BuildContext context, String slug) async {
  //   Map<String, dynamic> dict = {
  //     "slug":slug,
  //   };
  //   try {
  //     ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
  //     var response = await ApiProvider().prodectDetails(
  //         context, WebApiConstant.API_URL_HOME_PRODUCT_DETAILS, dict, ""!);
  //
  //     PrintLog.printLog("Response.....${response}");
  //     if (response != null) {
  //       if (response.error != true && response.errorCode == 0) {
  //         if (response.data?.images != null) {
  //           banner.value = response.data?.images ?? [];
  //         }
  //
  //       } else {
  //         Fluttertoast.showToast(msg: response.message ?? "");
  //       }
  //       product_id.value=response.data?.product_id! ??0 ;
  //       title.value=response.data?.title! ??"" ;
  //       price.value= response.data?.price!.toString() ??"" ;
  //       disc_price.value=response.data?.discPrice!.toString() ?? "" ;
  //       stock.value=response.data?.stock??0;
  //       description.value=response.data?.discription! ?? "" ;
  //     }
  //   } catch (_) {
  //     PrintLog.printLog("Exception...$_...");
  //     Fluttertoast.showToast(msg: WebApiConstant.ApiError);
  //   }
  //   // try {
  //   //   isLoading.value = true;
  //   //   errorMessage.value = '';
  //   //
  //   //   // Check internet connection
  //   //   if (!await ConnectionValidator.checkInternet()) {
  //   //     errorMessage.value = 'No internet connection';
  //   //     isLoading.value = false;
  //   //     return;
  //   //   }
  //   //
  //   //   // Get token from SharedPreferences
  //   //   String? token = await AppSharedPreferences().getString(AppSharedPreferences.token);
  //   //
  //   //   if (token == null || token.isEmpty) {
  //   //     errorMessage.value = 'Please login first';
  //   //     isLoading.value = false;
  //   //     return;
  //   //   }
  //   //
  //   //   ConsoleLog.printColor("Fetching product details for ID: $productId");
  //   //
  //   //   // API call
  //   //   var response = await ApiProvider().getData(
  //   //     WebApiConstant.productDetailApi + productId,
  //   //     token,
  //   //   );
  //   //
  //   //   ConsoleLog.printColor("Product Detail Response: $response");
  //   //
  //   //   if (response != null) {
  //   //     var apiResponse = ProductDetailsApiResponseModel.fromJson(response);
  //   //
  //   //     if (apiResponse.status == 200) {
  //   //       productDetail.value = apiResponse.data;
  //   //       ConsoleLog.printColor("Product details loaded successfully");
  //   //     } else {
  //   //       errorMessage.value = apiResponse.msg ?? 'Failed to load product details';
  //   //       ConsoleLog.printColor("API Error: ${apiResponse.msg}", ConsoleLog.red);
  //   //     }
  //   //   } else {
  //   //     errorMessage.value = 'Failed to load product details';
  //   //     ConsoleLog.printColor("Response is null", ConsoleLog.red);
  //   //   }
  //   // } catch (e) {
  //   //   errorMessage.value = 'Error: ${e.toString()}';
  //   //   ConsoleLog.printColor("Exception in getProductDetails: $e", ConsoleLog.red);
  //   // } finally {
  //   //   isLoading.value = false;
  //   // }
  // }

  // For stock fetching without loading indicator
  Future<ProductDetailsResponseData?> getProductDetailsForStock(String slug) async {
    Map<String, dynamic> dict = {
      "slug": slug,
    };

    try {
      await loadToken();

      var response = await ApiProvider().productDetailsAPI(
        Get.context!,
        WebApiConstant.API_URL_HOME_PRODUCT_DETAILS,
        dict,
        userAccessToken ?? "",
      );

      if (response != null &&
          response.error != true &&
          response.errorCode == 0 &&
          response.data != null) {
        return response.data;
      }
    } catch (e) {
      ConsoleLog.printError("Exception in getProductDetailsForStock: $e");
    }

    return null;
  }

  @override
  void onClose() {
    clearProductData();
    currentLoadingSlug = null;
    // productDetail.value = null;
    super.onClose();
  }
}
