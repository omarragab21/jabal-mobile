import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/payment_card.dart';
import '../cubit/payment_cards_cubit.dart';
import '../widgets/payment_card_view.dart';

/// "بطاقات الدفع": the saved cards and a button to add one.
class PaymentCardsPage extends StatelessWidget {
  const PaymentCardsPage({
    super.key,
    required this.onAdd,
    required this.onEdit,
  });

  /// Open the add-card flow / the nickname page of a card; each completes
  /// when the opened page is closed, and the list is reloaded.
  final Future<void> Function() onAdd;
  final Future<void> Function(PaymentCard card) onEdit;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'cards.$key'.tr(context: context);
    final cubit = context.read<PaymentCardsCubit>();
    return BlocBuilder<PaymentCardsCubit, PaymentCardsState>(
      builder: (context, state) => AppSubPage(
        title: t('title'),
        body: switch (state.status) {
          PaymentCardsStatus.loading => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          PaymentCardsStatus.failed => Center(
            child: TextButton(
              onPressed: cubit.load,
              child: Text('home.retry'.tr(context: context)),
            ),
          ),
          PaymentCardsStatus.ready when state.cards.isEmpty => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                t('empty'),
                textAlign: TextAlign.center,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          PaymentCardsStatus.ready => ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.cards.length,
            separatorBuilder: (_, _) => SizedBox(height: 16.h),
            itemBuilder: (_, index) {
              final card = state.cards[index];
              return GestureDetector(
                key: ValueKey('card-${card.id}'),
                onTap: () async {
                  await onEdit(card);
                  await cubit.load();
                },
                child: PaymentCardView(
                  brand: card.brand,
                  last4: card.last4,
                  expiry: card.expiry,
                  expiresLabel: t('expires'),
                  nickname: card.nickname,
                ),
              );
            },
          ),
        },
        bottom: AppButton(
          label: t('add_card'),
          onPressed: () async {
            await onAdd();
            await cubit.load();
          },
        ),
      ),
    );
  }
}
