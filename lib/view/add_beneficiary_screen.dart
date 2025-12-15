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
import '../utils/global_utils.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final DmtWalletController dmtController = Get.put(DmtWalletController());
  final ValueNotifier<int> charCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoadingName = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Clear form
    dmtController.selectedBank.value = "Select Bank";
    dmtController.beneIfscController.value.clear();
    dmtController.beneMobileController.value.clear();
    dmtController.beneAccountController.value.clear();
    dmtController.beneNameController.value.clear();
    dmtController.isAccountVerified.value = false;

    // Fetch banks list
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        dmtController.getAllBanks(context);
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
            "Add Beneficiary",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beneficiary Details',
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1B1C1C),
                ),
              ),
              SizedBox(height: 20),

              // Bank Selection
              buildLabelText('Bank Name'),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (dmtController.banksList.isEmpty) {
                    Fluttertoast.showToast(msg: "Loading banks...");
                    dmtController.getAllBanks(context);
                    return;
                  }
                  showBankSelectionBottomSheet();
                },
                child: Container(
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xffE2E5EC)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance,
                          color: Color(0xFF6B707E), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dmtController.selectedBank.value.isEmpty
                              ? "Select Bank"
                              : dmtController.selectedBank.value,
                          style: GoogleFonts.albertSans(
                            fontSize: GlobalUtils.screenWidth * (14 / 393),
                            color: dmtController.selectedBank.value.isEmpty
                                ? Color(0xFF6B707E)
                                : Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF6B707E)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // IFSC Code
              SizedBox(child: Row(
                children: [
                  buildLabelText('IFSC'),
                  Text("*", style: TextStyle(color: Colors.red, fontSize: 12,),),
                ],
              )),
              SizedBox(height: 8),
              GlobalUtils.CustomTextField(
                label: "IFSC Code",
                showLabel: false,
                controller: dmtController.beneIfscController.value,
                placeholder: "IFSC Code",
                height: GlobalUtils.screenWidth * (60 / 393),
                width: GlobalUtils.screenWidth * 0.9,
                backgroundColor: Colors.white,
                borderColor: Color(0xffE2E5EC),
                borderRadius: 16,
                placeholderStyle: GoogleFonts.albertSans(
                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                  color: Color(0xFF6B707E),
                ),
                inputTextStyle: GoogleFonts.albertSans(
                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                  color: Color(0xFF1B1C1C),
                ),
                prefixIcon: Icon(Icons.code,
                    color: Color(0xFF6B707E), size: 20),
                /*suffixIcon: TextButton(
                  onPressed: () async {
                    String account = dmtController.beneAccountController.value.text.trim();
                    String ifsc = dmtController.beneIfscController.value.text.trim();

                    if (account.isEmpty) {
                      Fluttertoast.showToast(msg: "Account number required!");
                      return;
                    }
                    if (!dmtController.isValidAccountNumber(account)) {
                      Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
                      return;
                    }
                    if (ifsc.isEmpty) {
                      Fluttertoast.showToast(msg: "IFSC code required!");
                      return;
                    }
                    if (!dmtController.isValidIFSC(ifsc)) {
                      Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
                      return;
                    }
                    if(dmtController.beneNameController.value.text.trim().isEmpty){
                      Fluttertoast.showToast(msg: "Please enter beneficiary name!");
                      return;
                    }
                    if (dmtController.selectedBank.value.isEmpty || dmtController.selectedBank.value == "Select Bank") {
                      Fluttertoast.showToast(msg: "Please select bank first", backgroundColor: Colors.red);
                      return;
                    }

                    // Verify account
                    await dmtController.verifyAccount(context);
                  },
                  child: dmtController.isAccountVerified.value ?
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Image.asset("assets/images/verified_icon.png",
                      height: 20,
                      ),
                      SizedBox(width: 2,),
                      Text("Verified", style: GoogleFonts.albertSans(
                        fontSize: GlobalUtils.screenWidth * (14 / 393),
                        color: Color(0xFF0054D3),
                        fontWeight: FontWeight.w500,
                      ),),
                      SizedBox(width: 12,),
                    ],) :
                    Text(
                      "Verify",
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0054D3),
                      ),
                    ),
                ),*/
              ),

              SizedBox(height: 16),

              // Account Number
              buildLabelText('Account Number'),
              SizedBox(height: 8),
              GlobalUtils.CustomTextField(
                onChanged: (value) {
                  charCountNotifier.value = value.length;
                },
                label: "Account Number",
                showLabel: false,
                controller: dmtController.beneAccountController.value,
                placeholder: "Account Number",
                height: GlobalUtils.screenWidth * (60 / 393),
                width: GlobalUtils.screenWidth * 0.9,
                backgroundColor: Colors.white,
                borderColor: Color(0xffE2E5EC),
                borderRadius: 16,
                keyboardType: TextInputType.number,
                suffixIcon: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: charCountNotifier,
                        builder: (context, count, child) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              '$count',
                              style: GoogleFonts.albertSans(
                                color: Color(0xFF0054D3),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                placeholderStyle: GoogleFonts.albertSans(
                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                  color: Color(0xFF6B707E),
                ),
                inputTextStyle: GoogleFonts.albertSans(
                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                  color: Color(0xFF1B1C1C),
                ),
                prefixIcon: Icon(Icons.account_balance_wallet,
                    color: Color(0xFF6B707E), size: 20),
              ),

              SizedBox(height: 16),

              // Account verification status
              if (dmtController.isAccountVerified.value) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4CAF50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF4CAF50), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Account verified successfully',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Beneficiary Name
              buildLabelText('Account Holder Name'),
              SizedBox(height: 8),
              GlobalUtils.CustomTextField(
                label: "Account Holder Name",
                showLabel: false,
                controller: dmtController.beneNameController.value,
                placeholder: "Account Holder Name",
                height: GlobalUtils.screenWidth * (60 / 393),
                width: GlobalUtils.screenWidth * 0.9,
                backgroundColor: Colors.white,
                borderColor: Color(0xffE2E5EC),
                borderRadius: 16,
                isName: true,
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: isLoadingName,
                  builder: (context, loading, child) {
                    return TextButton(
                      onPressed: loading ? null : () async{
                        String account = dmtController.beneAccountController.value.text.trim();
                        String ifsc = dmtController.beneIfscController.value.text.trim();
                        if (account.isEmpty) {
                          Fluttertoast.showToast(msg: "Account number required!");
                          return;
                        }
                        if (!dmtController.isValidAccountNumber(account)) {
                          Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
                          return;
                        }
                        if (ifsc.isEmpty) {
                          Fluttertoast.showToast(msg: "IFSC code required!");
                          return;
                        }
                        if (!dmtController.isValidIFSC(ifsc)) {
                          Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
                          return;
                        }
                        if (dmtController.selectedBank.value.isEmpty || dmtController.selectedBank.value == "Select Bank") {
                          Fluttertoast.showToast(msg: "Please select bank first", backgroundColor: Colors.red);
                          return;
                        }
                        isLoadingName.value = true;
                        await dmtController.getBeneficiaryName(context);
                        isLoadingName.value = false;
                        // dmtController.getBeneficiaryName(context);
                      },
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
                              'Get Name',
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
                // onSubmitted: (value){
                //   if(value.isNotEmpty){
                //     dmtController.currentSender.value?.name = value;
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
                prefixIcon: Icon(Icons.person,
                    color: Color(0xFF6B707E), size: 20),
                enabled: !dmtController.isAccountVerified.value,
                readOnly: dmtController.isAccountVerified.value,
              ),
              // SizedBox(height: 16),
              //
              // // Mobile Number (Optional)
              // buildLabelText('Mobile Number (Optional)'),
              // SizedBox(height: 8),
              // GlobalUtils.CustomTextField(
              //   label: "Mobile Number",
              //   showLabel: false,
              //   controller: dmtController.beneMobileController.value,
              //   placeholder: "Mobile Number",
              //   height: GlobalUtils.screenWidth * (60 / 393),
              //   width: GlobalUtils.screenWidth * 0.9,
              //   backgroundColor: Colors.white,
              //   borderColor: Color(0xffE2E5EC),
              //   borderRadius: 16,
              //   isMobileNumber: true,
              //   onSubmitted: (value) {
              //     if (value.isNotEmpty && !value.startsWith('+91')) {
              //       dmtController.currentSender.value?.mobile = value;
              //     }
              //   },
              //   placeholderStyle: GoogleFonts.albertSans(
              //     fontSize: GlobalUtils.screenWidth * (14 / 393),
              //     color: Color(0xFF6B707E),
              //   ),
              //   inputTextStyle: GoogleFonts.albertSans(
              //     fontSize: GlobalUtils.screenWidth * (14 / 393),
              //     color: Color(0xFF1B1C1C),
              //   ),
              //   prefixIcon: Icon(Icons.phone,
              //       color: Color(0xFF6B707E), size: 20),
              // ),
              // SizedBox(height: 8),
              //
              // // Info text
              // Row(
              //   children: [
              //     Icon(Icons.info_outline,
              //         size: 16, color: Color(0xFF6B707E)),
              //     SizedBox(width: 6),
              //     Expanded(
              //       child: Text(
              //         'Make sure all details are correct before adding',
              //         style: GoogleFonts.albertSans(
              //           fontSize: 12,
              //           color: Color(0xFF6B707E),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Add Beneficiary Button
        GlobalUtils.CustomButton(
          text: "Save",
          onPressed: () async {
            if (dmtController.selectedBank.value.isEmpty || dmtController.selectedBank.value == "Select Bank") {
              Fluttertoast.showToast(msg: "Please select bank");
              return;
            }

            if (dmtController.beneAccountController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "Account number required!");
              return;
            }
            if (!dmtController.isValidAccountNumber(dmtController.beneAccountController.value.text.trim())) {
              Fluttertoast.showToast(msg: "Please enter valid Account number! (9-18 digits)");
              return;
            }

            if (dmtController.beneIfscController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "IFSC code required!");
              return;
            }
            if (!dmtController.isValidIFSC(dmtController.beneIfscController.value.text.trim())) {
              Fluttertoast.showToast(msg: "Please enter valid IFSC! (e.g. SBIN0001234)");
              return;
            }
            // if (dmtController.beneAccountController.value.text.trim().isEmpty) {
            //   Fluttertoast.showToast(msg: "Please enter account number");
            //   return;
            // }
            //
            // if (dmtController.beneIfscController.value.text.trim().isEmpty) {
            //   Fluttertoast.showToast(msg: "Please enter IFSC code");
            //   return;
            // }

            if (dmtController.beneNameController.value.text.trim().isEmpty) {
              Fluttertoast.showToast(msg: "Please enter beneficiary name");
              return;
            }

            if (!dmtController.isAccountVerified.value) {
              Fluttertoast.showToast(msg: "Please verify account first");
              return;
            }

            // Add beneficiary
            await dmtController.addBeneficiary(context);
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
    RxList filteredBanks = RxList.from(dmtController.banksList);

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
                          filteredBanks.value = dmtController.banksList;
                        } else {
                          filteredBanks.value = dmtController.banksList
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
                          dmtController.selectedBank.value =
                              bank.bankName ?? "";
                          dmtController.selectedBankId.value =
                              bank.bankId ?? "";
                          dmtController.selectedIfsc.value =
                              bank.ifsc ?? "";

                          ConsoleLog.printColor("Selected Bank: ${bank.bankName}, IFSC: ${bank.ifsc}");

                          // Auto-fill IFSC if available
                          if (bank.ifsc != null && bank.ifsc!.isNotEmpty) {
                            dmtController.beneIfscController.value.text =
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