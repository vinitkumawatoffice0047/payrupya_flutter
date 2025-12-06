import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/view/transaction_confirmation_screen.dart';

import '../utils/global_utils.dart';

class TransferMoneyScreen extends StatefulWidget {
  final Map<String, dynamic> beneficiary;

  const TransferMoneyScreen({super.key, required this.beneficiary});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountWordsController = TextEditingController();
  final TextEditingController _taxPinController = TextEditingController();

  String senderName = "Sohel Khan";
  String senderMobile = "+91 9999887777";
  bool isVerified = true;
  bool isNEFT = true;
  // bool showConfirmationDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
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
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      child: buildTransferForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget buildTransferForm() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
                  'Transfer Money :',
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1B1C1C),
                  ),
                ),
                SizedBox(height: 20),
                // Bank Name
                buildLabelText('Bank Name'),
                SizedBox(height: 8),
                buildBankRow(),
                SizedBox(height: 16),
                // IFSC
                Row(
                  children: [
                    buildLabelText('IFSC'),
                    Text('*', style: GoogleFonts.albertSans(color: Colors.red),),
                  ],
                ),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "IFSC Number",
                  showLabel: false,
                  controller: _ifscController,
                  placeholder: "IFSC Number",
                  placeholderColor: Colors.white,
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  autoValidate: false,
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
                  errorColor: Colors.red,
                  errorFontSize: 12,
                ),
                // buildTextField(controller: _ifscController, hint: 'IFSC Number'),
                SizedBox(height: 16),
                // Account Number
                buildLabelText('Account Number'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Account Number",
                  showLabel: false,
                  controller: _accountNumberController,
                  placeholder: "Account Number",
                  placeholderColor: Colors.white,
                  keyboardType: TextInputType.number,
                  // isNumber: true,
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  autoValidate: false,
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
                  errorColor: Colors.red,
                  errorFontSize: 12,
                  suffixIcon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '14',
                          style: TextStyle(
                            color: Color(0xFF0054D3),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // buildTextField(
                //   controller: _accountNumberController,
                //   hint: '98451264054222',
                //   keyboardType: TextInputType.number,
                //   suffixWidget: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     margin: EdgeInsets.only(right: 8),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           '14',
                //           style: TextStyle(
                //             color: Color(0xFF0054D3),
                //             fontSize: 12,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 16),
                // Account Holder Name
                buildLabelText('Account Holder Name'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Account Holder Name",
                  showLabel: false,
                  controller: _accountHolderController,
                  placeholder: "Account Holder Name",
                  placeholderColor: Colors.white,
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  autoValidate: false,
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
                  errorColor: Colors.red,
                  errorFontSize: 12,
                  suffixIcon: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Name',
                          style: TextStyle(
                            color: Color(0xFF0054D3),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // buildTextField(
                //   controller: _accountHolderController,
                //   hint: 'Account Holder Name',
                //   suffixText: 'Get Name',
                // ),
                SizedBox(height: 16),
                // Amount
                buildLabelText('Amount'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Amount",
                  showLabel: false,
                  controller: _amountController,
                  placeholder: "Amount",
                  placeholderColor: Colors.white,
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: GlobalUtils.screenWidth * 0.9,
                  autoValidate: false,
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
                  errorColor: Colors.red,
                  errorFontSize: 12,
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 20),
                // Transfer Type
                Text(
                  'Transfer Type',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: GlobalUtils.screenWidth * (200 / 393),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildTransferType('NEFT', isNEFT, () {
                          setState(() => isNEFT = true);
                        }),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: buildTransferType('IMPS', !isNEFT, () {
                          setState(() => isNEFT = false);
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Transfer Button
          GlobalUtils.CustomButton(
            text: "Transfer",
            onPressed: () {
              Get.to(TransactionConfirmationScreen());
            },
            textStyle: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (16 / 393),
              color: Colors.white,
              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget buildBankRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/sbi_logo.png", width: 36),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'State Bank of India',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                color: Color(0xff1B1C1C),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget buildTransferType(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          // color: isSelected ? Color(0xFF2E5BFF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Color(0xFF0054D3) : Colors.grey[300]!,
            width: 1,
          ),
          // OUTER BORDER (LIKE IMAGE)
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF0054D3).withOpacity(0.15), // outer soft border
              spreadRadius: 3,
              blurRadius: 0,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF0054D3) : Colors.grey[400]!,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF0054D3),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
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

  // Widget _buildConfirmationDialog() {
  //   return Container(
  //     color: Colors.black54,
  //     child: Center(
  //       child: Container(
  //         margin: EdgeInsets.symmetric(horizontal: 24),
  //         padding: EdgeInsets.all(24),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Transaction Confirmation :',
  //               style: GoogleFonts.albertSans(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             _buildConfirmRow('Beneficiary Name', 'Sohel Khan'),
  //             _buildConfirmRow('Account Number', '1111-1111-1111-111'),
  //             _buildConfirmRow('Mode', 'IMPS'),
  //             _buildConfirmRow('Amount', '₹6'),
  //             _buildConfirmRow('Charged Amount', '₹6'),
  //             _buildConfirmRow('Total Charged', '₹6'),
  //             SizedBox(height: 24),
  //             Text(
  //               'Enter Taxation PIN',
  //               style: GoogleFonts.albertSans(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             SizedBox(height: 12),
  //             buildLabelText('TXN Pin *'),
  //             SizedBox(height: 8),
  //             buildTextField(
  //               controller: _taxPinController,
  //               hint: 'Enter Taxation PIN',
  //               keyboardType: TextInputType.number,
  //             ),
  //             SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       setState(() => showConfirmationDialog = false);
  //                     },
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(vertical: 14),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[200],
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           'Cancel',
  //                           style: TextStyle(
  //                             fontSize: 15,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.black87,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 12),
  //                 Expanded(
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       setState(() => showConfirmationDialog = false);
  //                     },
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(vertical: 14),
  //                       decoration: BoxDecoration(
  //                         color: Color(0xFF2E5BFF),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           'Process',
  //                           style: TextStyle(
  //                             fontSize: 15,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? suffixText,
    Widget? suffixWidget,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        // color: enabled ? Color(0xFFF8FAFC) : Colors.grey[100],
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
          // suffixStyle: GoogleFonts.albertSans(
          //   fontSize: 12,
          //   color: Color(0xff0054D3),
          //   fontWeight: FontWeight.w500,
          // ),
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

  @override
  void dispose() {
    _ifscController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    _amountWordsController.dispose();
    _taxPinController.dispose();
    super.dispose();
  }
}