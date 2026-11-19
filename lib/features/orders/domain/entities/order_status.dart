/// Where an order is in its life. The order of the values follows the happy
/// path; [cancelled] is the only way out of it.
enum OrderStatus {
  pendingApproval,
  inPreparation,
  onTheWay,
  delivered,
  cancelled;

  /// Shown under "current orders" (still moving) rather than "previous".
  bool get isCurrent => switch (this) {
    pendingApproval || inPreparation || onTheWay => true,
    delivered || cancelled => false,
  };

  /// The customer may cancel only before the store starts preparing.
  bool get isCancellable => this == pendingApproval;
}

/// Who cancelled an order, which changes the message shown to the customer.
enum CancelledBy { customer, store }
