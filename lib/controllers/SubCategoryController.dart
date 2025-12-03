// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/SubCategoriesApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/comming_soon_dialog.dart';

class SubCategoryScreenController extends GetxController{

  var pageIndex = 0.obs;

  String? userAccessToken;
  // RxString walletAmount = "0.00".obs;
  // RxString pointAmount = "0.00".obs;
  // RxString incomeWallet = "0.00".obs;
  // RxString todayIncome = "0.00".obs;
  // RxDouble total_balance = 0.0.obs;

  // RxBool kycStatus = true.obs;
  RxString userName = "".obs;
  RxList<Child> subCategory = <Child>[].obs;
  RxBool isLoading = false.obs;


  // @override
  @override
  void onInit() async {
    super.onInit();
    await getToken(Get.context!);
  }

  Future<void> subCategoryAPI(BuildContext context, int id) async {
    Map<String, dynamic> dict = {
      "parent_id": id,
    };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().getSubCategorisAPI(context, dict, userAccessToken ?? "");
      ConsoleLog.printColor("Response.....$response");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          if (response.data!= null) {
            subCategory.value=response.data! ?? [];
            Fluttertoast.showToast(msg: response.message ?? "Success");
          }
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }



  // Future<void> getSubCategoryAPI(BuildContext context, int id) async {
  //   isLoading.value = true; // Start loading
  //   Map<String, dynamic> dict = {
  //     "parent_id": id,
  //   };
  //   try {
  //     PrintLog.printLog("UserToken...$userAccessToken...");
  //     var response = await ApiProvider().getSubCategorisAPI(context, dict, userAccessToken ?? "");
  //     PrintLog.printLog("Response.....${response}");
  //     if (response != null) {
  //       if (response.error != true && response.errorCode == 0) {
  //         if (response.data?.children != null) {
  //           subCategory.assignAll(response.data!.children ?? []);
  //           Fluttertoast.showToast(msg: response.message ?? "Success");
  //         }
  //       } else {
  //         Fluttertoast.showToast(msg: response.message ?? "No data found");
  //       }
  //     }
  //   } catch (_) {
  //     PrintLog.printLog("Exception...$_...");
  //     Fluttertoast.showToast(msg: WebApiConstant.ApiError);
  //   } finally {
  //     isLoading.value = false; // Stop loading
  //   }
  // }

  Future<void> getToken(BuildContext context) async {
    // await AppSharedPreferences().getUserDetails1().then((value){
    //   PrintLog.printLog("asdfsf:- $value");
    //   // userName.value = value.name ??"";
    // });
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      //getSubCategoryAPI(context,);
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
