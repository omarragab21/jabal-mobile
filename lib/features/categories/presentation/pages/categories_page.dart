import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../home/domain/entities/product_category.dart';
import '../../../home/presentation/widgets/home_search_field.dart';
import '../cubit/sections_cubit.dart';
import '../widgets/section_tile.dart';

/// The sections tab: a search field and one photo card per section. Tapping
/// a section opens its page; typing in the search field swaps the cards for
/// the matching products.
class SectionsPage extends StatefulWidget {
  const SectionsPage({
    super.key,
    required this.onOpenSection,
    this.onOpenSearch,
    this.onBack,
  });

  final ValueChanged<ProductCategory> onOpenSection;

  /// The search field was tapped: open the search screen.
  final VoidCallback? onOpenSearch;

  /// The arrow at the start of the header.
  final VoidCallback? onBack;

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<SectionsCubit>().load(code);
    }
  }

  String _t(String key) => 'sections.$key'.tr(context: context);

  Widget _message(String text, {String? actionLabel, VoidCallback? onAction}) =>
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _loader() =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // white from the top of the screen, status bar included
          ColoredBox(
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppPageHeader(
                    title: 'nav.categories'.tr(context: context),
                    onBack: widget.onBack,
                    showBack: widget.onBack != null,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 1.h, 16.w, 8.h),
                    child: HomeSearchField(
                      readOnly: true,
                      onTap: widget.onOpenSearch,
                      hint: 'home.search_hint'.tr(context: context),
                      clearLabel: 'home.clear_search'.tr(context: context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _sections()),
        ],
      ),
    );
  }

  Widget _sections() => BlocBuilder<SectionsCubit, SectionsState>(
    builder: (context, state) => switch (state.status) {
      SectionsStatus.loading => _loader(),
      SectionsStatus.failed => _message(
        _t('error'),
        actionLabel: 'home.retry'.tr(context: context),
        onAction: () =>
            context.read<SectionsCubit>().load(_languageCode ?? 'ar'),
      ),
      SectionsStatus.ready when state.sections.isEmpty => _message(_t('empty')),
      SectionsStatus.ready => SectionsGrid(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        tiles: [
          for (final section in state.sections)
            SectionTile(
              key: ValueKey('section-${section.id}'),
              name: section.name,
              imageUrl: section.imageUrl,
              onTap: () => widget.onOpenSection(section),
            ),
        ],
      ),
    },
  );
}
