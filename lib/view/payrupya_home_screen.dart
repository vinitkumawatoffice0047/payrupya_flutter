import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/dmt_wallet_controller.dart';
import 'package:payrupya/controllers/payrupya_home_screen_controller.dart';
import 'package:payrupya/view/add_sender_screen.dart';
import 'package:payrupya/controllers/login_controller.dart';
import 'package:payrupya/view/aeps_one_screen.dart';
import 'package:payrupya/view/aeps_three_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'dart:async';
import '../main.dart';
import '../utils/custom_loading.dart';
import 'add_sender_upi_screen.dart';

class PayrupyaHomeScreen extends StatefulWidget {
  const PayrupyaHomeScreen({super.key});

  @override
  State<PayrupyaHomeScreen> createState() => _PayrupyaHomeScreenState();
}

class _PayrupyaHomeScreenState extends State<PayrupyaHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController refreshController;
  String location = "Jaipur, Rajasthan";
  String coordinates = "26.912434, 75.787270";

  final List<String> promoImages = [
    "assets/images/banner.png",
    "assets/images/banner.png", // yahaan alag-alag image paths daal sakte hain
    "assets/images/banner.png",
  ];
  late PageController pageController;
  Timer? timer;

  final List<Map<String, dynamic>> quickLinks = [
    {'img': 'assets/icons/dmtkyc.png', 'label': 'DMT KYC'},
    {'img': 'assets/icons/wallet.png', 'label': 'Payrupya\nWallet'},
    {'img': 'assets/icons/upi.png', 'label': 'Payrupya\nUPI'},
    {'img': 'assets/icons/aeps.png', 'label': 'AEPS One'},
    {'img': 'assets/icons/aeps.png', 'label': 'AEPS Three'},
    {'img': 'assets/icons/nepal.png', 'label': 'Indo Nepal\nDMT'},
    {'img': 'assets/icons/paybills.png', 'label': 'Pay Bills'},
    {'img': 'assets/icons/offline.png', 'label': 'Offline\nBills'},
    // {'img': 'assets/icons/aeps.png', 'label': 'AEPS'},
    {'img': 'assets/icons/card.png', 'label': 'Credit Card\nBill'},
    {'img': 'assets/icons/cms.png', 'label': 'CMS'},
  ];

  // ✅ List of labels that should remain ACTIVE
  final List<String> activeLabels = [
    'Payrupya\nWallet',
    'Payrupya\nUPI',
    'AEPS One',
    'AEPS Three'
  ];

  final List<Map<String, dynamic>> downBanks = [
    {'name': 'State Bank Of India', 'time': '2 hrs', 'img': 'assets/images/sbi_logo.png'},
    {'name': 'Union Bank', 'time': '2 hrs', 'img': 'assets/images/union_logo.png'},
  ];

  bool _isInitialLoading = true;
  // bool isServiceLoading = true;
  // bool isServiceLoaded = false;

  DmtWalletController get dmtController => Get.find<DmtWalletController>();
  LoginController get loginController => Get.find<LoginController>();
  PayrupyaHomeScreenController get payrupyaHomeScreenController => Get.find<PayrupyaHomeScreenController>();

  @override
  void initState() {
    super.initState();
    refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // smooth 360°
    );

    // Initialize page controller pehle
    pageController = PageController(
      viewportFraction: 1,
      initialPage: promoImages.length * 1000,
    );
    startAutoScroll();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });
  }

  /// Initialize data after widget is built
  Future<void> initializeData() async {
    try {
      // Show custom loading overlay
      CustomLoading.showLoading();

      // Show loading state
      setState(() {
        _isInitialLoading = true;
      });

      // Load wallet balance and services
      await payrupyaHomeScreenController.initializeHomeScreen();

    } catch (e) {
      debugPrint('Error initializing data: $e');
      CustomLoading.hideLoading();
      setState(() {
        _isInitialLoading = false;
      });
    } finally {
      // Hide loading state after a small delay to ensure smooth UX
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        CustomLoading.hideLoading();
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  void startAutoScroll() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // Check if pageController has clients before using
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff80a8ff),
      body: Stack(
        children: [
          Container(
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
          // // ✅ NEW: Full screen loading overlay
          // if (_isInitialLoading)
          //   Container(
          //     color: Colors.black.withOpacity(0.4),
          //     child: Center(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           CircularProgressIndicator(
          //             color: Colors.white,
          //             strokeWidth: 3,
          //           ),
          //           SizedBox(height: 16),
          //           Text(
          //             'Loading...',
          //             style: GoogleFonts.albertSans(
          //               fontSize: 14,
          //               color: Colors.grey[700],
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
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
                    onTap: () {
                      payrupyaHomeScreenController.getLocationAndLoadData();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(()=> Text(
                            payrupyaHomeScreenController.currentAddress.value,
                            // location,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Obx(()=> Text(
                                "${payrupyaHomeScreenController.latitude.value/*.toStringAsFixed(4)*/}, ${payrupyaHomeScreenController.longitude.value/*.toStringAsFixed(4)*/}",
                                // coordinates,
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
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
                    buildHeaderIcon("assets/icons/qr_scanner.png", () {}, isActive: false),
                    SizedBox(width: 12),
                    buildHeaderIcon("assets/icons/notification_bell.png", () {}, isActive: false),
                    SizedBox(width: 12),
                    buildHeaderIcon("assets/icons/menu_icon.png", () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TalkerScreen(talker: talker),
                        ),
                      );
                    }, isActive: true),
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

  Widget buildHeaderIcon(String imagePath, VoidCallback onTap, {bool isActive = true}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5, // Dim if inactive
      child: GestureDetector(
        onTap: isActive && !_isInitialLoading ? onTap : null,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Image.asset(imagePath, width: 22, height: 22, color: Colors.white),
        ),
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
                      Material(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: _isInitialLoading ? null : () { // ✅ Disable during loading
                            refreshController.forward(from: 0);
                            payrupyaHomeScreenController.getWalletBalance();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(refreshController),
                              child: Image.asset(
                                "assets/icons/refresh_icon.png",
                                height: 18,
                                width: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Container(
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
                  ),
                ],
              ),
              SizedBox(height: 30),
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
                "₹${payrupyaHomeScreenController.walletBalance.value}",
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
              // ✅ Logic to check if button should be Active or Inactive
              bool isActive = activeLabels.contains(item['label']);
              return GestureDetector(
                onTap: (isActive && !_isInitialLoading) ? () { // ✅ Disable during loading & isActive state
                  switch (item['label']) {
                    case "Payrupya\nWallet":
                      Get.to(() => AddSenderScreen(showBackButton: true));
                      break;
                    case "Payrupya\nUPI":
                      Get.to(() => AddSenderUPIScreen(showBackButton: true));
                      break;
                    case "AEPS One":
                      Get.to(() => AepsOneScreen(showBackButton: true));
                      break;
                    case "AEPS Three":
                      Get.to(() => AepsThreeScreen(showBackButton: true));
                      break;
                  }
                  print('Tapped on ${item['label']}');
                }: () {
                  // Optional: Show message for inactive buttons
                  Fluttertoast.showToast(msg: "Coming Soon");
                },
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.4, // ✅ Dim inactive items
                  // opacity: _isInitialLoading ? 0.5 : 1.0, // ✅ Dim during loading
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPromoBanner() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        height: 125,
        padding: EdgeInsets.symmetric(horizontal: 20), // Add padding only at sides
        child: ClipRRect( // Outer ClipRRect for curved edges
          borderRadius: BorderRadius.circular(15),
          child: PageView.builder(
            controller: pageController,
            itemBuilder: (context, index) {
              final imageIndex = index % promoImages.length;
              return Image.asset(
                promoImages[imageIndex],
                fit: BoxFit.fill,
                width: double.infinity,
              );
            },
          ),
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
              // ✅ View All button Inactive/Dimmed
              Opacity(
                opacity: 0.5,
                child: TextButton(
                  onPressed: null, // Disabled
                  // onPressed: _isInitialLoading ? null : () {}, // ✅ Disable during loading
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
            return Opacity(
              opacity: 0.5,
              child: Container(
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
    refreshController.dispose();
    CustomLoading.hideLoading();
    super.dispose();
  }
}