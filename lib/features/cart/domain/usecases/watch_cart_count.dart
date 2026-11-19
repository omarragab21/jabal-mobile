import '../repositories/cart_repository.dart';

class WatchCartCount {
  const WatchCartCount(this._repository);
  final CartRepository _repository;

  Stream<int> call() => _repository.watchItemCount();
}
