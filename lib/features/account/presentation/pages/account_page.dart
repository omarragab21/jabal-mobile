import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_menu_row.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';

/// What each row of the account menu does. Every entry opens a page over the
/// tabs, so the account page itself stays free of any feature's details.
class AccountActions {
  const AccountActions({
    required this.openPersonalInfo,
    required this.openAddresses,
    required this.openPaymentCards,
    required this.openSupport,
    required this.openPolicies,
    required this.openCommunity,
    required this.openAbout,
    required this.shareApp,
    required this.readVersion,
    required this.openSettings,
  });

  final Future<void> Function(BuildContext context) openPersonalInfo;
  final Future<void> Function(BuildContext context) openAddresses;
  final Future<void> Function(BuildContext context) openPaymentCards;
  final Future<void> Function(BuildContext context) openSupport;
  final Future<void> Function(BuildContext context) openPolicies;
  final Future<void> Function(BuildContext context) openCommunity;
  final Future<void> Function(BuildContext context) openAbout;
  final Future<void> Function(BuildContext context) shareApp;

  /// The app version shown under the logout button.
  final Future<String> Function() readVersion;
  final Future<void> Function(BuildContext context) openSettings;
}

/// The account tab: the menu.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.actions});

  final AccountActions actions;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'account.$key'.tr(context: context);
    final cubit = context.read<AccountCubit>();

    /// Opens a page, then refreshes the name shown above (it may have changed).
    Future<void> open(Future<void> Function(BuildContext) action) async {
      await action(context);
      await cubit.load();
    }

    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (p, c) => !p.loggedOut && c.loggedOut,
      listener: (context, _) => Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
      child: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) => ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppPageHeader(
                  title: 'nav.account'.tr(context: context),
                  showBack: false,
                  trailing: Semantics(
                    button: true,
                    label: 'settings.title'.tr(context: context),
                    child: InkResponse(
                      key: const ValueKey('open-settings'),
                      onTap: () => open(actions.openSettings),
                      radius: 24.r,
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: SvgPicture.asset(
                          'assets/icons/account/settings.svg',
                          width: 24.r,
                          height: 24.r,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textDefault,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 24.h),
                    children: [
                      AppMenuRow(
                        key: const ValueKey('menu-personal-info'),
                        iconAsset: 'assets/icons/account/profile.svg',
                        label: t('personal_info'),
                        onTap: () => open(actions.openPersonalInfo),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-addresses'),
                        iconAsset: 'assets/icons/account/addresses.svg',
                        label: t('addresses'),
                        onTap: () => open(actions.openAddresses),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-cards'),
                        iconAsset: 'assets/icons/account/cards.svg',
                        label: t('payment_cards'),
                        onTap: () => open(actions.openPaymentCards),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-support'),
                        iconAsset: 'assets/icons/account/support.svg',
                        label: t('support'),
                        onTap: () => open(actions.openSupport),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-policies'),
                        iconAsset: 'assets/icons/account/policy.svg',
                        label: t('policies'),
                        onTap: () => open(actions.openPolicies),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-community'),
                        iconAsset: 'assets/icons/account/community.svg',
                        label: t('community'),
                        onTap: () => open(actions.openCommunity),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-about'),
                        leading: const Icon(Icons.info_outline, size: 24),
                        label: t('about'),
                        onTap: () => open(actions.openAbout),
                      ),
                      AppMenuRow(
                        key: const ValueKey('menu-share'),
                        iconAsset: 'assets/icons/account/share.svg',
                        label: t('share'),
                        showDivider: false,
                        onTap: () => actions.shareApp(context),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
                        child: SizedBox(
                          height: 44.h,
                          child: OutlinedButton(
                            key: const ValueKey('logout'),
                            onPressed: cubit.logout,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              textStyle: AppTextStyles.textMdRegular,
                            ),
                            child: Text(t('logout')),
                          ),
                        ),
                      ),
                      _VersionText(read: actions.readVersion),
                    ],
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

/// "الإصدار 1.0.0" under the logout button; empty if the version is unknown.
class _VersionText extends StatefulWidget {
  const _VersionText({required this.read});

  final Future<String> Function() read;

  @override
  State<_VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<_VersionText> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // "1.0.0 (1)": the build number is not shown.
      final version = (await widget.read()).split(' ').first;
      if (mounted) setState(() => _version = version);
    } catch (_) {
      // no version to show
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = _version;
    return Padding(
      padding: EdgeInsets.only(top: 13.h),
      child: SizedBox(
        height: 20.h,
        child: version == null
            ? null
            : Text(
                '${'legal.version'.tr(context: context)} $version',
                key: const ValueKey('app-version'),
                textAlign: TextAlign.center,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.textLabel,
                ),
              ),
      ),
    );
  }
}
