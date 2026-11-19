import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The texts to complete to, one per row with a hairline between: tapping one
/// searches for it.
class SearchSuggestionList extends StatelessWidget {
  const SearchSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: suggestions.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.neutral200),
      itemBuilder: (_, index) => InkWell(
        key: ValueKey('suggestion-$index'),
        onTap: () => onSelected(suggestions[index]),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              suggestions[index],
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
