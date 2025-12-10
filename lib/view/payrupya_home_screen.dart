import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/dmt_wallet_controller.dart';
import 'package:payrupya/view/add_sender_screen.dart';
import 'package:payrupya/controllers/login_controller.dart';
import 'package:payrupya/view/otp_verification_screen.dart';
import 'dart:async';

import 'package:payrupya/view/wallet_screen.dart';

import '../utils/ConsoleLog.dart';

class PayrupyaHomeScreen extends StatefulWidget {
  const PayrupyaHomeScreen({super.key});

  @override
  State<PayrupyaHomeScreen> createState() => _PayrupyaHomeScreenState();
}

class _PayrupyaHomeScreenState extends State<PayrupyaHomeScreen> {
  String balance = "21,500.00";
  String location = "Jaipur, Rajasthan";
  String coordinates = "26.912434, 75.787270";

  final List<String> _promoImages = [
    "assets/images/banner.png",
    "assets/images/banner.png", // Aap yahaan alag-alag image paths daal sakte hain
    "assets/images/banner.png",
  ];
  late PageController pageController;
  Timer? timer;

  final List<Map<String, dynamic>> quickLinks = [
    {'img': 'assets/icons/dmtkyc.png', 'label': 'DMT KYC'},
    {'img': 'assets/icons/wallet.png', 'label': 'Payrupya\nWallet'},
    {'img': 'assets/icons/upi.png', 'label': 'Payrupya\nUPI'},
    {'img': 'assets/icons/nepal.png', 'label': 'Indo Nepal\nDMT'},
    {'img': 'assets/icons/paybills.png', 'label': 'Pay Bills'},
    {'img': 'assets/icons/offline.png', 'label': 'Offline\nBills'},
    {'img': 'assets/icons/aeps.png', 'label': 'AEPS'},
    {'img': 'assets/icons/card.png', 'label': 'Credit Card\nBill'},
    {'img': 'assets/icons/cms.png', 'label': 'CMS'},
  ];

  final List<Map<String, dynamic>> downBanks = [
    {'name': 'State Bank Of India', 'time': '2 hrs', 'img': 'assets/images/sbi_logo.png'},
    {'name': 'Union Bank', 'time': '2 hrs', 'img': 'assets/images/union_logo.png'},
  ];

  bool isServiceLoading = true;
  bool isServiceLoaded = false;

  DmtWalletController dmtController = Get.put(DmtWalletController());
  final LoginController loginController = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   dmtController.getAllowedServiceByType(context);
    // });
    _initialize();
  }

  Future<void> _initialize() async {
    pageController = PageController(
      viewportFraction: 1,
      initialPage: _promoImages.length * 1000,
    );
    startAutoScroll();

    // ✅ Better way to check location
    if (loginController.latitude.value != 0.0 &&
        loginController.longitude.value != 0.0) {

      ConsoleLog.printInfo("Location available, loading services...");
      await _loadServices();
    } else {
      ConsoleLog.printWarning("Location not available yet");
      isServiceLoading = false;
    }
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        isServiceLoading = true;
      });

      // ✅ Wait for service to load
      // await dmtController.getAllowedServiceByType(context);

      // ✅ Check if service code was loaded
      if (dmtController.serviceCode.value.isNotEmpty) {
        setState(() {
          isServiceLoaded = true;
          isServiceLoading = false;
        });
        ConsoleLog.printSuccess("Service loaded successfully: ${dmtController.serviceCode.value}");
      } else {
        setState(() {
          isServiceLoaded = false;
          isServiceLoading = false;
        });
        ConsoleLog.printWarning("Service code empty after loading");
      }
    } catch (e) {
      setState(() {
        isServiceLoading = false;
      });
      ConsoleLog.printError("Failed to load services: $e");
    }
  }


  void startAutoScroll() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E5BFF), Color(0xFF5E92F3)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            buildHeader(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      buildQuickLinks(),
                      SizedBox(height: 20),
                      buildPromoBanner(),
                      SizedBox(height: 20),
                      buildDownBanks(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            coordinates,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  buildHeaderIcon("assets/icons/qr_scanner.png", () {}),
                  SizedBox(width: 12),
                  buildHeaderIcon("assets/icons/notification_bell.png", () {}),
                  SizedBox(width: 12),
                  buildHeaderIcon("assets/icons/menu_icon.png", () {}),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          buildBalanceCard(),
        ],
      ),
    );
  }

  Widget buildHeaderIcon(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Image.asset(imagePath, width: 22, height: 22, color: Colors.white),
      ),
    );
  }

  Widget buildBalanceCard() {
    return Stack(
      children: [
        Image.asset("assets/images/balance_cards.png"),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          // decoration: BoxDecoration(
          //   color: Colors.black.withOpacity(0.4),
          //   borderRadius: BorderRadius.circular(20),
          //   border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        // child: Icon(Icons.refresh, color: Colors.white, size: 18),
                        child: Image.asset("assets/icons/refresh_icon.png", height: 18, width: 18,),
                      ),
                    ],
                  ),
                  // Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Add Money',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Spacer(),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // SizedBox(height: 5),
              Text(
                "₹$balance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick Links :',
            style: GoogleFonts.albertSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: quickLinks.length,
            itemBuilder: (context, index) {
              final item = quickLinks[index];
              return GestureDetector(
                onTap: () {
                  if(item['label'] == "Payrupya\nWallet"){
                    // Get.to(WalletScreen(showBackButton: true));
                    Get.to(AddSenderScreen(showBackButton: true));
                  }else if(item['label'] == "DMT KYC"){
                    Get.to(OtpVerificationScreen(phoneNumber: "1234567890", referenceId: "referenceId"));
                  }
                  print('Tapped on ${item['label']}');
                  },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Image.asset(item['img'], fit: BoxFit.contain),
                      ),
                    ),
                    SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        item['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPromoBanner() {
    return Container(
      height: 125,
      padding: EdgeInsets.symmetric(horizontal: 20), // Add padding only at sides
      child: ClipRRect( // Outer ClipRRect for curved edges
        borderRadius: BorderRadius.circular(15),
        child: PageView.builder(
          controller: pageController,
          itemBuilder: (context, index) {
            final imageIndex = index % _promoImages.length;
            return Image.asset(
              _promoImages[imageIndex],
              fit: BoxFit.fill,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }
  // Widget buildPromoBanner() {
  //   return SizedBox(
  //     height: 150, // Aap apne banner ki height ke hisab se adjust kar sakte hain
  //     // width: GlobalUtils.screenWidth,
  //     child: PageView.builder(
  //       controller: _pageController,
  //       // itemCount anant scroll ke liye null rakha ja sakta hai
  //       itemBuilder: (context, index) {
  //         final imageIndex = index % _promoImages.length;
  //         return AnimatedBuilder(
  //           animation: _pageController,
  //           builder: (context, child) {
  //             double value = 1.0;
  //             if (_pageController.position.haveDimensions) {
  //               value = (_pageController.page! - index);
  //               value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
  //             }
  //             return Center(
  //               child: SizedBox(
  //                 // height: Curves.easeOut.transform(value) * 150,
  //                 child: child,
  //               ),
  //             );
  //           },
  //           child: Container(
  //             width: double.infinity,
  //             margin: EdgeInsets.symmetric(horizontal: 8),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(15),
  //               child: Image.asset(_promoImages[imageIndex], fit: BoxFit.fill),
  //             ),
  //           ),
  //         );
  //       },
  //     ));
  // }

  Widget buildDownBanks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Down Banks :',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: downBanks.length,
          itemBuilder: (context, index) {
            final bank = downBanks[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      bank['img'],
                      width: 28,
                      height: 28,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      bank['name'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bank['time'],
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}