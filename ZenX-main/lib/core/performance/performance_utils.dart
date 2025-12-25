import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance utilities for optimizing Flutter app
class PerformanceUtils {
  PerformanceUtils._();

  /// Debounce function to limit rapid updates
  static T Function() debounce<T>(
    T Function() func,
    Duration delay,
  ) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () {
        func();
      });
      return func();
    };
  }

  /// Throttle function to limit function calls
  static T Function() throttle<T>(
    T Function() func,
    Duration delay,
  ) {
    DateTime? lastCall;
    T? lastResult;
    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) >= delay) {
        lastCall = now;
        lastResult = func();
        return lastResult as T;
      }
      return lastResult as T;
    };
  }

  /// Measure widget build time
  static void measureBuildTime(String widgetName, VoidCallback buildFunction) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      buildFunction();
      stopwatch.stop();
      debugPrint('$widgetName build time: ${stopwatch.elapsedMilliseconds}ms');
    } else {
      buildFunction();
    }
  }

  /// Check if frame is being rendered
  static bool get isRenderingFrame {
    return SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks;
  }

  /// Schedule frame callback for next frame
  static void scheduleFrameCallback(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) => callback());
  }
}

/// Extension for ListView performance optimization
extension ListViewPerformance on ListView {
  /// Create optimized ListView.builder
  static ListView optimizedBuilder({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    double? itemExtent,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemExtent: itemExtent,
      itemBuilder: itemBuilder,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
    );
  }
}

/// Extension for Image optimization
extension ImageOptimization on Image {
  /// Create optimized network image
  static Image optimizedNetwork(
    String src, {
    double? width,
    double? height,
    BoxFit? fit,
    String? placeholder,
  }) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder != null
            ? Image.asset(placeholder)
            : const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}

