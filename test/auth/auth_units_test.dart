import 'package:dr_jabel/core/countries/countries.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:dr_jabel/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:dr_jabel/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dr_jabel/features/auth/domain/entities/phone_number.dart';
import 'package:dr_jabel/features/auth/domain/entities/registration_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('countries', () {
    test('Jordan, Saudi Arabia, Egypt come first; ISO codes are unique', () {
      expect(kCountries.take(3).map((c) => c.isoCode), ['JO', 'SA', 'EG']);
      expect(kCountries.take(3).map((c) => c.dialCodeWithPlus), [
        '+962',
        '+966',
        '+20',
      ]);
      final iso = kCountries.map((c) => c.isoCode).toSet();
      expect(iso.length, kCountries.length);
      expect(kCountries.length, greaterThan(200));
      // Only the 22 Arab League countries are offered for now.
      expect(Countries.available.length, 22);
      expect(Countries.available.take(3).map((c) => c.isoCode), [
        'JO',
        'SA',
        'EG',
      ]);
    });

    test('search by name (ar/en) and dial code', () {
      expect(Countries.search('مصر').first.isoCode, 'EG');
      expect(Countries.search('saudi').first.isoCode, 'SA');
      expect(Countries.search('+962').first.isoCode, 'JO');
      expect(Countries.search('zzzz'), isEmpty);
    });
  });

  group('repository + mock backend', () {
    late AuthRepositoryImpl repo;
    late AuthLocalDataSourceImpl local;
    const demo = PhoneNumber(
      isoCode: 'JO',
      dialCode: '962',
      national: '0791234567',
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      local = AuthLocalDataSourceImpl(await SharedPrefsStorage.create());
      repo = AuthRepositoryImpl(
        MockAuthRemoteDataSource(latency: Duration.zero),
        local,
      );
    });

    test('login maps server codes to domain failures', () async {
      final wrong = await repo.login(phone: demo, password: 'bad-pass');
      expect(wrong, isA<Err<void>>());
      expect((wrong as Err).failure, isA<InvalidCredentialsFailure>());

      final unknown = await repo.login(
        phone: const PhoneNumber(
          isoCode: 'SA',
          dialCode: '966',
          national: '0555555555',
        ),
        password: '123456',
      );
      expect((unknown as Err).failure, isA<UserNotFoundFailure>());

      expect(await repo.login(phone: demo, password: '123456'), isA<Success>());
    });

    test('verifyOtp: wrong code fails, right code saves the session', () async {
      final bad = await repo.verifyOtp(phone: demo, code: '1234');
      expect((bad as Err).failure, isA<InvalidOtpFailure>());
      expect(local.readSession(), isNull);

      final ok = await repo.verifyOtp(phone: demo, code: '5991');
      expect(ok, isA<Success>());
      expect(local.readSession()?.user.name, 'أحمد محمد');
      final current = await repo.currentSession();
      expect((current as Success).data, isNotNull);

      await repo.logout();
      expect(local.readSession(), isNull);
    });

    test('register then duplicate phone', () async {
      const data = RegistrationData(
        name: 'Sara',
        email: 's@x.co',
        phone: PhoneNumber(
          isoCode: 'EG',
          dialCode: '20',
          national: '01012345678',
        ),
        password: 'secret1',
      );
      expect(await repo.register(data), isA<Success>());
      final again = await repo.register(data);
      expect((again as Err).failure, isA<PhoneAlreadyRegisteredFailure>());
      // the new account can now log in
      expect(
        await repo.login(phone: data.phone, password: 'secret1'),
        isA<Success>(),
      );
    });
  });
}
