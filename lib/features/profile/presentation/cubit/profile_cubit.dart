import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_use_cases.dart';

enum ProfileStatus { loading, ready, failed }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.saving = false,
    this.saveFailure,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final bool saving;

  /// Why the last save failed; cleared by the next change.
  final Failure? saveFailure;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    bool? saving,
    Failure? Function()? saveFailure,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    saving: saving ?? this.saving,
    saveFailure: saveFailure != null ? saveFailure() : this.saveFailure,
  );

  @override
  List<Object?> get props => [status, profile, saving, saveFailure];
}

/// View model of the personal information page: shows the profile and saves
/// the changes that need no input page (gender, birth date).
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfile getProfile,
    required UpdateGender updateGender,
    required UpdateBirthDate updateBirthDate,
  }) : _getProfile = getProfile,
       _updateGender = updateGender,
       _updateBirthDate = updateBirthDate,
       super(const ProfileState());

  final GetProfile _getProfile;
  final UpdateGender _updateGender;
  final UpdateBirthDate _updateBirthDate;

  Future<void> load() async {
    final result = await _getProfile();
    if (isClosed) return;
    result.when(
      success: (profile) =>
          emit(state.copyWith(status: ProfileStatus.ready, profile: profile)),
      failure: (_) => emit(state.copyWith(status: ProfileStatus.failed)),
    );
  }

  /// Another page changed the profile: show the saved version.
  Future<void> reload() => load();

  Future<void> setGender(Gender? gender) => _save(() => _updateGender(gender));

  Future<void> setBirthDate(DateTime? date) =>
      _save(() => _updateBirthDate(date));

  Future<void> _save(Future<Result<UserProfile>> Function() action) async {
    emit(state.copyWith(saving: true, saveFailure: () => null));
    final result = await action();
    if (isClosed) return;
    result.when(
      success: (profile) =>
          emit(state.copyWith(saving: false, profile: profile)),
      failure: (failure) =>
          emit(state.copyWith(saving: false, saveFailure: () => failure)),
    );
  }
}
