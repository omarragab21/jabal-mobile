import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_options_sheet.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

/// "المعلومات الشخصية": one row per detail, tap a row to change it.
class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({
    super.key,
    required this.onEditName,
    required this.onEditEmail,
    required this.onEditPhone,
  });

  /// Each opens its edit page and completes when that page is closed.
  final Future<void> Function() onEditName;
  final Future<void> Function() onEditEmail;
  final Future<void> Function() onEditPhone;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'profile.$key'.tr(context: context);
    final cubit = context.read<ProfileCubit>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return AppSubPage(
          title: t('personal_info'),
          loading: state.saving,
          body: profile == null
              ? Center(
                  child: state.status == ProfileStatus.failed
                      ? TextButton(
                          onPressed: cubit.load,
                          child: Text('home.retry'.tr(context: context)),
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                )
              : ListView(
                  children: [
                    InfoRow(
                      icon: 'assets/icons/account/name.svg',
                      label: t('full_name'),
                      value: profile.name,
                      onTap: () async {
                        await onEditName();
                        await cubit.reload();
                      },
                    ),
                    InfoRow(
                      icon: 'assets/icons/account/email.svg',
                      label: t('email'),
                      value: profile.email ?? t('not_set'),
                      muted: profile.email == null,
                      ltrValue: profile.email != null,
                      onTap: () async {
                        await onEditEmail();
                        await cubit.reload();
                      },
                    ),
                    InfoRow(
                      icon: 'assets/icons/account/gender.svg',
                      label: t('gender'),
                      value: switch (profile.gender) {
                        Gender.male => t('male'),
                        Gender.female => t('female'),
                        null => t('not_set'),
                      },
                      muted: profile.gender == null,
                      onTap: () => _chooseGender(context, profile),
                    ),
                    InfoRow(
                      icon: 'assets/icons/account/phone.svg',
                      label: t('phone'),
                      value: profile.phone,
                      ltrValue: true,
                      onTap: () async {
                        await onEditPhone();
                        await cubit.reload();
                      },
                    ),
                    InfoRow(
                      icon: 'assets/icons/account/birthday.svg',
                      label: t('birth_date'),
                      value: profile.birthDate == null
                          ? t('not_set')
                          : DateFormat.yMMMMd(
                              context.locale.toLanguageTag(),
                            ).format(profile.birthDate!),
                      muted: profile.birthDate == null,
                      showDivider: false,
                      onTap: () => _chooseBirthDate(context, profile),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _chooseGender(BuildContext context, UserProfile profile) async {
    final cubit = context.read<ProfileCubit>();
    String t(String key) => 'profile.$key'.tr(context: context);
    await showOptionsSheet<void>(
      context,
      title: t('choose_gender'),
      children: [
        for (final gender in Gender.values)
          InkWell(
            key: ValueKey('gender-${gender.name}'),
            onTap: () {
              Navigator.of(context).pop();
              cubit.setGender(gender);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t(gender.name),
                      style: AppTextStyles.textMdRegular.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                  ),
                  if (profile.gender == gender)
                    const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _chooseBirthDate(
    BuildContext context,
    UserProfile profile,
  ) async {
    final cubit = context.read<ProfileCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: profile.birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: context.locale,
    );
    if (picked != null) await cubit.setBirthDate(picked);
  }
}

/// A personal-information row: icon, small label over the value, chevron.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.muted = false,
    this.ltrValue = false,
    this.showDivider = true,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  /// The value is a placeholder ("not set"), drawn grey.
  final bool muted;

  /// The value (a phone, an e-mail) reads left to right in any language.
  final bool ltrValue;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: AppColors.neutral200))
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: SvgPicture.asset(
                    icon,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textDefault,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          value,
                          textDirection: ltrValue ? TextDirection.ltr : null,
                          style: AppTextStyles.textMdRegular.copyWith(
                            color: muted
                                ? AppColors.textSecondary
                                : AppColors.textDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.flip(
                  flipX: ltr,
                  child: SvgPicture.asset(
                    'assets/icons/address/chevron.svg',
                    width: 24.r,
                    height: 24.r,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
