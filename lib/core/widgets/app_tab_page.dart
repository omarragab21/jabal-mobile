import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_page_header.dart';

/// Frame of a bottom-bar tab root: white page with the centered [title]
/// header (no back arrow) and the tab's [body] below it.
class AppTabPage extends StatelessWidget {
  const AppTabPage({super.key, required this.title, this.body});

  final String title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(title: title, showBack: false),
            Expanded(child: body ?? const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
