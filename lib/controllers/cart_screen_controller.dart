import 'dart:ffi';

// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// import 'package:groticshop/View/Dashboard/Home/HomeScreen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../../DataProvider/api_provider.dart';
// import '../../DataProvider/app_shared_preferences.dart';
// import '../../DataProvider/web_api_constant.dart';
// import '../../Util/Print/print_log.dart';
// import '../../Util/QuickAlert/QuickAlert.dart';
// import '../Dashboard/DashboardScreen.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/CartListApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/CustomDialog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/custom_success_dialog.dart';
import '../view/main_screen.dart';

class AddToCartScreenController extends GetxController{
  String? userAccessToken;
  RxBool isLogined =false.obs;
  RxList<String> banner = <String>[].obs;
  // RxList<Data> banners = <Data>[].obs;  // Observable list for banners
  RxList<String> category = <String>[].obs;
  RxString title = "".obs;
  RxInt product_id = 0.obs;
  RxString description = "".obs;
  RxString price = "".obs;
  RxString disc_price = "".obs;
 RxInt currentIndex = 0.obs;

  RxList<Data> cartList = <Data>[].obs;
  RxInt cart_item = 0.obs;
  RxDouble total_price = 0.0.obs;
  RxDouble actual_amt = 0.0.obs;
  RxDouble difference_amt = 0.0.obs;
  RxInt prodectQty = 1.obs;
  String? userName;
  String? mobileNo;
  String orderId="";
  String customerName="";
  String productName="";
  double prices=0.0;
  String addresss="";
  int Payment=0;

  @override
  void onInit() {
    super.onInit();
    AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
  });
  }

  // Future<void> productDetails(BuildContext context, String slug) async{
  //   Map<String, dynamic> dict = {
  //     "slug":slug,
  //   };
  //   try {
  //     ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
  //     var response = await ApiProvider().productDetailsAPI(
  //         context, WebApiConstant.API_URL_HOME_PRODUCT_DETAILS, dict, "");
  //
  //     ConsoleLog.printColor("Response.....$response", color: "green");
  //     if (response != null) {
  //       if (response.error != true && response.errorCode == 0) {
  //         if (response.data?.images != null) {
  //           banner.value = response.data?.images ?? [];
  //         }
  //
  //       } else {
  //         Fluttertoast.showToast(msg: response.message ?? "");
  //       }
  //       product_id.value=response.data?.id! ??0 ;
  //       title.value=response.data?.title! ??"" ;
  //       price.value= response.data?.price!.toString() ??"" ;
  //       disc_price.value=response.data?.discPrice!.toString() ?? "" ;
  //       description.value=response.data?.discription! ?? "" ;
  //     }
  //   } catch (e) {
  //     ConsoleLog.printError("Exception...$e...");
  //     Fluttertoast.showToast(msg: WebApiConstant.ApiError);
  //   }
  // }

  Future<void> getCartList(BuildContext context,) async{

    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "green");
      var response = await ApiProvider().getCartList(
          context,userAccessToken!);

      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          if (response.data!= null) {
            cartList.value=response.data! ??[];
            cart_item.value=response.cart_item!;
            total_price.value=response.total_amt!;
            actual_amt.value=response.actual_amt!;
            difference_amt.value=response.difference_amt!;
          }
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
    }
  }

  Future<void> addToCart(BuildContext context, String id, {String? qty}) async{
    Map<String, dynamic> dict = {
      "product_id":id,
      "qty":qty,
    };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...");
      var response = await ApiProvider().addToCartApi(context, WebApiConstant.API_URL_ADD_TO_CART, dict, userAccessToken!);

      ConsoleLog.printColor("Response.....$response",color: "green");

      if (response != null) {
        if (response['error'] != true && response['errorCode'] == 0) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success, // Correct the type to QuickAlertType.success
            title: "Success",  // Capitalized 'Success' for a proper title
            text: response['message'], // Display the message from the response
            confirmBtnText: 'OK',
            onConfirmBtnTap: () {
              Get.offAll(MainScreen(selectedIndex: 2,));
             // Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );//         Get.back();
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning, // Correct the type to QuickAlertType.success
            title: "Warning",  // Capitalized 'Success' for a proper title
            text: response['message'], // Display the message from the response
            confirmBtnText: 'OK',
            onConfirmBtnTap: () {
              Get.back();
              },
          );
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  Future<void> deleteToCartApi(BuildContext context, id) async{
    Map<String, dynamic> dict = {
      "cart_id": id,
    };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().deleteToCartApi(context, WebApiConstant.API_URL_DELETE_TO_CART, dict, userAccessToken!);
      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        if (response['error'] != true && response['errorCode'] == 0) {
          Fluttertoast.showToast(msg: response['message'] ?? "");
          getCartList(context);
        } else {
          Fluttertoast.showToast(msg: response['message'] ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  // Future<void> getToken(BuildContext context, String slug) async {
  //   await AppSharedPreferences().getBool(AppSharedPreferences.isLogin).then((value){
  //     isLogined.value = value;
  //   });
  //   await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
  //     userAccessToken = value;
  //     productDetails(context,slug);
  //   });
  // }

  Future<void> buyNow(BuildContext context,String address,String pinCode,deliver,String amount) async{
    Map<String, dynamic> dict = {
      "address":address,
      "phone_no":mobileNo,
      "pin_code":pinCode,
      "user_name":userName,
      "deliver_type":deliver,
    };
    try {
      var response = await ApiProvider().buyNowApi(
          context, WebApiConstant.API_URL_BUY_NOW, dict,userAccessToken!);

      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {

        if (response['error'] != true && response['errorCode'] == 0) {
          // getCartList(context);
          if(deliver==0){
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return OrderSuccessDialog(
                    orderId: response["data"]!["order_id"].toString(),
                    customerName: response["data"]!["user_name"] ?? "--",
                    address: response["data"]!["address"] ?? "--",
                    onClose: () {
                      Get.back();
                      Get.back();
                      getCartList(context);
                    },
                    Payment: int.parse(response["data"]!["deliver_type"].toString()),
                  );
                },
              );
            });
          }
          else{
            // initPayment(amount);
            String description = 'Fine T-Shirt';
            startTransacitonRazorPay( response["data"]!["payment"]!["notes"]!["key"],
                response["data"]!["payment"]!["amount"]!.toString(),
                response["data"]!["payment"]!["notes"]!["name"] ?? "demo",
                response["data"]!["payment"]!["notes"]!["mobile"].toString(),
                response["data"]!["payment"]!["notes"]!["email"],
                response["data"]!["payment"]!["id"],
                description
            );
            orderId=response["data"]!["order"]!["order_id"].toString();
            customerName=response["data"]!["payment"]!["notes"]!["name"] ?? "demo";
            // productName=response["data"]!["payment"]!["notes"]!["name"] ?? "demo";
            // prices=double.parse(response["data"]!["payment"]!["amount"].toString(),);
            addresss=response["data"]!["order"]!["address"];
            Payment=int.parse(response["data"]!["order"]!["deliver_type"].toString(),);
            //void startTransacitonRazorPay(String key,String amount,String name,String mobileNo,String email,String orderId){
          }//         Get.back();
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning, // Correct the type to QuickAlertType.success
            title: "Warning",  // Capitalized 'Success' for a proper title
            text: response['message'], // Display the message from the response
            confirmBtnText: 'OK',
            onConfirmBtnTap: () {
              Get.back();
            },
          );
          //Fluttertoast.showToast(msg: response['message'] ?? "");
        }

      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  void startTransacitonRazorPay(String key,String amount,String name,String mobileNo,String email,String orderId,String description){
    try {
      Razorpay razorpay = Razorpay();
      var options = {
        'key': key,
        'amount': amount,
        'order_id': orderId,
        'name': name,
        'description': description,
        'retry': {'enabled': true, 'max_count': 2},
        'send_sms_hash': true,
        'prefill': {'contact': mobileNo, 'email': email},
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
      razorpay.open(options);
    }catch (ex){
      ConsoleLog.printError("$ex");
    }
  }
  void handlePaymentErrorResponse(PaymentFailureResponse response){
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    //showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
    QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.warning,
        text: response.message,
        onConfirmBtnTap: (){
          Get.back();

        }
    );

  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){
    QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        text: response.paymentId,
        onConfirmBtnTap: (){
          Get.back();
          Get.back();
        }
    );
  }

  void showAlertDialog(BuildContext context, String title, String content) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(content,textAlign: TextAlign.justify),
            ),
            actions: [okButton],
          );
        });
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog(Get.context!, "External Wallet Selected", "${response.walletName}");
  }
  // Future<void> showAlertDialog(BuildContext context, String title, String message) async {
  //   // set up the buttons
  //   Widget continueButton = ElevatedButton(
  //     child: const Text("Continue"),
  //     onPressed:  () {},
  //   );
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text(title),
  //     content: Text(message),
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  void handleTransactionStatus(Map<dynamic, dynamic> response) {
    String status = response['status'].toString();
    if (status == 'SUCCESS')
    {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: Get.context! ,
          builder: (BuildContext context) {
            return OrderSuccessDialog(
              orderId:orderId,
              customerName:customerName,
              // productName:productName,
              // price: prices,
              address:addresss,
              onClose: () {
                Get.back();
                Get.back();
                Get.back();

              },
              Payment:Payment,
            );
          },
        );
      });
    }
    else {
      CustomDialog.showDialog1(Get.context!,  "Transaction Failed , Please check in your transaction history ");
    }
  }
}