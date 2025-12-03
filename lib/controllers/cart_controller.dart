import 'dart:convert';
// import 'package:e_commerce_app/utils/global_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/global_utils.dart';

class CartController extends GetxController {
  final cartItems = <ProductItem>[].obs;
  final cartCount = 0.obs;
  RxString currentAddress = ''.obs;
  RxString pinCode = ''.obs;
  Position? currentLocation ;

  @override
  void onInit() {
    super.onInit();
    loadCartFromPreferences();
  }

  static Future<Position> getCurrentPosition(BuildContext context) async {
    ConsoleLog.printColor("Location Started");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    ConsoleLog.printColor("Location Started1");
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      LocationPermission permission2 = await Geolocator.checkPermission();
      if (permission2 == LocationPermission.denied) {
        throw Exception(
          'Location permissions are permanently denied. Please enable it from app settings.',
        );
      }else{
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable it from app settings.',
      );
    }
    ConsoleLog.printColor("Location Started3");
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Convert coordinates into a full human-readable address
  static Future<String> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.street}, "
            "${place.subLocality}, ${place.locality}, "
            " ${place.postalCode}";
      } else {
        return "No address found";
      }
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  Future<void> getCurrentAddress(context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('current_selected_address');
    final savedPincode = prefs.getString('current_selected_pincode');

    if (savedAddress != null && savedAddress.isNotEmpty &&
        savedPincode != null && savedPincode.isNotEmpty) {
      currentAddress.value = savedAddress;
      pinCode.value = savedPincode;
      ConsoleLog.printColor("Using saved address: $savedAddress, $savedPincode");
      return;
    }

    // Only fetch location if no saved address exists
    currentLocation = await getCurrentPosition(context);
    ConsoleLog.printColor("Location Started4");
    ConsoleLog.printColor("$currentLocation");

    if (currentLocation != null) {
      currentAddress.value = await getAddressFromLatLng(currentLocation!);
      ConsoleLog.printColor("Location Started5");
      ConsoleLog.printColor(currentAddress.value);

      final pinRegex = RegExp(r'\b\d{6}\b');
      final match = pinRegex.firstMatch(currentAddress.value);

      if (match != null) {
        final pin = match.group(0);
        pinCode.value = pin ?? '';
        ConsoleLog.printColor("Extracted Pincode: ${pinCode.value}");

        // Newly detected address को भी save करें
        await prefs.setString('current_selected_address', currentAddress.value);
        await prefs.setString('current_selected_pincode', pinCode.value);
      } else {
        pinCode.value = '';
        ConsoleLog.printColor("No Pincode found in address");
      }
    }
  }

  // SharedPreferences se cart load karna
  Future<void> loadCartFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decoded = json.decode(cartData);
        cartItems.value = decoded.map((item) => ProductItem.fromJson(item)).toList();
        updateCartCount();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // SharedPreferences mein cart save karna
  Future<void> saveCartToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(cartItems);
      await prefs.setString('cart_items', cartData);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Cart count update karna
  void updateCartCount() {
    cartCount.value = cartItems.fold(0, (sum, item) => sum + item.qty);
  }

  // Product ko cart mein add karna
  void addToCart(ProductItem product) {
    final index = cartItems.indexWhere((item) => item.productId == product.productId);

    if (index != -1) {
      cartItems[index].qty++;
      cartItems.refresh();
    } else {
      product.qty = 1;
      cartItems.add(product);
    }

    updateCartCount();
    saveCartToPreferences();

    GlobalUtils.showSnackbar(
      title: 'Added to Cart',
      message: '${product.title} added successfully',
      position: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      icon: Image.network(product.images!.first.toString(), errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image);
      },)
    );
  }

  // Cart se product remove karna
  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.productId == productId);
    updateCartCount();
    saveCartToPreferences();
    // Yaha Delete Cart Item API call karein
    // deleteCartItemAPI(productId);
  }

  // Quantity update karna
  void updateQuantity(String productId, int quantity) {
    final index = cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        cartItems[index].qty = quantity;
        cartItems.refresh();
        updateCartCount();
        saveCartToPreferences();

        // Yaha Update Cart API call karein
        // updateCartAPI(productId, quantity);
      }
    }
  }

  // Product ka current quantity get karna
  int getProductQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.productId == productId);
    return index != -1 ? cartItems[index].qty : 0;
  }

  // Check karna ki product cart mein hai ya nahi
  bool isInCart(String productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  // Total price calculate karna
  double getTotalPrice() {
    return cartItems.fold(0.0, (sum, item) {
      final priceToUse = item.sellPrice is double ? item.sellPrice : item.sellPrice;
      return sum + (priceToUse * item.qty);
    });
  }

  // Cart clear karna
  void clearCart() {
    cartItems.clear();
    cartCount.value = 0;
    saveCartToPreferences();

    // Yaha Clear Cart API call karein
    // clearCartAPI();
  }
}
