import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory management utilities
class MemoryManager {
  MemoryManager._();

  /// Clear image cache
  static Future<void> clearImageCache() async {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Get current memory usage (approximate)
  static int getCurrentMemoryUsage() {
    // This is a placeholder - actual implementation would use platform channels
    // or a package like flutter_memory_usage
    return 0;
  }

  /// Force garbage collection (development only)
  static void forceGC() {
    if (kDebugMode) {
      // Force GC by creating and disposing large objects
      final largeList = List.generate(1000000, (i) => i);
      largeList.clear();
    }
  }

  /// Monitor memory usage
  static Stream<int> monitorMemoryUsage({Duration interval = const Duration(seconds: 5)}) {
    final controller = StreamController<int>.broadcast();
    Timer? timer;

    timer = Timer.periodic(interval, (_) {
      final usage = getCurrentMemoryUsage();
      controller.add(usage);
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

/// Mixin for automatic disposal of resources
mixin DisposableMixin {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<TextEditingController> _controllers = [];

  /// Register subscription for automatic disposal
  void registerSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Register timer for automatic disposal
  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Register controller for automatic disposal
  void registerController(TextEditingController controller) {
    _controllers.add(controller);
  }

  /// Dispose all registered resources
  void disposeAll() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

