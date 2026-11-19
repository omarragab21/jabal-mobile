import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/maps_config.dart';
import '../../core/error/failures.dart';
import '../../core/network/dio_api_client.dart';
import '../../core/network/network_config.dart';
import '../../core/storage/local_storage.dart';
import 'data/datasources/address_local_data_source.dart';
import 'data/datasources/device_location_data_source.dart';
import 'data/datasources/google_places_remote_data_source.dart';
import 'data/datasources/places_remote_data_source.dart';
import 'data/repositories/address_repository_impl.dart';
import 'data/repositories/location_repository_impl.dart';
import 'data/repositories/places_repository_impl.dart';
import 'data/repositories/service_area_delivery_repository.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../auth/domain/validators/phone_number_validator.dart';
import 'domain/entities/address.dart';
import 'domain/entities/address_type.dart';
import 'domain/validators/address_form_validators.dart';
import 'domain/entities/delivery_location.dart';
import 'domain/entities/geo_point.dart';
import 'domain/repositories/address_repository.dart';
import 'domain/repositories/delivery_area_repository.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/places_repository.dart';
import 'domain/usecases/address_use_cases.dart';
import 'domain/usecases/place_use_cases.dart';
import 'presentation/cubit/address_form_cubit.dart';
import 'presentation/cubit/delivery_location_cubit.dart';
import 'presentation/cubit/delivery_location_state.dart';
import 'presentation/cubit/map_picker_cubit.dart';
import 'presentation/pages/address_details_page.dart';
import 'presentation/pages/addresses_page.dart';
import 'presentation/pages/map_picker_page.dart';
import 'presentation/widgets/address_list_sheet.dart';
import 'presentation/widgets/delivery_header.dart';
import 'presentation/widgets/delivery_options_sheet.dart';
import 'presentation/widgets/map_canvas.dart';

/// What the map page does with the place the customer confirmed.
enum MapPurpose {
  /// Deliver to the place without saving it.
  browse,

  /// Save the place as a new address and deliver to it.
  saveNew,
}

/// The delivery address feature: the home header line, the address sheets,
/// and the map page. It talks to Google Places by default; pass other data
/// sources to run it offline.
class AddressModule {
  AddressModule(
    LocalStorage storage, {
    required PhoneNumberValidator phoneValidator,
    PlacesRemoteDataSource? places,
    DeviceLocationDataSource? deviceLocation,
    DeliveryAreaRepository? deliveryArea,
    MapCanvasBuilder? mapBuilder,
    String Function()? newId,
    this.searchDebounce = const Duration(milliseconds: 350),
  }) : _phoneValidator = phoneValidator,
       _mapBuilder = mapBuilder ?? googleMapCanvas,
       _newId = newId ?? _timestampId,
       _addresses = AddressRepositoryImpl(
         StorageAddressLocalDataSource(storage),
       ),
       _places = PlacesRepositoryImpl(places ?? _googlePlaces()),
       _location = LocationRepositoryImpl(
         deviceLocation ?? const GeolocatorDeviceLocation(),
       ),
       _area = deliveryArea ?? const ServiceAreaDeliveryRepository() {
    _cubit = DeliveryLocationCubit(
      getAddresses: GetAddresses(_addresses),
      getDeliveryLocation: GetDeliveryLocation(_addresses),
      setDeliveryLocation: SetDeliveryLocation(_addresses),
      saveAddress: SaveAddress(_addresses),
      deleteAddress: DeleteAddress(_addresses),
      getCurrentLocation: GetCurrentLocation(_location),
      describePlace: DescribePlace(_places),
    );
    unawaited(_cubit.load());
  }

  final PhoneNumberValidator _phoneValidator;
  final AddressFormValidators _formValidators = AddressFormValidators();
  final AddressRepository _addresses;
  final PlacesRepository _places;
  final LocationRepository _location;
  final DeliveryAreaRepository _area;
  final MapCanvasBuilder _mapBuilder;
  final String Function() _newId;
  final Duration searchDebounce;
  late final DeliveryLocationCubit _cubit;

  static String _timestampId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  static PlacesRemoteDataSource _googlePlaces() => GooglePlacesRemoteDataSource(
    DioApiClient(
      // The key is in every request URL: never log them.
      config: const NetworkConfig(
        baseUrl: MapsConfig.placesBaseUrl,
        enableLogging: false,
      ),
    ),
  );

  /// The app-wide delivery place (home header, sheets).
  DeliveryLocationCubit get deliveryLocation => _cubit;

  /// The home header: the address line with [below] under it.
  Widget header(Widget below) => BlocProvider.value(
    value: _cubit,
    child: Builder(
      builder: (context) =>
          DeliveryHeader(below: below, onTap: () => openDeliverySheet(context)),
    ),
  );

  /// The sheet that changes the delivery place: the saved addresses when
  /// there are any, otherwise the three ways to pick one.
  Future<void> openDeliverySheet(BuildContext context) {
    final navigator = Navigator.of(context);
    _cubit.clearLocationFailure();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<DeliveryLocationCubit, DeliveryLocationState>(
          builder: (_, _) {
            final state = _cubit.state;
            void closeThen(VoidCallback action) {
              Navigator.pop(sheetContext);
              action();
            }

            void addNew() =>
                closeThen(() => _openMap(navigator, MapPurpose.saveNew));
            if (state.addresses.isNotEmpty) {
              return AddressListSheet(
                addresses: state.addresses,
                onSelected: (address) {
                  _cubit.selectAddress(address);
                  Navigator.pop(sheetContext);
                },
                onAddNew: addNew,
              );
            }
            return DeliveryOptionsSheet(
              locating: state.locating,
              errorText: switch (state.locationFailure) {
                null => null,
                LocationPermissionFailure() =>
                  'address.location_permission_denied'.tr(
                    context: sheetContext,
                  ),
                LocationDisabledFailure() => 'address.location_disabled'.tr(
                  context: sheetContext,
                ),
                _ => 'address.location_failed'.tr(context: sheetContext),
              },
              onSearchOnMap: () => closeThen(
                () => _openMap(navigator, MapPurpose.browse, focusSearch: true),
              ),
              onUseCurrentLocation: () async {
                await _cubit.useCurrentLocation(
                  sheetContext.locale.languageCode,
                );
                if (_cubit.state.locationFailure == null &&
                    sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }
              },
              onAddNew: addNew,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openMap(
    NavigatorState navigator,
    MapPurpose purpose, {
    bool focusSearch = false,
  }) {
    final start =
        _cubit.state.selection?.point ??
        const GeoPoint(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    return navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MapPickerCubit(
            start: start,
            searchPlaces: SearchPlaces(_places),
            getPlacePoint: GetPlacePoint(_places),
            describePlace: DescribePlace(_places),
            checkDeliveryArea: CheckDeliveryArea(_area),
            searchDebounce: searchDebounce,
          ),
          child: Builder(
            builder: (pageContext) => MapPickerPage(
              mapBuilder: _mapBuilder,
              focusSearch: focusSearch,
              onConfirmed: (location) {
                switch (purpose) {
                  case MapPurpose.browse:
                    Navigator.pop(pageContext);
                    _cubit.selectLocation(location);
                  case MapPurpose.saveNew:
                    // Where it is is chosen; now what it is called.
                    _openDetails(Navigator.of(pageContext), location);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The details form of a new address (or of [editing]). Saving closes the
  /// form and the map page under it, and makes the address the delivery place.
  Future<void> _openDetails(
    NavigatorState navigator,
    DeliveryLocation location, {
    Address? editing,
  }) => navigator.push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => AddressFormCubit(
          location: location,
          editing: editing,
          validators: _formValidators,
          phoneValidator: _phoneValidator,
          newId: _newId,
          defaultTitle: (type) => _defaultTitle(navigator.context, type),
        ),
        child: Builder(
          builder: (pageContext) => AddressDetailsPage(
            onSaved: (address) {
              if (editing == null) {
                _cubit.saveAndSelect(address);
                // the form and the map page under it
                navigator
                  ..pop()
                  ..pop();
              } else {
                _cubit.saveAddress(address);
                navigator.pop();
              }
            },
            onDelete: editing == null
                ? null
                : () => _confirmDelete(pageContext, editing),
          ),
        ),
      ),
    ),
  );

  String _defaultTitle(BuildContext context, AddressType type) =>
      'address.form.default_${type.name}'.tr(context: context);

  Future<bool> _confirmDelete(BuildContext context, Address address) async {
    String t(String key) => 'address.form.$key'.tr(context: context);
    final confirmed = await showConfirmDialog(
      context,
      title: t('delete_title'),
      message: t('delete_message'),
      confirmLabel: t('delete_confirm'),
      cancelLabel: t('cancel'),
    );
    if (!confirmed) return false;
    await _cubit.removeAddress(address.id);
    return true;
  }

  /// Opens "delivery addresses" over the current page: the saved addresses,
  /// to edit or to add one.
  Future<void> openAddresses(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: AddressesPage(
            onAdd: () => _openMap(navigator, MapPurpose.saveNew),
            onEdit: (address) => _openDetails(
              navigator,
              DeliveryLocation.saved(address),
              editing: address,
            ),
          ),
        ),
      ),
    );
  }
}
