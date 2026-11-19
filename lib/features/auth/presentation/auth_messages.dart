import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../core/error/failures.dart';
import '../../../core/validation/validation_error.dart';

/// Maps domain results to localized text (`assets/translations/*.json`).
abstract final class AuthMessages {
  /// Message for a failed validation. Looks for a field-specific text first
  /// (`validation.email.invalidFormat`) and falls back to the generic one
  /// (`validation.invalidFormat`). Placeholders come from `error.params`.
  static String? validation(
    BuildContext context,
    String field,
    ValidationError? error,
  ) {
    if (error == null) return null;
    final args = {for (final e in error.params.entries) e.key: '${e.value}'};
    final specific = 'validation.$field.${error.code.name}';
    final text = specific.tr(context: context, namedArgs: args);
    if (text != specific) return text;
    return 'validation.${error.code.name}'.tr(
      context: context,
      namedArgs: args,
    );
  }

  /// Translation key for a business/network failure.
  static String failure(Failure f) => switch (f) {
    InvalidCredentialsFailure() => 'auth.errors.invalid_credentials',
    UserNotFoundFailure() => 'auth.errors.user_not_found',
    PhoneAlreadyRegisteredFailure() => 'auth.errors.phone_taken',
    NetworkFailure() => 'auth.errors.network',
    _ => 'auth.errors.unknown',
  };
}
