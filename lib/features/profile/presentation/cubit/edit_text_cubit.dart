import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';

class EditTextState extends Equatable {
  const EditTextState({
    this.error,
    this.saving = false,
    this.saved = false,
    this.failure,
  });

  /// Shown after the first save attempt, then live while typing.
  final ValidationError? error;
  final bool saving;
  final bool saved;
  final Failure? failure;

  @override
  List<Object?> get props => [error, saving, saved, failure];
}

/// Edits one text field of the profile (name, e-mail): validates it, shows
/// the error only after a first attempt, then saves.
class EditTextCubit<T> extends Cubit<EditTextState> {
  EditTextCubit({
    required String initial,
    required Validator<String> validator,
    required String Function(String raw) normalize,
    required Future<Result<T>> Function(String value) save,
  }) : _value = initial,
       _validator = validator,
       _normalize = normalize,
       _save = save,
       _initial = normalize(initial),
       super(const EditTextState());

  final Validator<String> _validator;
  final String Function(String raw) _normalize;
  final Future<Result<T>> Function(String value) _save;
  final String _initial;

  String _value;
  bool _submitted = false;

  /// True when the text differs from what is saved.
  bool get changed => _normalize(_value) != _initial;

  void changedTo(String value) {
    _value = value;
    emit(EditTextState(error: _submitted ? _validator.validate(_value) : null));
  }

  Future<void> submit() async {
    if (state.saving) return;
    _submitted = true;
    final error = _validator.validate(_value);
    if (error != null) {
      emit(EditTextState(error: error));
      return;
    }
    final value = _normalize(_value);
    // Nothing to save: just leave.
    if (value == _initial) {
      emit(const EditTextState(saved: true));
      return;
    }
    emit(const EditTextState(saving: true));
    final result = await _save(value);
    if (isClosed) return;
    result.when(
      success: (_) => emit(const EditTextState(saved: true)),
      failure: (f) => emit(EditTextState(failure: f)),
    );
  }
}
