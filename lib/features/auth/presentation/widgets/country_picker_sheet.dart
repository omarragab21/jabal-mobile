import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'country_flag.dart';

/// Bottom sheet listing every country (Jordan, Saudi Arabia, Egypt first)
/// with a search box. Names follow [languageCode].
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.emptyLabel,
    required this.languageCode,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String searchHint;
  final String emptyLabel;
  final String languageCode;
  final Country selected;
  final ValueChanged<Country> onSelected;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String searchHint,
    required String emptyLabel,
    required String languageCode,
    required Country selected,
    required ValueChanged<Country> onSelected,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => CountryPickerSheet(
      title: title,
      searchHint: searchHint,
      emptyLabel: emptyLabel,
      languageCode: languageCode,
      selected: selected,
      onSelected: (c) {
        onSelected(c);
        Navigator.of(context).pop();
      },
    ),
  );

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final countries = Countries.search(_query);
    final height = MediaQuery.sizeOf(context).height * 0.75;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Text(
              widget.title,
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.textMdRegular,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: countries.isEmpty
                  ? Center(
                      child: Text(
                        widget.emptyLabel,
                        style: AppTextStyles.textMdRegular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: countries.length,
                      itemBuilder: (_, i) {
                        final c = countries[i];
                        final isSelected = c == widget.selected;
                        return ListTile(
                          dense: true,
                          onTap: () => widget.onSelected(c),
                          leading: CountryFlag(isoCode: c.isoCode, size: 24),
                          title: Text(
                            c.name(widget.languageCode),
                            style: AppTextStyles.textMdRegular.copyWith(
                              color: AppColors.textDefault,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.dialCodeWithPlus,
                                textDirection: TextDirection.ltr,
                                style: AppTextStyles.textMdRegular.copyWith(
                                  color: AppColors.textLabel,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: 8.w),
                                const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
