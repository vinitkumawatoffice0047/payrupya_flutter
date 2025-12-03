// import 'package:e_commerce_app/models/ProductDetailsApiResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/search_screen_controller.dart';
import '../models/HomeDetailsApiResponseModel.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../models/product_model.dart';
import '../utils/global_utils.dart';
import '../view/product_detail_screen.dart';


// =====================================================
// REUSABLE PRODUCT GRID WIDGET
// =====================================================
class ReusableProductGrid extends StatelessWidget {
  final List<dynamic> products; // ProductItem ya koi bhi product list
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ReusableProductGrid({
    super.key,
    required this.products,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.53,
    this.crossAxisSpacing = 15,
    this.mainAxisSpacing = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product, isDark: isDark);
      },
    );
  }
}

// =====================================================
// REUSABLE PRODUCT LIST WIDGET (For Search Screen)
// =====================================================
class ReusableProductList extends StatelessWidget {
  final List<dynamic> products;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ReusableProductList({
    super.key,
    required this.products,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItem(product: product, isDark: isDark);
      },
    );
  }
}

// =====================================================
// PRODUCT CARD (Grid Item)
// =====================================================
class ProductCard extends StatelessWidget {
  dynamic product;
  final bool isDark;

  ProductCard({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return IntrinsicHeight(
      child: InkWell(
        onTap: () {
          Get.to(() => ProductDetailScreen(slug: getProductSlug(product)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff2a2a2a) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark ? Color(0xff3a3a3a) : Color(0xfff0f0f0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              Container(
                height: 125,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Center(
                  child: getProductImage(product),
                ),
              ),

              // Product Details
              Expanded(
                // fit: FlexFit.loose,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Title
                      Text(
                        getProductTitle(product),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),

                      // Product Description
                      Text(
                        getProductDescription(product),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Spacer(),
                      // SizedBox(height: 8),

                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${getDiscountPrice(product)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xff80a8ff),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                '₹${getOriginalPrice(product)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xff80a8ff),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.red,
                                  decorationThickness: 2,
                                ),
                              ),
                            ],
                          ),
                          buildSmartButton(cartController),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 FIXED: Main button logic with proper priority
  Widget buildSmartButton(CartController cartController) {
    // Check if it's a ProductItem (search results)
    if (product is ProductItem) {
      return buildSearchResultButton(cartController);
    }

    // For other product types (Home screen, etc.)
    return buildNormalButton(cartController);
  }

  // 🎯 Search Result Button - STOCK CHECK FIRST
  Widget buildSearchResultButton(CartController cartController) {
    final searchController = Get.isRegistered<SearchScreenController>()
        ? Get.find<SearchScreenController>()
        : null;

    // If no search controller, fallback to normal
    if (searchController == null) {
      return buildNormalButton(cartController);
    }

    final productItem = product as ProductItem;
    final productId = productItem.productId;
    final slug = productItem.slug ?? "";

    return Obx(() {
      // Force rebuild when cart changes
      final _ = cartController.cartItems.length;

      final quantity = cartController.getProductQuantity(productId!);
      final isInCart = quantity > 0;

      // 🚨 PRIORITY 1: If in cart, show quantity controls (no stock check)
      if (isInCart) {
        return buildQuantityControls(productId, quantity, cartController, isDark);
      }

      // 🚨 PRIORITY 2: Check stock status
      // final isFetching = searchController.isFetchingStock(slug);
      final isStockFetched = searchController.isStockFetched(slug);
      final stock = searchController.getStock(slug);

      // STATE 1: Stock not fetched yet - SHOW LOADING
      if (!isStockFetched) {
        return buildLoadingButton();
      }

      // STATE 2: Stock fetched - check availability
      if (stock != null && stock <= 0) {
        return buildOutOfStockButton();
      }

      // STATE 3: Stock available - show add button
      if (stock != null && stock > 0) {
        return buildAddButtonWithStock(cartController, stock);
      }

      // Fallback: Show loading if stock is null but fetched
      return buildLoadingButton();
    });
  }

  // 🎯 Normal Button (for Home screen items)
  Widget buildNormalButton(CartController cartController) {
    return Obx(() {
      final _ = cartController.cartItems.length;
      final productId = getProductId(product);
      final quantity = cartController.getProductQuantity(productId);
      final isInCart = quantity > 0;

      if (isInCart) {
        return buildQuantityControls(productId, quantity, cartController, isDark);
      }

      // FIXED: Use helper function instead of direct casting
      final stock = getProductStock(product);

      if (stock <= 0) {
        return buildOutOfStockButton();
      }

      return buildAddButton(cartController, stock);
    });
  }

  // 🔄 Enhanced Loading Button with Animation
  Widget buildLoadingButton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff80a8ff).withOpacity(0.1),
            Color(0xff80a8ff).withOpacity(0.2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xff80a8ff).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff80a8ff)),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Checking Stock...',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xff80a8ff),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ❌ Out of Stock Button
  Widget buildOutOfStockButton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[300]!, width: 1.5),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 18,
              color: Colors.red[700],
            ),
            SizedBox(width: 6),
            Text(
              'Out of Stock',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Add Button with Stock Badge
  Widget buildAddButtonWithStock(CartController cartController, int stock) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stock Badge
        if (stock <= 10)
          Container(
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: stock <= 5 ? Colors.orange[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stock <= 5 ? 'Only $stock left!' : '$stock in stock',
              style: TextStyle(
                fontSize: 9,
                color: stock <= 5 ? Colors.orange[900] : Colors.green[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Add Button
        GlobalUtils.CustomButton(
          height: 40,
          onPressed: () {
            final cartItem = createCartItem(product);
            cartController.addToCart(cartItem);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xff80a8ff),
          borderRadius: 10,
          padding: EdgeInsets.symmetric(horizontal: 8),
          showBorder: false,
          animation: ButtonAnimation.scale,
        ),
      ],
    );
  }

  // // ✅ Add to Cart Button (with stock badge)
  Widget buildAddButton(CartController cartController, int stock) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stock Badge (optional but helpful)
        if (stock <= 10)
          Container(
            margin: EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: stock <= 5 ? Colors.orange[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stock <= 5 ? 'Only $stock left!' : '$stock in stock',
              style: TextStyle(
                fontSize: 9,
                color: stock <= 5 ? Colors.orange[900] : Colors.green[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Add Button
        GlobalUtils.CustomButton(
          height: 40,
          onPressed: () {
            final cartItem = createCartItem(product);
            cartController.addToCart(cartItem);
                    },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xff80a8ff),
          borderRadius: 10,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          showBorder: false,
          animation: ButtonAnimation.scale,
        ),
      ],
    );
  }

  Widget buildQuantityControls(String productId, int quantity, CartController cartController, bool isDark) {
    // 🎯 SMART STOCK CHECKING: Handle both normal products and search results
    int stock = getActualStock(productId);
    return Container(
      width: GlobalUtils.screenWidth,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xff80a8ff).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlobalUtils.CustomButton(
            onPressed: () => cartController.updateQuantity(productId, quantity - 1),
            icon: Icon(Icons.remove, size: 25),
            iconColor: Color(0xff80a8ff),
            backgroundColor: Colors.transparent,
            showBorder: false,
            showShadow: false,
            animation: ButtonAnimation.scale,
            padding: EdgeInsets.all(4),
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          GlobalUtils.CustomButton(
            onPressed: () {
              // 🎯 CONDITION: Quantity stock se kam honi chahiye
              if (quantity < stock) {
                cartController.updateQuantity(productId, quantity + 1);
              } else {
                // Stock limit reached message
                GlobalUtils.showSnackbar(
                  title: 'Stock Limit',
                  message: 'Only $stock items available in stock',
                );
              }
            },
            icon: Icon(Icons.add, size: 25),
            iconColor: Color(0xff80a8ff),
            backgroundColor: Colors.transparent,
            showBorder: false,
            showShadow: false,
            animation: ButtonAnimation.scale,
            padding: EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  // 🎯 NEW FUNCTION: Get actual stock considering search results
  int getActualStock(String productId) {
    // Check if it's a search result product
    if (product is ProductItem) {
      final searchController = Get.isRegistered<SearchScreenController>()
          ? Get.find<SearchScreenController>()
          : null;

      if (searchController != null) {
        final slug = getProductSlug(product);
        final fetchedStock = searchController.getStock(slug);

        // If stock is fetched from search, use that
        if (fetchedStock != null) {
          return fetchedStock;
        }
      }
    }
    // Fallback to normal stock for other products
    return getProductStock(product);
  }
}

// =====================================================
// PRODUCT LIST ITEM (For Search Screen)
// =====================================================
class ProductListItem extends StatelessWidget {
  final dynamic product;
  final bool isDark;

  const ProductListItem({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String slug = getProductSlug(product);
        if (slug.isNotEmpty) {
          Get.to(() => ProductDetailScreen(slug: slug));
        } else{
          GlobalUtils.showSnackbar(
            title: 'Error',
            message: 'Product information not available',
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: getProductImage(product),
              ),
            ),
            SizedBox(width: 15),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getProductTitle(product),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    getProductDescription(product),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '₹${getDiscountPrice(product)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff80a8ff),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '₹${getOriginalPrice(product)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// =====================================================
// REUSABLE CART LIST WIDGET
// =====================================================
class ReusableCartList extends StatelessWidget {
  final List<ProductItem> cartItems;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ReusableCartList({
    super.key,
    required this.cartItems,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? EdgeInsets.all(20),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return CartItemCard(
          item: item,
          isDark: isDark,
        );
      },
    );
  }
}


// =====================================================
// CART ITEM CARD
// =====================================================
class CartItemCard extends StatelessWidget {
  final ProductItem item;
  final bool isDark;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isDark,
    this.margin,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          buildProductImage(),
          SizedBox(width: 15),

          // Product Details
          Expanded(
            child: buildProductDetails(),
          ),

          SizedBox(width: 10),

          // Quantity Controls
          buildQuantityControlsForCart(cartController),
        ],
      ),
    );
  }

  Widget buildProductImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          item.image!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.image, size: 35, color: Colors.grey);
          },
        ),
      ),
    );
  }

  Widget buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 5),
        Text(
          item.discription,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Text(
              '₹${item.sellPrice}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xff80a8ff),
              ),
            ),
            SizedBox(width: 8),
            if (item.price != item.sellPrice)
              Text(
                '₹${item.price}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildQuantityControlsForCart(CartController cartController) {
    // 🎯 STOCK CHECK: Get actual stock for this product
    final stock = getActualStockForCart(item.productId!);
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff80a8ff).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GlobalUtils.CustomButton(
            onPressed: () {
              // 🎯 CONDITION: Quantity stock se kam honi chahiye
              if (item.qty < stock) {
                cartController.updateQuantity(
                  item.productId!,
                  item.qty + 1,
                );
              } else {
                // 🎯 MANAGED SNACKBAR: Prevents multiple shows
                GlobalUtils.showSnackbar(
                  title: 'Stock Limit',
                  message: 'Only $stock items available in stock',
                  type: SnackbarType.warning,
                  duration: Duration(seconds: 2),
                );
              }
            },
            // onPressed: () {
            //   cartController.updateQuantity(
            //     item.productId,
            //     item.qty + 1,
            //   );
            // },
            icon: Icon(Icons.add, size: 20),
            iconColor: Color(0xff80a8ff),
            backgroundColor: Colors.transparent,
            showBorder: false,
            showShadow: false,
            animation: ButtonAnimation.scale,
            padding: EdgeInsets.all(8),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '${item.qty}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          GlobalUtils.CustomButton(
            onPressed: () {
              cartController.updateQuantity(
                item.productId!,
                item.qty - 1,
              );
            },
            icon: Icon(Icons.remove, size: 20),
            iconColor: Color(0xff80a8ff),
            backgroundColor: Colors.transparent,
            showBorder: false,
            showShadow: false,
            animation: ButtonAnimation.scale,
            padding: EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  // 🎯 NEW FUNCTION: Get actual stock for cart items
  int getActualStockForCart(String productId) {
    // Check if it's a search result product
    final searchController = Get.isRegistered<SearchScreenController>()
        ? Get.find<SearchScreenController>()
        : null;

    if (searchController != null) {
      final slug = item.slug ?? "";
      final fetchedStock = searchController.getStock(slug);

      // If stock is fetched from search, use that
      if (fetchedStock != null) {
        return fetchedStock;
      }
    }
  
    // Fallback: Use the stock from the item itself
    // return item.stock ?? 0;
    return getProductStock(item);
  }
}

// =====================================================
// ALTERNATIVE: HORIZONTAL QUANTITY CONTROLS (Optional)
// =====================================================
class CartItemCardHorizontal extends StatelessWidget {
  final ProductItem item;
  final bool isDark;
  final EdgeInsetsGeometry? margin;

  const CartItemCardHorizontal({
    super.key,
    required this.item,
    required this.isDark,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.image!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, size: 35, color: Colors.grey);
                    },
                  ),
                ),
              ),
              SizedBox(width: 15),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      item.discription,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '₹${item.sellPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff80a8ff),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (item.price != item.sellPrice)
                          Text(
                            '₹${item.price}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Horizontal Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: Color(0xff80a8ff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlobalUtils.CustomButton(
                  onPressed: () {
                    cartController.updateQuantity(
                      item.productId!,
                      item.qty - 1,
                    );
                  },
                  icon: Icon(Icons.remove, size: 25),
                  iconColor: Color(0xff80a8ff),
                  backgroundColor: Colors.transparent,
                  showBorder: false,
                  showShadow: false,
                  animation: ButtonAnimation.scale,
                  padding: EdgeInsets.all(8),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.qty}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                GlobalUtils.CustomButton(
                  onPressed: () {
                    cartController.updateQuantity(
                      item.productId!,
                      item.qty + 1,
                    );
                  },
                  icon: Icon(Icons.add, size: 25),
                  iconColor: Color(0xff80a8ff),
                  backgroundColor: Colors.transparent,
                  showBorder: false,
                  showShadow: false,
                  animation: ButtonAnimation.scale,
                  padding: EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CART SUMMARY WIDGET (Bottom Section)
// =====================================================
class CartSummary extends StatelessWidget {
  final int totalItems;
  final double totalPrice;
  final VoidCallback onCheckout;
  final bool isDark;

  const CartSummary({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.onCheckout,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Items Row
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
                '$totalItems',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Total Price Row
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
                '₹${totalPrice.toStringAsFixed(2)}',
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

          // Checkout Button
          GlobalUtils.CustomButton(
            onPressed: onCheckout,
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
    );
  }
}

// =====================================================
// EMPTY CART WIDGET
// =====================================================
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback onStartShopping;
  final bool isDark;

  const EmptyCartWidget({
    super.key,
    required this.onStartShopping,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: GlobalUtils.screenHeight * 0.25),
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
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
          Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: GlobalUtils.screenHeight * 0.2),
          GlobalUtils.CustomButton(
            width: GlobalUtils.screenWidth * 0.9,
            onPressed: onStartShopping,
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
}



// =====================================================
// HELPER FUNCTIONS
// =====================================================

// Helper functions (keep existing ones and add slug getter)
String getProductSlug(dynamic product) {
  if (product is TopSelling) return product.slug ?? "";
  if (product is ProductDetailsResponseData) return product.slug ?? "";
  if (product is ProductItem) return product.slug ?? "";
  return "";
}

// Keep all other existing helper functions from reusable_product_grid.dart
Widget getProductImage(dynamic product) {
  if (product is TopSelling) {
    return product.images != null && product.images!.isNotEmpty
        ? Image.network(product.images!.first, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        "assets/images/noImageIcon.png",
        fit: BoxFit.contain,
      );
    }) : Image.asset("assets/images/noImageIcon.png");
  }
  if (product is ProductDetailsResponseData) {
    final images = product.images;
    if (images != null && images.isNotEmpty) {
      return Image.network(images.first.toString(), fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/images/noImageIcon.png",
          fit: BoxFit.contain,
        );
      });
    }else{return Image.asset("assets/images/noImageIcon.png");}
    return Image.asset("assets/images/noImageIcon.png");
  }
  if (product is ProductItem) {
    return product.image!.isNotEmpty
        ? Image.network(product.image ?? "", fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        "assets/images/noImageIcon.png",
        fit: BoxFit.contain,
      );
    }) : Image.asset("assets/images/noImageIcon.png");
  }
  return Image.asset("assets/images/noImageIcon.png");
}

String getProductTitle(dynamic product) {
  if (product is ProductItem) return product.title ?? '';
  if (product is TopSelling) return product.title ?? '';
  if (product is ProductDetailsResponseData) return product.title?.toString() ?? '';
  return '';
}

String getProductDescription(dynamic product) {
  if (product is TopSelling) return product.title ?? '';
  if (product is ProductDetailsResponseData) return product.title?.toString() ?? '';
  if (product is ProductItem) return product.discription ?? '';
  return '';
}

String getProductId(dynamic product) {
  if (product is TopSelling) return product.product_id?.toString() ?? '';
  if (product is ProductDetailsResponseData) return product.product_id?.toString() ?? '';
  if (product is ProductItem) return product.productId!;
  return '';
}

dynamic getDiscountPrice(dynamic product) {
  if (product is TopSelling) return product.discPrice ?? product.price ?? 0;
  if (product is ProductDetailsResponseData) return product.discPrice ?? product.price ?? 0;
  if (product is ProductItem) return product.sellPrice ?? 0;
  return 0;
}

dynamic getOriginalPrice(dynamic product) {
  if (product is TopSelling) return product.price ?? 0;
  if (product is ProductDetailsResponseData) return product.price ?? 0;
  if (product is ProductItem) return product.price ?? 0;
  return 0;
}

// FIXED: Added proper type checking for stock
int getProductStock(dynamic product) {
  if (product is TopSelling) return product.stock ?? 0;
  if (product is ProductDetailsResponseData) return product.stock ?? 0;
  if (product is ProductItem) return 99;
  return 0;
}

ProductItem createCartItem(dynamic product) {
  if (product is ProductItem) return product;
  return ProductItem(
    productId: getProductId(product),
    image: getProductImageUrl(product),
    images: getProductImages(product),
    title: getProductTitle(product),
    discription: getProductDescription(product),
    price: getOriginalPrice(product) ?? 0,
    sellPrice: getDiscountPrice(product) ?? 0,
    qty: 1,
    slug: getProductSlug(product),
  );
}

String getProductImageUrl(dynamic product) {
  if (product is TopSelling) {
    return product.images != null && product.images!.isNotEmpty ? product.images!.first : '';
  }
  if (product is ProductDetailsResponseData) {
    return product.images != null && product.images!.isNotEmpty ? product.images!.first : '';
  }
  if (product is ProductItem) {
    return product.image ?? '';
  }
  return '';
}

List<String>? getProductImages(dynamic product) {
  if (product is TopSelling) return product.images;
  if (product is ProductDetailsResponseData) return product.images;
  if (product is ProductItem) return product.images;
  return null;
}