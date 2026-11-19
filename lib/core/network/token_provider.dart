/// Abstraction for reading the auth token. The network layer doesn't care
/// where it's stored (secure storage, memory, ...); implement this in the
/// auth feature and inject it.
abstract interface class TokenProvider {
  Future<String?> getAccessToken();
}
