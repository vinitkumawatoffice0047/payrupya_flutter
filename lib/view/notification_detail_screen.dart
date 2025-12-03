
// Notification Detail Screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/theme_controller.dart';
import '../utils/global_utils.dart';

class NotificationDetailScreen extends StatefulWidget {
  final dynamic notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff1a1a1a) : Colors.white,
      appBar: AppBar(
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
        title: const Text(
          'Notification Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Section
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.notification.image != null && widget.notification.image!.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                                    widget.notification.image!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
                    );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                                    },
                                  ),
                  )
                  : const Center(
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),

            // Content Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: /*Colors.white*/isDark ? GlobalUtils.globalDarkIconColor : GlobalUtils.globalLightIconColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.notification.title ?? 'Notification',
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: /*const Color(0xFF212121)*/GlobalUtils.globalBlueTxtColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date and Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: /*const Color(0xFF1976D2).withOpacity(0.1)*/GlobalUtils.globalBlueIconColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: /*Color(0xFF1976D2)*/GlobalUtils.globalBlueTxtColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatFullDate(widget.notification.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: /*Color(0xFF1976D2)*/GlobalUtils.globalBlueTxtColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 20),

                  // Body/Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.w600,
                      color: /*const Color(0xFF212121)*/GlobalUtils.globalBlueTxtColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.notification.title ?? widget.notification.title ?? 'No description available.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: isDark ? Colors.grey :const Color(0xFF616161),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy • hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }
}