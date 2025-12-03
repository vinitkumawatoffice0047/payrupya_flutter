// // import 'package:e_commerce_app/utils/global_utils.dart';
// // import 'package:e_commerce_app/view/search_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:payrupya/view/search_screen.dart';
// import '../controllers/cart_controller.dart';
// import '../controllers/navigation_controller.dart';
// import '../controllers/theme_controller.dart';
// import '../utils/global_utils.dart';
// import '../utils/will_pop_validation.dart';
// import 'account_screen.dart';
// import 'cart_screen.dart';
// import 'categories_screen.dart';
// import 'home_screen.dart';
//
// final NavigationController navController = Get.put(NavigationController());
// final ThemeController themeController = Get.put(ThemeController());
// final CartController cartController = Get.put(CartController());
//
// final List<Widget> screens = [
//   HomeScreen(),
//   CategoriesScreen(),
//   SearchScreen(),
//   CartScreen(),
//   AccountScreen(),
// ];
//
// class MainScreen extends StatefulWidget {
//   int selectedIndex = 0;
//   MainScreen({super.key, required this.selectedIndex});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: ()=> GlobalUtils.showConfirmationDialog(title: "Exit", message: "Are you sure want to exit app?"),
//       child: Scaffold(
//         body: Obx(() => screens[widget.selectedIndex != 2 ? navController.selectedIndex.value : widget.selectedIndex],
//         ),
//         bottomNavigationBar: Obx(() {
//           final isDark = Theme.of(context).brightness == Brightness.dark;
//           return Container(
//             decoration: BoxDecoration(
//               color: isDark ? Color(0xff2a2a2a) : Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withAlpha(26),
//                   blurRadius: 20,
//                   offset: Offset(0, -5),
//                 ),
//               ],
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25),
//                 topRight: Radius.circular(25),
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25),
//                 topRight: Radius.circular(25),
//               ),
//               child: BottomNavigationBar(
//                 currentIndex: navController.selectedIndex.value,
//                 onTap: navController.changeIndex,
//                 type: BottomNavigationBarType.fixed,
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 selectedItemColor: Color(0xff80a8ff),
//                 unselectedItemColor: Colors.grey,
//                 selectedFontSize: 12,
//                 unselectedFontSize: 11,
//                 items: [
//                   buildNavItem(Icons.home_rounded, 'Home', 0),
//                   buildNavItem(Icons.grid_view_rounded, 'Categories', 1),
//                   buildNavItem(Icons.search_rounded, 'Search', 2),
//                   buildNavItem(Icons.shopping_cart_rounded, 'Cart', 3, badge: cartController.cartCount.value),
//                   buildNavItem(Icons.person_rounded, 'Account', 4),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   BottomNavigationBarItem buildNavItem(IconData icon, String label, int index, {int badge = 0}) {
//     return BottomNavigationBarItem(
//       icon: Obx(() {
//         final isSelected = navController.selectedIndex.value == index;
//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               padding: EdgeInsets.all(isSelected ? 8 : 0),
//               decoration: BoxDecoration(
//                 color: isSelected ? Color(0xff80a8ff).withOpacity(0.2) : Colors.transparent,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Icon(icon, size: isSelected ? 28 : 24),
//             ),
//             if (badge > 0)
//               Positioned(
//                 right: -6,
//                 top: -6,
//                 child: Container(
//                   padding: EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   constraints: BoxConstraints(
//                     minWidth: 18,
//                     minHeight: 18,
//                   ),
//                   child: Text(
//                     badge > 99 ? '99+' : badge.toString(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }),
//       label: label,
//     );
//   }
// }