import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../address/domain/entities/address.dart';
import '../../../address/domain/entities/address_type.dart';
import '../../../address/presentation/cubit/delivery_location_cubit.dart';
import '../../../address/presentation/cubit/delivery_location_state.dart';
import '../../../payment_cards/domain/entities/payment_card.dart';
import '../cubit/checkout_cubit.dart';
import '../widgets/checkout_dialogs.dart';
import '../widgets/checkout_section.dart';
import '../widgets/delivery_address_tile.dart';
import '../widgets/order_summary_content.dart';
import '../widgets/payment_methods_content.dart';
import '../widgets/price_summary_content.dart';
import '../widgets/promo_code_section.dart';
import '../widgets/terms_footer.dart';
import 'payment_gateway_page.dart';

/// Checkout: where to deliver, the order's products, a discount code, how to
/// pay and what it all adds up to, then "confirm order".
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.onChangeAddress,
    required this.onAddCard,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    required this.onBackHome,
  });

  /// Opens the address chooser; the page follows the chosen place.
  final Future<void> Function(BuildContext context) onChangeAddress;

  /// Adds and verifies a card; null when the customer gave up.
  final Future<PaymentCard?> Function(BuildContext context) onAddCard;

  /// The two links under "confirm order": each opens its own page.
  final void Function(BuildContext context) onOpenTerms;
  final void Function(BuildContext context) onOpenPrivacy;

  /// "Back to home" on the confirmation.
  final void Function(BuildContext context) onBackHome;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<CheckoutCubit>().load(code);
    }
  }

  String _t(String key) => 'checkout.$key'.tr(context: context);

  Future<void> _onPhase(BuildContext context, OrderPhase phase) async {
    final cubit = context.read<CheckoutCubit>();
    switch (phase) {
      case OrderPhase.awaitingGateway:
        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const PaymentGatewayPage()),
        );
        await cubit.completeGateway(paid: paid ?? false);
      case OrderPhase.placed:
        final number = cubit.state.placedOrder?.number ?? '';
        await showOrderPlacedDialog(context, orderNumber: number);
        if (context.mounted) widget.onBackHome(context);
      case OrderPhase.failed:
        showAppToast(context, _t('order_failed'), error: true);
        cubit.acknowledgeFailure();
      case OrderPhase.idle || OrderPhase.submitting:
        break;
    }
  }

  Future<void> _addCard(BuildContext context) async {
    final cubit = context.read<CheckoutCubit>();
    final card = await widget.onAddCard(context);
    if (card == null || !context.mounted) return;
    await cubit.cardAdded(card);
    if (context.mounted) showAppToast(context, _t('card_added'));
  }

  void _info(BuildContext context, PriceInfo info) {
    final key = switch (info) {
      PriceInfo.savings => 'savings',
      PriceInfo.discounts => 'discounts',
      PriceInfo.delivery => 'delivery_fee',
    };
    showCheckoutInfoSheet(context, title: _t(key), message: _t('${key}_info'));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (p, c) => p.phase != c.phase,
          listener: (context, state) => _onPhase(context, state.phase),
        ),
        // The address chooser changes the app-wide delivery place.
        BlocListener<DeliveryLocationCubit, DeliveryLocationState>(
          listenWhen: (p, c) => p.selection != c.selection,
          listener: (context, state) => cubit.setAddress(state.selection),
        ),
      ],
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) {
          final options = state.options;
          return AppSubPage(
            title: 'nav.cart'.tr(context: context),
            backgroundColor: AppColors.backgroundBody,
            loading: state.phase == OrderPhase.submitting,
            bottom: state.status == CheckoutStatus.ready
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        key: const ValueKey('confirm-order'),
                        label: _t('confirm_order'),
                        onPressed: state.canConfirm ? cubit.confirm : null,
                      ),
                      SizedBox(height: 12.h),
                      TermsFooter(
                        onOpenTerms: () => widget.onOpenTerms(context),
                        onOpenPrivacy: () => widget.onOpenPrivacy(context),
                      ),
                    ],
                  )
                : null,
            body: switch (state.status) {
              CheckoutStatus.loading => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              CheckoutStatus.failed => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_t('load_failed')),
                    TextButton(
                      onPressed: () => cubit.load(_languageCode ?? 'ar'),
                      child: Text('home.retry'.tr(context: context)),
                    ),
                  ],
                ),
              ),
              CheckoutStatus.ready => ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  CheckoutSection(
                    title: _t('delivery_address'),
                    child: Builder(
                      builder: (context) {
                        final saved = context
                            .watch<DeliveryLocationCubit>()
                            .state
                            .addresses
                            .where((a) => a.id == state.address?.addressId);
                        final Address? address = saved.isEmpty
                            ? null
                            : saved.first;
                        return DeliveryAddressTile(
                          location: state.address,
                          type: address?.type ?? AddressType.other,
                          phone: address?.phone ?? '',
                          onTap: () => widget.onChangeAddress(context),
                        );
                      },
                    ),
                  ),
                  CheckoutSection(
                    title: _t('order_summary'),
                    child: OrderSummaryContent(cart: state.cart),
                  ),
                  CheckoutSection(
                    title: _t('promo_code'),
                    child: PromoCodeContent(
                      state: state,
                      onChanged: cubit.promoChanged,
                      onApply: cubit.applyPromo,
                    ),
                  ),
                  CheckoutSection(
                    title: _t('payment_method'),
                    child: PaymentMethodsContent(
                      walletBalance: options?.walletBalance ?? 0,
                      useWallet: state.useWallet,
                      onWalletChanged: cubit.toggleWallet,
                      applePayAvailable: options?.applePayAvailable ?? false,
                      cards: state.cards,
                      selected: state.method,
                      onSelect: cubit.selectMethod,
                      onAddCard: () => _addCard(context),
                    ),
                  ),
                  CheckoutSection(
                    title: _t('payment_summary'),
                    divider: false,
                    child: PriceSummaryContent(
                      pricing: state.pricing,
                      onInfo: (info) => _info(context, info),
                    ),
                  ),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}
