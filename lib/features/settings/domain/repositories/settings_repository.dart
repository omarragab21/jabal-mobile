import '../../../../core/utils/result.dart';

abstract interface class SettingsRepository {
  /// Whether the customer wants notifications (on by default).
  Future<Result<bool>> getNotificationsEnabled();

  Future<Result<void>> setNotificationsEnabled(bool enabled);

  /// Deletes the account and everything saved for it on this device. The
  /// language and the "onboarding seen" flag stay.
  Future<Result<void>> deleteAccount();
}
