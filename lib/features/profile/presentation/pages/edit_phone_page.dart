import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../../auth/presentation/widgets/country_picker_sheet.dart';
import '../../../auth/presentation/widgets/otp_error_message.dart';
import '../../../auth/presentation/widgets/otp_input.dart';
import '../../../auth/presentation/widgets/phone_field.dart';
import '../cubit/edit_phone_cubit.dart';

/// Changing the account number: the new number first, then the code that was
/// sent to it. Pops with `true` once the number is changed.
class EditPhonePage extends StatefulWidget {
  const EditPhonePage({super.key});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  final TextEditingController _phone = TextEditingController();
  final GlobalKey<State<OtpInput>> _otpKey = GlobalKey<State<OtpInput>>();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String _t(String key) => 'profile.$key'.tr(context: context);

  /// Keep the digits left to right inside Arabic text.
  static final String _lri = String.fromCharCode(0x2066); // LTR isolate
  static final String _pdi = String.fromCharCode(0x2069); // pop isolate

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditPhoneCubit>();
    return BlocConsumer<EditPhoneCubit, EditPhoneState>(
      listenWhen: (p, c) => !p.saved && c.saved,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final onCode = state.step == EditPhoneStep.code;
        return AppSubPage(
          title: _t('edit_phone'),
          loading: state.busy,
          onBack: onCode ? cubit.backToNumber : null,
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
            child: onCode
                ? _codeStep(context, cubit, state)
                : _numberStep(context, cubit, state),
          ),
          bottom: onCode
              ? null
              : AppButton(
                  label: _t('send_code'),
                  onPressed: state.busy ? null : cubit.sendCode,
                ),
        );
      },
    );
  }

  Widget _numberStep(
    BuildContext context,
    EditPhoneCubit cubit,
    EditPhoneState state,
  ) {
    final error = state.sameNumber
        ? _t('phone_same')
        : AuthMessages.validation(context, 'phone', state.numberError);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhoneField(
          label: 'auth.fields.phone'.tr(context: context),
          hint: 'auth.fields.phone_hint'.tr(context: context),
          country: state.country,
          controller: _phone,
          errorText: error,
          textInputAction: TextInputAction.done,
          onChanged: cubit.numberChanged,
          onCountryTap: () => CountryPickerSheet.show(
            context,
            title: 'auth.country.title'.tr(context: context),
            searchHint: 'auth.country.search'.tr(context: context),
            emptyLabel: 'auth.country.empty'.tr(context: context),
            languageCode: context.locale.languageCode,
            selected: state.country,
            onSelected: cubit.countryChanged,
          ),
        ),
        if (state.failure != null) ...[
          SizedBox(height: 8.h),
          Text(
            _t('save_failed'),
            key: const ValueKey('save-failed'),
            style: AppTextStyles.textSmRegular.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _codeStep(
    BuildContext context,
    EditPhoneCubit cubit,
    EditPhoneState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t(
            'code_sent',
          ).replaceAll('{phone}', '$_lri${cubit.newNumber.local}$_pdi'),
          style: AppTextStyles.textMdRegular.copyWith(
            color: AppColors.textDefault,
          ),
        ),
        SizedBox(height: 20.h),
        OtpInput(
          key: _otpKey,
          status: state.wrongCode ? OtpStatus.error : OtpStatus.idle,
          onChanged: (_) => cubit.codeChanged(),
          onCompleted: cubit.verify,
        ),
        if (state.wrongCode) ...[
          SizedBox(height: 16.h),
          Center(
            child: OtpErrorMessage(
              message: 'auth.otp.wrong'.tr(context: context),
            ),
          ),
        ],
        if (state.failure != null) ...[
          SizedBox(height: 16.h),
          Text(
            _t('save_failed'),
            key: const ValueKey('save-failed'),
            style: AppTextStyles.textSmRegular.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
