import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/validation/validator.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/validators/digit_normalizer.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.phone,
    required VerifyOtp verifyOtp,
    required ResendOtp resendOtp,
    required Validator<String> otpValidator,
    this.resendSeconds = 60,
  }) : _verifyOtp = verifyOtp,
       _resendOtp = resendOtp,
       _otpValidator = otpValidator,
       super(OtpState(secondsLeft: resendSeconds)) {
    _startTimer();
  }

  final PhoneNumber phone;
  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;
  final Validator<String> _otpValidator;
  final int resendSeconds;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsLeft <= 1) {
        _timer?.cancel();
        emit(state.copyWith(secondsLeft: 0));
      } else {
        emit(state.copyWith(secondsLeft: state.secondsLeft - 1));
      }
    });
  }

  /// The user edited the code: leave the "wrong code" state.
  void codeChanged() {
    if (state.status == OtpVerifyStatus.wrong || state.failure != null) {
      emit(state.copyWith(status: OtpVerifyStatus.idle, failure: () => null));
    }
  }

  Future<void> verify(String code) async {
    if (state.status == OtpVerifyStatus.verifying) return;
    final normalized = DigitNormalizer.toLatin(code).trim();
    if (_otpValidator.validate(normalized) != null) {
      emit(state.copyWith(status: OtpVerifyStatus.wrong));
      return;
    }
    emit(
      state.copyWith(status: OtpVerifyStatus.verifying, failure: () => null),
    );
    final result = await _verifyOtp(phone: phone, code: normalized);
    result.when(
      success: (_) => emit(state.copyWith(status: OtpVerifyStatus.success)),
      failure: (f) => emit(
        f is InvalidOtpFailure
            ? state.copyWith(status: OtpVerifyStatus.wrong)
            : state.copyWith(status: OtpVerifyStatus.failure, failure: () => f),
      ),
    );
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    emit(state.copyWith(resending: true, failure: () => null));
    final result = await _resendOtp(phone);
    result.when(
      success: (_) {
        emit(
          state.copyWith(
            resending: false,
            status: OtpVerifyStatus.idle,
            secondsLeft: resendSeconds,
          ),
        );
        _startTimer();
      },
      failure: (f) => emit(state.copyWith(resending: false, failure: () => f)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
