import 'dart:async';

/// Utility for merging multiple streams with deduplication
class StreamMerger<T> {
  final List<Stream<T>> _streams;
  final T Function(T, T)? _mergeStrategy;
  final bool Function(T, T)? _equalityCheck;

  StreamMerger({
    required List<Stream<T>> streams,
    T Function(T, T)? mergeStrategy,
    bool Function(T, T)? equalityCheck,
  })  : _streams = streams,
        _mergeStrategy = mergeStrategy,
        _equalityCheck = equalityCheck;

  /// Merge all streams into a single stream
  Stream<T> merge() {
    if (_streams.isEmpty) {
      return Stream<T>.empty();
    }

    if (_streams.length == 1) {
      return _streams.first;
    }

    return Stream.multi((controller) {
      final subscriptions = <StreamSubscription<T>>[];
      final latestValues = <int, T>{};
      var activeStreams = _streams.length;

      for (var i = 0; i < _streams.length; i++) {
        final stream = _streams[i];
        final index = i;

        final subscription = stream.listen(
          (value) {
            latestValues[index] = value;
            _emitMergedValue(controller, latestValues);
          },
          onError: controller.addError,
          onDone: () {
            activeStreams--;
            if (activeStreams == 0) {
              controller.close();
            }
          },
        );

        subscriptions.add(subscription);
      }

      controller.onCancel = () {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      };
    });
  }

  void _emitMergedValue(
    StreamController<T> controller,
    Map<int, T> values,
  ) {
    if (values.length < _streams.length) {
      return; // Wait for all streams to emit at least once
    }

    final allValues = values.values.toList();

    if (_equalityCheck != null) {
      // Deduplicate using custom equality check
      final uniqueValues = <T>[];
      for (final value in allValues) {
        if (!uniqueValues.any((v) => _equalityCheck(v, value))) {
          uniqueValues.add(value);
        }
      }
      allValues.clear();
      allValues.addAll(uniqueValues);
    }

    if (allValues.length == 1) {
      controller.add(allValues.first);
    } else if (_mergeStrategy != null) {
      // Merge multiple values using strategy
      T merged = allValues.first;
      for (var i = 1; i < allValues.length; i++) {
        merged = _mergeStrategy(merged, allValues[i]);
      }
      controller.add(merged);
    } else {
      // Default: emit the first value
      controller.add(allValues.first);
    }
  }
}

/// Extension for easier stream merging
extension StreamMergeExtension<T> on Stream<T> {
  /// Merge this stream with another stream
  Stream<T> mergeWith(Stream<T> other, {T Function(T, T)? mergeStrategy}) {
    return StreamMerger<T>(
      streams: [this, other],
      mergeStrategy: mergeStrategy,
    ).merge();
  }

  /// Merge this stream with multiple other streams
  Stream<T> mergeWithAll(
    List<Stream<T>> others, {
    T Function(T, T)? mergeStrategy,
    bool Function(T, T)? equalityCheck,
  }) {
    return StreamMerger<T>(
      streams: [this, ...others],
      mergeStrategy: mergeStrategy,
      equalityCheck: equalityCheck,
    ).merge();
  }
}









