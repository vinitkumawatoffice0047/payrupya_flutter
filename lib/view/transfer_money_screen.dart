// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:payrupya/view/transaction_confirmation_screen.dart';
//
// import '../utils/global_utils.dart';
//
// class TransferMoneyScreen extends StatefulWidget {
//   final Map<String, dynamic> beneficiary;
//
//   const TransferMoneyScreen({super.key, required this.beneficiary});
//
//   @override
//   State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
// }
//
// class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
//   final TextEditingController _ifscController = TextEditingController();
//   final TextEditingController _accountNumberController = TextEditingController();
//   final TextEditingController _accountHolderController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _amountWordsController = TextEditingController();
//   final TextEditingController _taxPinController = TextEditingController();
//
//   String senderName = "Sohel Khan";
//   String senderMobile = "+91 9999887777";
//   bool isVerified = true;
//   bool isNEFT = true;
//   // bool showConfirmationDialog = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           Container(
//             height: GlobalUtils.getScreenHeight(),
//             width: GlobalUtils.getScreenWidth(),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: GlobalUtils.getBackgroundColor()
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   buildHeader(context),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: BouncingScrollPhysics(),
//                       padding: EdgeInsets.all(16),
//                       child: buildTransferForm(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
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
//   Widget buildTransferForm() {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.06),
//                   blurRadius: 15,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Transfer Money :',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xff1B1C1C),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 // Bank Name
//                 buildLabelText('Bank Name'),
//                 SizedBox(height: 8),
//                 buildBankRow(),
//                 SizedBox(height: 16),
//                 // IFSC
//                 Row(
//                   children: [
//                     buildLabelText('IFSC'),
//                     Text('*', style: GoogleFonts.albertSans(color: Colors.red),),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 GlobalUtils.CustomTextField(
//                   label: "IFSC Number",
//                   showLabel: false,
//                   controller: _ifscController,
//                   placeholder: "IFSC Number",
//                   placeholderColor: Colors.white,
//                   height: GlobalUtils.screenWidth * (60 / 393),
//                   width: GlobalUtils.screenWidth * 0.9,
//                   autoValidate: false,
//                   backgroundColor: Colors.white,
//                   borderColor: Color(0xffE2E5EC),
//                   borderRadius: 16,
//                   placeholderStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF6B707E),
//                   ),
//                   inputTextStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF1B1C1C),
//                   ),
//                   errorColor: Colors.red,
//                   errorFontSize: 12,
//                 ),
//                 // buildTextField(controller: _ifscController, hint: 'IFSC Number'),
//                 SizedBox(height: 16),
//                 // Account Number
//                 buildLabelText('Account Number'),
//                 SizedBox(height: 8),
//                 GlobalUtils.CustomTextField(
//                   label: "Account Number",
//                   showLabel: false,
//                   controller: _accountNumberController,
//                   placeholder: "Account Number",
//                   placeholderColor: Colors.white,
//                   keyboardType: TextInputType.number,
//                   // isNumber: true,
//                   height: GlobalUtils.screenWidth * (60 / 393),
//                   width: GlobalUtils.screenWidth * 0.9,
//                   autoValidate: false,
//                   backgroundColor: Colors.white,
//                   borderColor: Color(0xffE2E5EC),
//                   borderRadius: 16,
//                   placeholderStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF6B707E),
//                   ),
//                   inputTextStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF1B1C1C),
//                   ),
//                   errorColor: Colors.red,
//                   errorFontSize: 12,
//                   suffixIcon: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     margin: EdgeInsets.only(right: 8),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           '14',
//                           style: TextStyle(
//                             color: Color(0xFF0054D3),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // buildTextField(
//                 //   controller: _accountNumberController,
//                 //   hint: '98451264054222',
//                 //   keyboardType: TextInputType.number,
//                 //   suffixWidget: Container(
//                 //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 //     margin: EdgeInsets.only(right: 8),
//                 //     child: Row(
//                 //       mainAxisSize: MainAxisSize.min,
//                 //       children: [
//                 //         Text(
//                 //           '14',
//                 //           style: TextStyle(
//                 //             color: Color(0xFF0054D3),
//                 //             fontSize: 12,
//                 //             fontWeight: FontWeight.w500,
//                 //           ),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 // ),
//                 SizedBox(height: 16),
//                 // Account Holder Name
//                 buildLabelText('Account Holder Name'),
//                 SizedBox(height: 8),
//                 GlobalUtils.CustomTextField(
//                   label: "Account Holder Name",
//                   showLabel: false,
//                   controller: _accountHolderController,
//                   placeholder: "Account Holder Name",
//                   placeholderColor: Colors.white,
//                   height: GlobalUtils.screenWidth * (60 / 393),
//                   width: GlobalUtils.screenWidth * 0.9,
//                   autoValidate: false,
//                   backgroundColor: Colors.white,
//                   borderColor: Color(0xffE2E5EC),
//                   borderRadius: 16,
//                   placeholderStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF6B707E),
//                   ),
//                   inputTextStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF1B1C1C),
//                   ),
//                   errorColor: Colors.red,
//                   errorFontSize: 12,
//                   suffixIcon: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     margin: EdgeInsets.only(right: 8),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Get Name',
//                           style: TextStyle(
//                             color: Color(0xFF0054D3),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // buildTextField(
//                 //   controller: _accountHolderController,
//                 //   hint: 'Account Holder Name',
//                 //   suffixText: 'Get Name',
//                 // ),
//                 SizedBox(height: 16),
//                 // Amount
//                 buildLabelText('Amount'),
//                 SizedBox(height: 8),
//                 GlobalUtils.CustomTextField(
//                   label: "Amount",
//                   showLabel: false,
//                   controller: _amountController,
//                   placeholder: "Amount",
//                   placeholderColor: Colors.white,
//                   height: GlobalUtils.screenWidth * (60 / 393),
//                   width: GlobalUtils.screenWidth * 0.9,
//                   autoValidate: false,
//                   backgroundColor: Colors.white,
//                   borderColor: Color(0xffE2E5EC),
//                   borderRadius: 16,
//                   placeholderStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF6B707E),
//                   ),
//                   inputTextStyle: GoogleFonts.albertSans(
//                     fontSize: GlobalUtils.screenWidth * (14 / 393),
//                     color: Color(0xFF1B1C1C),
//                   ),
//                   errorColor: Colors.red,
//                   errorFontSize: 12,
//                   keyboardType: TextInputType.number
//                 ),
//                 SizedBox(height: 20),
//                 // Transfer Type
//                 Text(
//                   'Transfer Type',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 SizedBox(
//                   width: GlobalUtils.screenWidth * (200 / 393),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: buildTransferType('NEFT', isNEFT, () {
//                           setState(() => isNEFT = true);
//                         }),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: buildTransferType('IMPS', !isNEFT, () {
//                           setState(() => isNEFT = false);
//                         }),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 24),
//           // Transfer Button
//           GlobalUtils.CustomButton(
//             text: "Transfer",
//             onPressed: () {
//               Get.to(TransactionConfirmationScreen());
//             },
//             textStyle: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (16 / 393),
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//             ),
//             width: GlobalUtils.screenWidth * 0.9,
//             height: GlobalUtils.screenWidth * (60 / 393),
//             backgroundGradient: GlobalUtils.blueBtnGradientColor,
//             borderColor: Color(0xFF71A9FF),
//             showShadow: false,
//             textColor: Colors.white,
//             animation: ButtonAnimation.fade,
//             animationDuration: const Duration(milliseconds: 150),
//             buttonType: ButtonType.elevated,
//             borderRadius: 16,
//           ),
//           SizedBox(height: 16),
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
//   Widget buildTransferType(String text, bool isSelected, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           // color: isSelected ? Color(0xFF2E5BFF).withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: isSelected ? Color(0xFF0054D3) : Colors.grey[300]!,
//             width: 1,
//           ),
//           // OUTER BORDER (LIKE IMAGE)
//           boxShadow: isSelected ? [
//             BoxShadow(
//               color: Color(0xFF0054D3).withOpacity(0.15), // outer soft border
//               spreadRadius: 3,
//               blurRadius: 0,
//             ),
//           ] : null,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? Color(0xFF0054D3) : Colors.grey[400]!,
//                   width: 1,
//                 ),
//               ),
//               child: isSelected
//                   ? Center(
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: Color(0xFF0054D3),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               )
//                   : null,
//             ),
//             SizedBox(width: 8),
//             Text(
//               text,
//               style: GoogleFonts.albertSans(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildConfirmationDialog() {
//   //   return Container(
//   //     color: Colors.black54,
//   //     child: Center(
//   //       child: Container(
//   //         margin: EdgeInsets.symmetric(horizontal: 24),
//   //         padding: EdgeInsets.all(24),
//   //         decoration: BoxDecoration(
//   //           color: Colors.white,
//   //           borderRadius: BorderRadius.circular(20),
//   //         ),
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               'Transaction Confirmation :',
//   //               style: GoogleFonts.albertSans(
//   //                 fontSize: 18,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: Colors.black87,
//   //               ),
//   //             ),
//   //             SizedBox(height: 20),
//   //             _buildConfirmRow('Beneficiary Name', 'Sohel Khan'),
//   //             _buildConfirmRow('Account Number', '1111-1111-1111-111'),
//   //             _buildConfirmRow('Mode', 'IMPS'),
//   //             _buildConfirmRow('Amount', '₹6'),
//   //             _buildConfirmRow('Charged Amount', '₹6'),
//   //             _buildConfirmRow('Total Charged', '₹6'),
//   //             SizedBox(height: 24),
//   //             Text(
//   //               'Enter Taxation PIN',
//   //               style: GoogleFonts.albertSans(
//   //                 fontSize: 16,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: Colors.black87,
//   //               ),
//   //             ),
//   //             SizedBox(height: 12),
//   //             buildLabelText('TXN Pin *'),
//   //             SizedBox(height: 8),
//   //             buildTextField(
//   //               controller: _taxPinController,
//   //               hint: 'Enter Taxation PIN',
//   //               keyboardType: TextInputType.number,
//   //             ),
//   //             SizedBox(height: 24),
//   //             Row(
//   //               children: [
//   //                 Expanded(
//   //                   child: GestureDetector(
//   //                     onTap: () {
//   //                       setState(() => showConfirmationDialog = false);
//   //                     },
//   //                     child: Container(
//   //                       padding: EdgeInsets.symmetric(vertical: 14),
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.grey[200],
//   //                         borderRadius: BorderRadius.circular(10),
//   //                       ),
//   //                       child: Center(
//   //                         child: Text(
//   //                           'Cancel',
//   //                           style: TextStyle(
//   //                             fontSize: 15,
//   //                             fontWeight: FontWeight.w600,
//   //                             color: Colors.black87,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 SizedBox(width: 12),
//   //                 Expanded(
//   //                   child: GestureDetector(
//   //                     onTap: () {
//   //                       setState(() => showConfirmationDialog = false);
//   //                     },
//   //                     child: Container(
//   //                       padding: EdgeInsets.symmetric(vertical: 14),
//   //                       decoration: BoxDecoration(
//   //                         color: Color(0xFF2E5BFF),
//   //                         borderRadius: BorderRadius.circular(10),
//   //                       ),
//   //                       child: Center(
//   //                         child: Text(
//   //                           'Process',
//   //                           style: TextStyle(
//   //                             fontSize: 15,
//   //                             fontWeight: FontWeight.w600,
//   //                             color: Colors.white,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildConfirmRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               color: Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
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
//   Widget buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType? keyboardType,
//     String? suffixText,
//     Widget? suffixWidget,
//     bool enabled = true,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         // color: enabled ? Color(0xFFF8FAFC) : Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         enabled: enabled,
//         style: GoogleFonts.albertSans(
//           fontSize: 14,
//           color: Color(0xff1B1C1C),
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: GoogleFonts.albertSans(color: Colors.grey[400], fontSize: 14),
//           border: InputBorder.none,
//           // suffixStyle: GoogleFonts.albertSans(
//           //   fontSize: 12,
//           //   color: Color(0xff0054D3),
//           //   fontWeight: FontWeight.w500,
//           // ),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           suffixIcon: suffixWidget ??
//               (suffixText != null
//                   ? Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 margin: EdgeInsets.only(right: 8),
//                 child: Center(
//                   widthFactor: 1,
//                   child: Text(
//                     suffixText,
//                     style: TextStyle(
//                       color: Color(0xFF0054D3),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
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
//     _ifscController.dispose();
//     _accountNumberController.dispose();
//     _accountHolderController.dispose();
//     _amountController.dispose();
//     _amountWordsController.dispose();
//     _taxPinController.dispose();
//     super.dispose();
//   }
// }




// lib/view/transfer_money_screen.dart
// Complete implementation with API integration

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/view/transaction_confirmation_screen.dart';
import '../controllers/dmt_wallet_controller.dart';
// import '../models/dmt_api_response_models.dart';
import '../models/get_beneficiary_list_response_model.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';

class TransferMoneyScreen extends StatefulWidget {
  final BeneficiaryData beneficiary;

  const TransferMoneyScreen({
    super.key,
    required this.beneficiary,
  });

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final DmtWalletController dmtController = Get.put(DmtWalletController());

  // bool showTPINField = false;
  String selectedTransferMode = "IMPS";
  // ValueNotifiers for amount in words for skip keyboard hide problem
  final ValueNotifier<String> amountInWords = ValueNotifier<String>("");
  final ValueNotifier<String> confirmAmountInWords = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    // Clear previous values
    dmtController.transferAmountController.value.clear();
    dmtController.transferConfirmAmountController.value.clear();
    // dmtController.tpinController.value.clear();

    // Add listeners for amount fields
    dmtController.transferAmountController.value.addListener(() {
      amountInWords.value = convertToWords(
          dmtController.transferAmountController.value.text.trim()
      );
    });

    dmtController.transferConfirmAmountController.value.addListener(() {
      confirmAmountInWords.value = convertToWords(
          dmtController.transferConfirmAmountController.value.text.trim()
      );
    });
  }

  // Convert number to words
  String convertToWords(String amount) {
    if (amount.isEmpty) return "";

    double? value = double.tryParse(amount);
    if (value == null || value <= 0) return "";

    int rupees = value.floor();
    int paise = ((value - rupees) * 100).round();

    String result = numberToWords(rupees).toUpperCase() + " RUPEES";

    if (paise > 0) {
      result += " AND " + numberToWords(paise).toUpperCase() + " PAISE";
    }

    result += " ONLY";

    return result;
  }

  String numberToWords(int number) {
    if (number == 0) return "zero";

    final ones = [
      "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
      "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
      "seventeen", "eighteen", "nineteen"
    ];

    final tens = [
      "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"
    ];

    if (number < 20) {
      return ones[number];
    }

    if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? " " + ones[number % 10] : "");
    }

    if (number < 1000) {
      return ones[number ~/ 100] + " hundred" +
          (number % 100 != 0 ? " " + numberToWords(number % 100) : "");
    }

    if (number < 100000) {
      return numberToWords(number ~/ 1000) + " thousand" +
          (number % 1000 != 0 ? " " + numberToWords(number % 1000) : "");
    }

    if (number < 10000000) {
      return numberToWords(number ~/ 100000) + " lakh" +
          (number % 100000 != 0 ? " " + numberToWords(number % 100000) : "");
    }

    return numberToWords(number ~/ 10000000) + " crore" +
        (number % 10000000 != 0 ? " " + numberToWords(number % 10000000) : "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            buildCustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    buildBeneficiaryCard(),
                    SizedBox(height: 16),
                    buildTransferForm(),
                    SizedBox(height: 24),
                    buildTransferButton(context),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
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
            "Transfer Money",
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

  Widget buildBeneficiaryCard() {
    return Container(
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: /*widget.beneficiary.logo != null &&
                    widget.beneficiary.logo!.isNotEmpty
                    ?*/ ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.account_balance,
                    color: Color(0xFF4A90E2),
                    size: 28,
                  ),/*Image.network(
                    widget.beneficiary.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Icon(
                        Icons.account_balance,
                        color: Color(0xFF4A90E2),
                        size: 28,
                      );
                    },
                  ),*/
                )
                    /*: Icon(
                  Icons.account_balance,
                  color: Color(0xFF4A90E2),
                  size: 28,
                ),*/
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.beneficiary.name ?? "Unknown",
                            style: GoogleFonts.albertSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1B1C1C),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        if (widget.beneficiary.isVerified == true)
                          Icon(Icons.verified,
                              color: Color(0xff009C46), size: 18),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.beneficiary.bankName ?? "Unknown Bank",
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        color: Color(0xff6B707E),
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E5EC)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account Number',
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: Color(0xff6B707E),
                      ),
                    ),
                    Text(
                      widget.beneficiary.accountNo ?? "N/A",
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'IFSC Code',
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: Color(0xff6B707E),
                      ),
                    ),
                    Text(
                      widget.beneficiary.ifsc ?? "N/A",
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransferForm() {
    return Obx(() => Container(
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
            'Transfer Details',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff1B1C1C),
            ),
          ),
          SizedBox(height: 20),

          // // Available Balance Info
          // Obx(() {
          //   var sender = dmtController.currentSender.value;
          //   if (sender != null) {
          //     double availableLimit =
          //         double.tryParse(sender.availableLimit ?? "0") ?? 0;
          //     return Container(
          //       padding: EdgeInsets.all(12),
          //       decoration: BoxDecoration(
          //         color: Color(0xFFE3F2FD),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(Icons.account_balance_wallet,
          //               color: Color(0xFF1976D2), size: 20),
          //           SizedBox(width: 8),
          //           Text(
          //             'Available Limit: ',
          //             style: GoogleFonts.albertSans(
          //               fontSize: 13,
          //               color: Color(0xFF1565C0),
          //             ),
          //           ),
          //           Text(
          //             '₹${availableLimit.toStringAsFixed(2)}',
          //             style: GoogleFonts.albertSans(
          //               fontSize: 15,
          //               fontWeight: FontWeight.w600,
          //               color: Color(0xFF0D47A1),
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }
          //   return SizedBox.shrink();
          // }),
          // SizedBox(height: 16),

          // Transfer Mode Selection
          buildLabelText('Transfer Type'),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                // child: buildTransferModeOption("IMPS", "Instant"),
                child: buildTransferModeOption("IMPS", ""),
              ),
              SizedBox(width: 12),
              Expanded(
                // child: buildTransferModeOption("NEFT", "Within 2 hrs"),
                child: buildTransferModeOption("NEFT", ""),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Amount Field
          buildLabelText('Enter Amount'),
          SizedBox(height: 8),
          GlobalUtils.CustomTextField(
            label: "Amount",
            showLabel: false,
            controller: dmtController.transferAmountController.value,
            placeholder: "Amount",
            height: GlobalUtils.screenWidth * (60 / 393),
            width: GlobalUtils.screenWidth * 0.9,
            backgroundColor: Colors.white,
            borderColor: Color(0xffE2E5EC),
            borderRadius: 16,
            keyboardType: TextInputType.number,
            placeholderStyle: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (14 / 393),
              color: Color(0xFF6B707E),
            ),
            inputTextStyle: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (14 / 393),
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
            maxLength: 9,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16, top: GlobalUtils.screenWidth * (9 / 393)),
              child: Text(
                '₹',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1C1C),
                ),
              ),
            ),
          ),

          // Amount in words - Using ValueListenableBuilder
          ValueListenableBuilder<String>(
            valueListenable: amountInWords,
            builder: (context, value, child) {
              if (value.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  value,
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    color: Color(0xFF0054D3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Confirm Amount Field
          buildLabelText('Enter Confirm Amount'),
          SizedBox(height: 8),
          GlobalUtils.CustomTextField(
            label: "Confirm Amount",
            showLabel: false,
            controller: dmtController.transferConfirmAmountController.value,
            placeholder: "Confirm Amount",
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
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16, top: GlobalUtils.screenWidth * (9 / 393)),
              child: Text(
                '₹',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1C1C),
                ),
              ),
            ),
          ),

          // Confirm Amount in words - Using ValueListenableBuilder
          ValueListenableBuilder<String>(
            valueListenable: confirmAmountInWords,
            builder: (context, value, child) {
              if (value.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  value,
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    color: Color(0xFF0054D3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),

          // SizedBox(height: 8),
          //
          // // Quick amount buttons
          // Row(
          //   children: [
          //     buildQuickAmountButton("500"),
          //     SizedBox(width: 8),
          //     buildQuickAmountButton("1000"),
          //     SizedBox(width: 8),
          //     buildQuickAmountButton("2000"),
          //     SizedBox(width: 8),
          //     buildQuickAmountButton("5000"),
          //   ],
          // ),
          // SizedBox(height: 16),

          // // Show TPIN field after amount is entered
          // if (showTPINField) ...[
          //   buildLabelText('Enter TPIN *'),
          //   SizedBox(height: 8),
          //   GlobalUtils.CustomTextField(
          //     label: "TPIN",
          //     showLabel: false,
          //     controller: dmtController.tpinController.value,
          //     placeholder: "Enter 4-digit TPIN",
          //     height: GlobalUtils.screenWidth * (60 / 393),
          //     width: GlobalUtils.screenWidth * 0.9,
          //     backgroundColor: Colors.white,
          //     borderColor: Color(0xffE2E5EC),
          //     borderRadius: 16,
          //     keyboardType: TextInputType.number,
          //     isObscure: true,
          //     maxLength: 4,
          //     placeholderStyle: GoogleFonts.albertSans(
          //       fontSize: GlobalUtils.screenWidth * (14 / 393),
          //       color: Color(0xFF6B707E),
          //     ),
          //     inputTextStyle: GoogleFonts.albertSans(
          //       fontSize: GlobalUtils.screenWidth * (18 / 393),
          //       fontWeight: FontWeight.w600,
          //       color: Color(0xFF1B1C1C),
          //       letterSpacing: 8,
          //     ),
          //     prefixIcon: Icon(Icons.lock,
          //         color: Color(0xFF6B707E), size: 20),
          //   ),
          //   SizedBox(height: 8),
          //   Row(
          //     children: [
          //       Icon(Icons.info_outline,
          //           size: 14, color: Color(0xFF6B707E)),
          //       SizedBox(width: 4),
          //       Text(
          //         'Enter your transaction PIN for verification',
          //         style: GoogleFonts.albertSans(
          //           fontSize: 11,
          //           color: Color(0xFF6B707E),
          //         ),
          //       ),
          //     ],
          //   ),
          // ],

          // Charges info
          SizedBox(height: 16),
          // Container(
          //   padding: EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: Color(0xFFFFF3E0),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(Icons.info_outline,
          //           color: Color(0xFFF57C00), size: 18),
          //       SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           'Transfer charges may apply as per bank norms',
          //           style: GoogleFonts.albertSans(
          //             fontSize: 12,
          //             color: Color(0xFFE65100),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
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

  Widget buildTransferModeOption(String mode, String description) {
    bool isSelected = selectedTransferMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTransferMode = mode;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF2196F3) : Color(0xFFE2E5EC),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF2196F3)
                          : Color(0xFFBDBDBD),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 8),
                Text(
                  mode,
                  style: GoogleFonts.albertSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Color(0xFF1976D2)
                        : Color(0xFF1B1C1C),
                  ),
                ),
              ],
            ),
            // SizedBox(height: 4),
            // Text(
            //   description,
            //   style: GoogleFonts.albertSans(
            //     fontSize: 11,
            //     color: Color(0xFF6B707E),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickAmountButton(String amount, String confirmAmount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          dmtController.transferAmountController.value.text = amount;
          dmtController.transferConfirmAmountController.value.text = confirmAmount;
          // setState(() {
          //   showTPINField = true;
          // });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              '₹$amount',
              style: GoogleFonts.albertSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTransferButton(BuildContext transferMoneyContext) {
    return GlobalUtils.CustomButton(
      // text: showTPINField ? "Confirm Transfer" : "Proceed",
      text: "Transfer",
      onPressed: () async {
        String amount = dmtController.transferAmountController.value.text.trim();
        String confirmAmount = dmtController.transferConfirmAmountController.value.text.trim();

        if (amount.isEmpty) {
          Fluttertoast.showToast(msg: "Please enter amount");
          return;
        }

        if (confirmAmount.isEmpty) {
          Fluttertoast.showToast(msg: "Please enter confirm amount");
          return;
        }

        if (amount != confirmAmount) {
          Fluttertoast.showToast(msg: "Confirm amount doesn't match");
          return;
        }

        double amountValue = double.tryParse(amount) ?? 0;
        if (amountValue <= 0) {
          Fluttertoast.showToast(msg: "Please enter valid amount");
          return;
        }

        double confirmAmountValue = double.tryParse(confirmAmount) ?? 0;
        if (confirmAmountValue <= 0) {
          Fluttertoast.showToast(msg: "Please enter valid confirm amount");
          return;
        }

        // if (!showTPINField) {
        //   // Show TPIN field
        //   setState(() {
        //     showTPINField = true;
        //   });
        //   return;
        // }

        // String tpin = dmtController.tpinController.value.text.trim();
        // if (tpin.isEmpty || tpin.length != 4) {
        //   Fluttertoast.showToast(msg: "Please enter 4-digit TPIN");
        //   return;
        // }

        // ✅ Call API and wait
        print("🔍 Calling confirmTransfer...");
        await dmtController.confirmTransfer(context, widget.beneficiary);
        print("🔍 Back from confirmTransfer");

        // ✅ Check if data is available
        print("🔍 confirmationData: ${dmtController.confirmationData.value}");

        if (dmtController.confirmationData.value != null) {
          print("✅ Data available, navigating...");

          // ✅ Navigate here
          final result = await Get.to(() => TransactionConfirmationScreen());

          print("✅ Back from confirmation screen");

          // Clean up when back
          dmtController.confirmationData.value = null;
          dmtController.showConfirmation.value = false;
        } else {
          print("❌ No confirmation data");
        }
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
    );
  }

  void showConfirmationDialog(double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Transfer',
            style: GoogleFonts.albertSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to transfer:',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Color(0xFF6B707E),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: GoogleFonts.albertSans(fontSize: 13),
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0054D3),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To:',
                          style: GoogleFonts.albertSans(fontSize: 13),
                        ),
                        Text(
                          widget.beneficiary.name ?? "Unknown",
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mode:',
                          style: GoogleFonts.albertSans(fontSize: 13),
                        ),
                        Text(
                          selectedTransferMode,
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.albertSans(
                  color: Color(0xFF6B707E),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Transfer money
                // await dmtController.transferMoney(context, widget.beneficiary);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0054D3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.albertSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}