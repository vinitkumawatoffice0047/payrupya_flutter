// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../utils/ConsoleLog.dart';
// import '../utils/app_shared_preferences.dart';
// import '../utils/custom_loading.dart';
// import '../utils/reusable_product_grid.dart';
// import 'cart_controller.dart';
//
// class WishlistController extends GetxController {
//   // Observable list of wishlist product IDs
//   // var wishlistItems = <dynamic>[].obs;
//   var wishlistItems = <dynamic>[].obs;
//   var isLoading = false.obs;
//   final CartController cartController = Get.put(CartController());
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadWishlist();
//   }
//
//   // Load wishlist from SharedPreferences
//   Future<void> loadWishlist() async {
//     isLoading.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? wishlistJson = prefs.getString('wishlist');
//
//       if (wishlistJson != null && wishlistJson.isNotEmpty) {
//         final List<dynamic> decoded = json.decode(wishlistJson);
//         wishlistItems.value = decoded.cast<String>();
//         isLoading.value = false;
//       }
//     } catch (e) {
//       print('Error loading wishlist: $e');
//       isLoading.value = false;
//     }
//   }
//
//   // Save wishlist to SharedPreferences
//   Future<void> saveWishlist() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String wishlistJson = json.encode(wishlistItems);
//       await prefs.setString('wishlist', wishlistJson);
//     } catch (e) {
//       print('Error saving wishlist: $e');
//     }
//   }
//
//   // Add product to wishlist
//   Future<void> addToWishlist(String productId) async {
//     if (!wishlistItems.contains(productId)) {
//       wishlistItems.add(productId);
//       await saveWishlist();
//     }
//   }
//
//   // Remove product from wishlist
//   Future<void> removeFromWishlist(String productId) async {
//     wishlistItems.remove(productId);
//     await saveWishlist();
//   }
//
//   // Toggle wishlist status
//   Future<void> toggleWishlist(String productId) async {
//     if (isInWishlist(productId)) {
//       await removeFromWishlist(productId);
//     } else {
//       await addToWishlist(productId);
//     }
//   }
//
//   // Check if product is in wishlist
//   bool isInWishlist(String productId) {
//     return wishlistItems.contains(productId);
//   }
//
//   // Move product to cart (using reusable cart functionality)
//   Future<void> moveToCart(String productId) async {
//     try {
//       final cartItem = createCartItem(wishlistItems.contains(productId));
//       cartController.addToCart(cartItem);
//       // Use CartController's addToCart method (reusable from product grid)
//       // await cartController.addToCart(cartItem
//       //   /*
//       //   productId: productId,
//       //   quantity: 1,*/
//       // );
//
//       // Remove from wishlist after successfully adding to cart
//       await removeFromWishlist(productId);
//
//       Get.snackbar(
//         'Success',
//         'Moved to cart successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       ConsoleLog.printError('Error moving to cart: $e');
//       Get.snackbar('Error', 'Failed to move to cart',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   // Clear entire wishlist
//   Future<void> clearWishlist() async {
//     wishlistItems.clear();
//     await saveWishlist();
//   }
//
//   // Get wishlist count
//   int get wishlistCount => wishlistItems.length;
// }






import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/ConsoleLog.dart';
// IMPORTANT: Apne ProductModel ka sahi path yahan check karein
import '../models/product_model.dart';
import '../utils/reusable_product_grid.dart';
import 'cart_controller.dart';

class WishlistController extends GetxController {
  // CHANGE 1: Ab yeh String nahi, ProductModel ki list hogi
  var wishlistItems = <ProductItem>[].obs;

  var isLoading = false.obs;
  final CartController cartController = Get.put(CartController());

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  // --- Load Wishlist from SharedPreferences ---
  Future<void> loadWishlist() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? wishlistJson = prefs.getString('wishlist');

      if (wishlistJson != null && wishlistJson.isNotEmpty) {
        // JSON String ko decode karke List<ProductModel> banayenge
        // final List<dynamic> decoded = json.decode(wishlistJson);
        // wishlistItems.value = decoded.map((e) => ProductItem.fromJson(e)).toList();

        final List<dynamic> decoded = json.decode(wishlistJson);

        if (decoded.isNotEmpty) {
          // FIX: Check karein ki data String hai (Purana) ya Map (Naya)
          if (decoded.first is String) {
            // Agar purana data (Sirf IDs) hai, to use clear kar dein taaki crash na ho
            print("Old wishlist format detected. Clearing to prevent crash.");
            await prefs.remove('wishlist');
            wishlistItems.clear();
          } else {
            // Agar naya data (Objects) hai, to load karein
            wishlistItems.value = decoded.map((e) => ProductItem.fromJson(e)).toList();
          }
        }
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      wishlistItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Save Wishlist to SharedPreferences ---
  Future<void> saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // List<ProductModel> ko wapas JSON String mein badal kar save karenge
      final String wishlistJson = json.encode(
          wishlistItems.map((e) => e.toJson()).toList()
      );
      await prefs.setString('wishlist', wishlistJson);
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  // --- Add Product (Takes full Model) ---
  Future<void> addToWishlist(ProductItem product) async {
    // Check karein agar ID pehle se exist karti hai
    if (!isInWishlist(product.productId!)) {
      wishlistItems.add(product);
      await saveWishlist();
      // Get.snackbar(
      //   'Wishlist',
      //   'Added to wishlist',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 1),
      // );
    }
  }

  // --- Remove Product ---
  Future<void> removeFromWishlist(String productId) async {
    // ID match karke remove karein
    wishlistItems.removeWhere((item) => item.productId == productId);
    await saveWishlist();
  }

  // --- Toggle Logic (Important for Heart Icon) ---
  // Ab ye sirf ID nahi, balki poora object lega
  Future<void> toggleWishlist(ProductItem product) async {
    if (product.productId == null) return;

    if (isInWishlist(product.productId!)) {
      await removeFromWishlist(product.productId!);
      // Get.snackbar('Wishlist', 'Removed from wishlist', snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } else {
      await addToWishlist(product);
    }
  }

  // --- Check if In Wishlist ---
  bool isInWishlist(String productId) {
    // List mein check karein ki kisi item ki ID match karti hai kya
    return wishlistItems.any((item) => item.productId == productId);
  }

  // --- Move to Cart Logic ---
  Future<void> moveToCart(ProductItem product) async {
    try {
      // VALIDATION: Check if product ID exists
      if (product.productId == null || product.productId!.isEmpty) {
        Get.snackbar(
          'Error',
          'Product ID is missing',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return;
      }

      // ✅ FIX 1: createCartItem ko product object pass karo (boolean nahi)
      final cartItem = createCartItem(product);

      // ✅ FIX 2: Directly addToCart call karo (correct syntax)
      cartController.addToCart(cartItem);

      // Remove from wishlist after successfully adding to cart
      await removeFromWishlist(product.productId!);
      // Success message already shown by cartController.addToCart()
      // No need to show duplicate snackbar

    } catch (e) {
      ConsoleLog.printError('Error moving to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to move to cart: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  // --- Clear entire wishlist ---
  Future<void> clearWishlist() async {
    wishlistItems.clear();
    await saveWishlist();
    Get.snackbar(
      'Wishlist',
      'Wishlist cleared',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  // Get wishlist count
  int get wishlistCount => wishlistItems.length;
}