import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/formatters/input_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum OtpStatus { idle, error, success }

/// Row of [length] 48pt boxes backed by one invisible text field, so typing,
/// deleting and pasting all work. The first box is always on the left, border color reflects [status].
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 4,
    this.status = OtpStatus.idle,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final OtpStatus status;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Clears the typed code (e.g. after a wrong attempt).
  void clear() => _controller.clear();

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final borderColor = switch (widget.status) {
      OtpStatus.idle => AppColors.border,
      OtpStatus.error => AppColors.error,
      OtpStatus.success => AppColors.success,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      // Digits always fill left -> right, in Arabic as well as English.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) SizedBox(width: 24.w),
                  _OtpBox(
                    char: i < text.length ? text[i] : '',
                    color: widget.status == OtpStatus.idle && i == text.length
                        ? AppColors.primary
                        : borderColor,
                  ),
                ],
              ],
            ),
            // Invisible field that owns the keyboard.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: digitsFormatters(max: widget.length),
                  onChanged: _onChanged,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.char, required this.color});

  final String char;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color),
      ),
      child: Text(
        char,
        style: AppTextStyles.displayXsBold.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.textDefault,
        ),
      ),
    );
  }
}
