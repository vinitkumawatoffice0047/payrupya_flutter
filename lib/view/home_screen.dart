// import 'package:e_commerce_app/controllers/home_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_screen_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/product_screen_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/global_utils.dart';
import '../utils/reusable_product_grid.dart';
import 'category_detail_screen.dart';
import 'edit_location_screen.dart';
import 'notification_screen.dart';

final ThemeController themeController = Get.put(ThemeController());
final CartController cartController = Get.put(CartController());
final HomeScreenController homeScreenController = Get.put(HomeScreenController());
final TextEditingController addressController = TextEditingController();
final TextEditingController pincodeController = TextEditingController();
final ProductScreenController productController = Get.put(ProductScreenController());
final NavigationController navController = Get.put(NavigationController());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final TextEditingController addressController = TextEditingController();
  // final TextEditingController pincodeController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // homeScreenController.getToken(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeScreenController.getToken(context);
      // cartController.getToken(context);
      // cartController.getCartList(context);
      // cartController.getOffer(context);
    });
    if (addressController.text == "" || pincodeController.text == ""){
      addressController.text = "Add address details!";
      cartController.currentAddress.value = addressController.value.text;
    }
    // पहले saved address load करें, फिर current location
    loadSavedAddressAndPinCode(context).then((_) {
      // अगर saved address नहीं है, तो ही current location fetch करें
      if (cartController.currentAddress.value.isEmpty || cartController.pinCode.value.isEmpty) {
        cartController.getCurrentAddress(context);
      }
    });
  }

  Future<void> loadSavedAddressAndPinCode(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var currentAddress = prefs.getString('current_selected_address') ?? '';
    var currentPincode = prefs.getString('current_selected_pincode') ?? '';

    ConsoleLog.printColor("Loading saved address: $currentAddress, pincode: $currentPincode");

    if (currentAddress.isNotEmpty && currentPincode.isNotEmpty) {
      cartController.currentAddress.value = currentAddress;
      cartController.pinCode.value = currentPincode;

      // यहाँ भी shared preferences में save करें ताकि बाद के लिए available रहे
      await prefs.setString('current_selected_address', currentAddress);
      await prefs.setString('current_selected_pincode', currentPincode);
    }
  }

  Future<void> loadLocationScreen(BuildContext context) async{
      // Edit Location Screen open karenge
      var result = await Get.to(() => EditLocationScreen(
        currentAddress: addressController.value.text,
        currentPincode: pincodeController.value.text,
        homeScreenAddressController: addressController,
        homeScreenPincodeController: pincodeController,
      ));

      // Agar user ne address save kiya hai
      if (result != null && result is Map<String, String>) {
        setState(() {
          cartController.currentAddress.value = result['address'] ?? '';
          cartController.pinCode.value = result['pincode'] ?? '';
          // Save the updated address to SharedPreferences
          AppSharedPreferences().setString(AppSharedPreferences.lastAddress, result['address'] ?? '');
          AppSharedPreferences().setString(AppSharedPreferences.lastPincode, result['pincode'] ?? '');
        });
        // SharedPreferences में save करें
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_selected_address', cartController.currentAddress.value);
        await prefs.setString('current_selected_pincode', cartController.pinCode.value);
        ConsoleLog.printColor("Address updated and saved: ${cartController.currentAddress.value}, ${cartController.pinCode.value}");
      }
  }

  @override
  Widget build(BuildContext context) {
    GlobalUtils.init(context);
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: festival != 'default' && festivalData != null
              ? LinearGradient(
            colors: festivalData['colors'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: GlobalUtils.getBackgroundColor(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Obx(()=>Column(
            children: [
              buildHeader(context, festival, festivalData, isDark, onLocationChanged: () async => await loadLocationScreen(context)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xff1a1a1a) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        buildSearchBar(isDark),
                        const SizedBox(height: 20),
                        buildDeliveryBanner(isDark, festival, festivalData),
                        const SizedBox(height: 25),
                        buildCategoriesSection(isDark),
                        const SizedBox(height: 25),
                        buildBannerSlider(isDark),
                        const SizedBox(height: 25),
                        buildProductsGrid(isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

  Widget buildHeader(BuildContext context, String festival, Map? festivalData, bool isDark, {
    required Future<void> Function() onLocationChanged,
  }) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text('Deliver to', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        await onLocationChanged();
                      },
                      child: SizedBox(
                        width: GlobalUtils.screenWidth * 0.5,
                        child: Text(
                          maxLines: 1,
                          cartController.currentAddress.value,
                          // 'Add Your Delivery Address!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: /*16*/GlobalUtils.screenWidth * 0.047,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // InkWell(child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                    // onTap: () async {await onLocationChanged();}
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (festival != 'default' && festivalData != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(festivalData['icon'] as String, style: const TextStyle(fontSize: 24)),
            ),
          const SizedBox(width: 10),
          InkWell(
            onTap: ()=> Get.to(const NotificationsScreen()),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlobalUtils.CustomButton(
        onPressed: () {
          navController.selectedIndex.value = 2;
        }/*=> Get.offAll(() => MainScreen(selectedIndex: 2),*//* transition: Transition.fadeIn*//*)*/,
        height: 55,
        backgroundColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
        borderRadius: 15,
        showBorder: false,
        showShadow: true,
        shadowBlurRadius: 10,
        shadowColor: Colors.black.withOpacity(0.05),
        animation: ButtonAnimation.scale,
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xff80a8ff)),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                'Search for products...',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            // Icon(Icons.mic, color: Color(0xff80a8ff)),
          ],
        ),
      ),
    );
  }

  Widget buildDeliveryBanner(bool isDark, String festival, Map? festivalData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: festival != 'default' && festivalData != null
              ? LinearGradient(colors: festivalData['colors'] as List<Color>)
              : const LinearGradient(colors: [Color(0xff80a8ff), Color(0xff5e60ce)]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff80a8ff).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.yellow, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival != 'default' && festivalData != null
                        ? festivalData['name'] as String
                        : 'Delivery in 10 minutes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '0.2 kms away',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesSection(bool isDark) {
    // final categories = themeController.categoryThemes.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              GlobalUtils.CustomButton(
                onPressed: () => Get.find<NavigationController>().changeIndex(1),
                text: 'See All',
                textColor: const Color(0xff80a8ff),
                backgroundColor: Colors.transparent,
                showBorder: false,
                showShadow: false,
                animation: ButtonAnimation.scale,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: Obx(() {
            if (homeScreenController.isLoading.value) {
              return const Center(child: CircularProgressIndicator()); // ⏳
            } else if (homeScreenController.errorMessage.isNotEmpty) {
              return const SizedBox(); // 👈 Empty box instead of red text
            } else {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // itemCount: categories.length,
                itemCount: 7,
                itemBuilder: (context, index) {
                  // final category = categories[index];
                  // final categoryData = themeController.categoryThemes[category]!;
                  // final categoryData = themeController.getCategoryTheme(
                  //   widget.categoryName ?? 'Default',
                  //   index: int.tryParse(widget.categoryId ?? '0'),
                  // );

                  return GlobalUtils.CustomButton(
                    onPressed: () {
                        Get.to(() => CategoryDetailScreen(categoryName: homeScreenController.category[index].title, categoryImage: homeScreenController.category[index].image, categoryId: homeScreenController.category[index].category_id,));
                        productController.getToken(context, int.parse(homeScreenController.category[index].category_id.toString()));
                      },
                    width: 85,
                    backgroundColor: Colors.transparent,
                    showBorder: false,
                    showShadow: false,
                    animation: ButtonAnimation.scale,
                    padding: EdgeInsets.zero,
                    child: Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              // gradient: LinearGradient(
                              //   colors: categoryData['colors'] as List<Color>,
                              // ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  // color: (categoryData['colors'] as List<Color>)[0].withOpacity(0.3),
                                  // color: isDarkMode : Colors.white.withAlpha(100),
                                  color: isDark ? Colors.white.withAlpha(100) : Colors.grey.withAlpha(100),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              child: Image.network(homeScreenController.category[index].image.toString()),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            homeScreenController.category[index].title.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
        ),
      ],
    );
  }

  Widget buildBannerSlider(bool isDark) {
    // final offers = [
    //   {'discount': '15', 'title': 'Special Offer', 'subtitle': 'On all groceries'},
    //   {'discount': '30', 'title': 'Mega Sale', 'subtitle': 'Electronics & Fashion'},
    //   {'discount': '45', 'title': 'Super Deal', 'subtitle': 'Limited time only'},
    // ];
    final offers = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Top Offers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // itemCount: offers.length,
            itemCount: homeScreenController.banner.length,
            itemBuilder: (context, index) {
              return Obx(()=> Row(
                children: [
                  GlobalUtils.CustomButton(
                    onPressed: () {},
                    width: 300,
                    backgroundGradient: const LinearGradient(
                      colors: [Color(0xffffabab), Color(0xffff6b6b)],
                    ),
                    borderRadius: 20,
                    showBorder: false,
                    animation: ButtonAnimation.scale,
                    padding: EdgeInsets.zero,
                    child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.network(homeScreenController.banner[index].image.toString(), width: GlobalUtils.screenWidth, height: GlobalUtils.screenHeight, fit: BoxFit.fill,),),
                  ),
                  SizedBox(width: index == offers.length - 1 ? 0 : 10,)
                ],
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget buildProductsGrid(bool isDark) {
    // final products = List.generate(
    //   homeScreenController.topSellProduct.length,
    //       (index) => {
    //     'product_id': '${homeScreenController.topSellProduct[index].product_id}',
    //     'stock': '${homeScreenController.topSellProduct[index].stock}',
    //     'name': '${homeScreenController.topSellProduct[index].title}',
    //     'short_discription': '${homeScreenController.topSellProduct[index].shortDiscription}',
    //     'discPrice': homeScreenController.topSellProduct[index].discPrice,
    //     'price': homeScreenController.topSellProduct[index].price,
    //     'image': homeScreenController.topSellProduct[index].image.toString(),
    //   },
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Popular Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // 🎯 REUSABLE WIDGET KA USAGE
        ReusableProductGrid(
          products: homeScreenController.topSellProduct,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          crossAxisCount: 2,
          childAspectRatio: 0.50,
        ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: GridView.builder(
        //     // Restricts the GridView's height to its children and prevents scrolling
        //     shrinkWrap: true,
        //     physics: const NeverScrollableScrollPhysics(),
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 2,
        //       crossAxisSpacing: 15, // Horizontal spacing
        //       mainAxisSpacing: 15,  // Vertical spacing
        //       childAspectRatio: 0.53, // Defines the base aspect ratio for items
        //     ),
        //     itemCount: /*products.length*/homeScreenController.topSellProduct.length,
        //     itemBuilder: (context, index) {
        //       // final product = /*products[index]*/productController.product[index];
        //       final product = homeScreenController.topSellProduct[index];
        //       // IntrinsicHeight ensures that all grid items in a row share the height
        //       // of the tallest item, even with dynamic content.
        //       return IntrinsicHeight(
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: isDark ? const Color(0xff2a2a2a) : Colors.white,
        //             borderRadius: BorderRadius.circular(15),
        //             border: Border.all(
        //               color: isDark
        //                   ? const Color(0xff3a3a3a)
        //                   : const Color(0xfff0f0f0),
        //             ),
        //             boxShadow: [
        //               BoxShadow(
        //                 color: Colors.black.withOpacity(0.05),
        //                 blurRadius: 10,
        //                 offset: const Offset(0, 5),
        //               ),
        //             ],
        //           ),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               // --- Fixed Image Section ---
        //               Container(
        //                 height: 125, // Fixed height for the image
        //                 width: double.infinity,
        //                 decoration: const BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: BorderRadius.only(
        //                     topLeft: Radius.circular(15),
        //                     topRight: Radius.circular(15),
        //                   ),
        //                 ),
        //                 padding: const EdgeInsets.all(20),
        //                 // child: Image.network(
        //                 //   product['image'] as String,
        //                 //   fit: BoxFit.contain,
        //                 // ),
        //
        //
        //                 // child: Center(
        //                 //   // child: Icon(product['image'] as IconData, size: 50, color: Colors.grey)
        //                 //   child: homeScreenController.topSellProduct[index].images!.isNotEmpty ? Image.network(homeScreenController.topSellProduct[index].images!.first.toString(), fit: BoxFit.contain) : Image.asset("assets/images/noImageIcon.png"),
        //                 // ),
        //                 child: Center(
        //                   child: product.images!.isNotEmpty
        //                       ? Image.network(product.images!.first.toString(), fit: BoxFit.contain)
        //                       : Image.asset("assets/images/noImageIcon.png"),
        //                 ),
        //               ),
        //
        //               // --- Flexible Content Section ---
        //               // Expanded ensures the content takes up the remaining vertical space
        //               Flexible(
        //                 fit: FlexFit.loose,
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(10),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     mainAxisSize: MainAxisSize.min,
        //                     children: [
        //                       // Product Name
        //                       Text(
        //                         // homeScreenController.topSellProduct[index].title.toString(),
        //                         product.title.toString(),
        //                         /*product['name'] as String,*/
        //                         style: TextStyle(
        //                           fontWeight: FontWeight.bold,
        //                           fontSize: 14,
        //                           color: isDark ? Colors.white : Colors.black87,
        //                         ),
        //                         maxLines: 2,
        //                         overflow: TextOverflow.ellipsis,
        //                       ),
        //                       const SizedBox(height: 5),
        //
        //                       // Product Description
        //                       Text(
        //                         // homeScreenController.topSellProduct[index].slug.toString(),
        //                         product.discription.toString(),
        //                         /*product['short_discription'] as String,*/
        //                         style: const TextStyle(
        //                             color: Colors.grey, fontSize: 12),
        //                         maxLines: 3,
        //                         overflow: TextOverflow.ellipsis,
        //                       ),
        //
        //                       // Spacer pushes the price and button to the bottom
        //                       const Spacer(),
        //
        //                       // Price and Add Button
        //                       Column(
        //                         children: [
        //                           Row(
        //                             children: [
        //                               Text(
        //                                 // '₹${product['discPrice']}',
        //                                 // '₹${/*product['discPrice']*/homeScreenController.topSellProduct[index].discPrice.toString()}',
        //                                 '₹${product.discPrice.toString()}',
        //                                 style: const TextStyle(
        //                                   fontWeight: FontWeight.bold,
        //                                   fontSize: 20,
        //                                   color: Color(0xff80a8ff), // Accent color
        //                                 ),
        //                               ),
        //                               const SizedBox(width: 5),
        //                               Text(
        //                                 // '₹${product['price']}',
        //                                 // '₹${/*product['price']*/homeScreenController.topSellProduct[index].price.toString()}',
        //                                 '₹${product.price.toString()}',
        //                                 style: const TextStyle(
        //                                   fontWeight: FontWeight.bold,
        //                                   fontSize: 16,
        //                                   color: Color(0xff80a8ff), // Accent color
        //                                   decoration: TextDecoration.lineThrough,
        //                                   decorationColor: Colors.red,
        //                                   decorationThickness: 2,
        //                                 ),
        //                               ),
        //                               // const Spacer(),
        //
        //                             ],
        //                           ),
        //                           Obx((){
        //                             // final _ = cartController.cartItems.length;
        //                             // // final productId = product['product_id'] as String;
        //                             // final productId = /*product['product_id'] as String*/homeScreenController.topSellProduct[index].product_id;
        //                             // // final quantity = cartController.getProductQuantity(productId);
        //                             // final quantity = cartController.getProductQuantity(productId.toString());
        //                             // final isInCart = quantity > 0;
        //                             final _ = cartController.cartItems.length;
        //                             final productId = product.product_id.toString();
        //                             final quantity = cartController.getProductQuantity(productId);
        //                             final isInCart = quantity > 0;
        //                             return isInCart
        //                                 ? Container(
        //                               width: GlobalUtils.screenWidth,
        //                               height: 40,
        //                               decoration: BoxDecoration(
        //                                 color: Color(0xff80a8ff).withOpacity(0.1),
        //                                 borderRadius: BorderRadius.circular(10),
        //                               ),
        //                               child: Row(
        //                                 // mainAxisSize: MainAxisSize.min,
        //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   GlobalUtils.CustomButton(
        //                                     onPressed: () {
        //                                       cartController.updateQuantity(
        //                                         // product['product_id'] as String,
        //                                         /*product['product_id'] as String*/productId,
        //                                         quantity - 1,
        //                                       );
        //                                     },
        //                                     icon: Icon(Icons.remove, size: 25),
        //                                     iconColor: Color(0xff80a8ff),
        //                                     backgroundColor: Colors.transparent,
        //                                     showBorder: false,
        //                                     showShadow: false,
        //                                     animation: ButtonAnimation.scale,
        //                                     padding: EdgeInsets.all(4),
        //                                   ),
        //                                   Container(
        //                                     // constraints: BoxConstraints(minWidth: 20),
        //                                     padding: EdgeInsets.symmetric(horizontal: 6),
        //                                     child: Text(
        //                                       '$quantity',
        //                                       style: TextStyle(
        //                                         fontWeight: FontWeight.bold,
        //                                         fontSize: 16,
        //                                         color: isDark ? Colors.white : Colors.black87,
        //                                       ),
        //                                     ),
        //                                   ),
        //                                   GlobalUtils.CustomButton(
        //                                     onPressed: () {
        //                                       cartController.updateQuantity(
        //                                         /*product['product_id'] as String*/productId,
        //                                         // product['product_id'] as String,
        //                                         quantity + 1,
        //                                       );
        //                                     },
        //                                     icon: Icon(Icons.add, size: 25),
        //                                     iconColor: Color(0xff80a8ff),
        //                                     backgroundColor: Colors.transparent,
        //                                     showBorder: false,
        //                                     showShadow: false,
        //                                     animation: ButtonAnimation.scale,
        //                                     padding: EdgeInsets.all(8),
        //                                   ),
        //                                 ],
        //                               ),
        //                             ) : GlobalUtils.CustomButton(
        //                               height: 40,
        //                               // onPressed: () => cartController.addToCart(product),
        //
        //                               // onPressed: () => cartController.addToCart(/*product*/homeScreenController.topSellProduct[index].toJson()),
        //                               onPressed: () {
        //                                 // ProductItem create karo API response se
        //                                 final cartItem = ProductItem(
        //                                   productId: product.product_id.toString(),
        //                                   image: product.images!.isNotEmpty ? product.images!.first : '',
        //                                   title: product.title ?? '',
        //                                   discription: product.discription ?? '',
        //                                   price: product.price ?? 0,
        //                                   sellPrice: product.discPrice ?? 0,
        //                                   qty: 1,
        //                                 );
        //                                 cartController.addToCart(cartItem);
        //                               },
        //                                 // onPressed: (){},
        //                               icon: const Icon(Icons.add, size: 25),
        //                               iconColor: Colors.white,
        //                               backgroundColor: const Color(0xff80a8ff),
        //                               borderRadius: 8,
        //                               padding: const EdgeInsets.all(6),
        //                               showBorder: false,
        //                               animation: ButtonAnimation.scale,
        //                             );
        //                           }),
        //                         ],
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
    ],
    );
  }

class Abc extends StatelessWidget {
  const Abc({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
