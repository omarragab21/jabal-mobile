import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/formatters/input_formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../domain/entities/payment_card.dart';
import '../card_formatters.dart';
import '../cubit/add_card_cubit.dart';

/// Add a card: number, expiry and security code. Pops with the saved
/// [PaymentCard].
class AddPaymentCardPage extends StatelessWidget {
  const AddPaymentCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'cards.$key'.tr(context: context);
    final cubit = context.read<AddCardCubit>();
    return BlocConsumer<AddCardCubit, AddCardState>(
      listenWhen: (p, c) => p.saved == null && c.saved != null,
      listener: (context, state) => Navigator.of(context).pop(state.saved),
      builder: (context, state) => AppSubPage(
        title: t('add_title'),
        loading: state.saving,
        loadingLabel: t('verifying'),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: t('number'),
                hint: '0000 0000 0000 0000',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textDirection: TextDirection.ltr,
                inputFormatters: const [CardNumberFormatter()],
                errorText: AuthMessages.validation(
                  context,
                  'card_number',
                  state.numberError,
                ),
                onChanged: cubit.numberChanged,
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: t('expiry'),
                      hint: 'MM/YY',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      inputFormatters: const [CardExpiryFormatter()],
                      errorText: AuthMessages.validation(
                        context,
                        'expiry',
                        state.expiryError,
                      ),
                      onChanged: cubit.expiryChanged,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AppTextField(
                      label: t('cvv'),
                      hint: '123',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      obscureText: true,
                      inputFormatters: digitsFormatters(max: 3),
                      errorText: AuthMessages.validation(
                        context,
                        'cvv',
                        state.cvvError,
                      ),
                      onChanged: cubit.cvvChanged,
                      onSubmitted: (_) => cubit.submit(),
                    ),
                  ),
                ],
              ),
              if (state.failure != null) ...[
                SizedBox(height: 12.h),
                Text(
                  t('save_failed'),
                  key: const ValueKey('save-failed'),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Text(
                t('privacy_note'),
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        bottom: AppButton(
          label: t('add_action'),
          onPressed: state.saving ? null : cubit.submit,
        ),
      ),
    );
  }
}
