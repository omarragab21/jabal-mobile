import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/loading_overlay.dart';

/// Common frame of every auth screen: header, scrollable [body], optional
/// [bottom] block pinned above the keyboard, and the loading overlay.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.loading = false,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final Widget body;
  final Widget? bottom;
  final bool loading;
  final VoidCallback? onBack;

  /// False on a screen nobody can go back from (login is where the app
  /// starts, so an arrow there leads nowhere).
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppPageHeader(title: title, onBack: onBack, showBack: showBack),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.w, 17.h, 16.w, 16.h),
                    child: body,
                  ),
                ),
                if (bottom != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: bottom,
                  ),
              ],
            ),
          ),
          if (loading) const Positioned.fill(child: LoadingOverlay()),
        ],
      ),
    );
  }
}
