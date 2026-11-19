/// What the product page needs to open: which product, and, when it is opened
/// to edit a cart line, the quantity that line has now (the page then offers
/// "update" instead of "add to cart").
class ProductDetailsArgs {
  const ProductDetailsArgs({required this.productId, this.cartQuantity})
    : assert(cartQuantity == null || cartQuantity > 0);

  final int productId;
  final int? cartQuantity;

  bool get isUpdate => cartQuantity != null;
}
