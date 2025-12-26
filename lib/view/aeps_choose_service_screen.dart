import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your controllers and models
// import '../controllers/aeps_controller.dart';
// import '../models/aeps_response_models.dart';

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
  // Controller - Replace with your actual controller
  // final AepsController controller = Get.find<AepsController>();
  
  // State variables
  bool isLoading = false;
  bool isTransactionLoading = false;
  String selectedService = '';
  String selectedDevice = '';
  String? selectedBankId;
  String? selectedBankName;
  String? selectedBankIin;
  
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

  // Demo bank list (replace with API data)
  List<Map<String, dynamic>> bankList = [
    {'id': '1', 'bank_name': 'State Bank of India', 'bank_iin': 'SBIN', 'is_fav': '1'},
    {'id': '2', 'bank_name': 'HDFC Bank', 'bank_iin': 'HDFC', 'is_fav': '0'},
    {'id': '3', 'bank_name': 'ICICI Bank', 'bank_iin': 'ICIC', 'is_fav': '0'},
    {'id': '4', 'bank_name': 'Axis Bank', 'bank_iin': 'UTIB', 'is_fav': '0'},
    {'id': '5', 'bank_name': 'Punjab National Bank', 'bank_iin': 'PUNB', 'is_fav': '0'},
  ];

  // Demo recent transactions
  List<Map<String, dynamic>> recentTransactions = [];

  // Form controllers
  final aadhaarController = TextEditingController(text: '123412341234');
  final mobileController = TextEditingController(text: '9876543210');
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
    _fetchBankList();
    _fetchRecentTransactions();
  }

  @override
  void dispose() {
    aadhaarController.dispose();
    mobileController.dispose();
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// Fetch bank list
  Future<void> _fetchBankList() async {
    setState(() => isLoading = true);
    try {
      // TODO: Replace with actual API call
      // final response = await controller.fetchAepsBankList();
      // if (response?.respCode == 'RCS') {
      //   bankList = response?.data ?? [];
      // }
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showSnackbar('Error fetching banks: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Fetch recent transactions
  Future<void> _fetchRecentTransactions() async {
    try {
      // TODO: Replace with actual API call
      // final serviceType = widget.aepsType == 'AEPS1' ? 'AEPS2' : 'AEPS3';
      // final response = await controller.fetchRecentTransactions(serviceType);
      // if (response?.respCode == 'RCS') {
      //   recentTransactions = response?.data ?? [];
      // }
      
      // Demo data
      recentTransactions = [
        {
          'request_dt': '2024-12-24 10:30:00',
          'record_type': 'Balance Check',
          'txn_amt': '0',
          'portal_status': 'Success',
          'portal_txn_id': 'TXN123456',
        },
        {
          'request_dt': '2024-12-23 15:45:00',
          'record_type': 'Cash Withdrawal',
          'txn_amt': '5000',
          'portal_status': 'Success',
          'portal_txn_id': 'TXN123455',
        },
      ];
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E5BFF)))
          : Stack(
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
                        if (recentTransactions.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _buildRecentTransactions(),
                        ],
                      ],
                    ),
                  ),
                ),

                // Confirmation Modal
                if (showConfirmModal) _buildConfirmationModal(),

                // Result Modal
                if (showResultModal) _buildResultModal(),
              ],
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
            return _buildServiceCard(service, isSelected);
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
        setState(() {
          selectedService = service['value'] ?? '';
          amountController.clear();
        });
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
          value: selectedDevice,
          items: deviceList,
          icon: Icons.devices,
          onChanged: (value) => setState(() => selectedDevice = value ?? ''),
        ),
        const SizedBox(height: 16),

        // Bank Selection
        _buildBankSelector(),
        const SizedBox(height: 16),

        // Aadhaar Number (readonly)
        _buildTextField(
          label: 'Aadhaar Number',
          controller: aadhaarController,
          prefixIcon: Icons.credit_card,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        // Mobile Number (readonly)
        _buildTextField(
          label: 'Mobile Number',
          controller: mobileController,
          prefixIcon: Icons.phone_android,
          readOnly: true,
        ),

        // Amount (for withdrawal and Aadhaar Pay)
        if (showAmountInput) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Amount',
            controller: amountController,
            prefixIcon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              final amount = int.tryParse(value) ?? 0;
              if (amount < 100) {
                return 'Minimum amount is ₹100';
              }
              if (amount > 10000) {
                return 'Maximum amount is ₹10,000';
              }
              return null;
            },
          ),
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
            child: Text(
              'Proceed',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bank Selector with search
  Widget _buildBankSelector() {
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
                selectedBankName ?? 'Select Bank',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: selectedBankName != null ? Colors.grey[800] : Colors.grey[500],
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  /// Show bank selection modal
  void _showBankSelectionModal() {
    List<Map<String, dynamic>> filteredBanks = List.from(bankList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                      color: Colors.grey[300],
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
                        setModalState(() {
                          if (value.isEmpty) {
                            filteredBanks = List.from(bankList);
                          } else {
                            filteredBanks = bankList.where((bank) {
                              final name = (bank['bank_name'] ?? '').toLowerCase();
                              return name.contains(value.toLowerCase());
                            }).toList();
                          }
                        });
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

                  // Favorites Section
                  if (bankList.any((b) => b['is_fav'] == '1')) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Favorites',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: bankList
                            .where((b) => b['is_fav'] == '1')
                            .map((bank) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedBankId = bank['id'];
                                        selectedBankName = bank['bank_name'];
                                        selectedBankIin = bank['bank_iin'];
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Chip(
                                      label: Text(
                                        bank['bank_name'] ?? '',
                                        style: GoogleFonts.albertSans(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.amber[50],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                  ],

                  // Bank List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
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
                            style: GoogleFonts.albertSans(),
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
                            onPressed: () => _toggleFavorite(bank, setModalState),
                          ),
                          onTap: () {
                            setState(() {
                              selectedBankId = bank['id'];
                              selectedBankName = bank['bank_name'];
                              selectedBankIin = bank['bank_iin'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => searchController.clear());
  }

  /// Toggle favorite bank
  Future<void> _toggleFavorite(Map<String, dynamic> bank, StateSetter setModalState) async {
    final isFavorite = bank['is_fav'] == '1';
    final action = isFavorite ? 'REMOVE' : 'ADD';

    try {
      // TODO: Replace with actual API call
      // await controller.markFavoriteBank(action);

      // Update local state
      setModalState(() {
        final index = bankList.indexWhere((b) => b['id'] == bank['id']);
        if (index != -1) {
          bankList[index]['is_fav'] = isFavorite ? '0' : '1';
        }
      });
      setState(() {});

      _showSnackbar(isFavorite ? 'Removed from favorites' : 'Added to favorites');
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  /// Check if can proceed
  bool _canProceed() {
    if (selectedDevice.isEmpty) return false;
    if (selectedBankId == null) return false;
    if (showAmountInput && amountController.text.isEmpty) return false;
    return true;
  }

  /// Confirm transaction
  Future<void> _confirmTransaction() async {
    setState(() => isTransactionLoading = true);

    try {
      // TODO: Replace with actual API call
      // final skey = widget.aepsType == 'AEPS1' ? selectedService : selectedService;
      // final response = await controller.aepsTransactionProcess(skey, 'CONFIRM', '');
      // if (response?.respCode == 'RCS') {
      //   confirmationData = response?.data;
      //   setState(() => showConfirmModal = true);
      // }

      // Demo data
      await Future.delayed(const Duration(seconds: 1));
      confirmationData = {
        'commission': '5.00',
        'tds': '1.00',
        'totalcharge': '2.00',
        'totalccf': '0.50',
        'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
        'chargedamt': '3.50',
        'txnpin': '0',
      };
      setState(() => showConfirmModal = true);
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      setState(() => isTransactionLoading = false);
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
                const SizedBox(height: 16),

                // Transaction details
                _buildConfirmRow('Service', _getServiceName(selectedService)),
                _buildConfirmRow('Bank', selectedBankName ?? ''),
                if (showAmountInput)
                  _buildConfirmRow('Amount', '₹${amountController.text}'),
                _buildConfirmRow('Commission', '₹${confirmationData?['commission'] ?? '0'}'),
                _buildConfirmRow('TDS', '₹${confirmationData?['tds'] ?? '0'}'),
                _buildConfirmRow('Charges', '₹${confirmationData?['totalcharge'] ?? '0'}'),
                const Divider(),
                _buildConfirmRow(
                  'Total Deduction',
                  '₹${confirmationData?['chargedamt'] ?? '0'}',
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
                          Icons.fingerprint,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Scan fingerprint to proceed',
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
                      child: ElevatedButton(
                        onPressed: isTransactionLoading ? null : _processTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5BFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isTransactionLoading
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
    setState(() => isTransactionLoading = true);

    try {
      // TODO: Replace with actual fingerprint scan and API call
      // final fingerprintResult = await FingerprintService.scan(...);
      // final skey = widget.aepsType == 'AEPS1' ? selectedService : selectedService;
      // final response = await controller.aepsTransactionProcess(skey, 'PROCESS', fingerprintResult.encdata);
      // transactionResult = response?.data?.toJson();

      // Demo: Simulate success
      await Future.delayed(const Duration(seconds: 2));
      transactionResult = {
        'txn_status': 'Success',
        'txn_desc': 'Transaction completed successfully',
        'balance': '15000.00',
        'date': '2024-12-24 12:30:00',
        'txnid': 'TXN${DateTime.now().millisecondsSinceEpoch}',
        'opid': 'OP${DateTime.now().millisecondsSinceEpoch}',
        'trasamt': amountController.text.isEmpty ? '0' : amountController.text,
      };

      setState(() {
        showConfirmModal = false;
        showResultModal = true;
      });

      // Refresh transactions
      _fetchRecentTransactions();
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      setState(() => isTransactionLoading = false);
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
                    color: isSuccess ? Colors.green[700] : Colors.red[700],
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
                        _buildResultRow('Transaction ID', transactionResult?['txnid'] ?? ''),
                        _buildResultRow('Date', transactionResult?['date'] ?? ''),
                        if (transactionResult?['balance'] != null)
                          _buildResultRow('Balance', '₹${transactionResult?['balance']}'),
                        if (showAmountInput)
                          _buildResultRow('Amount', '₹${transactionResult?['trasamt']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

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
  Future<void> _printReceipt() async {
    // TODO: Implement print receipt functionality
    _showSnackbar('Receipt printing coming soon!');
  }

  /// Recent Transactions Section
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: _fetchRecentTransactions,
              child: Text(
                'Refresh',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: const Color(0xFF2E5BFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            final txn = recentTransactions[index];
            final isSuccess = txn['portal_status'] == 'Success';
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
                      isSuccess ? Icons.check_circle : Icons.error,
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
                          txn['record_type'] ?? '',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          txn['request_dt'] ?? '',
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
                      if (txn['txn_amt'] != null && txn['txn_amt'] != '0')
                        Text(
                          '₹${txn['txn_amt']}',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        txn['portal_status'] ?? '',
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
        ),
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

  /// Show snackbar
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.albertSans()),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
