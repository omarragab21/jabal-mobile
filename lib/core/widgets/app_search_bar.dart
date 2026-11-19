import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_search_field.dart';

/// Top bar of the search screens (map page, product search): the search field and the back arrow at the start
/// edge (right in RTL).
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.clearLabel,
    required this.onBack,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final String clearLabel;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    return SizedBox(
      height: 58.h,
      child: Padding(
        // The home page's search padding: 16 on the sides.
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        child: Row(
          children: [
            InkResponse(
              onTap: onBack,
              radius: 24.r,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                // The asset points right (the RTL "back" direction).
                child: Transform.flip(
                  flipX: ltr,
                  child: SvgPicture.asset(
                    'assets/icons/arrow_back.svg',
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppSearchField(
                controller: controller,
                focusNode: focusNode,
                hint: hint,
                clearLabel: clearLabel,
                onChanged: onChanged,
                onClear: onClear,
                onSubmitted: onSubmitted,
                autofocus: autofocus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
