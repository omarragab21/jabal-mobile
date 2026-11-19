import 'package:dr_jabel/core/countries/countries.dart';
import 'package:dr_jabel/core/validation/string_rules.dart';
import 'package:dr_jabel/core/validation/validation_error.dart';
import 'package:dr_jabel/core/validation/validator.dart';
import 'package:dr_jabel/features/auth/data/validators/lib_phone_number_validator.dart';
import 'package:dr_jabel/features/auth/domain/entities/phone_number.dart';
import 'package:dr_jabel/features/auth/domain/validators/digit_normalizer.dart';
import 'package:dr_jabel/features/auth/domain/validators/email_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/login_password_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/name_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/otp_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/password_validator.dart';
import 'package:flutter_test/flutter_test.dart';

ValidationCode? _code(ValidationError? e) => e?.code;

void main() {
  group('core rules', () {
    test('composite reports the first failure; validateAll reports all', () {
      const v = CompositeValidator<String>([
        RequiredRule(),
        MinLengthRule(5),
        MaxLengthRule(3),
      ]);
      expect(_code(v.validate('')), ValidationCode.required);
      expect(_code(v.validate('abcd')), ValidationCode.tooShort);
      expect(v.validate('abcd')!.params['min'], 5);
      expect(v.validateAll('abcd').length, 2); // too short AND too long
    });
    test('digits: Arabic-Indic and Persian become Latin', () {
      expect(DigitNormalizer.toLatin('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(DigitNormalizer.toLatin('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(DigitNormalizer.digitsOnly('٠٧٩-١٢٣ 45'), '07912345');
    });
  });

  group('name', () {
    final v = NameValidator();
    test('valid', () {
      for (final n in [
        'Ali',
        'أحمد محمد',
        'سارة أحمد  العلي', // extra spaces are collapsed
        "O'Brien Smith",
        'Anne-Marie',
        'Dr. Omar',
      ]) {
        expect(v.validate(n), isNull, reason: n);
      }
    });
    test('invalid', () {
      expect(_code(v.validate('')), ValidationCode.required);
      expect(_code(v.validate('   ')), ValidationCode.required);
      expect(_code(v.validate('A')), ValidationCode.tooShort);
      expect(_code(v.validate('A' * 51)), ValidationCode.tooLong);
      expect(_code(v.validate('Ali123')), ValidationCode.invalidCharacters);
      expect(_code(v.validate('Ali@home')), ValidationCode.invalidCharacters);
      expect(_code(v.validate('-Ali')), ValidationCode.invalidCharacters);
      expect(_code(v.validate('Aaaali')), ValidationCode.repeatedCharacters);
    });
  });

  group('email', () {
    final v = EmailValidator();
    test('valid', () {
      for (final e in [
        'a@b.co',
        'sara.ahmed+tag@example.com',
        'USER@Example.COM',
        "o'brien@mail.example.org",
        'x_y-z@sub.domain.example.io',
      ]) {
        expect(v.validate(e), isNull, reason: e);
      }
    });
    test('invalid', () {
      for (final e in [
        'nope',
        'a@b',
        'a@@b.com',
        '@b.com',
        'a@.com',
        'a@b..com',
        'a..b@c.com',
        '.a@c.com',
        'a.@c.com',
        'a@-b.com',
        'a@b-.com',
        'a@b.c',
        'a@b.123',
        'a b@c.com',
        'a@b .com',
      ]) {
        expect(v.validate(e), isNotNull, reason: e);
      }
      expect(_code(v.validate('')), ValidationCode.required);
      expect(
        _code(v.validate('${'a' * 65}@b.com')),
        ValidationCode.invalidFormat,
      );
      expect(_code(v.validate('a@${'b' * 250}.com')), ValidationCode.tooLong);
    });
  });

  group('password (sign-up policy)', () {
    final v = PasswordValidator();
    test('accepts strong passwords', () {
      for (final p in ['Str0ng!Pass#9', 'Tr33-House&Lamp', 'مرحبا_Zx9\$kQ']) {
        expect(v.validate(p), isNull, reason: p);
      }
    });
    test('each rule has its own error', () {
      expect(_code(v.validate('')), ValidationCode.required);
      expect(_code(v.validate('Ab1!')), ValidationCode.tooShort);
      expect(_code(v.validate('A' * 65)), ValidationCode.tooLong);
      expect(_code(v.validate('Str0ng! Pass')), ValidationCode.hasWhitespace);
      expect(_code(v.validate('str0ng!pass#')), ValidationCode.noUppercase);
      expect(_code(v.validate('STR0NG!PASS#')), ValidationCode.noLowercase);
      expect(_code(v.validate('Strong!Pass#')), ValidationCode.noDigit);
      expect(_code(v.validate('Str0ngPass99')), ValidationCode.noSpecialChar);
    });
    test('rejects common, sequential and repeated passwords', () {
      expect(_code(v.validate('Password1!')), ValidationCode.commonPassword);
      expect(_code(v.validate('P@ssw0rd')), ValidationCode.commonPassword);
      expect(_code(v.validate('Qwerty123!')), ValidationCode.commonPassword);
      expect(
        _code(v.validate('Zx9!abcdKq')),
        ValidationCode.sequentialCharacters,
      );
      expect(
        _code(v.validate('Zx9!Kq4321')),
        ValidationCode.sequentialCharacters,
      );
      expect(
        _code(v.validate('Zx9!Kqqq#W')),
        ValidationCode.repeatedCharacters,
      );
    });
    test('rejects passwords built from personal data', () {
      final p = PasswordValidator(
        personalData: ['Sara', 'sara.ahmed', '791234567'],
      );
      expect(
        _code(p.validate('mySara#Zx9Kq')),
        ValidationCode.containsPersonalInfo,
      );
      expect(
        _code(p.validate('Zx#791234567Kq')),
        ValidationCode.containsPersonalInfo,
      );
      expect(p.validate('Zx#Kq9!Lmop'), isNull);
    });
    test('unmet() lists every missing requirement', () {
      final codes = v.unmet('abc').map((e) => e.code).toSet();
      expect(
        codes,
        containsAll({
          ValidationCode.tooShort,
          ValidationCode.noUppercase,
          ValidationCode.noDigit,
          ValidationCode.noSpecialChar,
        }),
      );
    });
    test('login only requires a password to be present', () {
      const l = LoginPasswordValidator();
      expect(l.validate('123456'), isNull);
      expect(_code(l.validate('')), ValidationCode.required);
    });
    test('strength estimate', () {
      const e = PasswordStrengthEstimator();
      expect(e.estimate('abc'), PasswordStrength.weak);
      expect(e.estimate('Password1!'), PasswordStrength.weak); // common
      expect(e.estimate('Zx9!Kq4w'), PasswordStrength.medium);
      expect(e.estimate('Tr33-House&Lamp9'), PasswordStrength.strong);
    });
  });

  group('otp', () {
    final v = OtpValidator();
    test('4 digits only (any digit script)', () {
      expect(v.validate('5991'), isNull);
      expect(v.validate('٥٩٩١'), isNull);
      expect(_code(v.validate('')), ValidationCode.required);
      expect(_code(v.validate('599')), ValidationCode.wrongLength);
      expect(_code(v.validate('59911')), ValidationCode.wrongLength);
      expect(_code(v.validate('59a1')), ValidationCode.invalidCharacters);
    });
  });

  group('phone numbers per country (mobile only)', () {
    const v = LibPhoneNumberValidator();
    PhoneNumber p(String iso, String national) {
      final c = Countries.byIso(iso);
      return PhoneNumber(
        isoCode: iso,
        dialCode: c.dialCode,
        national: national,
      );
    }

    // Real-format mobile numbers from each country's numbering plan.
    const mobiles = {
      'JO': ['0791234567', '0781234567', '0771234567', '791234567'],
      'SA': ['0512345678', '0551234567', '591234567'],
      'EG': ['01012345678', '01112345678', '01212345678', '01512345678'],
      'AE': ['0501234567', '0551234567'],
      'KW': ['51234567', '65123456', '90123456'],
      'QA': ['33123456', '55123456'],
      'BH': ['36001234', '39123456'],
      'OM': ['92123456', '71234567'],
      'LB': ['03123456', '71123456'],
      'IQ': ['07901234567', '07501234567'],
      'MA': ['0612345678', '0712345678'],
      'DZ': ['0551234567', '0661234567'],
      'TN': ['20123456', '50123456'],
      'LY': ['0912345678'],
      'SD': ['0912345678'],
      'SY': ['0944123456'],
      'YE': ['712345678'],
      'PS': ['0599123456'],
    };

    test('valid mobile numbers are accepted', () {
      mobiles.forEach((iso, numbers) {
        for (final n in numbers) {
          expect(v.validate(p(iso, n)), isNull, reason: '$iso $n');
        }
      });
    });

    test('Arabic-Indic digits are accepted', () {
      expect(v.validate(p('JO', '٠٧٩١٢٣٤٥٦٧')), isNull);
      expect(v.validate(p('SA', '٠٥١٢٣٤٥٦٧٨')), isNull);
    });

    test('empty / too short / too long / wrong prefix', () {
      expect(_code(v.validate(p('JO', ''))), ValidationCode.required);
      expect(_code(v.validate(p('JO', '   '))), ValidationCode.required);
      expect(_code(v.validate(p('JO', '079123'))), ValidationCode.invalidPhone);
      expect(
        _code(v.validate(p('JO', '07912345678'))),
        ValidationCode.invalidPhone,
      );
      expect(
        _code(v.validate(p('JO', '0601234567'))),
        ValidationCode.invalidPhone,
      );
      expect(
        _code(v.validate(p('SA', '0412345678'))),
        ValidationCode.invalidPhone,
      );
      expect(
        _code(v.validate(p('EG', '01312345678'))),
        ValidationCode.invalidPhone,
      );
    });

    test('a number valid in another country is rejected', () {
      // Saudi mobile typed with Jordan selected, and vice versa.
      expect(v.validate(p('JO', '0512345678')), isNotNull);
      expect(v.validate(p('SA', '0791234567')), isNotNull);
      expect(v.validate(p('EG', '0791234567')), isNotNull);
    });

    test('landlines are rejected as "not a mobile"', () {
      expect(
        _code(v.validate(p('JO', '0701234567'))),
        ValidationCode.notMobileNumber,
      );
      expect(
        _code(v.validate(p('SA', '0112345678'))),
        ValidationCode.notMobileNumber,
      );
      expect(
        _code(v.validate(p('EG', '0223456789'))),
        ValidationCode.notMobileNumber,
      );
    });

    test('every country in the list can be validated without crashing', () {
      for (final c in kCountries) {
        final r = v.validate(
          PhoneNumber(
            isoCode: c.isoCode,
            dialCode: c.dialCode,
            national: '123',
          ),
        );
        expect(r, isNotNull, reason: c.isoCode); // "123" is never valid
      }
    });
  });
}
