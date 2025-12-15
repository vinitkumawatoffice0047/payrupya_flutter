import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/dmt_wallet_controller.dart';
import 'package:payrupya/models/confirm_transfer_response_model.dart';
import 'package:payrupya/models/get_beneficiary_list_response_model.dart';

import '../utils/global_utils.dart';

class TransactionConfirmationScreen extends StatefulWidget {
  const TransactionConfirmationScreen({super.key});

  @override
  State<TransactionConfirmationScreen> createState() => _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState extends State<TransactionConfirmationScreen> {
  // final TextEditingController txnPinController = TextEditingController();
  DmtWalletController dmtWalletController = Get.put(DmtWalletController());
  // BeneficiaryData beneficiary = BeneficiaryData();
  // ConfirmTransferData chargesData = ConfirmTransferData();

  String senderName = "Unknown";
  String senderMobile = "";
  bool isVerified = false;

  @override
  Widget build(BuildContext context) {
    return Obx((){
      // Get data from controller's confirmationData
      final confirmData = dmtWalletController.confirmationData.value;

      // Check if data exists
      if (confirmData == null) {
        return Scaffold(
          body: Center(
            child: Text('No confirmation data available'),
          ),
        );
      }

      // Extract beneficiary and charges data
      final BeneficiaryData beneficiary = confirmData['beneficiary'] as BeneficiaryData;
      final ConfirmTransferData charges = confirmData['charges'] as ConfirmTransferData;

      return Scaffold(
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
                buildHeader(context),
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
                                  buildConfirmRow('Beneficiary Name', beneficiary.name ?? ''),
                                  buildConfirmRow('Account Number', beneficiary.accountNo ?? ''),
                                  buildConfirmRow('Mode', dmtWalletController.selectedTransferMode.value),
                                  buildConfirmRow('Amount', charges.trasamt ?? 0.toString()),
                                  buildConfirmRow('Charged Amount', charges.chargedamt.toString()),
                                  buildConfirmRow('Total Charge', charges.totalcharge.toString()),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                              if(charges.txnPinStatus == "1")...[
                              SizedBox(height: 8),
                              // buildTextField(
                              //   controller: taxPinController,
                              //   hint: 'Enter Transaction PIN',
                              //   keyboardType: TextInputType.number,
                              // ),
                              Obx(()=>
                                 GlobalUtils.CustomTextField(
                                  label: "Enter Transaction PIN",
                                  showLabel: false,
                                  controller: dmtWalletController.txnPinController.value,
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
                              ],
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
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
                            if(charges.txnPinStatus != "1"){
                              dmtWalletController.txnPinController.value.text = dmtWalletController.txnPin.value;
                            }
                            dmtWalletController.initiateTransfer(context);
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
      );
    }
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          /// BACK BUTTON
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),
          SizedBox(width: 16),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/avatar.png'),
            onBackgroundImageError: (exception, stackTrace) {},
            child: Image.asset(
              'assets/images/avatar.png',
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person, size: 24, color: Colors.grey);
              },
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    senderName,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                  SizedBox(width: 6),
                  if (isVerified)
                    Icon(Icons.verified, color: Colors.green, size: 18),
                ],
              ),
              Text(
                senderMobile,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff6B707E),
                ),
              ),
            ],
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

  Widget buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType, String? suffixText, Widget? suffixWidget, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: GoogleFonts.albertSans(
          fontSize: 14,
          color: Color(0xff1B1C1C),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.albertSans(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixWidget ??
              (suffixText != null
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(right: 8),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    suffixText,
                    style: TextStyle(
                      color: Color(0xFF0054D3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  : null),
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   txnPinController.dispose();
  //   super.dispose();
  // }
}
