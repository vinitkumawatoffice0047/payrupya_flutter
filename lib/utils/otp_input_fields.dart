/*
///HOW TO USE

final GlobalKey<OtpInputFieldsState> _otpKey = GlobalKey<OtpInputFieldsState>();

// UI me:
OtpInputFields(
key: _otpKey,
length: 6,
),

// OTP read karna:
final otp = _otpKey.currentState?.currentOtp ?? '';

// Clear + focus first:
_otpKey.currentState?.clear();
_otpKey.currentState?.focusFirst();
*/

// otp_input_fields.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Selection handles + toolbar hide karne ke liye
class EmptyTextSelectionControls extends MaterialTextSelectionControls {
  @override
  Widget buildHandle(
      BuildContext context,
      TextSelectionHandleType type,
      double textLineHeight, [
        VoidCallback? onTap,
      ]) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset selectionMidpoint,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus, [
        Offset? lastSecondaryTapDownPosition,
      ]) {
    return const SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return Offset.zero;
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }
}

/// Reusable OTP fields widget
class OtpInputFields extends StatefulWidget {
  const OtpInputFields({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
  });

  /// OTP length (default 6)
  final int length;

  /// Jab bhi OTP string change ho
  final ValueChanged<String>? onChanged;

  /// Jab saare digits fill ho jayein
  final ValueChanged<String>? onCompleted;

  @override
  OtpInputFieldsState createState() => OtpInputFieldsState();
}

class OtpInputFieldsState extends State<OtpInputFields> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  /// Current OTP string
  String get currentOtp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  /// Saare fields clear karo
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() {});
    _notifyOtpChanged();
  }

  /// Pehle field par focus lao
  void focusFirst() {
    if (_focusNodes.isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes.first);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 50,
          child: RawKeyboardListener(
            // Backspace handle karne ke liye
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_controllers[index].text.isEmpty && index > 0) {
                  // Previous field clear + focus
                  _controllers[index - 1].clear();
                  _focusNodes[index - 1].requestFocus();
                } else if (_controllers[index].text.isNotEmpty) {
                  _controllers[index].clear();
                  setState(() {});
                }
                _notifyOtpChanged();
              }
            },
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: const TextSelectionThemeData(
                  selectionColor: Colors.transparent,
                  selectionHandleColor: Colors.transparent,
                ),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                // 👇 Yahi wali line previous bug fix karti hai
                maxLengthEnforcement: MaxLengthEnforcement.none,
                showCursor: false,
                enableInteractiveSelection: false,
                selectionControls: EmptyTextSelectionControls(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _focusNodes[index].hasFocus &&
                      _controllers[index].text.isNotEmpty
                      ? const Color(0xFF0054D3) // focused + filled -> blue
                      : _controllers[index].text.isEmpty
                      ? const Color(0xff6B707E) // empty -> grey
                      : Colors.black, // filled but not focused -> black
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '-',
                  hintStyle: const TextStyle(
                    color: Color(0xff6B707E),
                    fontSize: 24,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E5BFF),
                      width: 2,
                    ),
                  ),
                ),
                onTap: () {
                  // Tap par purana digit select ho jaye (replace behaviour)
                  if (_controllers[index].text.isNotEmpty) {
                    _controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[index].text.length,
                    );
                  }
                  setState(() {});
                },
                onChanged: (value) {
                  // Agar kisi tarah 2 char aa gaye, last wali rakho
                  if (value.length > 1) {
                    _controllers[index].text =
                        value.substring(value.length - 1);
                    _controllers[index].selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: _controllers[index].text.length,
                          ),
                        );
                  }

                  // Next field ko auto focus
                  if (value.isNotEmpty) {
                    if (index < widget.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  }

                  setState(() {});
                  _notifyOtpChanged();
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  void _notifyOtpChanged() {
    final otp = currentOtp;

    if (widget.onChanged != null) {
      widget.onChanged!(otp);
    }

    final allFilled = otp.length == widget.length &&
        !_controllers.any((c) => c.text.isEmpty);

    if (allFilled && widget.onCompleted != null) {
      widget.onCompleted!(otp);
    }
  }
}
