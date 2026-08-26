import 'package:flutter/foundation.dart';

/// Drop-in replacement for `print()` in hot paths (per-signal, per-tick,
/// per-event call sites in the calling/notification code) — a no-op in
/// release builds instead of a synchronous stdout write on every call.
/// Debug/profile builds behave exactly like `print()` did before.
void logCall(Object? message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}
