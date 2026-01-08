import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:payrupya/controllers/transaction_history_controller.dart';
import 'package:payrupya/utils/global_utils.dart';
import '../models/transaction_history_response_model_.dart';
import '../utils/ConsoleLog.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TransactionHistoryController controller;

  @override
  void initState() {
    super.initState();
    ConsoleLog.printColor("========== TransactionScreen initState CALLED ==========", color: "blue");
    controller = Get.put(TransactionHistoryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConsoleLog.printColor("postFrameCallback - calling fetchTransactionHistory", color: "blue");
      // ✅ Reset dates on initial screen load
      controller.fetchTransactionHistory(reset: true, resetDates: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        title: Text(
          'Transactions',
          style: GoogleFonts.albertSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Bar
            _buildSearchAndFilterBar(),

            // Transactions List
            Expanded(
              child:  Obx(() {
                if (controller.isInitialLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0054D3),
                    ),
                  );
                }

                if (controller.filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          'No Transactions Found',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B707E),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical:  12),
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final txn = controller.filteredTransactions[index];
                    return _buildTransactionTile(txn);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  //region buildSearchAndFilterBar
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                GlobalUtils.CustomTextField(
                  label: "Search",
                  showLabel: false,
                  controller: controller.searchController.value,
                  placeholder: "Search TXN ID, Service...",
                  height: GlobalUtils.screenWidth * (60 / 393),
                  width: double.infinity,
                  backgroundColor: Colors.white,
                  borderColor: Color(0xFFE2E5EC),
                  borderRadius: 16,
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B707E), size: 20),
                  placeholderStyle: GoogleFonts.albertSans(
                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                    color: Color(0xFF6B707E),
                  ),
                  inputTextStyle: GoogleFonts.albertSans(
                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                    color: Color(0xFF1B1C1C),
                  ),
                  onChanged: (value) {
                    controller.onSearchChanged(value);
                  },
                  onSubmitted: (value) {
                    // Keyboard submit action
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
                // Clear button - positioned over the text field
                Obx(() => controller.searchQuery.value.isNotEmpty
                    ? Positioned(
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            controller.searchController.value.clear();
                            controller.onSearchChanged('');
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F7FA),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.clear, color: Color(0xFF6B707E), size: 18),
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(),
            child: Container(
              width: GlobalUtils.screenWidth * (60 / 393),
              height: GlobalUtils.screenWidth * (60 / 393),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFE2E5EC)),
              ),
              child: Icon(Icons.tune_rounded, color: Color(0xFF0054D3), size: 24),
            ),
          ),
        ],
      ),
    );
  }
  //endregion

  //region buildTransactionTile
  Widget _buildTransactionTile(TransactionData txn) {
    bool isCredit = txn.chargedAmt != null && double.tryParse(txn. chargedAmt!) != null
        ? double.parse(txn.chargedAmt!) > 0
        : false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side:  Service Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.recordType ??  'Transaction',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1C1C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Date:  ${_formatDate(txn.requestDt)}',
                  style: GoogleFonts.albertSans(
                    fontSize: 11,
                    color: Color(0xFF6B707E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Txn ID: ${txn.portalTxnId ??  'N/A'}',
                  style: GoogleFonts.albertSans(
                    fontSize: 11,
                    color: Color(0xFF6B707E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right Side: Amount & Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${txn.chargedAmt ?? '0'}',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCredit ? Color(0xFF10B981) : Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Details Button
                  _buildIconButton(Icons.receipt_long_outlined, () {
                    _showTransactionDetailsBottomSheet(txn);
                  }),
                  SizedBox(width: 8),
                  // Print Button
                  _buildIconButton(Icons.print_outlined, () {
                    controller.printReceipt(context, txn.portalTxnId ??  '');
                  }),
                  SizedBox(width: 8),
                  // Share Button
                  _buildIconButton(Icons.share_outlined, () {
                    controller.shareReceipt(context, txn.portalTxnId ?? '');
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  //endregion

  //region buildIconButton
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFE2E5EC)),
        ),
        child: Icon(icon, size:  16, color: Color(0xFF6B707E)),
      ),
    );
  }
  //endregion

//region showFilterBottomSheet (✅ UPDATED WITH DATE RANGE)
  void _showFilterBottomSheet() {
    // ✅ Store current filter values before opening
    final previousServiceFilter = controller.selectedServiceFilter.value;
    final previousStatusFilter = controller.selectedStatusFilter.value;
    final previousFromDate = controller.customFromDate.value;
    final previousToDate = controller.customToDate.value;
    final previousSelectedDateRange = controller.selectedDateRange.value;
    final previousActualFromDate = controller.fromDate.value;
    final previousActualToDate = controller.toDate.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.albertSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1C1C),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // ✅ Restore previous values if closed without applying
                          controller.selectedServiceFilter.value = previousServiceFilter;
                          controller.selectedStatusFilter.value = previousStatusFilter;
                          controller.customFromDate.value = previousFromDate;
                          controller.customToDate.value = previousToDate;
                          controller.selectedDateRange.value = previousSelectedDateRange;
                          controller.fromDate.value = previousActualFromDate;
                          controller.toDate.value = previousActualToDate;
                          Get.back();
                        },
                        child: Icon(Icons.close, size: 24, color: Color(0xFF1B1C1C)),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // ✅ DATE RANGE FILTER
                  Text(
                    'Date Range',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Quick filters - Wrapped with Obx for reactive updates
                  Obx(() {
                    // Access reactive variable to trigger rebuild
                    final selected = controller.selectedDateRange.value;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Today', 'Last 7 Days', 'Last 30 Days']
                          .map((option) {
                        bool isSelected = selected == option;
                        return GestureDetector(
                          onTap: () {
                            controller.quickDateFilter(option);
                            controller.showCustomDateRange.value = false;
                          },
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF0054D3)
                                  : Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Color(0xFFE2E5EC)),
                            ),
                            child: Text(
                              option,
                              style: GoogleFonts.albertSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF1B1C1C),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  SizedBox(height: 16),

                  // ✅ Custom date range section
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.showCustomDateRange. value =
                          !controller.showCustomDateRange.value;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F7FA),
                            borderRadius: BorderRadius. circular(12),
                            border: Border.all(color: Color(0xFFE2E5EC)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Custom Date Range',
                                style: GoogleFonts.albertSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1B1C1C),
                                ),
                              ),
                              Icon(
                                controller.showCustomDateRange.value
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Color(0xFF6B707E),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.showCustomDateRange. value) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: 'From',
                                date: controller.customFromDate.value,
                                onDateSelected: (date) {
                                  controller.customFromDate.value = date;
                                  // ✅ Mark as custom when user selects custom date
                                  controller.selectedDateRange.value = 'Custom';
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildDatePicker(
                                label: 'To',
                                date: controller.customToDate.value,
                                onDateSelected: (date) {
                                  controller.customToDate.value = date;
                                  // ✅ Mark as custom when user selects custom date
                                  controller.selectedDateRange.value = 'Custom';
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  )),
                  SizedBox(height: 24),

                  // Service Filter
                  Text(
                    'Service',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing:  8,
                    children:  controller.services.map((service) {
                      bool isSelected =
                          controller.selectedServiceFilter.value == service;
                      return GestureDetector(
                        onTap: () {
                          controller.updateServiceFilter(service);
                        },
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF0054D3)
                                : Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? null
                                : Border.all(color: Color(0xFFE2E5EC)),
                          ),
                          child: Text(
                            service,
                            style: GoogleFonts.albertSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  SizedBox(height: 24),

                  // Status Filter
                  Text(
                    'Status',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.statuses.map((status) {
                      bool isSelected =
                          controller.selectedStatusFilter.value == status;
                      return GestureDetector(
                        onTap: () {
                          ConsoleLog.printInfo("Status selected: $status");
                          controller.updateStatusFilter(status);
                        },
                        child: Container(
                          padding:
                          EdgeInsets. symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ?  Color(0xFF0054D3)
                                : Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ?  null
                                : Border.all(color: Color(0xFFE2E5EC)),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts. albertSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Color(0xFF1B1C1C),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  SizedBox(height:  24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.resetFilters();
                            controller.showCustomDateRange.value = false;
                            
                            // ✅ Close bottom sheet first, then fetch
                            Get.back();
                            
                            // ✅ Fetch with reset dates (today)
                            controller.fetchTransactionHistory(reset: true, resetDates: true);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Color(0xFF0054D3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0054D3),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GlobalUtils.CustomButton(
                          text: 'Apply',
                          onPressed: () {
                            ConsoleLog.printColor("========== APPLY BUTTON PRESSED ==========", color: "yellow");
                            ConsoleLog.printColor("selectedDateRange: ${controller.selectedDateRange.value}", color: "yellow");
                            ConsoleLog.printColor("fromDate BEFORE apply: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(controller.fromDate.value)}", color: "yellow");
                            ConsoleLog.printColor("toDate BEFORE apply: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(controller.toDate.value)}", color: "yellow");
                            
                            // ✅ If custom date range is shown, apply it
                            if (controller.showCustomDateRange.value) {
                              ConsoleLog.printColor("Custom date range is shown - updating custom dates", color: "yellow");
                              controller.updateCustomDateRange(
                                controller.customFromDate.value,
                                controller.customToDate.value,
                              );
                            }
                            
                            ConsoleLog.printColor("fromDate AFTER custom update: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(controller.fromDate.value)}", color: "yellow");
                            ConsoleLog.printColor("toDate AFTER custom update: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(controller.toDate.value)}", color: "yellow");
                            
                            // ✅ Close bottom sheet first, then fetch
                            Get.back();
                            
                            ConsoleLog.printColor("Calling fetchTransactionHistory with resetDates: false", color: "yellow");
                            // ✅ Fetch transaction history with selected date range (don't reset dates)
                            controller.fetchTransactionHistory(reset: true, resetDates: false);
                          },
                          width: double.infinity,
                          height: 48,
                          backgroundGradient:
                          GlobalUtils.blueBtnGradientColor,
                          borderRadius: 12,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height:  20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
//endregion

//region buildDatePicker (✅ NEW - Theme matching calendar)
  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime. now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF0054D3), // Header color
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1B1C1C),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF0054D3),
                  ),
                ),
              ),
              child: child! ,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child:  Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE2E5EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 11,
                color: Color(0xFF6B707E),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  // Update when date changes
                  final displayDate = label == 'From'
                      ? controller.customFromDate.value
                      : controller.customToDate.value;

                  return Text(
                    DateFormat('dd-MM-yyyy').format(displayDate),
                    style: GoogleFonts.albertSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                  );
                }),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color:  Color(0xFF6B707E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
//endregion


  //region showTransactionDetailsBottomSheet
  void _showTransactionDetailsBottomSheet(TransactionData txn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:  (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Header
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction Details',
                        style: GoogleFonts.albertSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1C1C),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons. close, size: 24, color: Color(0xFF1B1C1C)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(height: 1, color: Color(0xFFE2E5EC)),
                  SizedBox(height:  16),

                  // Details Grid - ✅ Updated with correct API fields
                  ..._buildDetailRows([
              ('Date & Time', txn.requestDt ??  'N/A'),
              ('Txn ID', txn.portalTxnId ?? 'N/A'),
              ('Customer ID', txn.customerId ?? 'N/A'),
              ('Service Txn ID', txn.serviceTxnId ?? 'N/A'),
              ('Service', txn.recordType ?? 'N/A'),
              ('Txn Amount', '₹${txn.txnAmt ?? '0'}'),
              ('Net Amount', '₹${txn.chargedAmt ?? '0'}'),
              ('Wallet Name', txn.walletName ??  'N/A'),
              ('Status', txn.portalStatus ?? 'N/A'),
              ]),

          SizedBox(height:  20),
          Divider(height: 1, color: Color(0xFFE2E5EC)),
          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GlobalUtils.CustomButton(
                  text: 'Print',
                  onPressed: () {
                    Navigator.pop(context);
                    controller.printReceipt(context, txn.portalTxnId ?? '');
                  },
                  width: double. infinity,
                  height: 48,
                  backgroundGradient: GlobalUtils.blueBtnGradientColor,
                  borderRadius: 12,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.shareReceipt(context, txn.portalTxnId ?? '');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Color(0xFF0054D3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Share',
                    style:  GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0054D3),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height:  16),
          ],
        ),
      ),
    ),
    ),
    ),
    );
  }
  //endregion

  //region buildDetailRows
  List<Widget> _buildDetailRows(List<(String, String)> items) {
    return items.map((item) {
      bool isStatus = item.$1 == 'Status';
      String statusValue = item.$2.toUpperCase();
      Color statusColor = Colors.black;

      if (isStatus) {
        if (statusValue == 'PENDING') {
          statusColor = Color(0xFFF59E0B); // Yellow/Amber
        } else if (statusValue == 'SUCCESSFUL') {
          statusColor = Color(0xFF10B981); // Green
        } else if (statusValue == 'FAILED') {
          statusColor = Color(0xFFEF4444); // Red
        }
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                item.$1,
                style: GoogleFonts.albertSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B707E),
                ),
              ),
              Text(
                item.$2,
                style: GoogleFonts. albertSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      );
    }).toList();
  }
  //endregion

  //region formatDate
  String _formatDate(String?  dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
//endregion
}