import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/checkout_entities.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._remote);

  final CheckoutRemoteDataSource _remote;

  @override
  Future<Result<CheckoutOptions>> getOptions() => guard(_remote.fetchOptions);

  @override
  Future<Result<PromoDiscount>> validatePromo(
    String code,
    double subtotal,
  ) async {
    try {
      return Success(await _remote.validatePromo(code, subtotal));
    } on ServerException catch (e) {
      // The server's code becomes a failure the page can word.
      if (e.message == CheckoutErrorCodes.invalidPromo) {
        return const Err(InvalidPromoCodeFailure());
      }
      return Err(Failure.fromException(e));
    } on AppException catch (e) {
      return Err(Failure.fromException(e));
    } on Object {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<PlacedOrder>> placeOrder(PlaceOrderRequest request) =>
      guard(() => _remote.placeOrder(request));
}
