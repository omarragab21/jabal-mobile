import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/app_links.dart';
import '../../core/platform/clipboard_writer.dart';
import '../../core/platform/link_opener.dart';
import '../../core/sharing/share_flow.dart';
import '../../core/sharing/share_link.dart';
import 'data/datasources/store_info_remote_data_source.dart';
import 'data/repositories/store_info_repository_impl.dart';
import 'domain/repositories/store_info_repository.dart';
import 'domain/usecases/support_use_cases.dart';
import 'presentation/cubit/store_info_cubit.dart';
import 'presentation/pages/support_page.dart';

/// Support, the community page, and sharing the app: everything
/// that points outside the app.
class SupportModule {
  SupportModule({
    StoreInfoRemoteDataSource? remote,
    LinkOpener? linkOpener,
    ClipboardWriter? clipboard,
  }) : _repository = StoreInfoRepositoryImpl(
         remote ?? const MockStoreInfoRemoteDataSource(),
       ),
       _opener = linkOpener ?? const UrlLauncherLinkOpener(),
       _clipboard = clipboard ?? const SystemClipboardWriter();

  final StoreInfoRepository _repository;
  final LinkOpener _opener;
  final ClipboardWriter _clipboard;

  Future<void> _push(BuildContext context, Widget page) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => StoreInfoCubit(
              getStoreInfo: GetStoreInfo(_repository),
              openLink: OpenExternalLink(_opener),
            )..load(),
            child: page,
          ),
        ),
      );

  Future<void> openSupport(BuildContext context) =>
      _push(context, const SupportPage());

  Future<void> openCommunity(BuildContext context) =>
      _push(context, const CommunityPage());

  /// "Share the app": the shared share sheet, with the app's download link.
  Future<void> shareApp(BuildContext context) => shareViaSheet(
    context,
    share: ShareLink(_opener, _clipboard),
    title: 'support.share_title'.tr(context: context),
    message: 'support.share_message'.tr(context: context),
    link: Uri.parse(AppLinks.download),
  );
}
