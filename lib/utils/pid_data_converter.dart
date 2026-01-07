// import 'dart:convert';
// import 'package:xml/xml.dart';
//
// /// ╔═══════════════════════════════════════════════════════════════════════════════╗
// /// ║  PID DATA CONVERTER - Fingpay API Format                                      ║
// /// ║  Updated: January 2026                                                         ║
// /// ║                                                                                ║
// /// ║  CRITICAL: This follows the EXACT Fingpay API documentation format!           ║
// /// ║                                                                                ║
// /// ║  The API expects "captureResponse" object with these fields:                  ║
// /// ║  - PidDatatype, Piddata, ci, dc, dpID, errCode, errInfo, fCount, fType,       ║
// /// ║  - hmac, iCount, mc, mi, nmPoints, pCount, pType, qScore, rdsID, rdsVer,      ║
// /// ║  - sessionKey                                                                  ║
// /// ║                                                                                ║
// /// ║  For Face Auth: isFacialTan = true                                            ║
// /// ╚═══════════════════════════════════════════════════════════════════════════════╝
//
// class PidDataConverter {
//
//   /// ✅ MAIN METHOD: Convert PID XML to Fingpay captureResponse format
//   /// This is the EXACT format required by Fingpay API
//   static Map<String, dynamic> convertToCaptureResponse(String pidXml) {
//     if (pidXml.isEmpty) {
//       ConsoleLog.printInfo('❌ Empty PID XML');
//       return {};
//     }
//
//     try {
//       final document = XmlDocument.parse(pidXml);
//       final pidData = document.findAllElements('PidData').first;
//
//       // Extract all components
//       final deviceInfo = _extractDeviceInfo(pidData);
//       final data = _extractData(pidData);
//       final skey = _extractSkey(pidData);
//       final hmac = _extractHmac(pidData);
//       final resp = _extractResp(pidData);
//
//       // Build captureResponse in EXACT Fingpay format
//       final Map<String, dynamic> captureResponse = {
//         "PidDatatype": data['type'] ?? "X",
//         "Piddata": data['value'] ?? "",
//         "ci": skey['ci'] ?? "",
//         "dc": deviceInfo['dc'] ?? "",
//         "dpID": deviceInfo['dpId'] ?? "",
//         "errCode": resp['errCode'] ?? "0",
//         "errInfo": resp['errInfo'] ?? "",
//         "fCount": resp['fCount'] ?? "0",
//         "fType": resp['fType'] ?? "0",
//         "hmac": hmac,
//         "iCount": resp['iCount'] ?? "0",
//         "mc": deviceInfo['mc'] ?? "",
//         "mi": deviceInfo['mi'] ?? "",
//         "nmPoints": resp['nmPoints'] ?? "",
//         "pCount": resp['pCount'] ?? "0",
//         "pType": resp['pType'] ?? "0",
//         "qScore": resp['qScore'] ?? "",
//         "rdsID": deviceInfo['rdsId'] ?? "",
//         "rdsVer": deviceInfo['rdsVer'] ?? "",
//         "sessionKey": skey['value'] ?? "",
//       };
//
//       ConsoleLog.printInfo('✅ CaptureResponse generated successfully');
//       ConsoleLog.printInfo('   fCount: ${captureResponse['fCount']}, iCount: ${captureResponse['iCount']}, pCount: ${captureResponse['pCount']}');
//
//       return captureResponse;
//
//     } catch (e, stackTrace) {
//       ConsoleLog.printInfo('❌ CaptureResponse Conversion Error: $e');
//       ConsoleLog.printInfo('Stack trace: $stackTrace');
//       return {};
//     }
//   }
//
//   /// ✅ Check if Face Authentication (for isFacialTan flag)
//   static bool isFaceAuth(String deviceValue) {
//     return deviceValue == 'FACE_AUTH';
//   }
//
//   /// ✅ LEGACY METHOD: Convert to base64 encoded JSON (for backward compatibility)
//   /// Use this ONLY if your backend expects encdata as base64 JSON
//   static String convertPidToEncdata(String pidXml, {String? deviceType}) {
//     if (pidXml.isEmpty) {
//       ConsoleLog.printInfo('❌ Empty PID XML');
//       return '';
//     }
//
//     try {
//       final captureResponse = convertToCaptureResponse(pidXml);
//       if (captureResponse.isEmpty) return '';
//
//       // Convert to JSON and base64 encode
//       final jsonString = jsonEncode(captureResponse);
//       final base64Encoded = base64Encode(utf8.encode(jsonString));
//
//       ConsoleLog.printInfo('✅ Encdata (base64) length: ${base64Encoded.length}');
//       return base64Encoded;
//
//     } catch (e) {
//       ConsoleLog.printInfo('❌ Encdata Conversion Error: $e');
//       return '';
//     }
//   }
//
//   /// ✅ Convenience method with explicit device type
//   static String convertWithDeviceType(String pidXml, String deviceValue) {
//     return convertPidToEncdata(pidXml);
//   }
//
//   /// ✅ Build complete Fingpay transaction request body
//   /// This builds the EXACT request format from the API documentation
//   static Map<String, dynamic> buildFingpayTransactionBody({
//     required String pidXml,
//     required String merchantTranId,
//     required String aadhaarNumber,
//     required String nationalBankIdNumber,
//     required String mobileNumber,
//     required String latitude,
//     required String longitude,
//     required String transactionAmount,
//     required String transactionType, // "CW", "BE", "M" (AadhaarPay)
//     required String subMerchantId,
//     required String merchantUserName,
//     required String merchantPin, // Should be MD5 hashed
//     required String superMerchantId,
//     String? virtualId,
//     String requestRemarks = "",
//     String languageCode = "en",
//     String paymentType = "B",
//     required String deviceValue, // For isFacialTan check
//   }) {
//     final captureResponse = convertToCaptureResponse(pidXml);
//     final isFacial = isFaceAuth(deviceValue);
//
//     return {
//       "merchantTranId": merchantTranId,
//       "captureResponse": captureResponse,
//       "cardnumberORUID": {
//         "adhaarNumber": virtualId != null && virtualId.isNotEmpty
//             ? "999999999999" // 12 9's for virtual ID
//             : aadhaarNumber,
//         "indicatorforUID": virtualId != null && virtualId.isNotEmpty ? "2" : "0",
//         "nationalBankIdentificationNumber": nationalBankIdNumber,
//         if (virtualId != null && virtualId.isNotEmpty) "virtualId": virtualId,
//       },
//       "mobileNumber": mobileNumber,
//       "paymentType": paymentType,
//       "transactionType": transactionType,
//       "latitude": latitude,
//       "longitude": longitude,
//       "requestRemarks": requestRemarks,
//       "timestamp": DateTime.now().toIso8601String(),
//       "transactionAmount": transactionAmount,
//       "languageCode": languageCode,
//       "subMerchantId": subMerchantId,
//       "merchantUserName": merchantUserName,
//       "merchantPin": merchantPin, // Must be MD5 hashed
//       "superMerchantId": superMerchantId,
//       "isFacialTan": isFacial, // ✅ CRITICAL for Face Auth
//     };
//   }
//
//   /// ✅ Build 2FA request body
//   static Map<String, dynamic> build2FARequestBody({
//     required String pidXml,
//     required String aadhaarNumber,
//     required String latitude,
//     required String longitude,
//     required String deviceValue,
//     required String requestId,
//   }) {
//     final captureResponse = convertToCaptureResponse(pidXml);
//     final isFacial = isFaceAuth(deviceValue);
//
//     return {
//       "request_id": requestId,
//       "lat": latitude,
//       "long": longitude,
//       "device": deviceValue,
//       "aadhar_no": aadhaarNumber,
//       "skey": "TWOFACTORAUTH",
//       "isFacialTan": isFacial, // ✅ CRITICAL for Face Auth
//       "captureResponse": captureResponse, // ✅ Proper format
//     };
//   }
//
//   // ==================== EXTRACTION METHODS ====================
//
//   static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final deviceInfo = pidData.findAllElements('DeviceInfo').first;
//       result['dc'] = deviceInfo.getAttribute('dc') ?? '';
//       result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
//       result['mc'] = deviceInfo.getAttribute('mc') ?? '';
//       result['mi'] = deviceInfo.getAttribute('mi') ?? '';
//       result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
//       result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Error extracting DeviceInfo: $e');
//     }
//     return result;
//   }
//
//   static Map<String, String> _extractData(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final dataElement = pidData.findAllElements('Data').first;
//       result['type'] = dataElement.getAttribute('type') ?? 'X';
//       result['value'] = dataElement.innerText.trim();
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Error extracting Data: $e');
//     }
//     return result;
//   }
//
//   static Map<String, String> _extractSkey(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final skey = pidData.findAllElements('Skey').first;
//       result['ci'] = skey.getAttribute('ci') ?? '';
//       result['value'] = skey.innerText.trim();
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Error extracting Skey: $e');
//     }
//     return result;
//   }
//
//   static String _extractHmac(XmlElement pidData) {
//     try {
//       return pidData.findAllElements('Hmac').first.innerText.trim();
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Error extracting Hmac: $e');
//       return '';
//     }
//   }
//
//   static Map<String, String> _extractResp(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final resp = pidData.findAllElements('Resp').first;
//       result['errCode'] = resp.getAttribute('errCode') ?? '0';
//       result['errInfo'] = resp.getAttribute('errInfo') ?? '';
//       result['fCount'] = resp.getAttribute('fCount') ?? '0';
//       result['fType'] = resp.getAttribute('fType') ?? '0';
//       result['iCount'] = resp.getAttribute('iCount') ?? '0';
//       result['iType'] = resp.getAttribute('iType') ?? '0';
//       result['pCount'] = resp.getAttribute('pCount') ?? '0';
//       result['pType'] = resp.getAttribute('pType') ?? '0';
//       result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
//       final qScore = resp.getAttribute('qScore');
//       result['qScore'] = (qScore == null || qScore.isEmpty) ? '' : qScore;
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Error extracting Resp: $e');
//     }
//     return result;
//   }
//
//   /// Debug method
//   static void debugCaptureResponse(Map<String, dynamic> captureResponse) {
//     ConsoleLog.printInfo('\n🔍 CAPTURE RESPONSE DEBUG:');
//     ConsoleLog.printInfo('PidDatatype: ${captureResponse['PidDatatype']}');
//     ConsoleLog.printInfo('Piddata length: ${(captureResponse['Piddata'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('ci: ${captureResponse['ci']}');
//     ConsoleLog.printInfo('dc: ${(captureResponse['dc'] as String?)?.substring(0, 20) ?? ''}...');
//     ConsoleLog.printInfo('dpID: ${captureResponse['dpID']}');
//     ConsoleLog.printInfo('errCode: ${captureResponse['errCode']}');
//     ConsoleLog.printInfo('fCount: ${captureResponse['fCount']}, iCount: ${captureResponse['iCount']}, pCount: ${captureResponse['pCount']}');
//     ConsoleLog.printInfo('rdsID: ${captureResponse['rdsID']}');
//     ConsoleLog.printInfo('sessionKey length: ${(captureResponse['sessionKey'] as String?)?.length ?? 0}');
//   }
// }
//
//
// /*
// ╔═══════════════════════════════════════════════════════════════════════════════════╗
// ║  USAGE INSTRUCTIONS FOR AEPS CONTROLLER                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════════════╝
//
// ⚠️ IMPORTANT: The Fingpay API expects `captureResponse` object, NOT just encdata!
//
// BEFORE (WRONG):
// ```dart
// Map<String, dynamic> body = {
//   "request_id": generateRequestId(),
//   "device": selectedDevice.value,
//   "aadhar_no": aadhaarController.text,
//   "skey": "TWOFACTORAUTH",
//   "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),
// };
// ```
//
// AFTER (CORRECT - Option 1: Using helper method):
// ```dart
// Map<String, dynamic> body = PidDataConverter.build2FARequestBody(
//   pidXml: result.pidData ?? '',
//   aadhaarNumber: aadhaarController.text,
//   latitude: homeScreenController.latitude.value.toString(),
//   longitude: homeScreenController.longitude.value.toString(),
//   deviceValue: selectedDevice.value,
//   requestId: generateRequestId(),
// );
// ```
//
// AFTER (CORRECT - Option 2: Manual):
// ```dart
// final captureResponse = PidDataConverter.convertToCaptureResponse(result.pidData ?? '');
// final isFacial = PidDataConverter.isFaceAuth(selectedDevice.value);
//
// Map<String, dynamic> body = {
//   "request_id": generateRequestId(),
//   "lat": homeScreenController.latitude.value.toString(),
//   "long": homeScreenController.longitude.value.toString(),
//   "device": selectedDevice.value,
//   "aadhar_no": aadhaarController.text,
//   "skey": "TWOFACTORAUTH",
//   "isFacialTan": isFacial,  // ✅ CRITICAL for Face Auth
//   "captureResponse": captureResponse,  // ✅ Proper object format
// };
// ```
//
// For TRANSACTIONS (Cash Withdrawal, Balance, etc.):
// ```dart
// Map<String, dynamic> body = PidDataConverter.buildFingpayTransactionBody(
//   pidXml: result.pidData ?? '',
//   merchantTranId: generateMerchantTranId(),
//   aadhaarNumber: serviceAadhaarController.text,
//   nationalBankIdNumber: selectedBankIin.value,
//   mobileNumber: serviceMobileController.text,
//   latitude: homeScreenController.latitude.value.toString(),
//   longitude: homeScreenController.longitude.value.toString(),
//   transactionAmount: serviceAmountController.text,
//   transactionType: "CW", // or "BE" for balance, "M" for AadhaarPay
//   subMerchantId: subMerchantId,
//   merchantUserName: merchantUserName,
//   merchantPin: md5Hash(merchantPin), // Must be MD5 hashed!
//   superMerchantId: superMerchantId,
//   deviceValue: serviceSelectedDevice.value,
// );
// ```
//
// ╔═══════════════════════════════════════════════════════════════════════════════════╗
// ║  CRITICAL CHECKLIST FROM FINGPAY DOCUMENTATION                                    ║
// ╚═══════════════════════════════════════════════════════════════════════════════════╝
//
// ✅ Transaction timeout should be 210 seconds
// ✅ Aadhaar must be validated with Verhoeff algorithm
// ✅ Amount max 10,000 for withdrawal
// ✅ IIN list should be fetched from Fingpay bank API
// ✅ Location (lat/long) must be accurate
// ✅ deviceIMEI in headers = biometric scanner serial number (for web)
// ✅ merchantPin must be MD5 hashed
// ✅ Success = bankRRN present AND responseCode = "00"
// ✅ isFacialTan = true for Face Authentication
// ✅ Never store Aadhaar number or PID data in logs
// ✅ Check for duplicate transactions before sending
//
// */









/*
import 'dart:convert';
import 'package:xml/xml.dart';

class PidDataConverter {

  /// ✅ MAIN METHOD: Convert PID XML to Exact Fingpay/Backend Object Format
  /// Matches the structure: CI, DC, piddatatype, DPID, DATAVALUE, HMAC, MC, MI, RDSID, RDSVER, value
  static Map<String, dynamic> convertToCaptureResponse(String pidXml) {
    if (pidXml.isEmpty) {
      ConsoleLog.printInfo('❌ Empty PID XML');
      return {};
    }

    try {
      final document = XmlDocument.parse(pidXml);
      final pidData = document.findAllElements('PidData').first;

      // Extract components
      final deviceInfo = _extractDeviceInfo(pidData);
      final data = _extractData(pidData);
      final skey = _extractSkey(pidData);
      final hmac = _extractHmac(pidData);
      final resp = _extractResp(pidData);

      // ✅ EXACT MAPPING based on your provided "Fingpay final obj.txt"
      final Map<String, dynamic> captureResponse = {
        "CI": skey['ci'] ?? "",
        "DC": deviceInfo['dc'] ?? "",
        "piddatatype": data['type'] ?? "X",
        "DPID": deviceInfo['dpId'] ?? "",
        "DATAVALUE": data['value'] ?? "", // The Base64 PID Data
        "HMAC": hmac,
        "MC": deviceInfo['mc'] ?? "",
        "MI": deviceInfo['mi'] ?? "",
        "RDSID": deviceInfo['rdsId'] ?? "",
        "RDSVER": deviceInfo['rdsVer'] ?? "",
        "value": skey['value'] ?? "", // Session Key
        "pidata_qscore": resp['qScore'] ?? "",

        // Additional standard fields (Keep these just in case your backend needs them too)
        "errCode": resp['errCode'] ?? "0",
        "errInfo": resp['errInfo'] ?? "",
        "fCount": resp['fCount'] ?? "0",
        "fType": resp['fType'] ?? "0",
        "iCount": resp['iCount'] ?? "0",
        "iType": resp['iType'] ?? "0",
        "pCount": resp['pCount'] ?? "0",
        "pType": resp['pType'] ?? "0",
        "nmPoints": resp['nmPoints'] ?? "",
      };

      ConsoleLog.printInfo('✅ CaptureResponse Generated (Exact Format)');
      return captureResponse;

    } catch (e, stackTrace) {
      ConsoleLog.printInfo('❌ CaptureResponse Conversion Error: $e');
      ConsoleLog.printInfo('Stack trace: $stackTrace');
      return {};
    }
  }

  /// ✅ Check if Face Authentication
  static bool isFaceAuth(String deviceValue) {
    return deviceValue == 'FACE_AUTH';
  }

  /// ✅ Convert to Base64 Encoded JSON (If API expects a stringified JSON in encdata)
  static String convertPidToEncdata(String pidXml, {String? deviceType}) {
    if (pidXml.isEmpty) return '';
    try {
      final captureResponse = convertToCaptureResponse(pidXml);
      if (captureResponse.isEmpty) return '';
      // Convert Map to JSON String -> Base64
      final jsonString = jsonEncode(captureResponse);
      return base64Encode(utf8.encode(jsonString));
    } catch (e) {
      ConsoleLog.printInfo('❌ Encdata Conversion Error: $e');
      return '';
    }
  }

  /// ✅ Convenience method
  static String convertWithDeviceType(String pidXml, String deviceValue) {
    return convertPidToEncdata(pidXml);
  }

  // ==================== EXTRACTION HELPERS ====================

  static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;
      result['dc'] = deviceInfo.getAttribute('dc') ?? '';
      result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
      result['mc'] = deviceInfo.getAttribute('mc') ?? '';
      result['mi'] = deviceInfo.getAttribute('mi') ?? '';
      result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
      result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
    } catch (e) { ConsoleLog.printInfo('⚠️ DeviceInfo Error: $e'); }
    return result;
  }

  static Map<String, String> _extractData(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final dataElement = pidData.findAllElements('Data').first;
      result['type'] = dataElement.getAttribute('type') ?? 'X';
      result['value'] = dataElement.innerText.trim();
    } catch (e) { ConsoleLog.printInfo('⚠️ Data Error: $e'); }
    return result;
  }

  static Map<String, String> _extractSkey(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final skey = pidData.findAllElements('Skey').first;
      result['ci'] = skey.getAttribute('ci') ?? '';
      result['value'] = skey.innerText.trim();
    } catch (e) { ConsoleLog.printInfo('⚠️ Skey Error: $e'); }
    return result;
  }

  static String _extractHmac(XmlElement pidData) {
    try {
      return pidData.findAllElements('Hmac').first.innerText.trim();
    } catch (e) { return ''; }
  }

  static Map<String, String> _extractResp(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final resp = pidData.findAllElements('Resp').first;
      result['errCode'] = resp.getAttribute('errCode') ?? '0';
      result['errInfo'] = resp.getAttribute('errInfo') ?? '';
      result['fCount'] = resp.getAttribute('fCount') ?? '0';
      result['fType'] = resp.getAttribute('fType') ?? '0';
      result['iCount'] = resp.getAttribute('iCount') ?? '0';
      result['iType'] = resp.getAttribute('iType') ?? '0';
      result['pCount'] = resp.getAttribute('pCount') ?? '0';
      result['pType'] = resp.getAttribute('pType') ?? '0';
      result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
      result['qScore'] = resp.getAttribute('qScore') ?? '';
    } catch (e) { ConsoleLog.printInfo('⚠️ Resp Error: $e'); }
    return result;
  }
}*/








// import 'dart:convert';
// import 'package:xml/xml.dart';
//
// import 'ConsoleLog.dart';
//
// class PidDataConverter {
//   /// ✅ MAIN METHOD: Convert PID XML to EXACT Fingpay Format
//   /// Matches EXACTLY the structure from "fingpay final obj.txt"
//   static Map<String, dynamic> convertToCaptureResponse(String pidXml) {
//     if (pidXml.isEmpty) {
//       ConsoleLog.printInfo('❌ Empty PID XML');
//       return {};
//     }
//
//     try {
//       final document = XmlDocument.parse(pidXml);
//       final pidData = document.findAllElements('PidData').first;
//
//       // Extract components
//       final deviceInfo = _extractDeviceInfo(pidData);
//       final data = _extractData(pidData);
//       final skey = _extractSkey(pidData);
//       final hmac = _extractHmac(pidData);
//       final resp = _extractResp(pidData);
//       final additionalInfo = _extractAdditionalInfo(pidData);
//
//       // ✅ EXACT MAPPING based on "fingpay final obj.txt"
//       final Map<String, dynamic> captureResponse = {
//         // UPPERCASE keys (as in Fingpay response)
//         "CI": skey['ci'] ?? "", // UPPERCASE
//         "DC": deviceInfo['dc'] ?? "", // UPPERCASE
//         "piddatatype": data['type'] ?? "X", // lowercase 'p'
//         "DPID": deviceInfo['dpId'] ?? "", // UPPERCASE
//         "DATAVALUE": data['value'] ?? "", // UPPERCASE - Base64 PID Data
//         "HMAC": hmac, // UPPERCASE
//         "MC": deviceInfo['mc'] ?? "", // UPPERCASE
//         "MI": deviceInfo['mi'] ?? "", // UPPERCASE
//         "RDSID": deviceInfo['rdsId'] ?? "", // UPPERCASE
//         "RDSVER": deviceInfo['rdsVer'] ?? "", // UPPERCASE
//         "value": skey['value'] ?? "", // lowercase - Session Key
//         "pidata_qscore": resp['qScore'] ?? "", // lowercase 'p'
//         "base64pidData": base64Encode(utf8.encode(pidXml)), // ✅ CRITICAL: Add this
//         "srno": additionalInfo['srno'] ?? "", // Serial number
//         "allpiddata": _buildAllPidData(deviceInfo, data, skey, hmac, resp, additionalInfo), // JSON string
//
//         // Additional fields from Resp
//         "errCode": resp['errCode'] ?? "0",
//         "errInfo": resp['errInfo'] ?? "Pid generated successfully",
//         "nmpoints": resp['nmPoints'] ?? "",
//         "fcount": resp['fCount'] ?? "0",
//         "fType": resp['fType'] ?? "0",
//         "pcount": resp['pCount'] ?? "0",
//         "ptype": resp['pType'] ?? "0",
//         "icount": resp['iCount'] ?? "0",
//         "iType": resp['iType'] ?? "0",
//       };
//
//       ConsoleLog.printInfo('✅ CaptureResponse Generated (Exact Fingpay Format)');
//       _debugResponse(captureResponse);
//       return captureResponse;
//
//     } catch (e, stackTrace) {
//       ConsoleLog.printInfo('❌ CaptureResponse Conversion Error: $e');
//       ConsoleLog.printInfo('Stack trace: $stackTrace');
//       return {};
//     }
//   }
//
//   /// ✅ Build the "allpiddata" JSON string
//   static String _buildAllPidData(
//       Map<String, String> deviceInfo,
//       Map<String, String> data,
//       Map<String, String> skey,
//       String hmac,
//       Map<String, String> resp,
//       Map<String, String> additionalInfo,
//       ) {
//     final allPidData = {
//       "_Data": {
//         "type": data['type'] ?? "X",
//         "value": data['value'] ?? "",
//       },
//       "_DeviceInfo": {
//         "add_info": {
//           "params": [
//             {"name": "serial_number", "value": additionalInfo['srno'] ?? ""},
//             {"name": "srno", "value": additionalInfo['srno'] ?? ""},
//             {"name": "modality_type", "value": "Finger"},
//             {"name": "device_type", "value": "L1"},
//           ]
//         },
//         "dc": deviceInfo['dc'] ?? "",
//         "dpId": deviceInfo['dpId'] ?? "",
//         "mc": deviceInfo['mc'] ?? "",
//         "mi": deviceInfo['mi'] ?? "",
//         "rdsId": deviceInfo['rdsId'] ?? "",
//         "rdsVer": deviceInfo['rdsVer'] ?? "",
//       },
//       "_Hmac": hmac,
//       "_Resp": {
//         "errCode": resp['errCode'] ?? "0",
//         "errInfo": resp['errInfo'] ?? "Pid generated successfully",
//         "fCount": resp['fCount'] ?? "0",
//         "fType": resp['fType'] ?? "0",
//         "iCount": resp['iCount'] ?? "0",
//         "iType": resp['iType'] ?? "0",
//         "nmPoints": resp['nmPoints'] ?? "",
//         "pCount": resp['pCount'] ?? "0",
//         "pType": resp['pType'] ?? "0",
//         "qScore": resp['qScore'] ?? "",
//       },
//       "_Skey": {
//         "ci": skey['ci'] ?? "",
//         "value": skey['value'] ?? "",
//       },
//     };
//
//     return jsonEncode(allPidData);
//   }
//
//   /// ✅ Extract additional info from DeviceInfo
//   static Map<String, String> _extractAdditionalInfo(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final deviceInfo = pidData.findAllElements('DeviceInfo').first;
//       final additionalInfo = deviceInfo.findAllElements('additional_info').firstOrNull;
//       if (additionalInfo != null) {
//         final params = additionalInfo.findAllElements('Param');
//         for (final param in params) {
//           final name = param.getAttribute('name');
//           final value = param.getAttribute('value');
//           if (name != null && value != null) {
//             result[name] = value;
//           }
//         }
//       }
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ AdditionalInfo Error: $e');
//     }
//     return result;
//   }
//
//   /// ✅ Check if Face Authentication
//   static bool isFaceAuth(String deviceValue) {
//     return deviceValue == 'FACE_AUTH';
//   }
//
//   /// ✅ Convert to Base64 Encoded JSON (If API expects a stringified JSON in encdata)
//   static String convertPidToEncdata(String pidXml, {String? deviceType}) {
//     if (pidXml.isEmpty) return '';
//     try {
//       final captureResponse = convertToCaptureResponse(pidXml);
//       if (captureResponse.isEmpty) return '';
//       // Convert Map to JSON String -> Base64
//       final jsonString = jsonEncode(captureResponse);
//       return base64Encode(utf8.encode(jsonString));
//     } catch (e) {
//       ConsoleLog.printInfo('❌ Encdata Conversion Error: $e');
//       return '';
//     }
//   }
//
//   // ==================== EXTRACTION HELPERS ====================
//
//   static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final deviceInfo = pidData.findAllElements('DeviceInfo').first;
//       result['dc'] = deviceInfo.getAttribute('dc') ?? '';
//       result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
//       result['mc'] = deviceInfo.getAttribute('mc') ?? '';
//       result['mi'] = deviceInfo.getAttribute('mi') ?? '';
//       result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
//       result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ DeviceInfo Error: $e');
//     }
//     return result;
//   }
//
//   static Map<String, String> _extractData(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final dataElement = pidData.findAllElements('Data').first;
//       result['type'] = dataElement.getAttribute('type') ?? 'X';
//       result['value'] = dataElement.innerText.trim();
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Data Error: $e');
//     }
//     return result;
//   }
//
//   static Map<String, String> _extractSkey(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final skey = pidData.findAllElements('Skey').first;
//       result['ci'] = skey.getAttribute('ci') ?? '';
//       result['value'] = skey.innerText.trim();
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Skey Error: $e');
//     }
//     return result;
//   }
//
//   static String _extractHmac(XmlElement pidData) {
//     try {
//       return pidData.findAllElements('Hmac').first.innerText.trim();
//     } catch (e) {
//       return '';
//     }
//   }
//
//   static Map<String, String> _extractResp(XmlElement pidData) {
//     final Map<String, String> result = {};
//     try {
//       final resp = pidData.findAllElements('Resp').first;
//       result['errCode'] = resp.getAttribute('errCode') ?? '0';
//       result['errInfo'] = resp.getAttribute('errInfo') ?? '';
//       result['fCount'] = resp.getAttribute('fCount') ?? '0';
//       result['fType'] = resp.getAttribute('fType') ?? '0';
//       result['iCount'] = resp.getAttribute('iCount') ?? '0';
//       result['iType'] = resp.getAttribute('iType') ?? '0';
//       result['pCount'] = resp.getAttribute('pCount') ?? '0';
//       result['pType'] = resp.getAttribute('pType') ?? '0';
//       result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
//       result['qScore'] = resp.getAttribute('qScore') ?? '';
//     } catch (e) {
//       ConsoleLog.printInfo('⚠️ Resp Error: $e');
//     }
//     return result;
//   }
//
//   /// ✅ Debug method to verify structure
//   static void _debugResponse(Map<String, dynamic> response) {
//     ConsoleLog.printInfo('\n🔍 CAPTURE RESPONSE STRUCTURE VERIFICATION:');
//     ConsoleLog.printInfo('CI: ${response['CI']}');
//     ConsoleLog.printInfo('DC: ${(response['DC'] as String?)?.substring(0, 20)}...');
//     ConsoleLog.printInfo('piddatatype: ${response['piddatatype']}');
//     ConsoleLog.printInfo('DPID: ${response['DPID']}');
//     ConsoleLog.printInfo('DATAVALUE length: ${(response['DATAVALUE'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('HMAC length: ${(response['HMAC'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('MC length: ${(response['MC'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('MI: ${response['MI']}');
//     ConsoleLog.printInfo('RDSID: ${response['RDSID']}');
//     ConsoleLog.printInfo('RDSVER: ${response['RDSVER']}');
//     ConsoleLog.printInfo('value length: ${(response['value'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('base64pidData length: ${(response['base64pidData'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('srno: ${response['srno']}');
//     ConsoleLog.printInfo('allpiddata length: ${(response['allpiddata'] as String?)?.length ?? 0}');
//     ConsoleLog.printInfo('errCode: ${response['errCode']}');
//     ConsoleLog.printInfo('fcount: ${response['fcount']}, fType: ${response['fType']}');
//     ConsoleLog.printInfo('pcount: ${response['pcount']}, ptype: ${response['ptype']}');
//     ConsoleLog.printInfo('icount: ${response['icount']}, iType: ${response['iType']}');
//   }
//
//   /// ✅ For 2FA Request Body
//   static Map<String, dynamic> build2FARequestBody({
//     required String pidXml,
//     required String aadhaarNumber,
//     required String latitude,
//     required String longitude,
//     required String deviceValue,
//     required String requestId,
//   }) {
//     final captureResponse = convertToCaptureResponse(pidXml);
//     final isFacial = isFaceAuth(deviceValue);
//
//     return {
//       "request_id": requestId,
//       "lat": latitude,
//       "long": longitude,
//       "device": deviceValue,
//       "aadhar_no": aadhaarNumber,
//       "skey": "TWOFACTORAUTH",
//       "isFacialTan": isFacial,
//       "captureResponse": captureResponse, // ✅ Now EXACT match with Fingpay format
//     };
//   }
// }
import 'dart:convert';
import 'package:xml/xml.dart';
import '../utils/ConsoleLog.dart';

/// ╔═══════════════════════════════════════════════════════════════════════════════╗
/// ║  PID DATA CONVERTER - Fingpay API Format                                      ║
/// ║  Updated: January 2026 - FIXED VERSION                                        ║
/// ║                                                                                ║
/// ║  CRITICAL FIX: The backend expects captureResponse fields DIRECTLY in the     ║
/// ║  request body, NOT as base64 encoded encdata!                                 ║
/// ║                                                                                ║
/// ║  Successful format has these keys (from fingpay_final_obj.txt):               ║
/// ║  CI, DC, piddatatype, DPID, DATAVALUE, HMAC, MC, MI, RDSID, RDSVER, value     ║
/// ╚═══════════════════════════════════════════════════════════════════════════════╝

class PidDataConverter {

  /// ✅ MAIN METHOD: Convert PID XML to Fingpay captureResponse format
  /// Returns a Map with the EXACT keys that Fingpay API expects
  static Map<String, dynamic> convertToCaptureResponse(String pidXml) {
    if (pidXml.isEmpty) {
      ConsoleLog.printInfo('❌ Empty PID XML');
      return {};
    }

    try {
      final document = XmlDocument.parse(pidXml);
      final pidData = document.findAllElements('PidData').first;

      // Extract all components
      final deviceInfo = _extractDeviceInfo(pidData);
      final data = _extractData(pidData);
      final skey = _extractSkey(pidData);
      final hmac = _extractHmac(pidData);
      final resp = _extractResp(pidData);

      // ✅ FIX 1: Extract srno from DeviceInfo additional_info
      final srno = _extractSrno(pidData);

      // ✅ FIX 2: Create base64pidData (raw PID XML as base64)
      final base64pidData = base64Encode(utf8.encode(pidXml));

      // ✅ FIX 3: Create allpiddata (stringified JSON of all PID components)
      final allpiddata = _buildAllPidData(pidData, deviceInfo, data, skey, hmac, resp);

      // Build captureResponse with ALL required fields
      final Map<String, dynamic> captureResponse = {
        // ✅ Core fields (already correct)
        "CI": skey['ci'] ?? "",
        "DC": deviceInfo['dc'] ?? "",
        "piddatatype": data['type'] ?? "X",
        "DPID": deviceInfo['dpId'] ?? "",
        "DATAVALUE": data['value'] ?? "",
        "HMAC": hmac,
        "MC": deviceInfo['mc'] ?? "",
        "MI": deviceInfo['mi'] ?? "",
        "RDSID": deviceInfo['rdsId'] ?? "",
        "RDSVER": deviceInfo['rdsVer'] ?? "",
        "value": skey['value'] ?? "",
        "pidata_qscore": resp['qScore'] ?? "",

        // ✅ FIX 4: Add missing fields
        "base64pidData": base64pidData,
        "srno": srno,
        "allpiddata": allpiddata,

        // ✅ FIX 5: Correct key casing (lowercase)
        "errCode": resp['errCode'] ?? "0",
        "errInfo": resp['errInfo'] ?? "",
        "nmpoints": resp['nmPoints'] ?? "",  // ✅ FIXED: lowercase
        "fcount": resp['fCount'] ?? "0",     // ✅ FIXED: lowercase
        "fType": resp['fType'] ?? "0",       // fType stays as is
      };

      ConsoleLog.printInfo('✅ CaptureResponse generated successfully');
      ConsoleLog.printInfo('   CI: ${captureResponse['CI']}');
      ConsoleLog.printInfo('   DPID: ${captureResponse['DPID']}');
      ConsoleLog.printInfo('   srno: ${captureResponse['srno']}');
      ConsoleLog.printInfo('   base64pidData length: ${base64pidData.length}');
      ConsoleLog.printInfo('   DATAVALUE length: ${(captureResponse['DATAVALUE'] as String).length}');
      ConsoleLog.printInfo('   value length: ${(captureResponse['value'] as String).length}');

      return captureResponse;

    } catch (e, stackTrace) {
      ConsoleLog.printInfo('❌ CaptureResponse Conversion Error: $e');
      ConsoleLog.printInfo('Stack trace: $stackTrace');
      return {};
    }
  }

  /// ✅ Check if Face Authentication (for isFacialTan flag)
  static bool isFaceAuth(String deviceValue) {
    return deviceValue.toUpperCase() == 'FACE_AUTH';
  }

  /// ✅ Build Fingpay 2FA request body
  /// CRITICAL: captureResponse fields go DIRECTLY in body, NOT as base64 encdata
  static Map<String, dynamic> build2FARequestBody({
    required String pidXml,
    required String aadhaarNumber,
    required String latitude,
    required String longitude,
    required String deviceValue,
    required String requestId,
  }) {
    final captureResponse = convertToCaptureResponse(pidXml);
    final isFacial = isFaceAuth(deviceValue);

    if (captureResponse.isEmpty) {
      ConsoleLog.printError('❌ Failed to generate captureResponse');
      return {};
    }

    // ✅ CORRECT FORMAT: Spread captureResponse fields directly into request body
    return {
      "request_id": requestId,
      "lat": latitude,
      "long": longitude,
      "device": deviceValue,
      "aadhar_no": aadhaarNumber,
      "skey": "TWOFACTORAUTH",
      "isFacialTan": isFacial,
      // ✅ Spread all captureResponse fields directly
      ...captureResponse,
    };
  }

  /// ✅ Alternative: Build 2FA body with encdata as raw PID XML base64
  /// Use this if your backend expects encdata as base64 encoded raw PID XML
  static Map<String, dynamic> build2FARequestBodyWithRawPidXml({
    required String pidXml,
    required String aadhaarNumber,
    required String latitude,
    required String longitude,
    required String deviceValue,
    required String requestId,
  }) {
    final isFacial = isFaceAuth(deviceValue);

    // Base64 encode the RAW PID XML (not parsed JSON)
    final base64PidXml = base64Encode(utf8.encode(pidXml));
    ConsoleLog.printInfo('📊 Raw PID XML Base64 length: ${base64PidXml.length}');

    return {
      "request_id": requestId,
      "lat": latitude,
      "long": longitude,
      "device": deviceValue,
      "aadhar_no": aadhaarNumber,
      "skey": "TWOFACTORAUTH",
      "isFacialTan": isFacial,
      "encdata": base64PidXml,  // Raw PID XML as base64
    };
  }

  /// ✅ Alternative: Build 2FA body with encdata as JSON object base64
  /// Use this if your backend expects encdata as base64 encoded JSON of captureResponse
  static Map<String, dynamic> build2FARequestBodyWithJsonBase64({
    required String pidXml,
    required String aadhaarNumber,
    required String latitude,
    required String longitude,
    required String deviceValue,
    required String requestId,
  }) {
    final captureResponse = convertToCaptureResponse(pidXml);
    final isFacial = isFaceAuth(deviceValue);

    if (captureResponse.isEmpty) {
      ConsoleLog.printError('❌ Failed to generate captureResponse');
      return {};
    }

    // Convert captureResponse to JSON and base64 encode
    final jsonString = jsonEncode(captureResponse);
    final base64Encoded = base64Encode(utf8.encode(jsonString));
    ConsoleLog.printInfo('📊 JSON Base64 Encdata length: ${base64Encoded.length}');

    return {
      "request_id": requestId,
      "lat": latitude,
      "long": longitude,
      "device": deviceValue,
      "aadhar_no": aadhaarNumber,
      "skey": "TWOFACTORAUTH",
      "isFacialTan": isFacial,
      "encdata": base64Encoded,  // JSON captureResponse as base64
    };
  }

  /// ✅ Build complete Fingpay transaction request body
  static Map<String, dynamic> buildFingpayTransactionBody({
    required String pidXml,
    required String merchantTranId,
    required String aadhaarNumber,
    required String nationalBankIdNumber,
    required String mobileNumber,
    required String latitude,
    required String longitude,
    required String transactionAmount,
    required String transactionType,
    required String subMerchantId,
    required String merchantUserName,
    required String merchantPin,
    required String superMerchantId,
    String? virtualId,
    String requestRemarks = "",
    String languageCode = "en",
    String paymentType = "B",
    required String deviceValue,
  }) {
    final captureResponse = convertToCaptureResponse(pidXml);
    final isFacial = isFaceAuth(deviceValue);

    return {
      "merchantTranId": merchantTranId,
      "captureResponse": captureResponse,
      "cardnumberORUID": {
        "adhaarNumber": virtualId != null && virtualId.isNotEmpty
            ? "999999999999"
            : aadhaarNumber,
        "indicatorforUID": virtualId != null && virtualId.isNotEmpty ? "2" : "0",
        "nationalBankIdentificationNumber": nationalBankIdNumber,
        if (virtualId != null && virtualId.isNotEmpty) "virtualId": virtualId,
      },
      "mobileNumber": mobileNumber,
      "paymentType": paymentType,
      "transactionType": transactionType,
      "latitude": latitude,
      "longitude": longitude,
      "requestRemarks": requestRemarks,
      "timestamp": DateTime.now().toIso8601String(),
      "transactionAmount": transactionAmount,
      "languageCode": languageCode,
      "subMerchantId": subMerchantId,
      "merchantUserName": merchantUserName,
      "merchantPin": merchantPin,
      "superMerchantId": superMerchantId,
      "isFacialTan": isFacial,
    };
  }

  /// ✅ Convert PID to base64 encdata (legacy method)
  static String convertPidToEncdata(String pidXml, {String? deviceType}) {
    if (pidXml.isEmpty) {
      ConsoleLog.printInfo('❌ Empty PID XML');
      return '';
    }

    try {
      final captureResponse = convertToCaptureResponse(pidXml);
      if (captureResponse.isEmpty) return '';

      final jsonString = jsonEncode(captureResponse);
      final base64Encoded = base64Encode(utf8.encode(jsonString));

      ConsoleLog.printInfo('✅ Encdata (base64) length: ${base64Encoded.length}');
      return base64Encoded;

    } catch (e) {
      ConsoleLog.printInfo('❌ Encdata Conversion Error: $e');
      return '';
    }
  }

  /// ✅ Convenience method with explicit device type
  static String convertWithDeviceType(String pidXml, String deviceValue) {
    return convertPidToEncdata(pidXml);
  }

  // ==================== EXTRACTION METHODS ====================

  static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;
      result['dc'] = deviceInfo.getAttribute('dc') ?? '';
      result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
      result['mc'] = deviceInfo.getAttribute('mc') ?? '';
      result['mi'] = deviceInfo.getAttribute('mi') ?? '';
      result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
      result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting DeviceInfo: $e');
    }
    return result;
  }

  static Map<String, String> _extractData(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final dataElement = pidData.findAllElements('Data').first;
      result['type'] = dataElement.getAttribute('type') ?? 'X';
      result['value'] = dataElement.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Data: $e');
    }
    return result;
  }

  static Map<String, String> _extractSkey(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final skey = pidData.findAllElements('Skey').first;
      result['ci'] = skey.getAttribute('ci') ?? '';
      result['value'] = skey.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Skey: $e');
    }
    return result;
  }

  static String _extractHmac(XmlElement pidData) {
    try {
      return pidData.findAllElements('Hmac').first.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Hmac: $e');
      return '';
    }
  }

  static Map<String, String> _extractResp(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final resp = pidData.findAllElements('Resp').first;
      result['errCode'] = resp.getAttribute('errCode') ?? '0';
      result['errInfo'] = resp.getAttribute('errInfo') ?? '';
      result['fCount'] = resp.getAttribute('fCount') ?? '0';
      result['fType'] = resp.getAttribute('fType') ?? '0';
      result['iCount'] = resp.getAttribute('iCount') ?? '0';
      result['iType'] = resp.getAttribute('iType') ?? '0';
      result['pCount'] = resp.getAttribute('pCount') ?? '0';
      result['pType'] = resp.getAttribute('pType') ?? '0';
      result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
      final qScore = resp.getAttribute('qScore');
      result['qScore'] = (qScore == null || qScore.isEmpty) ? '' : qScore;
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Resp: $e');
    }
    return result;
  }

  /// Debug method - prints all fields
  static void debugCaptureResponse(Map<String, dynamic> captureResponse) {
    ConsoleLog.printInfo('\n🔍 CAPTURE RESPONSE DEBUG:');
    ConsoleLog.printInfo('CI: ${captureResponse['CI']}');
    ConsoleLog.printInfo('DC: ${_truncate(captureResponse['DC']?.toString() ?? '', 30)}');
    ConsoleLog.printInfo('piddatatype: ${captureResponse['piddatatype']}');
    ConsoleLog.printInfo('DPID: ${captureResponse['DPID']}');
    ConsoleLog.printInfo('DATAVALUE length: ${(captureResponse['DATAVALUE'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('HMAC: ${_truncate(captureResponse['HMAC']?.toString() ?? '', 30)}');
    ConsoleLog.printInfo('MC length: ${(captureResponse['MC'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('MI: ${captureResponse['MI']}');
    ConsoleLog.printInfo('RDSID: ${captureResponse['RDSID']}');
    ConsoleLog.printInfo('RDSVER: ${captureResponse['RDSVER']}');
    ConsoleLog.printInfo('value length: ${(captureResponse['value'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('pidata_qscore: ${captureResponse['pidata_qscore']}');
  }

  static String _truncate(String str, int maxLength) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}...';
  }

  /// ✅ Validate that all required fields are present
  static bool validateCaptureResponse(Map<String, dynamic> captureResponse) {
    final requiredFields = ['CI', 'DC', 'DPID', 'DATAVALUE', 'HMAC', 'MC', 'MI', 'RDSID', 'RDSVER', 'value'];

    for (final field in requiredFields) {
      if (!captureResponse.containsKey(field) ||
          captureResponse[field] == null ||
          (captureResponse[field] as String).isEmpty) {
        ConsoleLog.printError('❌ Missing or empty required field: $field');
        return false;
      }
    }

    ConsoleLog.printInfo('✅ All required fields present in captureResponse');
    return true;
  }

  /// ✅ NEW: Extract serial number from DeviceInfo additional_info
  static String _extractSrno(XmlElement pidData) {
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;
      final additionalInfo = deviceInfo.findAllElements('additional_info').firstOrNull;

      if (additionalInfo != null) {
        final params = additionalInfo.findAllElements('Param');
        for (var param in params) {
          if (param.getAttribute('name') == 'srno') {
            return param.getAttribute('value') ?? '';
          }
        }
      }
      return '';
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting srno: $e');
      return '';
    }
  }

  /// ✅ NEW: Build allpiddata JSON string
  static String _buildAllPidData(
      XmlElement pidData,
      Map<String, String> deviceInfo,
      Map<String, String> data,
      Map<String, String> skey,
      String hmac,
      Map<String, String> resp,
      ) {
    try {
      // Build the nested structure as seen in successful request
      final Map<String, dynamic> allPidDataMap = {
        "_Data": {
          "type": data['type'] ?? "X",
          "value": data['value'] ?? "",
        },
        "_DeviceInfo": {
          "add_info": _extractAdditionalInfo(pidData),
          "dc": deviceInfo['dc'] ?? "",
          "dpId": deviceInfo['dpId'] ?? "",
          "mc": deviceInfo['mc'] ?? "",
          "mi": deviceInfo['mi'] ?? "",
          "rdsId": deviceInfo['rdsId'] ?? "",
          "rdsVer": deviceInfo['rdsVer'] ?? "",
        },
        "_Hmac": hmac,
        "_Resp": {
          "errCode": resp['errCode'] ?? "0",
          "errInfo": resp['errInfo'] ?? "",
          "fCount": resp['fCount'] ?? "0",
          "fType": resp['fType'] ?? "0",
          "nmPoints": resp['nmPoints'] ?? "",
          "qScore": resp['qScore'] ?? "",
        },
        "_Skey": {
          "ci": skey['ci'] ?? "",
          "value": skey['value'] ?? "",
        },
      };

      return jsonEncode(allPidDataMap);
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error building allpiddata: $e');
      return "";
    }
  }

  /// ✅ NEW: Extract additional_info from DeviceInfo
  static Map<String, dynamic> _extractAdditionalInfo(XmlElement pidData) {
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;
      final additionalInfo = deviceInfo.findAllElements('additional_info').firstOrNull;

      if (additionalInfo != null) {
        final List<Map<String, String>> params = [];
        for (var param in additionalInfo.findAllElements('Param')) {
          params.add({
            "name": param.getAttribute('name') ?? '',
            "value": param.getAttribute('value') ?? '',
          });
        }
        return {"params": params};
      }
      return {"params": []};
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting additional_info: $e');
      return {"params": []};
    }
  }
}


/*
╔═══════════════════════════════════════════════════════════════════════════════════╗
║  USAGE IN AEPS CONTROLLER - completeFingpay2FAWithBiometric                       ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

Replace your current 2FA request body with one of these options:

OPTION 1: CaptureResponse fields spread directly in body (RECOMMENDED)
─────────────────────────────────────────────────────────────────────
```dart
Map<String, dynamic> body = PidDataConverter.build2FARequestBody(
  pidXml: result.pidData ?? '',
  aadhaarNumber: aadhaarController.text,
  latitude: homeScreenController.latitude.value.toString(),
  longitude: homeScreenController.longitude.value.toString(),
  deviceValue: selectedDevice.value,
  requestId: generateRequestId(),
);
```

This will produce request body like:
{
  "request_id": "ABC123",
  "lat": "26.8467",
  "long": "80.9462",
  "device": "FACE_AUTH",
  "aadhar_no": "123456789012",
  "skey": "TWOFACTORAUTH",
  "isFacialTan": true,
  "CI": "20280813",
  "DC": "44cbb49e-2a31-4e2f-...",
  "piddatatype": "X",
  "DPID": "Morpho.SmartChip",
  "DATAVALUE": "MjAyNi0wMS0wNl...",
  "HMAC": "1+6/DiBUk/O/6g...",
  "MC": "MIIEJDCCAwygAw...",
  "MI": "CBME3RD",
  "RDSID": "NXP.IDEMIA.001",
  "RDSVER": "1.1.4",
  "value": "RypW9nJGdtgxfM...",
  "pidata_qscore": ""
}


OPTION 2: Raw PID XML as base64 encdata
─────────────────────────────────────────────────────────────────────
```dart
Map<String, dynamic> body = PidDataConverter.build2FARequestBodyWithRawPidXml(
  pidXml: result.pidData ?? '',
  aadhaarNumber: aadhaarController.text,
  latitude: homeScreenController.latitude.value.toString(),
  longitude: homeScreenController.longitude.value.toString(),
  deviceValue: selectedDevice.value,
  requestId: generateRequestId(),
);
```


OPTION 3: JSON captureResponse as base64 encdata
─────────────────────────────────────────────────────────────────────
```dart
Map<String, dynamic> body = PidDataConverter.build2FARequestBodyWithJsonBase64(
  pidXml: result.pidData ?? '',
  aadhaarNumber: aadhaarController.text,
  latitude: homeScreenController.latitude.value.toString(),
  longitude: homeScreenController.longitude.value.toString(),
  deviceValue: selectedDevice.value,
  requestId: generateRequestId(),
);
```

╔═══════════════════════════════════════════════════════════════════════════════════╗
║  "Invalid encryption of Skey" ERROR FIX                                           ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

This error means the Skey (session key) data is not reaching the server correctly.

Possible causes:
1. ❌ Sending captureResponse as base64 encoded JSON when server expects raw fields
2. ❌ Missing or empty 'value' field (session key from <Skey> inner text)
3. ❌ Missing or empty 'CI' field (certificate ID from <Skey ci="...">)
4. ❌ Wrong key casing (e.g., 'ci' instead of 'CI')

Solution: Use build2FARequestBody() which spreads captureResponse fields directly
into the request body, matching the successful format from fingpay_final_obj.txt

*/














/*
import 'dart:convert';
import 'package:xml/xml.dart';

/// ╔═══════════════════════════════════════════════════════════════════════════════╗
/// ║  PID DATA CONVERTER - Fingpay API Format                                      ║
/// ║  Updated: January 2026                                                         ║
/// ║                                                                                ║
/// ║  CRITICAL: This follows the EXACT Fingpay API documentation format!           ║
/// ║                                                                                ║
/// ║  The API expects "captureResponse" object with these EXACT keys:              ║
/// ║  - CI, DC, piddatatype, DPID, DATAVALUE, HMAC, MC, MI, RDSID, RDSVER,         ║
/// ║    value (sessionKey), pidata_qscore (optional)                               ║
/// ║                                                                                ║
/// ║  Also supports additional fields: fCount, iCount, pCount, fType, iType, pType ║
/// ║                                                                                ║
/// ║  For Face Auth: isFacialTan = true                                            ║
/// ╚═══════════════════════════════════════════════════════════════════════════════╝

class PidDataConverter {

  /// ✅ MAIN METHOD: Convert PID XML to Fingpay captureResponse format
  /// This is the EXACT format required by Fingpay API (January 2026)
  /// Keys MUST match exactly: CI, DC, piddatatype, DPID, DATAVALUE, HMAC, MC, MI, RDSID, RDSVER, value
  static Map<String, dynamic> convertToCaptureResponse(String pidXml) {
    if (pidXml.isEmpty) {
      ConsoleLog.printInfo('❌ Empty PID XML');
      return {};
    }

    try {
      final document = XmlDocument.parse(pidXml);
      final pidData = document.findAllElements('PidData').first;

      // Extract all components
      final deviceInfo = _extractDeviceInfo(pidData);
      final data = _extractData(pidData);
      final skey = _extractSkey(pidData);
      final hmac = _extractHmac(pidData);
      final resp = _extractResp(pidData);

      // Build captureResponse in EXACT Fingpay format
      // ✅ CRITICAL: Key names must match Fingpay API exactly!
      final Map<String, dynamic> captureResponse = {
        // ✅ Certificate identifier - UPPERCASE
        "CI": skey['ci'] ?? "",

        // ✅ Device Code (dc attribute) - UPPERCASE
        "DC": deviceInfo['dc'] ?? "",

        // ✅ PID Data type - lowercase
        "piddatatype": data['type'] ?? "X",

        // ✅ Device Provider ID - UPPERCASE
        "DPID": deviceInfo['dpId'] ?? "",

        // ✅ Encrypted biometric data (from <Data> element) - UPPERCASE
        "DATAVALUE": data['value'] ?? "",

        // ✅ HMAC value - UPPERCASE
        "HMAC": hmac,

        // ✅ Machine Certificate - UPPERCASE
        "MC": deviceInfo['mc'] ?? "",

        // ✅ Machine Identifier - UPPERCASE
        "MI": deviceInfo['mi'] ?? "",

        // ✅ RD Service ID - UPPERCASE
        "RDSID": deviceInfo['rdsId'] ?? "",

        // ✅ RD Service Version - UPPERCASE
        "RDSVER": deviceInfo['rdsVer'] ?? "",

        // ✅ Session Key (from <Skey> element text) - lowercase
        "value": skey['value'] ?? "",

        // ✅ Quality Score - lowercase with underscore
        "pidata_qscore": resp['qScore'] ?? "",

        // ✅ Additional response fields (for compatibility)
        "errCode": resp['errCode'] ?? "0",
        "errInfo": resp['errInfo'] ?? "",
        "fCount": resp['fCount'] ?? "0",
        "fType": resp['fType'] ?? "0",
        "iCount": resp['iCount'] ?? "0",
        "iType": resp['iType'] ?? "0",
        "pCount": resp['pCount'] ?? "0",
        "pType": resp['pType'] ?? "0",
        "nmPoints": resp['nmPoints'] ?? "",
      };

      ConsoleLog.printInfo('✅ CaptureResponse generated successfully (Fingpay Format)');
      ConsoleLog.printInfo('   CI: ${captureResponse['CI']}');
      ConsoleLog.printInfo('   DPID: ${captureResponse['DPID']}');
      ConsoleLog.printInfo('   RDSID: ${captureResponse['RDSID']}');
      ConsoleLog.printInfo('   fCount: ${captureResponse['fCount']}, iCount: ${captureResponse['iCount']}, pCount: ${captureResponse['pCount']}');
      ConsoleLog.printInfo('   DATAVALUE length: ${(captureResponse['DATAVALUE'] as String?)?.length ?? 0}');
      ConsoleLog.printInfo('   value (sessionKey) length: ${(captureResponse['value'] as String?)?.length ?? 0}');

      return captureResponse;

    } catch (e, stackTrace) {
      ConsoleLog.printInfo('❌ CaptureResponse Conversion Error: $e');
      ConsoleLog.printInfo('Stack trace: $stackTrace');
      return {};
    }
  }

  /// ✅ Check if Face Authentication (for isFacialTan flag)
  static bool isFaceAuth(String deviceValue) {
    return deviceValue == 'FACE_AUTH';
  }

  /// ✅ LEGACY METHOD: Convert to base64 encoded JSON (for backward compatibility)
  /// Use this ONLY if your backend expects encdata as base64 JSON
  static String convertPidToEncdata(String pidXml, {String? deviceType}) {
    if (pidXml.isEmpty) {
      ConsoleLog.printInfo('❌ Empty PID XML');
      return '';
    }

    try {
      final captureResponse = convertToCaptureResponse(pidXml);
      if (captureResponse.isEmpty) return '';

      // Convert to JSON and base64 encode
      final jsonString = jsonEncode(captureResponse);
      final base64Encoded = base64Encode(utf8.encode(jsonString));

      ConsoleLog.printInfo('✅ Encdata (base64) length: ${base64Encoded.length}');
      return base64Encoded;

    } catch (e) {
      ConsoleLog.printInfo('❌ Encdata Conversion Error: $e');
      return '';
    }
  }

  /// ✅ Convenience method with explicit device type
  static String convertWithDeviceType(String pidXml, String deviceValue) {
    return convertPidToEncdata(pidXml);
  }

  /// ✅ Build complete Fingpay 2FA request body
  /// This builds the EXACT request format for Fingpay 2FA
  static Map<String, dynamic> build2FARequestBody({
    required String pidXml,
    required String aadhaarNumber,
    required String latitude,
    required String longitude,
    required String deviceValue,
    required String requestId,
  }) {
    final captureResponse = convertToCaptureResponse(pidXml);
    // Convert object to JSON string
    final jsonString = jsonEncode(captureResponse);
    ConsoleLog.printInfo('📊 JSON String length: ${jsonString.length}');

    // Base64 encode the JSON string
    final base64Encoded = base64Encode(utf8.encode(jsonString));
    ConsoleLog.printInfo('📊 Base64 Encdata length: ${base64Encoded.length}');
    final isFacial = isFaceAuth(deviceValue);

    return {
      "request_id": requestId,
      "lat": latitude,
      "long": longitude,
      "device": deviceValue,
      "aadhar_no": aadhaarNumber,
      "skey": "TWOFACTORAUTH",
      "isFacialTan": isFacial, // ✅ CRITICAL for Face Auth
      "encdata": base64Encoded, // ✅ Proper object format with correct keys
    };
  }

  /// ✅ Build complete Fingpay transaction request body
  /// This builds the EXACT request format from the API documentation
  static Map<String, dynamic> buildFingpayTransactionBody({
    required String pidXml,
    required String merchantTranId,
    required String aadhaarNumber,
    required String nationalBankIdNumber,
    required String mobileNumber,
    required String latitude,
    required String longitude,
    required String transactionAmount,
    required String transactionType, // "CW", "BE", "M" (AadhaarPay)
    required String subMerchantId,
    required String merchantUserName,
    required String merchantPin, // Should be MD5 hashed
    required String superMerchantId,
    String? virtualId,
    String requestRemarks = "",
    String languageCode = "en",
    String paymentType = "B",
    required String deviceValue, // For isFacialTan check
  }) {
    final captureResponse = convertToCaptureResponse(pidXml);
    final isFacial = isFaceAuth(deviceValue);

    return {
      "merchantTranId": merchantTranId,
      "captureResponse": captureResponse,
      "cardnumberORUID": {
        "adhaarNumber": virtualId != null && virtualId.isNotEmpty
            ? "999999999999" // 12 9's for virtual ID
            : aadhaarNumber,
        "indicatorforUID": virtualId != null && virtualId.isNotEmpty ? "2" : "0",
        "nationalBankIdentificationNumber": nationalBankIdNumber,
        if (virtualId != null && virtualId.isNotEmpty) "virtualId": virtualId,
      },
      "mobileNumber": mobileNumber,
      "paymentType": paymentType,
      "transactionType": transactionType,
      "latitude": latitude,
      "longitude": longitude,
      "requestRemarks": requestRemarks,
      "timestamp": DateTime.now().toIso8601String(),
      "transactionAmount": transactionAmount,
      "languageCode": languageCode,
      "subMerchantId": subMerchantId,
      "merchantUserName": merchantUserName,
      "merchantPin": merchantPin, // Must be MD5 hashed
      "superMerchantId": superMerchantId,
      "isFacialTan": isFacial, // ✅ CRITICAL for Face Auth
    };
  }

  // ==================== EXTRACTION METHODS ====================

  static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;
      result['dc'] = deviceInfo.getAttribute('dc') ?? '';
      result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
      result['mc'] = deviceInfo.getAttribute('mc') ?? '';
      result['mi'] = deviceInfo.getAttribute('mi') ?? '';
      result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
      result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting DeviceInfo: $e');
    }
    return result;
  }

  static Map<String, String> _extractData(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final dataElement = pidData.findAllElements('Data').first;
      result['type'] = dataElement.getAttribute('type') ?? 'X';
      result['value'] = dataElement.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Data: $e');
    }
    return result;
  }

  static Map<String, String> _extractSkey(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final skey = pidData.findAllElements('Skey').first;
      result['ci'] = skey.getAttribute('ci') ?? '';
      result['value'] = skey.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Skey: $e');
    }
    return result;
  }

  static String _extractHmac(XmlElement pidData) {
    try {
      return pidData.findAllElements('Hmac').first.innerText.trim();
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Hmac: $e');
      return '';
    }
  }

  static Map<String, String> _extractResp(XmlElement pidData) {
    final Map<String, String> result = {};
    try {
      final resp = pidData.findAllElements('Resp').first;
      result['errCode'] = resp.getAttribute('errCode') ?? '0';
      result['errInfo'] = resp.getAttribute('errInfo') ?? '';
      result['fCount'] = resp.getAttribute('fCount') ?? '0';
      result['fType'] = resp.getAttribute('fType') ?? '0';
      result['iCount'] = resp.getAttribute('iCount') ?? '0';
      result['iType'] = resp.getAttribute('iType') ?? '0';
      result['pCount'] = resp.getAttribute('pCount') ?? '0';
      result['pType'] = resp.getAttribute('pType') ?? '0';
      result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
      final qScore = resp.getAttribute('qScore');
      result['qScore'] = (qScore == null || qScore.isEmpty) ? '' : qScore;
    } catch (e) {
      ConsoleLog.printInfo('⚠️ Error extracting Resp: $e');
    }
    return result;
  }

  /// Debug method - ConsoleLog.printInfos all fields
  static void debugCaptureResponse(Map<String, dynamic> captureResponse) {
    ConsoleLog.printInfo('\n🔍 CAPTURE RESPONSE DEBUG (Fingpay Format):');
    ConsoleLog.printInfo('CI: ${captureResponse['CI']}');
    ConsoleLog.printInfo('DC: ${(captureResponse['DC'] as String?)?.substring(0, 20) ?? ''}...');
    ConsoleLog.printInfo('piddatatype: ${captureResponse['piddatatype']}');
    ConsoleLog.printInfo('DPID: ${captureResponse['DPID']}');
    ConsoleLog.printInfo('DATAVALUE length: ${(captureResponse['DATAVALUE'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('HMAC: ${(captureResponse['HMAC'] as String?)?.substring(0, 20) ?? ''}...');
    ConsoleLog.printInfo('MC length: ${(captureResponse['MC'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('MI: ${captureResponse['MI']}');
    ConsoleLog.printInfo('RDSID: ${captureResponse['RDSID']}');
    ConsoleLog.printInfo('RDSVER: ${captureResponse['RDSVER']}');
    ConsoleLog.printInfo('value (sessionKey) length: ${(captureResponse['value'] as String?)?.length ?? 0}');
    ConsoleLog.printInfo('pidata_qscore: ${captureResponse['pidata_qscore']}');
    ConsoleLog.printInfo('fCount: ${captureResponse['fCount']}, iCount: ${captureResponse['iCount']}, pCount: ${captureResponse['pCount']}');
  }

  /// ✅ Validate that all required fields are present
  static bool validateCaptureResponse(Map<String, dynamic> captureResponse) {
    final requiredFields = ['CI', 'DC', 'DPID', 'DATAVALUE', 'HMAC', 'MC', 'MI', 'RDSID', 'RDSVER', 'value'];

    for (final field in requiredFields) {
      if (!captureResponse.containsKey(field) ||
          captureResponse[field] == null ||
          (captureResponse[field] as String).isEmpty) {
        ConsoleLog.printInfo('❌ Missing or empty required field: $field');
        return false;
      }
    }

    ConsoleLog.printInfo('✅ All required fields present in captureResponse');
    return true;
  }
}


*/
/*
╔═══════════════════════════════════════════════════════════════════════════════════╗
║  FINGPAY API KEY MAPPING (January 2026)                                           ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

Fingpay Expected Keys    →    PID XML Source
─────────────────────────────────────────────
CI                       →    <Skey ci="...">
DC                       →    <DeviceInfo dc="...">
piddatatype              →    <Data type="...">
DPID                     →    <DeviceInfo dpId="...">
DATAVALUE                →    <Data>...</Data> (inner text)
HMAC                     →    <Hmac>...</Hmac>
MC                       →    <DeviceInfo mc="...">
MI                       →    <DeviceInfo mi="...">
RDSID                    →    <DeviceInfo rdsId="...">
RDSVER                   →    <DeviceInfo rdsVer="...">
value                    →    <Skey>...</Skey> (inner text)
pidata_qscore            →    <Resp qScore="...">


╔═══════════════════════════════════════════════════════════════════════════════════╗
║  USAGE INSTRUCTIONS FOR AEPS CONTROLLER                                           ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

⚠️ IMPORTANT: The Fingpay API expects `captureResponse` object with EXACT key casing!

CORRECT USAGE for 2FA:
```dart
Map<String, dynamic> body = PidDataConverter.build2FARequestBody(
  pidXml: result.pidData ?? '',
  aadhaarNumber: aadhaarController.text,
  latitude: homeScreenController.latitude.value.toString(),
  longitude: homeScreenController.longitude.value.toString(),
  deviceValue: selectedDevice.value,
  requestId: generateRequestId(),
);
```

CORRECT USAGE for Transactions:
```dart
Map<String, dynamic> body = PidDataConverter.buildFingpayTransactionBody(
  pidXml: result.pidData ?? '',
  merchantTranId: generateMerchantTranId(),
  aadhaarNumber: serviceAadhaarController.text,
  nationalBankIdNumber: selectedBankIin.value,
  mobileNumber: serviceMobileController.text,
  latitude: homeScreenController.latitude.value.toString(),
  longitude: homeScreenController.longitude.value.toString(),
  transactionAmount: serviceAmountController.text,
  transactionType: "CW", // or "BE" for balance, "M" for AadhaarPay
  subMerchantId: subMerchantId,
  merchantUserName: merchantUserName,
  merchantPin: md5Hash(merchantPin), // Must be MD5 hashed!
  superMerchantId: superMerchantId,
  deviceValue: serviceSelectedDevice.value,
);
```

╔═══════════════════════════════════════════════════════════════════════════════════╗
║  CRITICAL CHECKLIST FROM FINGPAY DOCUMENTATION                                    ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

✅ Transaction timeout should be 210 seconds
✅ Aadhaar must be validated with Verhoeff algorithm
✅ Amount max 10,000 for withdrawal
✅ IIN list should be fetched from Fingpay bank API
✅ Location (lat/long) must be accurate
✅ deviceIMEI in headers = biometric scanner serial number (for web)
✅ merchantPin must be MD5 hashed
✅ Success = bankRRN present AND responseCode = "00"
✅ isFacialTan = true for Face Authentication
✅ Never store Aadhaar number or PID data in logs
✅ Check for duplicate transactions before sending
✅ Key casing must be exact: CI, DC, DPID, DATAVALUE, HMAC, MC, MI, RDSID, RDSVER (UPPERCASE)
✅ piddatatype, value, pidata_qscore (lowercase)

*//*










*/
