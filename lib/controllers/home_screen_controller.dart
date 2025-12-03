import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/HomeDetailsApiResponseModel.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/comming_soon_dialog.dart';

class HomeScreenController extends GetxController{
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var pageIndex = 0.obs;
  String? userAccessToken;
  RxString userName = "".obs;
  RxInt ispaytmeadenable = 0.obs;
  RxList<Banners> banner = <Banners>[].obs;
  RxList<Category> category = <Category>[].obs;
  RxList<TopSelling> topSellProduct = <TopSelling>[].obs;
  RxList<MaleWellness> maleWellnessProduct = <MaleWellness>[].obs;
  RxList<FemaleWellness> femaleWellness = <FemaleWellness>[].obs;
  List<Category> filteredCategories = [];


  var balance = '0.00'.obs;
  var location = 'Add Location'.obs;
  var coordinates = '0.0, 0.0'.obs;
  var downBanks = <Map<String, dynamic>>[].obs;


  // @override
  @override
  void onInit() async {
    super.onInit();
    await getToken(Get.context!);
  }

  // API calls
  Future<void> getBalance() async {
    // API implementation
  }

  Future<void> getDownBanks() async {
    // API implementation
  }

  Future<void> loadHomePageAPI(BuildContext context) async {
    try {
      isLoading(true);
      errorMessage('');
      print("UserToken...$userAccessToken...");
      var response = await ApiProvider().homePageAPI(context, userAccessToken!);
      print("Response.....$response");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          if (response.data?.banner != null) {
            banner.value = response.data?.banner ?? [];
          }
          if (response.data?.category != null) {
            category.value=response.data?.category ??[];
          }
          if (response.data?.topSelling != null) {
              topSellProduct.value=response.data?.topSelling ??[];
          }
          if (response.data?.maleWellness != null) {
              maleWellnessProduct.value=response.data?.maleWellness ??[];
          }
          if (response.data?.femaleWellness != null) {
              femaleWellness.value=response.data?.femaleWellness ??[];
          }
          } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
      }else{
        errorMessage("Something went wrong");
      }
    } catch (_) {
      print("Exception...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
      errorMessage("Failed to load data");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getToken(BuildContext context) async {
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      loadHomePageAPI(context);
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
