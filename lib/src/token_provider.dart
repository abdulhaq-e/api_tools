/// Interface for providing authentication tokens.
///
/// Implement this abstract class to provide tokens from various sources
/// such as secure storage, memory cache, or authentication services.
abstract class TokenProvider {
  /// Returns the authentication token.
  ///
  /// This method is called before each API request to retrieve the current
  /// authentication token. Implementations should handle token retrieval,
  /// refresh logic if needed, and any errors that may occur.
  Future<String> getToken();
}
