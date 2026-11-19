import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../auth/domain/validators/auth_validation.dart';
import '../auth/domain/validators/email_validator.dart';
import '../auth/domain/validators/name_validator.dart';
import 'data/datasources/profile_local_data_source.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/entities/user_profile.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/profile_use_cases.dart';
import 'presentation/cubit/edit_phone_cubit.dart';
import 'presentation/cubit/edit_text_cubit.dart';
import 'presentation/cubit/profile_cubit.dart';
import 'presentation/pages/edit_phone_page.dart';
import 'presentation/pages/edit_text_page.dart';
import 'presentation/pages/personal_info_page.dart';

/// The personal information feature: the page that lists the details and the
/// pages that change one of them.
class ProfileModule {
  ProfileModule(
    LocalStorage storage, {
    required AuthValidation validation,
    ProfileRemoteDataSource? remote,
  }) : _repository = ProfileRepositoryImpl(
         StorageProfileLocalDataSource(storage),
         remote ?? const MockProfileRemoteDataSource(),
       ),
       _validation = validation;

  final ProfileRepository _repository;
  final AuthValidation _validation;

  /// Opens "personal information" over the current page.
  Future<void> openPersonalInfo(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProfileCubit(
            getProfile: GetProfile(_repository),
            updateGender: UpdateGender(_repository),
            updateBirthDate: UpdateBirthDate(_repository),
          )..load(),
          child: Builder(
            builder: (pageContext) => PersonalInfoPage(
              onEditName: () => _editName(pageContext),
              onEditEmail: () => _editEmail(pageContext),
              onEditPhone: () => _editPhone(pageContext),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final profile = (await GetProfile(
      _repository,
    )()).when(success: (p) => p, failure: (_) => null);
    if (profile == null || !context.mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EditTextCubit<UserProfile>(
            initial: profile.name,
            validator: _validation.name,
            normalize: NameValidator.normalize,
            save: UpdateName(_repository).call,
          ),
          child: EditTextPage<UserProfile>(
            title: 'profile.edit_name'.tr(context: context),
            label: 'profile.full_name'.tr(context: context),
            hint: 'profile.full_name_hint'.tr(context: context),
            field: 'name',
            initial: profile.name,
          ),
        ),
      ),
    );
  }

  Future<void> _editEmail(BuildContext context) async {
    final profile = (await GetProfile(
      _repository,
    )()).when(success: (p) => p, failure: (_) => null);
    if (profile == null || !context.mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EditTextCubit<UserProfile>(
            initial: profile.email ?? '',
            validator: _validation.email,
            normalize: EmailValidator.normalize,
            save: UpdateEmail(_repository).call,
          ),
          child: EditTextPage<UserProfile>(
            title: 'profile.edit_email'.tr(context: context),
            label: 'profile.email'.tr(context: context),
            hint: 'profile.email_hint'.tr(context: context),
            helper: 'profile.email_helper'.tr(context: context),
            field: 'email',
            initial: profile.email ?? '',
            keyboardType: TextInputType.emailAddress,
            ltr: true,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          ),
        ),
      ),
    );
  }

  Future<void> _editPhone(BuildContext context) async {
    final profile = (await GetProfile(
      _repository,
    )()).when(success: (p) => p, failure: (_) => null);
    if (profile == null || !context.mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => EditPhoneCubit(
            currentPhone: profile.phone,
            phoneValidator: _validation.phone,
            otpValidator: _validation.otp,
            requestChange: RequestPhoneChange(_repository),
            confirmChange: ConfirmPhoneChange(_repository),
          ),
          child: const EditPhonePage(),
        ),
      ),
    );
  }
}
