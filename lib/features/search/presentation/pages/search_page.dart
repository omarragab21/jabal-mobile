import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../home/domain/entities/product.dart';
import '../../../home/presentation/widgets/product_grid.dart';
import '../../../home/presentation/widgets/product_tile.dart';
import '../cubit/search_cubit.dart';
import '../widgets/search_no_results_view.dart';
import '../widgets/search_suggestion_list.dart';

/// The search screen: the field on top (focused as it opens), then what the
/// phase calls for: nothing, the suggestions, the products found, or the
/// "no results" view.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.onOpenProduct});

  /// A product card was tapped.
  final ProductOpener? onOpenProduct;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _field = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<SearchCubit>().setLanguage(context.locale.languageCode);
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _t(String key) => 'search.$key'.tr(context: context);

  /// Puts [text] in the field and searches for it.
  void _search(String text) {
    _field.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _focus.unfocus();
    context.read<SearchCubit>().submit(text);
  }

  void _clear() {
    _field.clear();
    context.read<SearchCubit>().queryChanged('');
    _focus.requestFocus();
  }

  Future<void> _askPharmacist() async {
    final opened = await context.read<SearchCubit>().askPharmacist(
      'home.ask_pharmacist_message'.tr(context: context),
    );
    if (!opened && mounted) {
      showAppToast(
        context,
        'home.whatsapp_failed'.tr(context: context),
        error: true,
      );
    }
  }

  Widget _message(String text, {String? actionLabel, VoidCallback? onAction}) =>
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (actionLabel != null)
                TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      );

  Widget _body(SearchState state, SearchCubit cubit) {
    switch (state.phase) {
      case SearchPhase.idle:
        return const SizedBox.shrink();
      case SearchPhase.suggesting:
        return SearchSuggestionList(
          suggestions: state.suggestions,
          onSelected: _search,
        );
      case SearchPhase.searching:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case SearchPhase.failed:
        return _message(
          _t('error'),
          actionLabel: 'home.retry'.tr(context: context),
          onAction: cubit.retry,
        );
      case SearchPhase.results:
        if (state.hasNoResults) {
          return SearchNoResultsView(onAskPharmacist: _askPharmacist);
        }
        return ProductGrid(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          cards: [for (final product in state.results) _card(product, cubit)],
        );
    }
  }

  Widget _card(Product product, SearchCubit cubit) => ProductTile(
    key: ValueKey('product-${product.id}'),
    product: product,
    onTap: () => widget.onOpenProduct?.call(context, product),
    onAddToCart: () async {
      await cubit.addToCart(product);
      if (mounted) showAddedToCart(context, product);
    },
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundBody,
      body: SafeArea(
        child: Column(
          children: [
            ColoredBox(
              color: AppColors.white,
              child: AppSearchBar(
                controller: _field,
                focusNode: _focus,
                autofocus: true,
                hint: _t('hint'),
                clearLabel: _t('clear'),
                onBack: () => Navigator.of(context).maybePop(),
                onChanged: cubit.queryChanged,
                onSubmitted: _search,
                onClear: _clear,
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => _body(state, cubit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
