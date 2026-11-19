import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/place_suggestion.dart';
import '../cubit/map_picker_state.dart';

/// Drop-down under the search field with the places that match the text.
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.status,
    required this.suggestions,
    required this.emptyText,
    required this.errorText,
    required this.onSelected,
  });

  final SuggestionsStatus status;
  final List<PlaceSuggestion> suggestions;
  final String emptyText;
  final String errorText;
  final ValueChanged<PlaceSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (status == SuggestionsStatus.searching) {
      content = Padding(
        padding: EdgeInsets.all(16.r),
        child: Center(
          child: SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    } else if (status == SuggestionsStatus.failed || suggestions.isEmpty) {
      content = Padding(
        padding: EdgeInsets.all(16.r),
        child: Text(
          status == SuggestionsStatus.failed ? errorText : emptyText,
          textAlign: TextAlign.center,
          style: AppTextStyles.textSmRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    } else {
      content = ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.neutral200),
        itemBuilder: (_, index) => InkWell(
          key: ValueKey('suggestion-${suggestions[index].placeId}'),
          onTap: () => onSelected(suggestions[index]),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              suggestions[index].description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      constraints: BoxConstraints(maxHeight: 280.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: content,
      ),
    );
  }
}
