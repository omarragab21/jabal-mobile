import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Label + bordered 44pt input (design "Input field"). Border turns green on
/// focus and red when [errorText] is set. [leading] is placed at the start
/// edge inside the border (e.g. the dial-code block), [trailing] at the end.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.errorText,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textDirection,
    this.textAlign,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? errorText;
  final Widget? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// Force a direction for the typed text (e.g. LTR digits for phones).
  final TextDirection? textDirection;
  final TextAlign? textAlign;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : _focus.hasFocus
        ? AppColors.primary
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.textMdRegular.copyWith(
            color: AppColors.textDefault,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 44.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              ?widget.leading,
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  textDirection: widget.textDirection,
                  textAlign: widget.textAlign ?? TextAlign.start,
                  cursorColor: AppColors.primary,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                ),
              ),
              ?widget.trailing,
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: AppTextStyles.textXsRegular.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
