// QR Scanner Screen Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:payrupya/utils/global_utils.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScanned;

  const QRScannerScreen({Key? key, required this.onScanned}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController cameraController;
  bool isScanned = false;
  bool isTorchOn = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize camera controller with proper configuration
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // Toggle flash/torch
  void toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
    });
    cameraController.toggleTorch();
  }

  // ✅ Gallery picker for QR code
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      // Analyze QR code from image
      final BarcodeCapture? capture = await cameraController.analyzeImage(image.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;

        if (code != null && code.isNotEmpty) {
          isScanned = true;
          HapticFeedback.vibrate();
          widget.onScanned(code);
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(msg: "No QR code found in image");
        }
      } else {
        Fluttertoast.showToast(msg: "No QR code detected");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to scan from gallery");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Scan UPI QR Code',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Gallery Button
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.white),
            onPressed: pickImageFromGallery,
            tooltip: 'Pick from Gallery',
          ),
          // Flash Button
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: toggleTorch,
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              if (isScanned) return;

              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final code = barcode.rawValue;

                if (code != null && code.isNotEmpty) {
                  setState(() {
                    isScanned = true;
                  });

                  // Provide haptic feedback
                  HapticFeedback.vibrate();

                  // Call the callback with scanned data
                  widget.onScanned(code);

                  // Close scanner screen
                  Navigator.of(context).pop();
                  break;
                }
              }
            },
          ),

          // Overlay with scanning frame
          SizedBox(
            width: GlobalUtils.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100,),
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: 50,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Align QR code within the frame',
                        style: GoogleFonts.albertSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scanner will automatically detect UPI QR',
                        style: GoogleFonts.albertSans(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      // Gallery hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Colors.white70, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Tap gallery icon to scan from image',
                            style: GoogleFonts.albertSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}