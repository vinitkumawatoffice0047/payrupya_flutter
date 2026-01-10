import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/kyc_controller.dart';
import '../utils/global_utils.dart';

class KycDocumentsScreen extends StatelessWidget {
  const KycDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KycController controller = Get.put(KycController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(),
            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.kycDocuments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0054D3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading KYC documents...',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: const Color(0xFF6B707E),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.kycDocuments.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.getKycStatus,
                    color: const Color(0xFF0054D3),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No KYC documents found',
                                style: GoogleFonts.albertSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B707E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pull down to refresh',
                                style: GoogleFonts.albertSans(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.getKycStatus,
                  color: const Color(0xFF0054D3),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.kycDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = controller.kycDocuments[index];
                      return _buildDocumentCard(
                        doc,
                        controller,
                      );
                    },
                  ),
                );
              }),
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
            onTap: () => Get.back(),
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
            'KYC Documents',
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

  Widget _buildDocumentCard(
    Map<String, dynamic> doc,
    KycController controller,
  ) {
    // Check if documents are uploaded based on userdocId (not just image path)
    final frontImagePath = doc['frontImage']?.toString() ?? '';
    final backImagePath = doc['backImage']?.toString() ?? '';
    final frontUserDocId = doc['frontUserDocId']?.toString();
    final backUserDocId = doc['backUserDocId']?.toString();
    final userDocId = doc['userDocId']?.toString();
    
    // Document is uploaded if userdocId exists
    final isFrontUploaded = (frontUserDocId != null && frontUserDocId.isNotEmpty && frontUserDocId != 'null') ||
                            (userDocId != null && userDocId.isNotEmpty && userDocId != 'null' && doc['type'] != 'aadhaar');
    final isBackUploaded = (backUserDocId != null && backUserDocId.isNotEmpty && backUserDocId != 'null');
    
    // Has actual image URL (not just 'uploaded' placeholder)
    final hasBackImage = isBackUploaded && backImagePath.isNotEmpty && backImagePath != 'uploaded';
    final hasFrontImage = isFrontUploaded && frontImagePath.isNotEmpty && frontImagePath != 'uploaded';
    
    // Show uploaded status even if no image URL yet
    final showFrontUploaded = isFrontUploaded;
    final showBackUploaded = isBackUploaded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0054D3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentIcon(doc['type']),
                    color: const Color(0xFF0054D3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['title'] ?? '',
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B1C1C),
                        ),
                      ),
                      if (showFrontUploaded || showBackUploaded || hasFrontImage || hasBackImage) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getDocumentSubtext(doc, showFrontUploaded, showBackUploaded),
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: const Color(0xFF6B707E),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(
                  doc['status'] ?? 'pending',
                  controller,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Document Images/Upload Buttons
            if (doc['type'] == 'aadhaar') ...[
              // Aadhar has front and back
              Row(
                children: [
                  Expanded(
                    child: _buildUploadButton(
                      'Front Side',
                      showFrontUploaded || hasFrontImage,
                      () => controller.uploadDocument(doc['type'], isBackSide: false),
                      imagePath: frontImagePath,
                      userdocId: frontUserDocId,
                      docType: doc['type'],
                      isBackSide: false,
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildUploadButton(
                      'Back Side',
                      showBackUploaded || hasBackImage,
                      () => controller.uploadDocument(doc['type'], isBackSide: true),
                      imagePath: backImagePath,
                      userdocId: backUserDocId,
                      docType: doc['type'],
                      isBackSide: true,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Other documents have only one image - full width
              SizedBox(
                width: double.infinity,
                child: _buildUploadButton(
                  'Upload Document',
                  showFrontUploaded || hasFrontImage,
                  () => controller.uploadDocument(doc['type']),
                  imagePath: frontImagePath,
                  userdocId: userDocId ?? frontUserDocId,
                  docType: doc['type'],
                  controller: controller,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, KycController controller) {
    final statusText = controller.getStatusText(status);
    final statusColor = controller.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.albertSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(
    String label,
    bool hasImage,
    VoidCallback onTap, {
    String? imagePath,
    String? userdocId,
    String? docType,
    bool isBackSide = false,
    required KycController controller,
  }) {
    // Check if document is uploaded but no image URL available
    final isUploadedNoUrl = imagePath == 'uploaded' || 
        (hasImage && imagePath != null && imagePath.isNotEmpty && imagePath == 'uploaded');
    
    // Check if document has userdocId (is uploaded)
    final isUploaded = userdocId != null && userdocId.isNotEmpty && userdocId != 'null';
    
    // If image URL exists and is not 'uploaded', show the image
    if (hasImage && imagePath != null && imagePath.isNotEmpty && imagePath != 'uploaded') {
      return GestureDetector(
        onTap: () => _showImagePreview(imagePath),
        child: Container(
          height: 90,
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0054D3),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: GoogleFonts.albertSans(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gradient overlay for better visibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                // Action buttons row
                Positioned(
                  top: 5,
                  right: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View button (if uploaded)
                      if (userdocId != null && userdocId.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            controller.viewDocument(userdocId);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: Color(0xFF0054D3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Edit button (to re-upload)
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Color(0xFF0054D3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Delete button
                        GestureDetector(
                          onTap: () {
                            controller.deleteUploadedKycDoc(
                              userdocId,
                              docType ?? '',
                              isBackSide: isBackSide,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: Color(0xFFF44336),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Upload button (if not uploaded)
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 14,
                              color: Color(0xFF0054D3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Label
                Positioned(
                  bottom: 5,
                  left: 8,
                  right: 50,
                  child: Text(
                    label,
                    style: GoogleFonts.albertSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If document is uploaded but no image URL available, show uploaded status
    if (isUploadedNoUrl || isUploaded) {
      return Container(
        height: 90,
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Positioned.fill(
              child: InkWell(
                onTap: userdocId != null && userdocId.isNotEmpty
                    ? () => controller.viewDocument(userdocId)
                    : onTap,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.albertSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Uploaded',
                      style: GoogleFonts.albertSans(
                        fontSize: 8,
                        color: const Color(0xFF6B707E),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons (if uploaded)
            if (userdocId != null && userdocId.isNotEmpty)
              Positioned(
                top: 35,
                right: 5,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFF0054D3),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    controller.deleteUploadedKycDoc(
                      userdocId ?? '',
                      docType ?? '',
                      isBackSide: isBackSide,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 14,
                      color: Color(0xFFF44336),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Empty upload button
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 90,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0054D3).withOpacity(0.25),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0054D3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 20,
                color: Color(0xFF0054D3),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.albertSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0054D3),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                'Tap to upload',
                style: GoogleFonts.albertSans(
                  fontSize: 8,
                  color: const Color(0xFF6B707E),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0054D3),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: const Color(0xFFF5F5F5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'aadhaar':
        return Icons.badge_outlined;
      case 'pan':
        return Icons.credit_card;
      case 'gst':
        return Icons.description;
      case 'cheque':
        return Icons.account_balance;
      case 'shop':
        return Icons.storefront;
      case 'selfie':
        return Icons.face;
      default:
        return Icons.insert_drive_file;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'process':
      case 'processing':
        return Icons.hourglass_empty;
      default:
        return Icons.upload;
    }
  }

  String _getDocumentSubtext(Map<String, dynamic> doc, bool showFrontUploaded, bool showBackUploaded) {
    final frontImagePath = doc['frontImage']?.toString() ?? '';
    final backImagePath = doc['backImage']?.toString() ?? '';
    final hasFront = frontImagePath.isNotEmpty && frontImagePath != 'uploaded';
    final hasBack = backImagePath.isNotEmpty && backImagePath != 'uploaded';

    if (doc['type'] == 'aadhaar') {
      if ((showFrontUploaded || hasFront) && (showBackUploaded || hasBack)) {
        return 'Front & Back uploaded';
      } else if (showFrontUploaded || hasFront) {
        return 'Front uploaded';
      } else if (showBackUploaded || hasBack) {
        return 'Back uploaded';
      }
    } else if (showFrontUploaded || hasFront) {
      return 'Document uploaded';
    }
    return 'Not uploaded';
  }
}
