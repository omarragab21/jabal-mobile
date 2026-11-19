import 'dart:async';

import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';

/// In-memory cart: keeps quantities per product for as long as the app runs.
class MockCartRepository implements CartRepository {
  MockCartRepository({Map<int, int> initial = const {}})
    : _quantities = {...initial};

  /// Insertion order is the order of the rows.
  final Map<int, int> _quantities;
  final StreamController<List<CartLine>> _changes =
      StreamController<List<CartLine>>.broadcast();

  List<CartLine> get _lines => [
    for (final entry in _quantities.entries)
      CartLine(productId: entry.key, quantity: entry.value),
  ];

  void _notify() => _changes.add(_lines);

  /// The current rows first, then every change. Each listener subscribes to
  /// the changes in the same step it gets the current rows, so an add right
  /// after `listen` is never missed.
  @override
  Stream<List<CartLine>> watchLines() {
    late final StreamController<List<CartLine>> controller;
    StreamSubscription<List<CartLine>>? changes;
    controller = StreamController<List<CartLine>>(
      onListen: () {
        controller.add(_lines);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<List<CartLine>> getLines() async => _lines;

  @override
  Stream<int> watchItemCount() => watchLines().map(
    (lines) => lines.fold(0, (sum, line) => sum + line.quantity),
  );

  @override
  Future<void> addItem(int productId, {int quantity = 1}) async {
    assert(quantity > 0);
    _quantities.update(
      productId,
      (q) => q + quantity,
      ifAbsent: () => quantity,
    );
    _notify();
  }

  @override
  Future<void> setItemQuantity(int productId, int quantity) async {
    assert(quantity > 0);
    _quantities[productId] = quantity;
    _notify();
  }

  @override
  Future<void> removeItem(int productId) async {
    if (_quantities.remove(productId) != null) _notify();
  }

  @override
  Future<void> clear() async {
    if (_quantities.isEmpty) return;
    _quantities.clear();
    _notify();
  }
}
