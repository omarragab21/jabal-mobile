import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../auth/domain/entities/phone_number.dart';
import '../../../auth/domain/validators/digit_normalizer.dart';
import '../../../auth/domain/validators/phone_number_validator.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/address_type.dart';
import '../../domain/entities/delivery_location.dart';
import '../../domain/validators/address_form_validators.dart';

enum AddressField { title, phone, building, floor, unit, instructions }

class AddressFormState extends Equatable {
  AddressFormState({
    required this.type,
    required this.title,
    Country? country,
    this.errors = const {},
    this.saving = false,
    this.saved,
  }) : country = country ?? Countries.defaultCountry;

  final AddressType type;

  /// The name of the address; follows the type until the customer edits it.
  final String title;
  final Country country;
  final Map<AddressField, ValidationError> errors;
  final bool saving;

  /// Set once the form produced a valid [Address].
  final Address? saved;

  /// The fields shown for [type]: a house has a number; an apartment or an
  /// office has building, floor and number; anything else a description.
  static List<AddressField> fieldsFor(AddressType type) => switch (type) {
    AddressType.house => [AddressField.unit],
    AddressType.apartment || AddressType.office => [
      AddressField.building,
      AddressField.floor,
      AddressField.unit,
    ],
    AddressType.other => [AddressField.building],
  };

  AddressFormState copyWith({
    AddressType? type,
    String? title,
    Country? country,
    Map<AddressField, ValidationError>? errors,
    bool? saving,
    Address? saved,
  }) => AddressFormState(
    type: type ?? this.type,
    title: title ?? this.title,
    country: country ?? this.country,
    errors: errors ?? this.errors,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [type, title, country, errors, saving, saved];
}

/// The details of an address: type, name, phone, where exactly and notes for
/// the courier. Builds the [Address] when everything is valid.
class AddressFormCubit extends Cubit<AddressFormState> {
  AddressFormCubit({
    required this.location,
    required this.defaultTitle,
    required AddressFormValidators validators,
    required PhoneNumberValidator phoneValidator,
    required String Function() newId,
    this.editing,
  }) : _validators = validators,
       _phoneValidator = phoneValidator,
       _newId = newId,
       super(_initialState(editing, defaultTitle)) {
    final address = editing;
    if (address != null) {
      _values = {
        AddressField.title: address.title,
        AddressField.building: address.building,
        AddressField.floor: address.floor,
        AddressField.unit: address.unit,
        AddressField.instructions: address.instructions,
      };
      final (country, national) = _splitPhone(address.phone);
      _phoneText = national;
      emit(state.copyWith(country: country));
    }
  }

  /// The place on the map this address is for.
  final DeliveryLocation location;

  /// Name used until the customer types one, per type.
  final String Function(AddressType type) defaultTitle;

  /// The address being edited; null when it is new.
  final Address? editing;
  final AddressFormValidators _validators;
  final PhoneNumberValidator _phoneValidator;
  final String Function() _newId;

  Map<AddressField, String> _values = {};
  String _phoneText = '';
  bool _titleEdited = false;
  bool _submitted = false;

  static AddressFormState _initialState(
    Address? editing,
    String Function(AddressType) defaultTitle,
  ) => editing == null
      ? AddressFormState(
          type: AddressType.house,
          title: defaultTitle(AddressType.house),
        )
      : AddressFormState(type: editing.type, title: editing.title);

  /// `+962791234567` -> (Jordan, `791234567`).
  static (Country, String) _splitPhone(String e164) {
    if (!e164.startsWith('+')) return (Countries.defaultCountry, e164);
    final digits = e164.substring(1);
    final candidates = [...Countries.available]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in candidates) {
      if (digits.startsWith(country.dialCode)) {
        return (country, digits.substring(country.dialCode.length));
      }
    }
    return (Countries.defaultCountry, digits);
  }

  /// The typed number without the country code, for a prefilled field.
  String get phoneText => _phoneText;

  String valueOf(AddressField field) => _values[field] ?? '';

  PhoneNumber get _phone => PhoneNumber(
    isoCode: state.country.isoCode,
    dialCode: state.country.dialCode,
    national: DigitNormalizer.toLatin(_phoneText),
  );

  void typeChanged(AddressType type) {
    emit(
      state.copyWith(
        type: type,
        title: _titleEdited ? state.title : defaultTitle(type),
        errors: _submitted ? _validate(type, state.title) : const {},
      ),
    );
  }

  void countryChanged(Country country) {
    emit(state.copyWith(country: country));
    if (_submitted) emit(state.copyWith(errors: _validate()));
  }

  void changed(AddressField field, String value) {
    if (field == AddressField.phone) {
      _phoneText = value;
    } else {
      _values[field] = value;
    }
    if (field == AddressField.title) {
      _titleEdited = true;
      emit(state.copyWith(title: value));
    }
    if (_submitted) emit(state.copyWith(errors: _validate()));
  }

  Map<AddressField, ValidationError> _validate([
    AddressType? type,
    String? title,
  ]) {
    final t = type ?? state.type;
    final errors = <AddressField, ValidationError>{};
    void check(AddressField field, ValidationError? error) {
      if (error != null) errors[field] = error;
    }

    check(AddressField.title, _validators.title.validate(title ?? state.title));
    check(AddressField.phone, _phoneValidator.validate(_phone));
    for (final field in AddressFormState.fieldsFor(t)) {
      final value = valueOf(field);
      check(
        field,
        field == AddressField.building
            ? _validators.detail.validate(value)
            : _validators.number.validate(value),
      );
    }
    check(
      AddressField.instructions,
      _validators.instructions.validate(valueOf(AddressField.instructions)),
    );
    return errors;
  }

  void submit() {
    if (state.saving) return;
    _submitted = true;
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    final fields = AddressFormState.fieldsFor(state.type);
    String? shown(AddressField f) =>
        fields.contains(f) ? valueOf(f).trim() : '';
    final address = Address(
      id: editing?.id ?? _newId(),
      title: state.title.trim(),
      details: location.details.isEmpty ? location.label : location.details,
      point: location.point,
      type: state.type,
      phone: _phone.e164,
      building: shown(AddressField.building) ?? '',
      floor: shown(AddressField.floor) ?? '',
      unit: shown(AddressField.unit) ?? '',
      instructions: valueOf(AddressField.instructions).trim(),
    );
    emit(state.copyWith(errors: const {}, saved: address));
  }
}
