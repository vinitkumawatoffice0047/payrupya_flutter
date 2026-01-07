// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// // Import your controllers and models
// // import '../controllers/aeps_controller.dart';
// // import '../models/aeps_response_models.dart';
//
// /// AEPS Choose Service Screen
// /// Shared screen for both AEPS One (Fingpay) and AEPS Three (Instantpay)
// /// Displays available services and handles transactions
// class AepsChooseServiceScreen extends StatefulWidget {
//   final String aepsType; // 'AEPS1' for Fingpay, 'AEPS3' for Instantpay
//
//   const AepsChooseServiceScreen({
//     super.key,
//     required this.aepsType,
//   });
//
//   @override
//   State<AepsChooseServiceScreen> createState() => _AepsChooseServiceScreenState();
// }
//
// class _AepsChooseServiceScreenState extends State<AepsChooseServiceScreen> {
//   // Controller - Replace with your actual controller
//   // final AepsController controller = Get.find<AepsController>();
//
//   // State variables
//   bool isLoading = false;
//   bool isTransactionLoading = false;
//   String selectedService = '';
//   String selectedDevice = '';
//   String? selectedBankId;
//   String? selectedBankName;
//   String? selectedBankIin;
//
//   // Show confirmation modal
//   bool showConfirmModal = false;
//   bool showResultModal = false;
//
//   // Transaction result
//   Map<String, dynamic>? transactionResult;
//   Map<String, dynamic>? confirmationData;
//
//   // Device list
//   final List<Map<String, String>> deviceList = [
//     {'name': 'Select Device', 'value': ''},
//     {'name': 'Mantra', 'value': 'MANTRA'},
//     {'name': 'Mantra MFS110', 'value': 'MFS110'},
//     {'name': 'Mantra Iris', 'value': 'MIS100V2'},
//     {'name': 'Morpho L0', 'value': 'MORPHO'},
//     {'name': 'Morpho L1', 'value': 'Idemia'},
//     {'name': 'TATVIK', 'value': 'TATVIK'},
//     {'name': 'Secugen', 'value': 'SecuGen Corp.'},
//     {'name': 'Startek', 'value': 'STARTEK'},
//   ];
//
//   // Demo bank list (replace with API data)
//   List<Map<String, dynamic>> bankList = [
//     {'id': '1', 'bank_name': 'State Bank of India', 'bank_iin': 'SBIN', 'is_fav': '1'},
//     {'id': '2', 'bank_name': 'HDFC Bank', 'bank_iin': 'HDFC', 'is_fav': '0'},
//     {'id': '3', 'bank_name': 'ICICI Bank', 'bank_iin': 'ICIC', 'is_fav': '0'},
//     {'id': '4', 'bank_name': 'Axis Bank', 'bank_iin': 'UTIB', 'is_fav': '0'},
//     {'id': '5', 'bank_name': 'Punjab National Bank', 'bank_iin': 'PUNB', 'is_fav': '0'},
//   ];
//
//   // Demo recent transactions
//   List<Map<String, dynamic>> recentTransactions = [];
//
//   // Form controllers
//   final aadhaarController = TextEditingController(text: '123412341234');
//   final mobileController = TextEditingController(text: '9876543210');
//   final amountController = TextEditingController();
//   final searchController = TextEditingController();
//
//   // Services based on AEPS type
//   List<Map<String, String>> get services {
//     if (widget.aepsType == 'AEPS1') {
//       // Fingpay services
//       return [
//         {'name': 'Balance Check', 'value': 'BCSFNGPY', 'icon': 'account_balance_wallet'},
//         {'name': 'Cash Withdrawal', 'value': 'CWSFNGPY', 'icon': 'money'},
//         {'name': 'Mini Statement', 'value': 'MSTFNGPY', 'icon': 'receipt_long'},
//         {'name': 'Aadhaar Pay', 'value': 'ADRFNGPY', 'icon': 'payments'},
//       ];
//     } else {
//       // Instantpay services
//       return [
//         {'name': 'Balance Check', 'value': 'BAP', 'icon': 'account_balance_wallet'},
//         {'name': 'Cash Withdrawal', 'value': 'WAP', 'icon': 'money'},
//         {'name': 'Mini Statement', 'value': 'SAP', 'icon': 'receipt_long'},
//       ];
//     }
//   }
//
//   // Check if selected service requires amount
//   bool get showAmountInput {
//     return selectedService == 'CWSFNGPY' ||
//            selectedService == 'WAP' ||
//            selectedService == 'ADRFNGPY';
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchBankList();
//     _fetchRecentTransactions();
//   }
//
//   @override
//   void dispose() {
//     aadhaarController.dispose();
//     mobileController.dispose();
//     amountController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }
//
//   /// Fetch bank list
//   Future<void> _fetchBankList() async {
//     setState(() => isLoading = true);
//     try {
//       // TODO: Replace with actual API call
//       // final response = await controller.fetchAepsBankList();
//       // if (response?.respCode == 'RCS') {
//       //   bankList = response?.data ?? [];
//       // }
//       await Future.delayed(const Duration(milliseconds: 500));
//     } catch (e) {
//       _showSnackbar('Error fetching banks: $e', isError: true);
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   /// Fetch recent transactions
//   Future<void> _fetchRecentTransactions() async {
//     try {
//       // TODO: Replace with actual API call
//       // final serviceType = widget.aepsType == 'AEPS1' ? 'AEPS2' : 'AEPS3';
//       // final response = await controller.fetchRecentTransactions(serviceType);
//       // if (response?.respCode == 'RCS') {
//       //   recentTransactions = response?.data ?? [];
//       // }
//
//       // Demo data
//       recentTransactions = [
//         {
//           'request_dt': '2024-12-24 10:30:00',
//           'record_type': 'Balance Check',
//           'txn_amt': '0',
//           'portal_status': 'Success',
//           'portal_txn_id': 'TXN123456',
//         },
//         {
//           'request_dt': '2024-12-23 15:45:00',
//           'record_type': 'Cash Withdrawal',
//           'txn_amt': '5000',
//           'portal_status': 'Success',
//           'portal_txn_id': 'TXN123455',
//         },
//       ];
//       setState(() {});
//     } catch (e) {
//       debugPrint('Error fetching transactions: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E5BFF)))
//           : Stack(
//               children: [
//                 SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Service Selection
//                         _buildServiceSelection(),
//                         const SizedBox(height: 24),
//
//                         // Transaction Form (shown after service selection)
//                         if (selectedService.isNotEmpty) _buildTransactionForm(),
//
//                         // Recent Transactions
//                         if (recentTransactions.isNotEmpty) ...[
//                           const SizedBox(height: 32),
//                           _buildRecentTransactions(),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Confirmation Modal
//                 if (showConfirmModal) _buildConfirmationModal(),
//
//                 // Result Modal
//                 if (showResultModal) _buildResultModal(),
//               ],
//             ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     final title = widget.aepsType == 'AEPS1' ? 'AEPS One (Fingpay)' : 'AEPS Three (Instantpay)';
//     return AppBar(
//       backgroundColor: const Color(0xFF2E5BFF),
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         title,
//         style: GoogleFonts.albertSans(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       centerTitle: true,
//     );
//   }
//
//   /// Service Selection Grid
//   Widget _buildServiceSelection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Service',
//           style: GoogleFonts.albertSans(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 16),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: services.length,
//           itemBuilder: (context, index) {
//             final service = services[index];
//             final isSelected = selectedService == service['value'];
//             return _buildServiceCard(service, isSelected);
//           },
//         ),
//       ],
//     );
//   }
//
//   /// Service Card Widget
//   Widget _buildServiceCard(Map<String, String> service, bool isSelected) {
//     IconData getIcon(String iconName) {
//       switch (iconName) {
//         case 'account_balance_wallet':
//           return Icons.account_balance_wallet;
//         case 'money':
//           return Icons.money;
//         case 'receipt_long':
//           return Icons.receipt_long;
//         case 'payments':
//           return Icons.payments;
//         default:
//           return Icons.help_outline;
//       }
//     }
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedService = service['value'] ?? '';
//           amountController.clear();
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF2E5BFF) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey[300]!,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: const Color(0xFF2E5BFF).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               getIcon(service['icon'] ?? ''),
//               size: 32,
//               color: isSelected ? Colors.white : const Color(0xFF2E5BFF),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               service['name'] ?? '',
//               style: GoogleFonts.albertSans(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? Colors.white : Colors.grey[800],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Transaction Form
//   Widget _buildTransactionForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Transaction Details',
//           style: GoogleFonts.albertSans(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Device Selection
//         _buildDropdownField(
//           label: 'Select Device',
//           value: selectedDevice,
//           items: deviceList,
//           icon: Icons.devices,
//           onChanged: (value) => setState(() => selectedDevice = value ?? ''),
//         ),
//         const SizedBox(height: 16),
//
//         // Bank Selection
//         _buildBankSelector(),
//         const SizedBox(height: 16),
//
//         // Aadhaar Number (readonly)
//         _buildTextField(
//           label: 'Aadhaar Number',
//           controller: aadhaarController,
//           prefixIcon: Icons.credit_card,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         // Mobile Number (readonly)
//         _buildTextField(
//           label: 'Mobile Number',
//           controller: mobileController,
//           prefixIcon: Icons.phone_android,
//           readOnly: true,
//         ),
//
//         // Amount (for withdrawal and Aadhaar Pay)
//         if (showAmountInput) ...[
//           const SizedBox(height: 16),
//           _buildTextField(
//             label: 'Amount',
//             controller: amountController,
//             prefixIcon: Icons.currency_rupee,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter amount';
//               }
//               final amount = int.tryParse(value) ?? 0;
//               if (amount < 100) {
//                 return 'Minimum amount is ₹100';
//               }
//               if (amount > 10000) {
//                 return 'Maximum amount is ₹10,000';
//               }
//               return null;
//             },
//           ),
//         ],
//         const SizedBox(height: 24),
//
//         // Proceed Button
//         SizedBox(
//           width: double.infinity,
//           height: 52,
//           child: ElevatedButton(
//             onPressed: _canProceed() ? _confirmTransaction : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2E5BFF),
//               foregroundColor: Colors.white,
//               disabledBackgroundColor: Colors.grey[300],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text(
//               'Proceed',
//               style: GoogleFonts.albertSans(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Bank Selector with search
//   Widget _buildBankSelector() {
//     return GestureDetector(
//       onTap: _showBankSelectionModal,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.account_balance, color: Colors.grey[600]),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 selectedBankName ?? 'Select Bank',
//                 style: GoogleFonts.albertSans(
//                   fontSize: 16,
//                   color: selectedBankName != null ? Colors.grey[800] : Colors.grey[500],
//                 ),
//               ),
//             ),
//             Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Show bank selection modal
//   void _showBankSelectionModal() {
//     List<Map<String, dynamic>> filteredBanks = List.from(bankList);
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Container(
//               height: MediaQuery.of(context).size.height * 0.75,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   // Handle
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 12),
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//
//                   // Title
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Select Bank',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(Icons.close),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Search
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: TextField(
//                       controller: searchController,
//                       onChanged: (value) {
//                         setModalState(() {
//                           if (value.isEmpty) {
//                             filteredBanks = List.from(bankList);
//                           } else {
//                             filteredBanks = bankList.where((bank) {
//                               final name = (bank['bank_name'] ?? '').toLowerCase();
//                               return name.contains(value.toLowerCase());
//                             }).toList();
//                           }
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Search bank...',
//                         prefixIcon: const Icon(Icons.search),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Favorites Section
//                   if (bankList.any((b) => b['is_fav'] == '1')) ...[
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.star, color: Colors.amber, size: 18),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Favorites',
//                             style: GoogleFonts.albertSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       height: 40,
//                       child: ListView(
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         children: bankList
//                             .where((b) => b['is_fav'] == '1')
//                             .map((bank) => Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         selectedBankId = bank['id'];
//                                         selectedBankName = bank['bank_name'];
//                                         selectedBankIin = bank['bank_iin'];
//                                       });
//                                       Navigator.pop(context);
//                                     },
//                                     child: Chip(
//                                       label: Text(
//                                         bank['bank_name'] ?? '',
//                                         style: GoogleFonts.albertSans(fontSize: 12),
//                                       ),
//                                       backgroundColor: Colors.amber[50],
//                                     ),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Divider(),
//                   ],
//
//                   // Bank List
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredBanks.length,
//                       itemBuilder: (context, index) {
//                         final bank = filteredBanks[index];
//                         final isFavorite = bank['is_fav'] == '1';
//                         return ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blue[50],
//                             child: Text(
//                               (bank['bank_name'] ?? 'B')[0],
//                               style: TextStyle(color: Colors.blue[700]),
//                             ),
//                           ),
//                           title: Text(
//                             bank['bank_name'] ?? '',
//                             style: GoogleFonts.albertSans(),
//                           ),
//                           subtitle: Text(
//                             bank['bank_iin'] ?? '',
//                             style: GoogleFonts.albertSans(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           trailing: IconButton(
//                             icon: Icon(
//                               isFavorite ? Icons.star : Icons.star_border,
//                               color: isFavorite ? Colors.amber : Colors.grey,
//                             ),
//                             onPressed: () => _toggleFavorite(bank, setModalState),
//                           ),
//                           onTap: () {
//                             setState(() {
//                               selectedBankId = bank['id'];
//                               selectedBankName = bank['bank_name'];
//                               selectedBankIin = bank['bank_iin'];
//                             });
//                             Navigator.pop(context);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).then((_) => searchController.clear());
//   }
//
//   /// Toggle favorite bank
//   Future<void> _toggleFavorite(Map<String, dynamic> bank, StateSetter setModalState) async {
//     final isFavorite = bank['is_fav'] == '1';
//     final action = isFavorite ? 'REMOVE' : 'ADD';
//
//     try {
//       // TODO: Replace with actual API call
//       // await controller.markFavoriteBank(action);
//
//       // Update local state
//       setModalState(() {
//         final index = bankList.indexWhere((b) => b['id'] == bank['id']);
//         if (index != -1) {
//           bankList[index]['is_fav'] = isFavorite ? '0' : '1';
//         }
//       });
//       setState(() {});
//
//       _showSnackbar(isFavorite ? 'Removed from favorites' : 'Added to favorites');
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     }
//   }
//
//   /// Check if can proceed
//   bool _canProceed() {
//     if (selectedDevice.isEmpty) return false;
//     if (selectedBankId == null) return false;
//     if (showAmountInput && amountController.text.isEmpty) return false;
//     return true;
//   }
//
//   /// Confirm transaction
//   Future<void> _confirmTransaction() async {
//     setState(() => isTransactionLoading = true);
//
//     try {
//       // TODO: Replace with actual API call
//       // final skey = widget.aepsType == 'AEPS1' ? selectedService : selectedService;
//       // final response = await controller.aepsTransactionProcess(skey, 'CONFIRM', '');
//       // if (response?.respCode == 'RCS') {
//       //   confirmationData = response?.data;
//       //   setState(() => showConfirmModal = true);
//       // }
//
//       // Demo data
//       await Future.delayed(const Duration(seconds: 1));
//       confirmationData = {
//         'commission': '5.00',
//         'tds': '1.00',
//         'totalcharge': '2.00',
//         'totalccf': '0.50',
//         'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
//         'chargedamt': '3.50',
//         'txnpin': '0',
//       };
//       setState(() => showConfirmModal = true);
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     } finally {
//       setState(() => isTransactionLoading = false);
//     }
//   }
//
//   /// Confirmation Modal
//   Widget _buildConfirmationModal() {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.all(24),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Confirm Transaction',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => setState(() => showConfirmModal = false),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 const SizedBox(height: 16),
//
//                 // Transaction details
//                 _buildConfirmRow('Service', _getServiceName(selectedService)),
//                 _buildConfirmRow('Bank', selectedBankName ?? ''),
//                 if (showAmountInput)
//                   _buildConfirmRow('Amount', '₹${amountController.text}'),
//                 _buildConfirmRow('Commission', '₹${confirmationData?['commission'] ?? '0'}'),
//                 _buildConfirmRow('TDS', '₹${confirmationData?['tds'] ?? '0'}'),
//                 _buildConfirmRow('Charges', '₹${confirmationData?['totalcharge'] ?? '0'}'),
//                 const Divider(),
//                 _buildConfirmRow(
//                   'Total Deduction',
//                   '₹${confirmationData?['chargedamt'] ?? '0'}',
//                   isBold: true,
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Fingerprint Section
//                 Center(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(40),
//                         ),
//                         child: Icon(
//                           Icons.fingerprint,
//                           size: 48,
//                           color: Colors.grey[400],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'Scan fingerprint to proceed',
//                         style: GoogleFonts.albertSans(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => setState(() => showConfirmModal = false),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'Cancel',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: isTransactionLoading ? null : _processTransaction,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2E5BFF),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: isTransactionLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : Text(
//                                 'Scan & Process',
//                                 style: GoogleFonts.albertSans(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Confirm row widget
//   Widget _buildConfirmRow(String label, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
//               color: Colors.grey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Process transaction
//   Future<void> _processTransaction() async {
//     setState(() => isTransactionLoading = true);
//
//     try {
//       // TODO: Replace with actual fingerprint scan and API call
//       // final fingerprintResult = await FingerprintService.scan(...);
//       // final skey = widget.aepsType == 'AEPS1' ? selectedService : selectedService;
//       // final response = await controller.aepsTransactionProcess(skey, 'PROCESS', fingerprintResult.encdata);
//       // transactionResult = response?.data?.toJson();
//
//       // Demo: Simulate success
//       await Future.delayed(const Duration(seconds: 2));
//       transactionResult = {
//         'txn_status': 'Success',
//         'txn_desc': 'Transaction completed successfully',
//         'balance': '15000.00',
//         'date': '2024-12-24 12:30:00',
//         'txnid': 'TXN${DateTime.now().millisecondsSinceEpoch}',
//         'opid': 'OP${DateTime.now().millisecondsSinceEpoch}',
//         'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
//       };
//
//       setState(() {
//         showConfirmModal = false;
//         showResultModal = true;
//       });
//
//       // Refresh transactions
//       _fetchRecentTransactions();
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     } finally {
//       setState(() => isTransactionLoading = false);
//     }
//   }
//
//   /// Result Modal
//   Widget _buildResultModal() {
//     final isSuccess = transactionResult?['txn_status'] == 'Success';
//
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.all(24),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Status Icon
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: isSuccess ? Colors.green[50] : Colors.red[50],
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Icon(
//                     isSuccess ? Icons.check_circle : Icons.error,
//                     size: 48,
//                     color: isSuccess ? Colors.green : Colors.red,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Status Text
//                 Text(
//                   isSuccess ? 'Transaction Successful!' : 'Transaction Failed',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: isSuccess ? Colors.green[700] : Colors.red[700],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   transactionResult?['txn_desc'] ?? '',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Transaction Details
//                 if (isSuccess) ...[
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         _buildResultRow('Transaction ID', transactionResult?['txnid'] ?? ''),
//                         _buildResultRow('Date', transactionResult?['date'] ?? ''),
//                         if (transactionResult?['balance'] != null)
//                           _buildResultRow('Balance', '₹${transactionResult?['balance']}'),
//                         if (showAmountInput)
//                           _buildResultRow('Amount', '₹${transactionResult?['trasamt']}'),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//
//                 // Buttons
//                 Row(
//                   children: [
//                     if (isSuccess)
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: _printReceipt,
//                           icon: const Icon(Icons.print),
//                           label: Text(
//                             'Print',
//                             style: GoogleFonts.albertSans(fontWeight: FontWeight.w600),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (isSuccess) const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             showResultModal = false;
//                             selectedService = '';
//                             amountController.clear();
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2E5BFF),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'Done',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Result row widget
//   Widget _buildResultRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.albertSans(
//               fontSize: 13,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.albertSans(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Print receipt
//   Future<void> _printReceipt() async {
//     // TODO: Implement print receipt functionality
//     _showSnackbar('Receipt printing coming soon!');
//   }
//
//   /// Recent Transactions Section
//   Widget _buildRecentTransactions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Recent Transactions',
//               style: GoogleFonts.albertSans(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             TextButton(
//               onPressed: _fetchRecentTransactions,
//               child: Text(
//                 'Refresh',
//                 style: GoogleFonts.albertSans(
//                   fontSize: 14,
//                   color: const Color(0xFF2E5BFF),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: recentTransactions.length,
//           itemBuilder: (context, index) {
//             final txn = recentTransactions[index];
//             final isSuccess = txn['portal_status'] == 'Success';
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: isSuccess ? Colors.green[50] : Colors.red[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       isSuccess ? Icons.check_circle : Icons.error,
//                       color: isSuccess ? Colors.green : Colors.red,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           txn['record_type'] ?? '',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           txn['request_dt'] ?? '',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       if (txn['txn_amt'] != null && txn['txn_amt'] != '0')
//                         Text(
//                           '₹${txn['txn_amt']}',
//                           style: GoogleFonts.albertSans(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       Text(
//                         txn['portal_status'] ?? '',
//                         style: GoogleFonts.albertSans(
//                           fontSize: 12,
//                           color: isSuccess ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   /// Get service name from key
//   String _getServiceName(String key) {
//     final service = services.firstWhere(
//       (s) => s['value'] == key,
//       orElse: () => {'name': key},
//     );
//     return service['name'] ?? key;
//   }
//
//   /// Text field widget
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required IconData prefixIcon,
//     bool readOnly = false,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       style: GoogleFonts.albertSans(
//         fontSize: 16,
//         color: readOnly ? Colors.grey[600] : Colors.grey[800],
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.albertSans(
//           fontSize: 14,
//           color: Colors.grey[600],
//         ),
//         prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
//         filled: true,
//         fillColor: readOnly ? Colors.grey[100] : Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
//         ),
//       ),
//     );
//   }
//
//   /// Dropdown field widget
//   Widget _buildDropdownField({
//     required String label,
//     required String value,
//     required List<Map<String, String>> items,
//     required IconData icon,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value.isEmpty ? null : value,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.albertSans(
//           fontSize: 14,
//           color: Colors.grey[600],
//         ),
//         prefixIcon: Icon(icon, color: Colors.grey[600]),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
//         ),
//       ),
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item['value'],
//           child: Text(
//             item['name'] ?? '',
//             style: GoogleFonts.albertSans(fontSize: 16),
//           ),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
//
//   /// Show snackbar
//   void _showSnackbar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: GoogleFonts.albertSans()),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }







/*
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ✅ Import controllers
import '../controllers/aeps_controller.dart';
import '../controllers/payrupya_home_screen_controller.dart';
import '../utils/ConsoleLog.dart';
import '../utils/global_utils.dart';

/// AEPS Choose Service Screen
/// Shared screen for both AEPS One (Fingpay) and AEPS Three (Instantpay)
/// Displays available services and handles transactions
class AepsChooseServiceScreen extends StatefulWidget {
  final String aepsType; // 'AEPS1' for Fingpay, 'AEPS3' for Instantpay

  const AepsChooseServiceScreen({
    super.key,
    required this.aepsType,
  });

  @override
  State<AepsChooseServiceScreen> createState() => _AepsChooseServiceScreenState();
}

class _AepsChooseServiceScreenState extends State<AepsChooseServiceScreen> {
  // ✅ Controllers - Use Get.find()
  AepsController get aepsController => Get.find<AepsController>();
  PayrupyaHomeScreenController get homeController => Get.find<PayrupyaHomeScreenController>();

  // State variables
  bool isLoading = false;
  bool isTransactionLoading = false;
  String selectedService = '';
  String selectedDevice = '';

  // Show confirmation modal
  bool showConfirmModal = false;
  bool showResultModal = false;

  // Transaction result
  Map<String, dynamic>? transactionResult;
  Map<String, dynamic>? confirmationData;

  // Device list
  final List<Map<String, String>> deviceList = [
    {'name': 'Select Device', 'value': ''},
    {'name': 'Mantra', 'value': 'MANTRA'},
    {'name': 'Mantra MFS110', 'value': 'MFS110'},
    {'name': 'Mantra Iris', 'value': 'MIS100V2'},
    {'name': 'Morpho L0', 'value': 'MORPHO'},
    {'name': 'Morpho L1', 'value': 'Idemia'},
    {'name': 'TATVIK', 'value': 'TATVIK'},
    {'name': 'Secugen', 'value': 'SecuGen Corp.'},
    {'name': 'Startek', 'value': 'STARTEK'},
  ];

  // Form controllers
  final amountController = TextEditingController();
  final searchController = TextEditingController();

  // Services based on AEPS type
  List<Map<String, String>> get services {
    if (widget.aepsType == 'AEPS1') {
      // Fingpay services
      return [
        {'name': 'Balance Check', 'value': 'BCSFNGPY', 'icon': 'account_balance_wallet'},
        {'name': 'Cash Withdrawal', 'value': 'CWSFNGPY', 'icon': 'money'},
        {'name': 'Mini Statement', 'value': 'MSTFNGPY', 'icon': 'receipt_long'},
        {'name': 'Aadhaar Pay', 'value': 'ADRFNGPY', 'icon': 'payments'},
      ];
    } else {
      // Instantpay services
      return [
        {'name': 'Balance Check', 'value': 'BAP', 'icon': 'account_balance_wallet'},
        {'name': 'Cash Withdrawal', 'value': 'WAP', 'icon': 'money'},
        {'name': 'Mini Statement', 'value': 'SAP', 'icon': 'receipt_long'},
      ];
    }
  }

  // Check if selected service requires amount
  bool get showAmountInput {
    return selectedService == 'CWSFNGPY' ||
        selectedService == 'WAP' ||
        selectedService == 'ADRFNGPY';
  }

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// ✅ Initialize screen with real data
  Future<void> _initializeScreen() async {
    setState(() => isLoading = true);
    try {
      // Fetch bank list from API
      await aepsController.fetchAepsBankList();

      // Fetch recent transactions
      await aepsController.fetchRecentTransactions(
        widget.aepsType == 'AEPS1' ? 'AEPS2' : 'AEPS3',
      );

      // Set service device from controller
      selectedDevice = aepsController.serviceSelectedDevice.value;

    } catch (e) {
      ConsoleLog.printError("Error initializing screen: $e");
      Fluttertoast.showToast(msg: 'Error loading data');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      // appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E5BFF)))
          : SafeArea(
            child: Column(
              children: [
                buildCustomAppBar(),
                Expanded(
                  child: Stack(
                          children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Selection
                          _buildServiceSelection(),
                          const SizedBox(height: 24),

                          // Transaction Form (shown after service selection)
                          if (selectedService.isNotEmpty) _buildTransactionForm(),

                          // Recent Transactions
                          Obx(() {
                            if (aepsController.recentTransactions.isNotEmpty) {
                              return Column(
                                children: [
                                  const SizedBox(height: 32),
                                  _buildRecentTransactions(),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Confirmation Modal
                  if (showConfirmModal) _buildConfirmationModal(),

                  // Result Modal
                  if (showResultModal) _buildResultModal(),

                  // ✅ Biometric Scanning Modal
                  Obx(() {
                    if (aepsController.isBiometricScanning.value) {
                      return _buildBiometricScanningModal();
                    }
                    return const SizedBox.shrink();
                  }),
                          ],
                        ),
                ),
              ],
            ),
          ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = widget.aepsType == 'AEPS1' ? 'AEPS One (Fingpay)' : 'AEPS Three (Instantpay)';
    return AppBar(
      backgroundColor: const Color(0xFF2E5BFF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        title,
        style: GoogleFonts.albertSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget buildCustomAppBar() {
    final title = widget.aepsType == 'AEPS1' ? 'AEPS One (Fingpay)' : 'AEPS Three (Instantpay)';
    return Padding(
      padding: EdgeInsets.only(
          left: GlobalUtils.screenWidth * 0.04,
          right: GlobalUtils.screenWidth * 0.04,
          bottom: 16
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            title,
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

  /// ✅ Biometric Scanning Modal
  Widget _buildBiometricScanningModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fingerprint Animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Color(0xFF2E5BFF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Scanning Fingerprint...',
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please place your finger on the device',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xFF2E5BFF)),
            ],
          ),
        ),
      ),
    );
  }

  /// Service Selection Grid
  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final isSelected = selectedService == service['value'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedService = service['value'] ?? '';
                  aepsController.selectedService.value = selectedService;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2E5BFF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF2E5BFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getServiceIcon(service['icon'] ?? ''),
                      size: 32,
                      color: isSelected ? Colors.white : const Color(0xFF2E5BFF),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['name'] ?? '',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Get icon for service
  IconData _getServiceIcon(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'money':
        return Icons.money;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'payments':
        return Icons.payments;
      default:
        return Icons.help_outline;
    }
  }

  /// Transaction Form
  Widget _buildTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getServiceName(selectedService),
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ Aadhaar Number (from controller - readonly)
          _buildTextField(
            label: 'Aadhaar Number',
            controller: aepsController.serviceAadhaarController,
            prefixIcon: Icons.credit_card,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // ✅ Mobile Number (from controller - readonly)
          _buildTextField(
            label: 'Mobile Number',
            controller: aepsController.serviceMobileController,
            prefixIcon: Icons.phone_android,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Device Selection
          _buildDropdownField(
            label: 'Select Device',
            value: selectedDevice,
            items: deviceList,
            icon: Icons.fingerprint,
            onChanged: (value) {
              setState(() {
                selectedDevice = value ?? '';
                aepsController.serviceSelectedDevice.value = selectedDevice;
              });
            },
          ),
          const SizedBox(height: 16),

          // ✅ Bank Selection (from controller)
          _buildBankSelector(),
          const SizedBox(height: 16),

          // Amount Input (for Cash Withdrawal and Aadhaar Pay)
          if (showAmountInput) ...[
            _buildTextField(
              label: 'Amount',
              controller: amountController,
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
          ],

          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() => ElevatedButton(
              onPressed: _canProceed() && !aepsController.isBiometricScanning.value
                  ? _initiateTransaction
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5BFF),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: aepsController.isFingpayTransactionLoading.value ||
                  aepsController.isInstantpayTransactionLoading.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Proceed',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  /// ✅ Bank Selector using controller data
  Widget _buildBankSelector() {
    return Obx(() {
      final selectedBank = aepsController.selectedBankName.value;

      return GestureDetector(
        onTap: _showBankSelectionModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedBank.isEmpty ? 'Select Bank' : selectedBank,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    color: selectedBank.isEmpty ? Colors.grey[600] : Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ],
          ),
        ),
      );
    });
  }

  /// ✅ Show Bank Selection Modal
  void _showBankSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Bank',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    aepsController.filterAepsBankList(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search bank...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ✅ Bank List from controller
              Expanded(
                child: Obx(() {
                  final banks = aepsController.filteredBankList;

                  if (banks.isEmpty) {
                    return Center(
                      child: Text(
                        'No banks found',
                        style: GoogleFonts.albertSans(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      final isFavorite = bank.isFav == '1';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Text(
                            (bank.bankName ?? 'B')[0],
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ),
                        title: Text(
                          bank.bankName ?? '',
                          style: GoogleFonts.albertSans(),
                        ),
                        subtitle: Text(
                          bank.bankIin ?? '',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(bank),
                        ),
                        onTap: () {
                          aepsController.selectedBankId.value = bank.id ?? '';
                          aepsController.selectedBankName.value = bank.bankName ?? '';
                          aepsController.selectedBankIin.value = bank.bankIin ?? '';
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    ).then((_) => searchController.clear());
  }

  /// ✅ Toggle favorite bank
  Future<void> _toggleFavorite(dynamic bank) async {
    final isFavorite = bank.isFav == '1';
    final action = isFavorite ? 'REMOVE' : 'ADD';

    try {
      await aepsController.markFavoriteBank(
        bankId: bank.id ?? '',
        action: action,
      );
      Fluttertoast.showToast(
        msg: isFavorite ? 'Removed from favorites' : 'Added to favorites',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  /// Check if can proceed
  bool _canProceed() {
    if (selectedDevice.isEmpty) return false;
    if (aepsController.selectedBankId.value.isEmpty) return false;
    if (showAmountInput && amountController.text.isEmpty) return false;
    return true;
  }

  /// ✅ Initiate Transaction - Calls real biometric and API
  Future<void> _initiateTransaction() async {
    // Validate amount for withdrawal
    if (showAmountInput) {
      final amount = int.tryParse(amountController.text) ?? 0;
      if (amount < 100) {
        Fluttertoast.showToast(msg: 'Minimum amount is ₹100');
        return;
      }
      if (amount > 10000) {
        Fluttertoast.showToast(msg: 'Maximum amount is ₹10,000');
        return;
      }
    }

    // Set amount in controller
    aepsController.serviceAmountController.text = amountController.text;

    if (widget.aepsType == 'AEPS1') {
      // ✅ Fingpay Transaction
      await _processFingpayTransaction();
    } else {
      // ✅ Instantpay Transaction - First confirm, then process
      await _processInstantpayTransaction();
    }
  }

  /// ✅ Process Fingpay Transaction
  Future<void> _processFingpayTransaction() async {
    try {
      // For Fingpay - Direct process with biometric
      final success = await aepsController.processFingpayTransactionWithBiometric(
        skey: selectedService,
      );

      if (success) {
        setState(() {
          transactionResult = {
            'txn_status': 'Success',
            'txn_desc': aepsController.transactionResult.value?.txnDesc ?? 'Transaction completed',
            'balance': aepsController.transactionResult.value?.balance ?? '',
            'date': DateTime.now().toString(),
            'txnid': aepsController.transactionResult.value?.txnId ?? '',
            'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
          };
          showResultModal = true;
        });
      }
    } catch (e) {
      ConsoleLog.printError("Fingpay Transaction Error: $e");
      Fluttertoast.showToast(msg: 'Transaction failed: $e');
    }
  }

  /// ✅ Process Instantpay Transaction (Confirm → Process)
  Future<void> _processInstantpayTransaction() async {
    try {
      // Step 1: Confirm transaction (get charges)
      final confirmed = await aepsController.confirmInstantpayTransaction(
        skey: selectedService,
      );

      if (confirmed && aepsController.confirmationData.value != null) {
        // Show confirmation modal
        confirmationData = {
          'commission': aepsController.confirmationData.value?.commission ?? '0',
          'tds': aepsController.confirmationData.value?.tds ?? '0',
          'totalcharge': aepsController.confirmationData.value?.totalCharge ?? '0',
          'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
          'chargedamt': aepsController.confirmationData.value?.chargedAmt ?? '0',
        };
        setState(() => showConfirmModal = true);
      }
    } catch (e) {
      ConsoleLog.printError("Instantpay Confirm Error: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  /// Confirmation Modal
  Widget _buildConfirmationModal() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirm Transaction',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => showConfirmModal = false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),

                // Transaction Details
                _buildConfirmRow('Service', _getServiceName(selectedService)),
                _buildConfirmRow('Bank', aepsController.selectedBankName.value),
                if (showAmountInput)
                  _buildConfirmRow('Amount', '₹${confirmationData?['trasamt'] ?? '0'}'),
                _buildConfirmRow('Commission', '₹${confirmationData?['commission'] ?? '0'}'),
                _buildConfirmRow('TDS', '₹${confirmationData?['tds'] ?? '0'}'),
                _buildConfirmRow('Total Charges', '₹${confirmationData?['totalcharge'] ?? '0'}'),
                const Divider(),
                _buildConfirmRow(
                  'Total Deduction',
                  '₹${confirmationData?['chargedamt'] ?? '0'}',
                  isBold: true,
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => showConfirmModal = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: aepsController.isBiometricScanning.value
                            ? null
                            : _processTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: aepsController.isInstantpayTransactionLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Scan & Process',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm row widget
  Widget _buildConfirmRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Process transaction with biometric
  Future<void> _processTransaction() async {
    try {
      final success = await aepsController.processInstantpayTransactionWithBiometric(
        skey: selectedService,
      );

      if (success) {
        setState(() {
          showConfirmModal = false;
          transactionResult = {
            'txn_status': 'Success',
            'txn_desc': aepsController.transactionResult.value?.txnDesc ?? 'Transaction completed',
            'balance': aepsController.transactionResult.value?.balance ?? '',
            'date': DateTime.now().toString(),
            'txnid': aepsController.transactionResult.value?.txnId ?? '',
            'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
          };
          showResultModal = true;
        });

        // Refresh transactions
        await aepsController.fetchRecentTransactions(
          widget.aepsType == 'AEPS1' ? 'AEPS2' : 'AEPS3',
        );
      } else {
        setState(() => showConfirmModal = false);
      }
    } catch (e) {
      ConsoleLog.printError("Process Transaction Error: $e");
      Fluttertoast.showToast(msg: 'Transaction failed');
      setState(() => showConfirmModal = false);
    }
  }

  /// Result Modal
  Widget _buildResultModal() {
    final isSuccess = transactionResult?['txn_status'] == 'Success';

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 48,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),

                // Status Text
                Text(
                  isSuccess ? 'Transaction Successful!' : 'Transaction Failed',
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  transactionResult?['txn_desc'] ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                if (isSuccess) ...[
                  const SizedBox(height: 24),
                  // Balance
                  if (transactionResult?['balance'] != null &&
                      transactionResult!['balance'].toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Color(0xFF2E5BFF)),
                          const SizedBox(width: 8),
                          Text(
                            'Balance: ₹${transactionResult?['balance']}',
                            style: GoogleFonts.albertSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E5BFF),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Transaction Details
                  _buildResultRow('Transaction ID', transactionResult?['txnid'] ?? '-'),
                  _buildResultRow('Date', transactionResult?['date']?.toString().split('.')[0] ?? '-'),
                  if (showAmountInput)
                    _buildResultRow('Amount', '₹${transactionResult?['trasamt'] ?? '0'}'),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    if (isSuccess)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _printReceipt,
                          icon: const Icon(Icons.print),
                          label: Text(
                            'Print',
                            style: GoogleFonts.albertSans(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (isSuccess) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showResultModal = false;
                            selectedService = '';
                            amountController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Result row widget
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Print receipt
  void _printReceipt() {
    // TODO: Implement print receipt functionality
    Fluttertoast.showToast(msg: 'Print receipt functionality coming soon');
  }

  /// Recent Transactions
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: aepsController.recentTransactions.length > 5
              ? 5
              : aepsController.recentTransactions.length,
          itemBuilder: (context, index) {
            final txn = aepsController.recentTransactions[index];
            final isSuccess = txn.portalStatus?.toLowerCase() == 'success';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.close,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn.recordType ?? 'Transaction',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          txn.requestDt ?? '',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (txn.txnAmt != null && txn.txnAmt != '0')
                        Text(
                          '₹${txn.txnAmt}',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      Text(
                        txn.portalStatus ?? '',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }

  /// Get service name from key
  String _getServiceName(String key) {
    final service = services.firstWhere(
          (s) => s['value'] == key,
      orElse: () => {'name': key},
    );
    return service['name'] ?? key;
  }

  /// Text field widget
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.albertSans(
        fontSize: 16,
        color: readOnly ? Colors.grey[600] : Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.albertSans(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
        ),
      ),
    );
  }

  /// Dropdown field widget
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.albertSans(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(
            item['name'] ?? '',
            style: GoogleFonts.albertSans(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}*/









import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/aeps_controller.dart';
import '../controllers/payrupya_home_screen_controller.dart';
import '../utils/ConsoleLog.dart';
import '../utils/global_utils.dart';

/// AEPS Choose Service Screen
/// Shared screen for both AEPS One (Fingpay) and AEPS Three (Instantpay)
/// Displays available services and handles transactions
class AepsChooseServiceScreen extends StatefulWidget {
  final String aepsType; // 'AEPS1' for Fingpay, 'AEPS3' for Instantpay

  const AepsChooseServiceScreen({
    super.key,
    required this.aepsType,
  });

  @override
  State<AepsChooseServiceScreen> createState() => _AepsChooseServiceScreenState();
}

class _AepsChooseServiceScreenState extends State<AepsChooseServiceScreen> {
  // Controllers
  PayrupyaHomeScreenController get homeScreenController => Get.find<PayrupyaHomeScreenController>();
  AepsController get aepsController => Get.find<AepsController>();

  // Local state variables
  RxBool isLoading = false.obs;
  RxBool isTransactionLoading = false.obs;
  RxString selectedService = ''.obs;
  RxString selectedDevice = ''.obs;

  // Bank selection
  Rxn<String> selectedBankId = Rxn<String>();
  Rxn<String> selectedBankName = Rxn<String>();
  Rxn<String> selectedBankIin = Rxn<String>();

  // Modal states
  RxBool showConfirmModal = false.obs;
  RxBool showResultModal = false.obs;

  // Transaction result
  Rxn<Map<String, dynamic>> transactionResult = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> confirmationData = Rxn<Map<String, dynamic>>();

  // Bank list - using RxList for reactivity
  RxList<Map<String, dynamic>> bankList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> favoriteBankList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredBankList = <Map<String, dynamic>>[].obs;

  // Recent transactions
  RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;

  // Device list - Updated for January 2026
  final List<Map<String, String>> deviceList = [
    {'name': 'Select Device', 'value': ''},
    {'name': 'Morpho L1', 'value': 'Idemia'},
    {'name': 'Mantra MFS110', 'value': 'MFS110'},
    {'name': 'Mantra IRIS', 'value': 'MIS100V2'},
    {'name': 'Face Authentication', 'value': 'FACE_AUTH'},
  ];

  // Form controllers
  final mobileController = TextEditingController();
  final aadhaarController = TextEditingController();
  final amountController = TextEditingController();
  final searchController = TextEditingController();

  // Services based on AEPS type
  List<Map<String, String>> get services {
    if (widget.aepsType == 'AEPS1') {
      // Fingpay services
      return [
        {'name': 'Balance Check', 'value': 'BCSFNGPY', 'icon': 'account_balance_wallet'},
        {'name': 'Cash Withdrawal', 'value': 'CWSFNGPY', 'icon': 'money'},
        {'name': 'Mini Statement', 'value': 'MSTFNGPY', 'icon': 'receipt_long'},
        {'name': 'Aadhaar Pay', 'value': 'ADRFNGPY', 'icon': 'payments'},
      ];
    } else {
      // Instantpay services
      return [
        {'name': 'Balance Check', 'value': 'BAP', 'icon': 'account_balance_wallet'},
        {'name': 'Cash Withdrawal', 'value': 'WAP', 'icon': 'money'},
        {'name': 'Mini Statement', 'value': 'SAP', 'icon': 'receipt_long'},
      ];
    }
  }

  // Check if selected service requires amount
  bool get showAmountInput {
    return selectedService.value == 'CWSFNGPY' ||
        selectedService.value == 'WAP' ||
        selectedService.value == 'ADRFNGPY';
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    mobileController.dispose();
    aadhaarController.dispose();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// Initialize data - NO loading screen needed as 2FA already completed
  Future<void> _initializeData() async {
    try {
      // Pre-fill from controller if available
      if (aepsController.serviceAadhaarController.text.isNotEmpty) {
        aadhaarController.text = aepsController.serviceAadhaarController.text;
      } else if (aepsController.aadhaarController.text.isNotEmpty) {
        aadhaarController.text = aepsController.aadhaarController.text;
      }

      if (aepsController.serviceMobileController.text.isNotEmpty) {
        mobileController.text = aepsController.serviceMobileController.text;
      } else if (aepsController.mobileController.text.isNotEmpty) {
        mobileController.text = aepsController.mobileController.text;
      }

      // Fetch bank list in background (no loading screen)
      _fetchBankList();
      _fetchRecentTransactions();
    } catch (e) {
      ConsoleLog.printError('Error initializing data: $e');
    }
  }

  /// Fetch bank list
  Future<void> _fetchBankList() async {
    try {
      // Call actual API
      await aepsController.fetchAepsBankList();

      // Convert from controller's bank list
      bankList.clear();
      for (var bank in aepsController.allBankList) {
        bankList.add({
          'id': bank.id,
          'bank_name': bank.bankName,
          'bank_iin': bank.bankIin,
          'is_fav': bank.isFav,
        });
      }

      // Update favorites list
      _updateFavoritesList();

      // Initialize filtered list
      filteredBankList.assignAll(bankList);

    } catch (e) {
      ConsoleLog.printError('Error fetching banks: $e');
      _showSnackbar('Error fetching bank list', isError: true);
    }
  }

  /// Update favorites list from bankList
  void _updateFavoritesList() {
    favoriteBankList.clear();
    favoriteBankList.addAll(
        bankList.where((b) => b['is_fav'] == '1').toList()
    );
  }

  /// Fetch recent transactions
  Future<void> _fetchRecentTransactions() async {
    try {
      final serviceType = widget.aepsType == 'AEPS1' ? 'AEPS2' : 'AEPS3';
      await aepsController.fetchRecentTransactions(serviceType);

      // Convert from controller
      recentTransactions.clear();
      for (var txn in aepsController.recentTransactions) {
        recentTransactions.add({
          'request_dt': txn.requestDt ?? '',
          'record_type': txn.recordType ?? '',
          'txn_amt': txn.txnAmt ?? '0',
          'portal_status': txn.portalStatus ?? '',
          'portal_txn_id': txn.portalTxnId ?? '',
        });
      }
    } catch (e) {
      ConsoleLog.printError('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (isLoading.value) {
                    return _buildLoadingWidget();
                  }
                  return _buildMainContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final title = widget.aepsType == 'AEPS1' ? 'AEPS One (Fingpay)' : 'AEPS Three (Instantpay)';
    return Padding(
      padding: EdgeInsets.only(
        left: GlobalUtils.screenWidth * 0.04,
        right: GlobalUtils.screenWidth * 0.04,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            title,
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

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E5BFF)),
          ),
          SizedBox(height: 20),
          Text('Processing...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Selection
                _buildServiceSelection(),
                const SizedBox(height: 24),

                // Transaction Form (shown after service selection)
                Obx(() {
                  if (selectedService.value.isNotEmpty) {
                    return _buildTransactionForm();
                  }
                  return const SizedBox.shrink();
                }),

                // Recent Transactions
                Obx(() {
                  if (recentTransactions.isNotEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildRecentTransactions(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),

        // Confirmation Modal
        Obx(() => showConfirmModal.value ? _buildConfirmationModal() : const SizedBox.shrink()),

        // Result Modal
        Obx(() => showResultModal.value ? _buildResultModal() : const SizedBox.shrink()),
      ],
    );
  }

  /// Service Selection Grid
  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Obx(() {
              final isSelected = selectedService.value == service['value'];
              return _buildServiceCard(service, isSelected);
            });
          },
        ),
      ],
    );
  }

  /// Service Card Widget
  Widget _buildServiceCard(Map<String, String> service, bool isSelected) {
    IconData getIcon(String iconName) {
      switch (iconName) {
        case 'account_balance_wallet':
          return Icons.account_balance_wallet;
        case 'money':
          return Icons.money;
        case 'receipt_long':
          return Icons.receipt_long;
        case 'payments':
          return Icons.payments;
        default:
          return Icons.help_outline;
      }
    }

    return GestureDetector(
      onTap: () {
        selectedService.value = service['value'] ?? '';
        amountController.clear();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E5BFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF2E5BFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIcon(service['icon'] ?? ''),
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF2E5BFF),
            ),
            const SizedBox(height: 8),
            Text(
              service['name'] ?? '',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Transaction Form
  Widget _buildTransactionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Details',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        // Device Selection
        _buildDropdownField(
          label: 'Select Device',
          value: selectedDevice.value,
          items: deviceList,
          icon: Icons.devices,
          onChanged: (value) {
            selectedDevice.value = value ?? '';
            aepsController.serviceSelectedDevice.value = value ?? '';
          },
        ),
        const SizedBox(height: 16),

        // Bank Selection
        _buildBankSelector(),
        const SizedBox(height: 16),

        // ✅ Mobile Number Field
        GlobalUtils.CustomTextField(
          label: 'Mobile Number',
          prefixIcon: Icon(Icons.phone_android),
          controller: mobileController,
          keyboardType: TextInputType.phone,
          // inputFormatters: [
          //   FilteringTextInputFormatter.digitsOnly,
          //   LengthLimitingTextInputFormatter(10),
          // ],
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Please enter mobile number';
          //   }
          //   if (value.length != 10) {
          //     return 'Mobile number must be 10 digits';
          //   }
          //   return null;
          // },
          onChanged: (value) {
            aepsController.serviceMobileController.text = value;
          },
        ),
        const SizedBox(height: 16),

        // ✅ Aadhaar Number Field (NEW - was missing)
        GlobalUtils.CustomTextField(
          label: 'Aadhaar Number',
          prefixIcon: Icon(Icons.credit_card),
          controller: aadhaarController,
          keyboardType: TextInputType.number,
          // inputFormatters: [
          //   FilteringTextInputFormatter.digitsOnly,
          //   LengthLimitingTextInputFormatter(12),
          // ],
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Please enter Aadhaar number';
          //   }
          //   if (value.length != 12) {
          //     return 'Aadhaar number must be 12 digits';
          //   }
          //   // Verhoeff validation can be added here
          //   return null;
          // },
          onChanged: (value) {
            aepsController.serviceAadhaarController.text = value;
          },
        ),

        // Amount (for withdrawal and Aadhaar Pay)
        if (showAmountInput) ...[
          const SizedBox(height: 16),
          GlobalUtils.CustomTextField(
            label: 'Amount',
            prefixIcon: Icon(Icons.currency_rupee),
            controller: amountController,
            keyboardType: TextInputType.number,
            // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter amount';
            //   }
            //   final amount = int.tryParse(value) ?? 0;
            //   if (amount < 100) {
            //     return 'Minimum amount is ₹100';
            //   }
            //   if (amount > 10000) {
            //     return 'Maximum amount is ₹10,000';
            //   }
            //   return null;
            // },
            onChanged: (value) {
              aepsController.serviceAmountController.text = value;
            },
          ),
          // Amount in words
          if (amountController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _amountToWords(amountController.text),
              style: GoogleFonts.albertSans(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
        const SizedBox(height: 24),

        // Proceed Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _canProceed() ? _confirmTransaction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(() => isTransactionLoading.value
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Proceed',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
        ),
      ],
    );
  }

  /// Dropdown field builder
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(
            item['name'] ?? '',
            style: GoogleFonts.albertSans(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Bank Selector with favorites
  Widget _buildBankSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Favorite Banks Row (if any)
        Obx(() {
          if (favoriteBankList.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Favorite Banks',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteBankList.length,
                  itemBuilder: (context, index) {
                    final bank = favoriteBankList[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          selectedBankId.value = bank['id'];
                          selectedBankName.value = bank['bank_name'];
                          selectedBankIin.value = bank['bank_iin'];
                          // Update controller
                          aepsController.selectedBankId.value = bank['id'] ?? '';
                          aepsController.selectedBankName.value = bank['bank_name'] ?? '';
                          aepsController.selectedBankIin.value = bank['bank_iin'] ?? '';
                        },
                        child: Chip(
                          label: Text(
                            bank['bank_name'] ?? '',
                            style: GoogleFonts.albertSans(fontSize: 12),
                          ),
                          backgroundColor: Colors.amber[50],
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeFavorite(bank),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),

        // Bank Selection Button
        GestureDetector(
          onTap: _showBankSelectionModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Text(
                    selectedBankName.value ?? 'Select Bank',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: selectedBankName.value != null ? Colors.grey[800] : Colors.grey[500],
                    ),
                  )),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Show bank selection modal
  void _showBankSelectionModal() {
    filteredBankList.assignAll(bankList);
    searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFDEEBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Bank',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      filteredBankList.assignAll(bankList);
                    } else {
                      filteredBankList.assignAll(
                        bankList.where((bank) {
                          final name = (bank['bank_name'] ?? '').toLowerCase();
                          return name.contains(value.toLowerCase());
                        }).toList(),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search bank...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Bank List
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: filteredBankList.length,
                  itemBuilder: (context, index) {
                    final bank = filteredBankList[index];
                    final isFavorite = bank['is_fav'] == '1';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(
                          (bank['bank_name'] ?? 'B')[0],
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                      title: Text(
                        bank['bank_name'] ?? '',
                        style: GoogleFonts.albertSans(
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        bank['bank_iin'] ?? '',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(bank),
                      ),
                      onTap: () {
                        selectedBankId.value = bank['id'];
                        selectedBankName.value = bank['bank_name'];
                        selectedBankIin.value = bank['bank_iin'];
                        // Update controller
                        aepsController.selectedBankId.value = bank['id'] ?? '';
                        aepsController.selectedBankName.value = bank['bank_name'] ?? '';
                        aepsController.selectedBankIin.value = bank['bank_iin'] ?? '';
                        Navigator.pop(context);
                      },
                    );
                  },
                )),
              ),
            ],
          ),
        );
      },
    ).then((_) => searchController.clear());
  }

  /// ✅ Toggle favorite bank - FIXED
  Future<void> _toggleFavorite(Map<String, dynamic> bank) async {
    final isFavorite = bank['is_fav'] == '1';
    final action = isFavorite ? 'REMOVE' : 'ADD';
    final bankId = bank['id'];
    final bankIIN = bank['bank_iin'];

    try {
      // Call API to update favorite status
      bool success = await aepsController.markFavoriteBank(
        bankIIN: bankIIN,
        bankId: bankId ?? '',
        action: action,
      );

      if (success) {
        // ✅ Update local state immediately
        final index = bankList.indexWhere((b) => b['id'] == bankId);
        if (index != -1) {
          // Create new map to trigger reactivity
          final updatedBank = Map<String, dynamic>.from(bankList[index]);
          updatedBank['is_fav'] = isFavorite ? '0' : '1';
          bankList[index] = updatedBank;

          // Update filtered list too
          final filteredIndex = filteredBankList.indexWhere((b) => b['id'] == bankId);
          if (filteredIndex != -1) {
            filteredBankList[filteredIndex] = updatedBank;
          }
        }

        // ✅ Update favorites list
        _updateFavoritesList();

        _showSnackbar(isFavorite ? 'Removed from favorites' : 'Added to favorites');
      }
    } catch (e) {
      ConsoleLog.printError('Error toggling favorite: $e');
      _showSnackbar('Error updating favorite', isError: true);
    }
  }

  /// ✅ Remove from favorites - FIXED
  Future<void> _removeFavorite(Map<String, dynamic> bank) async {
    final bankId = bank['id'];
    final bankIIN = bank['bank_iin'];

    try {
      // Call API to remove favorite
      bool success = await aepsController.markFavoriteBank(
        bankIIN: bankIIN,
        bankId: bankId ?? '',
        action: 'REMOVE',
      );

      if (success) {
        // ✅ Update local state immediately
        final index = bankList.indexWhere((b) => b['id'] == bankId);
        if (index != -1) {
          final updatedBank = Map<String, dynamic>.from(bankList[index]);
          updatedBank['is_fav'] = '0';
          bankList[index] = updatedBank;
        }

        // ✅ Update favorites list immediately
        _updateFavoritesList();

        _showSnackbar('Removed from favorites');
      }
    } catch (e) {
      ConsoleLog.printError('Error removing favorite: $e');
      _showSnackbar('Error removing favorite', isError: true);
    }
  }

  /// Check if can proceed
  bool _canProceed() {
    if (selectedDevice.value.isEmpty) return false;
    if (selectedBankId.value == null) return false;
    if (mobileController.text.length != 10) return false;
    if (aadhaarController.text.length != 12) return false;
    if (showAmountInput && amountController.text.isEmpty) return false;
    return true;
  }

  /// Confirm transaction
  Future<void> _confirmTransaction() async {
    isTransactionLoading.value = true;

    try {
      final skey = selectedService.value;

      if (widget.aepsType == 'AEPS1') {
        // Fingpay - directly process (no confirmation step)
        showConfirmModal.value = true;
        confirmationData.value = {
          'commission': '0',
          'tds': '0',
          'totalcharge': '0',
          'chargedamt': '0',
          'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
          'txnpin': '0',
        };
      } else {
        // Instantpay - confirm first
        bool confirmed = await aepsController.confirmInstantpayTransaction(skey: skey);

        if (confirmed && aepsController.confirmationData.value != null) {
          confirmationData.value = {
            'commission': aepsController.confirmationData.value!.commission,
            'tds': aepsController.confirmationData.value!.tds,
            'totalcharge': aepsController.confirmationData.value!.totalCharge,
            'chargedamt': aepsController.confirmationData.value!.chargedAmt,
            'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
            'txnpin': aepsController.confirmationData.value!.txnPin,
          };
          showConfirmModal.value = true;
        }
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      isTransactionLoading.value = false;
    }
  }

  /// Build confirmation modal
  Widget _buildConfirmationModal() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirm Transaction',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showConfirmModal.value = false,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Transaction details
                _buildConfirmRow('Service', _getServiceName(selectedService.value)),
                _buildConfirmRow('Bank', selectedBankName.value ?? ''),
                _buildConfirmRow('Aadhaar', '${aadhaarController.text.substring(0, 4)}****${aadhaarController.text.substring(8)}'),
                _buildConfirmRow('Mobile', mobileController.text),
                if (showAmountInput)
                  _buildConfirmRow('Amount', '₹${amountController.text}'),
                _buildConfirmRow('Commission', '₹${confirmationData.value?['commission'] ?? '0'}'),
                _buildConfirmRow('TDS', '₹${confirmationData.value?['tds'] ?? '0'}'),
                _buildConfirmRow('Charges', '₹${confirmationData.value?['totalcharge'] ?? '0'}'),
                const Divider(),
                _buildConfirmRow(
                  'Total Deduction',
                  '₹${confirmationData.value?['chargedamt'] ?? '0'}',
                  isBold: true,
                ),
                const SizedBox(height: 24),

                // Fingerprint Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          selectedDevice.value == 'FACE_AUTH'
                              ? Icons.face
                              : selectedDevice.value == 'MIS100V2'
                              ? Icons.remove_red_eye
                              : Icons.fingerprint,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedDevice.value == 'FACE_AUTH'
                            ? 'Scan face to proceed'
                            : selectedDevice.value == 'MIS100V2'
                            ? 'Scan iris to proceed'
                            : 'Scan fingerprint to proceed',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => showConfirmModal.value = false,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: isTransactionLoading.value ? null : _processTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isTransactionLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Scan & Process',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm row widget
  Widget _buildConfirmRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Process transaction
  Future<void> _processTransaction() async {
    isTransactionLoading.value = true;

    try {
      final skey = selectedService.value;
      bool success = false;

      if (widget.aepsType == 'AEPS1') {
        // Fingpay transaction
        success = await aepsController.processFingpayTransactionWithBiometric(skey: skey);
      } else {
        // Instantpay transaction
        success = await aepsController.processInstantpayTransactionWithBiometric(skey: skey);
      }

      if (success && aepsController.transactionResult.value != null) {
        transactionResult.value = {
          'txn_status': aepsController.transactionResult.value!.txnStatus,
          'txn_desc': aepsController.transactionResult.value!.txnDesc,
          'balance': aepsController.transactionResult.value!.balance,
          'txnid': aepsController.transactionResult.value!.txnId,
          'opid': aepsController.transactionResult.value!.opId,
          'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
        };

        showConfirmModal.value = false;
        showResultModal.value = true;

        // Refresh transactions
        _fetchRecentTransactions();
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      isTransactionLoading.value = false;
    }
  }

  /// Result Modal
  Widget _buildResultModal() {
    final isSuccess = transactionResult.value?['txn_status'] == 'Success';

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 48,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),

                // Status Text
                Text(
                  isSuccess ? 'Transaction Successful!' : 'Transaction Failed',
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transactionResult.value?['txn_desc'] ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Transaction Details
                if (isSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildResultRow('Transaction ID', transactionResult.value?['txnid'] ?? ''),
                        if (transactionResult.value?['balance'] != null)
                          _buildResultRow('Balance', '₹${transactionResult.value?['balance']}'),
                        if (showAmountInput)
                          _buildResultRow('Amount', '₹${transactionResult.value?['trasamt']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showResultModal.value = false;
                      selectedService.value = '';
                      amountController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5BFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Result row widget
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Transactions
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            final txn = recentTransactions[index];
            return _buildTransactionCard(txn);
          },
        )),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    final status = txn['portal_status'] ?? '';
    final isSuccess = status.toLowerCase() == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['record_type'] ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn['request_dt'] ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${txn['txn_amt'] ?? '0'}',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.albertSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== UTILITY METHODS ====================

  String _getServiceName(String value) {
    final service = services.firstWhere(
          (s) => s['value'] == value,
      orElse: () => {'name': value},
    );
    return service['name'] ?? value;
  }

  void _showSnackbar(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  String _amountToWords(String amount) {
    if (amount.isEmpty) return '';

    try {
      int num = int.parse(amount);
      if (num == 0) return 'Zero Rupees';

      final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
        'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
        'Seventeen', 'Eighteen', 'Nineteen'];
      final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

      String words = '';

      if (num >= 10000000) {
        words += '${ones[num ~/ 10000000]} Crore ';
        num %= 10000000;
      }
      if (num >= 100000) {
        words += '${ones[num ~/ 100000]} Lakh ';
        num %= 100000;
      }
      if (num >= 1000) {
        words += '${ones[num ~/ 1000]} Thousand ';
        num %= 1000;
      }
      if (num >= 100) {
        words += '${ones[num ~/ 100]} Hundred ';
        num %= 100;
      }
      if (num >= 20) {
        words += '${tens[num ~/ 10]} ';
        num %= 10;
      }
      if (num > 0) {
        words += '${ones[num]} ';
      }

      return '${words.trim()} Rupees';
    } catch (e) {
      return '';
    }
  }
}