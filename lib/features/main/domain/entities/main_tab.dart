/// The bottom-navigation tabs, in logical order (the first is the "start"
/// side: right in Arabic, left in English).
enum MainTab {
  home('nav.home', 'home'),
  categories('nav.categories', 'categories'),
  cart('nav.cart', 'cart'),
  orders('nav.orders', 'orders'),
  account('nav.account', 'account');

  const MainTab(this.labelKey, this._icon);

  /// Translation key of the label.
  final String labelKey;
  final String _icon;

  String get iconAsset => 'assets/icons/nav/$_icon.svg';
  String get activeIconAsset => 'assets/icons/nav/${_icon}_active.svg';
}
