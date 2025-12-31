import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================
/// BIOMETRIC SCAN DIALOG
/// ============================================
/// Shows animated fingerprint scanning UI
/// Used during 2FA, eKYC, and transaction processes
/// ============================================

class BiometricScanDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? deviceName;
  final bool isScanning;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  
  const BiometricScanDialog({
    Key? key,
    this.title = 'Scanning Fingerprint',
    this.subtitle,
    this.deviceName,
    this.isScanning = true,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
  }) : super(key: key);

  /// Show the dialog
  static Future<T?> show<T>(
    BuildContext context, {
    String title = 'Scanning Fingerprint',
    String? subtitle,
    String? deviceName,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => BiometricScanDialog(
        title: title,
        subtitle: subtitle,
        deviceName: deviceName,
      ),
    );
  }

  /// Show with controller for updates
  static void showWithController(
    BuildContext context, {
    required RxBool isScanning,
    required RxBool isSuccess,
    required RxBool isError,
    required RxString errorMessage,
    String title = 'Scanning Fingerprint',
    String? subtitle,
    String? deviceName,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Obx(() => BiometricScanDialog(
        title: title,
        subtitle: subtitle,
        deviceName: deviceName,
        isScanning: isScanning.value,
        isSuccess: isSuccess.value,
        isError: isError.value,
        errorMessage: errorMessage.value,
        onCancel: onCancel,
        onRetry: onRetry,
      )),
    );
  }

  @override
  State<BiometricScanDialog> createState() => _BiometricScanDialogState();
}

class _BiometricScanDialogState extends State<BiometricScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.isScanning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BiometricScanDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.title,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B1C1C),
              ),
            ),
            
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Fingerprint Icon with Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isScanning ? _pulseAnimation.value : 1.0,
                  child: _buildFingerprintIcon(),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Status Text
            _buildStatusText(),
            
            // Device Name
            if (widget.deviceName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.usb,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.deviceName!,
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerprintIcon() {
    Color iconColor;
    Color bgColor;
    Color borderColor;
    IconData icon;
    
    if (widget.isSuccess) {
      iconColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (widget.isError) {
      iconColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
      icon = Icons.error_outline;
    } else {
      iconColor = const Color(0xFF2E5BFF);
      bgColor = const Color(0xFF2E5BFF).withOpacity(0.1);
      borderColor = const Color(0xFF2E5BFF);
      icon = Icons.fingerprint;
    }
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: widget.isScanning
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 60,
        color: iconColor,
      ),
    );
  }

  Widget _buildStatusText() {
    String text;
    Color color;
    
    if (widget.isSuccess) {
      text = 'Fingerprint captured successfully!';
      color = Colors.green;
    } else if (widget.isError) {
      text = widget.errorMessage ?? 'Fingerprint capture failed';
      color = Colors.red;
    } else {
      text = 'Place your finger on the device';
      color = Colors.grey[600]!;
    }
    
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: color,
        fontWeight: widget.isSuccess || widget.isError
            ? FontWeight.w500
            : FontWeight.normal,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.isSuccess) {
      // Auto close after success
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      });
      return const SizedBox.shrink();
    }
    
    if (widget.isError) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.onCancel != null)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  widget.onCancel?.call();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
          if (widget.onCancel != null && widget.onRetry != null)
            const SizedBox(width: 12),
          if (widget.onRetry != null)
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5BFF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    
    // Scanning state - show cancel button
    if (widget.onCancel != null) {
      return TextButton(
        onPressed: () {
          Navigator.pop(context, false);
          widget.onCancel?.call();
        },
        child: Text(
          'Cancel',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// ============================================
/// BIOMETRIC INSTRUCTIONS WIDGET
/// ============================================
/// Shows instructions for fingerprint scanning
/// ============================================

class BiometricInstructionsCard extends StatelessWidget {
  final String? deviceName;
  final VoidCallback? onStartScan;
  final bool isEnabled;
  
  const BiometricInstructionsCard({
    Key? key,
    this.deviceName,
    this.onStartScan,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Color(0xFF2E5BFF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fingerprint Verification',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                    if (deviceName != null)
                      Text(
                        deviceName!,
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Instructions
          _buildInstruction(1, 'Connect your biometric device'),
          const SizedBox(height: 10),
          _buildInstruction(2, 'Ensure the device is powered on'),
          const SizedBox(height: 10),
          _buildInstruction(3, 'Place your finger firmly on the scanner'),
          const SizedBox(height: 10),
          _buildInstruction(4, 'Hold still until scan completes'),
          
          const SizedBox(height: 24),
          
          // Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isEnabled ? onStartScan : null,
              icon: const Icon(Icons.fingerprint, size: 22),
              label: Text(
                'Start Fingerprint Scan',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5BFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.albertSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E5BFF),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================
/// DEVICE SELECTOR WIDGET
/// ============================================
/// Dropdown for selecting biometric device
/// ============================================

class BiometricDeviceSelector extends StatelessWidget {
  final String? selectedDevice;
  final List<Map<String, String>> devices;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;
  final String? errorText;
  
  const BiometricDeviceSelector({
    Key? key,
    this.selectedDevice,
    required this.devices,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedDevice?.isEmpty == true ? null : selectedDevice,
            decoration: InputDecoration(
              labelText: 'Select Biometric Device',
              labelStyle: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.fingerprint,
                color: Colors.grey[600],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            dropdownColor: Colors.white,
            items: devices.map((device) {
              return DropdownMenuItem<String>(
                value: device['value'],
                child: Text(
                  device['name'] ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    color: device['value']!.isEmpty 
                        ? Colors.grey[400] 
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: GoogleFonts.albertSans(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
