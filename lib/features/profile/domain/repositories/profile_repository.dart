import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// The signed-in customer; a `NotFoundFailure` when nobody is signed in.
  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateName(String name);

  Future<Result<UserProfile>> updateEmail(String email);

  Future<Result<UserProfile>> updateGender(Gender? gender);

  Future<Result<UserProfile>> updateBirthDate(DateTime? date);

  /// Sends a verification code to [e164], the new number.
  Future<Result<void>> requestPhoneChange(String e164);

  /// Checks [code] and, when it is right, makes [e164] the account number.
  /// An `InvalidOtpFailure` when the code is wrong.
  Future<Result<UserProfile>> confirmPhoneChange(String e164, String code);
}
