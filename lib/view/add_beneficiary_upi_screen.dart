// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../utils/global_utils.dart';
//
// class AddBeneficiaryScreen extends StatefulWidget {
//   const AddBeneficiaryScreen({super.key});
//
//   @override
//   State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
// }
//
// class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
//   final TextEditingController ifscController = TextEditingController();
//   final TextEditingController accountNumberController = TextEditingController();
//   final TextEditingController accountHolderController = TextEditingController();
//
//   String selectedBank = 'State Bank of India';
//   String senderName = "Sohel Khan";
//   String senderMobile = "+91 9999887777";
//   bool isVerified = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         height: GlobalUtils.getScreenHeight(),
//         width: GlobalUtils.getScreenWidth(),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: GlobalUtils.getBackgroundColor()
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               buildHeader(context),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 child: Column(
//                   children: [
//                     buildBeneficiaryForm(),
//                   ],
//                 ),
//               ),
//               Spacer(),
//               // Save Button
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 child: GlobalUtils.CustomButton(
//                   text: "Save",
//                   onPressed: () {
//                     Get.back();
//                   },
//                   textStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (16 / 393),
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   // width: GlobalUtils.screenWidth * 0.9,
//                   height: GlobalUtils.screenWidth * (60 / 393),
//                   backgroundGradient: GlobalUtils.blueBtnGradientColor,
//                   borderColor: Color(0xFF71A9FF),
//                   showShadow: false,
//                   textColor: Colors.white,
//                   animation: ButtonAnimation.fade,
//                   animationDuration: const Duration(milliseconds: 150),
//                   buttonType: ButtonType.elevated,
//                   borderRadius: 16,
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildHeader(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           /// BACK BUTTON
//           GestureDetector(
//             onTap: () => Get.back(),
//             child: Container(
//               height: GlobalUtils.screenHeight * (22 / 393),
//               width: GlobalUtils.screenWidth * (47 / 393),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
//             ),
//           ),
//           SizedBox(width: 16),
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: Colors.transparent,
//             backgroundImage: AssetImage('assets/images/avatar.png'),
//             onBackgroundImageError: (exception, stackTrace) {},
//             child: Image.asset(
//               'assets/images/avatar.png',
//               errorBuilder: (context, error, stackTrace) {
//                 return Icon(Icons.person, size: 24, color: Colors.grey);
//               },
//             ),
//           ),
//           SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     senderName,
//                     style: GoogleFonts.albertSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: Color(0xff1B1C1C),
//                     ),
//                   ),
//                   SizedBox(width: 6),
//                   if (isVerified)
//                     Icon(Icons.verified, color: Colors.green, size: 18),
//                 ],
//               ),
//               Text(
//                 senderMobile,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Color(0xff6B707E),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBeneficiaryForm() {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 10),
//           Text(
//             'Add New Beneficiary :',
//             style: GoogleFonts.albertSans(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Color(0xff1B1C1C),
//             ),
//           ),
//           SizedBox(height: 20),
//           // Bank Name Dropdown
//           buildLabelText('Bank Name'),
//           SizedBox(height: 8),
//           buildBankRow(),
//           // Container(
//           //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           //   decoration: BoxDecoration(
//           //     color: Color(0xFFF8FAFC),
//           //     borderRadius: BorderRadius.circular(12),
//           //     border: Border.all(color: Colors.grey[200]!),
//           //   ),
//           //   child: Row(
//           //     children: [
//           //       Container(
//           //         padding: EdgeInsets.all(8),
//           //         decoration: BoxDecoration(
//           //           color: Color(0xFF4A90E2).withOpacity(0.1),
//           //           shape: BoxShape.circle,
//           //         ),
//           //         child: Icon(Icons.account_balance, size: 20, color: Color(0xFF4A90E2)),
//           //       ),
//           //       SizedBox(width: 12),
//           //       Expanded(
//           //         child: Text(
//           //           selectedBank,
//           //           style: TextStyle(
//           //             fontSize: 14,
//           //             color: Colors.black87,
//           //             fontWeight: FontWeight.w500,
//           //           ),
//           //         ),
//           //       ),
//           //       Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
//           //     ],
//           //   ),
//           // ),
//           SizedBox(height: 16),
//           // IFSC Field
//           Row(
//             children: [
//               buildLabelText('IFSC'),
//               Text("*", style: TextStyle(color: Colors.red, fontSize: 12,),),
//             ],
//           ),
//           SizedBox(height: 8),
//           GlobalUtils.CustomTextField(
//             label: "IFSC Number",
//             showLabel: false,
//             controller: ifscController,
//             placeholder: "IFSC Number",
//             placeholderColor: Colors.white,
//             height: GlobalUtils.screenWidth * (60 / 393),
//             width: GlobalUtils.screenWidth * 0.9,
//             autoValidate: false,
//             backgroundColor: Colors.white,
//             borderColor: Color(0xffE2E5EC),
//             borderRadius: 16,
//             placeholderStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF6B707E),
//             ),
//             inputTextStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF1B1C1C),
//             ),
//             errorColor: Colors.red,
//             errorFontSize: 12,
//           ),
//           // _buildTextField(
//           //   controller: _ifscController,
//           //   hint: 'IFSC Number',
//           // ),
//           SizedBox(height: 16),
//           // Account Number Field
//           buildLabelText('Account Number'),
//           SizedBox(height: 8),
//           GlobalUtils.CustomTextField(
//             label: "Account Number",
//             showLabel: false,
//             controller: accountNumberController,
//             placeholder: "Account Number",
//             placeholderColor: Colors.white,
//             keyboardType: TextInputType.number,
//             // isNumber: true,
//             height: GlobalUtils.screenWidth * (60 / 393),
//             width: GlobalUtils.screenWidth * 0.9,
//             autoValidate: false,
//             backgroundColor: Colors.white,
//             borderColor: Color(0xffE2E5EC),
//             borderRadius: 16,
//             placeholderStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF6B707E),
//             ),
//             inputTextStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF1B1C1C),
//             ),
//             errorColor: Colors.red,
//             errorFontSize: 12,
//             suffixIcon: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               margin: EdgeInsets.only(right: 8),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '14',
//                     style: TextStyle(
//                       color: Color(0xFF0054D3),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // _buildTextField(
//           //   controller: _accountNumberController,
//           //   hint: '98451264054222',
//           //   keyboardType: TextInputType.number,
//           //   suffixIcon: Container(
//           //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           //     margin: EdgeInsets.only(right: 8),
//           //     decoration: BoxDecoration(
//           //       color: Colors.transparent,
//           //       borderRadius: BorderRadius.circular(6),
//           //     ),
//           //     child: Row(
//           //       mainAxisSize: MainAxisSize.min,
//           //       children: [
//           //         Icon(Icons.verified, color: Color(0xFF4A90E2), size: 14),
//           //         SizedBox(width: 4),
//           //         Text(
//           //           '14',
//           //           style: TextStyle(
//           //             color: Color(0xFF4A90E2),
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           SizedBox(height: 16),
//           // Account Holder Name Field
//           buildLabelText('Account Holder Name'),
//           SizedBox(height: 8),
//           GlobalUtils.CustomTextField(
//             label: "Account Holder Name",
//             showLabel: false,
//             controller: accountHolderController,
//             placeholder: "Account Holder Name",
//             placeholderColor: Colors.white,
//             height: GlobalUtils.screenWidth * (60 / 393),
//             width: GlobalUtils.screenWidth * 0.9,
//             autoValidate: false,
//             backgroundColor: Colors.white,
//             borderColor: Color(0xffE2E5EC),
//             borderRadius: 16,
//             placeholderStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF6B707E),
//             ),
//             inputTextStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (14 / 393),
//               color: Color(0xFF1B1C1C),
//             ),
//             errorColor: Colors.red,
//             errorFontSize: 12,
//             suffixIcon: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               margin: EdgeInsets.only(right: 8),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Get Name',
//                     style: TextStyle(
//                       color: Color(0xFF0054D3),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // _buildTextField(
//           //   controller: _accountHolderController,
//           //   hint: 'Account Holder Name',
//           //   suffixText: 'Get Name',
//           //   suffixTextColor: Color(0xFF4A90E2),
//           // ),
//           // SizedBox(height: 200),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBankRow() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         // color: Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Image.asset("assets/images/sbi_logo.png", width: 36),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'State Bank of India',
//               style: GoogleFonts.albertSans(
//                 fontSize: 16,
//                 color: Color(0xff1B1C1C),
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
//         ],
//       ),
//     );
//   }
//
//   Widget buildLabelText(String text) {
//     return Text(
//       text,
//       style: GoogleFonts.albertSans(
//         fontSize: 14,
//         color: Color(0xff6B707E),
//         fontWeight: FontWeight.w400,
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType? keyboardType,
//     String? suffixText,
//     Color? suffixTextColor,
//     Widget? suffixIcon,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           suffixIcon: suffixIcon ??
//               (suffixText != null
//                   ? Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 margin: EdgeInsets.only(right: 8),
//                 child: Center(
//                   widthFactor: 1,
//                   child: Text(
//                     suffixText,
//                     style: TextStyle(
//                       color: suffixTextColor ?? Color(0xFF4A90E2),
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//                   : null),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     ifscController.dispose();
//     accountNumberController.dispose();
//     accountHolderController.dispose();
//     super.dispose();
//   }
// }



// lib/view/add_beneficiary_screen.dart
// Complete implementation with API integration

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/utils/ConsoleLog.dart';
import '../controllers/dmt_wallet_controller.dart';
import '../controllers/upi_wallet_controller.dart';
import '../utils/global_utils.dart';

class AddBeneficiaryUPIScreen extends StatefulWidget {
  const AddBeneficiaryUPIScreen({super.key});

  @override
  State<AddBeneficiaryUPIScreen> createState() => _AddBeneficiaryUPIScreenState();
}

class _AddBeneficiaryUPIScreenState extends State<AddBeneficiaryUPIScreen> {
  // final DmtWalletController upiWalletController = Get.put(DmtWalletController());
  final UPIWalletController upiWalletController = Get.put(UPIWalletController());
  final ValueNotifier<int> charCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoadingName = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Clear form
    upiWalletController.selectedPaymentMode.value = "Phonepay";
    upiWalletController.selectedBank.value = "Select Bank";
    upiWalletController.beneIfscController.value.clear();
    upiWalletController.beneMobileController.value.clear();
    upiWalletController.beneAccountController.value.clear();
    upiWalletController.beneNameController.value.clear();
    upiWalletController.isAccountVerified.value = false;

    // Fetch banks list
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        upiWalletController.getAllBanks(context);
      }
    });
  }

  @override
  void dispose() {
    charCountNotifier.dispose();
    isLoadingName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for manage multiple text field keyboard and cursor
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        body: SafeArea(
          child: Column(
            children: [
              buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  child: buildBeneficiaryForm(),
                ),
              ),
            ],
          ),
        ),
      ),
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
            onTap: () => Get.back(),
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
            "Add New Beneficiary",
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

  Widget buildToggleButton(String imgPath, String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF0054D3).withOpacity(0.15),
              spreadRadius: 3,
              blurRadius: 0,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(imgPath),
            ),
            // Container(
            //   width: 20,
            //   height: 20,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     border: Border.all(
            //       color: isSelected ? Color(0xFF0054D3) : Colors.grey[400]!,
            //       width: 1,
            //     ),
            //   ),
            //   child: isSelected
            //       ? Center(
            //     child: Container(
            //       width: 10,
            //       height: 10,
            //       decoration: BoxDecoration(
            //         color: Color(0xFF0054D3),
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //   )
            //       : null,
            // ),
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBeneficiaryForm() {
    return Obx(() => Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode :',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1B1C1C),
                  ),
                ),
                SizedBox(height: 20),

                //region Payment Toggles
                SizedBox(
                  height: 60,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 3),
                        SizedBox(
                          width: GlobalUtils.screenWidth * (155 / 393),
                          height: 55,
                          child: buildToggleButton("assets/icons/phonepe.png", "Phone Pay",
                            upiWalletController.selectedPaymentMode.value == 'Phonepay',
                                () {
                              upiWalletController.selectedPaymentMode.value = 'Phonepay';
                            },),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: GlobalUtils.screenWidth * (155 / 393),
                          height: 55,
                          child: buildToggleButton("assets/icons/gpay.png", "Google Pay",
                            upiWalletController.selectedPaymentMode.value == 'Googlepay',
                                () {
                              upiWalletController.selectedPaymentMode.value = 'Googlepay';
                            },),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: GlobalUtils.screenWidth * (155 / 393),
                          height: 55,
                          child: buildToggleButton("assets/icons/paytm.png", "Paytm",
                            upiWalletController.selectedPaymentMode.value == 'Paytm',
                                () {
                              upiWalletController.selectedPaymentMode.value = 'Paytm';
                            },),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: GlobalUtils.screenWidth * (155 / 393),
                          height: 53,
                          child: buildToggleButton("assets/icons/other_icon.png", "Other",
                            upiWalletController.selectedPaymentMode.value == 'Others',
                                () {
                              upiWalletController.selectedPaymentMode.value = 'Others';
                            },),
                        ),
                        SizedBox(width: 3),
                      ],
                    ),
                  ),
                ),
                //endregion

                SizedBox(height: 16),

                // Beneficiary Name
                buildLabelText('UPI ID'),
                SizedBox(height: 8),
                Row(
                  children: [
                    GlobalUtils.CustomTextField(
                      label: "UPI ID",
                      showLabel: false,
                      controller: upiWalletController.beneVPAController.value,
                      placeholder: upiWalletController.selectedPaymentMode.value == "Phonepay" ? "Enter Phone Pay UPI ID" :
                      upiWalletController.selectedPaymentMode.value == "Googlepay" ? "Enter Google Pay UPI ID" :
                      upiWalletController.selectedPaymentMode.value == "Paytm" ? "Enter Paytm UPI ID" :
                      "Enter UPI ID",
                      height: GlobalUtils.screenWidth * (60 / 393),
                      width: GlobalUtils.screenWidth * 0.7,
                      backgroundColor: Colors.white,
                      borderColor: Color(0xffE2E5EC),
                      borderRadius: 16,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: ValueListenableBuilder<bool>(
                        valueListenable: isLoadingName,
                        builder: (context, loading, child) {
                          return TextButton(
                            onPressed: upiWalletController.verifyButton.value
                                ? null
                                : () => upiWalletController.verifyUPIVPA(context),
                            child: loading
                                ? SizedBox(  // ✅ Show loading indicator
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0054D3)),
                              ),
                            )
                                : Container(  // ✅ Show "Get Name" text
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Verify',
                                    style: GoogleFonts.albertSans(
                                      color: Color(0xFF0054D3),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      maxLength: upiWalletController.selectedPaymentMode.value == "Others" ? null : 10,
                      // inputFormatters: isOthers
                      //     ? null
                      //     : [FilteringTextInputFormatter.digitsOnly],
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return null;
                      },
                      onChanged: (value) {
                        if (upiWalletController.isVPAVerified.value) {
                          upiWalletController.isVPAVerified.value = false;
                        }
                        // Auto-clear VPA selection when mobile changes
                        if (upiWalletController.selectedPaymentMode.value != "Others" && upiWalletController.selectedVPA.value.isNotEmpty) {
                          upiWalletController.selectedVPA.value = '';
                        }
                      },
                      // onSubmitted: (value){
                      //   if(value.isNotEmpty){
                      //     upiWalletController.currentSender.value?.name = value;
                      //   }
                      // },
                      placeholderStyle: GoogleFonts.albertSans(
                        fontSize: GlobalUtils.screenWidth * (14 / 393),
                        color: Color(0xFF6B707E),
                      ),
                      inputTextStyle: GoogleFonts.albertSans(
                        fontSize: GlobalUtils.screenWidth * (14 / 393),
                        color: Color(0xFF1B1C1C),
                      ),
                      enabled: !upiWalletController.isAccountVerified.value,
                      readOnly: upiWalletController.isAccountVerified.value,
                    ),

                    Spacer(),

                    GlobalUtils.CustomButton(
                      onPressed: (){},
                      height: GlobalUtils.screenWidth * (60 / 393),
                      width: GlobalUtils.screenWidth * (60 / 393),
                      backgroundColor: Colors.white,
                      borderColor: Color(0xffE2E5EC),
                      borderRadius: 16,
                      borderWidth: 1,
                      padding: EdgeInsets.all(13),
                      child: Image.asset("assets/icons/scan_icon.png")
                    )
                  ],
                ),

                SizedBox(height: 16),

                // VPA Provider Selection (Only for Paytm, Googlepay, Phonepe)
                Obx(() {
                  bool showVPASelection = upiWalletController.selectedPaymentMode.value != 'Others' &&
                      upiWalletController.beneVPAController.value.text.isNotEmpty;

                  if (!showVPASelection) return SizedBox.shrink();

                  List<String> vpaList = upiWalletController.getVPAListForMode(
                      upiWalletController.selectedPaymentMode.value
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose VPA *',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1B1C1C),
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vpaList.map((vpaProvider) {
                          String mobileNumber = upiWalletController.upiMobileController.value.text;
                          String fullVPA = '$mobileNumber@$vpaProvider';

                          return Obx(() => GestureDetector(
                            onTap: () {
                              upiWalletController.selectedVPA.value = fullVPA;
                              upiWalletController.beneVPAController.value.text = fullVPA;
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: upiWalletController.selectedVPA.value == fullVPA
                                    ? Color(0xFF0054D3).withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: upiWalletController.selectedVPA.value == fullVPA
                                      ? Color(0xFF0054D3)
                                      : Colors.grey[300]!,
                                  width: upiWalletController.selectedVPA.value == fullVPA ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (upiWalletController.selectedVPA.value == fullVPA)
                                    Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.radio_button_checked,
                                        color: Color(0xFF0054D3),
                                        size: 18,
                                      ),
                                    ),
                                  Text(
                                    fullVPA,
                                    style: GoogleFonts.albertSans(
                                      fontSize: 13,
                                      color: upiWalletController.selectedVPA.value == fullVPA
                                          ? Color(0xFF0054D3)
                                          : Colors.black87,
                                      fontWeight: upiWalletController.selectedVPA.value == fullVPA
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }),

                GlobalUtils.CustomTextField(
                  label: "Beneficiary Name",
                  showLabel: false,
                  controller: upiWalletController.beneNameController.value,
                  placeholder: "Beneficiary Name",
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  backgroundColor: Colors.white,
                  borderColor: Color(0xffE2E5EC),
                  borderRadius: 16,
                  // isName: true,
                  // onSubmitted: (value){
                  //   if(value.isNotEmpty){
                  //     upiWalletController.currentSender.value?.name = value;
                  //   }
                  // },
                  placeholderStyle: GoogleFonts.albertSans(
                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                    color: Color(0xFF6B707E),
                  ),
                  inputTextStyle: GoogleFonts.albertSans(
                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                    color: Color(0xFF1B1C1C),
                  ),
                  enabled: !upiWalletController.isAccountVerified.value,
                  readOnly: upiWalletController.isAccountVerified.value,
                ),
              ],
            ),
        ),
        SizedBox(height: 24),

        // Add Beneficiary Button
        GlobalUtils.CustomButton(
          text: "Save",
          onPressed: () async {
            if (upiWalletController.selectedBank.value.isEmpty || upiWalletController.selectedBank.value == "Select Bank") {
              Fluttertoast.showToast(msg: "Please select bank");
              return;
            }

            if (upiWalletController.beneAccountController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "Account number required!");
              return;
            }
            // if (!upiWalletController.isValidAccountNumber(upiWalletController.beneAccountController.value.text.trim())) {
            //   Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
            //   return;
            // }

            if (upiWalletController.beneIfscController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "IFSC code required!");
              return;
            }
            // if (!upiWalletController.isValidIFSC(upiWalletController.beneIfscController.value.text.trim())) {
            //   Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
            //   return;
            // }



            // if (upiWalletController.beneAccountController.value.text.trim().isEmpty) {
            //   Fluttertoast.showToast(msg: "Please enter account number");
            //   return;
            // }
            //
            // if (upiWalletController.beneIfscController.value.text.trim().isEmpty) {
            //   Fluttertoast.showToast(msg: "Please enter IFSC code");
            //   return;
            // }

            if (upiWalletController.beneNameController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "Please enter beneficiary name");
              return;
            }

            if (!upiWalletController.isAccountVerified.value) {
              Fluttertoast.showToast(msg: "Please verify account first");
              return;
            }

            // Add beneficiary
            await upiWalletController.addUPIBeneficiary(context);
          },
          textStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          width: GlobalUtils.screenWidth * 0.9,
          height: GlobalUtils.screenWidth * (60 / 393),
          backgroundGradient: GlobalUtils.blueBtnGradientColor,
          borderColor: Color(0xFF71A9FF),
          showShadow: false,
          textColor: Colors.white,
          animation: ButtonAnimation.fade,
          animationDuration: const Duration(milliseconds: 150),
          buttonType: ButtonType.elevated,
          borderRadius: 16,
        ),
        SizedBox(height: 16),
      ],
    ));
  }

  Widget buildLabelText(String text) {
    return Text(
      text,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Color(0xff6B707E),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void showBankSelectionBottomSheet() {
    TextEditingController searchController = TextEditingController();
    RxList filteredBanks = RxList.from(upiWalletController.banksList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Select Bank',
                      style: GoogleFonts.albertSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Search Field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search bank...',
                        hintStyle: GoogleFonts.albertSans(
                          color: Color(0xFF6B707E),
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Color(0xFF6B707E)),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      style: GoogleFonts.albertSans(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          filteredBanks.value = upiWalletController.banksList;
                        } else {
                          filteredBanks.value = upiWalletController.banksList
                              .where((bank) => bank.bankName!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Banks List
              Expanded(
                child: Obx(() {
                  if (filteredBanks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Color(0xFF6B707E)),
                          SizedBox(height: 16),
                          Text(
                            'No banks found',
                            style: GoogleFonts.albertSans(
                              fontSize: 16,
                              color: Color(0xFF6B707E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBanks.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      var bank = filteredBanks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: bank.logo != null && bank.logo!.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              bank.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                return Icon(
                                  Icons.account_balance,
                                  color: Color(0xFF4A90E2),
                                  size: 24,
                                );
                              },
                            ),
                          )
                              : Icon(
                            Icons.account_balance,
                            color: Color(0xFF4A90E2),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          bank.bankName ?? "Unknown Bank",
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1B1C1C),
                          ),
                        ),
                        subtitle: bank.ifsc != null && bank.ifsc!.isNotEmpty
                            ? Text(
                          'IFSC: ${bank.ifsc}',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Color(0xFF6B707E),
                          ),
                        )
                            : null,
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF6B707E),
                        ),
                        onTap: () {
                          upiWalletController.selectedBank.value =
                              bank.bankName ?? "";
                          upiWalletController.selectedBankId.value =
                              bank.bankId ?? "";
                          upiWalletController.selectedIfsc.value =
                              bank.ifsc ?? "";

                          ConsoleLog.printColor("Selected Bank: ${bank.bankName}, IFSC: ${bank.ifsc}");

                          // Auto-fill IFSC if available
                          if (bank.ifsc != null && bank.ifsc!.isNotEmpty) {
                            upiWalletController.beneIfscController.value.text =
                            bank.ifsc!;
                          }

                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}