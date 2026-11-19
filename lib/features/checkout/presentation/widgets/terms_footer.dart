import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "By continuing you agree to the terms and privacy policy", with the two
/// links in green.
class TermsFooter extends StatefulWidget {
  const TermsFooter({
    super.key,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  /// Each link opens its own document.
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  State<TermsFooter> createState() => _TermsFooterState();
}

class _TermsFooterState extends State<TermsFooter> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = widget.onOpenTerms;
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = widget.onOpenPrivacy;

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'checkout.$key'.tr(context: context);
    final base = AppTextStyles.textSmRegular.copyWith(
      color: AppColors.textDefault,
    );
    final link = base.copyWith(color: AppColors.primary);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${t('terms_prefix')} '),
          TextSpan(text: t('terms'), style: link, recognizer: _terms),
          TextSpan(text: ' ${t('and')} '),
          TextSpan(text: t('privacy'), style: link, recognizer: _privacy),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
