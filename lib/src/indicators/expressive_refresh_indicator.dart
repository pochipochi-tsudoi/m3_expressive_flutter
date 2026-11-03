import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

import '../loading_indicator/m3e_contained_loading_indicator.dart';

/// A Material 3 Expressive pull-to-refresh indicator that uses [M3eContainedLoadingIndicator]
/// with spring physics and morphing animations.
class ExpressiveRefreshIndicator extends StatefulWidget {
  const ExpressiveRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 80.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final double displacement;
  final double edgeOffset;
  final Color? color;
  final Color? backgroundColor;

  @override
  State<ExpressiveRefreshIndicator> createState() =>
      _ExpressiveRefreshIndicatorState();
}

enum _RefreshState { idle, drag, armed, refreshing, done }

class _ExpressiveRefreshIndicatorState extends State<ExpressiveRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _positionController;
  _RefreshState _state = _RefreshState.idle;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification) {
      if (_state == _RefreshState.idle) {
        _dragOffset = 0.0;
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_state == _RefreshState.refreshing) return false;

      final overscroll = notification.scrollDelta ?? 0.0;
      if (notification.metrics.extentBefore == 0 && overscroll < 0) {
        // Dragging down at top
        _dragOffset += -overscroll / 2.0; // rubber band resistance
        final progress = (_dragOffset / widget.displacement).clamp(0.0, 2.0);
        _positionController.value = progress;

        final newState =
            progress >= 1.0 ? _RefreshState.armed : _RefreshState.drag;
        if (newState != _state) {
          setState(() => _state = newState);
        }
      } else if (_dragOffset > 0 && overscroll > 0) {
        // Dragging up while pulled
        _dragOffset = math.max(0.0, _dragOffset - overscroll);
        final progress = (_dragOffset / widget.displacement).clamp(0.0, 2.0);
        _positionController.value = progress;

        final newState =
            progress >= 1.0
                ? _RefreshState.armed
                : (progress > 0 ? _RefreshState.drag : _RefreshState.idle);
        if (newState != _state) {
          setState(() => _state = newState);
        }
      }
    } else if (notification is OverscrollNotification) {
      if (_state == _RefreshState.refreshing) return false;

      if (notification.overscroll < 0) {
        _dragOffset += -notification.overscroll / 2.0;
        final progress = (_dragOffset / widget.displacement).clamp(0.0, 2.0);
        _positionController.value = progress;

        final newState =
            progress >= 1.0 ? _RefreshState.armed : _RefreshState.drag;
        if (newState != _state) {
          setState(() => _state = newState);
        }
      }
    } else if (notification is ScrollEndNotification) {
      if (_state == _RefreshState.armed) {
        _startRefresh();
      } else if (_state == _RefreshState.drag) {
        _cancelRefresh();
      }
    }

    return false;
  }

  Future<void> _startRefresh() async {
    setState(() => _state = _RefreshState.refreshing);
    await _positionController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _state = _RefreshState.done);
        await _positionController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInCubic,
        );
        if (mounted) {
          setState(() {
            _state = _RefreshState.idle;
            _dragOffset = 0.0;
          });
        }
      }
    }
  }

  void _cancelRefresh() {
    _positionController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInCubic,
    );
    setState(() {
      _state = _RefreshState.idle;
      _dragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          if (_state != _RefreshState.idle)
            AnimatedBuilder(
              animation: _positionController,
              builder: (context, child) {
                final progress = _positionController.value;
                final top =
                    widget.edgeOffset +
                    (progress * widget.displacement) -
                    (48.0 / 2);

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _state == _RefreshState.refreshing
                              ? M3eContainedLoadingIndicator(
                                key: const ValueKey('refreshing'),
                                indicatorColor: widget.color,
                                containerColor: widget.backgroundColor,
                              )
                              : M3eContainedLoadingIndicator(
                                key: const ValueKey('progress'),
                                progress: progress.clamp(0.0, 1.0),
                                indicatorColor: widget.color,
                                containerColor: widget.backgroundColor,
                              ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
