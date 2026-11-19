import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/core/validation/validation_error.dart';
import 'package:dr_jabel/features/address/domain/entities/address.dart';
import 'package:dr_jabel/features/address/domain/entities/address_type.dart';
import 'package:dr_jabel/features/address/domain/entities/delivery_location.dart';
import 'package:dr_jabel/features/address/domain/entities/geo_point.dart';
import 'package:dr_jabel/features/address/domain/validators/address_form_validators.dart';
import 'package:dr_jabel/features/address/data/models/address_model.dart';
import 'package:dr_jabel/features/address/presentation/cubit/address_form_cubit.dart';
import 'package:dr_jabel/features/auth/data/validators/lib_phone_number_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/email_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/name_validator.dart';
import 'package:dr_jabel/features/auth/domain/validators/otp_validator.dart';
import 'package:dr_jabel/features/legal/data/datasources/legal_data_source.dart';
import 'package:dr_jabel/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:dr_jabel/features/legal/domain/entities/legal_document.dart';
import 'package:dr_jabel/features/payment_cards/data/datasources/payment_cards_local_data_source.dart';
import 'package:dr_jabel/features/payment_cards/data/repositories/payment_cards_repository_impl.dart';
import 'package:dr_jabel/features/payment_cards/domain/entities/payment_card.dart';
import 'package:dr_jabel/features/payment_cards/domain/usecases/payment_cards_use_cases.dart';
import 'package:dr_jabel/features/payment_cards/domain/validators/card_validators.dart';
import 'package:dr_jabel/features/payment_cards/presentation/card_formatters.dart';
import 'package:dr_jabel/features/payment_cards/presentation/cubit/add_card_cubit.dart';
import 'package:dr_jabel/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:dr_jabel/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dr_jabel/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:dr_jabel/features/profile/domain/entities/user_profile.dart';
import 'package:dr_jabel/features/profile/domain/usecases/profile_use_cases.dart';
import 'package:dr_jabel/features/profile/presentation/cubit/edit_phone_cubit.dart';
import 'package:dr_jabel/features/profile/presentation/cubit/edit_text_cubit.dart';
import 'package:dr_jabel/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:dr_jabel/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:dr_jabel/features/settings/domain/usecases/settings_use_cases.dart';
import 'package:dr_jabel/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:dr_jabel/features/support/data/models/store_info_model.dart';
import 'package:dr_jabel/features/support/domain/entities/store_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user =
    '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":"ahmad@example.com"}';

Future<SharedPrefsStorage> _storage([Map<String, Object> initial = const {}]) {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPrefsStorage.create();
}

void main() {
  group('profile', () {
    Future<(ProfileRepositoryImpl, SharedPrefsStorage)> make([
      Map<String, Object>? initial,
    ]) async {
      final storage = await _storage(
        initial ?? {StorageKeys.authToken: 't', StorageKeys.authUser: _user},
      );
      return (
        ProfileRepositoryImpl(
          StorageProfileLocalDataSource(storage),
          const MockProfileRemoteDataSource(latency: Duration.zero),
        ),
        storage,
      );
    }

    test('reads the signed-in user; nobody signed in -> not found', () async {
      final (repo, _) = await make();
      final profile = ((await repo.getProfile()) as Success<UserProfile>).data;
      expect(profile.name, 'Ahmad Ali');
      expect(profile.phone, '+962791234567');
      expect(profile.email, 'ahmad@example.com');
      expect(profile.gender, isNull);
      expect(profile.birthDate, isNull);

      final (empty, _) = await make({});
      expect(
        ((await empty.getProfile()) as Err<UserProfile>).failure,
        isA<NotFoundFailure>(),
      );
    });

    test(
      'changes are saved where the auth user lives, so everyone sees them',
      () async {
        final (repo, storage) = await make();
        await repo.updateName('Sara Ali');
        await repo.updateEmail('sara@example.com');
        await repo.updateGender(Gender.female);
        await repo.updateBirthDate(DateTime(1995, 9, 27));
        final profile =
            ((await repo.getProfile()) as Success<UserProfile>).data;
        expect(profile.name, 'Sara Ali');
        expect(profile.email, 'sara@example.com');
        expect(profile.gender, Gender.female);
        expect(profile.birthDate, DateTime(1995, 9, 27));
        expect(storage.getString(StorageKeys.authUser), contains('Sara Ali'));
        // the token is untouched
        expect(storage.getString(StorageKeys.authToken), 't');
        // clearing the extras
        await repo.updateGender(null);
        await repo.updateBirthDate(null);
        final cleared =
            ((await repo.getProfile()) as Success<UserProfile>).data;
        expect(cleared.gender, isNull);
        expect(cleared.birthDate, isNull);
      },
    );

    test('phone change: right code changes it, wrong code does not', () async {
      final (repo, _) = await make();
      expect(
        await repo.requestPhoneChange('+962781234567'),
        isA<Success<void>>(),
      );
      final wrong = await repo.confirmPhoneChange('+962781234567', '0000');
      expect((wrong as Err<UserProfile>).failure, isA<InvalidOtpFailure>());
      expect(
        ((await repo.getProfile()) as Success<UserProfile>).data.phone,
        '+962791234567',
      );
      final right = await repo.confirmPhoneChange('+962781234567', '5991');
      expect((right as Success<UserProfile>).data.phone, '+962781234567');
    });

    test(
      'EditTextCubit: error only after the first try, then live; no-op when unchanged',
      () async {
        final (repo, _) = await make();
        final cubit = EditTextCubit<UserProfile>(
          initial: 'Ahmad Ali',
          validator: NameValidator(),
          normalize: NameValidator.normalize,
          save: UpdateName(repo).call,
        );
        cubit.changedTo('A');
        expect(cubit.state.error, isNull); // typing alone shows nothing
        await cubit.submit();
        expect(cubit.state.error?.code, ValidationCode.tooShort);
        cubit.changedTo('Ahmad  Ali 5');
        expect(
          cubit.state.error?.code,
          ValidationCode.invalidCharacters,
        ); // live now
        cubit.changedTo('Ahmad Ali');
        await cubit.submit(); // same as saved: just leaves
        expect(cubit.state.saved, isTrue);
        expect(cubit.changed, isFalse);

        final other = EditTextCubit<UserProfile>(
          initial: 'Ahmad Ali',
          validator: NameValidator(),
          normalize: NameValidator.normalize,
          save: UpdateName(repo).call,
        );
        other.changedTo('  Sara   Omar ');
        await other.submit();
        expect(other.state.saved, isTrue);
        expect(
          ((await repo.getProfile()) as Success<UserProfile>).data.name,
          'Sara Omar', // trimmed and collapsed
        );
        await cubit.close();
        await other.close();
      },
    );

    test('email validation', () {
      final v = EmailValidator();
      expect(v.validate('a@b.co'), isNull);
      expect(v.validate('nope')?.code, ValidationCode.invalidFormat);
      expect(v.validate('')?.code, ValidationCode.required);
    });

    test(
      'EditPhoneCubit: validation, same number, code step, wrong and right code',
      () async {
        final (repo, _) = await make();
        final cubit = EditPhoneCubit(
          currentPhone: '+962791234567',
          phoneValidator: const LibPhoneNumberValidator(),
          otpValidator: OtpValidator(),
          requestChange: RequestPhoneChange(repo),
          confirmChange: ConfirmPhoneChange(repo),
        );
        await cubit.sendCode();
        expect(cubit.state.numberError?.code, ValidationCode.required);

        cubit.numberChanged('0791234567'); // the number it already has
        await cubit.sendCode();
        expect(cubit.state.sameNumber, isTrue);
        expect(cubit.state.step, EditPhoneStep.number);

        cubit.numberChanged('0781234567');
        expect(cubit.state.sameNumber, isFalse);
        await cubit.sendCode();
        expect(cubit.state.step, EditPhoneStep.code);
        expect(cubit.newNumber.e164, '+962781234567');

        await cubit.verify('1234');
        expect(cubit.state.wrongCode, isTrue);
        cubit.codeChanged();
        expect(cubit.state.wrongCode, isFalse);
        await cubit.verify('٥٩٩١'); // Arabic digits are accepted
        expect(cubit.state.saved, isTrue);
        expect(
          ((await repo.getProfile()) as Success<UserProfile>).data.phone,
          '+962781234567',
        );
        await cubit.close();
      },
    );

    test('ProfileCubit loads and saves gender and birth date', () async {
      final (repo, _) = await make();
      final cubit = ProfileCubit(
        getProfile: GetProfile(repo),
        updateGender: UpdateGender(repo),
        updateBirthDate: UpdateBirthDate(repo),
      );
      expect(cubit.state.status, ProfileStatus.loading);
      await cubit.load();
      expect(cubit.state.profile?.name, 'Ahmad Ali');
      await cubit.setGender(Gender.male);
      expect(cubit.state.profile?.gender, Gender.male);
      await cubit.setBirthDate(DateTime(2000, 1, 2));
      expect(cubit.state.profile?.birthDate, DateTime(2000, 1, 2));
      expect(cubit.state.saving, isFalse);
      await cubit.close();

      final (empty, _) = await make({});
      final failed = ProfileCubit(
        getProfile: GetProfile(empty),
        updateGender: UpdateGender(empty),
        updateBirthDate: UpdateBirthDate(empty),
      );
      await failed.load();
      expect(failed.state.status, ProfileStatus.failed);
      await failed.close();
    });
  });

  group('payment cards', () {
    const validVisa = '4242 4242 4242 4242';
    final now = DateTime(2026, 11, 10);

    test('Luhn and brands', () {
      expect(CardNumberValidator.passesLuhn('4242424242424242'), isTrue);
      expect(CardNumberValidator.passesLuhn('4242424242424241'), isFalse);
      expect(CardBrand.of('4242424242424242'), CardBrand.visa);
      expect(CardBrand.of('5555555555554444'), CardBrand.mastercard);
      expect(CardBrand.of('2223000048400011'), CardBrand.mastercard);
      expect(CardBrand.of('3782822463100005'), CardBrand.other);
      expect(CardBrand.of(''), CardBrand.other);
    });

    test('number validator', () {
      const v = CardNumberValidator();
      expect(v.validate(validVisa), isNull);
      expect(v.validate('')?.code, ValidationCode.required);
      expect(v.validate('4242 4242')?.code, ValidationCode.wrongLength);
      expect(
        v.validate('4242 4242 4242 4241')?.code,
        ValidationCode.invalidCardNumber,
      );
    });

    test(
      'expiry validator: format, month, expired, this month is still fine',
      () {
        final v = CardExpiryValidator(now: () => now);
        expect(v.validate('11/26'), isNull);
        expect(v.validate('12/26'), isNull);
        expect(v.validate('01/30'), isNull);
        expect(v.validate('10/26')?.code, ValidationCode.cardExpired);
        expect(v.validate('12/25')?.code, ValidationCode.cardExpired);
        expect(v.validate('13/27')?.code, ValidationCode.invalidFormat);
        expect(v.validate('00/27')?.code, ValidationCode.invalidFormat);
        expect(v.validate('1/27')?.code, ValidationCode.invalidFormat);
        expect(v.validate('')?.code, ValidationCode.required);
      },
    );

    test('cvv and nickname validators', () {
      const cvv = CvvValidator();
      expect(cvv.validate('123'), isNull);
      expect(cvv.validate('12')?.code, ValidationCode.wrongLength);
      expect(cvv.validate('12a')?.code, ValidationCode.invalidCharacters);
      expect(cvv.validate('')?.code, ValidationCode.required);
      const nick = CardNicknameValidator(maxLength: 5);
      expect(nick.validate(''), isNull); // optional
      expect(nick.validate('abcde'), isNull);
      expect(nick.validate('abcdef')?.code, ValidationCode.tooLong);
    });

    test('formatters group the number and add the expiry slash', () {
      const number = CardNumberFormatter();
      TextEditingValue type(TextInputFormatter f, String text) =>
          f.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: text),
          );
      expect(type(number, '4242424242424242').text, '4242 4242 4242 4242');
      expect(type(number, '٤٢٤٢').text, '4242'); // Arabic digits
      expect(type(number, '42424242424242429999').text, '4242 4242 4242 4242');
      expect(type(number, '12345').text, '1234 5');
      const expiry = CardExpiryFormatter();
      expect(type(expiry, '1126').text, '11/26');
      expect(type(expiry, '11').text, '11/');
      expect(type(expiry, '1').text, '1');
      // deleting the slash removes the month digit before it as well
      expect(
        expiry
            .formatEditUpdate(
              const TextEditingValue(text: '11/'),
              const TextEditingValue(text: '11'),
            )
            .text,
        '11',
      );
    });

    test('repository keeps the last four digits only', () async {
      final storage = await _storage();
      var n = 0;
      final repo = PaymentCardsRepositoryImpl(
        StoragePaymentCardsLocalDataSource(storage),
        newId: () => 'c${n++}',
      );
      final added =
          ((await repo.addCard(
                    const NewCard(
                      number: '4242424242424242',
                      expiry: '12/30',
                      cvv: '123',
                    ),
                  ))
                  as Success<PaymentCard>)
              .data;
      expect(added.last4, '4242');
      expect(added.brand, CardBrand.visa);
      final raw = storage.getString(StorageKeys.paymentCards)!;
      expect(raw, isNot(contains('4242424242424242')));
      expect(raw, isNot(contains('123"')));

      await repo.addCard(
        const NewCard(number: '5555555555554444', expiry: '01/31', cvv: '999'),
      );
      expect(
        ((await repo.getCards()) as Success<List<PaymentCard>>).data,
        hasLength(2),
      );
      await repo.setNickname('c0', '  Work  ');
      expect(
        ((await repo.getCards()) as Success<List<PaymentCard>>)
            .data
            .first
            .nickname,
        'Work',
      );
      expect(
        ((await repo.setNickname('nope', 'x')) as Err<PaymentCard>).failure,
        isA<NotFoundFailure>(),
      );
      await repo.deleteCard('c0');
      final left = ((await repo.getCards()) as Success<List<PaymentCard>>).data;
      expect(left.single.last4, '4444');
    });

    test('corrupted storage reads as no cards', () async {
      final storage = await _storage({StorageKeys.paymentCards: '{{'});
      expect(StoragePaymentCardsLocalDataSource(storage).read(), isEmpty);
      final partial = await _storage({
        StorageKeys.paymentCards:
            '[{"id":"a","last4":"12"},{"id":"b","last4":"4242","brand":"visa","expiry":"01/30"}]',
      });
      expect(StoragePaymentCardsLocalDataSource(partial).read().single.id, 'b');
    });

    test(
      'AddCardCubit: errors after the first try, brand follows the number, saves',
      () async {
        final storage = await _storage();
        final repo = PaymentCardsRepositoryImpl(
          StoragePaymentCardsLocalDataSource(storage),
          newId: () => 'x1',
        );
        final cubit = AddCardCubit(
          addCard: AddPaymentCard(repo),
          expiryValidator: CardExpiryValidator(now: () => now),
        );
        cubit.numberChanged('4242');
        expect(cubit.state.brand, CardBrand.visa);
        expect(cubit.state.numberError, isNull);
        await cubit.submit();
        expect(cubit.state.numberError?.code, ValidationCode.wrongLength);
        expect(cubit.state.expiryError?.code, ValidationCode.required);
        expect(cubit.state.cvvError?.code, ValidationCode.required);
        expect(cubit.state.saved, isNull);

        cubit.numberChanged(validVisa);
        cubit.expiryChanged('10/20');
        cubit.cvvChanged('123');
        expect(cubit.state.numberError, isNull);
        expect(cubit.state.expiryError?.code, ValidationCode.cardExpired);
        cubit.expiryChanged('12/30');
        await cubit.submit();
        expect(cubit.state.saved?.last4, '4242');
        expect(cubit.state.saving, isFalse);
        await cubit.close();
      },
    );
  });

  group('address form', () {
    const location = DeliveryLocation(
      point: GeoPoint(31.95, 35.91),
      label: 'King Hussein St',
      details: 'Abdali, Amman',
    );

    AddressFormCubit make({Address? editing}) => AddressFormCubit(
      location: location,
      editing: editing,
      validators: AddressFormValidators(),
      phoneValidator: const LibPhoneNumberValidator(),
      newId: () => 'new-id',
      defaultTitle: (type) => 'default-${type.name}',
    );

    test('the name follows the type until the customer types one', () {
      final cubit = make();
      expect(cubit.state.type, AddressType.house);
      expect(cubit.state.title, 'default-house');
      cubit.typeChanged(AddressType.office);
      expect(cubit.state.title, 'default-office');
      cubit.changed(AddressField.title, 'My shop');
      cubit.typeChanged(AddressType.apartment);
      expect(cubit.state.title, 'My shop'); // typed names stay
    });

    test('fields per type', () {
      expect(AddressFormState.fieldsFor(AddressType.house), [
        AddressField.unit,
      ]);
      expect(AddressFormState.fieldsFor(AddressType.apartment), [
        AddressField.building,
        AddressField.floor,
        AddressField.unit,
      ]);
      expect(AddressFormState.fieldsFor(AddressType.other), [
        AddressField.building,
      ]);
    });

    test('house: needs a number and a valid phone; builds the address', () {
      final cubit = make();
      cubit.submit();
      expect(cubit.state.saved, isNull);
      expect(
        cubit.state.errors.keys,
        containsAll([AddressField.unit, AddressField.phone]),
      );
      expect(cubit.state.errors.containsKey(AddressField.floor), isFalse);

      cubit.changed(AddressField.unit, '12');
      cubit.changed(AddressField.phone, '٠٧٩١٢٣٤٥٦٧'); // Arabic digits
      cubit.changed(AddressField.instructions, '  bell is broken ');
      expect(cubit.state.errors, isEmpty); // live after the first try
      cubit.submit();
      final address = cubit.state.saved!;
      expect(address.id, 'new-id');
      expect(address.title, 'default-house');
      expect(address.details, 'Abdali, Amman');
      expect(address.point, location.point);
      expect(address.phone, '+962791234567');
      expect(address.unit, '12');
      expect(address.building, '');
      expect(address.instructions, 'bell is broken');
      expect(address.type, AddressType.house);
    });

    test(
      'apartment needs building, floor and number; a field of another type is dropped',
      () {
        final cubit = make();
        cubit.typeChanged(AddressType.apartment);
        cubit.changed(AddressField.phone, '0791234567');
        cubit.submit();
        expect(
          cubit.state.errors.keys,
          containsAll([
            AddressField.building,
            AddressField.floor,
            AddressField.unit,
          ]),
        );
        cubit.changed(AddressField.building, 'Tower A');
        cubit.changed(AddressField.floor, '3');
        cubit.changed(AddressField.unit, '7');
        cubit.submit();
        expect(cubit.state.saved?.building, 'Tower A');
        expect(cubit.state.saved?.floor, '3');
        expect(cubit.state.saved?.unit, '7');

        // typed for an apartment, then switched to a house: floor/building dropped
        final other = make();
        other.typeChanged(AddressType.apartment);
        other.changed(AddressField.building, 'Tower A');
        other.changed(AddressField.floor, '3');
        other.changed(AddressField.unit, '7');
        other.typeChanged(AddressType.house);
        other.changed(AddressField.phone, '0791234567');
        other.submit();
        expect(other.state.saved?.building, '');
        expect(other.state.saved?.floor, '');
        expect(other.state.saved?.unit, '7');
      },
    );

    test('name rules and a phone that is not a mobile', () {
      final cubit = make();
      cubit.changed(AddressField.title, 'x');
      cubit.changed(AddressField.unit, '1');
      cubit.changed(AddressField.phone, '0641234567'); // a landline
      cubit.submit();
      expect(
        cubit.state.errors[AddressField.title]?.code,
        ValidationCode.tooShort,
      );
      expect(cubit.state.errors[AddressField.phone], isNotNull);
      cubit.changed(AddressField.title, 'y' * 31);
      expect(
        cubit.state.errors[AddressField.title]?.code,
        ValidationCode.tooLong,
      );
    });

    test('editing: starts from the address, keeps its id and place', () {
      const old = Address(
        id: 'a1',
        title: 'Villa',
        details: 'Tabarbour',
        point: GeoPoint(31.98, 35.98),
        type: AddressType.apartment,
        phone: '+962791234567',
        building: 'Tower B',
        floor: '2',
        unit: '4',
        instructions: 'call me',
      );
      final cubit = make(editing: old);
      expect(cubit.state.type, AddressType.apartment);
      expect(cubit.state.title, 'Villa');
      expect(cubit.state.country.dialCode, '962');
      expect(cubit.phoneText, '791234567');
      expect(cubit.valueOf(AddressField.building), 'Tower B');
      cubit.changed(AddressField.floor, '5');
      cubit.submit();
      final saved = cubit.state.saved!;
      expect(saved.id, 'a1');
      expect(saved.floor, '5');
      expect(saved.building, 'Tower B');
      expect(saved.phone, '+962791234567');
      expect(saved.title, 'Villa');
    });

    test('Address JSON keeps the new fields; old records still load', () {
      const a = Address(
        id: 'z',
        title: 't',
        details: 'd',
        point: GeoPoint(1, 2),
        building: 'b',
        floor: 'f',
        unit: 'u',
        instructions: 'i',
      );
      expect(AddressModel.tryFromJson(AddressModel.toJson(a)), a);
      final old = AddressModel.tryFromJson({'id': 'o', 'lat': 1, 'lng': 2})!;
      expect(old.building, '');
      expect(old.unit, '');
    });
  });

  group('store info and links', () {
    test('settings -> channels and social links; junk is ignored', () {
      final info = StoreInfoModel.fromSettings({
        'whatsapp': 'https://wa.me/962791234567',
        'support_email': 'help@jabel.com',
        'support_phone': '8001240198',
        'social_links': {
          'facebook': 'https://facebook.com/jabel',
          'instagram': 'not a link',
          'x_twitter': 'https://x.com/jabel',
        },
      });
      expect(info.whatsappNumber, '962791234567');
      expect(info.email, 'help@jabel.com');
      expect(info.phone, '8001240198');
      expect(info.social.keys, [SocialNetwork.facebook, SocialNetwork.x]);
      expect(
        info.contactUri(ContactChannel.whatsapp).toString(),
        'https://wa.me/962791234567',
      );
      expect(
        info.contactUri(ContactChannel.email).toString(),
        'mailto:help@jabel.com',
      );
      expect(
        info.contactUri(ContactChannel.phone).toString(),
        'tel:8001240198',
      );
      expect(
        info.socialUri(SocialNetwork.facebook).toString(),
        'https://facebook.com/jabel',
      );
      expect(info.socialUri(SocialNetwork.tiktok), isNull);

      final empty = StoreInfoModel.fromSettings({
        'support_email': 'broken',
        'support_phone': 'abc',
        'whatsapp': '12',
      });
      expect(empty, const StoreInfo());
      expect(empty.has(ContactChannel.email), isFalse);
      expect(empty.contactUri(ContactChannel.phone), isNull);
    });

    test(
      'the email falls back to the plain `email` setting; phone to the contact phone',
      () {
        final info = StoreInfoModel.fromSettings({
          'email': 'info@jabel.com',
          'site_contact_phone': '+962 6 123 4567',
        });
        expect(info.email, 'info@jabel.com');
        expect(info.phone, '+96261234567');
      },
    );
  });

  group('legal texts', () {
    test(
      'both documents in both languages, numbered sections, not empty',
      () async {
        const repo = LegalRepositoryImpl(StaticLegalDataSource());
        for (final type in LegalDocumentType.values) {
          for (final lang in ['ar', 'en']) {
            final doc =
                ((await repo.getDocument(type, lang)) as Success<LegalDocument>)
                    .data;
            expect(doc.type, type);
            expect(doc.title, isNotEmpty);
            expect(doc.intro, isNotEmpty);
            expect(doc.sections.length, greaterThanOrEqualTo(6));
            for (final s in doc.sections) {
              expect(s.heading, isNotEmpty);
              expect(s.body.length, greaterThan(20));
            }
          }
        }
        final ar =
            ((await repo.getDocument(LegalDocumentType.terms, 'ar'))
                    as Success<LegalDocument>)
                .data;
        expect(ar.title, 'الشروط والأحكام');
        final en =
            ((await repo.getDocument(LegalDocumentType.privacy, 'en'))
                    as Success<LegalDocument>)
                .data;
        expect(en.title, 'Privacy policy');
        // the store is Jabel, not the old app
        expect(ar.sections.map((s) => s.body).join(), isNot(contains('هدايا')));
      },
    );
  });

  group('settings', () {
    test(
      'notifications default on, saved, and delete clears the account only',
      () async {
        final storage = await _storage({
          StorageKeys.authToken: 't',
          StorageKeys.authUser: _user,
          StorageKeys.profileExtras: '{}',
          StorageKeys.addresses: '[]',
          StorageKeys.deliverySelection: '{}',
          StorageKeys.paymentCards: '[]',
          StorageKeys.languageCode: 'en',
          StorageKeys.onboardingSeen: true,
        });
        final repo = SettingsRepositoryImpl(storage);
        final cubit = SettingsCubit(
          getNotifications: GetNotificationsEnabled(repo),
          setNotifications: SetNotificationsEnabled(repo),
          deleteAccount: DeleteAccount(repo),
        );
        await cubit.load();
        expect(cubit.state.notificationsEnabled, isTrue);
        await cubit.setNotifications(false);
        expect(cubit.state.notificationsEnabled, isFalse);
        expect(storage.getBool(StorageKeys.notificationsEnabled), isFalse);

        await cubit.deleteAccount();
        expect(cubit.state.deleted, isTrue);
        for (final key in [
          StorageKeys.authToken,
          StorageKeys.authUser,
          StorageKeys.profileExtras,
          StorageKeys.addresses,
          StorageKeys.deliverySelection,
          StorageKeys.paymentCards,
          StorageKeys.notificationsEnabled,
        ]) {
          expect(storage.containsKey(key), isFalse, reason: key);
        }
        // what is not the account's stays
        expect(storage.getString(StorageKeys.languageCode), 'en');
        expect(storage.getBool(StorageKeys.onboardingSeen), isTrue);
        await cubit.close();
      },
    );
  });
}
