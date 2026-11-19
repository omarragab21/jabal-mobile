import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/delivery_location.dart';

enum DeliveryLocationStatus { loading, ready }

/// Which hint to show under the address in the home header.
enum DeliveryHint {
  /// Nothing chosen yet.
  chooseAddress,

  /// The chosen place was not saved.
  unsavedLocation,
}

class DeliveryLocationState extends Equatable {
  const DeliveryLocationState({
    this.status = DeliveryLocationStatus.loading,
    this.addresses = const [],
    this.selection,
    this.locating = false,
    this.locationFailure,
    this.hintDismissed = false,
  });

  final DeliveryLocationStatus status;
  final List<Address> addresses;

  /// Where the order goes; null until the customer chooses.
  final DeliveryLocation? selection;

  /// True while the device position is being read.
  final bool locating;

  /// Why "use my location" failed; shown once, then cleared.
  final Failure? locationFailure;
  final bool hintDismissed;

  /// The hint to show, or null when there is none (or it was dismissed).
  DeliveryHint? get hint {
    if (status != DeliveryLocationStatus.ready || hintDismissed) return null;
    final selection = this.selection;
    if (selection == null) return DeliveryHint.chooseAddress;
    return selection.isSaved ? null : DeliveryHint.unsavedLocation;
  }

  DeliveryLocationState copyWith({
    DeliveryLocationStatus? status,
    List<Address>? addresses,
    DeliveryLocation? Function()? selection,
    bool? locating,
    Failure? Function()? locationFailure,
    bool? hintDismissed,
  }) => DeliveryLocationState(
    status: status ?? this.status,
    addresses: addresses ?? this.addresses,
    selection: selection != null ? selection() : this.selection,
    locating: locating ?? this.locating,
    locationFailure: locationFailure != null
        ? locationFailure()
        : this.locationFailure,
    hintDismissed: hintDismissed ?? this.hintDismissed,
  );

  @override
  List<Object?> get props => [
    status,
    addresses,
    selection,
    locating,
    locationFailure,
    hintDismissed,
  ];
}
