import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/countries/country.dart';
import '../../../../core/formatters/input_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'country_flag.dart';

/// Phone input: `[ flag +962 ] [ number ]` where the grey dial-code block sits
/// at the start edge and opens the country picker.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.label,
    required this.hint,
    required this.country,
    required this.onCountryTap,
    this.controller,
    this.errorText,
    this.onChanged,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final Country country;
  final VoidCallback onCountryTap;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      textInputAction: textInputAction,
      keyboardType: TextInputType.phone,
      inputFormatters: digitsFormatters(max: 15),
      leading: _DialCodeBlock(country: country, onTap: onCountryTap),
    );
  }
}

class _DialCodeBlock extends StatelessWidget {
  const _DialCodeBlock({required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.buttonSecondary,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryFlag(isoCode: country.isoCode),
            SizedBox(width: 6.w),
            // Dial codes always read left-to-right: "+962".
            Text(
              country.dialCodeWithPlus,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
