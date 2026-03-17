import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Helper per ripetere chiamate HTTP/API con backoff esponenziale.
///
/// Esempio:
/// ```dart
/// final result = await retryWithBackoff(() => http.get(uri));
/// ```
Future<T> retryWithBackoff<T>(
  Future<T> Function() fn, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration maxDelay = const Duration(seconds: 10),
  bool Function(Exception)? retryIf,
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await fn();
    } on Exception catch (e) {
      attempt++;
      if (attempt >= maxRetries || (retryIf != null && !retryIf(e))) {
        rethrow;
      }
      final delay = _calculateDelay(attempt, initialDelay, maxDelay);
      debugPrint('retryWithBackoff: attempt $attempt/$maxRetries, '
          'retrying in ${delay.inMilliseconds}ms — $e');
      await Future.delayed(delay);
    }
  }
}

Duration _calculateDelay(int attempt, Duration initial, Duration max) {
  // Exponential backoff con jitter
  final baseMs = initial.inMilliseconds * pow(2, attempt - 1);
  final jitter = Random().nextInt(initial.inMilliseconds);
  final delayMs = (baseMs + jitter).toInt();
  return Duration(milliseconds: min(delayMs, max.inMilliseconds));
}

/// Wrappa un Future con un timeout e messaggio leggibile.
Future<T> withTimeout<T>(
  Future<T> future, {
  Duration timeout = const Duration(seconds: 10),
  String? operationName,
}) {
  return future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException(
      operationName != null
          ? '$operationName: tempo scaduto (${timeout.inSeconds}s)'
          : 'Operazione scaduta dopo ${timeout.inSeconds}s',
    ),
  );
}
