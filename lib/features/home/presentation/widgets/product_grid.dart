import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Two-column list of product cards (search results and category pages):
/// 24pt between columns and 16pt between rows, as in the design.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.cards, this.padding});

  final List<Widget> cards;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final rows = (cards.length / 2).ceil();
    return ListView.separated(
      padding: padding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: rows,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (_, row) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cards[row * 2]),
          SizedBox(width: 24.w),
          Expanded(
            child: row * 2 + 1 < cards.length
                ? cards[row * 2 + 1]
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
