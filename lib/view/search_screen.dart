import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/search_screen_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/global_utils.dart';
import '../utils/reusable_product_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CartController cartController = Get.put(CartController());
  final SearchScreenController searchScreenController = Get.put(SearchScreenController());
  final ScrollController scrollController = ScrollController();
  final ThemeController themeController = Get.put(ThemeController());
  final List<String> recentSearches = ['Milk', 'Bread', 'Oil', 'Rice'];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.dispose();
  }

  // ✅ Infinite Scroll Handler
  void onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      searchScreenController.loadMoreItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff1a1a1a) : Colors.white,
      appBar: AppBar(
        // backgroundColor: Color(0xff80a8ff),
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
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GlobalUtils.CustomTextField(
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchScreenController.searchTxtController,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    searchScreenController.clearSearch();
                  },
                );
              }
              return SizedBox(width: 0);
            },
          ),
          label: '',
          showLabel: false,
          autoValidate: false,
          controller: searchScreenController.searchTxtController,
          placeholder: 'Search products...',
          placeholderColor: Colors.grey,
          inputTextColor: isDark ? Colors.white : Colors.black,
          prefixIcon: Icon(Icons.search, color: Color(0xff80a8ff)),
          backgroundColor: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
          borderRadius: 12,
          height: 50,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          width: GlobalUtils.screenWidth,
          maxLines: 1,
          shouldValidate: false,
          onChanged: (value) {
            searchScreenController.onSearchChanged(context, value);
          },
          onSubmitted: (value) {
            searchScreenController.onSearchSubmitted(context, value);
          },
        ),
        titleSpacing: 10,
      ),
      body: Obx(() {
        // Show loading on first search
        if (searchScreenController.isLoading.value) {
          return buildLoadingState();
        }

        // Show error if any
        if (searchScreenController.errorMessage.value.isNotEmpty) {
          return buildErrorState(isDark);
        }

        // Show empty state
        if (searchScreenController.searchResults.isEmpty) {
          return buildEmptyState(isDark);
        }

        // Show results with infinite scroll
        return buildSearchResults(isDark);
      }),
    );
  }

  // ✅ Loading State
  Widget buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xff80a8ff)),
          SizedBox(height: 20),
          Text(
            'Searching...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ✅ Error State
  Widget buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text(
            searchScreenController.errorMessage.value,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          GlobalUtils.CustomButton(
            width: GlobalUtils.screenWidth * 0.9,
            onPressed: () {
              searchScreenController.refreshSearch(context);
            },
            text: 'Retry',
            textColor: Colors.white,
            backgroundColor: Color(0xff80a8ff),
            borderRadius: 10,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ],
      ),
    );
  }

  // ✅ Empty State (Recent Searches)
  Widget buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recentSearches.map((search) {
                return GlobalUtils.CustomButton(
                  onPressed: () {
                    searchScreenController.searchTxtController.text = search;
                    searchScreenController.onSearchSubmitted(context, search);
                  },
                  text: search,
                  icon: Icon(Icons.history, size: 16),
                  iconColor: Color(0xff80a8ff),
                  textColor: isDark ? Colors.white : Colors.black87,
                  backgroundColor: isDark ? Color(0xff2a2a2a) : Color(0xfff5f5f5),
                  borderRadius: 20,
                  showBorder: false,
                  animation: ButtonAnimation.scale,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 15),
          ...['Chocolates', 'Sugar', 'Masala', 'Water'].map((item) {
            return ListTile(
              leading: Icon(Icons.trending_up, color: Color(0xff80a8ff)),
              title: Text(
                item,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                searchScreenController.searchTxtController.text = item;
                searchScreenController.onSearchSubmitted(context, item);
              },
            );
          }),
        ],
      ),
    );
  }

  // ✅ Search Results with Infinite Scroll
  Widget buildSearchResults(bool isDark) {
    return RefreshIndicator(
      onRefresh: () => searchScreenController.refreshSearch(context),
      color: Color(0xff80a8ff),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Results (${searchScreenController.allSearchResults.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Showing ${searchScreenController.searchResults.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid Items
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.53,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final product = searchScreenController.searchResults[index];
                  return ProductCard(product: product, isDark: isDark);
                },
                childCount: searchScreenController.searchResults.length,
              ),
            ),
          ),

          // Loading More Indicator
          SliverToBoxAdapter(
            child: Obx(() {
              if (searchScreenController.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff80a8ff),
                    ),
                  ),
                );
              }

              if (!searchScreenController.hasMoreItems.value &&
                  searchScreenController.searchResults.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No more items',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SizedBox(height: 20);
            }),
          ),
        ],
      ),
    );
  }
}