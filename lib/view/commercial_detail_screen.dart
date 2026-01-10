import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/my_commercials_controller.dart';
import '../utils/global_utils.dart';
import '../utils/ConsoleLog.dart';

class CommercialDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> marginList;

  const CommercialDetailScreen({super.key, required this.marginList});

  @override
  State<CommercialDetailScreen> createState() => _CommercialDetailScreenState();
}

class _CommercialDetailScreenState extends State<CommercialDetailScreen> {
  String selectedPlanType = 'bank'; // 'bank' = Standard Plan, 'bank1' = Special Plan
  List<Map<String, dynamic>> standardPlanList = [];
  List<Map<String, dynamic>> specialPlanList = [];
  late MyCommercialsController controller;
  final ScrollController _planListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<MyCommercialsController>();
    standardPlanList = widget.marginList;
    _fetchSpecialMargins();
  }

  @override
  void dispose() {
    _planListScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecialMargins() async {
    try {
      List<Map<String, dynamic>> result = await controller.fetchSpecialMargins(standardPlanList);
      setState(() {
        specialPlanList = result;
      });
    } catch (e) {
      ConsoleLog.printError('Error in _fetchSpecialMargins: $e');
      setState(() {
        specialPlanList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            // Segmented Control (Standard Plan / Special Plan)
            _buildSegmentedControl(),
            // Plan List
            Expanded(
              child: _buildPlanList(),
            ),
          ],
        ),
      ),
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

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton('bank', 'Standard Plan'),
          ),
          Expanded(
            child: _buildSegmentButton('bank1', 'Special Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String value, String label) {
    bool isSelected = selectedPlanType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0054D3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF6B707E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanList() {
    List<Map<String, dynamic>> currentList = selectedPlanType == 'bank' ? standardPlanList : specialPlanList;

    if (currentList.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: const Color(0xFF6B707E),
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
        controller: _planListScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        interactive: true,
        child: ListView.builder(
          controller: _planListScrollController,
          padding: const EdgeInsets.all(16),
          itemCount: currentList.length,
          cacheExtent: 200, // Performance optimization
          itemBuilder: (context, index) {
            return _buildPlanCard(currentList[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    String serviceName = plan['service_name']?.toString() ?? '---';
    String serviceType = plan['service_type']?.toString() ?? '---';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
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
                    _showMarginDetailModal(plan, index);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
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
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMarginDetailModal(Map<String, dynamic> plan, int index) {
    final ScrollController detailScrollController = ScrollController();
    bool isDisposed = false;

    void disposeController() {
      if (!isDisposed) {
        detailScrollController.dispose();
        isDisposed = true;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMarginDetailModalContent(plan, detailScrollController),
    ).then((_) {
      // Dispose controller when modal is dismissed
      disposeController();
    });
  }

  Widget _buildMarginDetailModalContent(Map<String, dynamic> plan, ScrollController scrollController) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Detail',
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
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8,
                  radius: const Radius.circular(4),
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBEBEBE)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDetailRow('Service Name', plan['service_name']?.toString() ?? '---'),
                          _buildDetailRow('Service Type', plan['service_type']?.toString() ?? '---'),
                          _buildDetailRow('Margin Type', plan['margin_type']?.toString() ?? '---'),
                          _buildDetailRow('Calculation Type', plan['calculation_type']?.toString() ?? '---'),
                          _buildDetailRow('Rate', plan['rate']?.toString() ?? '---'),
                          _buildDetailRow('Capping', plan['capping']?.toString() ?? '---'),
                          _buildDetailRow('Valid From', plan['valid_from']?.toString() ?? '---'),
                          _buildDetailRow('Valid To', plan['valid_to']?.toString() ?? '---', isLast: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String key, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: isLast ? 0 : 12,
      ),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: GoogleFonts.albertSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.albertSans(
                fontSize: 11,
                color: const Color(0xFF9F9F9F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
