// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/OrderDetailsApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';

class OrderDetailsScreenController extends GetxController{
  String? userAccessToken;
  Rx<OrderData?> orderList = Rx<OrderData?>(null);
  RxList<OrderItem> orderItemList = <OrderItem>[].obs;
  RxBool isLoading = false.obs;



  Future<void> getToken(BuildContext context,orderId) async {
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      getOrderDetailsList(context,orderId);
    });
  }

  Future<void> getOrderDetailsList(BuildContext context,String orderId) async{
    isLoading = true.obs;
    Map<String, dynamic> dict = {
        "order_id":orderId,
      };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().getOrderDetailsList(
          context,userAccessToken!,dict);

      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        isLoading =false.obs;
        if (response.error != true && response.errorCode == 0) {
            orderList.value=response.orderData!; // Store only the first index
            orderItemList.value=response.orderItem ??[];
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
        // product_id.value=response.data?.id! ??0 ;
        // title.value=response.data?.title! ??"" ;
        // price.value= response.data?.price!.toString() ??"" ;
        // disc_price.value=response.data?.discPrice!.toString() ?? "" ;
        // description.value=response.data?.discription! ?? "" ;
      }
    } catch (e) {
      isLoading =false.obs;
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }
}
