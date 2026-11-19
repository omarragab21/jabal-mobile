import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/widgets.dart';

import '../widgets/app_toast.dart';
import 'share_link.dart';
import 'share_sheet.dart';
import 'share_target.dart';

/// Shows [outcome]'s feedback: a toast when the link was copied or the target
/// app could not take it (nothing when another app took it).
void showShareFeedback(BuildContext context, ShareOutcome outcome) {
  switch (outcome) {
    case ShareOutcome.opened:
      break;
    case ShareOutcome.copied:
      showAppToast(context, 'share.link_copied'.tr(context: context));
    case ShareOutcome.failed:
      showAppToast(context, 'share.failed'.tr(context: context), error: true);
  }
}

/// The whole share flow for pages that have no view model of their own: the
/// sheet, sending to the picked target, and the feedback.
Future<void> shareViaSheet(
  BuildContext context, {
  required ShareLink share,
  required String title,
  required String message,
  required Uri link,
}) async {
  final target = await showShareSheet(context, title: title);
  if (target == null || !context.mounted) return;
  final outcome = await share(target, message: message, link: link);
  if (context.mounted) showShareFeedback(context, outcome);
}
