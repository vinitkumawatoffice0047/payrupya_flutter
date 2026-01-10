import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_provider.dart';
import '../utils/custom_loading.dart';
import '../utils/CustomDialog.dart';
import '../utils/ConsoleLog.dart';
import '../api/web_api_constant.dart';
import '../utils/global_utils.dart';

class KycController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final ImagePicker _picker = ImagePicker();

  // KYC Document Status
  var kycDocuments = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getKycStatus();
  }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  // Get KYC Status
  Future<void> getKycStatus() async {
    try {
      isLoading.value = true;

      // Load auth credentials first
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        ConsoleLog.printError("❌ Invalid token or signature");
        CustomDialog.error(message: "Session expired. Please login again.");
        isLoading.value = false;
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_KYC_STATUS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      isLoading.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("GET KYC STATUS RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          dynamic dataValue = result['data'];
          
          // Handle both List and Map response structures
          if (dataValue is List) {
            // API returns a list of documents
            List<dynamic> dataList = dataValue;
            
            ConsoleLog.printColor("KYC Data is a List with ${dataList.length} items", color: "cyan");
            if (dataList.isNotEmpty) {
              ConsoleLog.printColor("First item structure: ${jsonEncode(dataList.first)}", color: "cyan");
            }
            
            // Map API response to our document structure
            // Initialize with default values (pending status)
            Map<String, Map<String, dynamic>> documentMap = {
              'aadhaar': {
                'title': 'Aadhar Card',
                'frontImage': '',
                'backImage': '',
                'status': 'pending',
                'frontStatus': 'pending',
                'backStatus': 'pending',
                'frontUserDocId': null,
                'backUserDocId': null,
                'type': 'aadhaar'
              },
              'pan': {
                'title': 'PAN Card',
                'frontImage': '',
                'status': 'pending',
                'userDocId': null,
                'type': 'pan'
              },
              'gst': {
                'title': 'GST Certificate',
                'frontImage': '',
                'status': 'pending',
                'userDocId': null,
                'type': 'gst'
              },
              'cheque': {
                'title': 'Cancelled Cheque',
                'frontImage': '',
                'status': 'pending',
                'userDocId': null,
                'type': 'cheque'
              },
              'shop': {
                'title': 'Shop Image',
                'frontImage': '',
                'status': 'pending',
                'userDocId': null,
                'type': 'shop'
              },
              'selfie': {
                'title': 'Selfie with Employee',
                'frontImage': '',
                'status': 'pending',
                'userDocId': null,
                'type': 'selfie'
              },
            };
            
            // Process each document from API response
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                String docName = (item['doc_name'] ?? item['docname'] ?? '').toString();
                String docNameLower = docName.toLowerCase();
                String status = (item['status'] ?? 'pending').toString().toUpperCase();
                // Try multiple field name variations for userdoc_id
                String? userdocId = item['userdoc_id']?.toString() ?? 
                                   item['userdocId']?.toString() ??
                                   item['user_doc_id']?.toString() ??
                                   item['userDocId']?.toString();
                
                // Clean userdocId - remove 'null' strings
                if (userdocId != null && (userdocId.isEmpty || userdocId.toLowerCase() == 'null')) {
                  userdocId = null;
                }
                
                bool isUploaded = userdocId != null && userdocId.isNotEmpty;
                
                ConsoleLog.printInfo("Processing doc_name: $docName, status: $status, userdoc_id: $userdocId, isUploaded: $isUploaded");
                if (isUploaded) {
                  ConsoleLog.printSuccess("  ✓ Document is uploaded with userdocId: $userdocId");
                }
                
                // Map document names to our document types
                // Handle Aadhar Card Front and Back separately
                if (docNameLower.contains('aadhar') || docNameLower.contains('aadhaar')) {
                  if (docNameLower.contains('front')) {
                    documentMap['aadhaar']!['frontImage'] = isUploaded ? 'uploaded' : '';
                    documentMap['aadhaar']!['frontStatus'] = isUploaded ? status : 'pending';
                    documentMap['aadhaar']!['frontUserDocId'] = userdocId;
                    // Update overall status if front is uploaded
                    if (isUploaded) {
                      String currentStatus = documentMap['aadhaar']!['status'].toString();
                      if (currentStatus == 'pending' || status == 'APPROVED') {
                        documentMap['aadhaar']!['status'] = status;
                      }
                    }
                  } else if (docNameLower.contains('back')) {
                    documentMap['aadhaar']!['backImage'] = isUploaded ? 'uploaded' : '';
                    documentMap['aadhaar']!['backStatus'] = isUploaded ? status : 'pending';
                    documentMap['aadhaar']!['backUserDocId'] = userdocId;
                    // Update overall status based on both front and back
                    if (isUploaded) {
                      String currentStatus = documentMap['aadhaar']!['status'].toString();
                      String frontStatus = documentMap['aadhaar']!['frontStatus'].toString();
                      // If both are approved, overall status is approved
                      if (frontStatus == 'APPROVED' && status == 'APPROVED') {
                        documentMap['aadhaar']!['status'] = 'APPROVED';
                      } else if (status == 'APPROVED') {
                        documentMap['aadhaar']!['status'] = status;
                      } else if (currentStatus == 'pending' && status != 'pending') {
                        documentMap['aadhaar']!['status'] = status;
                      }
                    }
                  } else {
                    // Generic aadhar (not front/back specified) - treat as front
                    documentMap['aadhaar']!['frontImage'] = isUploaded ? 'uploaded' : '';
                    documentMap['aadhaar']!['frontStatus'] = isUploaded ? status : 'pending';
                    documentMap['aadhaar']!['frontUserDocId'] = userdocId;
                    documentMap['aadhaar']!['status'] = isUploaded ? status : 'pending';
                  }
                } else if (docNameLower.contains('pan') && docNameLower.contains('card')) {
                  documentMap['pan']!['frontImage'] = isUploaded ? 'uploaded' : '';
                  documentMap['pan']!['status'] = isUploaded ? status : 'pending';
                  documentMap['pan']!['userDocId'] = userdocId;
                } else if (docNameLower.contains('gst')) {
                  documentMap['gst']!['frontImage'] = isUploaded ? 'uploaded' : '';
                  documentMap['gst']!['status'] = isUploaded ? status : 'pending';
                  documentMap['gst']!['userDocId'] = userdocId;
                } else if (docNameLower.contains('cheque') || docNameLower.contains('cancel')) {
                  documentMap['cheque']!['frontImage'] = isUploaded ? 'uploaded' : '';
                  documentMap['cheque']!['status'] = isUploaded ? status : 'pending';
                  documentMap['cheque']!['userDocId'] = userdocId;
                } else if (docNameLower.contains('shop') || docNameLower.contains('store')) {
                  documentMap['shop']!['frontImage'] = isUploaded ? 'uploaded' : '';
                  documentMap['shop']!['status'] = isUploaded ? status : 'pending';
                  documentMap['shop']!['userDocId'] = userdocId;
                } else if (docNameLower.contains('selfie') || docNameLower.contains('employee') || docNameLower.contains('distributor')) {
                  documentMap['selfie']!['frontImage'] = isUploaded ? 'uploaded' : '';
                  documentMap['selfie']!['status'] = isUploaded ? status : 'pending';
                  documentMap['selfie']!['userDocId'] = userdocId;
                }
              }
            }
            
            // Convert map to list in the correct order
            kycDocuments.value = [
              documentMap['aadhaar']!,
              documentMap['pan']!,
              documentMap['gst']!,
              documentMap['cheque']!,
              documentMap['shop']!,
              documentMap['selfie']!,
            ];
            
            // Log the updated documents for debugging
            ConsoleLog.printColor("KYC Documents after mapping:", color: "cyan");
            for (var doc in kycDocuments) {
              ConsoleLog.printInfo("  - ${doc['title']}: status=${doc['status']}, frontUserDocId=${doc['frontUserDocId']}, backUserDocId=${doc['backUserDocId']}, userDocId=${doc['userDocId']}");
            }
            
            // Force refresh the reactive list
            kycDocuments.refresh();
          } else if (dataValue is Map<String, dynamic>) {
            // API returns a map (original structure)
            Map<String, dynamic> data = dataValue;

            // Initialize KYC documents list
            kycDocuments.value = [
              {
                'title': 'Aadhar Card',
                'frontImage': data['aadhaar_front'] ?? '',
                'backImage': data['aadhaar_back'] ?? '',
                'status': data['aadhaar_status'] ?? 'pending',
                'type': 'aadhaar'
              },
              {
                'title': 'PAN Card',
                'frontImage': data['pan_front'] ?? '',
                'status': data['pan_status'] ?? 'pending',
                'type': 'pan'
              },
              {
                'title': 'GST Certificate',
                'frontImage': data['gst_certificate'] ?? '',
                'status': data['gst_status'] ?? 'pending',
                'type': 'gst'
              },
              {
                'title': 'Cancelled Cheque',
                'frontImage': data['cancelled_cheque'] ?? '',
                'status': data['cheque_status'] ?? 'pending',
                'type': 'cheque'
              },
              {
                'title': 'Shop Image',
                'frontImage': data['shop_image'] ?? '',
                'status': data['shop_status'] ?? 'pending',
                'type': 'shop'
              },
              {
                'title': 'Selfie with Employee',
                'frontImage': data['selfie_image'] ?? '',
                'status': data['selfie_status'] ?? 'pending',
                'type': 'selfie'
              },
            ];
          } else {
            // Unknown data format
            ConsoleLog.printError("Unknown data format in KYC response: ${dataValue.runtimeType}");
            kycDocuments.value = [];
          }
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to fetch KYC status',
          );
        }
      } else {
        CustomDialog.error(
          message: 'Failed to fetch KYC status',
        );
      }
      
      // After getting KYC status, fetch uploaded documents with image URLs
      await fetchUploadedDocs();
    } catch (e) {
      isLoading.value = false;
      ConsoleLog.printError('Error in getKycStatus: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }

  // Fetch Uploaded Documents with Image URLs
  Future<void> fetchUploadedDocs() async {
    try {
      // Load auth credentials first
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        ConsoleLog.printError("❌ Invalid token or signature");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_FETCH_UPLOADED_DOCS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("FETCH UPLOADED DOCS RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          dynamic dataValue = result['data'];
          
          if (dataValue is List) {
            List<dynamic> uploadedDocsList = dataValue;
            
            ConsoleLog.printColor("Uploaded docs list with ${uploadedDocsList.length} items", color: "cyan");
            
            // Update kycDocuments with userdocId from API response
            // API response contains userdoc_id, not image URLs
            // We'll use userdoc_id to generate view URL when needed
            for (var uploadedDoc in uploadedDocsList) {
              if (uploadedDoc is Map<String, dynamic>) {
                String? userdocId = uploadedDoc['userdoc_id']?.toString();
                String? docName = uploadedDoc['doc_name']?.toString() ?? 
                                  uploadedDoc['docname']?.toString();
                String? status = uploadedDoc['status']?.toString();
                
                ConsoleLog.printInfo("Processing uploaded doc - userdocId: $userdocId, docName: $docName, status: $status");
                
                if (userdocId != null && userdocId.isNotEmpty && userdocId != 'null') {
                  String statusUpper = (status ?? 'APPROVED').toString().toUpperCase();
                  
                  // Find and update the corresponding document in kycDocuments by matching doc_name or userdocId
                  for (int i = 0; i < kycDocuments.length; i++) {
                    Map<String, dynamic> doc = kycDocuments[i];
                    String docNameLower = (docName ?? '').toLowerCase();
                    bool updated = false;
                    
                    // Check for Aadhar Front/Back by matching doc_name or userdocId
                    if (doc['type'] == 'aadhaar') {
                      String? existingFrontId = doc['frontUserDocId']?.toString();
                      String? existingBackId = doc['backUserDocId']?.toString();
                      
                      // Match by userdocId first (most reliable)
                      if (docNameLower.contains('front') && (docNameLower.contains('aadhar') || docNameLower.contains('aadhaar'))) {
                        // Match Aadhar Front - update if userdocId matches or if not set yet
                        if (existingFrontId == userdocId || (existingFrontId == null || existingFrontId.isEmpty || existingFrontId == 'null')) {
                          if (existingFrontId != userdocId) {
                            kycDocuments[i]['frontImage'] = 'uploaded';
                            kycDocuments[i]['frontUserDocId'] = userdocId;
                          }
                          kycDocuments[i]['frontStatus'] = statusUpper;
                          
                          // Update overall status based on front status
                          String? backStatus = doc['backStatus']?.toString();
                          if (backStatus == 'APPROVED' && statusUpper == 'APPROVED') {
                            kycDocuments[i]['status'] = 'APPROVED';
                          } else if (statusUpper == 'APPROVED') {
                            kycDocuments[i]['status'] = statusUpper;
                          } else if (backStatus != null && backStatus != 'APPROVED' && statusUpper != 'APPROVED') {
                            kycDocuments[i]['status'] = statusUpper;
                          }
                          
                          updated = true;
                          ConsoleLog.printSuccess("✅ Updated Aadhar Front - userdocId: $userdocId, status: $statusUpper");
                        }
                      } else if (docNameLower.contains('back') && (docNameLower.contains('aadhar') || docNameLower.contains('aadhaar'))) {
                        // Match Aadhar Back - update if userdocId matches or if not set yet
                        if (existingBackId == userdocId || (existingBackId == null || existingBackId.isEmpty || existingBackId == 'null')) {
                          if (existingBackId != userdocId) {
                            kycDocuments[i]['backImage'] = 'uploaded';
                            kycDocuments[i]['backUserDocId'] = userdocId;
                          }
                          kycDocuments[i]['backStatus'] = statusUpper;
                          
                          // Update overall status based on back status
                          String? frontStatus = doc['frontStatus']?.toString();
                          if (frontStatus == 'APPROVED' && statusUpper == 'APPROVED') {
                            kycDocuments[i]['status'] = 'APPROVED';
                          } else if (statusUpper == 'APPROVED') {
                            kycDocuments[i]['status'] = statusUpper;
                          } else if (frontStatus != null && frontStatus != 'APPROVED' && statusUpper != 'APPROVED') {
                            kycDocuments[i]['status'] = statusUpper;
                          }
                          
                          updated = true;
                          ConsoleLog.printSuccess("✅ Updated Aadhar Back - userdocId: $userdocId, status: $statusUpper");
                        }
                      }
                    } else {
                      // For other documents, match by doc_name or userdocId
                      String docType = doc['type']?.toString() ?? '';
                      bool nameMatch = false;
                      
                      if (docType == 'pan' && docNameLower.contains('pan')) {
                        nameMatch = true;
                      } else if (docType == 'gst' && docNameLower.contains('gst')) {
                        nameMatch = true;
                      } else if (docType == 'cheque' && (docNameLower.contains('cheque') || docNameLower.contains('cancel'))) {
                        nameMatch = true;
                      } else if (docType == 'shop' && (docNameLower.contains('shop') || docNameLower.contains('store'))) {
                        nameMatch = true;
                      } else if (docType == 'selfie' && (docNameLower.contains('selfie') || docNameLower.contains('employee') || docNameLower.contains('distributor'))) {
                        nameMatch = true;
                      }
                      
                      if (nameMatch) {
                        String? existingDocId = doc['userDocId']?.toString();
                        // Update if userdocId matches (always update status) or if not set yet
                        if (existingDocId == userdocId || (existingDocId == null || existingDocId.isEmpty || existingDocId == 'null')) {
                          if (existingDocId != userdocId) {
                            kycDocuments[i]['frontImage'] = 'uploaded';
                            kycDocuments[i]['userDocId'] = userdocId;
                          }
                          // Always update status from fetchUploadedDocs API
                          kycDocuments[i]['status'] = statusUpper;
                          updated = true;
                          ConsoleLog.printSuccess("✅ Updated ${docType} - userdocId: $userdocId, status: $statusUpper");
                        }
                      }
                    }
                    
                    if (updated) break; // Found matching document, no need to check others
                  }
                }
              }
            }
            
            // Force refresh the reactive list
            kycDocuments.refresh();
            
            // Log final state for debugging
            ConsoleLog.printColor("KYC Documents after fetchUploadedDocs:", color: "cyan");
            for (var doc in kycDocuments) {
              String? frontImage = doc['frontImage']?.toString();
              String frontImagePreview = frontImage != null && frontImage.isNotEmpty
                  ? (frontImage.length > 30 ? '${frontImage.substring(0, 30)}...' : frontImage)
                  : 'empty';
              ConsoleLog.printInfo("  - ${doc['title']}: status=${doc['status']}, frontImage=$frontImagePreview, frontUserDocId=${doc['frontUserDocId']}, backUserDocId=${doc['backUserDocId']}, userDocId=${doc['userDocId']}");
            }
            
            ConsoleLog.printSuccess("✅ Uploaded documents fetched and image URLs updated");
          }
        }
      }
    } catch (e) {
      ConsoleLog.printError('Error in fetchUploadedDocs: $e');
      // Don't show error dialog as this is a background operation
    }
  }

  // Delete Uploaded KYC Document
  Future<void> deleteUploadedKycDoc(String userdocId, String docType, {bool isBackSide = false}) async {
    try {
      // Show confirmation dialog first
      bool? shouldDelete = await Get.dialog<bool>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            width: Get.width - 50,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Color(0xFFF44336),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Delete Document?',
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Are you sure you want to delete this document? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: const Color(0xFF6B707E),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    InkWell(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        width: 120,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.albertSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B707E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Delete Button
                    InkWell(
                      onTap: () => Get.back(result: true),
                      child: Container(
                        width: 120,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.albertSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
      );

      if (shouldDelete != true) return;

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'userdoc_id': userdocId,
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_DELETE_UPLOADED_KYC_DOC,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("DELETE KYC DOC RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Document deleted successfully',
            onContinue: () {
              // Refresh KYC status and uploaded docs
              getKycStatus();
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Failed to delete document',
          );
        }
      } else {
        CustomDialog.error(
          message: 'Failed to delete document',
        );
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in deleteUploadedKycDoc: $e');
      CustomDialog.error(
        message: 'Technical issue. Please try again.',
      );
    }
  }

  // Upload Document
  Future<void> uploadDocument(String docType, {bool isBackSide = false}) async {
    try {
      // Show source selection dialog
      final source = await _showImageSourceDialog();
      if (source == null) return;

      File? imageFile;

      if (source == ImageSource.camera) {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
      } else if (source == ImageSource.gallery) {
        // Use image_picker to directly open mobile gallery
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
      }

      if (imageFile == null) return;

      CustomLoading.showLoading();

      // Load auth credentials
      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'doc_type': docType,
        'is_back_side': isBackSide ? 'true' : 'false',
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.postMultipartRequest(
        WebApiConstant.API_URL_UPLOAD_KYC_DOCUMENT,
        requestBody,
        imageFile,
        'document',
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("UPLOAD KYC DOC RESP: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS') {
          CustomDialog.success(
            message: result['Resp_desc'] ?? 'Document uploaded successfully',
            onContinue: () {
              Get.back();
              getKycStatus(); // Refresh KYC status
            },
          );
        } else {
          CustomDialog.error(
            message: result['Resp_desc'] ?? 'Unable to upload document',
          );
        }
      } else {
        CustomDialog.error(
          message: 'Failed to upload document',
        );
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in uploadDocument: $e');
      CustomDialog.error(
        message: 'Unable to upload document. Please try again.',
      );
    }
  }

  // Show Image Source Dialog
  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(25),
        child: Container(
          width: Get.width - 50,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Choose Source',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(height: 24),
              
              // Camera Option
              InkWell(
                onTap: () => Get.back(result: ImageSource.camera),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0054D3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF0054D3),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Camera',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF6B707E),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Gallery Option
              InkWell(
                onTap: () => Get.back(result: ImageSource.gallery),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0054D3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF0054D3),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Gallery',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF6B707E),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Cancel Button
              InkWell(
                onTap: () => Get.back(result: null),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.albertSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B707E),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Get Status Color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      case 'process':
      case 'processing':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Get Status Text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'process':
      case 'processing':
        return 'Processing';
      case 'pending':
        return 'Pending';
      default:
        return 'Pending';
    }
  }

  // View Uploaded Document
  Future<void> viewDocument(String userdocId) async {
    try {
      if (userdocId.isEmpty || userdocId == 'null') {
        CustomDialog.error(message: 'Document ID not found');
        return;
      }

      // Generate view URL
      final viewUrl = 'https://uat.payrupya.in/viewKycDoc/$userdocId';
      
      ConsoleLog.printInfo("Opening document view URL: $viewUrl");
      
      final Uri url = Uri.parse(viewUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        CustomDialog.error(message: 'Could not open document. Please try again.');
      }
    } catch (e) {
      ConsoleLog.printError('Error in viewDocument: $e');
      CustomDialog.error(message: 'Unable to open document. Please try again.');
    }
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }
}