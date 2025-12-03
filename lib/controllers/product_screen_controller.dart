// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/ProductApiResponseModel.dart';
// import '../models/ProductResponseApi.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/comming_soon_dialog.dart';

// import '../../../DataProvider/api_provider.dart';
// import '../../../DataProvider/app_shared_preferences.dart';
// import '../../../DataProvider/web_api_constant.dart';
// import '../../../Util/CustomDialog/comming_soon_dialog.dart';
// import '../../../Util/Print/print_log.dart';
// import '../../Model/ProductModel/ProductResponseApi.dart';

class ProductScreenController extends GetxController{

  var pageIndex = 0.obs;

  String? userAccessToken;
  // RxString walletAmount = "0.00".obs;
  // RxString pointAmount = "0.00".obs;
  // RxString incomeWallet = "0.00".obs;
  // RxString todayIncome = "0.00".obs;
  // RxDouble total_balance = 0.0.obs;

  // RxBool kycStatus = true.obs;
  RxString userName = "".obs;
  // RxInt cartIteam = 0.obs;
  // RxList<ProductDetailsResponseData> product = <ProductDetailsResponseData>[].obs;
  RxList<ProductDetailsResponseData> product = <ProductDetailsResponseData>[].obs;
  RxBool isloading = true.obs;


  Future<void> productApi(BuildContext context,int catId) async {
    Map<String, dynamic> dict = {
      "cat_id":catId,
    };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().categoryToProductApi(
          context,dict,userAccessToken!);
      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          if (response.data != null) {
            // product.value = response.data ?? [];
            product.value = (response.data as List).cast<ProductDetailsResponseData>();
            if(product.value.isEmpty){
              isloading.value = false;
            }
            // cartIteam.value = response.cart_item!;
           }else{
            isloading.value=false;
          }
          // if (response.data?.category != null) {
          //   category.value=response.data?.category ??[];
          // }
          // if (response.data?.topSelling != null) {
          //   topSellProduct.value=response.data?.topSelling ??[];
          // }
          // if (response.data?.maleWellness != null) {
          //   maleWellnessProduct.value=response.data?.maleWellness ??[];
          // }
          // if (response.data?.femaleWellness != null) {
          //   femaleWellness.value=response.data?.femaleWellness ??[];
          // }
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  Future<void> getToken(BuildContext context, int catId) async {
    // await AppSharedPreferences().getUserDetails1().then((value){
    //   PrintLog.printLog("asdfsf:- $value");
    //   // userName.value = value.name ??"";
    // });
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      productApi(context, catId);
    });
  }
  void showPopUp(context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: uploadBox(context),
          ),
        );
      },);
  }
}
