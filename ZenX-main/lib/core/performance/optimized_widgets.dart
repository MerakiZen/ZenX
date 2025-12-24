import 'package:flutter/material.dart';

/// Optimized widget that only rebuilds when needed
class OptimizedWidget extends StatelessWidget {
  final Widget child;
  final bool shouldRebuild;

  const OptimizedWidget({
    super.key,
    required this.child,
    this.shouldRebuild = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldRebuild) {
      return child;
    }
    return RepaintBoundary(child: child);
  }
}

/// Widget with automatic keep alive for tab views
class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Optimized list item widget
class OptimizedListItem extends StatelessWidget {
  final Widget child;
  final double? itemExtent;

  const OptimizedListItem({
    super.key,
    required this.child,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: itemExtent,
        child: child,
      ),
    );
  }
}

/// Lazy loading widget
class LazyLoadWidget extends StatefulWidget {
  final Widget Function() builder;
  final bool loadImmediately;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    this.loadImmediately = false,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.loadImmediately) {
      _isLoaded = true;
    } else {
      // Load on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox.shrink();
    }
    return widget.builder();
  }
}









