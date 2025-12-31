import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// ============================================
/// AEPS BIOMETRIC DEVICE SERVICE
/// ============================================
/// Handles communication with native Android code
/// for biometric fingerprint capture using RD Services
/// ============================================

class AepsBiometricService extends GetxController {
  static AepsBiometricService get instance => Get.find<AepsBiometricService>();
  
  // Method Channel for native communication
  static const MethodChannel _channel = MethodChannel('aeps_biometric_channel');
  
  // Observable states
  final RxBool isScanning = false.obs;
  final RxBool isDeviceAvailable = false.obs;
  final RxString lastError = ''.obs;
  final RxString lastPidData = ''.obs;
  final RxList<BiometricDevice> availableDevices = <BiometricDevice>[].obs;
  
  // Supported devices
  static const List<Map<String, String>> supportedDevices = [
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
  
  // WADH values
  static const String wadhForEkyc = 'E0jzJ/P8UopUHAieZn8CKqS4WPMi5ZSYXgfnlfkWjrc=';
  static const String wadhEmpty = '';
  
  @override
  void onInit() {
    super.onInit();
    _checkAvailableDevices();
  }
  
  /// Check which devices are available (installed)
  Future<void> _checkAvailableDevices() async {
    try {
      final result = await _channel.invokeMethod('getAvailableDevices');
      
      if (result != null && result is List) {
        availableDevices.clear();
        for (var item in result) {
          if (item is Map) {
            availableDevices.add(BiometricDevice(
              name: _getDeviceName(item['device'] ?? ''),
              value: item['device'] ?? '',
              packageName: item['package'] ?? '',
              isInstalled: item['isInstalled'] ?? false,
            ));
          }
        }
        print('✅ Available Devices: ${availableDevices.where((d) => d.isInstalled).map((d) => d.name).toList()}');
      }
    } catch (e) {
      print('❌ Error checking available devices: $e');
    }
  }
  
  /// Get device display name
  String _getDeviceName(String value) {
    for (var device in supportedDevices) {
      if (device['value'] == value) {
        return device['name'] ?? value;
      }
    }
    return value;
  }
  
  /// Check if specific device is available
  Future<bool> checkDeviceAvailability(String device) async {
    try {
      final result = await _channel.invokeMethod('checkDeviceAvailability', {
        'device': device,
      });
      
      isDeviceAvailable.value = result == true;
      return result == true;
    } catch (e) {
      print('❌ Error checking device availability: $e');
      isDeviceAvailable.value = false;
      return false;
    }
  }
  
  /// Open biometric device for fingerprint capture
  /// 
  /// [device] - Device name (MANTRA, MFS110, MORPHO, etc.)
  /// [wadh] - WADH hash (use empty string for 2FA/transactions, wadhForEkyc for eKYC)
  /// [aadhaar] - Aadhaar number (optional, for logging)
  /// 
  /// Returns: BiometricResult with PID data on success
  Future<BiometricResult> scanFingerprint({
    required String device,
    String wadh = '',
    String aadhaar = '',
  }) async {
    if (isScanning.value) {
      return BiometricResult(
        success: false,
        errorCode: 'ALREADY_SCANNING',
        errorMessage: 'Fingerprint scan already in progress',
      );
    }
    
    if (device.isEmpty) {
      return BiometricResult(
        success: false,
        errorCode: 'NO_DEVICE',
        errorMessage: 'Please select a biometric device',
      );
    }
    
    try {
      isScanning.value = true;
      lastError.value = '';
      lastPidData.value = '';
      
      print('🔵 Starting fingerprint scan...');
      print('   Device: $device');
      print('   WADH: ${wadh.isEmpty ? "Empty (2FA/Transaction)" : "Present (eKYC)"}');
      
      final result = await _channel.invokeMethod('openBiometric', {
        'device': device,
        'wadh': wadh,
        'aadhaar': aadhaar,
      });
      
      isScanning.value = false;
      
      if (result != null && result is Map) {
        if (result['success'] == true) {
          final pidData = result['pidData'] as String? ?? '';
          lastPidData.value = pidData;
          
          print('✅ Fingerprint captured successfully');
          print('   PID Data Length: ${pidData.length}');
          
          return BiometricResult(
            success: true,
            pidData: pidData,
            device: result['device'] as String?,
            message: result['message'] as String? ?? 'Fingerprint captured successfully',
          );
        }
      }
      
      return BiometricResult(
        success: false,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: 'Failed to capture fingerprint',
      );
      
    } on PlatformException catch (e) {
      isScanning.value = false;
      lastError.value = e.message ?? 'Platform error';
      
      print('❌ Platform Exception: ${e.code} - ${e.message}');
      
      // Handle specific errors
      String userMessage = _getUserFriendlyError(e.code, e.message ?? '');
      
      return BiometricResult(
        success: false,
        errorCode: e.code,
        errorMessage: userMessage,
        details: e.details,
      );
      
    } catch (e) {
      isScanning.value = false;
      lastError.value = e.toString();
      
      print('❌ Error during fingerprint scan: $e');
      
      return BiometricResult(
        success: false,
        errorCode: 'EXCEPTION',
        errorMessage: 'Error during fingerprint capture: $e',
      );
    }
  }
  
  /// Get user-friendly error message
  String _getUserFriendlyError(String code, String message) {
    switch (code) {
      case 'DEVICE_NOT_INSTALLED':
        return 'Please install the RD Service app for your biometric device from Play Store';
      case 'CANCELLED':
        return 'Fingerprint capture was cancelled. Please try again.';
      case 'NO_PID_DATA':
        return 'No fingerprint data received. Please ensure the device is connected and try again.';
      case 'UNKNOWN_DEVICE':
        return 'Unknown biometric device. Please select a valid device.';
      case 'TIMEOUT':
        return 'Fingerprint capture timed out. Please try again.';
      case '710':
        return 'Fingerprint device not ready. Please connect the device and try again.';
      case '720':
        return 'Fingerprint capture failed. Please clean your finger and try again.';
      case '730':
        return 'Poor quality fingerprint. Please try with a different finger.';
      case '740':
        return 'Device busy. Please wait and try again.';
      default:
        return message.isNotEmpty ? message : 'Fingerprint capture failed. Please try again.';
    }
  }
  
  /// Cancel ongoing scan (if supported by device)
  void cancelScan() {
    isScanning.value = false;
    lastError.value = 'Scan cancelled by user';
  }
  
  /// Show device installation dialog
  void showInstallDeviceDialog(String device) {
    final packageName = _getPackageName(device);
    final playStoreUrl = 'market://details?id=$packageName';
    
    Fluttertoast.showToast(
      msg: 'Please install $device RD Service from Play Store',
      toastLength: Toast.LENGTH_LONG,
    );
    
    // You can also open Play Store here
    // launchUrl(Uri.parse(playStoreUrl));
  }
  
  /// Get package name for device
  String _getPackageName(String device) {
    const packages = {
      'MANTRA': 'com.mantra.rdservice',
      'MFS110': 'com.mantra.mfs110.rdservice',
      'MIS100V2': 'com.mantra.mis100v2.rdservice',
      'MORPHO': 'com.scl.rdservice',
      'Idemia': 'com.idemia.l1rdservice',
      'SecuGen Corp.': 'com.secugen.rdservice',
      'STARTEK': 'com.acpl.registersdk',
      'TATVIK': 'com.aborygen.rdservice',
    };
    return packages[device] ?? '';
  }
  
  /// Get installed devices only
  List<Map<String, String>> getInstalledDevices() {
    final installed = <Map<String, String>>[];
    
    installed.add({'name': 'Select Device', 'value': ''});
    
    for (var device in availableDevices) {
      if (device.isInstalled) {
        installed.add({'name': device.name, 'value': device.value});
      }
    }
    
    // If no devices are installed, return all supported devices
    if (installed.length == 1) {
      return supportedDevices;
    }
    
    return installed;
  }
}

/// Biometric device model
class BiometricDevice {
  final String name;
  final String value;
  final String packageName;
  final bool isInstalled;
  
  BiometricDevice({
    required this.name,
    required this.value,
    required this.packageName,
    required this.isInstalled,
  });
}

/// Biometric scan result
class BiometricResult {
  final bool success;
  final String? pidData;
  final String? device;
  final String? message;
  final String? errorCode;
  final String? errorMessage;
  final dynamic details;
  
  BiometricResult({
    required this.success,
    this.pidData,
    this.device,
    this.message,
    this.errorCode,
    this.errorMessage,
    this.details,
  });
  
  @override
  String toString() {
    if (success) {
      return 'BiometricResult(success: true, pidLength: ${pidData?.length ?? 0})';
    } else {
      return 'BiometricResult(success: false, error: $errorCode - $errorMessage)';
    }
  }
}
