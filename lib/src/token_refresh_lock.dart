import 'dart:async';
import 'package:api_tools/api_tools.dart';

/// A lock that ensures only one token refresh operation happens at a time.
///
/// This class coordinates token refresh operations across multiple concurrent
/// requests to prevent multiple simultaneous refresh attempts.
class TokenRefreshLock {
  final TokenProvider tokenProvider;
  Completer<void>? _refreshCompleter;

  TokenRefreshLock({required this.tokenProvider});

  /// Attempts to refresh the token, ensuring only one refresh happens at a time.
  ///
  /// If a refresh is already in progress, this method will wait for the
  /// in-progress refresh to complete instead of starting a new one.
  ///
  /// Throws any exception that occurs during the refresh operation.
  Future<void> refresh() async {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      // A refresh is already in progress, wait for it to complete
      return _refreshCompleter!.future;
    }

    // Start a new refresh operation
    _refreshCompleter = Completer<void>();

    try {
      await tokenProvider.refreshToken();
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
    }

    // Return the completer's future so all callers get the same result
    return _refreshCompleter!.future;
  }
}
