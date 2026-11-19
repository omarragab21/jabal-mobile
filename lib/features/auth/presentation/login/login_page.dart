import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../auth_messages.dart';
import '../otp/otp_args.dart';
import '../widgets/account_blocked_dialog.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/form_gap.dart';
import '../widgets/password_field.dart';
import '../widgets/phone_field.dart';
import 'login_cubit.dart';
import 'login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.otp, arguments: OtpArgs(phone: state.phone!));
        } else if (state.status == LoginStatus.failure &&
            state.failure != null) {
          final failure = state.failure!;
          if (failure is AccountBlockedFailure) {
            AccountBlockedDialog.show(
              context,
              title: 'auth.blocked.title'.tr(context: context),
              message: 'auth.blocked.message'.tr(context: context),
              contactLabel: 'auth.blocked.contact_support'.tr(context: context),
              // TODO: open the real support channel once it is defined.
              onContactSupport: () =>
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('auth.coming_soon'.tr(context: context)),
                    ),
                  ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AuthMessages.failure(failure).tr(context: context),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) => AuthScaffold(
        title: 'auth.login.title'.tr(context: context),
        showBack: false,
        loading: state.isLoading,
        body: Column(
          children: [
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
            ForgotPasswordLink(
              label: 'auth.login.forgot_password'.tr(context: context),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('auth.coming_soon'.tr(context: context)),
                ),
              ),
            ),
          ],
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'auth.login.button'.tr(context: context),
              onPressed: state.isLoading ? null : () => _submit(context),
            ),
            SizedBox(height: 16.h),
            AuthFooterLink(
              question: 'auth.login.no_account'.tr(context: context),
              action: 'auth.login.create_account'.tr(context: context),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
