import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../../profile/presentation/cubit/edit_text_cubit.dart';
import '../../domain/entities/payment_card.dart';
import '../widgets/payment_card_view.dart';

/// The nickname of a card, shown on its face. [onDelete] (the edit case)
/// adds a delete button; it returns true when the card was deleted.
class CardNicknamePage extends StatefulWidget {
  const CardNicknamePage({super.key, required this.card, this.onDelete});

  final PaymentCard card;
  final Future<bool> Function()? onDelete;

  @override
  State<CardNicknamePage> createState() => _CardNicknamePageState();
}

class _CardNicknamePageState extends State<CardNicknamePage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.card.nickname,
  );
  late String _nickname = widget.card.nickname;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'cards.$key'.tr(context: context);
    final cubit = context.read<EditTextCubit<PaymentCard>>();
    final editing = widget.onDelete != null;
    return BlocConsumer<EditTextCubit<PaymentCard>, EditTextState>(
      listenWhen: (p, c) => !p.saved && c.saved,
      listener: (context, _) => Navigator.of(context).pop(),
      builder: (context, state) => AppSubPage(
        title: editing ? t('edit_nickname') : t('add_nickname'),
        loading: state.saving,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaymentCardView(
                brand: widget.card.brand,
                last4: widget.card.last4,
                expiry: widget.card.expiry,
                expiresLabel: t('expires'),
                nickname: _nickname.trim(),
              ),
              SizedBox(height: 24.h),
              AppTextField(
                label: t('nickname'),
                hint: t('nickname_hint'),
                controller: _controller,
                textInputAction: TextInputAction.done,
                errorText: AuthMessages.validation(
                  context,
                  'card_nickname',
                  state.error,
                ),
                onChanged: (value) {
                  setState(() => _nickname = value);
                  cubit.changedTo(value);
                },
                onSubmitted: (_) => cubit.submit(),
              ),
              if (state.failure != null) ...[
                SizedBox(height: 8.h),
                Text(
                  t('save_failed'),
                  key: const ValueKey('save-failed'),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              if (editing) ...[
                SizedBox(height: 24.h),
                AppButton(
                  label: t('delete_card'),
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    final deleted = await widget.onDelete!();
                    if (deleted && context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ],
          ),
        ),
        bottom: AppButton(
          label: t('save'),
          onPressed: state.saving ? null : cubit.submit,
        ),
      ),
    );
  }
}
