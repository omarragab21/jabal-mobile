import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_page_header.dart';
import 'loading_overlay.dart';

/// Frame of a page pushed over the tabs: white, with the centred [title]
/// header (back arrow at the start edge) and [body] below it.
class AppSubPage extends StatelessWidget {
  const AppSubPage({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.onBack,
    this.backgroundColor = AppColors.white,
    this.loading = false,
    this.loadingLabel,
    this.bottom,
  });

  final String title;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onBack;
  final Color backgroundColor;

  /// Dims the page and shows a spinner (saving, verifying).
  final bool loading;

  /// Text under the spinner while [loading] ("verifying your card").
  final String? loadingLabel;

  /// Pinned under the body (a save button), above the keyboard.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppPageHeader(title: title, onBack: onBack, trailing: trailing),
                Expanded(child: body),
                if (bottom != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: bottom,
                  ),
              ],
            ),
          ),
          if (loading)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0x66161616),
                child: Center(
                  child: loadingLabel == null
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppSpinner(),
                            SizedBox(height: 16.h),
                            Text(
                              loadingLabel!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.textLgBold.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
