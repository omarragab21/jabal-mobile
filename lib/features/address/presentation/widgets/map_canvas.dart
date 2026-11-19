import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/maps_config.dart';
import '../../domain/entities/geo_point.dart';

/// What the map page needs from a map: it opens at [initial], reports the
/// centre while it moves and when it stops, and flies to [moveRequests].
class MapCanvasConfig {
  const MapCanvasConfig({
    required this.initial,
    required this.onMoved,
    required this.onIdle,
    required this.moveRequests,
  });

  final GeoPoint initial;
  final ValueChanged<GeoPoint> onMoved;
  final ValueChanged<GeoPoint> onIdle;
  final Stream<GeoPoint> moveRequests;
}

/// Builds the map. The page depends on this, not on the Google SDK, so tests
/// can put a plain widget in its place.
typedef MapCanvasBuilder =
    Widget Function(BuildContext context, MapCanvasConfig config);

/// The real map: Google Maps with the pin fixed at the centre.
Widget googleMapCanvas(BuildContext context, MapCanvasConfig config) =>
    _GoogleMapCanvas(config: config);

class _GoogleMapCanvas extends StatefulWidget {
  const _GoogleMapCanvas({required this.config});

  final MapCanvasConfig config;

  @override
  State<_GoogleMapCanvas> createState() => _GoogleMapCanvasState();
}

class _GoogleMapCanvasState extends State<_GoogleMapCanvas> {
  GoogleMapController? _controller;
  StreamSubscription<GeoPoint>? _moves;
  late LatLng _center = _latLng(widget.config.initial);

  static LatLng _latLng(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);

  @override
  void initState() {
    super.initState();
    _moves = widget.config.moveRequests.listen(
      (point) => _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _latLng(point), zoom: MapsConfig.defaultZoom),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _moves?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: MapsConfig.defaultZoom,
      ),
      onMapCreated: (controller) => _controller = controller,
      onCameraMove: (position) {
        _center = position.target;
        widget.config.onMoved(
          GeoPoint(position.target.latitude, position.target.longitude),
        );
      },
      onCameraIdle: () =>
          widget.config.onIdle(GeoPoint(_center.latitude, _center.longitude)),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );
  }
}
