import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

enum OtpVerifyStatus { idle, verifying, wrong, success, failure }

class OtpState extends Equatable {
  const OtpState({
    this.status = OtpVerifyStatus.idle,
    this.secondsLeft = 0,
    this.resending = false,
    this.failure,
  });

  final OtpVerifyStatus status;
  final int secondsLeft;
  final bool resending;

  /// Set for non-"wrong code" problems (network...), shown as a message.
  final Failure? failure;

  bool get isBusy => status == OtpVerifyStatus.verifying || resending;
  bool get canResend => secondsLeft == 0 && !isBusy;

  OtpState copyWith({
    OtpVerifyStatus? status,
    int? secondsLeft,
    bool? resending,
    Failure? Function()? failure,
  }) => OtpState(
    status: status ?? this.status,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    resending: resending ?? this.resending,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, secondsLeft, resending, failure];
}
