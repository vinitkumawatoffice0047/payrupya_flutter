// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final isDarkMode = false.obs;
  
  // get val => festivalThemes;
  //
  // @override
  // void onInit() {
  //   // TODO: implement onInit
  //   super.onInit();
  //   ConsoleLog.printColor("===============${val["diwali"]["name"]}", color: "yellow");
  // }

  final festivalThemes = {
    'january': {
      'icon': '🎊',
      'name': 'New Year Celebration',
      'colors': [Color(0xff1E40AF), Color(0xff7C3AED), Color(0xffDB2777)],
      'month': 1,
      'startDay': 1,
      'endDay': 15,
    },
    'february': {
      'icon': '❤️',
      'name': 'Valentine\'s Day Special',
      'colors': [Color(0xffDC2626), Color(0xffDB2777), Color(0xffEC4899)],
      'month': 2,
      'startDay': 10,
      'endDay': 20,
    },
    'march': {
      'icon': '🎨',
      'name': 'Holi - Festival of Colors',
      'colors': [Color(0xffDB2777), Color(0xffDC2626), Color(0xff9333EA)],
      'month': 3,
      'startDay': 10,
      'endDay': 25,
    },
    'april': {
      'icon': '🌸',
      'name': 'Spring Festival',
      'colors': [Color(0xffDB2777), Color(0xffEC4899), Color(0xff9333EA)],
      'month': 4,
      'startDay': 1,
      'endDay': 30,
    },
    'may': {
      'icon': '☀️',
      'name': 'Summer Vibes',
      'colors': [Color(0xffEA580C), Color(0xffDC2626), Color(0xffD97706)],
      'month': 5,
      'startDay': 1,
      'endDay': 31,
    },
    'june': {
      'icon': '🌧️',
      'name': 'Monsoon Magic',
      'colors': [Color(0xff059669), Color(0xff0D9488), Color(0xff0891B2)],
      'month': 6,
      'startDay': 1,
      'endDay': 30,
    },
    'july': {
      'icon': '❄️',
      'name': 'Rainy Season Sale',
      'colors': [Color(0xff0891B2), Color(0xff0D9488), Color(0xff059669)],
      'month': 7,
      'startDay': 1,
      'endDay': 31,
    },
    'august': {
      'icon': '🦚',
      'name': 'Janmashtami & Raksha Bandhan',
      'colors': [Color(0xff1E40AF), Color(0xff6366F1), Color(0xff7C3AED)],
      'month': 8,
      'startDay': 1,
      'endDay': 31,
    },
    'september': {
      'icon': '🍂',
      'name': 'Autumn Season',
      'colors': [Color(0xffB45309), Color(0xffD97706), Color(0xffEA580C)],
      'month': 9,
      'startDay': 1,
      'endDay': 30,
    },
    'october': {
      'icon': '🪔',
      'name': 'Diwali - Festival of Lights',
      'colors': [Color(0xffDC2626), Color(0xffD97706), Color(0xffEA580C)],
      'month': 10,
      'startDay': 1,
      'endDay': 31,
    },
    'november': {
      'icon': '🛍️',
      'name': 'Black Friday Sale',
      'colors': [Color(0xff1E293B), Color(0xff334155), Color(0xffDC2626)],
      'month': 11,
      'startDay': 1,
      'endDay': 30,
    },
    'december': {
      'icon': '🎄',
      'name': 'Christmas & New Year',
      'colors': [Color(0xffDC2626), Color(0xff059669), Color(0xff7C3AED)],
      'month': 12,
      'startDay': 1,
      'endDay': 31,
    },
    // 'diwali': {
    //   'icon': '🪔',
    //   'name': 'Diwali Special',
    //   'colors': [Color(0xffff9933), Color(0xffffd700), Color(0xffff6b35)],
    // },
    // 'holi': {
    //   'icon': '🎨',
    //   'name': 'Holi Dhamaka',
    //   'colors': [Color(0xffff006e), Color(0xff8338ec), Color(0xff3a86ff)],
    // },
    // 'navratri': {
    //   'icon': '🕉️',
    //   'name': 'Navratri Celebration',
    //   'colors': [Color(0xffff006e), Color(0xfffffb00), Color(0xff06ffa5)],
    // },
    // 'janmashtami': {
    //   'icon': '🦚',
    //   'name': 'Janmashtami Joy',
    //   'colors': [Color(0xff4361ee), Color(0xff7209b7), Color(0xfff72585)],
    // },
    // 'rakhi': {
    //   'icon': '🧵',
    //   'name': 'Raksha Bandhan',
    //   'colors': [Color(0xffff6b6b), Color(0xfffeca57), Color(0xff48dbfb)],
    // },
    // 'ganesh': {
    //   'icon': '🐘',
    //   'name': 'Ganesh Chaturthi',
    //   'colors': [Color(0xfffe9920), Color(0xfffeca57), Color(0xffee5a6f)],
    // },
  };

  // Ye color palettes automatically categories ko assign honge
  final List<List<Color>> colorPalettes = [
    [Color(0xff0D9488), Color(0xff0891B2)], // Teal-Cyan (Dark)
    [Color(0xff4338CA), Color(0xff6366F1)], // Indigo-Blue (Dark)
    [Color(0xffDC2626), Color(0xffEA580C)], // Red-Orange (Dark)
    [Color(0xffB91C1C), Color(0xffDC2626)], // Dark Red
    [Color(0xffDB2777), Color(0xffF472B6)], // Deep Pink
    [Color(0xff0284C7), Color(0xff0EA5E9)], // Sky Blue (Dark)
    [Color(0xff7C3AED), Color(0xff9333EA)], // Purple (Dark)
    [Color(0xffDB2777), Color(0xffEC4899)], // Pink (Dark)
    [Color(0xffEA580C), Color(0xffF59E0B)], // Orange-Amber (Dark)
    [Color(0xff1E40AF), Color(0xff7C3AED)], // Blue-Purple (Dark)
    [Color(0xffDC2626), Color(0xff9333EA)], // Red-Purple (Dark)
    [Color(0xff059669), Color(0xffD97706)], // Green-Orange (Dark)
    [Color(0xffDC2626), Color(0xffD97706)], // Red-Gold (Dark)
    [Color(0xff0891B2), Color(0xffDC2626)], // Cyan-Red (Dark)
    [Color(0xffB91C1C), Color(0xffEA580C)], // Dark Red-Orange
  ];

  // Ye icons automatically categories ko assign honge
  final List<IconData> iconsList = [
    Icons.shopping_basket,
    Icons.phone_android,
    Icons.checkroom,
    Icons.home,
    Icons.spa,
    Icons.sports_basketball,
    Icons.menu_book,
    Icons.toys,
    Icons.watch,
    Icons.kitchen,
    Icons.pets,
    Icons.directions_car,
    Icons.fitness_center,
    Icons.music_note,
    Icons.camera_alt,
    Icons.restaurant,
    Icons.laptop,
    Icons.bed,
    Icons.child_care,
    Icons.local_pharmacy,
  ];

  // Category theme ko get karne ka main function
  Map<String, dynamic> getCategoryTheme(String categoryName, String categoryImage, {int? index}) {
    // // Pehle check karo ki predefined theme hai ya nahi
    // if (_predefinedCategoryThemes.containsKey(categoryName)) {
    //   return _predefinedCategoryThemes[categoryName]!;
    // }

    // Agar nahi hai to dynamic generate karo
    return generateThemeForCategory(categoryName, categoryImage, index);
  }

  // Dynamic theme generate karne ka function
  Map<String, dynamic> generateThemeForCategory(String categoryName, String categoryImage, int? index) {
    // Category name se consistent hash generate karo
    int hash = generateHash(categoryName);

    // Agar index available hai to use bhi consider karo
    if (index != null) {
      hash = (hash + index) % 1000000;
    }

    // Hash se color palette aur icon select karo
    int colorIndex = hash % colorPalettes.length;
    // int iconIndex = hash % _iconsList.length;

    return {
      'colors': colorPalettes[colorIndex],
      'image': categoryImage,
      // 'icon': _iconsList[iconIndex],
    };
  }

  // String se consistent hash generate karne ka function
  int generateHash(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = ((hash << 5) - hash) + text.codeUnitAt(i);
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.abs();
  }



  String getCurrentFestival() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Har festival ko check karo
    for (var entry in festivalThemes.entries) {
      final theme = entry.value;
      final festivalMonth = theme['month'] as int;
      final startDay = theme['startDay'] as int;
      final endDay = theme['endDay'] as int;

      if (month == festivalMonth && day >= startDay && day <= endDay) {
        return entry.key;
      }
    }

    // Agar koi specific festival nahi hai to current month return karo
    final monthKeys = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];

    return monthKeys[month - 1];

    // final month = DateTime.now().month;
    // final day = DateTime.now().day;

    // if ((month == 10 && day >= 20) || (month == 11 && day <= 15)) return 'diwali';
    // if (month == 3 && day >= 15 && day <= 25) return 'holi';
    // if ((month == 9 && day >= 15) || (month == 10 && day <= 10)) return 'navratri';
    // if (month == 8 && day >= 20 && day <= 30) return 'janmashtami';
    // if (month == 8 && day >= 1 && day <= 15) return 'rakhi';
    // if (month == 9 && day >= 1 && day <= 15) return 'ganesh';

    // return 'default';
  }

  // Current festival ka data get karne ke liye helper function
  Map<String, dynamic>? getCurrentFestivalData() {
    final currentKey = getCurrentFestival();
    return festivalThemes[currentKey];
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
