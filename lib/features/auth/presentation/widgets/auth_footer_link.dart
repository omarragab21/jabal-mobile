import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "ليس لديك حساب؟ إنشاء حساب" — plain question + green tappable action.
class AuthFooterLink extends StatefulWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  State<AuthFooterLink> createState() => _AuthFooterLinkState();
}

class _AuthFooterLinkState extends State<AuthFooterLink> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = widget.onTap;

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.textXsRegular.copyWith(
      color: AppColors.textDefault,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${widget.question} '),
          TextSpan(
            text: widget.action,
            style: base.copyWith(color: AppColors.primary),
            recognizer: _tap,
          ),
        ],
      ),
    );
  }
}
