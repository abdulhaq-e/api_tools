import 'package:api_tools/api_tools.dart';
import 'package:api_tools/src/token_refresh_lock.dart';
import 'package:api_tools/src/testing.dart';
import 'package:flutter_test/flutter_test.dart';

({
  TokenRefreshLock lock,
  ConfigurableTokenProviderTestDouble tokenProvider,
}) makeSUT({
  ConfigurableTokenProviderTestDouble? tokenProvider,
}) {
  final provider = tokenProvider ?? ConfigurableTokenProviderTestDouble();
  final lock = TokenRefreshLock(tokenProvider: provider);
  return (lock: lock, tokenProvider: provider);
}

void main() {
  group("TokenRefreshLock", () {
    test("should call refreshToken on the token provider", () async {
      final (lock: sut, :tokenProvider) = makeSUT();

      expect(tokenProvider.refreshCallCount, 0);
      await sut.refresh();
      expect(tokenProvider.refreshCallCount, 1);
    });

    test("should only call refreshToken once when multiple concurrent refreshes are requested",
        () async {
      final (lock: sut, :tokenProvider) = makeSUT();
      tokenProvider.refreshDelay = Duration(milliseconds: 100);

      // Start multiple concurrent refresh operations
      final futures = [
        sut.refresh(),
        sut.refresh(),
        sut.refresh(),
        sut.refresh(),
      ];

      await Future.wait(futures);

      // Should only have called refreshToken once despite 4 concurrent requests
      expect(tokenProvider.refreshCallCount, 1);
    });

    test("should allow sequential refreshes", () async {
      final (lock: sut, :tokenProvider) = makeSUT();

      await sut.refresh();
      expect(tokenProvider.refreshCallCount, 1);

      await sut.refresh();
      expect(tokenProvider.refreshCallCount, 2);

      await sut.refresh();
      expect(tokenProvider.refreshCallCount, 3);
    });

    test("should propagate exceptions from token provider", () async {
      final (lock: sut, :tokenProvider) = makeSUT();
      final exception = Exception("Token refresh failed");
      tokenProvider.exceptionToThrow = exception;

      await expectLater(
        sut.refresh(),
        throwsA(equals(exception)),
      );
    });

    test("should propagate the same exception to all waiting callers", () async {
      final (lock: sut, :tokenProvider) = makeSUT();
      final exception = Exception("Token refresh failed");
      tokenProvider.exceptionToThrow = exception;
      tokenProvider.refreshDelay = Duration(milliseconds: 100);

      // Start multiple concurrent refresh operations
      final futures = [
        sut.refresh(),
        sut.refresh(),
        sut.refresh(),
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
      final (lock: sut, :tokenProvider) = makeSUT();
      final exception = Exception("First refresh failed");
      tokenProvider.exceptionToThrow = exception;

      // First refresh should fail
      await expectLater(
        sut.refresh(),
        throwsA(equals(exception)),
      );

      // Clear the exception for the next attempt
      tokenProvider.exceptionToThrow = null;

      // Second refresh should succeed
      await sut.refresh();
      expect(tokenProvider.refreshCallCount, 2);
    });

    test("should serialize concurrent refresh calls even with delays", () async {
      final (lock: sut, :tokenProvider) = makeSUT();
      tokenProvider.refreshDelay = Duration(milliseconds: 50);

      final startTime = DateTime.now();

      // Start 3 concurrent refresh operations
      final futures = [
        sut.refresh(),
        sut.refresh(),
        sut.refresh(),
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
