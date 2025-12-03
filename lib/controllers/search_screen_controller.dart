import 'dart:async';
// import 'package:e_commerce_app/api/web_api_constant.dart';
// import 'package:e_commerce_app/controllers/product_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/ProductApiResponseModel.dart';
import '../models/ProductDetailsApiResponseModel.dart';
import '../models/product_model.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';

class SearchScreenController extends GetxController {
  // Text Controller
  // Rx<TextEditingController> searchTxtController = TextEditingController().obs;
  final TextEditingController searchTxtController = TextEditingController();
  // final ProductDetailController productDetailController = Get.put(ProductDetailController());
  // Use lazy initialization to avoid conflicts
  // ProductDetailController? _productDetailController;
  // ProductDetailController get productDetailController {
  //   if (_productDetailController == null) {
  //     if (Get.isRegistered<ProductDetailController>()) {
  //       _productDetailController = Get.find<ProductDetailController>();
  //     } else {
  //       _productDetailController = Get.put(ProductDetailController(), tag: 'search_stock');
  //     }
  //   }
  //   return _productDetailController!;
  // }

  // Search Results
  final RxList<ProductItem> searchResults = <ProductItem>[].obs;
  final RxList<ProductItem> allSearchResults = <ProductItem>[].obs;

  // Loading & Error States
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 20; // Show only 20 items at a time
  final RxBool hasMoreItems = true.obs;

  // Debouncing
  Timer? _debounceTimer;
  final int debounceDuration = 800; // 800ms delay

  // ✨ Stock Management - NEW ADDITION
  final RxMap<String, int?> productStockMap = <String, int?>{}.obs;
  final RxSet<String> fetchingStockIds = <String>{}.obs;
  final RxSet<String> stockFetchedIds = <String>{}.obs;

  // 🚨 BULLETPROOF: Multiple search handling
  String? _activeSearchQuery; // Track current active search
  int _searchSessionId = 0; // Unique ID for each search

  // 🚨 RATE LIMITING for Stock Fetch
  DateTime? _lastStockFetchTime;
  static const _stockFetchDelay = Duration(milliseconds: 800);
  Timer? _stockFetchTimer;
  final List<_StockFetchItem> _stockFetchQueue = [];

  String? userAccessToken;
  String lastSearchQuery = '';

  bool _isSearching = false;

  //   Future<void> getToken(BuildContext context,) async {
  //   await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
  //     userAccessToken = value;
  //   });
  // }

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> loadToken() async {
    if (userAccessToken == null || userAccessToken!.isEmpty) {
      userAccessToken = await AppSharedPreferences().getString(AppSharedPreferences.token);
    }
  }

  @override
  void onClose() {
    searchTxtController.dispose();
    _debounceTimer?.cancel();
    _cancelAllStockFetching();
    // _productDetailController = null;
    super.onClose();
  }

  // 🚨 CRITICAL: Cancel all ongoing stock fetches
  void _cancelAllStockFetching() {
    _stockFetchTimer?.cancel();
    _stockFetchQueue.clear();
    fetchingStockIds.clear();
    ConsoleLog.printColor("🛑 Cancelled all stock fetching", color: "red");
  }

  // ✅ Debounced Search - Use this for onChanged
  void onSearchChanged(BuildContext context, String searchText) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    searchText = searchText.trim();

    if (searchText.isEmpty) {
      clearSearch();
      return;
    }

    // Start new timer
    _debounceTimer = Timer(Duration(milliseconds: debounceDuration), () {
      searchProductApi(context, searchText);
    });
  }

  // ✅ Instant Search - Use this for onSubmitted
  void onSearchSubmitted(BuildContext context, String searchText) {
    _debounceTimer?.cancel(); // Cancel any pending debounce
    searchText = searchText.trim();

    if (searchText.isEmpty) {
      clearSearch();
      return;
    }

    searchProductApi(context, searchText);
  }


  // Search Product API Call
  Future<void> searchProductApi(BuildContext context, String searchText) async {
    // 🚨 NEW: Increment session ID for new search
    _searchSessionId++;
    final currentSessionId = _searchSessionId;
    ConsoleLog.printColor(
        "🔍 New search session #$currentSessionId: $searchText",
        color: "cyan"
    );
    // 🚨 Cancel previous search's stock fetching
    if (_activeSearchQuery != null && _activeSearchQuery != searchText) {
      ConsoleLog.printColor(
          "🛑 Cancelling previous search: $_activeSearchQuery",
          color: "yellow"
      );
      _cancelAllStockFetching();
    }

    _activeSearchQuery = searchText;

    // Prevent duplicate searches for same query
    if (lastSearchQuery == searchText && allSearchResults.isNotEmpty) {
      ConsoleLog.printColor("✅ Using cached results for: $searchText", color: "green");
      return;
    }

    // Wait if already searching
    if (_isSearching) {
      ConsoleLog.printColor("⏳ Search in progress, queuing...", color: "yellow");
      await Future.delayed(Duration(milliseconds: 100));

      // Check if this search is still relevant
      if (_searchSessionId != currentSessionId) {
        ConsoleLog.printColor(
            "❌ Search session #$currentSessionId cancelled (newer search started)",
            color: "red"
        );
        return;
      }
    }
    _isSearching = true;
    lastSearchQuery = searchText;
    // Only show loading on first search or query change
    isLoading.value = true;
    errorMessage.value = '';
    currentPage.value = 1;
    hasMoreItems.value = true;

    // Clear previous stock data
    productStockMap.clear();
    fetchingStockIds.clear();
    stockFetchedIds.clear();


    // if (searchText.trim().isEmpty) {
    //   searchResults.clear();
    //   return;
    // }
    Map<String, dynamic> dict = {
      "title":searchText,
    };

    try {
      await loadToken();
      ConsoleLog.printColor("Searching for: $searchText", color: "cyan");

      // if (userAccessToken == null || userAccessToken!.isEmpty) {
      // await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      //   userAccessToken = value;
      // });}

      // Example API call structure:
      var response = await ApiProvider().searchProductApi(context, WebApiConstant.API_URL_SEARCH_PRODUCT, dict, userAccessToken ?? "");
      // 🚨 CRITICAL: Check if this search is still relevant
      if (_searchSessionId != currentSessionId) {
        ConsoleLog.printColor(
            "❌ Search response ignored (session #$currentSessionId obsolete)",
            color: "red"
        );
        return;
      }
      if (response != null) {
      if (response.error != true && response.errorCode == 0){
        // // Convert API response to ProductItem list
        // searchResults.value = response.data
        //     ?.map((item) => ProductItem(
        //           productId: item.productId.toString(),
        //           title: item.title ?? '',
        //           discription: item.description ?? '',
        //           image: item.image ?? '',
        //           images: [],
        //           price: item.price ?? 0,
        //           sellPrice: item.discPrice ?? 0,
        //           qty: 1,
        //         ))
        //     .toList() ?? [];

        // Convert all items
        allSearchResults.value = response.data
        // List<ProductItem> tempProducts = response.data
            ?.map((item) {
          try {
            return ProductItem(
              productId: item.productId?.toString() ?? '',
              title: item.title ?? '',
              discription: item.description?.toString() ?? '',
              // image: item.image ?? '',
              images: item.image != null ? [item.image!] : [],
              price: item.price ?? 0,
              image: item.image ?? '',
              qty: 1,
              sellPrice: item.discPrice,
              slug: item.slug ?? '',
              // stock: item.stock
              // discPrice: item.discPrice ?? 0,
              // slug: item.slug ?? '',
              // qty: 1,
            );
          } catch (e) {
            ConsoleLog.printError("Error converting item: $e");
            return null;
          }
        })
            .where((item) => item != null)
            .cast<ProductItem>()
            .toList() ?? [];

        // await fetchStockForProducts(tempProducts, context);

        // allSearchResults.value = tempProducts;

        // Load first page
        loadPage(1);

        // 🎯 Start stock fetching for THIS search session
        _startSmartStockFetching(currentSessionId);

        ConsoleLog.printSuccess(
            "✅ Session #$currentSessionId: Found ${allSearchResults.length} results"
        );

        ConsoleLog.printSuccess(
            "✅ Total results: ${allSearchResults.length}, Showing: ${searchResults.length}"
        );
      } else {
        errorMessage.value = response.message ?? 'Search failed';
        searchResults.clear();
        allSearchResults.clear();
        ConsoleLog.printError("❌ Search failed: ${response.message}");
      }
      }else {
        // errorMessage.value = 'Item Not Found!';
        searchResults.clear();
        allSearchResults.clear();
        ConsoleLog.printError("❌ No response from server");
      }
      ConsoleLog.printColor("Search results: ${searchResults.length} items found");

    } catch (e) {
      ConsoleLog.printError("❌ Search error: $e");
      errorMessage.value = 'An error occurred while searching';
      searchResults.clear();
      allSearchResults.clear();
    } finally {
      isLoading.value = false;
      _isSearching = false;
    }
  }

  // 🎯 Smart Stock Fetching with Session Tracking
  void _startSmartStockFetching(int sessionId) {
    if (searchResults.isEmpty) return;

    ConsoleLog.printColor(
        "📊 Session #$sessionId: Starting stock fetch for ${searchResults.length} items",
        color: "cyan"
    );

    // Priority: First 8 visible items
    int visibleCount = searchResults.length > 8 ? 8 : searchResults.length;
    for (int i = 0; i < visibleCount; i++) {
      final slug = searchResults[i].slug;
      if (slug.isNotEmpty) {
        _addToStockQueue(slug, sessionId: sessionId, priority: true);
      }
    }

    // Remaining items
    for (int i = visibleCount; i < searchResults.length; i++) {
      final slug = searchResults[i].slug;
      if (slug.isNotEmpty) {
        _addToStockQueue(slug, sessionId: sessionId, priority: false);
      }
    }

    _processStockQueue();
  }
  // Add to queue with session tracking
  void _addToStockQueue(String slug, {required int sessionId, bool priority = false}) {
    if (stockFetchedIds.contains(slug) || fetchingStockIds.contains(slug)) {
      return;
    }

    final item = _StockFetchItem(slug: slug, sessionId: sessionId);

    if (priority) {
      _stockFetchQueue.insert(0, item);
    } else {
      _stockFetchQueue.add(item);
    }
  }

  // Process queue with session validation
  void _processStockQueue() {
    if (_stockFetchQueue.isEmpty) {
      ConsoleLog.printSuccess("✅ Stock fetching completed");
      return;
    }

    // Check rate limit
    if (_lastStockFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastStockFetchTime!);
      if (timeSinceLastFetch < _stockFetchDelay) {
        final waitTime = _stockFetchDelay - timeSinceLastFetch;
        _stockFetchTimer = Timer(waitTime, _processStockQueue);
        return;
      }
    }

    // Get next item
    final item = _stockFetchQueue.removeAt(0);

    // 🚨 CRITICAL: Validate session before fetching
    if (item.sessionId != _searchSessionId) {
      ConsoleLog.printColor(
          "⏭️ Skipping stock fetch for session #${item.sessionId} (obsolete)",
          color: "yellow"
      );
      // Continue with next item
      _processStockQueue();
      return;
    }

    // Fetch stock
    _fetchProductStock(item.slug, item.sessionId).then((_) {
      _processStockQueue();
    });
  }

  // Fetch stock with session validation
  Future<void> _fetchProductStock(String slug, int sessionId) async {
    // Double-check session is still valid
    if (sessionId != _searchSessionId) {
      ConsoleLog.printColor(
          "❌ Stock fetch cancelled for session #$sessionId",
          color: "red"
      );
      return;
    }

    if (fetchingStockIds.contains(slug) || stockFetchedIds.contains(slug)) {
      return;
    }

    try {
      fetchingStockIds.add(slug);
      _lastStockFetchTime = DateTime.now();

      Map<String, dynamic> body = {
        "slug": slug,
      };

      ConsoleLog.printColor("📦 Session #$sessionId: Fetching $slug", color: "blue");

      var response = await ApiProvider().productDetailsAPI(
        Get.context!,
        WebApiConstant.API_URL_HOME_PRODUCT_DETAILS,
        body,
        userAccessToken ?? "",
      );

      // 🚨 Validate session after API response
      if (sessionId != _searchSessionId) {
        ConsoleLog.printColor(
            "❌ Stock response ignored for session #$sessionId (obsolete)",
            color: "red"
        );
        return;
      }

      if (response != null &&
          response.error != true &&
          response.errorCode == 0 &&
          response.data != null) {
        var stock = response.data?.stock;
        productStockMap[slug] = stock ?? 0;
        stockFetchedIds.add(slug);

        ConsoleLog.printSuccess('✅ Session #$sessionId: $slug = $stock');
      } else {
        productStockMap[slug] = 0;
        stockFetchedIds.add(slug);
      }
    } catch (e) {
      if (e.toString().contains('429')) {
        ConsoleLog.printError('⏸️ Rate limit hit, pausing (session #$sessionId)');
        _stockFetchQueue.insert(0, _StockFetchItem(slug: slug, sessionId: sessionId));
        _stockFetchTimer?.cancel();
        _stockFetchTimer = Timer(Duration(seconds: 2), _processStockQueue);
      } else {
        ConsoleLog.printError('❌ Error fetching $slug: $e');
        productStockMap[slug] = 0;
        stockFetchedIds.add(slug);
      }
    } finally {
      fetchingStockIds.remove(slug);
    }
  }

  //
  // // 🚀 OPTIMIZED: Background mein sirf visible products ka stock fetch kare
  // void _fetchStockForVisibleProducts() {
  //   if (searchResults.isEmpty) return;
  //
  //   // Priority: Pehle visible items ka stock fetch karo
  //   _fetchStockInBatches(searchResults, priority: true);
  //
  //   // Background: Baad mein remaining items ka stock fetch karo
  //   if (allSearchResults.length > searchResults.length) {
  //     Future.delayed(Duration(milliseconds: 500), () {
  //       var remainingProducts = allSearchResults
  //           .where((p) => !searchResults.contains(p))
  //           .toList();
  //       _fetchStockInBatches(remainingProducts, priority: false);
  //     });
  //   }
  // }
  //
  // // Batch processing with optimized timing
  // void _fetchStockInBatches(List<ProductItem> products, {bool priority = false}) {
  //   if (products.isEmpty) return;
  //
  //   int batchSize = priority ? 3 : 5; // Priority items faster fetch
  //   int delayBetweenBatches = priority ? 100 : 300; // ms
  //
  //   for (int i = 0; i < products.length; i += batchSize) {
  //     int end = (i + batchSize < products.length) ? i + batchSize : products.length;
  //     List<ProductItem> batch = products.sublist(i, end);
  //
  //     Future.delayed(Duration(milliseconds: i * delayBetweenBatches ~/ batchSize), () {
  //       for (var product in batch) {
  //         if (product.slug != null && product.slug!.isNotEmpty) {
  //           _fetchProductStock(product.slug!);
  //         }
  //       }
  //     });
  //   }
  // }
  //
  // // Individual product ka stock fetch kare
  // Future<void> _fetchProductStock(String slug) async {
  //   // Skip if already fetching or fetched
  //   if (fetchingStockIds.contains(slug) || stockFetchedIds.contains(slug)) {
  //     return;
  //   }
  //
  //   try {
  //     fetchingStockIds.add(slug);
  //
  //     // Use the new method that doesn't show loading
  //     var productData = await productDetailController.getProductDetailsForStock(slug);
  //
  //     if (productData != null) {
  //       var stock = productData.stock;
  //       productStockMap[slug] = stock ?? 0;
  //       stockFetchedIds.add(slug);
  //
  //       ConsoleLog.printColor(
  //           'Stock fetched for slug $slug: $stock',
  //           color: "green"
  //       );
  //     } else {
  //       productStockMap[slug] = 0;
  //       stockFetchedIds.add(slug);
  //     }
  //
  //     // Map<String, dynamic> body = {
  //     //   "slug": slug,
  //     // };
  //     //
  //     // var response = await ApiProvider().productDetailsAPI(
  //     //   Get.context!,
  //     //   WebApiConstant.API_URL_HOME_PRODUCT_DETAILS,
  //     //   body,
  //     //   userAccessToken ?? "",
  //     // );
  //     //
  //     // if (response != null && response.error != true && response.errorCode == 0) {
  //     //   var stock = response.data?.stock;
  //     //   productStockMap[slug] = stock ?? 0;
  //     //   stockFetchedIds.add(slug);
  //     //
  //     //   ConsoleLog.printColor(
  //     //       'Stock fetched for slug $slug: $stock',
  //     //       color: "cyan"
  //     //   );
  //     // } else {
  //     //   productStockMap[slug] = 0;
  //     //   stockFetchedIds.add(slug);
  //     // }
  //   } catch (e) {
  //     ConsoleLog.printError('Error fetching stock for slug $slug: $e');
  //     productStockMap[slug] = 0;
  //     stockFetchedIds.add(slug);
  //   } finally {
  //     fetchingStockIds.remove(slug);
  //   }
  // }

  // Check kare ki product ka stock available hai ya nahi
  bool isStockAvailable(String? slug) {
    if (slug == null || slug.isEmpty) return false;
    var stock = productStockMap[slug];
    if (stock == null) return true;
    return stock > 0;
  }

  bool isFetchingStock(String? slug) {
    if (slug == null || slug.isEmpty) return false;
    return fetchingStockIds.contains(slug);
  }

  int? getStock(String? slug) {
    if (slug == null || slug.isEmpty) return null;
    return productStockMap[slug];
  }

  bool isStockFetched(String? slug) {
    if (slug == null || slug.isEmpty) return false;
    return stockFetchedIds.contains(slug);
  }

  void loadPage(int page) {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= allSearchResults.length) {
      hasMoreItems.value = false;
      return;
    }

    final pageItems = allSearchResults.sublist(
        startIndex,
        endIndex > allSearchResults.length ? allSearchResults.length : endIndex
    );

    if (page == 1) {
      searchResults.value = pageItems;
    } else {
      searchResults.addAll(pageItems);

      // Add new items to queue with current session
      for (var item in pageItems) {
        if (item.slug.isNotEmpty) {
          _addToStockQueue(item.slug, sessionId: _searchSessionId, priority: true);
        }
      }
      _processStockQueue();
    }

    hasMoreItems.value = endIndex < allSearchResults.length;
  }

  void loadMoreItems() {
    if (isLoadingMore.value || !hasMoreItems.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    Future.delayed(Duration(milliseconds: 300), () {
      loadPage(currentPage.value);
      isLoadingMore.value = false;
    });
  }

  void clearSearch() {
    searchTxtController.clear();
    searchResults.clear();
    allSearchResults.clear();
    errorMessage.value = '';
    lastSearchQuery = '';
    currentPage.value = 1;
    hasMoreItems.value = true;
    _debounceTimer?.cancel();
    _isSearching = false;
    _activeSearchQuery = null;

    _cancelAllStockFetching();
    productStockMap.clear();
    fetchingStockIds.clear();
    stockFetchedIds.clear();
  }

  Future<void> refreshSearch(BuildContext context) async {
    if (lastSearchQuery.isNotEmpty) {
      await searchProductApi(context, lastSearchQuery);
    }
  }
}

// 🚨 Helper class for queue items with session tracking
class _StockFetchItem {
  final String slug;
  final int sessionId;

  _StockFetchItem({required this.slug, required this.sessionId});
}

// =====================================================
// ACTUAL API INTEGRATION EXAMPLE
// =====================================================
/*
// Step 1: Create SearchResponseApi model (if not exists)
class SearchResponseApi {
  final bool? error;
  final String? message;
  final List<SearchProductData>? data;

  SearchResponseApi({
    this.error,
    this.message,
    this.data,
  });

  factory SearchResponseApi.fromJson(Map<String, dynamic> json) {
    return SearchResponseApi(
      error: json['error'],
      message: json['message'],
      data: json['data'] != null
          ? List<SearchProductData>.from(
              json['data'].map((x) => SearchProductData.fromJson(x)))
          : null,
    );
  }
}

class SearchProductData {
  final int? product_id;
  final String? title;
  final String? description;
  final String? image;
  final List<String>? images;
  final dynamic price;
  final dynamic discPrice;
  final int? stock;

  SearchProductData({
    this.product_id,
    this.title,
    this.description,
    this.image,
    this.images,
    this.price,
    this.discPrice,
    this.stock,
  });

  factory SearchProductData.fromJson(Map<String, dynamic> json) {
    return SearchProductData(
      product_id: json['product_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      price: json['price'],
      discPrice: json['disc_price'],
      stock: json['stock'],
    );
  }
}

// Step 2: Add API method in ApiProvider
Future<SearchResponseApi?> searchProduct(
  BuildContext context,
  String searchText,
) async {
  try {
    final response = await dio.post(
      'YOUR_API_ENDPOINT/search',
      data: {
        'title': searchText,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return SearchResponseApi.fromJson(response.data);
    }
  } catch (e) {
    print('API Error: $e');
  }
  return null;
}

// Step 3: Use in Controller
Future<void> searchProductApi(BuildContext context, String searchText) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiProvider().searchProduct(context, searchText);

    if (response != null && response.error == false) {
      searchResults.value = response.data
          ?.map((item) => ProductItem(
                productId: item.product_id.toString(),
                title: item.title ?? '',
                discription: item.description ?? '',
                image: item.image ?? '',
                images: item.images ?? [],
                price: item.price ?? 0,
                sellPrice: item.discPrice ?? 0,
                qty: 1,
              ))
          .toList() ?? [];
    } else {
      errorMessage.value = response?.message ?? 'Search failed';
      searchResults.clear();
    }
  } catch (e) {
    errorMessage.value = 'An error occurred';
    searchResults.clear();
  } finally {
    isLoading.value = false;
  }
}
*/