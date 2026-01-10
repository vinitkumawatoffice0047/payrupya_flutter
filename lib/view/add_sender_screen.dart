// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../controllers/signup_controller.dart';
// import '../utils/global_utils.dart';
// import '../utils/otp_input_fields.dart';
// import 'payrupya_wallet_screen.dart';
//
// class AddSenderScreen extends StatefulWidget {
//   final bool showBackButton;
//   const AddSenderScreen({super.key, this.showBackButton = true});
//
//   @override
//   State<AddSenderScreen> createState() => _AddSenderScreenState();
// }
//
// // // Custom class to remove selection handles and highlight
// // class EmptyTextSelectionControls extends MaterialTextSelectionControls {
// //   @override
// //   Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
// //     return SizedBox.shrink(); // No handles
// //   }
// //
// //   @override
// //   Widget buildToolbar(
// //       BuildContext context,
// //       Rect globalEditableRegion,
// //       double textLineHeight,
// //       Offset selectionMidpoint,
// //       List<TextSelectionPoint> endpoints,
// //       TextSelectionDelegate delegate,
// //       ValueListenable<ClipboardStatus>? clipboardStatus,
// //       Offset? lastSecondaryTapDownPosition,
// //       ) {
// //     return SizedBox.shrink(); // No toolbar
// //   }
// //
// //   @override
// //   Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
// //     return Offset.zero;
// //   }
// //
// //   @override
// //   Size getHandleSize(double textLineHeight) {
// //     return Size.zero;
// //   }
// // }
//
// class _AddSenderScreenState extends State<AddSenderScreen> {
//   bool verifyByMobile = true;
//   bool isMobileNumberAlreadyRegistered = false;
//   bool showOtpDialog = false;
//
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController pincodeController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//
//   RxString selectedCity = 'Jaipur'.obs;
//   RxString selectedState = 'Rajasthan'.obs;
//
//   final GlobalKey<OtpInputFieldsState> otpKey =  GlobalKey<OtpInputFieldsState>();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF0F4F8),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Column(
//               children: [
//                 if(!widget.showBackButton)...[
//                   SizedBox(height: GlobalUtils.screenHeight * (12 / 393)),
//                 ],
//                 buildCustomAppBar(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: BouncingScrollPhysics(),
//                     padding: EdgeInsets.all(10),
//                     child: buildSenderForm(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (showOtpDialog) _buildOtpDialog(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCustomAppBar() {
//     return Padding(
//       padding: EdgeInsets.only(
//           left: GlobalUtils.screenWidth * 0.04,
//           right: GlobalUtils.screenWidth * 0.04,
//           bottom: 16
//       ),
//       child: Row(
//         children: [
//           if(widget.showBackButton)...[
//             /// BACK BUTTON
//             GestureDetector(
//               onTap: () => Get.back(),
//               child: Container(
//                 height: GlobalUtils.screenHeight * (22 / 393),
//                 width: GlobalUtils.screenWidth * (47 / 393),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
//               ),
//             ),
//
//             SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
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
//   Widget buildSenderForm() {
//     SignupController signupController = Get.put(SignupController());
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
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
//               ),
//               child:
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 12),
//                   Text(
//                     'Sender Details :',
//                     style: GoogleFonts.albertSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xff1B1C1C),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Verify by',
//                     style: GoogleFonts.albertSans(
//                       fontSize: 14,
//                       color: Color(0xff707070),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   // Toggle Buttons
//                   Row(
//                     children: [
//                       SizedBox(
//                         width: GlobalUtils.screenWidth * (174/393),
//                         height: 60,
//                         child: buildToggleButton('Mobile Number', verifyByMobile, () {
//                           setState(() => verifyByMobile = true);
//                         }),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   // Mobile Number Field
//                   buildLabelText('Sender Mobile Number'),
//                   SizedBox(height: 8),
//                   /// PHONE NUMBER
//                   GlobalUtils.CustomTextField(
//                     label: "Phone Number",
//                     showLabel: false,
//                     controller: mobileController,
//                     // prefixIcon: Icon(Icons.call, color: Color(0xFF6B707E)),
//                     isMobileNumber: true,
//                     placeholder: "Phone Number",
//                     placeholderColor: Colors.white,
//                     height: GlobalUtils.screenWidth * (60 / 393),
//                     width: GlobalUtils.screenWidth * 0.9,
//                     autoValidate: false,
//                     backgroundColor: Colors.white,
//                     borderColor: Color(0xffE2E5EC),
//                     borderRadius: 16,
//                     placeholderStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF6B707E),
//                     ),
//                     inputTextStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF1B1C1C),
//                     ),
//                     errorColor: Colors.red,
//                     errorFontSize: 12,
//                     suffixIcon: TextButton(
//                       onPressed: () {
//                         if (mobileController.text.isEmpty ||
//                             mobileController.text.length != 10) {
//                           Fluttertoast.showToast(
//                             msg: "Please enter valid 10-digit mobile number",
//                             backgroundColor: Colors.red,
//                           );
//                           return;
//                         }
//
//                         setState(() => showOtpDialog = true);
//
//                         // Dialog khulne ke baad OTP fields reset + focus first
//                         Future.delayed(const Duration(milliseconds: 100), () {
//                           if (showOtpDialog && mounted) {
//                             otpKey.currentState?.clear();
//                             otpKey.currentState?.focusFirst();
//                           }
//                         });
//                       },
//                       child: Text(
//                         "Verify",
//                         style: GoogleFonts.albertSans(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF0054D3),
//                         ),
//                       ),
//                     ),
//                   ),
//
//
//                   if(isMobileNumberAlreadyRegistered)...[
//                   SizedBox(height: 16),
//                   // Name Field
//                   buildLabelText('Your Name'),
//                   SizedBox(height: 8),
//                   GlobalUtils.CustomTextField(
//                     label: "Your Name",
//                     showLabel: false,
//                     controller: nameController,
//                     // prefixIcon: Icon(Icons.call, color: Color(0xFF6B707E)),
//                     isName: true,
//                     placeholder: "Your Name",
//                     placeholderColor: Colors.white,
//                     height: GlobalUtils.screenWidth * (60 / 393),
//                     width: GlobalUtils.screenWidth * 0.9,
//                     autoValidate: false,
//                     backgroundColor: Colors.white,
//                     borderColor: Color(0xffE2E5EC),
//                     borderRadius: 16,
//                     placeholderStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF6B707E),
//                     ),
//                     inputTextStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF1B1C1C),
//                     ),
//                     errorColor: Colors.red,
//                     errorFontSize: 12,
//                     // onChanged: (value) {
//                     //   signupController.isMobileNo.value = value.length == 10;
//                     // },
//                     // enabled: !signupController.isMobileVerified.value,
//                     // readOnly: signupController.isMobileVerified.value,
//                   ),
//                   SizedBox(height: 16),
//
//                   // State Dropdown With Search
//                   buildLabelText('State'),
//                   SizedBox(height: 8),
//                   /// STATE DROPDOWN WITH SEARCH
//                   Obx(()=>
//                     GestureDetector(
//                       onTap: () {
//                         signupController.fetchStates(context);
//                         showSearchableDropdown(
//                           context,
//                           'Select State',
//                           signupController.stateList,
//                           signupController.selectedState,
//                               (value) {
//                             signupController.selectedState.value = value;
//                             signupController.fetchCities(context);
//                           },
//                         );
//                       },
//                       child: Container(
//                         height: GlobalUtils.screenWidth * (60 / 393),
//                         width: GlobalUtils.screenWidth * 0.9,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Color(0xffE2E5EC)),
//                         ),
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             // Icon(Icons.location_on, color: Color(0xFF6B707E)),
//                             // SizedBox(width: 12),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 signupController.selectedState.value.isEmpty
//                                     ? "Select State"
//                                     : signupController.selectedState.value,
//                                 style: GoogleFonts.albertSans(
//                                   fontSize: GlobalUtils.screenWidth * (14 / 393),
//                                   color: signupController.selectedState.value.isEmpty
//                                       ? Color(0xFF6B707E)
//                                       : Color(0xFF1B1C1C),
//                                 ),
//                               ),
//                             ),
//                             Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//
//                   // City Dropdown
//                   buildLabelText('City'),
//                   SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () {
//                       if (signupController.selectedState.value.isEmpty) {
//                         Fluttertoast.showToast(msg: "Please select state first");
//                         return;
//                       }
//                       showSearchableDropdown(
//                         context,
//                         'Select City',
//                         signupController.cityList,
//                         signupController.selectedCity,
//                             (value) {
//                           signupController.selectedCity.value = value;
//                           signupController.fetchPincodes(context);
//                         },
//                       );
//                     },
//                     child: Container(
//                       height: GlobalUtils.screenWidth * (60 / 393),
//                       width: GlobalUtils.screenWidth * 0.9,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xffE2E5EC)),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           // Icon(Icons.location_city, color: Color(0xFF6B707E)),
//                           // SizedBox(width: 12),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               signupController.selectedCity.value.isEmpty
//                                   ? "Select City"
//                                   : signupController.selectedCity.value,
//                               style: GoogleFonts.albertSans(
//                                 fontSize: GlobalUtils.screenWidth * (14 / 393),
//                                 color: signupController.selectedCity.value.isEmpty
//                                     ? Color(0xFF6B707E)
//                                     : Color(0xFF1B1C1C),
//                               ),
//                             ),
//                           ),
//                           Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//
//                   // Pincode Dropdown With Search
//                   buildLabelText('Pincode'),
//                   SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () {
//                       if (signupController.selectedState.value.isEmpty) {
//                         Fluttertoast.showToast(msg: "Please select state first");
//                         return;
//                       }
//                       if (signupController.selectedCity.value.isEmpty) {
//                         Fluttertoast.showToast(msg: "Please select city first");
//                         return;
//                       }
//                       if (signupController.pincodeList.isEmpty) {
//                         Fluttertoast.showToast(msg: "No pincodes available for selected city");
//                         return;
//                       }
//                       showSearchableDropdown(
//                         context,
//                         'Select Pincode',
//                         signupController.pincodeList,
//                         signupController.selectedPincode,
//                             (value) {
//                           signupController.selectedPincode.value = value;
//                         },
//                       );
//                     },
//                     child: Container(
//                       height: GlobalUtils.screenWidth * (60 / 393),
//                       width: GlobalUtils.screenWidth * 0.9,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Color(0xffE2E5EC)),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           // Icon(Icons.pin_drop, color: Color(0xFF6B707E)),
//                           // SizedBox(width: 12),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               signupController.selectedPincode.value.isEmpty
//                                   ? "Select Pincode"
//                                   : signupController.selectedPincode.value,
//                               style: GoogleFonts.albertSans(
//                                 fontSize: GlobalUtils.screenWidth * (14 / 393),
//                                 color: signupController.selectedPincode.value.isEmpty
//                                     ? Color(0xFF6B707E)
//                                     : Color(0xFF1B1C1C),
//                               ),
//                             ),
//                           ),
//                           Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//
//                   // Address Field
//                   buildLabelText('Address'),
//                   SizedBox(height: 8),
//                   GlobalUtils.CustomTextField(
//                     label: "Address",
//                     showLabel: false,
//                     controller: addressController,
//                     placeholder: "Address",
//                     placeholderColor: Colors.white,
//                     width: GlobalUtils.screenWidth * 0.9,
//                     autoValidate: false,
//                     backgroundColor: Colors.white,
//                     borderColor: Color(0xffE2E5EC),
//                     borderRadius: 16,
//                     placeholderStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF6B707E),
//                     ),
//                     inputTextStyle: GoogleFonts.albertSans(
//                       fontSize: GlobalUtils.screenWidth * (14 / 393),
//                       color: Color(0xFF1B1C1C),
//                     ),
//                     minLines: 1,
//                     maxLines: 3,
//                     errorColor: Colors.red,
//                     errorFontSize: 12,
//                   ),],
//                   SizedBox(height: 10),
//                 ],
//               ),
//           ),
//           SizedBox(height: 24),
//           // Continue Button
//           GlobalUtils.CustomButton(
//             text: "Continue",
//             onPressed: () {
//               if(isMobileNumberAlreadyRegistered) {
//                 Get.to(WalletScreen(showBackButton: true));
//               }else{
//                 Get.to(WalletScreen(showBackButton: true));
//               }
//             },
//             textStyle: GoogleFonts.albertSans(
//               fontSize: 16,
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
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
//   void showSearchableDropdown(BuildContext context, String title, RxList<String> items, RxString selectedValue, Function(String) onSelect) {
//     TextEditingController searchController = TextEditingController();
//     RxList<String> filteredItems = RxList<String>.from(items);
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.7,
//           decoration: BoxDecoration(
//             // color: Colors.white,
//             color: Color(0xFFDEEBFF),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(25),
//               topRight: Radius.circular(25),
//             ),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[700],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       title,
//                       style: GoogleFonts.albertSans(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1B1C1C),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search...',
//                         prefixIcon: Icon(Icons.search, color: Color(0xFF6B707E)),
//                         filled: true,
//                         fillColor: Color(0xFFF5F5F5),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: TextStyle(
//                         color: Colors.black, // This sets the input text color
//                       ),
//                       onChanged: (value) {
//                         filteredItems.value = items
//                             .where((item) =>
//                             item.toLowerCase().contains(value.toLowerCase()))
//                             .toList();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Obx(() {
//                   if (filteredItems.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No items found',
//                         style: GoogleFonts.albertSans(
//                           color: Color(0xFF6B707E),
//                         ),
//                       ),
//                     );
//                   }
//                   return ListView.builder(
//                     itemCount: filteredItems.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(
//                           filteredItems[index],
//                           style: GoogleFonts.albertSans(
//                             fontSize: 14,
//                             color: Color(0xFF1B1C1C),
//                           ),
//                         ),
//                         onTap: () {
//                           onSelect(filteredItems[index]);
//                           Navigator.pop(context);
//                         },
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           // color: isSelected ? Color(0xFF2E5BFF).withOpacity(0.1) : Colors.transparent,
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[300]!,
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
//     String? suffixText,
//     VoidCallback? onSuffixTap,
//     TextInputType? keyboardType,
//     int maxLines = 1,
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
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           suffixIcon: suffixText != null
//               ? GestureDetector(
//             onTap: onSuffixTap,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(
//                 child: Text(
//                   suffixText,
//                   style: TextStyle(
//                     color: Color(0xFF2E5BFF),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           )
//               : null,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown(
//       String value,
//       List<String> items,
//       void Function(String?) onChanged,
//       ) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
//           items: items.map((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(
//                 item,
//                 style: TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOtpDialog() {
//     return Container(
//       color: Colors.black54,
//       child: Center(
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 10),
//           padding: EdgeInsets.symmetric(horizontal: 17, vertical: 24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Enter Verification Code',
//                     style: GoogleFonts.albertSans(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff0F0F0F),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() => showOtpDialog = false);
//                     },
//                     child: Icon(Icons.close, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               RichText(
//                 text: TextSpan(
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   children: [
//                     TextSpan(text: 'We sent a verification code to '),
//                     TextSpan(
//                       text: mobileController.text.isNotEmpty
//                           ? '+91 ${mobileController.text}'
//                           : '+91 9999887777',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 24),
//               // OTP Input Fields
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               //   children: List.generate(6, (index) {
//               //     return Container(
//               //       width: 50,
//               //       // height: 60,
//               //       child: RawKeyboardListener(
//               //         focusNode: FocusNode(),
//               //         onKey: (RawKeyEvent event) {
//               //           if (event is RawKeyDownEvent) {
//               //             if (event.logicalKey == LogicalKeyboardKey.backspace) {
//               //               if (otpControllers[index].text.isEmpty && index > 0) {
//               //                 // Move to previous field and clear it
//               //                 otpControllers[index - 1].clear();
//               //                 otpFocusNodes[index - 1].requestFocus();
//               //               } else if (otpControllers[index].text.isNotEmpty) {
//               //                 // Clear current field
//               //                 otpControllers[index].clear();
//               //                 setState(() {});
//               //               }
//               //             }
//               //           }
//               //         },
//               //         child: Theme(
//               //           data: ThemeData(
//               //             textSelectionTheme: TextSelectionThemeData(
//               //               selectionColor: Colors.transparent, // Remove purple highlight
//               //               selectionHandleColor: Colors.transparent,
//               //             ),
//               //           ),
//               //           child: TextField(
//               //             controller: otpControllers[index],
//               //             focusNode: otpFocusNodes[index],
//               //             keyboardType: TextInputType.number,
//               //             textAlign: TextAlign.center,
//               //             maxLength: 1,
//               //             maxLengthEnforcement: MaxLengthEnforcement.none,
//               //             showCursor: false, // Hide cursor
//               //             enableInteractiveSelection: false, // Disable text selection
//               //             selectionControls: EmptyTextSelectionControls(),
//               //             style: TextStyle(
//               //               fontSize: 24,
//               //               fontWeight: FontWeight.w600,
//               //               color: otpFocusNodes[index].hasFocus && otpControllers[index].text.isNotEmpty
//               //                   ? Color(0xFF0054D3) // Blue when focused and has value
//               //                   : otpControllers[index].text.isEmpty
//               //                   ? Color(0xff6B707E) // Grey when empty
//               //                   : Colors.black, // Black when filled and not focused
//               //             ),
//               //             inputFormatters: [
//               //               FilteringTextInputFormatter.digitsOnly,
//               //             ],
//               //             decoration: InputDecoration(
//               //               counterText: '',
//               //               hintText: '-',
//               //               hintStyle: TextStyle(
//               //                 color: Color(0xff6B707E),
//               //                 fontSize: 24,
//               //               ),
//               //               filled: true,
//               //               fillColor: Colors.white,
//               //               contentPadding: EdgeInsets.symmetric(vertical: 16),
//               //               border: OutlineInputBorder(
//               //                 borderRadius: BorderRadius.circular(16),
//               //                 borderSide: BorderSide(color: Colors.grey[300]!),
//               //               ),
//               //               enabledBorder: OutlineInputBorder(
//               //                 borderRadius: BorderRadius.circular(16),
//               //                 borderSide: BorderSide(color: Colors.grey[300]!),
//               //               ),
//               //               focusedBorder: OutlineInputBorder(
//               //                 borderRadius: BorderRadius.circular(16),
//               //                 borderSide: BorderSide(color: Color(0xFF2E5BFF), width: 2),
//               //               ),
//               //             ),
//               //             onTap: () {
//               //               // Select all text so new input replaces old digit
//               //               if (otpControllers[index].text.isNotEmpty) {
//               //                 otpControllers[index].selection = TextSelection(
//               //                   baseOffset: 0,
//               //                   extentOffset: otpControllers[index].text.length,
//               //                 );
//               //               }
//               //               setState(() {}); // Trigger rebuild to update color
//               //             },
//               //             onChanged: (value) {
//               //               if (value.length > 1) {
//               //                 // If user types when field already has digit, keep only new digit
//               //                 otpControllers[index].text = value[value.length - 1];
//               //                 otpControllers[index].selection = TextSelection.fromPosition(
//               //                   TextPosition(offset: otpControllers[index].text.length),
//               //                 );
//               //               }
//               //
//               //               if (value.isNotEmpty) {
//               //                 // Move to next field
//               //                 if (index < 5) {
//               //                   otpFocusNodes[index + 1].requestFocus();
//               //                 } else {
//               //                   // Last field - remove focus
//               //                   otpFocusNodes[index].unfocus();
//               //                 }
//               //               }
//               //               setState(() {}); // Trigger rebuild to update colors
//               //             },
//               //           ),
//               //         ),
//               //       ),
//               //     );
//               //   }),
//               // ),
//
//               /// 🔹 Yahan reusable OTP widget use ho raha hai
//               OtpInputFields(
//                 key: otpKey,
//                 length: 6,
//               ),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Didn\'t receive the code? ',
//                     style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                   ),
//                   GestureDetector(
//                     // onTap: () {
//                     //   // Clear all OTP fields
//                     //   for (int i = 0; i < 6; i++) {
//                     //     otpControllers[i].clear();
//                     //   }
//                     //   // Focus first field
//                     //   otpFocusNodes[0].requestFocus();
//                     //   Fluttertoast.showToast(msg: "OTP sent successfully");
//                     // },
//                     onTap: () {
//                       // OTP reset + focus first
//                       otpKey.currentState?.clear();
//                       otpKey.currentState?.focusFirst();
//                       Fluttertoast.showToast(msg: "OTP sent successfully");
//                     },
//                     child: Text(
//                       'Click to resend',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF2E5BFF),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 24),
//               // Verify Button
//               GlobalUtils.CustomButton(
//                 text: "VERIFY",
//                 onPressed: () {
//                   final otp = otpKey.currentState?.currentOtp ?? '';
//
//                   if (otp.length < 6) {
//                     Fluttertoast.showToast(
//                       msg: "Please enter complete 6-digit OTP",
//                       backgroundColor: Colors.red,
//                     );
//                     return;
//                   }
//
//                   if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
//                     Fluttertoast.showToast(
//                       msg: "Please enter valid OTP",
//                       backgroundColor: Colors.red,
//                     );
//                     return;
//                   }
//
//                   if (kDebugMode) {
//                     print('OTP Entered: $otp');
//                   }
//
//                   Fluttertoast.showToast(
//                     msg: "Mobile number verified successfully",
//                     backgroundColor: Colors.green,
//                   );
//                   setState(() => showOtpDialog = false);
//                 },
//                 textStyle: GoogleFonts.albertSans(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 width: GlobalUtils.screenWidth * 0.9,
//                 height: GlobalUtils.screenWidth * (60 / 393),
//                 backgroundGradient: GlobalUtils.blueBtnGradientColor,
//                 borderColor: Color(0xFF71A9FF),
//                 showShadow: false,
//                 textColor: Colors.white,
//                 animation: ButtonAnimation.fade,
//                 animationDuration: const Duration(milliseconds: 150),
//                 buttonType: ButtonType.elevated,
//                 borderRadius: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     mobileController.dispose();
//     nameController.dispose();
//     pincodeController.dispose();
//     addressController.dispose();
//     // otpControllers.forEach((controller) => controller.dispose());
//     // otpFocusNodes.forEach((node) => node.dispose());
//     super.dispose();
//   }
// }



// lib/view/add_sender_screen.dart
// Updated version with full API integration

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/api/api_provider.dart';

import '../controllers/dmt_wallet_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';
import '../models/get_beneficiary_list_response_model.dart';
import '../models/transfer_money_response_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/custom_loading.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';
import '../utils/transfer_success_dialog.dart';
import 'payrupya_wallet_screen.dart';

class AddSenderScreen extends StatefulWidget {
  final bool showBackButton;
  final String? initialMobile;

  const AddSenderScreen({
    super.key,
    this.showBackButton = true,
    this.initialMobile,
  });

  @override
  State<AddSenderScreen> createState() => _AddSenderScreenState();
}

class _AddSenderScreenState extends State<AddSenderScreen> {
  bool verifyByMobile = true;
  bool isMobileNumberAlreadyRegistered = false;
  // bool showOtpDialog = false;
  bool showOtpField = false;
  bool isOtpSent = false;

  late final DmtWalletController dmtController;
  // final SignupController signupController = Get.put(SignupController());
  // final LoginController loginController = Get.put(LoginController());
  bool _isInitialized = false;
  bool _isLoading = true;

  final GlobalKey<OtpInputFieldsState> otpKey = GlobalKey<OtpInputFieldsState>();

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<DmtWalletController>()) {
      Get.delete<DmtWalletController>(force: true);
    }

    dmtController = Get.put(DmtWalletController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeServices();
    });

    // If initial mobile is provided, set it and check sender
    if (widget.initialMobile != null && widget.initialMobile!.isNotEmpty) {
      dmtController.senderMobileController.value.text = widget.initialMobile!;

      // Check sender after a small delay
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          dmtController.checkSender(context, widget.initialMobile!);
        }
      });
    }

    // Fetch states for location dropdown
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && Get.context != null) {
        // signupController.fetchStates(Get.context!);
      }
    });
  }

  Future<void> initializeServices() async {
    try {
      setState(() {
        _isLoading = true;
      });

      ConsoleLog.printInfo("=== Initializing DMT Services ===");

      // 1. Load auth credentials first
      await dmtController.loadAuthCredentials();

      // // 2. Wait for location
      // int waitCount = 0;
      // while ((loginController.latitude.value == 0.0 ||
      //     loginController.longitude.value == 0.0) &&
      //     waitCount < 20) {
      //   ConsoleLog.printWarning("Waiting for location in screen... ($waitCount/20)");
      //   await Future.delayed(Duration(milliseconds: 500));
      //   waitCount++;
      // }
      //
      // if (loginController.latitude.value == 0.0 ||
      //     loginController.longitude.value == 0.0) {
      //   ConsoleLog.printError("❌ Location timeout");
      //   Fluttertoast.showToast(
      //     msg: "Unable to get location. Please enable GPS.",
      //     backgroundColor: Colors.red,
      //   );
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   return;
      // }

      // 3. Check if service code is already loaded
      if (dmtController.serviceCode.value.isEmpty) {
        ConsoleLog.printWarning("Service code empty, loading from API...");

        // 4. Load service code
        await dmtController.getAllowedServiceByType(context);

        // Wait for service to load
        await Future.delayed(Duration(milliseconds: 1000));

        if (dmtController.serviceCode.value.isEmpty) {
          ConsoleLog.printError("❌ Service code still empty after API call");
          Fluttertoast.showToast(
            msg: "Failed to initialize services. Please try again.",
            backgroundColor: Colors.red,
          );
        }
      }

      // 4. Load banks list
      await dmtController.getAllBanks(context);

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      ConsoleLog.printSuccess("Services initialized. Service Code: ${dmtController.serviceCode.value}");

    } catch (e) {
      ConsoleLog.printError("Failed to initialize services: $e");
      // dmtController.serviceCode.value = "DMTRZP"; // Set default
      // await dmtController.getAllowedServiceByType(context);

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    }
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
          child: SizedBox(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          if (!widget.showBackButton) ...[
                            SizedBox(height: GlobalUtils.screenHeight * (12 / 393)),
                          ],
                          buildCustomAppBar(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.all(10),
                              child: buildSenderForm(),
                            ),
                          ),
                        ],
                      ),
                      // if (showOtpDialog) _buildOtpDialog(),
                    ],
                  ),
                ),
                SizedBox(height: 15,),

                //region Verify & Continue Button
                // Verify & Continue Button
                GlobalUtils.CustomButton(
                  text: (!dmtController.isSenderVerified.value &&
                      isMobileNumberAlreadyRegistered) ? "Continue" : "Verify",
                  onPressed: () async {

                    /// 🔒 Button disable condition
                    if (_isLoading || dmtController.serviceCode.value.isEmpty) {
                      return;
                    }

                    /// CASE 1️⃣ : Sender OTP verification flow
                    if (!dmtController.isSenderVerified.value &&
                        isMobileNumberAlreadyRegistered) {

                      final otp = otpKey.currentState?.currentOtp ?? '';

                      if (otp.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter OTP",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderMobileController.value.text.length != 10) {
                        Fluttertoast.showToast(msg: "Please enter valid mobile number",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderNameController.value.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter name",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderAddressController.value.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter address",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderPincodeController.value.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter pincode number",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderCityController.value.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter city name",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      if (dmtController.senderStateController.value.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter state name",
                          gravity: ToastGravity.TOP,
                        );
                        return;
                      }

                      /// ✅ Add Sender API
                      await dmtController.addSender(context, otp);
                      return;
                    }

                    /// CASE 2️⃣ : Mobile verify / check sender
                    String mobile =
                    dmtController.senderMobileController.value.text.trim();

                    if (mobile.isEmpty || mobile.length != 10) {
                      Fluttertoast.showToast(
                        msg: "Please enter valid 10-digit mobile number",
                        backgroundColor: Colors.red,
                        gravity: ToastGravity.TOP,
                      );
                      return;
                    }

                    /// ✅ THIS WAS NOT CALLING EARLIER
                    await dmtController.checkSender(context, mobile);

                    if (!dmtController.isSenderVerified.value) {
                      setState(() {
                        isMobileNumberAlreadyRegistered = true;
                      });
                    } else if (dmtController.senderName.value.isEmpty) {
                      setState(() {
                        isMobileNumberAlreadyRegistered = false;
                      });
                    }

                    if (dmtController.checkSenderRespCode.value == "RCS") {
                      await Get.to(() => PayrupyaWalletScreen());
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
                ),
                //endregion
            //     // Continue Button Old with Separate Verify Button on Mobile No Field
            //     GlobalUtils.CustomButton(
            //       text: "Continue",
            //       onPressed: () async {
            //         if (!dmtController.isSenderVerified.value && isMobileNumberAlreadyRegistered) {
            //           final otp = otpKey.currentState?.currentOtp ?? '';
            //           if(otp.isEmpty){
            //             Fluttertoast.showToast(msg: "Please enter OTP");
            //             return;
            //           }
            //           if(dmtController.senderMobileController.value.text.isEmpty && dmtController.senderMobileController.value.text.length < 10){
            //             Fluttertoast.showToast(msg: "Please enter mobile number");
            //             return;
            //           }
            //           if(dmtController.senderNameController.value.text.isEmpty){
            //             Fluttertoast.showToast(msg: "Please enter name");
            //             return;
            //           }
            //           if(dmtController.selectedState.value.isEmpty){
            //             Fluttertoast.showToast(msg: "Please select state");
            //             return;
            //           }
            //           if(dmtController.selectedPincode.value.isEmpty){
            //             Fluttertoast.showToast(msg: "Please select pincode");
            //             return;
            //           }
            //           if(dmtController.senderAddressController.value.text.isEmpty) {
            //             Fluttertoast.showToast(msg: "Please enter address");
            //             return;
            //           }
            //           if(
            //           otp.isNotEmpty &&
            //               dmtController.senderMobileController.value.text.isNotEmpty &&
            //               dmtController.senderNameController.value.text.isNotEmpty &&
            //               dmtController.selectedState.value.isNotEmpty &&
            //               dmtController.selectedCity.value.isNotEmpty &&
            //               dmtController.selectedPincode.value.isNotEmpty &&
            //               dmtController.senderAddressController.value.text.isNotEmpty
            //           ){
            //             // Add new sender
            //             await dmtController.addSender(context, otp);
            //           }
            //
            //           // // Show OTP dialog
            //           // setState(() => showOtpDialog = true);
            //           // Future.delayed(const Duration(milliseconds: 100), () {
            //           //   if (showOtpDialog && mounted) {
            //           //     otpKey.currentState?.clear();
            //           //     otpKey.currentState?.focusFirst();
            //           //   }
            //           // });
            //         } else{
            //           Fluttertoast.showToast(msg: "Please Verify Mobile Number!");
            //           return null;
            //         }/*else {
            //   // Navigate to wallet
            //   // Get.to(() => WalletScreen(showBackButton: true));
            //   Get.to(() => WalletScreen());
            // }*/
            //       },
            //       textStyle: GoogleFonts.albertSans(
            //         fontSize: 16,
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //       ),
            //       width: GlobalUtils.screenWidth * 0.9,
            //       height: GlobalUtils.screenWidth * (60 / 393),
            //       backgroundGradient: GlobalUtils.blueBtnGradientColor,
            //       borderColor: Color(0xFF71A9FF),
            //       showShadow: false,
            //       textColor: Colors.white,
            //       animation: ButtonAnimation.fade,
            //       animationDuration: const Duration(milliseconds: 150),
            //       buttonType: ButtonType.elevated,
            //       borderRadius: 16,
            //     ),
                SizedBox(height: 16),
              ],
            ),
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
              onTap: () {
                dmtController.senderMobileController.value.clear();
                otpKey.currentState?.clear();
                dmtController.senderNameController.value.clear();
                // signupController.selectedState.value = "";
                // dmtController.selectedState.value = "";
                // signupController.selectedCity.value = "";
                // dmtController.selectedCity.value = "";
                // signupController.selectedPincode.value = "";
                // dmtController.selectedPincode.value = "";
                dmtController.senderAddressController.value.clear();
                // Get.back();
                Navigator.of(context).pop(context);
              },
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

  Widget buildSenderForm() {
    return Column(
      children: [
        // Show loading indicator
        if (_isLoading) ...[
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(color: Colors.black,),
                SizedBox(height: 16),
                Text(
                  "Initializing services...",
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Color(0xFF6B707E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
        if (!_isLoading) ...[
          Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Text(
                'Sender Details :',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1B1C1C),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Verify by',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Color(0xff707070),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: GlobalUtils.screenWidth * (174 / 393),
                    height: 60,
                    child: buildToggleButton('Mobile Number', verifyByMobile, () {
                      setState(() => verifyByMobile = true);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20),

              //region Mobile Number Field
              buildLabelText('Sender Mobile Number'),
              SizedBox(height: 8),
              GlobalUtils.CustomTextField(
                label: "Phone Number",
                showLabel: false,
                controller: dmtController.senderMobileController.value,
                isMobileNumber: true,
                placeholder: "Phone Number",
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
                onChanged: (value) {
                  /// Agar OTP / Extra fields already visible hain
                  if (isMobileNumberAlreadyRegistered) {
                    setState(() {
                      isMobileNumberAlreadyRegistered = false;
                    });

                    /// Sender verification reset
                    dmtController.isSenderVerified.value = false;

                    /// OPTIONAL but recommended: extra fields clear
                    dmtController.senderNameController.value.clear();
                    dmtController.senderAddressController.value.clear();
                    dmtController.selectedState.value = '';
                    dmtController.selectedCity.value = '';
                    dmtController.selectedPincode.value = '';

                    /// OTP clear
                    otpKey.currentState?.clear();
                  }
                }
                // suffixIcon: TextButton(
                //   onPressed: (_isLoading || dmtController.serviceCode.value.isEmpty)
                //       ? null // ✅ Disable button if service not ready
                //       : () async {
                //     String mobile = dmtController.senderMobileController.value.text.trim();
                //
                //     if (mobile.isEmpty || mobile.length != 10) {
                //       Fluttertoast.showToast(
                //         msg: "Please enter valid 10-digit mobile number",
                //         backgroundColor: Colors.red,
                //       );
                //       return;
                //     }
                //
                //     // Check sender
                //     await dmtController.checkSender(context, mobile);
                //
                //     // If sender not found, show registration form
                //     if (!dmtController.isSenderVerified.value) {
                //       setState(() {
                //         isMobileNumberAlreadyRegistered = true;
                //       });
                //     } else if(dmtController.senderName.value.isEmpty){
                //       setState(() {
                //         isMobileNumberAlreadyRegistered = false;
                //       });
                //     }
                //     if(dmtController.checkSenderRespCode.value == "RCS") {
                //       // Sender exists, navigate to wallet
                //       // Get.to(() => WalletScreen(showBackButton: true));
                //       // await Future.delayed(Duration(seconds: 5));
                //       await Get.to(() => WalletScreen());
                //     }
                //   },
                //   child: _isLoading
                //       ? SizedBox(
                //     width: 16,
                //     height: 16,
                //     child: CircularProgressIndicator(
                //       strokeWidth: 2,
                //       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0054D3)),
                //     ),
                //   )
                //       : Text(
                //     "Verify",
                //     style: GoogleFonts.albertSans(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w500,
                //       color: (_isLoading || dmtController.serviceCode.value.isEmpty)
                //           ? Colors.grey // ✅ Grey when disabled
                //           : Color(0xFF0054D3),
                //     ),
                //   ),
                // ),
              ),
              //endregion

              if (isMobileNumberAlreadyRegistered && !dmtController.isSenderVerified.value && dmtController.checkSenderRespCode.value.isNotEmpty && dmtController.checkSenderRespCode.value == "RNF") ...[
                SizedBox(height: 16),
                buildLabelText('OTP Verification'),
                SizedBox(height: 8),

                OtpInputFields(
                  key: otpKey,
                  length: 6,
                ),

                SizedBox(height: 16),

                //region Name Field
                buildLabelText('Your Name'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Your Name",
                  showLabel: false,
                  controller: dmtController.senderNameController.value,
                  isName: true,
                  placeholder: "Your Name",
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
                ),
                SizedBox(height: 16),
                //endregion

                //region Address Field
                buildLabelText('Address'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Address",
                  showLabel: false,
                  controller: dmtController.senderAddressController.value,
                  placeholder: "Address",
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
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                //endregion

                //region Pincode Field
                buildLabelText('Pincode'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "Pincode",
                  showLabel: false,
                  controller: dmtController.senderPincodeController.value,
                  placeholder: "Pincode",
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
                  maxLength: 6,
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.number,
                  onChanged: (value){
                    if(value.length == 6){
                      ApiProvider().getCityStateByPinCode(context, dmtController.senderPincodeController.value.text);
                    }
                  },
                ),
                SizedBox(height: 16),
                //endregion

                //region City
                buildLabelText('City'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "City",
                  showLabel: false,
                  controller: dmtController.senderCityController.value,
                  placeholder: "City",
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
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                //endregion

                //region State
                buildLabelText('State'),
                SizedBox(height: 8),
                GlobalUtils.CustomTextField(
                  label: "State",
                  showLabel: false,
                  controller: dmtController.senderStateController.value,
                  placeholder: "State",
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
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                //endregion

                //region USE THESE AS IT IS WHEN REQUIRED
                // //region State Dropdown
                // buildLabelText('State'),
                // SizedBox(height: 8),
                // Obx(()=>
                //     GestureDetector(
                //       onTap: () {
                //         signupController.fetchStates(context);
                //         showSearchableDropdown(
                //           context,
                //           'Select State',
                //           signupController.stateList,
                //           signupController.selectedState,
                //               (value) {
                //             signupController.selectedState.value = value;
                //             dmtController.selectedState.value = value;
                //             signupController.fetchCities(context);
                //           },
                //         );
                //       },
                //       child: Container(
                //         height: GlobalUtils.screenWidth * (60 / 393),
                //         width: GlobalUtils.screenWidth * 0.9,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(16),
                //           border: Border.all(color: Color(0xffE2E5EC)),
                //         ),
                //         padding: EdgeInsets.symmetric(horizontal: 16),
                //         child: Row(
                //           children: [
                //             SizedBox(width: 10),
                //             Expanded(
                //               child: Text(
                //                 signupController.selectedState.value.isEmpty
                //                     ? "Select State"
                //                     : signupController.selectedState.value,
                //                 style: GoogleFonts.albertSans(
                //                   fontSize: GlobalUtils.screenWidth * (14 / 393),
                //                   color: signupController.selectedState.value.isEmpty
                //                       ? Color(0xFF6B707E)
                //                       : Color(0xFF1B1C1C),
                //                 ),
                //               ),
                //             ),
                //             Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                //           ],
                //         ),
                //       ),
                //     ),
                // ),
                // SizedBox(height: 16),
                // //endregion
                //
                // //region City Dropdown
                // buildLabelText('City'),
                // SizedBox(height: 8),
                // Obx(()=>
                //     GestureDetector(
                //       onTap: () {
                //         if (signupController.selectedState.value.isEmpty) {
                //           Fluttertoast.showToast(msg: "Please select state first");
                //           return;
                //         }
                //         showSearchableDropdown(
                //           context,
                //           'Select City',
                //           signupController.cityList,
                //           signupController.selectedCity,
                //               (value) {
                //             signupController.selectedCity.value = value;
                //             dmtController.selectedCity.value = value;
                //             signupController.fetchPincodes(context);
                //           },
                //         );
                //       },
                //       child: Container(
                //         height: GlobalUtils.screenWidth * (60 / 393),
                //         width: GlobalUtils.screenWidth * 0.9,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(16),
                //           border: Border.all(color: Color(0xffE2E5EC)),
                //         ),
                //         padding: EdgeInsets.symmetric(horizontal: 16),
                //         child: Row(
                //           children: [
                //             SizedBox(width: 10),
                //             Expanded(
                //               child: Text(
                //                 signupController.selectedCity.value.isEmpty
                //                     ? "Select City"
                //                     : signupController.selectedCity.value,
                //                 style: GoogleFonts.albertSans(
                //                   fontSize: GlobalUtils.screenWidth * (14 / 393),
                //                   color: signupController.selectedCity.value.isEmpty
                //                       ? Color(0xFF6B707E)
                //                       : Color(0xFF1B1C1C),
                //                 ),
                //               ),
                //             ),
                //             Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                //           ],
                //         ),
                //       ),
                //     ),
                // ),
                // SizedBox(height: 16),
                // //endregion
                //
                // //region Pincode Dropdown
                // buildLabelText('Pincode'),
                // SizedBox(height: 8),
                // Obx(()=>
                //     GestureDetector(
                //       onTap: () {
                //         if (signupController.selectedState.value.isEmpty) {
                //           Fluttertoast.showToast(msg: "Please select state first");
                //           return;
                //         }
                //         if (signupController.selectedCity.value.isEmpty) {
                //           Fluttertoast.showToast(msg: "Please select city first");
                //           return;
                //         }
                //         if (signupController.pincodeList.isEmpty) {
                //           Fluttertoast.showToast(msg: "Wait for pincode list to load & press again");
                //           return;
                //         }
                //         showSearchableDropdown(
                //           context,
                //           'Select Pincode',
                //           signupController.pincodeList,
                //           signupController.selectedPincode,
                //               (value) {
                //             signupController.selectedPincode.value = value;
                //             dmtController.selectedPincode.value = value;
                //           },
                //         );
                //       },
                //       child: Container(
                //         height: GlobalUtils.screenWidth * (60 / 393),
                //         width: GlobalUtils.screenWidth * 0.9,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(16),
                //           border: Border.all(color: Color(0xffE2E5EC)),
                //         ),
                //         padding: EdgeInsets.symmetric(horizontal: 16),
                //         child: Row(
                //           children: [
                //             SizedBox(width: 10),
                //             Expanded(
                //               child: Text(
                //                 signupController.selectedPincode.value.isEmpty
                //                     ? "Select Pincode"
                //                     : signupController.selectedPincode.value,
                //                 style: GoogleFonts.albertSans(
                //                   fontSize: GlobalUtils.screenWidth * (14 / 393),
                //                   color: signupController.selectedPincode.value.isEmpty
                //                       ? Color(0xFF6B707E)
                //                       : Color(0xFF1B1C1C),
                //                 ),
                //               ),
                //             ),
                //             Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                //           ],
                //         ),
                //       ),
                //     ),
                // ),
                // SizedBox(height: 16),
                // //endregion
                //endregion
              ],
              // SizedBox(height: 10),
            ],
          ),
        ),

          SizedBox(height: 10,),

          Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //region SEARCH ACCOUNTS SECTION
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F9FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE3F0FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Existing Account',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Search Input Field and Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Search Input Field
                        Expanded(
                          child: SizedBox(
                            height: GlobalUtils.screenWidth * (60 / 393),
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // TextField without Column wrapper to avoid overflow
                                Container(
                                  height: GlobalUtils.screenWidth * (60 / 393),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xffE2E5EC),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: dmtController.searchAccountController.value,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      color: Color(0xFF1B1C1C),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Search by account number",
                                      hintStyle: GoogleFonts.albertSans(
                                        fontSize: GlobalUtils.screenWidth * (14 / 393),
                                        color: Color(0xFF6B707E),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                // Clear button inside input field
                                Obx(() => Positioned(
                                  right: 12,
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    ignoring: dmtController.searchAccountController.value.text.isEmpty,
                                    child: AnimatedOpacity(
                                      opacity: dmtController.searchAccountController.value.text.isNotEmpty ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 150),
                                      child: GestureDetector(
                                        onTap: () {
                                          dmtController.resetSearch();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.clear, color: Color(0xFF6B707E), size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Search button outside input field with gradient
                        Container(
                          width: GlobalUtils.screenWidth * (60 / 393),
                          height: GlobalUtils.screenWidth * (60 / 393),
                          decoration: BoxDecoration(
                            gradient: GlobalUtils.blueBtnGradientColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                String query = dmtController.searchAccountController.value.text.trim();
                                if (query.isNotEmpty) {
                                  dmtController.searchByAccountNumber(query);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Please enter account number",
                                    gravity: ToastGravity.TOP,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center,
                                child: Icon(Icons.search, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Search Suggestions List with Infinite Scroll
                    Obx(() {
                      // Initial Loading State
                      if (dmtController.isSearching.value && dmtController.searchSuggestions.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0054D3)),
                            ),
                          ),
                        );
                      }

                      // No suggestions
                      if (dmtController.searchSuggestions.isEmpty) {
                        return SizedBox. shrink();
                      }

                      // Suggestions List
                      return NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          // Check if user scrolled to bottom
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                              ! dmtController.isLoadingMore.value &&
                              dmtController.hasMoreSuggestions.value) {

                            // Load more suggestions
                            ConsoleLog.printColor("📍 Bottom reached, loading more...");
                            dmtController.loadMoreAccountSuggestions(
                                dmtController.lastSearchQuery.value
                            );
                          }
                          return true;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE2E5EC)),
                          ),
                          constraints: BoxConstraints(
                            maxHeight: GlobalUtils.screenHeight * 0.4, // Max height for list
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: dmtController.searchSuggestions.length + 1, // +1 for footer
                            separatorBuilder: (_, __) => Divider(height: 1, color: Color(0xFFE2E5EC)),
                            itemBuilder: (context, index) {
                              // Regular items
                              if (index < dmtController.searchSuggestions.length) {
                                final account = dmtController.searchSuggestions[index];
                                return buildSearchSuggestionTile(account);
                              }

                              // Footer (Loading indicator or Load More button)
                              if (dmtController.isLoadingMore.value) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0054D3)),
                                    ),
                                  ),
                                );
                              }

                              // Show Load More button if more data available
                              if (dmtController.hasMoreSuggestions.value) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        dmtController.loadMoreAccountSuggestions(
                                            dmtController.lastSearchQuery.value
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical:  8),
                                        decoration:  BoxDecoration(
                                          color: Color(0xFFE3F0FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Load More',
                                          style: GoogleFonts.albertSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0054D3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // No more data message
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'All results loaded (${dmtController.searchSuggestions.length} total)',
                                    style: GoogleFonts.albertSans(
                                      fontSize: 12,
                                      color: Color(0xFF6B707E),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // SizedBox(height: 20),
              //endregion
            ],
          ),
        ),
        ],
      ],
    );
  }

  // Helper Methods...
  // Helper widget for suggestion tile
  Widget buildSearchSuggestionTile(BeneficiaryData account) {
    return InkWell(
      onTap: () {
        dmtController.onSuggestionSelected(account);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (account.name ?? '? ')[0].toUpperCase(),
                      style: GoogleFonts.albertSans(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0054D3),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name ?? 'Unknown',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${account.accountNo ?? ''} • ${account.bankName ?? ''}',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: Color(0xFF6B707E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (account.mobile != null && account.mobile!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          'Mobile: ${account.mobile}',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Color(0xFF6B707E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B707E)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showSearchableDropdown(BuildContext context, String title, RxList<String> items, RxString selectedValue, Function(String) onSelect) {
    TextEditingController searchController = TextEditingController();
    RxList<String> filteredItems = RxList<String>.from(items);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Color(0xFFDEEBFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, color: Color(0xFF6B707E)),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        filteredItems.value = items
                            .where((item) =>
                            item.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Text(
                        'No items found',
                        style: GoogleFonts.albertSans(color: Color(0xFF6B707E)),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          filteredItems[index],
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: Color(0xFF1B1C1C),
                          ),
                        ),
                        onTap: () {
                          onSelect(filteredItems[index]);
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

  Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
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

  Widget _buildOtpDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter Verification Code',
                    style: GoogleFonts.albertSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0F0F0F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // setState(() => showOtpDialog = false);
                    },
                    child: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  children: [
                    TextSpan(text: 'We sent a verification code to '),
                    TextSpan(
                      text: '+91 ${dmtController.senderMobileController.value.text}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // OTP Input Fields
              OtpInputFields(
                key: otpKey,
                length: 6,
              ),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final otp = otpKey.currentState?.currentOtp ?? '';
                      // Resend OTP
                      await dmtController.addSender(context, otp);

                      otpKey.currentState?.clear();
                      otpKey.currentState?.focusFirst();
                      Fluttertoast.showToast(msg: "OTP sent successfully");
                    },
                    child: Text(
                      'Click to resend',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E5BFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Verify Button
              GlobalUtils.CustomButton(
                text: "VERIFY",
                onPressed: () async {
                  dmtController.checkSender(context, dmtController.senderMobileController.value.text.trim());
                  // final otp = otpKey.currentState?.currentOtp ?? '';
                  //
                  // if (otp.length < 6) {
                  //   Fluttertoast.showToast(
                  //     msg: "Please enter complete 6-digit OTP",
                  //     backgroundColor: Colors.red,
                  //   );
                  //   return;
                  // }
                  //
                  // // Verify OTP
                  // await dmtController.verifySenderOtp(context, otp);

                  // if (dmtController.isSenderVerified.value) {
                  //   setState(() => showOtpDialog = false);
                  //
                  //   // Navigate to wallet
                  //   Get.to(() => WalletScreen(showBackButton: true));
                  // }
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (Get.isRegistered<DmtWalletController>()) {
      Get.delete<DmtWalletController>(force: true);
    }
    dmtController.dispose();
    // signupController.dispose();
    // loginController.dispose();
    otpKey.currentState?.dispose();
  }
}