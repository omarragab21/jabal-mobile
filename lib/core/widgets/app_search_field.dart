import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The app's search box (home page, map page): grey, magnifier at the start, a clear button at the end once
/// there is text.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    required this.hint,
    required this.clearLabel,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  /// Null for a field that only opens something (see [readOnly]).
  final TextEditingController? controller;
  final String hint;
  final String clearLabel;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// A field that only opens something when tapped (the home page's search).
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.textMdRegular.copyWith(
      color: AppColors.textDefault,
    );
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/home/search.svg',
            width: 24.r,
            height: 24.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              autofocus: autofocus,
              readOnly: readOnly,
              onTap: onTap,
              style: style,
              cursorColor: AppColors.primary,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: style.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
          if (controller == null)
            SizedBox(width: 8.w)
          else
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller!,
              builder: (_, value, _) => value.text.isEmpty
                  ? SizedBox(width: 8.w)
                  : IconButton(
                      tooltip: clearLabel,
                      onPressed: onClear,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: 40.h,
                        height: 40.h,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20.r,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
