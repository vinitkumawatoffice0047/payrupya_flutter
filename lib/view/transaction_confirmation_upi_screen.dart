import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/dmt_wallet_controller.dart';
import 'package:payrupya/controllers/upi_wallet_controller.dart';
import 'package:payrupya/models/confirm_transfer_response_model.dart';
import 'package:payrupya/models/get_beneficiary_list_response_model.dart';

import '../models/get_beneficiary_list_upi_response_model.dart';
import '../utils/global_utils.dart';

class TransactionConfirmationUPIScreen extends StatefulWidget {
  const TransactionConfirmationUPIScreen({super.key});

  @override
  State<TransactionConfirmationUPIScreen> createState() => _TransactionConfirmationUPIScreenState();
}

class _TransactionConfirmationUPIScreenState extends State<TransactionConfirmationUPIScreen> {
  // final TextEditingController txnPinController = TextEditingController();
  UPIWalletController upiWalletController = Get.put(UPIWalletController());
  BeneficiaryUPIData beneficiary = BeneficiaryUPIData();
  // ConfirmTransferData chargesData = ConfirmTransferData();

  String senderName = "Unknown";
  String senderMobile = "";
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    upiWalletController.txnPinController.value.clear();
  }

  @override
  void dispose(){
    upiWalletController.txnPinController.value.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      // Get data from controller's confirmationData
      final confirmData = upiWalletController.confirmationData.value;

      // Check if data exists
      if (confirmData == null) {
        return Scaffold(
          body: Center(
            child: Text('No confirmation data available'),
          ),
        );
      }

      // Extract beneficiary and charges data
      final BeneficiaryUPIData beneficiary = confirmData['beneficiary'] as BeneficiaryUPIData;
      final ConfirmTransferData charges = confirmData['charges'] as ConfirmTransferData;

      return GestureDetector(
        // for manage multiple text field keyboard and cursor
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: GlobalUtils.getScreenHeight(),
            width: GlobalUtils.getScreenWidth(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: GlobalUtils.getBackgroundColor()
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  buildCustomAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'Transaction Confirmation :',
                                      style: GoogleFonts.albertSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Image.asset("assets/images/dashed_line.png"),
                                    SizedBox(height: 10),
                                    buildConfirmRow('Beneficiary Name', beneficiary.benename ?? ''),
                                    buildConfirmRow('UPI ID', beneficiary.vpa ?? ''),
                                    buildConfirmRow('Mode', "UPI"),
                                    buildConfirmRow('Amount', "${double.parse(charges.trasamt ?? 0.toString())}"),
                                    buildConfirmRow('Charges', charges.totalcharge.toString()),
                                    buildConfirmRow('Total Amount', '${double.parse(charges.chargedamt.toString())+double.parse(charges.totalcharge.toString())}'),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if(charges.txnPinStatus == "1")...[
                          SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter Transaction PIN',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    buildLabelText('TXN Pin '),
                                    Text("*", style: GoogleFonts.albertSans(color: Colors.red),)
                                  ],
                                ),
                                SizedBox(height: 8),
                                Obx(()=>
                                   GlobalUtils.CustomTextField(
                                    label: "Enter Transaction PIN",
                                    showLabel: false,
                                    controller: upiWalletController.txnPinController.value,
                                    placeholder: "Enter Transaction PIN",
                                    height: GlobalUtils.screenWidth * (60 / 393),
                                    width: GlobalUtils.screenWidth * 0.9,
                                    backgroundColor: Colors.white,
                                    borderColor: Color(0xffE2E5EC),
                                    borderRadius: 16,
                                    keyboardType: TextInputType.number,
                                    maxLength: 9,
                                    placeholderStyle: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      color: Color(0xFF6B707E),
                                    ),
                                    inputTextStyle: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B1C1C),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          ]
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xffE2E5EC),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff1B1C1C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GlobalUtils.CustomButton(
                            text: "Process",
                            onPressed: () {
                              Get.back();
                              upiWalletController.initiateTransfer(context, beneficiary, upiWalletController.txnPinController.value.text.trim());
                            },
                            textStyle: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (16 / 393),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundGradient: GlobalUtils.blueBtnGradientColor,
                            borderColor: Color(0xFF71A9FF),
                            showShadow: false,
                            textColor: Colors.white,
                            animation: ButtonAnimation.fade,
                            animationDuration: const Duration(milliseconds: 150),
                            buttonType: ButtonType.elevated,
                            borderRadius: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }
    );
  }

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: GlobalUtils.screenWidth * 0.04,
        right: GlobalUtils.screenWidth * 0.04,
        bottom: 16,
        top: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
          onTap: () {
              // Clean up confirmation data when going back
              upiWalletController.confirmationData.value = null;
              upiWalletController.showConfirmation.value = false;
              Get.back();
            },
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            "Transasction Details",
            style: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (20 / 393),
              fontWeight: FontWeight.w600,
              color: const Color(0xff1B1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xff6B707E),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              value,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Color(0xff1B1C1C),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabelText(String text) {
    return Text(
      text,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Color(0xff6B707E),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
