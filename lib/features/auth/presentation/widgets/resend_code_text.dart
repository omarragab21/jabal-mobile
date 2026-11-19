import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "ما وصلك الرمز؟ إعادة الإرسال بعد 00:43" — and once the timer ends,
/// "ما وصلك الرمز؟ [إعادة الإرسال]" as a tappable green link.
class ResendCodeText extends StatelessWidget {
  const ResendCodeText({
    super.key,
    required this.prompt,
    required this.waitLabel,
    required this.resendLabel,
    required this.secondsLeft,
    required this.onResend,
  });

  /// "ما وصلك الرمز؟"
  final String prompt;

  /// "إعادة الإرسال بعد" (followed by the countdown)
  final String waitLabel;

  /// "إعادة الإرسال"
  final String resendLabel;
  final int secondsLeft;
  final VoidCallback onResend;

  static String format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.textMdRegular.copyWith(
      color: AppColors.textDisplay,
    );
    final green = base.copyWith(color: AppColors.primary);
    final waiting = secondsLeft > 0;

    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '$prompt '),
          if (waiting) ...[
            TextSpan(text: '$waitLabel '),
            TextSpan(text: format(secondsLeft), style: green),
          ] else
            TextSpan(
              text: resendLabel,
              style: green,
              recognizer: TapGestureRecognizer()..onTap = onResend,
            ),
        ],
      ),
    );
  }
}
