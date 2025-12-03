// import 'package:e_commerce_app/view/main_screen.dart';
// import 'package:e_commerce_app/view/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_screen_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/product_screen_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/global_utils.dart';
import 'category_detail_screen.dart';

final ProductScreenController productController = Get.put(ProductScreenController());
final HomeScreenController homeScreenController = Get.put(HomeScreenController());
final NavigationController navController = Get.put(NavigationController());

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final categories = themeController.categoryThemes.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff1a1a1a) : Colors.white,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),),
        automaticallyImplyLeading: false,
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
        // backgroundColor: const Color(0xff80a8ff),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white,),
            // onPressed: () => Get.to(() => const SearchScreen()),
            onPressed: (){
              navController.selectedIndex.value = 2;
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: homeScreenController.category.length,
        itemBuilder: (context, index) {
          // final category = categories[index];
          final categoryName = homeScreenController.category[index].title;
          // final categoryData = themeController.categoryThemes[category]!;
          // final colors = categoryData['colors'] as List<Color>;

          return Column(
            children: [
              GlobalUtils.CustomButton(
                onPressed: (){
                    Get.to(() => CategoryDetailScreen(categoryName: categoryName, categoryImage: homeScreenController.category[index].image, categoryId: homeScreenController.category[index].category_id,));
                    productController.getToken(context, int.parse(homeScreenController.category[index].category_id.toString()));
                },
                // backgroundGradient: LinearGradient(colors: colors),
                borderRadius: 20,
                showBorder: false,
                animation: ButtonAnimation.scale,
                padding: const EdgeInsets.all(10),
                child: Container(
                  // margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                            height: GlobalUtils.screenWidth * 0.15,
                            width: GlobalUtils.screenWidth * 0.25,
                            child: Image.network(homeScreenController.category[index].image.toString())
                        ),
                        // child: Icon(
                        //   categoryData['icon'] as IconData,
                        //   color: Colors.white,
                        //   size: 30,
                        // ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          // category,
                          homeScreenController.category[index].title.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 3,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: category == category.length - 1 ? 0 : 10,)
              SizedBox(height: homeScreenController.category[index] == homeScreenController.category[homeScreenController.category.length - 1] ? 0 : 10),
            ],
          );
        },
      ),
    );
  }
}