import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../payment_cards/domain/entities/payment_card.dart';
import '../../domain/entities/payment_method.dart';

/// The wallet switch, the payment methods to pick from (cash, Apple Pay, the
/// saved cards) and the button that adds a card.
class PaymentMethodsContent extends StatelessWidget {
  const PaymentMethodsContent({
    super.key,
    required this.walletBalance,
    required this.useWallet,
    required this.onWalletChanged,
    required this.applePayAvailable,
    required this.cards,
    required this.selected,
    required this.onSelect,
    required this.onAddCard,
  });

  final double walletBalance;
  final bool useWallet;
  final ValueChanged<bool> onWalletChanged;
  final bool applePayAvailable;
  final List<PaymentCard> cards;
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'checkout.$key'.tr(context: context);
    final currency = 'home.currency'.tr(context: context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (walletBalance > 0) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('use_wallet'),
                      style: AppTextStyles.textMdRegular.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      t('wallet_balance').replaceAll(
                        '{amount}',
                        '${walletBalance.toStringAsFixed(2)} $currency',
                      ),
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.textLabel,
                      ),
                    ),
                  ],
                ),
              ),
              AppSwitch(
                key: const ValueKey('wallet-switch'),
                value: useWallet,
                onChanged: onWalletChanged,
                label: t('use_wallet'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
        _MethodRow(
          key: const ValueKey('method-cash'),
          label: t('cash'),
          logo: Icon(Icons.payments_outlined, size: 24.r),
          selected: selected is CashPayment,
          onTap: () => onSelect(const CashPayment()),
        ),
        if (applePayAvailable)
          _MethodRow(
            key: const ValueKey('method-apple-pay'),
            label: t('apple_pay'),
            logo: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apple, size: 18.r),
                Text(
                  'Pay',
                  style: AppTextStyles.textSmBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ],
            ),
            selected: selected is ApplePayPayment,
            onTap: () => onSelect(const ApplePayPayment()),
          ),
        for (final card in cards)
          _MethodRow(
            key: ValueKey('method-card-${card.id}'),
            label: card.nickname.isEmpty
                ? 'xxxx-${card.last4}'
                : '${card.nickname} · ${card.last4}',
            logo: _BrandMark(brand: card.brand),
            selected: switch (selected) {
              CardPayment(card: final c) => c.id == card.id,
              _ => false,
            },
            onTap: () => onSelect(CardPayment(card)),
          ),
        SizedBox(height: 4.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const ValueKey('add-card'),
            onPressed: onAddCard,
            icon: Icon(Icons.add, size: 22.r),
            label: Text(t('add_card')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDefault,
              side: const BorderSide(color: AppColors.border),
              minimumSize: Size(0, 44.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              textStyle: AppTextStyles.textMdRegular,
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    super.key,
    required this.label,
    required this.logo,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Widget logo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              _Radio(selected: selected),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textLabel,
                  ),
                ),
              ),
              Container(
                width: 56.w,
                height: 40.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: FittedBox(fit: BoxFit.scaleDown, child: logo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green ring with a dot when selected, a grey ring otherwise.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 24.r,
    height: 24.r,
    padding: EdgeInsets.all(3.r),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        width: 1.5,
      ),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}

/// The card network's name in its colour (there are no logo assets).
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.brand});

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (brand) {
      CardBrand.visa => ('VISA', const Color(0xFF172B85)),
      CardBrand.mastercard => ('MC', const Color(0xFFEB001B)),
      CardBrand.other => ('CARD', AppColors.textLabel),
    };
    return Text(
      text,
      style: AppTextStyles.textSmBold.copyWith(
        color: color,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
