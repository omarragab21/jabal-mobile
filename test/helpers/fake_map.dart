import 'dart:async';

import 'package:dr_jabel/features/address/data/datasources/device_location_data_source.dart';
import 'package:dr_jabel/features/address/domain/entities/geo_point.dart';
import 'package:dr_jabel/features/address/presentation/widgets/map_canvas.dart';
import 'package:flutter/material.dart';

/// Stands in for Google Maps in tests: a grey box that reports the camera
/// like the real map does, driven by [moveTo].
class FakeMapCanvas extends StatefulWidget {
  const FakeMapCanvas({super.key, required this.config});

  /// The config of the map currently on screen.
  static MapCanvasConfig? current;

  /// Moves the camera to [point] and stops there.
  static void moveTo(GeoPoint point) {
    final config = current!;
    config.onMoved(point);
    config.onIdle(point);
  }

  static Widget build(BuildContext context, MapCanvasConfig config) =>
      FakeMapCanvas(config: config);

  final MapCanvasConfig config;

  @override
  State<FakeMapCanvas> createState() => _FakeMapCanvasState();
}

class _FakeMapCanvasState extends State<FakeMapCanvas> {
  StreamSubscription<GeoPoint>? _moves;

  @override
  void initState() {
    super.initState();
    FakeMapCanvas.current = widget.config;
    // The real map flies to the point; the fake lands there at once.
    _moves = widget.config.moveRequests.listen(FakeMapCanvas.moveTo);
    // A real map reports idle once it is created.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.config.onIdle(widget.config.initial),
    );
  }

  @override
  void dispose() {
    _moves?.cancel();
    if (FakeMapCanvas.current == widget.config) FakeMapCanvas.current = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(key: ValueKey('fake-map'), color: Color(0xFFE5E7EB));
}

/// A device position that is a fixed point or a fixed error.
class FakeDeviceLocation implements DeviceLocationDataSource {
  FakeDeviceLocation({this.point, this.error});

  GeoPoint? point;
  Object? error;
  int calls = 0;

  @override
  Future<GeoPoint> currentPoint() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return point!;
  }
}
