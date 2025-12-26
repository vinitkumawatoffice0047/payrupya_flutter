import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AEPS Loading Dialog
class AepsLoadingDialog extends StatelessWidget {
  final String? message;

  const AepsLoadingDialog({super.key, this.message});

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AepsLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF2E5BFF),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fingerprint Scanning Widget with Animation
class FingerprintScanWidget extends StatefulWidget {
  final bool isScanning;
  final bool isSuccess;
  final VoidCallback? onScan;
  final String? deviceName;

  const FingerprintScanWidget({
    super.key,
    this.isScanning = false,
    this.isSuccess = false,
    this.onScan,
    this.deviceName,
  });

  @override
  State<FingerprintScanWidget> createState() => _FingerprintScanWidgetState();
}

class _FingerprintScanWidgetState extends State<FingerprintScanWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FingerprintScanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fingerprint Icon with animation
        GestureDetector(
          onTap: widget.isScanning ? null : widget.onScan,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isScanning ? _animation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: widget.isSuccess
                        ? Colors.green[50]
                        : widget.isScanning
                            ? Colors.blue[50]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: widget.isSuccess
                          ? Colors.green
                          : widget.isScanning
                              ? const Color(0xFF2E5BFF)
                              : Colors.grey[300]!,
                      width: 3,
                    ),
                    boxShadow: widget.isScanning
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2E5BFF).withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.isSuccess ? Icons.check_circle : Icons.fingerprint,
                    size: 64,
                    color: widget.isSuccess
                        ? Colors.green
                        : widget.isScanning
                            ? const Color(0xFF2E5BFF)
                            : Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Status text
        Text(
          widget.isSuccess
              ? 'Fingerprint verified!'
              : widget.isScanning
                  ? 'Scanning fingerprint...'
                  : 'Place your finger on the device',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: widget.isSuccess
                ? Colors.green[700]
                : widget.isScanning
                    ? const Color(0xFF2E5BFF)
                    : Colors.grey[600],
            fontWeight: widget.isScanning || widget.isSuccess
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),

        // Device name
        if (widget.deviceName != null && widget.deviceName!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Device: ${widget.deviceName}',
            style: GoogleFonts.albertSans(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green[50]!;
      case 'pending':
        return Colors.orange[50]!;
      case 'failed':
      case 'failure':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green[700]!;
      case 'pending':
        return Colors.orange[700]!;
      case 'failed':
      case 'failure':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: GoogleFonts.albertSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: _textColor,
        ),
      ),
    );
  }
}

/// Info Card Widget
class AepsInfoCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const AepsInfoCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.blue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cardColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: cardColor.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Transaction Card Widget
class TransactionCard extends StatelessWidget {
  final String title;
  final String date;
  final String? amount;
  final String status;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.date,
    this.amount,
    required this.status,
    this.onTap,
  });

  bool get _isSuccess => status.toLowerCase() == 'success';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isSuccess ? Icons.check_circle : Icons.error,
                color: _isSuccess ? Colors.green : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (amount != null && amount != '0')
                  Text(
                    '₹$amount',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                const SizedBox(height: 2),
                StatusBadge(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Service Selection Card
class ServiceCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E5BFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E5BFF) : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E5BFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF2E5BFF),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bank Selection Tile
class BankTile extends StatelessWidget {
  final String name;
  final String iin;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const BankTile({
    super.key,
    required this.name,
    required this.iin,
    required this.isFavorite,
    required this.isSelected,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      leading: CircleAvatar(
        backgroundColor: isSelected ? const Color(0xFF2E5BFF) : Colors.blue[50],
        child: Text(
          name.isNotEmpty ? name[0] : 'B',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.albertSans(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        iin,
        style: GoogleFonts.albertSans(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: onFavoriteToggle != null
          ? IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            )
          : isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFF2E5BFF))
              : null,
    );
  }
}

/// Confirmation Row Widget
class ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const ConfirmationRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? Colors.grey[900] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget
class AepsEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AepsEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.albertSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success Dialog
class AepsSuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onContinue;
  final String continueLabel;

  const AepsSuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.onContinue,
    this.continueLabel = 'Continue',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onContinue,
    String continueLabel = 'Continue',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AepsSuccessDialog(
        title: title,
        message: message,
        onContinue: onContinue,
        continueLabel: continueLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onContinue?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5BFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  continueLabel,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error Dialog
class AepsErrorDialog extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const AepsErrorDialog({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AepsErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                if (onCancel != null && onRetry != null)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetry?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5BFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      onRetry != null ? 'Retry' : 'OK',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}

/// Primary Button
class AepsPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AepsPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5BFF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}

/// Secondary Button
class AepsSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AepsSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2E5BFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF2E5BFF),
                  strokeWidth: 2,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}
