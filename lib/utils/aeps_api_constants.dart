/// AEPS API Constants
/// Contains all API endpoints for AEPS One (Fingpay) and AEPS Three (Instantpay)
/// 
/// Add these constants to your existing WebApiConstant class

class AepsApiConstants {
  // Base paths
  static const String fetchBase = 'Fetch/';
  static const String actionBase = 'Action/';

  // ==========================================
  // AEPS THREE (INSTANTPAY) ENDPOINTS
  // ==========================================
  
  /// Check user onboard status for Instantpay
  static const String checkUserOnboardStatus = '${fetchBase}checkUserOnboardStatus';
  
  /// Check bio auth status for Instantpay
  static const String checkBioAuthStatus = '${fetchBase}checkBioAuthStatus';
  
  /// Process onboarding for Instantpay
  /// req_type: CHECKUSER, REGISTERUSER
  static const String instantpayAepsProcessOnboarding = '${actionBase}instantpayAepsProcessOnboarding';
  
  /// Start 2FA process for Instantpay
  static const String start2FaAuthProcess = '${actionBase}start_2faauth_process';
  
  /// Process transaction for Instantpay
  /// skey: BAP (Balance), WAP (Withdrawal), SAP (Statement)
  /// request_type: CONFIRM, PROCESS
  static const String aepsStartTransactionProcess = '${actionBase}aepsStartTransactionProcess';

  // ==========================================
  // AEPS ONE (FINGPAY) ENDPOINTS
  // ==========================================
  
  /// Check user onboard status for Fingpay
  static const String checkFingpayUserOnboardStatus = '${fetchBase}checkFingpayUserOnboardStatus';
  
  /// Check Fingpay auth status
  static const String checkFingpayAuthStatus = '${fetchBase}checkFingpayAuthStatus';
  
  /// Process onboarding for Fingpay
  /// req_type: REGISTERUSER, VERIFYONBOARDOTP, PROCESSEKYC, RESENDOTP
  static const String fingpayAepsProcessOnboarding = '${actionBase}fingpayAepsProcessOnboarding';
  
  /// Fingpay 2FA process
  static const String fingpayTwofaProcess = '${actionBase}fingpayTwofaProcess';
  
  /// Process transaction for Fingpay
  /// skey: BCSFNGPY (Balance), CWSFNGPY (Withdrawal), MSTFNGPY (Statement), ADRFNGPY (Aadhaar Pay)
  static const String fingpayTransactionProcess = '${actionBase}fingpayTransactionProcess';

  // ==========================================
  // COMMON ENDPOINTS
  // ==========================================
  
  /// Get AEPS bank list
  static const String getAepsBanklist = '${fetchBase}getAepsBanklist';
  
  /// Get user's bank list (for Fingpay onboarding)
  static const String getAllMyBankList = '${fetchBase}getAllMyBankList';
  
  /// Mark/Unmark favorite bank
  /// action: ADD, REMOVE
  static const String markFavBank = '${actionBase}markFavBank';
  
  /// Get recent transaction data
  /// type: AEPS2 (Fingpay), AEPS3 (Instantpay)
  static const String getRecentTxnData = '${fetchBase}getRecentTxnData';
}

/// AEPS Service Keys
class AepsServiceKeys {
  // Instantpay (AEPS Three) service keys
  static const String instantpayBalanceCheck = 'BAP';
  static const String instantpayCashWithdrawal = 'WAP';
  static const String instantpayMiniStatement = 'SAP';
  
  // Fingpay (AEPS One) service keys
  static const String fingpayBalanceCheck = 'BCSFNGPY';
  static const String fingpayCashWithdrawal = 'CWSFNGPY';
  static const String fingpayMiniStatement = 'MSTFNGPY';
  static const String fingpayAadhaarPay = 'ADRFNGPY';
}

/// AEPS Request Types
class AepsRequestTypes {
  // Onboarding request types
  static const String checkUser = 'CHECKUSER';
  static const String registerUser = 'REGISTERUSER';
  static const String verifyOnboardOtp = 'VERIFYONBOARDOTP';
  static const String processEkyc = 'PROCESSEKYC';
  static const String resendOtp = 'RESENDOTP';
  
  // Transaction request types
  static const String confirm = 'CONFIRM';
  static const String process = 'PROCESS';
  
  // Favorite bank actions
  static const String addFavorite = 'ADD';
  static const String removeFavorite = 'REMOVE';
  
  // Recent transaction types
  static const String aeps2 = 'AEPS2'; // Fingpay
  static const String aeps3 = 'AEPS3'; // Instantpay
}

/// AEPS Response Codes
class AepsResponseCodes {
  static const String success = 'RCS';
  static const String failure = 'RCF';
  static const String pending = 'RCP';
  static const String error = 'RCE';
}

/// Supported Fingerprint Devices
class AepsDevices {
  static const List<Map<String, String>> deviceList = [
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
  
  static String getDeviceName(String value) {
    final device = deviceList.firstWhere(
      (d) => d['value'] == value,
      orElse: () => {'name': value, 'value': value},
    );
    return device['name'] ?? value;
  }
}
