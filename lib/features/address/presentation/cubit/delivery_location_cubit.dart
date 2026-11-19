import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/delivery_location.dart';
import '../../domain/usecases/address_use_cases.dart';
import '../../domain/usecases/place_use_cases.dart';
import 'delivery_location_state.dart';

/// Shared by the whole app: the saved addresses and the place the order is
/// delivered to (home header, address sheets, map page).
class DeliveryLocationCubit extends Cubit<DeliveryLocationState> {
  DeliveryLocationCubit({
    required GetAddresses getAddresses,
    required GetDeliveryLocation getDeliveryLocation,
    required SetDeliveryLocation setDeliveryLocation,
    required SaveAddress saveAddress,
    required DeleteAddress deleteAddress,
    required GetCurrentLocation getCurrentLocation,
    required DescribePlace describePlace,
  }) : _getAddresses = getAddresses,
       _getDeliveryLocation = getDeliveryLocation,
       _setDeliveryLocation = setDeliveryLocation,
       _saveAddress = saveAddress,
       _deleteAddress = deleteAddress,
       _getCurrentLocation = getCurrentLocation,
       _describePlace = describePlace,
       super(const DeliveryLocationState());

  final GetAddresses _getAddresses;
  final GetDeliveryLocation _getDeliveryLocation;
  final SetDeliveryLocation _setDeliveryLocation;
  final SaveAddress _saveAddress;
  final DeleteAddress _deleteAddress;
  final GetCurrentLocation _getCurrentLocation;
  final DescribePlace _describePlace;

  Future<void> load() async {
    final addresses = (await _getAddresses()).when(
      success: (list) => list,
      failure: (_) => const <Address>[],
    );
    final selection = (await _getDeliveryLocation()).when(
      success: (location) => location,
      failure: (_) => null,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        status: DeliveryLocationStatus.ready,
        addresses: addresses,
        selection: () => selection,
      ),
    );
  }

  Future<void> _reloadAddresses() async {
    final addresses = (await _getAddresses()).when(
      success: (list) => list,
      failure: (_) => state.addresses,
    );
    if (!isClosed) emit(state.copyWith(addresses: addresses));
  }

  /// Delivers to the saved [address].
  Future<void> selectAddress(Address address) =>
      selectLocation(DeliveryLocation.saved(address));

  /// Delivers to [location] (saved or not).
  Future<void> selectLocation(DeliveryLocation location) async {
    emit(state.copyWith(selection: () => location, hintDismissed: false));
    await _setDeliveryLocation(location);
  }

  /// Saves [address] (a new one or an edited one) without changing where the
  /// order goes. Editing the delivery address keeps the header in sync.
  Future<void> saveAddress(Address address) async {
    await _saveAddress(address);
    await _reloadAddresses();
    final current = state.selection;
    if (current?.addressId == address.id && !isClosed) {
      emit(state.copyWith(selection: () => DeliveryLocation.saved(address)));
    }
  }

  /// Saves [address] and delivers to it.
  Future<void> saveAndSelect(Address address) async {
    await _saveAddress(address);
    await _reloadAddresses();
    await selectAddress(address);
  }

  Future<void> removeAddress(String id) async {
    await _deleteAddress(id);
    await _reloadAddresses();
    if (state.selection?.addressId == id && !isClosed) {
      emit(state.copyWith(selection: () => null, hintDismissed: false));
    }
  }

  /// Reads the device position and delivers there, unsaved. On failure
  /// [DeliveryLocationState.locationFailure] explains why.
  Future<void> useCurrentLocation(String languageCode) async {
    if (state.locating) return;
    emit(state.copyWith(locating: true, locationFailure: () => null));
    final located = await _getCurrentLocation();
    if (isClosed) return;
    final point = located.when(success: (p) => p, failure: (_) => null);
    if (point == null) {
      emit(
        state.copyWith(
          locating: false,
          locationFailure: () =>
              located.when(success: (_) => null, failure: (failure) => failure),
        ),
      );
      return;
    }
    // The text is a nicety: without it the point is still a valid place.
    final place = (await _describePlace(
      point,
      languageCode,
    )).when(success: (info) => info, failure: (_) => null);
    if (isClosed) return;
    emit(state.copyWith(locating: false));
    await selectLocation(
      DeliveryLocation(
        point: point,
        label: place?.headline ?? '',
        details: place?.details ?? '',
      ),
    );
  }

  void clearLocationFailure() {
    if (state.locationFailure != null) {
      emit(state.copyWith(locationFailure: () => null));
    }
  }

  void dismissHint() {
    if (!state.hintDismissed) emit(state.copyWith(hintDismissed: true));
  }
}
