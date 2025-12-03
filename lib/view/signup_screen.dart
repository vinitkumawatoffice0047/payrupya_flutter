import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/web_api_constant.dart';
import '../controllers/signup_controller.dart';
import '../utils/global_utils.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupController signupController = Get.put(SignupController());

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GlobalUtils.screenWidth * 0.04,
      ),
      child: Row(
        children: [
          /// BACK BUTTON
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (40 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),

          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),

          /// TITLE
          Text(
            "Sign Up",
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
              buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),

                        /// SUBTITLE TEXT
                        Text(
                          "Register Your Account",
                          style: GoogleFonts.albertSans(
                            fontSize: GlobalUtils.screenWidth * (24 / 393),
                            color: Color(0xFF0F0F0F),
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: GlobalUtils.screenHeight * 0.035),

                        /// FIRST NAME
                        GlobalUtils.CustomTextField(
                            label: "First Name",
                            showLabel: false,
                            controller: signupController.firstNameController.value,
                            prefixIcon: Icon(Icons.person, color: Color(0xFF6B707E)),
                            isName: true,
                            placeholder: "First Name",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                              signupController.isValidName.value = value.isNotEmpty && value.length >= 2;
                            }
                        ),

                        SizedBox(height: 20),

                        /// LAST NAME
                        GlobalUtils.CustomTextField(
                            label: "Last Name",
                            showLabel: false,
                            controller: signupController.lastNameController.value,
                            prefixIcon: Icon(Icons.person, color: Color(0xFF6B707E)),
                            isName: true,
                            placeholder: "Last Name",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /// EMAIL
                        GlobalUtils.CustomTextField(
                            label: "Email",
                            showLabel: false,
                            controller: signupController.emailController.value,
                            prefixIcon: Icon(Icons.email, color: Color(0xFF6B707E)),
                            isEmail: true,
                            placeholder: "Email",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                              signupController.isValidEmail.value = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                            }
                        ),

                        SizedBox(height: 20),

                        /// PHONE NUMBER
                        GlobalUtils.CustomTextField(
                            label: "Phone Number",
                            showLabel: false,
                            controller: signupController.mobileController.value,
                            prefixIcon: Icon(Icons.call, color: Color(0xFF6B707E)),
                            suffixIcon: Obx(() {
                              if (signupController.isMobileVerified.value) {
                                return Row(
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
                            ],);
                            /*Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      "Verified",
                                      style: GoogleFonts.albertSans(
                                        fontSize: GlobalUtils.screenWidth * (14 / 393),
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                  ],
                                );*/
                              } else {
                                return TextButton(
                                  onPressed: () async {
                                    String mobile = signupController.mobileController.value.text.trim();

                                    if (mobile.isEmpty || mobile.length != 10) {
                                      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
                                      return;
                                    }

                                    // Call the updated sendMobileOtp function
                                    await signupController.sendMobileOtp(context);
                                  },
                                  child: Text(
                                    "Verify",
                                    style: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      color: Color(0xFF0054D3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                            }),
                            isMobileNumber: true,
                            placeholder: "Phone Number",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                              signupController.isMobileNo.value = value.length == 10;
                            },
                            enabled: !signupController.isMobileVerified.value,
                            readOnly: signupController.isMobileVerified.value,
                        ),

                        SizedBox(height: 20),

                        /// GENDER DROPDOWN
                        Container(
                          height: GlobalUtils.screenWidth * (60 / 393),
                          width: GlobalUtils.screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: signupController.selectedGender.value.isEmpty
                                  ? null
                                  : signupController.selectedGender.value,
                              hint: Row(
                                children: [
                                  Icon(Icons.person_outline, color: Color(0xFF6B707E)),
                                  SizedBox(width: 12),
                                  Text(
                                    "Select Gender",
                                    style: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      color: Color(0xFF6B707E),
                                    ),
                                  ),
                                ],
                              ),
                              isExpanded: true,
                              dropdownColor: Color(0xFFDEEBFF),
                              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                              items: ['MALE', 'FEMALE', 'OTHER'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.albertSans(
                                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                                      color: Color(0xFF1B1C1C),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  signupController.selectedGender.value = newValue;
                                }
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        /// PERMANENT ADDRESS
                        GlobalUtils.CustomTextField(
                            label: "Permanent Address",
                            showLabel: false,
                            controller: signupController.permanentAddressController.value,
                            prefixIcon: Icon(Icons.home, color: Color(0xFF6B707E)),
                            placeholder: "Enter Permanent Address",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /// SHOP NAME
                        GlobalUtils.CustomTextField(
                            label: "Shop Name",
                            showLabel: false,
                            controller: signupController.shopNameController.value,
                            prefixIcon: Icon(Icons.store, color: Color(0xFF6B707E)),
                            placeholder: "Enter Shop Name",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /// PAN NUMBER
                        GlobalUtils.CustomTextField(
                            label: "PAN Number",
                            showLabel: false,
                            controller: signupController.panController.value,
                            prefixIcon: Icon(Icons.credit_card, color: Color(0xFF6B707E)),
                            placeholder: "Enter PAN Number",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /*/// AADHAR NUMBER - NEW FIELD FOR FUTURE
                        GlobalUtils.CustomTextField(
                            label: "Aadhar Number",
                            showLabel: false,
                            controller: signupController.aadharController.value,
                            prefixIcon: Icon(Icons.badge, color: Color(0xFF6B707E)),
                            isAadharNumber: true,
                            placeholder: "Enter 12-digit Aadhar Number",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            maxLength: 12,
                            onChanged: (value) {
                            }
                        ),

                        SizedBox(height: 20),*/

                        /// GSTIN NUMBER
                        GlobalUtils.CustomTextField(
                            label: "GSTIN Number",
                            showLabel: false,
                            controller: signupController.gstinController.value,
                            prefixIcon: Icon(Icons.document_scanner, color: Color(0xFF6B707E)),
                            placeholder: "Enter GSTIN Number (Optional)",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /// STATE DROPDOWN WITH SEARCH
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
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Color(0xFF6B707E)),
                                SizedBox(width: 12),
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

                        SizedBox(height: 20),

                        /// CITY DROPDOWN WITH SEARCH
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
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.location_city, color: Color(0xFF6B707E)),
                                SizedBox(width: 12),
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

                        SizedBox(height: 20),

                        /// PINCODE DROPDOWN WITH SEARCH
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
                              Fluttertoast.showToast(msg: "No pincodes available for selected city");
                              return;
                            }
                            showSearchableDropdown(
                              context,
                              'Select Pincode',
                              signupController.pincodeList,
                              signupController.selectedPincode,
                                  (value) {
                                signupController.selectedPincode.value = value;
                              },
                            );
                          },
                          child: Container(
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.pin_drop, color: Color(0xFF6B707E)),
                                SizedBox(width: 12),
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

                        SizedBox(height: 20),

                        /// SHOP ADDRESS
                        GlobalUtils.CustomTextField(
                            label: "Shop Address",
                            showLabel: false,
                            controller: signupController.shopAddressController.value,
                            prefixIcon: Icon(Icons.business, color: Color(0xFF6B707E)),
                            placeholder: "Enter Shop Address",
                            placeholderColor: Colors.white,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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
                            errorFontSize: 12
                        ),

                        SizedBox(height: 20),

                        /// TERMS & CONDITIONS CHECKBOX
                        Row(
                          children: [
                            Checkbox(
                              value: signupController.isChecked.value,
                              onChanged: (value) {
                                signupController.isChecked.value = value ?? false;
                              },
                              activeColor: Color(0xFF0054D3),
                              checkColor: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                "I agree to Terms & Conditions",
                                style: GoogleFonts.albertSans(
                                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                                  color: Color(0xFF6B707E),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        /// SIGN UP BUTTON
                        GlobalUtils.CustomButton(
                          text: "SIGN UP",
                          onPressed: () {
                            signupController.validateAndRegister(context);
                          },
                          textStyle: GoogleFonts.albertSans(
                            fontSize: GlobalUtils.screenWidth * (16 / 393),
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

                        SizedBox(height: GlobalUtils.screenWidth * 0.02),

                        /// ALREADY HAVE ACCOUNT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.albertSans(
                                color: Color(0xFF6B707E),
                                fontSize: GlobalUtils.screenWidth * (16 / 393),
                              ),
                            ),
                            GlobalUtils.CustomButton(
                              onPressed: () {
                                Get.to(LoginScreen());
                              },
                              buttonType: ButtonType.text,
                              text: "Sign in",
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              textStyle: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (16 / 393),
                                color: Color(0xFF0054D3),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: GlobalUtils.screenWidth * 0.05)
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
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
            // color: Colors.white,
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
                      style: TextStyle(
                        color: Colors.black, // This sets the input text color
                      ),
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
                        style: GoogleFonts.albertSans(
                          color: Color(0xFF6B707E),
                        ),
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
}



















// // import 'package:e_commerce_app/utils/global_utils.dart';
// // import 'package:e_commerce_app/view/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../api/web_api_constant.dart';
// import '../controllers/signup_controller.dart';
// import '../utils/global_utils.dart';
// import 'login_screen.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   SignupController signupController = Get.put(SignupController());
//
//   Widget buildCustomAppBar() {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: GlobalUtils.screenWidth * 0.04,
//       ),
//       child: Row(
//         children: [
//           /// BACK BUTTON
//           GestureDetector(
//             onTap: () => Get.back(),
//             child: Container(
//               height: GlobalUtils.screenHeight * (40 / 393),
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
//
//           /// TITLE
//           Text(
//             "Sign Up",
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
//               buildCustomAppBar(),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Obx(()=> SizedBox(
//                     width: GlobalUtils.screenWidth,
//                     height: GlobalUtils.screenHeight,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         /// SUBTITLE TEXT
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Text(
//                                 "Register Your Account",
//                                 style: GoogleFonts.albertSans(
//                                   fontSize: GlobalUtils.screenWidth * (24 / 393),
//                                   color: Color(0xFF0F0F0F),
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         SizedBox(height: GlobalUtils.screenHeight * 0.035,),
//
//                         GlobalUtils.CustomTextField(
//                             label: "First Name",
//                             showLabel: false,
//                             controller: signupController.firstNameController.value.obs(),
//                             prefixIcon: Icon(Icons.person, color: Color(0xFF6B707E)),
//                             isName: true,
//                             placeholder: "First Name",
//                             placeholderColor: Colors.white,
//                             height: GlobalUtils.screenWidth * (60 / 393),
//                             width: GlobalUtils.screenWidth*0.9,
//                             autoValidate: false,
//                             backgroundColor: Colors.white,
//                             borderRadius: 16,
//                             placeholderStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF6B707E),
//                             ),
//                             inputTextStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF1B1C1C),
//                             ),
//                             // backgroundGradient: LinearGradient(
//                             //   colors: [Colors.blueAccent, Colors.purple.shade300],
//                             // ),
//                             errorColor:  Colors.red,
//                             errorFontSize: 12
//                         ),
//
//                         SizedBox(height: 20,),
//
//                         GlobalUtils.CustomTextField(
//                             label: "Last Name",
//                             showLabel: false,
//                             controller: signupController.firstNameController.value.obs(),
//                             prefixIcon: Icon(Icons.person, color: Color(0xFF6B707E)),
//                             isName: true,
//                             placeholder: "Last Name",
//                             placeholderColor: Colors.white,
//                             height: GlobalUtils.screenWidth * (60 / 393),
//                             width: GlobalUtils.screenWidth*0.9,
//                             autoValidate: false,
//                             backgroundColor: Colors.white,
//                             borderRadius: 16,
//                             placeholderStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF6B707E),
//                             ),
//                             inputTextStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF1B1C1C),
//                             ),
//                             // backgroundGradient: LinearGradient(
//                             //   colors: [Colors.blueAccent, Colors.purple.shade300],
//                             // ),
//                             errorColor:  Colors.red,
//                             errorFontSize: 12
//                         ),
//
//                         SizedBox(height: 20,),
//
//                         GlobalUtils.CustomTextField(
//                             label: "Email",
//                             showLabel: false,
//                             controller: signupController.emailController.value.obs(),
//                             prefixIcon: Icon(Icons.email, color: Color(0xFF6B707E)),
//                             isEmail: true,
//                             placeholder: "Email",
//                             placeholderColor: Colors.white,
//                             height: GlobalUtils.screenWidth * (60 / 393),
//                             width: GlobalUtils.screenWidth*0.9,
//                             autoValidate: false,
//                             backgroundColor: Colors.white,
//                             borderRadius: 16,
//                             suffixIcon: /*Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                               Image.asset("assets/images/verified_icon.png",
//                               height: 20,
//                               ),
//                               SizedBox(width: 2,),
//                               Text("Verified", style: GoogleFonts.albertSans(
//                                 fontSize: GlobalUtils.screenWidth * (14 / 393),
//                                 color: Color(0xFF0054D3),
//                                 fontWeight: FontWeight.w500,
//                               ),),
//                               SizedBox(width: 12,),
//                             ],)*/TextButton(onPressed: (){}, child: Text("Verify", style: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF0054D3),
//                               fontWeight: FontWeight.w500,
//                             ))),
//                             placeholderStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF6B707E),
//                             ),
//                             inputTextStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF1B1C1C),
//                             ),
//                             // backgroundGradient: LinearGradient(
//                             //   colors: [Colors.blueAccent, Colors.purple.shade300],
//                             // ),
//                             errorColor:  Colors.red,
//                             errorFontSize: 12
//                         ),
//
//                         SizedBox(height: 20,),
//
//                         GlobalUtils.CustomTextField(
//                             label: "Phone Number",
//                             showLabel: false,
//                             controller: signupController.mobileController.value.obs(),
//                             prefixIcon: Icon(Icons.call, color: Color(0xFF6B707E)),/*Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(onPressed: (){},
//                                     icon: SizedBox(
//                                         height: GlobalUtils.screenHeight * (24 / 393),
//                                         width: GlobalUtils.screenWidth * (30 / 393),
//                                         child: Image.asset("assets/images/india_flag.png")),
//                                 ),
//                                 // SizedBox(width: 10,),
//                                 Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
//                               ],
//                             ),*/
//                             isMobileNumber: true,
//                             placeholder: "Phone Number",
//                             placeholderColor: Colors.white,
//                             height: GlobalUtils.screenWidth * (60 / 393),
//                             width: GlobalUtils.screenWidth*0.9,
//                             autoValidate: false,
//                             backgroundColor: Colors.white,
//                             borderRadius: 16,
//                             suffixIcon: /*Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                               Image.asset("assets/images/verified_icon.png",
//                               height: 20,
//                               ),
//                               SizedBox(width: 2,),
//                               Text("Verified", style: GoogleFonts.albertSans(
//                                 fontSize: GlobalUtils.screenWidth * (14 / 393),
//                                 color: Color(0xFF0054D3),
//                                 fontWeight: FontWeight.w500,
//                               ),),
//                               SizedBox(width: 12,),
//                             ],)*/TextButton(onPressed: (){}, child: Text("Verify", style: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF0054D3),
//                               fontWeight: FontWeight.w500,
//                             ))),
//                             placeholderStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF6B707E),
//                             ),
//                             inputTextStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (14 / 393),
//                               color: Color(0xFF1B1C1C),
//                             ),
//                             // backgroundGradient: LinearGradient(
//                             //   colors: [Colors.blueAccent, Colors.purple.shade300],
//                             // ),
//                             errorColor:  Colors.red,
//                             errorFontSize: 12
//                         ),
//
//                         SizedBox(height: 20),
//
// /*
//                         GlobalUtils.CustomTextField(
//                           label: "Password",
//                           showLabel: false,
//                           controller: signupController.passwordController.value.obs(),
//                           prefixIcon: Icon(Icons.password),
//                           isPassword: true,
//                           placeholder: "Please enter your password.",
//                           placeholderColor: Colors.white,
//                           height: GlobalUtils.screenHeight * 0.06,
//                           width: GlobalUtils.screenWidth * 0.9,
//                           autoValidate: false,
//                           backgroundGradient: LinearGradient(
//                             colors: [Colors.blueAccent, Colors.purple.shade300],
//                           ),
//                           errorColor:  Colors.red,
//                           errorFontSize: 12,
//                         ),
// */
//
//                         // SizedBox(
//                         //   height: GlobalUtils.screenWidth * 0.2,
//                         // ),
//
//                         Spacer(),
//
//                         GlobalUtils.CustomButton(
//                           text: "SIGN UP",
//                           onPressed: (){
//                             if(signupController.isValidName.value && signupController.isValidEmail.value && signupController.isMobileNo.value && signupController.isPassword.value){
//                               if(signupController.isChecked.value) {
//                                 print("log12sdf");
//                                 signupController.registerUser(context);
//                               }else{
//                                 Fluttertoast.showToast(msg: WebApiConstant.TermsConditionError);
//                               }
//                             }
//                           },
//                           textStyle: GoogleFonts.albertSans(
//                             fontSize: GlobalUtils.screenWidth * (16 / 393),
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           width: GlobalUtils.screenWidth * 0.9,
//                           height: GlobalUtils.screenWidth * (60 / 393),
//                           backgroundGradient: GlobalUtils.blueBtnGradientColor,
//                           // backgroundGradient: LinearGradient(
//                           //   colors: [Colors.blue, Colors.purple],
//                           // ),
//                           borderColor: Color(0xFF71A9FF),
//                           showShadow: false,
//                           textColor: Colors.white,
//                           animation: ButtonAnimation.fade,
//                           animationDuration: const Duration(milliseconds: 150),
//                           buttonType: ButtonType.elevated,
//                           borderRadius: 16,
//                         ),
//
//                         SizedBox(height: GlobalUtils.screenWidth * 0.02),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text("Already have an account?", style: GoogleFonts.albertSans(color: Color(0xFF6B707E),
//                               fontSize: GlobalUtils.screenWidth * (16 / 393),
//                             )),
//                             GlobalUtils.CustomButton(onPressed: (){Get.to(LoginScreen());}, buttonType: ButtonType.text, text: "Signin", padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5), textStyle: GoogleFonts.albertSans(
//                               fontSize: GlobalUtils.screenWidth * (16 / 393),
//                               color: Color(0xFF0054D3),
//                               fontWeight: FontWeight.w600,
//                             )/*textGradient: LinearGradient(colors: [Colors.purple, Colors.pink, Colors.orange],)*/)
//                           ],
//                         ),
//                         SizedBox(height: GlobalUtils.screenWidth * 0.05)
//                       ],
//                     ),
//                   ),),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
