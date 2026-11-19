import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/localization/locale_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_menu_row.dart';
import '../../../../core/widgets/app_options_sheet.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../cubit/settings_cubit.dart';

/// "الإعدادات": notifications and the app language.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _t(BuildContext context, String key) =>
      'settings.$key'.tr(context: context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final languageName = context.locale.languageCode == 'ar'
            ? 'العربية'
            : 'English';
        return AppSubPage(
          title: _t(context, 'title'),
          body: ListView(
            children: [
              AppMenuRow(
                key: const ValueKey('setting-notifications'),
                leading: const Icon(Icons.notifications_none, size: 24),
                label: _t(context, 'notifications'),
                subtitle: _t(
                  context,
                  state.notificationsEnabled ? 'enabled' : 'disabled',
                ),
                showChevron: false,
                onTap: () =>
                    _toggleNotifications(context, !state.notificationsEnabled),
                trailing: Switch(
                  value: state.notificationsEnabled,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) => _toggleNotifications(context, value),
                ),
              ),
              AppMenuRow(
                key: const ValueKey('setting-language'),
                leading: const Icon(Icons.language, size: 24),
                label: _t(context, 'language'),
                subtitle: languageName,
                showDivider: false,
                onTap: () => _chooseLanguage(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleNotifications(BuildContext context, bool value) {
    context.read<SettingsCubit>().setNotifications(value);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _t(context, value ? 'notifications_on' : 'notifications_off'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final service = context.read<LocaleService>();
    final current = context.locale;
    final applyLabel = _t(context, 'apply');
    final picked = await showOptionsSheet<Locale>(
      context,
      title: _t(context, 'language_title'),
      children: [_LanguageChoice(initial: current, applyLabel: applyLabel)],
    );
    if (picked == null || picked == current || !context.mounted) return;
    await context.setLocale(picked);
    await service.save(picked);
  }
}

/// Pick Arabic or English inside the bottom sheet, then Apply.
class _LanguageChoice extends StatefulWidget {
  const _LanguageChoice({required this.initial, required this.applyLabel});

  final Locale initial;
  final String applyLabel;

  @override
  State<_LanguageChoice> createState() => _LanguageChoiceState();
}

class _LanguageChoiceState extends State<_LanguageChoice> {
  late Locale _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final locale in AppLocalization.supported)
          InkWell(
            key: ValueKey('language-${locale.languageCode}'),
            onTap: () => setState(() => _selected = locale),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      locale.languageCode == 'ar' ? 'العربية' : 'English',
                      style: AppTextStyles.textMdRegular.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                  ),
                  Icon(
                    _selected == locale
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _selected == locale
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 12.h),
        AppButton(
          label: widget.applyLabel,
          height: 40,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
