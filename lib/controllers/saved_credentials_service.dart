import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/ConsoleLog.dart';

/// Model class for saved credentials
class SavedCredential {
  final String mobile;
  final String password;
  final DateTime savedAt;

  SavedCredential({
    required this.mobile,
    required this.password,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'password': password,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedCredential.fromJson(Map<String, dynamic> json) {
    return SavedCredential(
      mobile: json['mobile'] ?? '',
      password: json['password'] ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Get masked mobile number for display (e.g., "98****1234")
  String get maskedMobile {
    if (mobile.length < 10) return mobile;
    return '${mobile.substring(0, 2)}****${mobile.substring(mobile.length - 4)}';
  }

  /// Get masked password for display (e.g., "••••••••")
  String get maskedPassword => '•' * password.length.clamp(6, 12);
}

/// Service class for managing saved login credentials
/// Uses flutter_secure_storage for secure storage on Android
class SavedCredentialsService {
  static const String _storageKey = 'payrupya_saved_credentials';
  static const int _maxSavedCredentials = 5; // Maximum credentials to store

  // Singleton pattern
  static SavedCredentialsService? _instance;
  static SavedCredentialsService get instance {
    _instance ??= SavedCredentialsService._();
    return _instance!;
  }

  SavedCredentialsService._();

  // Android-specific secure storage options for better performance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Check if a credential is already saved
  Future<bool> isCredentialSaved(String mobile) async {
    try {
      final credentials = await getSavedCredentials();
      return credentials.any((cred) => cred.mobile == mobile);
    } catch (e) {
      ConsoleLog.printError('Error checking saved credential: $e');
      return false;
    }
  }

  /// Save a new credential
  Future<bool> saveCredential(String mobile, String password) async {
    try {
      if (mobile.isEmpty || password.isEmpty) return false;

      List<SavedCredential> credentials = await getSavedCredentials();

      // Check if already exists - update if yes
      final existingIndex = credentials.indexWhere((c) => c.mobile == mobile);
      
      if (existingIndex != -1) {
        // Update existing credential
        credentials[existingIndex] = SavedCredential(
          mobile: mobile,
          password: password,
          savedAt: DateTime.now(),
        );
      } else {
        // Add new credential
        final newCredential = SavedCredential(
          mobile: mobile,
          password: password,
          savedAt: DateTime.now(),
        );
        
        credentials.insert(0, newCredential); // Add at beginning (most recent)
        
        // Keep only max allowed credentials
        if (credentials.length > _maxSavedCredentials) {
          credentials = credentials.sublist(0, _maxSavedCredentials);
        }
      }

      // Save to secure storage
      final jsonString = jsonEncode(credentials.map((c) => c.toJson()).toList());
      await _secureStorage.write(key: _storageKey, value: jsonString);

      ConsoleLog.printSuccess('✅ Credential saved for: ${mobile.substring(0, 2)}****');
      return true;
    } catch (e) {
      ConsoleLog.printError('Error saving credential: $e');
      return false;
    }
  }

  /// Get all saved credentials
  Future<List<SavedCredential>> getSavedCredentials() async {
    try {
      final jsonString = await _secureStorage.read(key: _storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SavedCredential.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ConsoleLog.printError('Error getting saved credentials: $e');
      return [];
    }
  }

  /// Delete a saved credential by mobile number
  Future<bool> deleteCredential(String mobile) async {
    try {
      List<SavedCredential> credentials = await getSavedCredentials();
      credentials.removeWhere((c) => c.mobile == mobile);

      final jsonString = jsonEncode(credentials.map((c) => c.toJson()).toList());
      await _secureStorage.write(key: _storageKey, value: jsonString);

      ConsoleLog.printSuccess('✅ Credential deleted for: ${mobile.substring(0, 2)}****');
      return true;
    } catch (e) {
      ConsoleLog.printError('Error deleting credential: $e');
      return false;
    }
  }

  /// Clear all saved credentials
  Future<bool> clearAllCredentials() async {
    try {
      await _secureStorage.delete(key: _storageKey);
      ConsoleLog.printSuccess('✅ All saved credentials cleared');
      return true;
    } catch (e) {
      ConsoleLog.printError('Error clearing credentials: $e');
      return false;
    }
  }

  /// Check if there are any saved credentials
  Future<bool> hasSavedCredentials() async {
    try {
      final credentials = await getSavedCredentials();
      return credentials.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
