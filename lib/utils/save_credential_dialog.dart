import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/global_utils.dart';

/// Dialog to ask user if they want to save their login credentials
/// Shows after successful login if credentials are not already saved
class SaveCredentialDialog extends StatelessWidget {
  final String mobile;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  const SaveCredentialDialog({
    super.key,
    required this.mobile,
    required this.onSave,
    required this.onSkip,
  });

  /// Get masked mobile for display
  String get _maskedMobile {
    if (mobile.length < 10) return mobile;
    return '${mobile.substring(0, 2)}****${mobile.substring(mobile.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0054D3).withOpacity(0.1),
                    const Color(0xFF71A9FF).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.save_rounded,
                size: 36,
                color: Color(0xFF0054D3),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Save Login Details?',
              style: GoogleFonts.albertSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B1C1C),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Save credentials for $_maskedMobile for quick login next time?',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: const Color(0xFF6B707E),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Security note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFE082),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFFF9A825),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Your data is securely encrypted',
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: const Color(0xFFF9A825),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Skip Button
                Expanded(
                  child: GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Not Now',
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B707E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Save Button
                Expanded(
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: GlobalUtils.blueBtnGradientColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0054D3).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Save',
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }

  /// Show the dialog
  static Future<bool?> show(BuildContext context, String mobile) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SaveCredentialDialog(
        mobile: mobile,
        onSave: () => Navigator.of(context).pop(true),
        onSkip: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
