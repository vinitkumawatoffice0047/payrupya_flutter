// // // ============================================
// // // WALLET SCREEN
// // // ============================================
// // import 'package:flutter/material.dart';
// //
// // class WalletScreen extends StatelessWidget {
// //   const WalletScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Wallet'),
// //         backgroundColor: Color(0xFF4A90E2),
// //         elevation: 0,
// //       ),
// //       body: Center(
// //         child: Text(
// //           'Wallet Screen',
// //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:payrupya/utils/global_utils.dart';
// import 'add_sender_screen.dart';
// import 'add_beneficiary_screen.dart';
// import 'transfer_money_screen.dart';
//
// class WalletScreen extends StatefulWidget {
//   final bool showBackButton;
//   const WalletScreen({super.key, this.showBackButton = true});
//
//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }
//
// class _WalletScreenState extends State<WalletScreen> {
//   final TextEditingController searchController = TextEditingController();
//
//   String senderName = "Sohel Khan";
//   String senderMobile = "+91 9636938763";
//   double consumedLimit = 25000;
//   double monthlyLimit = 80000;
//   bool isVerified = true;
//
//   List<Map<String, dynamic>> beneficiaries = [
//     {
//       'bankName': 'State Bank of India',
//       'holderName': 'Sohel Khan',
//       'isVerified': true,
//       'logo': 'assets/images/sbi_logo.png',
//     },
//     {
//       'bankName': 'State Bank of India',
//       'holderName': 'Sohel Khan',
//       'isVerified': true,
//       'logo': 'assets/images/sbi_logo.png',
//     },
//     {
//       'bankName': 'State Bank of India',
//       'holderName': 'Sohel Khan',
//       'isVerified': true,
//       'logo': 'assets/images/sbi_logo.png',
//     },
//     {
//       'bankName': 'State Bank of India',
//       'holderName': 'Sohel Khan',
//       'isVerified': true,
//       'logo': 'assets/images/sbi_logo.png',
//     },
//     {
//       'bankName': 'State Bank of India',
//       'holderName': 'Sohel Khan',
//       'isVerified': true,
//       'logo': 'assets/images/sbi_logo.png',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = GlobalUtils.screenWidth;
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
//               if(!widget.showBackButton)...[
//                 SizedBox(height: GlobalUtils.screenHeight * (12 / 393)),
//               ],
//               buildCustomAppBar(),
//               // buildHeader(context),
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: BouncingScrollPhysics(),
//                   child: Column(
//                     children: [
//                       // SizedBox(height: 16),
//                       buildSenderCard(screenWidth),
//                       SizedBox(height: 20),
//                       buildBeneficiarySection(screenWidth),
//                       SizedBox(height: 16),
//                       // Add Beneficiary Button
//                       GlobalUtils.CustomButton(
//                         text: "Add Beneficiary",
//                         onPressed: () {
//                           Get.to(AddBeneficiaryScreen());
//                         },
//                         textStyle: GoogleFonts.albertSans(
//                           fontSize: GlobalUtils.screenWidth * (16 / 393),
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         icon: Icon(Icons.add, color: Colors.white, size: 20),
//                         width: GlobalUtils.screenWidth * 0.9,
//                         height: GlobalUtils.screenWidth * (60 / 393),
//                         backgroundGradient: GlobalUtils.blueBtnGradientColor,
//                         borderColor: Color(0xFF71A9FF),
//                         showShadow: false,
//                         textColor: Colors.white,
//                         animation: ButtonAnimation.fade,
//                         animationDuration: const Duration(milliseconds: 150),
//                         buttonType: ButtonType.elevated,
//                         borderRadius: 16,
//                       ),
//                       SizedBox(height: 16)
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildCustomAppBar() {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: GlobalUtils.screenWidth * 0.04,
//         right: GlobalUtils.screenWidth * 0.04,
//         bottom: 16
//       ),
//       child: Row(
//         children: [
//           if(widget.showBackButton)...[
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
//
//           SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
//           ],
//           /// TITLE
//           Text(
//             "Payrupya Wallet",
//             style: GoogleFonts.albertSans(
//               fontSize: GlobalUtils.screenWidth * (20 / 393),
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff1B1C1C),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildHeaderIcon(IconData icon) {
//     return Container(
//       padding: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Color(0xFFF0F4F8),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Icon(icon, size: 22, color: Colors.black87),
//     );
//   }
//
//   Widget buildSenderCard(double screenWidth) {
//     double progressPercentage = (consumedLimit / monthlyLimit);
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10),
//       padding: EdgeInsets.all(13),
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
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     senderName,
//                     style: GoogleFonts.albertSans(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xff1B1C1C),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   if (isVerified)
//                     Icon(Icons.verified, color: Color(0xff009C46), size: 20),
//                 ],
//               ),
//               Column(
//                 children: [
//                   SizedBox(
//                     height: 8,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => AddSenderScreen()),
//                       );
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Image.asset("assets/icons/edit_icon.png", width: 16, height: 16),
//                           SizedBox(width: 4),
//                           Text(
//                             'Change Sender',
//                             style: GoogleFonts.albertSans(
//                               fontSize: 14,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 2),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               senderMobile,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xff1B1C1C),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           // Progress Bar
//           Stack(
//             children: [
//               ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset("assets/images/empty_slider.png", height: 16, fit: BoxFit.fitHeight)
//               ),
//               FractionallySizedBox(
//                 widthFactor: progressPercentage,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset(
//                     "assets/images/filled_slider.png",
//                     height: 16,
//                     fit: BoxFit.fitHeight,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: Color(0xFF4A90E2),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Consumed Unit',
//                         style: GoogleFonts.albertSans(
//                           fontSize: 12,
//                           color: Color(0xff707070),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // SizedBox(height: 4),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Text(
//                       '${consumedLimit.toStringAsFixed(0)}/-',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xff1B1C1C),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFE2E5EC),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Monthly Limit',
//                         style: GoogleFonts.albertSans(
//                           fontSize: 12,
//                           color: Color(0xff707070),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // SizedBox(height: 4),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Text(
//                       '${monthlyLimit.toStringAsFixed(0)}/-',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xff1B1C1C),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBeneficiarySection(double screenWidth) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10),
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
//         children: [
//           Container(
//             padding: EdgeInsets.only(top: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'My Beneficiary :',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xff1B1C1C),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     // color: Color(0xFFF0F4F8),
//                     borderRadius: BorderRadius.circular(100),
//                     border: Border.all(color: Colors.grey[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       // Icon(Icons.sort, size: 16, color: Colors.grey[700]),
//                       Image.asset("assets/icons/sort_icon.png", height: 16, width: 16),
//                       SizedBox(width: 4),
//                       Text(
//                         'Sort',
//                         style: GoogleFonts.albertSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: Color(0xff1B1C1C),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),
//           // Search Bar
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search Bank or Account or Name',
//                 hintStyle: GoogleFonts.albertSans(
//                   fontSize: 14,
//                   color: Color(0xff6B707E),
//                   fontWeight: FontWeight.w400,
//                 ),
//                 // prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
//                 prefixIcon: Image.asset("assets/icons/search_icon.png", scale: 3,),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           // Beneficiary List
//           ListView.separated(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: beneficiaries.length,
//             itemBuilder: (context, index) {
//               return buildBeneficiaryCard(beneficiaries[index], screenWidth);
//             },
//             separatorBuilder: (context, index) {
//               return Container(
//                 height: 1,
//                 color: Colors.grey.shade300,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBeneficiaryCard(Map<String, dynamic> beneficiary, double screenWidth) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           // Bank Logo
//           Container(
//             child: Image.asset(
//               beneficiary['logo'],
//               width: 36,
//               height: 36,
//               errorBuilder: (context, error, stackTrace) {
//                 return Icon(Icons.account_balance, size: 28, color: Color(0xFF4A90E2));
//               },
//             ),
//           ),
//           SizedBox(width: 12),
//           // Bank Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Flexible(
//                       child: Text(
//                         beneficiary['bankName'],
//                         style: GoogleFonts.albertSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: Color(0xff1B1C1C),
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     SizedBox(width: 3),
//                     if (beneficiary['isVerified'])
//                       Icon(Icons.verified, color: Color(0xff009C46), size: 16),
//                   ],
//                 ),
//                 // SizedBox(height: 4),
//                 Text(
//                   beneficiary['holderName'],
//                   style: GoogleFonts.albertSans(
//                     fontSize: 12,
//                     color: Color(0xff6B707E),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           // More Options
//           // SizedBox(
//           //   width: 40,
//           //   child: PopupMenuButton(
//           //     icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
//           //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
//           //     color: Colors.white,
//           //     itemBuilder: (context) => [
//           //       PopupMenuItem(
//           //         value: 'edit',
//           //         child: Text('Edit', style: GoogleFonts.albertSans(
//           //           fontSize: 14,
//           //           fontWeight: FontWeight.w400,
//           //           color: Color(0xff1B1C1C),
//           //         ),),
//           //       ),
//           //       PopupMenuItem(
//           //         value: 'delete',
//           //         child: Text('Delete', style: GoogleFonts.albertSans(
//           //           fontSize: 14,
//           //           fontWeight: FontWeight.w400,
//           //           color: Colors.red,
//           //         ),),
//           //       ),
//           //     ],
//           //     onSelected: (value) {
//           //       if (value == 'delete') {
//           //         showDeleteDialog(context);
//           //       }
//           //     },
//           //   ),
//           // ),
//           IconButton(onPressed: (){
//             showDeleteDialog(context);
//           }, icon: Icon(Icons.delete, color: Colors.red,)),
//           // Transfer Button
//           SizedBox(
//             width: 76,
//             height: 36,
//             child: ElevatedButton(
//               onPressed: (){
//                 Get.to(TransferMoneyScreen(beneficiary: beneficiary));
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0054D3)),
//                 padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
//               ),
//               child: Text("Transfer",
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//             ),softWrap: false,
//             ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   void showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Align(
//           alignment: Alignment.center,
//           child: SizedBox(
//             width: MediaQuery.of(context).size.width * 0.90, // 90% SCREEN WIDTH
//             child: Material(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset("assets/icons/delete_icon.png", width: 60,),
//                     SizedBox(height: 20),
//                     Text(
//                       'Delete Beneficiary',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xff0F0F0F),
//                       ),
//                     ),
//
//                     SizedBox(height: 12),
//
//                     Text(
//                       'Are you sure you want to delete this beneficiary?\nYou can always return and re-add them whenever you\'re ready.',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.albertSans(
//                         fontSize: 12,
//                         color: Color(0xff171F2D),
//                         fontWeight: FontWeight.w400,
//                         // height: 1.5,
//                       ),
//                     ),
//
//                     SizedBox(height: 24),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => Get.back(),
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(vertical: 14),
//                                 decoration: BoxDecoration(
//                                   // color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(15),
//                                   border: Border.all(color: Colors.grey[200]!),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.albertSans(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xff1B1C1C),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(vertical: 14),
//                                 decoration: BoxDecoration(
//                                   // color: Color(0xFF2E5BFF),
//                                   gradient: GlobalUtils.blueBtnGradientColor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'Yes, Delete',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dmt_wallet_controller.dart';
import '../utils/global_utils.dart';
import 'add_sender_screen.dart';
import 'add_beneficiary_screen.dart';
import 'transfer_money_screen.dart';

class WalletScreen extends StatefulWidget {
  final bool showBackButton;
  const WalletScreen({super.key, this.showBackButton = true});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final DmtWalletController dmtController = Get.put(DmtWalletController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch beneficiary list if sender is verified
    if (dmtController.currentSender.value != null) {
      dmtController.getBeneficiaryList(
        context,
        dmtController.currentSender.value!.mobile ?? "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (!widget.showBackButton) ...[
                SizedBox(height: GlobalUtils.screenHeight * (12 / 393)),
              ],
              buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Obx(() => Column(
                    children: [
                      buildSenderCard(GlobalUtils.screenWidth),
                      SizedBox(height: 20),
                      buildBeneficiarySection(GlobalUtils.screenWidth),
                      SizedBox(height: 16),

                      // Add Beneficiary Button
                      GlobalUtils.CustomButton(
                        text: "Add Beneficiary",
                        onPressed: () {
                          Get.to(() => AddBeneficiaryScreen());
                        },
                        textStyle: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (16 / 393),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        icon: Icon(Icons.add, color: Colors.white, size: 20),
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
                  )),
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
          bottom: 16
      ),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
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
            SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          ],
          Text(
            "Payrupya Wallet",
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

  Widget buildSenderCard(double screenWidth) {
    var sender = dmtController.currentSender.value;

    if (sender == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No sender selected',
            style: GoogleFonts.albertSans(fontSize: 16),
          ),
        ),
      );
    }

    double consumedLimit = double.tryParse(sender.consumedLimit ?? "0") ?? 0;
    double monthlyLimit = double.tryParse(sender.monthlyLimit ?? "80000") ?? 80000;
    double progressPercentage = monthlyLimit > 0 ? (consumedLimit / monthlyLimit) : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(13),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    sender.name ?? "Unknown",
                    style: GoogleFonts.albertSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                  SizedBox(width: 8),
                  if (sender.isVerified == true)
                    Icon(Icons.verified, color: Color(0xff009C46), size: 20),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => AddSenderScreen());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/icons/edit_icon.png", width: 16, height: 16),
                      SizedBox(width: 4),
                      Text(
                        'Change Sender',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+91 ${sender.mobile}',
              style: TextStyle(fontSize: 14, color: Color(0xff1B1C1C)),
            ),
          ),
          SizedBox(height: 20),

          // Progress Bar
          Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/empty_slider.png",
                    height: 16,
                    fit: BoxFit.fitHeight,
                  )
              ),
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/filled_slider.png",
                    height: 16,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Consumed Unit',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: Color(0xff707070),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${consumedLimit.toStringAsFixed(0)}/-',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFFE2E5EC),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Monthly Limit',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: Color(0xff707070),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${monthlyLimit.toStringAsFixed(0)}/-',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBeneficiarySection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
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
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Beneficiary :',
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1B1C1C),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/icons/sort_icon.png", height: 16, width: 16),
                      SizedBox(width: 4),
                      Text(
                        'Sort',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff1B1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Bank or Account or Name',
                hintStyle: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Color(0xff6B707E),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Image.asset("assets/icons/search_icon.png", scale: 3),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                dmtController.searchBeneficiaries(value);
              },
            ),
          ),
          SizedBox(height: 16),

          // Beneficiary List
          Obx(() {
            if (dmtController.filteredBeneficiaryList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No beneficiaries found',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Color(0xff6B707E),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dmtController.filteredBeneficiaryList.length,
              itemBuilder: (context, index) {
                return buildBeneficiaryCard(
                  dmtController.filteredBeneficiaryList[index],
                  screenWidth,
                );
              },
              separatorBuilder: (context, index) {
                return Container(height: 1, color: Colors.grey.shade300);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget buildBeneficiaryCard(dynamic beneficiary, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Bank Logo
          Container(
            child: beneficiary.logo != null && beneficiary.logo!.isNotEmpty
                ? Image.network(
              beneficiary.logo!,
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_balance,
                  size: 28,
                  color: Color(0xFF4A90E2),
                );
              },
            )
                : Icon(Icons.account_balance, size: 28, color: Color(0xFF4A90E2)),
          ),
          SizedBox(width: 12),

          // Bank Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        beneficiary.bankName ?? "Unknown Bank",
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff1B1C1C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 3),
                    if (beneficiary.isVerified == true)
                      Icon(Icons.verified, color: Color(0xff009C46), size: 16),
                  ],
                ),
                Text(
                  beneficiary.beneName ?? "Unknown",
                  style: GoogleFonts.albertSans(
                    fontSize: 12,
                    color: Color(0xff6B707E),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () {
              showDeleteDialog(context, beneficiary.beneId ?? "");
            },
            icon: Icon(Icons.delete, color: Colors.red),
          ),

          // Transfer Button
          SizedBox(
            width: 76,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => TransferMoneyScreen(beneficiary: beneficiary));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0054D3)),
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
              ),
              child: Text(
                "Transfer",
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                softWrap: false,
              ),
            ),
          )
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String beneId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.90,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/icons/delete_icon.png", width: 60),
                    SizedBox(height: 20),
                    Text(
                      'Delete Beneficiary',
                      style: GoogleFonts.albertSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff0F0F0F),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Are you sure you want to delete this beneficiary?\nYou can always return and re-add them whenever you\'re ready.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: Color(0xff171F2D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[200]!),
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
                            child: GestureDetector(
                              onTap: () async {
                                Get.back();
                                await dmtController.deleteBeneficiary(context, beneId);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: GlobalUtils.blueBtnGradientColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    'Yes, Delete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}