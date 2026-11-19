import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/app_text_field.dart';

/// Password input with the show/hide eye at the end edge.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      inputFormatters: [LengthLimitingTextInputFormatter(64)],
      keyboardType: TextInputType.visiblePassword,
      trailing: InkResponse(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: SvgPicture.asset(
            _obscure ? 'assets/icons/eye_off.svg' : 'assets/icons/eye.svg',
            width: 24.w,
            height: 24.h,
          ),
        ),
      ),
    );
  }
}
