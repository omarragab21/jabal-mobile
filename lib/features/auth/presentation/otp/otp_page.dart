import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_routes.dart';
import '../auth_messages.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_error_message.dart';
import '../widgets/otp_input.dart';
import '../widgets/resend_code_text.dart';
import 'otp_cubit.dart';
import 'otp_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpKey = GlobalKey<State<OtpInput>>();

  static final _lri = String.fromCharCode(0x2066); // LTR isolate
  static final _pdi = String.fromCharCode(0x2069); // pop isolate

  /// Keeps the phone readable inside RTL text.
  String _phoneLabel(OtpCubit cubit) => '$_lri${cubit.phone.local}$_pdi';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtpCubit>();

    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (p, c) => p.status != c.status || p.failure != c.failure,
      listener: (context, state) async {
        if (state.status == OtpVerifyStatus.success) {
          // Let the green "success" boxes be seen for a moment.
          await Future<void>.delayed(const Duration(milliseconds: 700));
          if (!context.mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.main, (_) => false);
        } else if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AuthMessages.failure(state.failure!).tr(context: context),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final wrong = state.status == OtpVerifyStatus.wrong;
        final status = switch (state.status) {
          OtpVerifyStatus.wrong => OtpStatus.error,
          OtpVerifyStatus.success => OtpStatus.success,
          _ => OtpStatus.idle,
        };

        return AuthScaffold(
          title: 'auth.otp.title'.tr(context: context),
          loading: state.isBusy,
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auth.otp.sent'.tr(
                    context: context,
                    namedArgs: {'phone': _phoneLabel(cubit)},
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    height: 24 / 16,
                  ),
                ),
                SizedBox(height: 20.h),
                OtpInput(
                  key: _otpKey,
                  status: status,
                  enabled: state.status != OtpVerifyStatus.success,
                  onChanged: (_) => cubit.codeChanged(),
                  onCompleted: cubit.verify,
                ),
                if (wrong) ...[
                  SizedBox(height: 16.h),
                  Center(
                    child: OtpErrorMessage(
                      message: 'auth.otp.wrong'.tr(context: context),
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                Center(
                  child: ResendCodeText(
                    prompt: 'auth.otp.didnt_receive'.tr(context: context),
                    waitLabel: 'auth.otp.resend_in'.tr(context: context),
                    resendLabel: 'auth.otp.resend'.tr(context: context),
                    secondsLeft: state.secondsLeft,
                    onResend: cubit.resend,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
