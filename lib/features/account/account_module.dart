import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../address/address_module.dart';
import '../auth/domain/usecases/get_current_session.dart';
import '../auth/domain/usecases/logout.dart';
import '../legal/legal_module.dart';
import '../payment_cards/payment_cards_module.dart';
import '../profile/profile_module.dart';
import '../settings/settings_module.dart';
import '../support/support_module.dart';
import 'presentation/cubit/account_cubit.dart';
import 'presentation/pages/account_page.dart';

/// Wires the account tab: the saved session, logging out, and the feature
/// modules each row of the menu opens.
class AccountModule {
  const AccountModule({
    required GetCurrentSession getCurrentSession,
    required Logout logout,
    required this.profile,
    required this.address,
    required this.paymentCards,
    required this.support,
    required this.legal,
    required this.settings,
  }) : _getCurrentSession = getCurrentSession,
       _logout = logout;

  final GetCurrentSession _getCurrentSession;
  final Logout _logout;
  final ProfileModule profile;
  final AddressModule address;
  final PaymentCardsModule paymentCards;
  final SupportModule support;
  final LegalModule legal;
  final SettingsModule settings;

  Widget page() => BlocProvider(
    create: (_) => AccountCubit(_getCurrentSession, _logout)..load(),
    child: AccountPage(
      actions: AccountActions(
        openPersonalInfo: profile.openPersonalInfo,
        openAddresses: address.openAddresses,
        openPaymentCards: paymentCards.open,
        openSupport: support.openSupport,
        openPolicies: legal.openPolicies,
        openCommunity: support.openCommunity,
        openAbout: legal.openAbout,
        shareApp: support.shareApp,
        readVersion: legal.readVersion,
        openSettings: settings.open,
      ),
    ),
  );
}
