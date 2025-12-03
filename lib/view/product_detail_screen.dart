import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../models/product_model.dart';
import '../utils/global_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  
  const ProductDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // final ProductDetailController controller = Get.put(ProductDetailController());
  // final CartController cartController = Get.put(CartController());
  // Create new controller instance for each screen
  late final ProductDetailController controller;
  late final CartController cartController;
  final WishlistController wishlistController = Get.put(WishlistController());
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Get or create controller with unique tag based on slug
    final tag = 'product_detail_${widget.slug}_${DateTime.now().millisecondsSinceEpoch}';
    controller = Get.put(ProductDetailController(), tag: tag);
    cartController = Get.find<CartController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getProductDetails(context, widget.slug);
    });
  }

  @override
  void dispose() {
    // Clean up controller when leaving screen
    final tag = 'product_detail_${widget.slug}_${DateTime.now().millisecondsSinceEpoch}';
    if (Get.isRegistered<ProductDetailController>(tag: tag)) {
      Get.delete<ProductDetailController>(tag: tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xff80a8ff)),
                SizedBox(height: 16),
                Text('Loading product details...'),
              ],
            ),
          );
        }
        
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.getProductDetails(context, widget.slug, showLoading: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // final product = controller.productDetail.value;
        final product = controller.productDetail.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        return CustomScrollView(
          slivers: [
            buildAppBar(isDark, product),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImageCarousel(product),
                  buildProductInfo(isDark, product),
                  // buildSpecifications(isDark, product),
                  buildDescription(isDark, product),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: buildBottomBar(Theme.of(context).brightness == Brightness.dark),
    );
  }

  Widget buildAppBar(bool isDark, ProductDetailsResponseData product) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: isDark ? const Color(0xff1a1a1a) : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.black),
          ),
          onPressed: () => shareProduct(product),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: product.images != null && product.images!.isNotEmpty
              ? CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: product.images!.map<Widget>((image) {
                    return Image.network(
                      image.toString(),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/noImageIcon.png');
                      },
                    );
                  }).toList(),
                )
              : Center(child: Image.asset('assets/images/noImageIcon.png')),
        ),
      ),
    );
  }

  // Share Product Function
  Future<void> shareProduct(ProductDetailsResponseData product) async {
    try {
      final String shareText = '''
🛍️ Check out this amazing product!

${product.title ?? 'Product'}

💰 Price: ₹${product.discPrice ?? product.price}
${product.price != product.discPrice ? '🏷️ Original Price: ₹${product.price} (${calculateDiscountPercentage(product.price, product.discPrice)}% OFF)' : ''}

${product.shortDiscription ?? ''}

Shop now on our app!
      ''';

      // Share with text only (you can add deep link URL here if available)
      await Share.share(
        shareText,
        subject: product.title ?? 'Check out this product',
      );

      GlobalUtils.showSnackbar(
        title: 'Shared',
        message: 'Product shared successfully!',
      );
    } catch (e) {
      GlobalUtils.showSnackbar(
        title: 'Error',
        message: 'Failed to share product',
      );
    }
  }

  Widget buildImageCarousel(ProductDetailsResponseData product) {
    if (product.images == null || product.images!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: product.images!.asMap().entries.map<Widget>((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == entry.key
                    ? const Color(0xff80a8ff)
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildProductInfo(bool isDark, ProductDetailsResponseData product) {
    final stock = product.stock ?? 0;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // color: product.stock! > 0 ? Colors.green.shade50 : Colors.red.shade50,
              color: stock > 0 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                // color: product.stock! > 0 ? Colors.green : Colors.red,
                color: stock > 0 ? Colors.green : Colors.red,
              ),
            ),
            child: Text(
              // product.stock! > 0 ? 'In Stock (${product.stock})' : 'Out of Stock',
              stock > 0 ? 'In Stock ($stock)' : 'Out of Stock',
              style: TextStyle(
                // color: product.stock! > 0 ? Colors.green.shade700 : Colors.red.shade700,
                color: stock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Product Title
          Text(
            product.title ?? 'Product Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Short Description
          if (product.shortDiscription != null)
            Text(
              product.shortDiscription!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          const SizedBox(height: 15),
          
          // Price Section
          Row(
            children: [
              Text(
                '₹${product.discPrice ?? product.price}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff80a8ff),
                ),
              ),
              const SizedBox(width: 10),
              if (product.discPrice != null && product.price != product.discPrice)
                Text(
                  '₹${product.price}',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.red,
                    decorationThickness: 2,
                  ),
                ),
              const SizedBox(width: 10),
              if (product.discPrice != null && product.price != product.discPrice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${calculateDiscountPercentage(product.price, product.discPrice)}% OFF',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String calculateDiscountPercentage(String originalPrice, String discountedPrice) {
    try {
      final original = double.tryParse(originalPrice) ?? 0;
      final discounted = double.tryParse(discountedPrice) ?? 0;

      if (original <= 0 || discounted >= original) return '0';

      final discountPercentage = ((original - discounted) / original) * 100;
      return discountPercentage.toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }

  Widget buildSpecifications(bool isDark, ProductDetailsResponseData product) {
    // if (product.specification == null || product.specification.isEmpty) {
    if (product.discription == null || product.discription!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff2a2a2a) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // itemCount: product.specification.length,
              itemCount: 1,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                height: 1,
              ),
              itemBuilder: (context, index) {
                // final spec = product.specification[index];
                final spec = product.discription;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          // spec.key ?? '',
                          spec ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          // spec.value ?? '',
                          spec ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription(bool isDark, ProductDetailsResponseData product) {
    if (product.discription == null || product.discription!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            product.discription!,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomBar(bool isDark) {
    return Obx(() {
      // final product = controller.productDetail.value;
      final product = controller.productDetail.value;
      final stock = product?.stock ?? 0;
      if (product == null) return const SizedBox.shrink();

      // final productId = product.product_id.toString();
      final productId = product.product_id.toString();
      final quantity = cartController.getProductQuantity(productId);
      final isInCart = quantity > 0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff2a2a2a) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isInCart)
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xff80a8ff).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xff80a8ff)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            cartController.updateQuantity(productId, quantity - 1);
                          },
                          icon: const Icon(Icons.remove, color: Color(0xff80a8ff)),
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (quantity < stock.toInt()) {
                              cartController.updateQuantity(productId, quantity + 1);
                            } else {
                              GlobalUtils.showSnackbar(
                                title: 'Stock Limit',
                                message: 'Maximum available quantity: $stock',
                              );
                            }
                          },
                          icon: const Icon(Icons.add, color: Color(0xff80a8ff)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: GlobalUtils.CustomButton(
                    height: 55,
                    // onPressed: product.stock > 0
                    onPressed: stock > 0
                        ? () {
                            final cartItem = ProductItem(
                              productId: product.product_id.toString(),
                              images: product.images?.isNotEmpty == true ? product.images! : [],
                              image: product.images?.isNotEmpty == true ? product.images!.first : '',
                              title: product.title?.toString() ?? '',
                              discription: product.discription?.toString() ?? '',
                              price: parseToDouble(product.price),
                              sellPrice: parseToDouble(product.discPrice ?? product.price),
                              qty: 1,
                              slug: product.slug ?? '',
                              // stock: product.stock ?? 0,
                            );
                            cartController.addToCart(cartItem);
                          }
                        : null,
                    // text: product.stock! > 0 ? 'Add to Cart' : 'Out of Stock',
                    text: stock > 0 ? 'Add to Cart' : 'Out of Stock',
                    // backgroundColor: product.stock! > 0 ? const Color(0xff80a8ff) : Colors.grey,
                    backgroundColor: stock > 0 ? const Color(0xff80a8ff) : Colors.grey,
                    textColor: Colors.white,
                    textFontSize: 16,
                    // fontSize: 16,
                    borderRadius: 15,
                    showShadow: true,
                    animation: ButtonAnimation.scale,
                  ),
                ),
              const SizedBox(width: 15),
              // Wishlist Button with Animation
              Obx(() {
                final isInWishlist = wishlistController.isInWishlist(productId);

                return GlobalUtils.CustomButton(
                  height: 55,
                  onPressed: () {
                    if (isInWishlist) {
                      wishlistController.removeFromWishlist(productId);
                      GlobalUtils.showSnackbar(
                        title: 'Removed',
                        message: 'Removed from wishlist',
                      );
                    } else {
                      final wishlistItem = ProductItem(
                        productId: product.product_id.toString(),
                        images: product.images?.isNotEmpty == true ? product.images! : [],
                        image: product.images?.isNotEmpty == true ? product.images!.first : '',
                        title: product.title?.toString() ?? '',
                        discription: product.discription?.toString() ?? '',
                        price: parseToDouble(product.price),
                        sellPrice: parseToDouble(product.discPrice ?? product.price),
                        qty: 1,
                        slug: product.slug ?? '',
                      );
                      // 2. Ab object pass karein
                      wishlistController.addToWishlist(wishlistItem);
                      // wishlistController.addToWishlist(productId);
                      GlobalUtils.showSnackbar(
                        title: 'Added',
                        message: 'Added to wishlist',
                      );
                      // Haptic feedback
                      HapticFeedback.mediumImpact();
                    }
                  },
                  child: Center(
                    child: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: isInWishlist ? Colors.red.shade600 : Colors.red.shade400,
                  borderRadius: 15,
                  showShadow: true,
                  animation: ButtonAnimation.scale,
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
