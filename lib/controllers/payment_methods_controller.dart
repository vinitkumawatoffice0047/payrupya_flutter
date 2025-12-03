import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_shared_preferences.dart';

class PaymentMethodsController extends GetxController {
  var selectedPaymentMethod = 'cod'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethod();
  }

  Future<void> loadPaymentMethod() async {
    final savedMethod = await AppSharedPreferences.getPaymentMethod();
    if (savedMethod != null && savedMethod.isNotEmpty) {
      selectedPaymentMethod.value = savedMethod;
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> savePaymentMethod() async {
    await AppSharedPreferences.setPaymentMethod(selectedPaymentMethod.value);
    Get.back();
    Get.snackbar(
      'Success',
      'Payment method saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Method to get selected payment method (to be used in checkout)
  static Future<String> getSelectedPaymentMethod() async {
    final method = await AppSharedPreferences.getPaymentMethod();
    return method ?? 'cod';
  }
}