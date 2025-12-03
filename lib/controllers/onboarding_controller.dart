import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController
    with GetSingleTickerProviderStateMixin {

  late AnimationController animController;
  late Animation<double> fadeAnim;
  late Animation<double> slideAnim;

  @override
  void onInit() {
    super.onInit();

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOut),
    );

    slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOutCubic),
    );

    animController.forward();
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}
