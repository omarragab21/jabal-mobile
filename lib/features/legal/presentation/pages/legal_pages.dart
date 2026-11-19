import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_menu_row.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/usecases/get_legal_document.dart';

/// "السياسات": the terms and the privacy policy.
class PoliciesPage extends StatelessWidget {
  const PoliciesPage({
    super.key,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'legal.$key'.tr(context: context);
    return AppSubPage(
      title: t('policies'),
      body: ListView(
        children: [
          AppMenuRow(
            key: const ValueKey('policy-terms'),
            iconAsset: 'assets/icons/account/policy.svg',
            label: t('terms'),
            onTap: onOpenTerms,
          ),
          AppMenuRow(
            key: const ValueKey('policy-privacy'),
            iconAsset: 'assets/icons/account/policy.svg',
            label: t('privacy'),
            onTap: onOpenPrivacy,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

/// One legal text: title, intro and numbered sections.
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({
    super.key,
    required this.type,
    required this.getDocument,
  });

  final LegalDocumentType type;
  final GetLegalDocument getDocument;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  Future<LegalDocument?>? _future;
  String? _language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _language) {
      _language = code;
      _future = widget
          .getDocument(widget.type, code)
          .then((r) => r.when(success: (d) => d, failure: (_) => null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackTitle = 'legal.${widget.type.name}'.tr(context: context);
    return FutureBuilder<LegalDocument?>(
      future: _future,
      builder: (context, snapshot) {
        final document = snapshot.data;
        return AppSubPage(
          title: document?.title ?? fallbackTitle,
          body: switch (snapshot.connectionState) {
            ConnectionState.done when document == null => Center(
              child: Text(
                'legal.error'.tr(context: context),
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ConnectionState.done => ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              children: [
                Text(
                  document!.intro,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                for (var i = 0; i < document.sections.length; i++) ...[
                  SizedBox(height: 20.h),
                  Text(
                    '${i + 1}. ${document.sections[i].heading}',
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    document.sections[i].body,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.textLabel,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          },
        );
      },
    );
  }
}

/// "عن التطبيق": the logo, the name, the version and a short description.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.version});

  /// `1.0.0 (1)`
  final String version;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'legal.$key'.tr(context: context);
    return AppSubPage(
      title: t('about'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 32.h),
        child: Column(
          children: [
            SvgPicture.asset('assets/icons/splash_logo.svg', height: 96.h),
            SizedBox(height: 16.h),
            Text(
              t('app_name'),
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${t('version')} $version',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              t('about_text'),
              textAlign: TextAlign.center,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textLabel,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
