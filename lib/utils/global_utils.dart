import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'ConsoleLog.dart';

// Button Type Enum
enum ButtonType {
  elevated,
  outlined,
  text,
  icon,
}

// Button Animation Enum
enum ButtonAnimation {
  none,
  scale,
  bounce,
  fade,
  rotate,
  shake,
}

// Snackbar Type Enum
enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class GlobalUtils {
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static List<Color> backgroundColor = [];
  static List<Color> appThemeColor = [];
  static bool obscureText = true;
  static Color titleColor = Colors.blue.shade600;
  static Color globalBlueTxtColor = const Color(0xff80a8ff);
  static Color globalBlueIconColor = const Color(0xff80a8ff).withOpacity(0.2);
  static Color globalDarkIconColor = const Color(0xff2a2a2a);
  static Color globalLightIconColor = const Color(0xfff5f5f5);
  static RxString CityName = "".obs;
  static RxString StateName = "".obs;

  // Method to initialize all global values
  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    // backgroundColor = <Color>[
    //   Color(0xff0054D3), Color(0xff00255D), Color(0xff001432)
    //   // Color(0xff80a8ff),
    //   // Color(0xffffffff),
    //   // Color(0xffffabab),
    // ];
    appThemeColor = <Color>[
      Color(0xFFDEEBFF),
      Color(0xFFFFFFFF),
      // Color(0xff80a8ff),
      // Color(0xffffabab),
    ];
  }

  static Future<Position?> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ConsoleLog.printError("Location permission permanently denied");
      return null;
    }

    if (permission == LocationPermission.denied) {
      ConsoleLog.printError("Location permission denied");
      return null;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ConsoleLog.printError("Location services are disabled");
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    ConsoleLog.printInfo("Lat: ${position.latitude}, Lng: ${position.longitude}");
    return position;
  }

  // Getter methods for global values
  static double getScreenWidth() {
    return screenWidth;
  }

  static double getScreenHeight() {
    return screenHeight;
  }

  static List<Color> getBackgroundColor() {
    // If not initialized or empty, return default colors
    if (backgroundColor.isEmpty) {
      return <Color>[
        Color(0xFFDEEBFF),
        Color(0xFFFFFFFF),
        // Color(0xff80a8ff),
        // Color(0xffffabab),
      ];
    }

    // If only 1 color, duplicate it to avoid gradient error
    if (backgroundColor.length == 1) {
      return <Color>[
        backgroundColor[0],
        backgroundColor[0],
      ];
    }

    return backgroundColor;
  }

  static List<Color> getSplashBackgroundColor() {
    // If not initialized or empty, return default colors
    // if (backgroundColor.isEmpty) {
      return <Color>[
        Color(0xff0054D3), Color(0xff00255D), Color(0xff001432)
        // Color(0xff80a8ff),
        // Color(0xffffabab),
      ];
    // }

    // If only 1 color, duplicate it to avoid gradient error
    if (backgroundColor.length == 1) {
      return <Color>[
        backgroundColor[0],
        backgroundColor[0],
      ];
    }

    return backgroundColor;
  }

  static List<Color> getAppThemeColor() {
    if (appThemeColor.isEmpty) {
      return <Color>[
        Color(0xFFDEEBFF),
        Color(0xFFFFFFFF),
        // Color(0xff80a8ff),
        // Color(0xffffabab),
      ];
    }

    if (appThemeColor.length == 1) {
      return <Color>[
        appThemeColor[0],
        appThemeColor[0],
      ];
    }

    return appThemeColor;
  }

  static LinearGradient blueGradientColor = LinearGradient(
    colors: <Color>[
      const Color(0xff00579C),
      const Color(0xf0c6c363),
    ],
  );

  static LinearGradient greyNegativeBtnGradientColor = LinearGradient(
    colors: <Color>[
      const Color(0xffA1A1A1),
      const Color(0xffA1A1A1),
    ],
  );

  static LinearGradient blueBtnGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0054D3), Color(0xFF71A9FF)],
  );

  static Gradient loginButtonGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A63FF), // bright top blue
      Color(0xFF1575FF), // soft light mid blue
      Color(0xFF0046CC), // deep bottom blue
    ],
  );


// Random request_id generator
  static String generateRandomId(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    Random rand = Random();

    String result = String.fromCharCodes(
      List.generate(length, (index) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );

    DateTime now = DateTime.now();
    return "$result${now.day}${now.month}${now.year}";
  }










  // 🎨 Gradient Text
  static Widget CustomGradientText(String text, {required Gradient gradient, TextStyle? style,}) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }

  static final Map<String, Timer> _cooldownTimers = {};
  // 🔔 Custom Snackbar
  static void showSnackbar({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration? duration,
    Duration cooldown = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    Widget? icon,
  }) {
    final String messageKey = '${title.trim()}:${message.trim()}:${type.name}';
    // Check if this specific message is in cooldown
    if (_cooldownTimers.containsKey(messageKey)) {
      return;
    }

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData defaultIcon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        defaultIcon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red;
        defaultIcon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        defaultIcon = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = Color(0xff80a8ff);
        defaultIcon = Icons.info;
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration ?? Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: 10,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: icon ?? Icon(defaultIcon, color: Colors.white),
      ),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );

    // Set cooldown for this specific message
    _cooldownTimers[messageKey] = Timer(cooldown, () {
      _cooldownTimers.remove(messageKey);
    });
  }

  // 📦 Loading Dialog
  static void showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff80a8ff)),
                ),
                if (message != null) ...[
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  // ❌ Hide Loading Dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // 💬 Confirmation Dialog
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    bool result = false;
    await Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: confirmText,
      textCancel: cancelText,
      confirmTextColor: Colors.white,
      cancelTextColor: cancelColor ?? Colors.grey,
      buttonColor: confirmColor ?? Color(0xff80a8ff),
      onConfirm: () {
        result = true;
        // Get.back(result: true);
        Get.close(Get.keys.length);
        // SystemNavigator.pop();
      },
      onCancel: () {
        result = false;
      },
    );
    return result;
  }

  // 🎨 Custom Bottom Sheet
  static void showCustomBottomSheet({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? height,
  }) {
    Get.bottomSheet(
      Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: child,
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
    );
  }

  // 📏 Responsive Size
  static double responsiveWidth(double percentage) {
    return (screenWidth * percentage) / 100;
  }

  static double responsiveHeight(double percentage) {
    return (screenHeight * percentage) / 100;
  }

  static double responsiveFontSize(double size) {
    return size * (screenWidth / 375); // 375 is base width (iPhone X)
  }

  // 🎯 Haptic Feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }



  // 📧 Email Validation
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // 🔒 Password Validation
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  // 📱 Mobile Number Validation
  static String? mobileValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number.';
    }
    if (value.length < 10) {
      return 'Mobile number must be at least 10 digits.';
    }
    final mobileRegex = RegExp(r'^[0-9]{10,12}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Please enter a valid mobile number.';
    }
    return null;
  }

  // 👤 Name Validation
  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name.';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    final nameRegex = RegExp(r'^[a-zA-Z ]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name should only contain letters.';
    }
    return null;
  }

  // 🔁 Confirm Password Validation
  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // 🆔 AADHAR NUMBER VALIDATION
  static String? aadharValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Aadhar number.';
    }

    // Remove any spaces or special characters
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it's exactly 12 digits
    if (cleanedValue.length != 12) {
      return 'Aadhar number must be 12 digits.';
    }

    // Check if it starts with 0 or 1 (invalid Aadhar)
    if (cleanedValue.startsWith('0') || cleanedValue.startsWith('1')) {
      return 'Invalid Aadhar number.';
    }

    // Verify check digit (basic verification)
    // Aadhar uses Verhoeff algorithm, but for basic validation we can check format
    final aadharRegex = RegExp(r'^[2-9]{1}[0-9]{11}$');
    if (!aadharRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid Aadhar number.';
    }

    return null;
  }

  // Number Validation
  static String? numberValidator(String? value/*, {int? minLength, int? maxLength}*/) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid number.';
    }

    // सिर्फ digits allow
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only digits are allowed.';
    }

    // // Minimum length check (optional)
    // if (minLength != null && value.length < minLength) {
    //   return 'Number must be at least $minLength digits.';
    // }
    //
    // // Maximum length check (optional)
    // if (maxLength != null && value.length > maxLength) {
    //   return 'Number cannot exceed $maxLength digits.';
    // }

    return null;
  }

  // Txn Pin Validation
  static String? txnPinValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your transaction pin.';
    }
    if (value.length < 4) {
      return 'Transaction pin must be at least 4 digits long.';
    }
    return null;
  }



  // 💰 Price Formatter
  static String formatPrice(double price, {String currency = '₹'}) {
    return '$currency${price.toStringAsFixed(2)}';
  }

  // 📅 Date Formatter
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ⏰ Time Formatter
  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // 🎨 Color from Hex
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // 📊 Percentage Calculator
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }


  // 🎨 ADVANCED CUSTOM BUTTON
  static Widget CustomButton({
    // Basic Properties
    required VoidCallback? onPressed,
    String? text,
    Widget? child,
    Icon? icon,

    // Button Type
    ButtonType buttonType = ButtonType.elevated,

    // Background
    Color? backgroundColor,
    Gradient? backgroundGradient,
    Color? disabledBackgroundColor,

    // Size
    double? height,
    double? width,
    EdgeInsets? padding,

    // Text Styling (only if text is provided)
    TextStyle? textStyle,
    Color? textColor,
    Gradient? textGradient,
    double? textFontSize,
    FontWeight? textFontWeight,

    // Border/Outline
    bool showBorder = true,
    double borderWidth = 2.0,
    Color? borderColor,
    double borderRadius = 10.0,

    // Shadow
    bool showShadow = true,
    Color? shadowColor,
    double shadowBlurRadius = 10.0,
    double shadowSpreadRadius = 1.0,
    Offset shadowOffset = const Offset(0, 3),
    double? elevation,

    // Animation
    ButtonAnimation animation = ButtonAnimation.scale,
    bool enableAnimation = true,
    Duration animationDuration = const Duration(milliseconds: 150),

    // Icon Properties (if icon button)
    double? iconSize,
    Color? iconColor,
    double? iconTextSpacing,
  }) {
    // Default Colors
    final defaultBackgroundColor = backgroundColor ?? const Color(0xFF5ED5A8);
    final defaultDisabledBackgroundColor = disabledBackgroundColor ?? Colors.grey.shade300;
    final defaultTextColor = textColor ?? Colors.black;
    final defaultBorderColor = borderColor ?? defaultBackgroundColor;
    final defaultShadowColor = shadowColor ?? defaultBackgroundColor.withOpacity(0.3);
    final defaultIconColor = iconColor ?? defaultTextColor;

    // Button Content
    Widget buttonContent;

    if (child != null) {
      buttonContent = child;
    } else if (icon != null && text != null) {
      // Icon + Text Button
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              color: onPressed != null ? defaultIconColor : Colors.grey,
              size: iconSize ?? 24,
            ),
            child: icon,
          ),
          SizedBox(width: iconTextSpacing ?? 8),
          Flexible(
            child: textGradient != null
                ? CustomGradientText(
              text,
              gradient: textGradient,
              style: textStyle ??
                  TextStyle(
                    fontSize: textFontSize ?? 16,
                    fontWeight: textFontWeight ?? FontWeight.w500,
                  ),
            ) :
            Text(text,
              style: textStyle ??
                  TextStyle(
                    color: onPressed != null ? defaultTextColor : Colors.grey,
                    fontSize: textFontSize ?? 16,
                    fontWeight: textFontWeight ?? FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      // Icon Only Button
      buttonContent = IconTheme(
        data: IconThemeData(
          color: onPressed != null ? defaultIconColor : Colors.grey,
          size: iconSize ?? 24,
        ),
        child: icon,
      );
    } else if (text != null) {
      // Text Only Button with Gradient Support
      buttonContent = textGradient != null
          ? CustomGradientText(
        text,
        gradient: textGradient,
        style: textStyle ??
            TextStyle(
              fontSize: textFontSize ?? 16,
              fontWeight: textFontWeight ?? FontWeight.w500,
            ),
      )
          : Text(
        text,
        style: textStyle ??
            TextStyle(
              color: onPressed != null ? defaultTextColor : Colors.grey,
              fontSize: textFontSize ?? 16,
              fontWeight: textFontWeight ?? FontWeight.w500,
            ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
      );
    } else {
      buttonContent = const SizedBox.shrink();
    }

    // Animation Wrapper
    Widget animatedButton = _AnimatedButton(
      animation: animation,
      enableAnimation: enableAnimation && onPressed != null,
      animationDuration: animationDuration,
      child: Container(
        height: height,
        width: width,
        decoration: buttonType == ButtonType.elevated && backgroundGradient != null
            ? BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: showShadow && onPressed != null
              ? [
            BoxShadow(
              color: defaultShadowColor,
              spreadRadius: shadowSpreadRadius,
              blurRadius: shadowBlurRadius,
              offset: shadowOffset,
            ),
          ]
              : null,
        )
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundGradient == null
                    ? (onPressed != null
                    ? (buttonType == ButtonType.text
                    ? Colors.transparent
                    : defaultBackgroundColor)
                    : defaultDisabledBackgroundColor)
                    : Colors.transparent,
                border: (buttonType == ButtonType.outlined ||
                    (buttonType == ButtonType.elevated && showBorder))
                    ? Border.all(
                  color: onPressed != null ? defaultBorderColor : Colors.grey,
                  width: borderWidth,
                )
                    : null,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: buttonType == ButtonType.elevated &&
                    showShadow &&
                    onPressed != null &&
                    backgroundGradient == null
                    ? [
                  BoxShadow(
                    color: defaultShadowColor,
                    spreadRadius: shadowSpreadRadius,
                    blurRadius: shadowBlurRadius,
                    offset: shadowOffset,
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: buttonContent,
              ),
            ),
          ),
        ),
      ),
    );

    return animatedButton;
  }



  // 🎨 COMPLETE CUSTOM TEXT FORM FIELD
  static Widget CustomTextField({
    // Basic Properties
    required String label,
    String? placeholder,
    TextEditingController? controller,
    String? Function(String?)? customValidator,
    GlobalKey<FormFieldState>? fieldKey,

    // Field Type
    bool isName = false,
    bool isEmail = false,
    bool isPassword = false,
    bool isTxnPin = false,
    bool isConfirmPassword = false,
    bool isMobileNumber = false,
    bool isAadharNumber = false,
    bool isNumber = false,
    bool isObscure = false,
    String? passwordToMatch, // For confirm password validation

    // Icons
    Widget? prefixIcon,
    Color? prefixIconColor,
    Widget? suffixIcon,
    Color? suffixIconColor,

    // Label Styling
    bool showLabel = true,
    TextStyle? labelStyle,
    Color? labelColor,
    double? labelFontSize,
    FontWeight? labelFontWeight,

    // Input Text Styling
    TextStyle? inputTextStyle,
    Color? inputTextColor,
    double? inputTextFontSize,
    FontWeight? inputTextFontWeight,
    TextCapitalization? textCapitalization,

    // Placeholder Styling
    TextStyle? placeholderStyle,
    Color? placeholderColor,
    double? placeholderFontSize,
    FontWeight? placeholderFontWeight,

    // Error Text Styling
    TextStyle? errorStyle,
    Color? errorColor,
    double? errorFontSize,
    FontWeight? errorFontWeight,

    // Background
    Color? backgroundColor,
    Gradient? backgroundGradient,
    Color? disabledBackgroundColor,

    // Border/Outline
    bool showBorder = true,
    double borderWidth = 1.0,
    double focusedBorderWidth = 2.0,
    double errorBorderWidth = 2.0,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double borderRadius = 10.0,

    // Size
    double? height,
    double? width,
    EdgeInsets? contentPadding,

    // Functionality
    bool enabled = true,
    bool readOnly = false,
    TextInputAction textInputAction = TextInputAction.next,
    FocusNode? focusNode,
    VoidCallback? onEditingComplete,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    int? maxLength,
    int? minLines,
    int? maxLines,
    bool autoValidate = false,
    bool shouldValidate = false,
    InputCounterWidgetBuilder? buildCounter
  }) {
    // State management for password visibility
    final ValueNotifier<bool> obscureTextNotifier = ValueNotifier<bool>(true);

    // State management for error message
    final ValueNotifier<String?> errorMessageNotifier = ValueNotifier<String?>(null);
    final GlobalKey<FormFieldState> formFieldKey = fieldKey ?? GlobalKey<FormFieldState>();

    // Conditional Validator Logic
    String? baseValidatorFunction(String? value) {
      if (customValidator != null) {
        return customValidator(value);
      } else if (isName) {
        return nameValidator(value);
      } else if (isEmail) {
        return emailValidator(value);
      } else if (isPassword) {
        return passwordValidator(value);
      }else if (isTxnPin) {
        return txnPinValidator(value);
      } else if (isConfirmPassword) {
        return confirmPasswordValidator(value, passwordToMatch);
      } else if (isMobileNumber) {
        return mobileValidator(value);
      }else if (isAadharNumber) {
        return aadharValidator(value);
      }else if (isNumber) {
        return numberValidator(value);
      } else {
        if (value == null || value.isEmpty && shouldValidate) {
          return 'This field cannot be empty.';
        }
        return null;
      }
    }

    // Conditional Keyboard Type Logic
    TextInputType getKeyboardType() {
      if (isMobileNumber) {
        return TextInputType.phone;
      } else if (isEmail) {
        return TextInputType.emailAddress;
      } else if (isPassword || isConfirmPassword) {
        return TextInputType.visiblePassword;
      }else if (isTxnPin) {
        return TextInputType.number;
      } else if (isAadharNumber) {
        return TextInputType.number;
      } else if (isNumber) {
        return TextInputType.number;
      }
      return keyboardType;
    }

    // Input Formatters
    List<TextInputFormatter>? getInputFormatters() {
      if (isMobileNumber) {
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength ?? 10),
        ];
      }
      if (isNumber || isTxnPin || isAadharNumber) {
        return [
          FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ];
      }
      if (maxLength != null) {
        return [LengthLimitingTextInputFormatter(maxLength)];
      }
      return null;
    }

    // Default Colors
    final defaultPrefixIconColor = prefixIconColor ?? Colors.white;
    final defaultSuffixIconColor = suffixIconColor ?? const Color(0xFF6B707E);
    final defaultLabelColor = labelColor ?? const Color(0xff41c7df);
    final defaultInputTextColor = inputTextColor ?? Colors.white;
    final defaultPlaceholderColor = placeholderColor ?? const Color.fromRGBO(255, 255, 255, 100);
    final defaultErrorColor = errorColor ?? Colors.red.shade300;
    final defaultBorderColor = borderColor ?? Colors.transparent;
    final defaultFocusedBorderColor = focusedBorderColor ?? const Color(0xFF5ED5A8);
    final defaultErrorBorderColor = errorBorderColor ?? Colors.red;
    final defaultBackgroundColor = backgroundColor ?? Colors.blue.shade300;
    final defaultDisabledBackgroundColor = disabledBackgroundColor ?? Colors.grey.withOpacity(0.1);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: labelStyle ??
                    TextStyle(
                      color: enabled ? defaultLabelColor : Colors.grey,
                      fontSize: labelFontSize ?? 16,
                      fontWeight: labelFontWeight ?? FontWeight.normal,
                    ),
              ),
            ),

          // Text Form Field with Error Display
          ValueListenableBuilder<bool>(
            valueListenable: obscureTextNotifier,
            builder: (context, obscureValue, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TextFormField Container
                  Container(
                    height: height,
                    decoration: backgroundGradient != null
                        ? BoxDecoration(
                      gradient: backgroundGradient,
                      borderRadius: BorderRadius.circular(borderRadius),
                    )
                        : null,
                    child: TextFormField(
                      key: formFieldKey,
                      controller: controller,
                      enabled: enabled,
                      readOnly: readOnly,
                      obscureText: !isObscure ? ((isPassword || isConfirmPassword || isTxnPin) && obscureValue) : isObscure,
                      validator: (value) {
                        if(shouldValidate){
                        final error = baseValidatorFunction(value);
                        // Update error message immediately
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          errorMessageNotifier.value = error;
                        });
                        return error;}else{
                          return null;
                        }
                      },
                      cursorColor: defaultFocusedBorderColor,
                      keyboardType: getKeyboardType(),
                      buildCounter: buildCounter,
                      textInputAction: textInputAction,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      textCapitalization: textCapitalization ?? TextCapitalization.sentences,
                      onChanged: (value) {
                        // Update error message on every change
                        final error = baseValidatorFunction(value);
                        errorMessageNotifier.value = error;

                        // Trigger form validation if autoValidate is true
                        if (autoValidate) {
                          formFieldKey.currentState?.validate();
                        }

                        if (onChanged != null) {
                          onChanged(value);
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (onSubmitted != null) {
                          onSubmitted(value);
                        }
                      },
                      minLines: 1,
                      maxLines: (isPassword || isConfirmPassword) ? 1 : (maxLines ?? 1),
                      autovalidateMode: autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      inputFormatters: getInputFormatters(),
                      style: inputTextStyle ??
                          TextStyle(
                            color: enabled ? defaultInputTextColor : Colors.grey,
                            fontSize: inputTextFontSize ?? 16,
                            fontWeight: inputTextFontWeight ?? FontWeight.normal,
                          ),
                      decoration: InputDecoration(
                        contentPadding: contentPadding ??
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                        // Prefix Icon
                        prefixIcon: prefixIcon != null
                            ? IconTheme(
                          data: IconThemeData(color: defaultPrefixIconColor),
                          child: prefixIcon,
                        )
                            : null,

                        // Placeholder
                        hintText: placeholder,
                        hintStyle: placeholderStyle ??
                            TextStyle(
                              color: defaultPlaceholderColor,
                              fontSize: placeholderFontSize ?? 14,
                              fontWeight: placeholderFontWeight ?? FontWeight.w400,
                            ),

                        // Error Style - Hidden inside field to prevent height change
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                        errorMaxLines: 1,

                        // Background Color
                        filled: true,
                        fillColor: backgroundGradient != null
                            ? Colors.transparent
                            : (enabled ? defaultBackgroundColor : defaultDisabledBackgroundColor),

                        // Borders
                        border: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: defaultBorderColor,
                            width: borderWidth,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,

                        enabledBorder: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: defaultBorderColor,
                            width: borderWidth,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,

                        focusedBorder: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: defaultFocusedBorderColor,
                            width: focusedBorderWidth,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,
                        errorBorder: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: defaultErrorBorderColor,
                            width: errorBorderWidth,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,

                        focusedErrorBorder: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: defaultErrorBorderColor,
                            width: errorBorderWidth,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,

                        disabledBorder: showBorder
                            ? OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                            : InputBorder.none,

                        // Suffix Icon (Password visibility toggle or custom)
                        suffixIcon: (isPassword || isConfirmPassword || isTxnPin)
                            ? IconButton(
                          icon: Icon(
                            obscureValue ? Icons.visibility_off : Icons.visibility,
                            color: enabled ? defaultSuffixIconColor : Colors.grey,
                          ),
                          onPressed: enabled
                              ? () {
                            obscureTextNotifier.value = !obscureTextNotifier.value;
                          }
                              : null,
                        )
                            : (suffixIcon != null
                            ? IconTheme(
                          data: IconThemeData(color: defaultSuffixIconColor),
                          child: suffixIcon,
                        )
                            : null),
                      ),
                    ),
                  ),

                  // Error Message Display (Below TextFormField)
                  ValueListenableBuilder<String?>(
                    valueListenable: errorMessageNotifier,
                    builder: (context, errorMessage, child) {
                      if (errorMessage == null || errorMessage.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          errorMessage,
                          style: errorStyle ??
                              TextStyle(
                                color: defaultErrorColor,
                                fontSize: errorFontSize ?? 12,
                                fontWeight: errorFontWeight ?? FontWeight.normal,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Animation Widget for Buttons
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final ButtonAnimation animation;
  final bool enableAnimation;
  final Duration animationDuration;

  const _AnimatedButton({
    required this.child,
    required this.animation,
    required this.enableAnimation,
    required this.animationDuration,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    switch (widget.animation) {
      case ButtonAnimation.scale:
        _animation = Tween<double>(begin: 1.0, end: 0.95).animate(//Expected Duration(ms): 150 – 200 ms
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case ButtonAnimation.bounce:
        _animation = Tween<double>(begin: 1.0, end: 1.1).animate(//Expected Duration(ms): 500 – 700 ms
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        break;
      case ButtonAnimation.fade:
        _animation = Tween<double>(begin: 1.0, end: 0.7).animate(//Expected Duration(ms): 250 – 300 ms
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case ButtonAnimation.rotate:
        _animation = Tween<double>(begin: 0.0, end: 0.05).animate(//Expected Duration(ms): 300 – 400 ms
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case ButtonAnimation.shake:
        _animation = Tween<double>(begin: 0.0, end: 10.0).animate(//Expected Duration(ms): 600 – 800 ms
          CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
        );
        break;
      case ButtonAnimation.none:
        _animation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation || widget.animation == ButtonAnimation.none) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget animatedChild;

        switch (widget.animation) {
          case ButtonAnimation.scale:
          case ButtonAnimation.bounce:
            animatedChild = Transform.scale(
              scale: _animation.value,
              child: widget.child,
            );
            break;
          case ButtonAnimation.fade:
            animatedChild = Opacity(
              opacity: _animation.value,
              child: widget.child,
            );
            break;
          case ButtonAnimation.rotate:
            animatedChild = Transform.rotate(
              angle: _animation.value,
              child: widget.child,
            );
            break;
          case ButtonAnimation.shake:
            animatedChild = Transform.translate(
              offset: Offset(_animation.value * (_controller.value > 0.5 ? -1 : 1), 0),
              child: widget.child,
            );
            break;
          default:
            animatedChild = widget.child;
            break;
        }

        // 👇 Wrap InkWell tap handling inside animation control
        return Listener(
          onPointerDown: (_) {
            if (widget.enableAnimation) _controller.forward();
          },
          onPointerUp: (_) {
            if (widget.enableAnimation) _controller.reverse();
          },
          onPointerCancel: (_) {
            if (widget.enableAnimation) _controller.reverse();
          },
          child: animatedChild,
        );
      },
    );
  }
}