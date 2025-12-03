import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_screen_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/global_utils.dart';
import '../utils/reusable_product_grid.dart';

final CartController cartController = Get.put(CartController());

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.slug, this.qty});
  final String? slug;
  final int? qty;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ThemeController themeController = Get.put(ThemeController());

  AddToCartScreenController productCtrl = Get.put(AddToCartScreenController());
  @override
  void initState() {
    // productCtrl.getToken(context, widget.slug.toString());
    // TODO: implement initState
    super.initState();
    // productCtrl.getToken(context, widget.slug.toString());
  }

  @override
  Widget build(BuildContext context) {
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: isDark ? Color(0xff1a1a1a) : Colors.white,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),),
        flexibleSpace: Container(
          height: GlobalUtils.screenHeight,
          width: GlobalUtils.screenWidth,
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
        ),
        automaticallyImplyLeading: false,
        // elevation: 0,
        actions: [
          Obx(() => cartController.cartItems.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.delete_outline, color: GlobalUtils.globalLightIconColor,),
            onPressed: () {
              Get.defaultDialog(
                backgroundColor: isDark ? Color(0xff2a2a2a) : Colors.white,
                title: 'Clear Cart',
                middleText: 'Are you sure you want to clear your cart?',
                textConfirm: 'Yes',
                textCancel: 'No',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  cartController.clearCart();
                  Get.back();
                },
              );
            },
          ) : SizedBox()),
        ],
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: GlobalUtils.screenHeight * 0.25),
                Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'Your cart is empty!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text('Add items to get started', style: TextStyle(color: Colors.grey)),
                SizedBox(height: GlobalUtils.screenHeight * 0.2),
                GlobalUtils.CustomButton(
                  width: GlobalUtils.screenWidth * 0.9,
                  onPressed: () => Get.find<NavigationController>().changeIndex(0),
                  text: 'Start Shopping',
                  textColor: Colors.white,
                  backgroundColor: Color(0xff80a8ff),
                  borderRadius: 15,
                  animation: ButtonAnimation.scale,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ReusableCartList(
                cartItems: cartController.cartItems,
                padding: EdgeInsets.all(20),
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     padding: EdgeInsets.all(20),
            //     itemCount: cartController.cartItems.length,
            //     itemBuilder: (context, index) {
            //       final item = cartController.cartItems[index];
            //       return Container(
            //         margin: EdgeInsets.only(bottom: 15),
            //         padding: EdgeInsets.all(12),
            //         decoration: BoxDecoration(
            //           color: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               width: 70,
            //               height: 70,
            //               decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(12),
            //               ),
            //               // child: Image.network(item['image'] as String, fit: BoxFit.contain),
            //               child: Image.network(
            //                 item.image,
            //                 fit: BoxFit.contain,
            //                 errorBuilder: (context, error, stackTrace) {
            //                   return Icon(Icons.image, size: 35, color: Colors.grey);
            //                 },
            //               ),
            //             ),
            //             SizedBox(width: 15),
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     // item['name'] as String,
            //                     item.title,
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 16,
            //                       color: isDark ? Colors.white : Colors.black87,
            //                     ),
            //                   ),
            //                   SizedBox(height: 5),
            //                   Text(
            //                     // item['short_discription'] as String,
            //                     item.discription,
            //                     style: TextStyle(color: Colors.grey, fontSize: 12),
            //                   ),
            //                   SizedBox(height: 5),
            //                   Text(
            //                     // '₹${item['price']}',
            //                     '₹${item.sellPrice}',
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 16,
            //                       color: Color(0xff80a8ff),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             Container(
            //               decoration: BoxDecoration(
            //                 color: Color(0xff80a8ff).withOpacity(0.1),
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Row(
            //                 children: [
            //                   GlobalUtils.CustomButton(
            //                     onPressed: () {
            //                       cartController.updateQuantity(
            //                         // item['product_id'] as String,
            //                         // item['stock'] - 1,
            //                         item.productId,
            //                         item.qty - 1,
            //                       );
            //                     },
            //                     icon: Icon(Icons.remove),
            //                     iconColor: Color(0xff80a8ff),
            //                     backgroundColor: Colors.transparent,
            //                     showBorder: false,
            //                     showShadow: false,
            //                     animation: ButtonAnimation.scale,
            //                     padding: EdgeInsets.all(8),
            //                   ),
            //                   Container(
            //                     padding: EdgeInsets.symmetric(horizontal: 12),
            //                     child: Text(
            //                       // '${item['stock']}',
            //                       '${item.qty}',
            //                       style: TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 16,
            //                         color: isDark ? Colors.white : Colors.black87,
            //                       ),
            //                     ),
            //                   ),
            //                   GlobalUtils.CustomButton(
            //                     onPressed: () {
            //                       cartController.updateQuantity(
            //                         // item['product_id'] as String,
            //                         // item['stock'] + 1,
            //                         item.productId,
            //                         item.qty + 1,
            //                       );
            //                     },
            //                     icon: Icon(Icons.add),
            //                     iconColor: Color(0xff80a8ff),
            //                     backgroundColor: Colors.transparent,
            //                     showBorder: false,
            //                     showShadow: false,
            //                     animation: ButtonAnimation.scale,
            //                     padding: EdgeInsets.all(8),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2a2a2a) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items:',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        '${cartController.cartCount.value}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      GlobalUtils.CustomGradientText(
                        '₹${cartController.getTotalPrice().toStringAsFixed(2)}',
                        gradient: LinearGradient(
                          colors: [Color(0xff80a8ff), Color(0xff5e60ce)],
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GlobalUtils.CustomButton(
                    onPressed: () {
                      Get.snackbar(
                        'Success',
                        'Order placed successfully!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: Duration(seconds: 3),
                      );
                      cartController.clearCart();
                    },
                    text: 'Proceed to Checkout',
                    textColor: Colors.white,
                    backgroundGradient: LinearGradient(
                      colors: [Color(0xff80a8ff), Color(0xff5e60ce)],
                    ),
                    borderRadius: 15,
                    animation: ButtonAnimation.scale,
                    height: 55,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}