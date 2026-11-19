import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';
import '../../../auth/domain/entities/phone_number.dart';
import '../../../auth/domain/validators/digit_normalizer.dart';
import '../../../auth/domain/validators/phone_number_validator.dart';
import '../../domain/usecases/profile_use_cases.dart';

enum EditPhoneStep { number, code }

class EditPhoneState extends Equatable {
  EditPhoneState({
    Country? country,
    this.step = EditPhoneStep.number,
    this.numberError,
    this.sameNumber = false,
    this.busy = false,
    this.wrongCode = false,
    this.saved = false,
    this.failure,
  }) : country = country ?? Countries.defaultCountry;

  final Country country;
  final EditPhoneStep step;
  final ValidationError? numberError;

  /// The typed number is the one the account already has.
  final bool sameNumber;
  final bool busy;
  final bool wrongCode;
  final bool saved;
  final Failure? failure;

  EditPhoneState copyWith({
    Country? country,
    EditPhoneStep? step,
    ValidationError? Function()? numberError,
    bool? sameNumber,
    bool? busy,
    bool? wrongCode,
    bool? saved,
    Failure? Function()? failure,
  }) => EditPhoneState(
    country: country ?? this.country,
    step: step ?? this.step,
    numberError: numberError != null ? numberError() : this.numberError,
    sameNumber: sameNumber ?? this.sameNumber,
    busy: busy ?? this.busy,
    wrongCode: wrongCode ?? this.wrongCode,
    saved: saved ?? this.saved,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    country,
    step,
    numberError,
    sameNumber,
    busy,
    wrongCode,
    saved,
    failure,
  ];
}

/// Changing the account number: type the new one, then confirm it with the
/// code sent to it.
class EditPhoneCubit extends Cubit<EditPhoneState> {
  EditPhoneCubit({
    required this.currentPhone,
    required PhoneNumberValidator phoneValidator,
    required Validator<String> otpValidator,
    required RequestPhoneChange requestChange,
    required ConfirmPhoneChange confirmChange,
  }) : _phoneValidator = phoneValidator,
       _otpValidator = otpValidator,
       _requestChange = requestChange,
       _confirmChange = confirmChange,
       super(EditPhoneState());

  /// The number the account has now (E.164).
  final String currentPhone;
  final PhoneNumberValidator _phoneValidator;
  final Validator<String> _otpValidator;
  final RequestPhoneChange _requestChange;
  final ConfirmPhoneChange _confirmChange;

  String _text = '';
  bool _submitted = false;

  PhoneNumber get _phone => PhoneNumber(
    isoCode: state.country.isoCode,
    dialCode: state.country.dialCode,
    national: DigitNormalizer.toLatin(_text),
  );

  void countryChanged(Country country) {
    emit(state.copyWith(country: country, sameNumber: false));
    if (_submitted) {
      emit(state.copyWith(numberError: () => _phoneValidator.validate(_phone)));
    }
  }

  void numberChanged(String text) {
    _text = text;
    emit(
      state.copyWith(
        numberError: _submitted
            ? () => _phoneValidator.validate(_phone)
            : () => null,
        sameNumber: false,
        failure: () => null,
      ),
    );
  }

  Future<void> sendCode() async {
    if (state.busy) return;
    _submitted = true;
    final error = _phoneValidator.validate(_phone);
    if (error != null) {
      emit(state.copyWith(numberError: () => error));
      return;
    }
    if (_phone.e164 == currentPhone) {
      emit(state.copyWith(sameNumber: true, numberError: () => null));
      return;
    }
    emit(state.copyWith(busy: true, failure: () => null));
    final result = await _requestChange(_phone.e164);
    if (isClosed) return;
    result.when(
      success: (_) =>
          emit(state.copyWith(busy: false, step: EditPhoneStep.code)),
      failure: (f) => emit(state.copyWith(busy: false, failure: () => f)),
    );
  }

  /// The new number the code was sent to.
  PhoneNumber get newNumber => _phone;

  void codeChanged() {
    if (state.wrongCode || state.failure != null) {
      emit(state.copyWith(wrongCode: false, failure: () => null));
    }
  }

  void backToNumber() =>
      emit(state.copyWith(step: EditPhoneStep.number, wrongCode: false));

  Future<void> verify(String code) async {
    if (state.busy) return;
    final normalized = DigitNormalizer.toLatin(code).trim();
    if (_otpValidator.validate(normalized) != null) {
      emit(state.copyWith(wrongCode: true));
      return;
    }
    emit(state.copyWith(busy: true, wrongCode: false, failure: () => null));
    final result = await _confirmChange(_phone.e164, normalized);
    if (isClosed) return;
    result.when(
      success: (_) => emit(state.copyWith(busy: false, saved: true)),
      failure: (f) => emit(
        f is InvalidOtpFailure
            ? state.copyWith(busy: false, wrongCode: true)
            : state.copyWith(busy: false, failure: () => f),
      ),
    );
  }
}
