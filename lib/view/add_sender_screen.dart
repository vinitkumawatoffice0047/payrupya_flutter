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
// import 'wallet_screen.dart';
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

import '../controllers/dmt_wallet_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';
import '../utils/ConsoleLog.dart';
import '../utils/global_utils.dart';
import '../utils/otp_input_fields.dart';
import 'wallet_screen.dart';

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
  bool showOtpDialog = false;

  final DmtWalletController dmtController = Get.put(DmtWalletController());
  final SignupController signupController = Get.put(SignupController());
  final LoginController loginController = Get.find<LoginController>();
  bool _isInitialized = false;
  bool _isLoading = true;

  final GlobalKey<OtpInputFieldsState> otpKey = GlobalKey<OtpInputFieldsState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
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
        signupController.fetchStates(Get.context!);
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _isLoading = true;
      });

      ConsoleLog.printInfo("=== Initializing DMT Services ===");

      // 1. Load auth credentials first
      await dmtController.loadAuthCredentials();

      // 2. Check if service code is already loaded
      if (dmtController.serviceCode.value.isEmpty) {
        ConsoleLog.printWarning("Service code empty, loading from API...");

        // 3. Load service code
        await dmtController.getAllowedServiceByType(context);

        // Wait for service to load
        await Future.delayed(Duration(milliseconds: 1000));

        if (dmtController.serviceCode.value.isEmpty) {
          ConsoleLog.printWarning("Still empty, setting default...");
          // dmtController.serviceCode.value = "DMTRZP";
          await dmtController.getAllowedServiceByType(context);
        }
      }

      // 4. Load banks list
      await dmtController.getAllBanks(context);

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      ConsoleLog.printSuccess("✅ Services initialized. Service Code: ${dmtController.serviceCode.value}");

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
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
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
          ),
          if (showOtpDialog) _buildOtpDialog(),
        ],
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

  Widget buildSenderForm() {
    return Obx(() => Column(
      children: [
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

              // Mobile Number Field
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
                suffixIcon: TextButton(
                  onPressed: () async {
                    String mobile = dmtController.senderMobileController.value.text.trim();

                    if (mobile.isEmpty || mobile.length != 10) {
                      Fluttertoast.showToast(
                        msg: "Please enter valid 10-digit mobile number",
                        backgroundColor: Colors.red,
                      );
                      return;
                    }

                    // Check sender
                    await dmtController.checkSender(context, mobile);

                    // If sender not found, show registration form
                    if (!dmtController.isSenderVerified.value) {
                      setState(() {
                        isMobileNumberAlreadyRegistered = true;
                      });
                    } else {
                      // Sender exists, navigate to wallet
                      Get.to(() => WalletScreen(showBackButton: true));
                    }
                  },
                  child: Text(
                    "Verify",
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0054D3),
                    ),
                  ),
                ),
              ),

              if (isMobileNumberAlreadyRegistered && !dmtController.isSenderVerified.value) ...[
                SizedBox(height: 16),

                // Name Field
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

                // State Dropdown
                buildLabelText('State'),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    signupController.fetchStates(context);
                    showSearchableDropdown(
                      context,
                      'Select State',
                      signupController.stateList,
                      signupController.selectedState,
                          (value) {
                        signupController.selectedState.value = value;
                        dmtController.selectedState.value = value;
                        signupController.fetchCities(context);
                      },
                    );
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
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            signupController.selectedState.value.isEmpty
                                ? "Select State"
                                : signupController.selectedState.value,
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: signupController.selectedState.value.isEmpty
                                  ? Color(0xFF6B707E)
                                  : Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // City Dropdown
                buildLabelText('City'),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (signupController.selectedState.value.isEmpty) {
                      Fluttertoast.showToast(msg: "Please select state first");
                      return;
                    }
                    showSearchableDropdown(
                      context,
                      'Select City',
                      signupController.cityList,
                      signupController.selectedCity,
                          (value) {
                        signupController.selectedCity.value = value;
                        dmtController.selectedCity.value = value;
                        signupController.fetchPincodes(context);
                      },
                    );
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
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            signupController.selectedCity.value.isEmpty
                                ? "Select City"
                                : signupController.selectedCity.value,
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: signupController.selectedCity.value.isEmpty
                                  ? Color(0xFF6B707E)
                                  : Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Pincode Dropdown
                buildLabelText('Pincode'),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (signupController.selectedState.value.isEmpty) {
                      Fluttertoast.showToast(msg: "Please select state first");
                      return;
                    }
                    if (signupController.selectedCity.value.isEmpty) {
                      Fluttertoast.showToast(msg: "Please select city first");
                      return;
                    }
                    if (signupController.pincodeList.isEmpty) {
                      Fluttertoast.showToast(msg: "No pincodes available");
                      return;
                    }
                    showSearchableDropdown(
                      context,
                      'Select Pincode',
                      signupController.pincodeList,
                      signupController.selectedPincode,
                          (value) {
                        signupController.selectedPincode.value = value;
                        dmtController.selectedPincode.value = value;
                      },
                    );
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
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            signupController.selectedPincode.value.isEmpty
                                ? "Select Pincode"
                                : signupController.selectedPincode.value,
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: signupController.selectedPincode.value.isEmpty
                                  ? Color(0xFF6B707E)
                                  : Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Address Field
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
              ],
              SizedBox(height: 10),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Continue Button
        GlobalUtils.CustomButton(
          text: "Continue",
          onPressed: () async {
            if (!dmtController.isSenderVerified.value && isMobileNumberAlreadyRegistered) {
              // Add new sender
              await dmtController.addSender(context);

              // Show OTP dialog
              setState(() => showOtpDialog = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (showOtpDialog && mounted) {
                  otpKey.currentState?.clear();
                  otpKey.currentState?.focusFirst();
                }
              });
            } else {
              // Navigate to wallet
              Get.to(() => WalletScreen(showBackButton: true));
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
        SizedBox(height: 16),
      ],
    ));
  }

  // Helper Methods...
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
                      setState(() => showOtpDialog = false);
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
                      // Resend OTP
                      await dmtController.addSender(context);

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
                  final otp = otpKey.currentState?.currentOtp ?? '';

                  if (otp.length < 6) {
                    Fluttertoast.showToast(
                      msg: "Please enter complete 6-digit OTP",
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  // Verify OTP
                  await dmtController.verifySenderOtp(context, otp);

                  if (dmtController.isSenderVerified.value) {
                    setState(() => showOtpDialog = false);

                    // Navigate to wallet
                    Get.to(() => WalletScreen(showBackButton: true));
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}