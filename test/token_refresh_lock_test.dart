import 'package:api_tools/api_tools.dart';
import 'package:api_tools/src/token_refresh_lock.dart';
import 'package:api_tools/src/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("TokenRefreshLock", () {
    test("should call refreshToken on the token provider", () async {
      final tokenProvider = ConfigurableTokenProviderTestDouble();
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      expect(tokenProvider.refreshCallCount, 0);
      await lock.refresh();
      expect(tokenProvider.refreshCallCount, 1);
    });

    test("should only call refreshToken once when multiple concurrent refreshes are requested",
        () async {
      final tokenProvider = ConfigurableTokenProviderTestDouble()
        ..refreshDelay = Duration(milliseconds: 100);
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      // Start multiple concurrent refresh operations
      final futures = [
        lock.refresh(),
        lock.refresh(),
        lock.refresh(),
        lock.refresh(),
      ];

      await Future.wait(futures);

      // Should only have called refreshToken once despite 4 concurrent requests
      expect(tokenProvider.refreshCallCount, 1);
    });

    test("should allow sequential refreshes", () async {
      final tokenProvider = ConfigurableTokenProviderTestDouble();
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      await lock.refresh();
      expect(tokenProvider.refreshCallCount, 1);

      await lock.refresh();
      expect(tokenProvider.refreshCallCount, 2);

      await lock.refresh();
      expect(tokenProvider.refreshCallCount, 3);
    });

    test("should propagate exceptions from token provider", () async {
      final exception = Exception("Token refresh failed");
      final tokenProvider = ConfigurableTokenProviderTestDouble()
        ..exceptionToThrow = exception;
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      await expectLater(
        lock.refresh(),
        throwsA(equals(exception)),
      );
    });

    test("should propagate the same exception to all waiting callers", () async {
      final exception = Exception("Token refresh failed");
      final tokenProvider = ConfigurableTokenProviderTestDouble()
        ..exceptionToThrow = exception
        ..refreshDelay = Duration(milliseconds: 100);
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      // Start multiple concurrent refresh operations
      final futures = [
        lock.refresh(),
        lock.refresh(),
        lock.refresh(),
      ];

      // All should receive the same exception
      for (final future in futures) {
        await expectLater(
          future,
          throwsA(equals(exception)),
        );
      }
    });

    test("should allow new refresh after a failed refresh", () async {
      final exception = Exception("First refresh failed");
      final tokenProvider = ConfigurableTokenProviderTestDouble()
        ..exceptionToThrow = exception;
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      // First refresh should fail
      await expectLater(
        lock.refresh(),
        throwsA(equals(exception)),
      );

      // Clear the exception for the next attempt
      tokenProvider.exceptionToThrow = null;

      // Second refresh should succeed
      await lock.refresh();
      expect(tokenProvider.refreshCallCount, 2);
    });

    test("should serialize concurrent refresh calls even with delays", () async {
      final tokenProvider = ConfigurableTokenProviderTestDouble()
        ..refreshDelay = Duration(milliseconds: 50);
      final lock = TokenRefreshLock(tokenProvider: tokenProvider);

      final startTime = DateTime.now();

      // Start 3 concurrent refresh operations
      final futures = [
        lock.refresh(),
        lock.refresh(),
        lock.refresh(),
      ];

      await Future.wait(futures);

      final duration = DateTime.now().difference(startTime);

      // Should have called refreshToken only once
      expect(tokenProvider.refreshCallCount, 1);

      // Total time should be around the delay time (not 3x the delay)
      // Adding some margin for test execution overhead
      expect(duration.inMilliseconds, lessThan(150));
    });
  });
}
