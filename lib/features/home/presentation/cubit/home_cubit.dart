import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/usecases/add_to_cart.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/contact_support.dart';
import '../../domain/usecases/get_home_data.dart';
import 'home_state.dart';

/// View model of the home page: loads the content. (Searching has its own
/// screen and module.)
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetHomeData getHomeData,
    required AddToCart addToCart,
    required ContactSupport contactSupport,
  }) : _getHomeData = getHomeData,
       _addToCart = addToCart,
       _contactSupport = contactSupport,
       super(const HomeState());

  final GetHomeData _getHomeData;
  final AddToCart _addToCart;
  final ContactSupport _contactSupport;

  String _languageCode = 'ar';

  /// Loads the page in [languageCode]. Called on start and whenever the app
  /// language changes.
  Future<void> load(String languageCode) async {
    _languageCode = languageCode;
    emit(state.copyWith(status: HomeStatus.loading, failure: () => null));
    await _fetch();
  }

  /// Pull-to-refresh: keeps the current content on screen while reloading.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final languageCode = _languageCode;
    final result = await _getHomeData(languageCode);
    if (isClosed || languageCode != _languageCode) return;
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: HomeStatus.ready,
          data: data,
          failure: () => null,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(
          // A failed refresh must not wipe content that is already shown.
          status: state.status == HomeStatus.ready
              ? HomeStatus.ready
              : HomeStatus.failed,
          failure: () => failure,
        ),
      ),
    );
  }

  /// Opens WhatsApp with the support team; false when it could not.
  Future<bool> contactSupport(String message) async => (await _contactSupport(
    message,
  )).when(success: (_) => true, failure: (_) => false);

  Future<void> addToCart(Product product) => _addToCart(product.id);
}
