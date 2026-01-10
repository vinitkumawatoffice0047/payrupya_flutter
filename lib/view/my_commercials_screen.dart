import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/my_commercials_controller.dart';
import '../utils/global_utils.dart';
import 'commercial_detail_screen.dart';

class MyCommercialsScreen extends StatefulWidget {
  const MyCommercialsScreen({super.key});

  @override
  State<MyCommercialsScreen> createState() => _MyCommercialsScreenState();
}

class _MyCommercialsScreenState extends State<MyCommercialsScreen> {
  late MyCommercialsController controller;
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyCommercialsController());
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(),
            // Content
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(const Color(0xFF0054D3).withOpacity(0.7)),
                  trackColor: MaterialStateProperty.all(const Color(0xFFE0E0E0).withOpacity(0.3)),
                  thickness: MaterialStateProperty.all(8),
                  radius: const Radius.circular(4),
                  minThumbLength: 48,
                  crossAxisMargin: 2,
                  mainAxisMargin: 4,
                ),
                child: Scrollbar(
                  controller: _mainScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8,
                  radius: const Radius.circular(4),
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: _mainScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Service Type Dropdown (Multi-select)
                        _buildServiceTypeDropdown(),
                        const SizedBox(height: 12),
                        // Selected Services Chips
                        Obx(() => _buildSelectedServicesChips()),
                        const SizedBox(height: 16),
                        // Search Button
                        _buildSearchButton(),
                        const SizedBox(height: 16),
                        // Filter Button
                        _buildFilterButton(),
                        const SizedBox(height: 16),
                        // Margin List
                        Obx(() => _buildMarginList()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Filter Modal
      bottomSheet: _buildFilterModal(),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: GlobalUtils.screenWidth * 0.04,
        right: GlobalUtils.screenWidth * 0.04,
        bottom: 16,
        top: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            'My Commercials',
            style: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (20 / 393),
              fontWeight: FontWeight.w600,
              color: const Color(0xff1B1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Obx(() {
      if (controller.isServiceTypeLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: Color(0xFF0054D3)),
          ),
        );
      }

      return GestureDetector(
        onTap: () {
          _showServiceTypeMultiSelectDialog();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  controller.selectedServices.isEmpty
                      ? 'Service Type ( Multiple Select )'
                      : '${controller.selectedServices.length} Selected',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: controller.selectedServices.isEmpty
                        ? const Color(0xFF6B707E)
                        : const Color(0xFF1B1C1C),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B707E),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showServiceTypeMultiSelectDialog() {
    final ScrollController serviceTypeScrollController = ScrollController();
    bool isDisposed = false;

    void disposeController() {
      if (!isDisposed) {
        serviceTypeScrollController.dispose();
        isDisposed = true;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Service Types',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (controller.serviceTypeList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No service types available',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: const Color(0xFF6B707E),
                          ),
                        ),
                      ),
                    );
                  }
                  return ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(const Color(0xFF0054D3).withOpacity(0.7)),
                      trackColor: MaterialStateProperty.all(const Color(0xFFE0E0E0).withOpacity(0.3)),
                      thickness: MaterialStateProperty.all(8),
                      radius: const Radius.circular(4),
                      minThumbLength: 48,
                      crossAxisMargin: 2,
                      mainAxisMargin: 4,
                    ),
                    child: Scrollbar(
                      controller: serviceTypeScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 8,
                      radius: const Radius.circular(4),
                      interactive: true,
                      child: ListView.builder(
                        controller: serviceTypeScrollController,
                        padding: EdgeInsets.zero,
                        itemCount: controller.serviceTypeList.length,
                        cacheExtent: 200, // Performance optimization
                        itemBuilder: (context, index) {
                        String serviceType = controller.serviceTypeList[index]['service_type']?.toString() ?? '';
                        if (serviceType.isEmpty) return const SizedBox.shrink();
                        
                        // Wrap each checkbox in Obx to make it reactive
                        return Obx(() {
                          // Access the observable list directly
                          final services = controller.selectedServices;
                          // Use contains() - GetX should track this if we access the list properly
                          bool isSelected = services.contains(serviceType);
                          return CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            dense: true,
                            title: Text(
                              serviceType,
                              style: GoogleFonts.albertSans(
                                fontSize: 14,
                                color: const Color(0xFF1B1C1C),
                              ),
                            ),
                            value: isSelected,
                            activeColor: const Color(0xFF0054D3),
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? newValue) {
                              // Toggle the service type
                              controller.toggleServiceType(serviceType);
                            },
                          );
                        });
                      },
                    ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Dispose controller when dialog is dismissed
      disposeController();
    });
  }

  Widget _buildSelectedServicesChips() {
    if (controller.selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.selectedServices.map((service) {
        return Chip(
          label: Text(
            service,
            style: GoogleFonts.albertSans(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF0054D3),
          deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
          onDeleted: () {
            controller.selectedServices.remove(service);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSearchButton() {
    return GlobalUtils.CustomButton(
      text: 'Search',
      onPressed: controller.getCommercials,
      backgroundGradient: GlobalUtils.blueBtnGradientColor,
      borderColor: const Color(0xFF71A9FF),
      borderRadius: 12,
      textColor: Colors.white,
      textFontSize: 16,
      textFontWeight: FontWeight.w600,
      textStyle: GoogleFonts.albertSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      height: GlobalUtils.screenWidth * (60 / 393),
      showShadow: false,
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildFilterModalContent(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 18,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(width: 5),
            Text(
              'FILTER',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModal() {
    return const SizedBox.shrink();
  }

  Widget _buildFilterModalContent() {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside input fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Service Name Input
                        TextField(
                          controller: controller.serviceNameFilterController,
                          decoration: InputDecoration(
                            labelText: 'Service Name',
                            labelStyle: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: const Color(0xFF6B707E),
                            ),
                            hintText: 'Enter Service Name',
                            hintStyle: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: const Color(0xFFCCCCCC),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0054D3), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Service Type Input
                        TextField(
                          controller: controller.serviceTypeFilterController,
                          decoration: InputDecoration(
                            labelText: 'Service Type',
                            labelStyle: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: const Color(0xFF6B707E),
                            ),
                            hintText: 'Enter Service Type',
                            hintStyle: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: const Color(0xFFCCCCCC),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0054D3), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GlobalUtils.CustomButton(
                            text: 'CANCEL',
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.clearFilters();
                              Navigator.pop(context);
                            },
                            backgroundColor: Colors.white,
                            borderColor: const Color(0xFFE0E0E0),
                            borderRadius: 12,
                            textColor: const Color(0xFF1B1C1C),
                            textFontSize: 16,
                            textFontWeight: FontWeight.w600,
                            textStyle: GoogleFonts.albertSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B1C1C),
                            ),
                            height: GlobalUtils.screenWidth * (60 / 393),
                            showShadow: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlobalUtils.CustomButton(
                            text: 'APPLY',
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.pop(context);
                              controller.filterCommercials();
                            },
                            backgroundGradient: GlobalUtils.blueBtnGradientColor,
                            borderColor: const Color(0xFF71A9FF),
                            borderRadius: 12,
                            textColor: Colors.white,
                            textFontSize: 16,
                            textFontWeight: FontWeight.w600,
                            textStyle: GoogleFonts.albertSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            height: GlobalUtils.screenWidth * (60 / 393),
                            showShadow: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarginList() {
    if (controller.isLoading.value && controller.filteredMarginList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Color(0xFF0054D3)),
        ),
      );
    }

    if (controller.filteredMarginList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No commercials found',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B707E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Note: This ListView is inside a SingleChildScrollView and has NeverScrollableScrollPhysics
    // So it's not scrollable and doesn't need a Scrollbar
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredMarginList.length,
      cacheExtent: 200, // Performance optimization
      itemBuilder: (context, index) {
        final commercial = controller.filteredMarginList[index];
        return _buildMarginCard(commercial, index);
      },
    );
  }

  Widget _buildMarginCard(Map<String, dynamic> commercial, int index) {
    String serviceName = commercial['service_name']?.toString() ?? '---';
    String serviceType = commercial['service_type']?.toString() ?? '---';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Name',
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceName,
                  style: GoogleFonts.albertSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Type',
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceType,
                  style: GoogleFonts.albertSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Margin',
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // Navigate to Commercial Detail Screen
                    Get.to(() => CommercialDetailScreen(marginList: controller.filteredMarginList));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFF2196F3)),
                    ),
                    child: Text(
                      'View',
                      style: GoogleFonts.albertSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
