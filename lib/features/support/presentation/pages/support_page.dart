import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_menu_row.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/store_info.dart';
import '../cubit/store_info_cubit.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

Widget _statusBody(
  BuildContext context,
  StoreInfoState state,
  VoidCallback retry,
  Widget Function() ready,
) => switch (state.status) {
  StoreInfoStatus.loading => const Center(
    child: CircularProgressIndicator(color: AppColors.primary),
  ),
  StoreInfoStatus.failed => Center(
    child: TextButton(
      onPressed: retry,
      child: Text('home.retry'.tr(context: context)),
    ),
  ),
  StoreInfoStatus.ready => ready(),
};

Widget _empty(BuildContext context, String text) => Center(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 32.w),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.textMdRegular.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ),
);

/// "الدعم والمساعدة": WhatsApp, e-mail and phone, as far as the store set them.
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'support.$key'.tr(context: context);
    final cubit = context.read<StoreInfoCubit>();
    return BlocBuilder<StoreInfoCubit, StoreInfoState>(
      builder: (context, state) => AppSubPage(
        title: t('title'),
        body: _statusBody(context, state, cubit.load, () {
          final channels = [
            for (final channel in ContactChannel.values)
              if (state.info.has(channel)) channel,
          ];
          if (channels.isEmpty) return _empty(context, t('none'));
          return ListView(
            children: [
              for (final channel in channels)
                AppMenuRow(
                  key: ValueKey('channel-${channel.name}'),
                  iconAsset: switch (channel) {
                    ContactChannel.whatsapp =>
                      'assets/icons/account/whatsapp.svg',
                    ContactChannel.email => 'assets/icons/account/mail.svg',
                    ContactChannel.phone => 'assets/icons/account/call.svg',
                  },
                  label: t(channel.name),
                  onTap: () async {
                    final opened = await cubit.open(
                      state.info.contactUri(channel),
                    );
                    if (!opened && context.mounted) {
                      _toast(context, t('open_failed'));
                    }
                  },
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// "انضم إلى مجتمع جبل": the store's social pages.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static String assetOf(SocialNetwork network) => switch (network) {
    SocialNetwork.facebook => 'assets/icons/account/facebook.svg',
    SocialNetwork.instagram => 'assets/icons/account/instagram.svg',
    SocialNetwork.x => 'assets/icons/account/x.svg',
    _ => 'assets/icons/account/link.svg',
  };

  static String nameOf(SocialNetwork network) => switch (network) {
    SocialNetwork.facebook => 'Facebook',
    SocialNetwork.instagram => 'Instagram',
    SocialNetwork.x => 'X',
    SocialNetwork.tiktok => 'TikTok',
    SocialNetwork.snapchat => 'Snapchat',
    SocialNetwork.youtube => 'YouTube',
    SocialNetwork.linkedin => 'LinkedIn',
  };

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'support.$key'.tr(context: context);
    final cubit = context.read<StoreInfoCubit>();
    return BlocBuilder<StoreInfoCubit, StoreInfoState>(
      builder: (context, state) => AppSubPage(
        title: t('community_title'),
        body: _statusBody(context, state, cubit.load, () {
          final networks = state.info.social.keys.toList();
          if (networks.isEmpty) return _empty(context, t('none'));
          return ListView(
            children: [
              for (final network in networks)
                AppMenuRow(
                  key: ValueKey('social-${network.name}'),
                  iconAsset: assetOf(network),
                  label: nameOf(network),
                  subtitle: t('follow_us'),
                  onTap: () async {
                    final opened = await cubit.open(
                      state.info.socialUri(network),
                    );
                    if (!opened && context.mounted) {
                      _toast(context, t('open_failed'));
                    }
                  },
                ),
            ],
          );
        }),
      ),
    );
  }
}
