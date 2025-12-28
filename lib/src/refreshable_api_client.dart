import 'package:api_tools/api_tools.dart';
import 'package:api_tools/src/token_refresh_lock.dart';

/// An API client that automatically refreshes tokens on 401 errors and retries requests.
///
/// This client wraps another APIClient and intercepts 401 (Unauthorized) responses.
/// When a 401 is detected, it uses a [TokenRefreshLock] to refresh the token
/// (ensuring only one refresh happens at a time) and then retries the request.
class RefreshableAPIClient extends APIClient {
  final APIClient client;
  final TokenRefreshLock tokenRefreshLock;
  final int maxRetries;

  RefreshableAPIClient({
    required this.client,
    required this.tokenRefreshLock,
    this.maxRetries = 3,
  });

  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    return _executeWithRetry(
      () => client.request(endpoint),
    );
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    return _executeWithRetry(
      () => client.requestMultipart(endpoint),
    );
  }

  Future<APIResponse> _executeWithRetry(
    Future<APIResponse> Function() requestFn,
  ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final response = await requestFn();

        if (response.statusCode == 401 && attempts < maxRetries - 1) {
          // Token is likely expired, refresh it and retry
          await tokenRefreshLock.refresh();
          attempts++;
          continue;
        }

        return response;
      } on APIError catch (e) {
        if (e.response.statusCode == 401 && attempts < maxRetries - 1) {
          // Token is likely expired, refresh it and retry
          await tokenRefreshLock.refresh();
          attempts++;
          continue;
        }
        rethrow;
      }
    }

    // This should never be reached, but just in case
    throw Exception('Maximum retry attempts reached');
  }
}
