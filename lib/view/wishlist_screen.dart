import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product_model.dart';
import '../utils/global_utils.dart';
import '../view/product_detail_screen.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({super.key});

  @override
  State<MyWishlistScreen> createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  final WishlistController controller = Get.put(WishlistController());

  // Function to fetch stock status using the reusable script logic
  Future<int> _fetchStockStatus(String productId) async {
    // TODO: IMPORTANT: Replace this mock function with the actual stock fetching logic
    // used in your search screen (which requires an asynchronous call,
    // as stock is not directly available in ProductItem).
    // Example: return Get.find<YourActualController>().fetchLiveStock(productId);

    // Mock Data Fallback: Add a short delay to simulate network latency
    await Future.delayed(Duration(milliseconds: 50));

    // Placeholder Logic (Replace this with your live data fetch):
    if (productId.startsWith('out_of_stock_')) {
      return 0; // Simulate out of stock
    }
    return 5; // Default stock value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        elevation: 0,
        actions: [
          Obx(() => controller.wishlistItems.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearAllDialog(context),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'Your Wishlist is Empty',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add items you love to your wishlist',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final nav = Get.find<NavigationController>();
                      nav.changeIndex(0); // Home tab par jayein
                      Get.back(); // Agar wishlist alag screen hai to wapas jayein
                    } catch (e) {
                      // Agar controller nahi mila to naya banayein (Fallback)
                      Get.put(NavigationController()).changeIndex(0);
                      Get.back();
                    }
                    // Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Start Shopping', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          // onRefresh: controller.fetchWishlist,
          onRefresh: controller.loadWishlist,
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: controller.wishlistItems.length,
            itemBuilder: (context, index) {
              final item = controller.wishlistItems[index];
              return _buildWishlistCard(context, item, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildWishlistCard(BuildContext context, ProductItem item, int index) {
    // Check if the item has been correctly loaded (especially slug for navigation)
    final String productSlug = item.slug;
    final displayTitle = item.title ?? 'Product Name';

    // Use item.sellPrice (discounted) and item.price (original)
    final salePrice = item.sellPrice ?? item.price ?? 0.0;
    final originalPrice = item.price ?? 0.0;
    final isDiscounted = originalPrice > salePrice;

    // Check for null item.id for safe removal
    final itemId = item.productId ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (productSlug.isNotEmpty) {
          // We are using slug for navigation, ensure it's not null/empty
          Get.to(() => ProductDetailScreen(slug: productSlug));
        } else {
          GlobalUtils.showSnackbar(title: "Error", message: "Product details missing.");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff2a2a2a) : Colors.white/*Theme.of(context).cardColor*/,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isDark ? Color(0xff3a3a3a) : Color(0xfff0f0f0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      item.image ?? '',
                      height: 130, // FIX 1: Reduced height to 130 (was 150)
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 130,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    // Use itemId for removal
                    onTap: () => controller.removeFromWishlist(itemId),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Discount Badge using correct fields (item.sellPrice vs item.price)
                if (isDiscounted)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${calculateDiscount(originalPrice, salePrice)}% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                // FIX 2: Reduced vertical padding for title/price section
                padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle, // Used item.title or fallback
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        // Current (Discounted) Price: salePrice
                        Text(
                          '₹${salePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                        // Original Price (If discounted): originalPrice
                        if (isDiscounted)
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              // FIX: originalPrice getter is item.price
                              '₹${originalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // FutureBuilder for dynamic stock check
                    FutureBuilder<int>(
                      future: itemId.isNotEmpty
                          ? _fetchStockStatus(itemId)
                          : Future.value(0),
                      builder: (context, snapshot) {
                        final stockValue = snapshot.data ?? 0;
                        final isLoading = snapshot.connectionState == ConnectionState.waiting;
                        final isOutOfStock = stockValue <= 0;

                        return SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            // Disable button if loading or out of stock
                            onPressed: isLoading || isOutOfStock
                                ? null
                                : () {
                              // Null check: Ensures item.productId is not null
                              if (itemId.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Product ID missing, cannot move to cart.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              controller.moveToCart(item);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading
                                  ? Colors.blueGrey
                                  : isOutOfStock ? Colors.grey : Theme.of(context).primaryColor,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              isLoading ? 'Loading...' : (isOutOfStock ? 'Out of Stock' : 'Move to Cart'),
                              style: TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 32,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // FIX: moveToCart now accepts the full object
                    //       controller.moveToCart(item);
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Theme.of(context).primaryColor,
                    //       padding: EdgeInsets.zero,
                    //     ),
                    //     child: Text(
                    //       'Move to Cart',
                    //       style: TextStyle(fontSize: 11, color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Wishlist'),
          content: const Text('Are you sure you want to remove all items from your wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.clearWishlist();
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper to calculate discount percentage
  String calculateDiscount(double originalPrice, double discountedPrice) {
    try {
      if (originalPrice <= 0 || discountedPrice >= originalPrice) return '0';

      final discountPercentage = ((originalPrice - discountedPrice) / originalPrice) * 100;
      return discountPercentage.toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }
}