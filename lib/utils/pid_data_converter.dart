import 'dart:convert';
import 'package:xml/xml.dart';
/// Converts PID XML data to the encdata format expected by the backend API.
///
/// CRITICAL FIX: The backend PHP code at line 2005 does:
///   $piddata = json_decode($tempdata_array['allpiddata'], true);
///
/// This means 'allpiddata' must be a JSON STRING, not a Map/Object.
///
/// Additionally, the nested fields (_Data, _DeviceInfo, _Resp, _Skey) must also
/// be JSON strings because PHP does:
///   $piddata['_Data']['value'] - after json_decode, this accesses array keys


class PidDataConverter {
  /// Main entry point - converts PID XML to base64 encoded JSON (encdata format)
  static String convertPidToEncdata(String pidXml) {
    if (pidXml.isEmpty) {
      print('❌ Empty PID XML');
      return '';
    }

    try {
      final document = XmlDocument.parse(pidXml);
      final pidData = document.findAllElements('PidData').first;

      // Extract all components from PID XML
      final deviceInfo = _extractDeviceInfo(pidData);
      final data = _extractData(pidData);
      final skey = _extractSkey(pidData);
      final hmac = _extractHmac(pidData);
      final resp = _extractResp(pidData);
      final srno = _extractSerialNumber(pidData);

      // Build the EXACT encdata structure that works
      final Map<String, dynamic> encdataMap = {
        // Skey fields
        'CI': skey['ci'] ?? '',

        // DeviceInfo fields
        'DC': deviceInfo['dc'] ?? '',
        'DPID': deviceInfo['dpId'] ?? '',
        'MC': deviceInfo['mc'] ?? '',
        'MI': deviceInfo['mi'] ?? '',
        'RDSID': deviceInfo['rdsId'] ?? '',
        'RDSVER': deviceInfo['rdsVer'] ?? '',

        // Data fields
        'piddatatype': data['type'] ?? 'X',
        'DATAVALUE': data['value'] ?? '',

        // Hmac
        'HMAC': hmac,

        // Skey value
        'value': skey['value'] ?? '',

        // Resp fields
        'pidata_qscore': resp['qScore'] ?? '',
        'errCode': resp['errCode'] ?? '0',
        'errInfo': resp['errInfo'] ?? '',
        'nmpoints': resp['nmPoints'] ?? '',
        'fcount': resp['fCount'] ?? '',
        'fType': resp['fType'] ?? '',
        'pcount': resp['pCount'] ?? '0',
        'ptype': resp['pType'] ?? '0',
        'icount': resp['iCount'] ?? '0',

        // Serial number
        'srno': srno,

        // CRITICAL: Full PID XML as base64
        'base64pidData': base64Encode(utf8.encode(pidXml)),

        // CRITICAL: allpiddata must be a JSON STRING (not Map)
        'allpiddata': _buildAllPidDataJsonString(
          data: data,
          deviceInfo: deviceInfo,
          hmac: hmac,
          resp: resp,
          skey: skey,
          srno: srno,
        ),
      };

      // Debug output
      print('✅ Encdata Map Keys: ${encdataMap.keys.length}');
      print('   CI: ${encdataMap['CI']}');
      print('   DC: ${(encdataMap['DC'] as String).substring(0, 20)}...');
      print('   DPID: ${encdataMap['DPID']}');
      print('   srno: ${encdataMap['srno']}');
      print('   allpiddata type: ${encdataMap['allpiddata'].runtimeType}');

      // Convert to JSON and base64 encode
      final jsonString = jsonEncode(encdataMap);
      final base64Encoded = base64Encode(utf8.encode(jsonString));

      print('✅ Final encdata length: ${base64Encoded.length}');
      return base64Encoded;

    } catch (e, stackTrace) {
      print('❌ Conversion Error: $e');
      print('Stack trace: $stackTrace');
      return '';
    }
  }

  /// Build allpiddata as JSON STRING (PHP does json_decode on this)
  static String _buildAllPidDataJsonString({
    required Map<String, String> data,
    required Map<String, String> deviceInfo,
    required String hmac,
    required Map<String, String> resp,
    required Map<String, String> skey,
    required String srno,
  }) {
    // _Data structure
    final dataMap = {
      'type': data['type'] ?? 'X',
      'value': data['value'] ?? '',
    };

    // _DeviceInfo structure with additional_info
    final deviceInfoMap = {
      'dc': deviceInfo['dc'] ?? '',
      'dpId': deviceInfo['dpId'] ?? '',
      'mc': deviceInfo['mc'] ?? '',
      'mi': deviceInfo['mi'] ?? '',
      'rdsId': deviceInfo['rdsId'] ?? '',
      'rdsVer': deviceInfo['rdsVer'] ?? '',
      'add_info': {
        'params': [
          {'name': 'serial_number', 'value': srno},
          {'name': 'srno', 'value': srno},
          {'name': 'modality_type', 'value': 'Finger'},
          {'name': 'device_type', 'value': 'L1'},
        ]
      }
    };

    // _Resp structure
    final respMap = {
      'errCode': resp['errCode'] ?? '0',
      'errInfo': resp['errInfo'] ?? '',
      'fCount': resp['fCount'] ?? '1',
      'fType': resp['fType'] ?? '0',
      'iCount': resp['iCount'] ?? '0',
      'iType': resp['iType'] ?? '0',
      'nmPoints': resp['nmPoints'] ?? '',
      'pCount': resp['pCount'] ?? '0',
      'pType': resp['pType'] ?? '0',
      'qScore': resp['qScore'] ?? '',
    };

    // _Skey structure
    final skeyMap = {
      'ci': skey['ci'] ?? '',
      'value': skey['value'] ?? '',
    };

    // Complete allpiddata structure
    final allPidDataMap = {
      '_Data': dataMap,
      '_DeviceInfo': deviceInfoMap,
      '_Hmac': hmac,
      '_Resp': respMap,
      '_Skey': skeyMap,
    };

    // CRITICAL: Return as JSON STRING, not Map
    return jsonEncode(allPidDataMap);
  }

  /// Extract DeviceInfo attributes
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
      print('⚠️ Error extracting DeviceInfo: $e');
    }

    return result;
  }

  /// Extract Data element
  static Map<String, String> _extractData(XmlElement pidData) {
    final Map<String, String> result = {};

    try {
      final dataElement = pidData.findAllElements('Data').first;
      result['type'] = dataElement.getAttribute('type') ?? 'X';
      result['value'] = dataElement.innerText.trim();
    } catch (e) {
      print('⚠️ Error extracting Data: $e');
    }

    return result;
  }

  /// Extract Skey element
  static Map<String, String> _extractSkey(XmlElement pidData) {
    final Map<String, String> result = {};

    try {
      final skey = pidData.findAllElements('Skey').first;
      result['ci'] = skey.getAttribute('ci') ?? '';
      result['value'] = skey.innerText.trim();
    } catch (e) {
      print('⚠️ Error extracting Skey: $e');
    }

    return result;
  }

  /// Extract Hmac value
  static String _extractHmac(XmlElement pidData) {
    try {
      return pidData.findAllElements('Hmac').first.innerText.trim();
    } catch (e) {
      print('⚠️ Error extracting Hmac: $e');
      return '';
    }
  }

  /// Extract Resp attributes
  static Map<String, String> _extractResp(XmlElement pidData) {
    final Map<String, String> result = {};

    try {
      final resp = pidData.findAllElements('Resp').first;
      result['errCode'] = resp.getAttribute('errCode') ?? '0';
      result['errInfo'] = resp.getAttribute('errInfo') ?? '';
      result['fCount'] = resp.getAttribute('fCount') ?? '1';
      result['fType'] = resp.getAttribute('fType') ?? '0';
      result['iCount'] = resp.getAttribute('iCount') ?? '0';
      result['iType'] = resp.getAttribute('iType') ?? '0';
      result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
      result['pCount'] = resp.getAttribute('pCount') ?? '0';
      result['pType'] = resp.getAttribute('pType') ?? '0';

      // Handle qScore - use empty string if null/blank
      final qScore = resp.getAttribute('qScore');
      result['qScore'] = (qScore == null || qScore.isEmpty) ? '' : qScore;
    } catch (e) {
      print('⚠️ Error extracting Resp: $e');
    }

    return result;
  }

  /// Extract serial number from DeviceInfo additional_info
  static String _extractSerialNumber(XmlElement pidData) {
    try {
      final deviceInfo = pidData.findAllElements('DeviceInfo').first;

      // Try additional_info first
      try {
        final additionalInfo = deviceInfo.findAllElements('additional_info').first;
        for (var param in additionalInfo.findAllElements('Param')) {
          final name = param.getAttribute('name');
          if (name == 'serial_number' || name == 'srno') {
            final value = param.getAttribute('value');
            if (value != null && value.isNotEmpty) {
              return value;
            }
          }
        }
      } catch (_) {
        // additional_info might not exist
      }

      // Fallback: try dc attribute parsing or return empty
      return '';
    } catch (e) {
      print('⚠️ Error extracting serial number: $e');
      return '';
    }
  }

  /// Debug method to verify the encdata structure
  static void debugEncdata(String encdata) {
    try {
      final decoded = utf8.decode(base64Decode(encdata));
      final json = jsonDecode(decoded);

      print('\n🔍 ENCDATA DEBUG:');
      print('Total keys: ${(json as Map).keys.length}');
      print('Keys: ${json.keys.toList()}');

      if (json.containsKey('allpiddata')) {
        print('\nallpiddata type: ${json['allpiddata'].runtimeType}');
        if (json['allpiddata'] is String) {
          final nested = jsonDecode(json['allpiddata']);
          print('allpiddata nested keys: ${(nested as Map).keys.toList()}');
        }
      }
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}
















// class PidDataConverter {
//   static String convertPidToEncdata(String pidXml) {
//     if (pidXml.isEmpty) return "";
//     try {
//       final jsonMap = parsePidXmlToJson(pidXml);
//       return base64Encode(utf8.encode(jsonEncode(jsonMap)));
//     } catch (e) {
//       print('❌ Conversion Error: $e');
//       return "";
//     }
//   }
//
//   static Map<String, dynamic> parsePidXmlToJson(String pidXml) {
//     final document = XmlDocument.parse(pidXml);
//     // final pidData = document.rootElement;
//     final pidData = document.findAllElements('PidData').first;
//
//     final deviceInfo = pidData.findElements('DeviceInfo').first;
//     final dataElement = pidData.findElements('Data').first;
//     final skeyElement = pidData.findElements('Skey').first;
//     final hmacElement = pidData.findElements('Hmac').first;
//     final respElement = pidData.findElements('Resp').first;
//
//     // PHP expects these internal structures
//     Map<String, dynamic> respMap = {
//       'errCode': respElement.getAttribute('errCode') ?? '0',
//       'errInfo': respElement.getAttribute('errInfo') ?? '',
//       'fCount': respElement.getAttribute('fCount') ?? '0',
//       'fType': respElement.getAttribute('fType') ?? '0',
//       'nmPoints': respElement.getAttribute('nmPoints') ?? '0',
//       'qScore': (respElement.getAttribute('qScore') == null || respElement.getAttribute('qScore') == "")
//           ? "0" : respElement.getAttribute('qScore'), // ✅ Handled blank qScore
//     };
//
//     Map<String, dynamic> deviceInfoMap = {
//       'dpId': deviceInfo.getAttribute('dpId') ?? '',
//       'rdsId': deviceInfo.getAttribute('rdsId') ?? '',
//       'rdsVer': deviceInfo.getAttribute('rdsVer') ?? '',
//       'mi': deviceInfo.getAttribute('mi') ?? '',
//       'mc': deviceInfo.getAttribute('mc') ?? '',
//       'dc': deviceInfo.getAttribute('dc') ?? '',
//     };
//
//     Map<String, dynamic> skeyMap = {
//       'ci': skeyElement.getAttribute('ci') ?? '',
//       'value': skeyElement.innerText.trim(),
//     };
//
//     Map<String, dynamic> dataMap = {
//       'type': dataElement.getAttribute('type') ?? 'X',
//       'value': dataElement.innerText.trim(),
//     };
//
//     // allpiddata MUST BE A JSON STRING for PHP's second json_decode
//     Map<String, dynamic> allPidDataMap = {
//       '_Resp': respMap,
//       '_DeviceInfo': deviceInfoMap,
//       '_Skey': skeyMap,
//       '_Hmac': hmacElement.innerText.trim(),
//       '_Data': dataMap,
//     };
//
//     return {
//       'allpiddata': jsonEncode(allPidDataMap), // ✅ This is now a String
//       'DPID': deviceInfoMap['dpId'],
//       'RDSID': deviceInfoMap['rdsId'],
//       'HMAC': hmacElement.innerText.trim(),
//     };
//   }
// }















// class PidDataConverter {
//   static String convertPidToEncdata(String pidXml) {
//     if (pidXml.isEmpty) return "";
//     try {
//       final jsonMap = parsePidXmlToJson(pidXml);
//       // Step 1: Convert Map to JSON String
//       String jsonString = jsonEncode(jsonMap);
//       // Step 2: Base64 Encode (PHP logic: base64_decode($params['encdata']))
//       return base64Encode(utf8.encode(jsonString));
//     } catch (e) {
//       return "";
//     }
//   }
//
//   static Map<String, dynamic> parsePidXmlToJson(String pidXml) {
//     final document = XmlDocument.parse(pidXml);
//     final pidData = document.rootElement;
//
//     final deviceInfo = pidData.findElements('DeviceInfo').first;
//     final dataElement = pidData.findElements('Data').first;
//     final skeyElement = pidData.findElements('Skey').first;
//     final hmacElement = pidData.findElements('Hmac').first;
//     final respElement = pidData.findElements('Resp').first;
//
//     // PHP expects these exact nested maps (not strings)
//     Map<String, dynamic> respMap = {
//       'errCode': respElement.getAttribute('errCode') ?? '0',
//       'errInfo': respElement.getAttribute('errInfo') ?? '',
//       'fCount': respElement.getAttribute('fCount') ?? '0',
//       'fType': respElement.getAttribute('fType') ?? '0',
//       'nmPoints': respElement.getAttribute('nmPoints') ?? '0',
//       'qScore': respElement.getAttribute('qScore') ?? '0',
//     };
//
//     Map<String, dynamic> deviceInfoMap = {
//       'dpId': deviceInfo.getAttribute('dpId') ?? '',
//       'rdsId': deviceInfo.getAttribute('rdsId') ?? '',
//       'rdsVer': deviceInfo.getAttribute('rdsVer') ?? '',
//       'mi': deviceInfo.getAttribute('mi') ?? '',
//       'mc': deviceInfo.getAttribute('mc') ?? '',
//       'dc': deviceInfo.getAttribute('dc') ?? '',
//     };
//
//     Map<String, dynamic> skeyMap = {
//       'ci': skeyElement.getAttribute('ci') ?? '',
//       'value': skeyElement.innerText.trim(),
//     };
//
//     Map<String, dynamic> dataMap = {
//       'type': dataElement.getAttribute('type') ?? 'X',
//       'value': dataElement.innerText.trim(),
//     };
//
//     // allpiddata variable for the second json_decode in PHP
//     Map<String, dynamic> allPidData = {
//       '_Resp': respMap,
//       '_DeviceInfo': deviceInfoMap,
//       '_Skey': skeyMap,
//       '_Hmac': hmacElement.innerText.trim(),
//       '_Data': dataMap,
//     };
//
//     // Main object returned to encdata
//     return {
//       'allpiddata': allPidData, // PHP will json_decode this
//       'DPID': deviceInfoMap['dpId'],
//       'RDSID': deviceInfoMap['rdsId'],
//       'HMAC': hmacElement.innerText.trim(),
//     };
//   }
// }

// class PidDataConverter {
//
//   /// Main entry point - converts PID XML to base64 encoded JSON string
//   static String convertPidToEncdata(String pidXml) {
//     if (pidXml.isEmpty) {
//       return '';
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
//       // Build the complete structure
//       final Map<String, dynamic> result = {
//         'CI': skey['ci'] ?? '',
//         'DC': deviceInfo['dc'] ?? '',
//         'piddatatype': data['type'] ?? 'X',
//         'DPID': deviceInfo['dpId'] ?? '',
//         'DATAVALUE': data['value'] ?? '',
//         'HMAC': hmac,
//         'MC': deviceInfo['mc'] ?? '',
//         'MI': deviceInfo['mi'] ?? '',
//         'RDSID': deviceInfo['rdsId'] ?? '',
//         'RDSVER': deviceInfo['rdsVer'] ?? '',
//         'value': skey['value'] ?? '',
//         'pidata_qscore': resp['qScore'] ?? '',
//         'base64pidData': base64Encode(utf8.encode(pidXml)),
//         'errCode': resp['errCode'] ?? '0',
//         'errInfo': resp['errInfo'] ?? '',
//         'nmpoints': resp['nmPoints'] ?? '',
//         'fcount': resp['fCount'] ?? '',
//         'fType': resp['fType'] ?? '',
//         'srno': _extractSerialNumber(pidData),
//         // CRITICAL: allpiddata must be a JSON STRING containing the nested structure
//         'allpiddata': _buildAllPidDataAsJsonString(data, deviceInfo, hmac, resp, skey),
//       };
//
//       // Convert to JSON and then base64 encode
//       final jsonString = jsonEncode(result);
//       return base64Encode(utf8.encode(jsonString));
//
//     } catch (e) {
//       print('Error converting PID to encdata: $e');
//       return '';
//     }
//   }
//
//   /// CRITICAL FIX: Build allpiddata as a JSON STRING
//   ///
//   /// PHP does: $piddata = json_decode($tempdata_array['allpiddata'], true);
//   /// So allpiddata must be a JSON string that when decoded gives:
//   /// {
//   ///   "_Data": {"type": "X", "value": "..."},
//   ///   "_DeviceInfo": {"dc": "...", "dpId": "...", ...},
//   ///   "_Hmac": "...",
//   ///   "_Resp": {"errCode": "0", ...},
//   ///   "_Skey": {"ci": "...", "value": "..."}
//   /// }
//   ///
//   /// Note: The nested fields (_Data, _DeviceInfo, etc.) should be OBJECTS (Maps)
//   /// because after json_decode, PHP accesses them like: $piddata['_Data']['value']
//   static String _buildAllPidDataAsJsonString(
//       Map<String, String> data,
//       Map<String, String> deviceInfo,
//       String hmac,
//       Map<String, String> resp,
//       Map<String, String> skey,
//       ) {
//     // Build _Data as a Map (will become array after PHP json_decode)
//     final dataMap = {
//       'type': data['type'] ?? 'X',
//       'value': data['value'] ?? '',
//     };
//
//     // Build _DeviceInfo as a Map
//     final deviceInfoMap = {
//       'dc': deviceInfo['dc'] ?? '',
//       'dpId': deviceInfo['dpId'] ?? '',
//       'mc': deviceInfo['mc'] ?? '',
//       'mi': deviceInfo['mi'] ?? '',
//       'rdsId': deviceInfo['rdsId'] ?? '',
//       'rdsVer': deviceInfo['rdsVer'] ?? '',
//       'add_info': {
//         'params': [
//           {'name': 'srno', 'value': deviceInfo['srno'] ?? ''},
//           {'name': 'modality_type', 'value': 'Finger'},
//           {'name': 'device_type', 'value': 'L1'},
//         ]
//       }
//     };
//
//     // Build _Resp as a Map
//     final respMap = {
//       'errCode': resp['errCode'] ?? '0',
//       'errInfo': resp['errInfo'] ?? '',
//       'fCount': resp['fCount'] ?? '1',
//       'fType': resp['fType'] ?? '0',
//       'nmPoints': resp['nmPoints'] ?? '',
//       'qScore': resp['qScore'] ?? '',
//     };
//
//     // Build _Skey as a Map
//     final skeyMap = {
//       'ci': skey['ci'] ?? '',
//       'value': skey['value'] ?? '',
//     };
//
//     // Build the complete allpiddata structure as a Map
//     final allPidDataMap = {
//       '_Data': dataMap,           // Map - PHP will access as $piddata['_Data']['value']
//       '_DeviceInfo': deviceInfoMap, // Map
//       '_Hmac': hmac,              // String
//       '_Resp': respMap,           // Map
//       '_Skey': skeyMap,           // Map
//     };
//
//     // CRITICAL: Return as JSON STRING, not as Map
//     // PHP does: json_decode($tempdata_array['allpiddata'], true)
//     return jsonEncode(allPidDataMap);
//   }
//
//   /// Extract DeviceInfo attributes from PidData
//   static Map<String, String> _extractDeviceInfo(XmlElement pidData) {
//     final Map<String, String> result = {};
//
//     try {
//       final deviceInfo = pidData.findAllElements('DeviceInfo').first;
//       result['dc'] = deviceInfo.getAttribute('dc') ?? '';
//       result['dpId'] = deviceInfo.getAttribute('dpId') ?? '';
//       result['mc'] = deviceInfo.getAttribute('mc') ?? '';
//       result['mi'] = deviceInfo.getAttribute('mi') ?? '';
//       result['rdsId'] = deviceInfo.getAttribute('rdsId') ?? '';
//       result['rdsVer'] = deviceInfo.getAttribute('rdsVer') ?? '';
//
//       // Extract serial number from additional_info if present
//       try {
//         final additionalInfo = deviceInfo.findAllElements('additional_info').first;
//         for (var param in additionalInfo.findAllElements('Param')) {
//           if (param.getAttribute('name') == 'serial_number' ||
//               param.getAttribute('name') == 'srno') {
//             result['srno'] = param.getAttribute('value') ?? '';
//             break;
//           }
//         }
//       } catch (_) {
//         // additional_info might not exist
//       }
//     } catch (e) {
//       print('Error extracting DeviceInfo: $e');
//     }
//
//     return result;
//   }
//
//   /// Extract Data element (encrypted biometric data)
//   static Map<String, String> _extractData(XmlElement pidData) {
//     final Map<String, String> result = {};
//
//     try {
//       final dataElement = pidData.findAllElements('Data').first;
//       result['type'] = dataElement.getAttribute('type') ?? 'X';
//       result['value'] = dataElement.innerText.trim();
//     } catch (e) {
//       print('Error extracting Data: $e');
//     }
//
//     return result;
//   }
//
//   /// Extract Skey element
//   static Map<String, String> _extractSkey(XmlElement pidData) {
//     final Map<String, String> result = {};
//
//     try {
//       final skey = pidData.findAllElements('Skey').first;
//       result['ci'] = skey.getAttribute('ci') ?? '';
//       result['value'] = skey.innerText.trim();
//     } catch (e) {
//       print('Error extracting Skey: $e');
//     }
//
//     return result;
//   }
//
//   /// Extract Hmac value
//   static String _extractHmac(XmlElement pidData) {
//     try {
//       return pidData.findAllElements('Hmac').first.innerText.trim();
//     } catch (e) {
//       print('Error extracting Hmac: $e');
//       return '';
//     }
//   }
//
//   /// Extract Resp attributes
//   static Map<String, String> _extractResp(XmlElement pidData) {
//     final Map<String, String> result = {};
//
//     try {
//       final resp = pidData.findAllElements('Resp').first;
//       result['errCode'] = resp.getAttribute('errCode') ?? '0';
//       result['errInfo'] = resp.getAttribute('errInfo') ?? '';
//       result['fCount'] = resp.getAttribute('fCount') ?? '1';
//       result['fType'] = resp.getAttribute('fType') ?? '0';
//       result['nmPoints'] = resp.getAttribute('nmPoints') ?? '';
//       result['qScore'] = resp.getAttribute('qScore') ?? '';
//     } catch (e) {
//       print('Error extracting Resp: $e');
//     }
//
//     return result;
//   }
//
//   /// Extract serial number from DeviceInfo additional_info
//   static String _extractSerialNumber(XmlElement pidData) {
//     try {
//       final deviceInfo = pidData.findAllElements('DeviceInfo').first;
//
//       // Try to get from additional_info first
//       try {
//         final additionalInfo = deviceInfo.findAllElements('additional_info').first;
//         for (var param in additionalInfo.findAllElements('Param')) {
//           final name = param.getAttribute('name');
//           if (name == 'serial_number' || name == 'srno') {
//             return param.getAttribute('value') ?? '';
//           }
//         }
//       } catch (_) {}
//
//       // Fallback: try to extract from dc attribute or other sources
//       return '';
//     } catch (e) {
//       return '';
//     }
//   }
// }


// ╔═══════════════════════════════════════════════════════════════╗
// ║  HOW TO USE IN AEPS CONTROLLER:                               ║
// ╚═══════════════════════════════════════════════════════════════╝

/*

1. Add import at top of aeps_controller.dart:

   import 'package:payrupya/utils/pid_data_converter.dart';
   // OR wherever you place this file


2. In completeInstantpay2FAWithBiometric() method (around line 4272-4280):

   // ❌ OLD CODE:
   Map<String, dynamic> body = {
     "request_id": generateRequestId(),
     "lat": homeScreenController.latitude.value.toString(),
     "long": homeScreenController.longitude.value.toString(),
     "device": selectedDevice.value,
     "aadhar_no": aadhaarController.text,
     "skey": "TWOFACTORAUTH",
     "encdata": result.pidData,  // ❌ Raw XML - WRONG!
   };

   // ✅ NEW CODE:
   Map<String, dynamic> body = {
     "request_id": generateRequestId(),
     "lat": homeScreenController.latitude.value.toString(),
     "long": homeScreenController.longitude.value.toString(),
     "device": selectedDevice.value,
     "aadhar_no": aadhaarController.text,
     "skey": "TWOFACTORAUTH",
     "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),  // ✅ Base64 JSON
   };


3. Similarly update completeFingpay2FAWithBiometric() (around line 4181):

   "encdata": PidDataConverter.convertPidToEncdata(result.pidData ?? ''),


4. And any other method that uses encdata field.

*/
