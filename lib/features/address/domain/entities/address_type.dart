/// What kind of place a saved address is; picks its icon.
enum AddressType {
  apartment,
  house,
  office,
  other;

  /// Parses a stored name; anything unknown is [other].
  static AddressType parse(String? name) => AddressType.values.firstWhere(
    (type) => type.name == name,
    orElse: () => AddressType.other,
  );
}
