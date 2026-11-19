import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/network/api_client.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/address/data/datasources/address_local_data_source.dart';
import 'package:dr_jabel/features/address/data/datasources/google_places_remote_data_source.dart';
import 'package:dr_jabel/features/address/data/datasources/mock_places_remote_data_source.dart';
import 'package:dr_jabel/features/address/data/models/address_model.dart';
import 'package:dr_jabel/features/address/data/repositories/address_repository_impl.dart';
import 'package:dr_jabel/features/address/data/repositories/location_repository_impl.dart';
import 'package:dr_jabel/features/address/data/repositories/places_repository_impl.dart';
import 'package:dr_jabel/features/address/data/repositories/service_area_delivery_repository.dart';
import 'package:dr_jabel/features/address/domain/entities/address.dart';
import 'package:dr_jabel/features/address/domain/entities/address_type.dart';
import 'package:dr_jabel/features/address/domain/entities/delivery_location.dart';
import 'package:dr_jabel/features/address/domain/entities/delivery_zone.dart';
import 'package:dr_jabel/features/address/domain/entities/geo_point.dart';
import 'package:dr_jabel/features/address/domain/entities/place_info.dart';
import 'package:dr_jabel/features/address/domain/entities/place_suggestion.dart';
import 'package:dr_jabel/features/address/domain/usecases/address_use_cases.dart';
import 'package:dr_jabel/features/address/domain/usecases/place_use_cases.dart';
import 'package:dr_jabel/features/address/presentation/cubit/delivery_location_cubit.dart';
import 'package:dr_jabel/features/address/presentation/cubit/delivery_location_state.dart';
import 'package:dr_jabel/features/address/presentation/cubit/map_picker_cubit.dart';
import 'package:dr_jabel/features/address/presentation/cubit/map_picker_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_map.dart';

const _amman = GeoPoint(31.9539, 35.9106);
const _irbid = GeoPoint(32.5556, 35.8469);
const _home = Address(
  id: 'a1',
  title: 'My Home',
  details: '32, سهيل بن عمرو, طبربور',
  point: GeoPoint(31.9863, 35.9814),
  type: AddressType.apartment,
  phone: '079XXXXXXX',
);

/// An [ApiClient] that answers from a script and remembers the last call.
class _FakeApi implements ApiClient {
  _FakeApi(this.body);

  Object? body;
  String? path;
  Map<String, dynamic>? query;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    this.path = path;
    query = queryParameters;
    return body;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<SharedPrefsStorage> _storage([Map<String, Object> initial = const {}]) {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPrefsStorage.create();
}

void main() {
  group('GeoPoint, PlaceInfo, DeliveryZone', () {
    test('distance (haversine)', () {
      expect(_amman.distanceKmTo(_amman), 0);
      // Amman -> Irbid is about 67 km by air
      expect(_amman.distanceKmTo(_irbid), closeTo(67, 3));
      expect(
        _irbid.distanceKmTo(_amman),
        closeTo(_amman.distanceKmTo(_irbid), 1e-9),
      );
    });

    test('PlaceInfo splits at the first comma, Arabic or Latin', () {
      final ar = PlaceInfo.fromFormatted(
        'شارع الدفاع، إربد، مدينة الحسن للشباب',
      );
      expect(ar.headline, 'شارع الدفاع');
      expect(ar.details, 'إربد، مدينة الحسن للشباب');
      final en = PlaceInfo.fromFormatted('Al-Difaa St, Irbid, Jordan');
      expect(en.headline, 'Al-Difaa St');
      expect(en.details, 'Irbid, Jordan');
      final single = PlaceInfo.fromFormatted('  Amman ');
      expect(single.headline, 'Amman');
      expect(single.details, '');
      expect(single.fullText, 'Amman');
      expect(ar.fullText, 'شارع الدفاع، إربد، مدينة الحسن للشباب');
    });

    test('delivery zone: Amman yes, Irbid and Aqaba no', () async {
      const policy = ServiceAreaDeliveryRepository();
      expect(await policy.isDeliverable(_amman), isTrue);
      expect(
        await policy.isDeliverable(const GeoPoint(31.9863, 35.9814)),
        isTrue,
      );
      expect(await policy.isDeliverable(_irbid), isFalse);
      expect(
        await policy.isDeliverable(const GeoPoint(29.5321, 35.0063)),
        isFalse,
      );
      const wide = DeliveryZone(center: _amman, radiusKm: 100);
      expect(
        await const ServiceAreaDeliveryRepository(
          zones: [wide],
        ).isDeliverable(_irbid),
        isTrue,
      );
    });

    test('AddressType.parse falls back to other', () {
      expect(AddressType.parse('house'), AddressType.house);
      expect(AddressType.parse('castle'), AddressType.other);
      expect(AddressType.parse(null), AddressType.other);
    });
  });

  group('stored addresses', () {
    test('JSON round trip; unusable records are skipped', () async {
      final storage = await _storage();
      final local = StorageAddressLocalDataSource(storage);
      expect(local.readAddresses(), isEmpty);
      await local.writeAddresses([_home]);
      expect(local.readAddresses(), [_home]);

      expect(AddressModel.tryFromJson({'id': 'x'}), isNull); // no coordinates
      expect(AddressModel.tryFromJson({'lat': 1, 'lng': 2}), isNull); // no id
      expect(
        AddressModel.tryFromJson({'id': 'x', 'lat': 99, 'lng': 2}),
        isNull,
      );
      final loose = AddressModel.tryFromJson({
        'id': 7,
        'lat': '31.5',
        'lng': 35,
        'type': 'weird',
      })!;
      expect(loose.id, '7');
      expect(loose.point, const GeoPoint(31.5, 35));
      expect(loose.type, AddressType.other);
    });

    test('corrupted storage reads as empty instead of throwing', () async {
      final storage = await _storage({
        StorageKeys.addresses: 'not json',
        StorageKeys.deliverySelection: '{broken',
      });
      final local = StorageAddressLocalDataSource(storage);
      expect(local.readAddresses(), isEmpty);
      expect(local.readDeliveryLocation(), isNull);
    });

    test('repository: save, replace, delete and the delivery choice', () async {
      final repository = AddressRepositoryImpl(
        StorageAddressLocalDataSource(await _storage()),
      );
      Future<List<Address>> list() async =>
          ((await repository.getAddresses()) as Success<List<Address>>).data;
      Future<DeliveryLocation?> chosen() async =>
          ((await repository.getDeliveryLocation())
                  as Success<DeliveryLocation?>)
              .data;

      await repository.saveAddress(_home);
      await repository.saveAddress(_home.copyWith(title: 'Villa'));
      expect(await list(), hasLength(1));
      expect((await list()).single.title, 'Villa');

      await repository.setDeliveryLocation(DeliveryLocation.saved(_home));
      expect((await chosen())?.addressId, 'a1');
      // renaming the delivery address updates the choice too
      await repository.saveAddress(_home.copyWith(title: 'Renamed'));
      expect((await chosen())?.label, 'Renamed');

      await repository.deleteAddress('a1');
      expect(await list(), isEmpty);
      expect(await chosen(), isNull); // its delivery choice goes with it

      // an unsaved choice survives deleting unrelated addresses
      const unsaved = DeliveryLocation(point: _amman, label: 'x', details: 'y');
      await repository.setDeliveryLocation(unsaved);
      await repository.deleteAddress('nothing');
      expect(await chosen(), unsaved);
      await repository.setDeliveryLocation(null);
      expect(await chosen(), isNull);
    });
  });

  group('GooglePlacesRemoteDataSource', () {
    test('autocomplete: request and answer', () async {
      final api = _FakeApi({
        'status': 'OK',
        'predictions': [
          {'description': 'شارع الدفاع، إربد', 'place_id': 'p1'},
          {'description': 'no id'},
        ],
      });
      final remote = GooglePlacesRemoteDataSource(api, apiKey: 'KEY');
      final result = await remote.autocomplete('دفاع', 'ar');
      expect(result, [
        const PlaceSuggestion(placeId: 'p1', description: 'شارع الدفاع، إربد'),
      ]);
      expect(api.path, '/place/autocomplete/json');
      expect(api.query?['input'], 'دفاع');
      expect(api.query?['language'], 'ar');
      expect(api.query?['components'], 'country:jo');
      expect(api.query?['key'], 'KEY');
    });

    test('Google answers 200 with a status: denied becomes an error', () async {
      final remote = GooglePlacesRemoteDataSource(
        _FakeApi({'status': 'REQUEST_DENIED', 'error_message': 'bad key'}),
      );
      await expectLater(
        remote.autocomplete('x', 'ar'),
        throwsA(
          isA<ServerException>().having((e) => e.message, 'message', 'bad key'),
        ),
      );
      expect(
        await GooglePlacesRemoteDataSource(
          _FakeApi({'status': 'ZERO_RESULTS'}),
        ).autocomplete('x', 'ar'),
        isEmpty,
      );
    });

    test('place location', () async {
      final api = _FakeApi({
        'status': 'OK',
        'result': {
          'geometry': {
            'location': {'lat': 32.5, 'lng': 35.8},
          },
        },
      });
      expect(
        await GooglePlacesRemoteDataSource(api).placeLocation('p1'),
        const GeoPoint(32.5, 35.8),
      );
      expect(api.query?['place_id'], 'p1');
      await expectLater(
        GooglePlacesRemoteDataSource(
          _FakeApi({'status': 'OK', 'result': {}}),
        ).placeLocation('p1'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('reverse geocode skips plus codes and handles no results', () async {
      final api = _FakeApi({
        'status': 'OK',
        'results': [
          {'formatted_address': '8G5P+XX Amman, Jordan'},
          {'formatted_address': 'سهيل بن عمرو، طبربور، عمّان'},
        ],
      });
      final info = await GooglePlacesRemoteDataSource(
        api,
      ).reverseGeocode(_amman, 'ar');
      expect(info?.headline, 'سهيل بن عمرو');
      expect(api.query?['latlng'], '31.9539,35.9106');

      final onlyCode = await GooglePlacesRemoteDataSource(
        _FakeApi({
          'status': 'OK',
          'results': [
            {'formatted_address': '8G5P+XX'},
          ],
        }),
      ).reverseGeocode(_amman, 'ar');
      expect(onlyCode?.headline, '8G5P+XX');
      expect(
        await GooglePlacesRemoteDataSource(
          _FakeApi({'status': 'ZERO_RESULTS', 'results': []}),
        ).reverseGeocode(_amman, 'ar'),
        isNull,
      );
    });

    test('repository maps "nothing there" to NotFoundFailure', () async {
      final repository = PlacesRepositoryImpl(
        GooglePlacesRemoteDataSource(
          _FakeApi({'status': 'ZERO_RESULTS', 'results': []}),
        ),
      );
      final result = await repository.describe(_amman, 'ar');
      expect((result as Err<PlaceInfo>).failure, isA<NotFoundFailure>());
    });
  });

  group('use cases', () {
    test('SearchPlaces ignores text under two characters', () async {
      const places = PlacesRepositoryImpl(
        MockPlacesRemoteDataSource(latency: Duration.zero),
      );
      const search = SearchPlaces(places);
      expect(
        ((await search(' ا ', 'ar')) as Success<List<PlaceSuggestion>>).data,
        isEmpty,
      );
      final found =
          ((await search('إربد', 'ar')) as Success<List<PlaceSuggestion>>).data;
      expect(found.single.placeId, 'irbid');
    });

    test('mock places: search in both languages, nearest place', () async {
      const mock = MockPlacesRemoteDataSource(latency: Duration.zero);
      expect(
        (await mock.autocomplete('tabarbour', 'en')).single.description,
        'Suhail Bin Amr St، Tabarbour, Amman',
      );
      expect(
        (await mock.reverseGeocode(_irbid, 'ar'))?.headline,
        'شارع الدفاع',
      );
      expect(
        (await mock.reverseGeocode(_amman, 'en'))?.headline,
        'King Hussein St',
      );
    });
  });

  group('DeliveryLocationCubit', () {
    late FakeDeviceLocation device;

    Future<DeliveryLocationCubit> make([
      Map<String, Object> initial = const {},
    ]) async {
      device = FakeDeviceLocation(point: const GeoPoint(31.9863, 35.9814));
      final addresses = AddressRepositoryImpl(
        StorageAddressLocalDataSource(await _storage(initial)),
      );
      const places = PlacesRepositoryImpl(
        MockPlacesRemoteDataSource(latency: Duration.zero),
      );
      return DeliveryLocationCubit(
        getAddresses: GetAddresses(addresses),
        getDeliveryLocation: GetDeliveryLocation(addresses),
        setDeliveryLocation: SetDeliveryLocation(addresses),
        saveAddress: SaveAddress(addresses),
        deleteAddress: DeleteAddress(addresses),
        getCurrentLocation: GetCurrentLocation(LocationRepositoryImpl(device)),
        describePlace: const DescribePlace(places),
      );
    }

    test('starts empty: the "choose an address" hint', () async {
      final cubit = await make();
      expect(cubit.state.hint, isNull); // still loading
      await cubit.load();
      expect(cubit.state.status, DeliveryLocationStatus.ready);
      expect(cubit.state.selection, isNull);
      expect(cubit.state.hint, DeliveryHint.chooseAddress);
      cubit.dismissHint();
      expect(cubit.state.hint, isNull);
      await cubit.close();
    });

    test(
      'saved address -> no hint; unsaved place -> unsaved hint; kept after restart',
      () async {
        final cubit = await make();
        await cubit.load();
        await cubit.saveAndSelect(_home);
        expect(cubit.state.addresses, [_home]);
        expect(cubit.state.selection?.isSaved, isTrue);
        expect(cubit.state.hint, isNull);

        const place = DeliveryLocation(point: _amman, label: 'x', details: 'y');
        cubit.dismissHint();
        await cubit.selectLocation(place);
        expect(cubit.state.hint, DeliveryHint.unsavedLocation);
        expect(
          cubit.state.hintDismissed,
          isFalse,
        ); // a new choice shows its hint again

        // a new cubit on the same storage restores everything
        final prefs = await SharedPreferences.getInstance();
        final saved = {for (final key in prefs.getKeys()) key: prefs.get(key)!};
        await cubit.close();
        final again = await make(saved);
        await again.load();
        expect(again.state.addresses, [_home]);
        expect(again.state.selection, place);
        await again.close();
      },
    );

    test('removing the delivery address clears the choice', () async {
      final cubit = await make();
      await cubit.load();
      await cubit.saveAndSelect(_home);
      await cubit.removeAddress('a1');
      expect(cubit.state.addresses, isEmpty);
      expect(cubit.state.selection, isNull);
      expect(cubit.state.hint, DeliveryHint.chooseAddress);
      await cubit.close();
    });

    test('use current location: unsaved place with its text', () async {
      final cubit = await make();
      await cubit.load();
      final states = <bool>[];
      final sub = cubit.stream.listen((s) => states.add(s.locating));
      await cubit.useCurrentLocation('en');
      await sub.cancel();
      expect(states, contains(true));
      expect(cubit.state.locating, isFalse);
      final selection = cubit.state.selection!;
      expect(selection.isSaved, isFalse);
      expect(selection.point, const GeoPoint(31.9863, 35.9814));
      expect(selection.label, 'Suhail Bin Amr St');
      expect(cubit.state.locationFailure, isNull);
      await cubit.close();
    });

    test(
      'use current location: denied / off are reported, nothing changes',
      () async {
        final cubit = await make();
        await cubit.load();
        device.error = const LocationPermissionException();
        await cubit.useCurrentLocation('ar');
        expect(cubit.state.locationFailure, isA<LocationPermissionFailure>());
        expect(cubit.state.selection, isNull);
        expect(cubit.state.locating, isFalse);
        cubit.clearLocationFailure();
        expect(cubit.state.locationFailure, isNull);

        device.error = const LocationDisabledException();
        await cubit.useCurrentLocation('ar');
        expect(cubit.state.locationFailure, isA<LocationDisabledFailure>());
        expect(device.calls, 2);
        await cubit.close();
      },
    );
  });

  group('MapPickerCubit', () {
    MapPickerCubit make({
      GeoPoint start = _amman,
      Duration debounce = Duration.zero,
    }) {
      const places = PlacesRepositoryImpl(
        MockPlacesRemoteDataSource(latency: Duration.zero),
      );
      return MapPickerCubit(
        start: start,
        searchPlaces: const SearchPlaces(places),
        getPlacePoint: const GetPlacePoint(places),
        describePlace: const DescribePlace(places),
        checkDeliveryArea: const CheckDeliveryArea(
          ServiceAreaDeliveryRepository(),
        ),
        searchDebounce: debounce,
      );
    }

    test('start: describes the point; deliverable in Amman', () async {
      final cubit = make();
      expect(cubit.state.placeStatus, PlaceStatus.loading);
      expect(cubit.state.canConfirm, isFalse);
      await cubit.start('ar');
      expect(cubit.state.placeStatus, PlaceStatus.ready);
      expect(cubit.state.place?.headline, 'شارع الملك حسين');
      expect(cubit.state.deliverable, isTrue);
      expect(cubit.state.canConfirm, isTrue);
      expect(cubit.state.location?.point, _amman);
      expect(cubit.state.location?.label, 'شارع الملك حسين');
      expect(cubit.state.outsideDeliveryArea, isFalse);
      await cubit.close();
    });

    test('outside the delivery area: message, no confirm', () async {
      final cubit = make(start: _irbid);
      await cubit.start('ar');
      expect(cubit.state.place?.headline, 'شارع الدفاع');
      expect(cubit.state.deliverable, isFalse);
      expect(cubit.state.outsideDeliveryArea, isTrue);
      expect(cubit.state.canConfirm, isFalse);
      expect(cubit.state.location, isNull);
      await cubit.close();
    });

    test('moving the map clears the address until it stops', () async {
      final cubit = make();
      await cubit.start('ar');
      cubit.onCameraMove(_irbid);
      expect(cubit.state.point, _irbid);
      expect(cubit.state.placeStatus, PlaceStatus.loading);
      expect(cubit.state.place, isNull);
      expect(cubit.state.canConfirm, isFalse);
      await cubit.onCameraIdle(_irbid);
      expect(cubit.state.placeStatus, PlaceStatus.ready);
      expect(cubit.state.outsideDeliveryArea, isTrue);
      await cubit.onCameraIdle(_amman); // idle without a move event
      expect(cubit.state.canConfirm, isTrue);
      await cubit.close();
    });

    test('the latest stop wins over a slower older answer', () async {
      final cubit = make();
      final a = cubit.onCameraIdle(_irbid);
      final b = cubit.onCameraIdle(_amman);
      await Future.wait([a, b]);
      expect(cubit.state.point, _amman);
      expect(cubit.state.deliverable, isTrue);
      await cubit.close();
    });

    test('language change describes the point again', () async {
      final cubit = make();
      await cubit.start('ar');
      await cubit.changeLanguage('en');
      expect(cubit.state.place?.headline, 'King Hussein St');
      await cubit.close();
    });

    test('search: suggestions, too-short text, close, failure', () async {
      final cubit = make();
      await cubit.start('ar');
      cubit.onQueryChanged(' ا ');
      expect(cubit.state.showSuggestions, isFalse);
      cubit.onQueryChanged('عمّان');
      expect(cubit.state.suggestionsStatus, SuggestionsStatus.searching);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.suggestionsStatus, SuggestionsStatus.done);
      expect(cubit.state.suggestions.map((s) => s.placeId), [
        'tabarbour',
        'jabal-hussein',
        'abdali',
      ]);
      cubit.closeSuggestions();
      expect(cubit.state.showSuggestions, isFalse);
      cubit.onQueryChanged('zzzz');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.suggestionsStatus, SuggestionsStatus.done);
      expect(cubit.state.suggestions, isEmpty);
      await cubit.close();
    });

    test('picking a suggestion flies the map to it', () async {
      final cubit = make();
      await cubit.start('ar');
      final moves = <GeoPoint>[];
      final sub = cubit.moveRequests.listen(moves.add);
      cubit.onQueryChanged('إربد');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await cubit.selectSuggestion(cubit.state.suggestions.single);
      await pumpEventQueue();
      expect(moves, [_irbid]);
      expect(cubit.state.showSuggestions, isFalse);
      await sub.cancel();
      await cubit.close();
    });
  });
}
