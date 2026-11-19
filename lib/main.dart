import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/images/app_image_cache.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/locale_service.dart';
import 'core/platform/link_opener.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/storage/shared_prefs_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage.dart';
import 'features/account/account_module.dart';
import 'features/address/address_module.dart';
import 'features/address/data/datasources/device_location_data_source.dart';
import 'features/address/data/datasources/places_remote_data_source.dart';
import 'features/address/presentation/widgets/map_canvas.dart';
import 'features/auth/auth_module.dart';
import 'features/legal/legal_module.dart';
import 'features/payment_cards/payment_cards_module.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/profile_module.dart';
import 'features/settings/settings_module.dart';
import 'features/support/data/datasources/store_info_remote_data_source.dart';
import 'features/support/support_module.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/cart/cart_module.dart';
import 'features/checkout/checkout_module.dart';
import 'features/categories/categories_module.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/home_module.dart';
import 'features/main/main_module.dart';
import 'features/orders/orders_module.dart';
import 'features/search/search_module.dart';
import 'features/product_details/product_details_module.dart';
import 'features/onboarding/onboarding_module.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppImageCacheManager.configureMemoryCache();
  await EasyLocalization.ensureInitialized();
  final storage = await SharedPrefsStorage.create();
  final localeService = LocaleService(storage);
  runApp(
    AppLocalization.wrap(
      startLocale: localeService.load(),
      child: MyApp(
        router: buildAppRouter(storage),
        localeService: localeService,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router, required this.localeService});

  final AppRouter router;
  final LocaleService localeService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: localeService,
      // Figma frame (Onboarding 01/03) is 375 x 812; every size scales from it.
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          title: 'Dr Jabal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: router.onGenerateRoute,
        ),
      ),
    );
  }
}

/// Composition root: builds every feature module and the router.
AppRouter buildAppRouter(
  LocalStorage storage, {
  AuthRemoteDataSource? authRemote,
  HomeRemoteDataSource? homeRemote,
  LinkOpener? linkOpener,
  ProfileRemoteDataSource? profileRemote,
  StoreInfoRemoteDataSource? storeInfoRemote,
  AppVersionReader? readVersion,
  PlacesRemoteDataSource? placesRemote,
  DeviceLocationDataSource? deviceLocation,
  MapCanvasBuilder? mapBuilder,
  bool animations = true,
}) {
  final auth = AuthModule(storage, remote: authRemote);
  final cart = CartModule(
    latency: animations ? const Duration(milliseconds: 200) : Duration.zero,
  );
  final home = HomeModule(
    addToCart: cart.addToCart,
    watchCartCount: cart.watchCartCount,
    remote: homeRemote,
    linkOpener: linkOpener,
    animations: animations,
  );
  final search = SearchModule(
    searchProducts: home.searchProducts,
    addToCart: cart.addToCart,
    contactSupport: home.contactSupport,
    favorites: home.favorites,
    latency: animations ? const Duration(milliseconds: 150) : Duration.zero,
    suggestionDebounce: animations
        ? const Duration(milliseconds: 250)
        : Duration.zero,
  );
  final address = AddressModule(
    storage,
    phoneValidator: auth.validation.phone,
    places: placesRemote,
    deviceLocation: deviceLocation,
    mapBuilder: mapBuilder,
    searchDebounce: animations
        ? const Duration(milliseconds: 350)
        : Duration.zero,
  );
  final support = SupportModule(
    remote: storeInfoRemote,
    linkOpener: linkOpener,
  );
  final orders = OrdersModule(
    linkOpener: linkOpener,
    openSupport: support.openSupport,
    latency: animations ? const Duration(milliseconds: 500) : Duration.zero,
  );
  final paymentCards = PaymentCardsModule(storage);
  final legal = LegalModule(readVersion: readVersion);
  final checkout = CheckoutModule(
    cart: cart,
    address: address,
    paymentCards: paymentCards,
    legal: legal,
    latency: animations ? const Duration(milliseconds: 400) : Duration.zero,
  );
  final productDetails = ProductDetailsModule(
    addToCart: cart.addToCart,
    updateCartItem: cart.updateCartItem,
    watchCartCount: cart.watchCartCount,
    favorites: home.favorites,
    linkOpener: linkOpener,
    latency: animations ? const Duration(milliseconds: 500) : Duration.zero,
  );
  return AppRouter(
    productDetails: productDetails,
    onboarding: OnboardingModule(storage),
    auth: auth,
    main: MainModule(
      home: home,
      categories: CategoriesModule(repository: home.repository),
      cart: cart,
      orders: orders,
      address: address,
      checkout: checkout,
      search: search,
      account: AccountModule(
        getCurrentSession: auth.getCurrentSession,
        logout: auth.logout,
        profile: ProfileModule(
          storage,
          validation: auth.validation,
          remote: profileRemote,
        ),
        address: address,
        paymentCards: paymentCards,
        support: support,
        legal: legal,
        settings: SettingsModule(storage),
      ),
    ),
  );
}
