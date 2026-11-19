import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/formatters/input_formatters.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../auth_messages.dart';
import '../otp/otp_args.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/form_gap.dart';
import '../widgets/password_field.dart';
import '../widgets/phone_field.dart';
import 'register_cubit.dart';
import 'register_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.otp, arguments: OtpArgs(phone: state.phone!));
        } else if (state.status == RegisterStatus.failure &&
            state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AuthMessages.failure(state.failure!).tr(context: context),
              ),
            ),
          );
        }
      },
      builder: (context, state) => AuthScaffold(
        title: 'auth.register.title'.tr(context: context),
        loading: state.isLoading,
        body: Column(
          children: [
            AppTextField(
              label: 'auth.register.full_name'.tr(context: context),
              hint: 'auth.fields.type_here'.tr(context: context),
              controller: _name,
              errorText: AuthMessages.validation(
                context,
                'name',
                state.nameError,
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              onChanged: cubit.nameChanged,
            ),
            const FormGap(),
            AppTextField(
              label: 'auth.register.email'.tr(context: context),
              hint: 'auth.fields.type_here'.tr(context: context),
              controller: _email,
              errorText: AuthMessages.validation(
                context,
                'email',
                state.emailError,
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: noSpaceFormatters(max: 254),
              onChanged: cubit.emailChanged,
            ),
            const FormGap(),
            PhoneField(
              label: 'auth.fields.phone'.tr(context: context),
              hint: 'auth.fields.phone_hint'.tr(context: context),
              country: state.country,
              controller: _phone,
              errorText: AuthMessages.validation(
                context,
                'phone',
                state.phoneError,
              ),
              textInputAction: TextInputAction.next,
              onChanged: cubit.phoneChanged,
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
            const FormGap(),
            PasswordField(
              label: 'auth.fields.password'.tr(context: context),
              hint: 'auth.fields.password_hint'.tr(context: context),
              controller: _password,
              errorText: AuthMessages.validation(
                context,
                'password',
                state.passwordError,
              ),
              textInputAction: TextInputAction.done,
              onChanged: cubit.passwordChanged,
              onSubmitted: (_) => _submit(context),
            ),
          ],
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'auth.register.send_code'.tr(context: context),
              onPressed: state.isLoading ? null : () => _submit(context),
            ),
            SizedBox(height: 16.h),
            AuthFooterLink(
              question: 'auth.register.have_account'.tr(context: context),
              action: 'auth.register.sign_in'.tr(context: context),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
