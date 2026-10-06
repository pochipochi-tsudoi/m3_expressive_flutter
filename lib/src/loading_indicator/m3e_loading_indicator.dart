import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart' hide Cubic;

import 'loading_indicator_defaults.dart';
import 'morph_painter.dart';

/// Material 3 Expressive Loading Indicator (uncontained).
///
/// - `progress == null` → indeterminate: loops through 7 shapes with morph + rotation.
/// - `progress` (0..1) → determinate: interpolates between [polygons] by progress.
///
/// ```dart
/// // Indeterminate (default)
/// M3eLoadingIndicator()
/// M3eShapes.LoadingIndicator() // shorthand
///
/// // Determinate
/// M3eLoadingIndicator(progress: 0.42)
/// M3eShapes.LoadingIndicator(progress: 0.6)
/// ```
class M3eLoadingIndicator extends StatefulWidget {
  const M3eLoadingIndicator({
    super.key,
    this.progress,
    this.color,
    this.size = M3eLoadingIndicatorDefaults.indicatorSize,
    this.polygons,
    this.semanticsLabel,
    this.semanticsValue,
  }) : assert(size > 0, 'size must be > 0'),
       assert(
         progress == null || (progress >= 0.0 && progress <= 1.0),
         'progress must be between 0.0 and 1.0',
       );

  /// Progress 0..1. `null` means indeterminate (auto-animated).
  final double? progress;

  /// Indicator color. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Size of the indicator (square). Default 38dp.
  final double size;

  /// Polygons to morph between. Defaults to
  /// [M3eLoadingIndicatorDefaults.indeterminatePolygons] (indeterminate)
  /// or [M3eLoadingIndicatorDefaults.determinatePolygons] (determinate).
  /// Must have at least 2 items if provided.
  final List<RoundedPolygon>? polygons;

  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  State<M3eLoadingIndicator> createState() => _M3eLoadingIndicatorState();
}

class _M3eLoadingIndicatorState extends State<M3eLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Spring-approximated fraction 0..1.14→1 per 650ms cycle (see AOSP Spring k=200, damping 0.6)
  late Animation<double> _springFraction;
  int _baseCount = 0;

  static const _durationPerShape = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _durationPerShape);
    _setupSpringAnimation();
    _controller.addStatusListener(_onStatus);
    if (widget.progress == null) {
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.progress == null) {
      // Each cycle = one morph step (650ms)
      _baseCount++;
      _controller.forward(from: 0);
    }
  }

  void _setupSpringAnimation() {
    // Approximate AOSP Spring (stiffness 200, dampingRatio 0.6) with
    // TweenSequence matching React's keyTimes/keySplines:
    // times: 0, 0.35, 0.52, 0.85, 1
    // values: 0, 1.0, 1.14, 1.0, 1.0
    // splines: 0.4 0 0.9 0.6; 0.1 0.4 0.4 1; 0.45 0 0.4 1; 0 0 1 1
    _springFraction = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.0,
        ).chain(CurveTween(curve: const Cubic(0.4, 0.0, 0.9, 0.6))),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.14,
        ).chain(CurveTween(curve: const Cubic(0.1, 0.4, 0.4, 1.0))),
        weight: 17,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.14,
          end: 1.0,
        ).chain(CurveTween(curve: const Cubic(0.45, 0.0, 0.4, 1.0))),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 15,
      ),
    ]).animate(_controller);
  }

  List<RoundedPolygon> _effectivePolygons({required bool isIndeterminate}) {
    if (widget.polygons != null) {
      assert(
        widget.polygons!.length >= 2,
        'polygons must have at least 2 items',
      );
      return widget.polygons!;
    }
    return isIndeterminate
        ? M3eLoadingIndicatorDefaults.indeterminatePolygons
        : M3eLoadingIndicatorDefaults.determinatePolygons;
  }

  @override
  void didUpdateWidget(covariant M3eLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      if (widget.progress == null) {
        _baseCount = 0;
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
    if (oldWidget.polygons != widget.polygons) {
      if (widget.progress == null) {
        // Reset base on polygons change
        _baseCount = 0;
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIndeterminate = widget.progress == null;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (!isIndeterminate) {
      return _buildDeterminate(context);
    }

    if (disableAnimations) {
      return _buildStatic(context);
    }

    return _buildIndeterminate(context);
  }

  Widget _buildDeterminate(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.primary;
    final polygons = _effectivePolygons(isIndeterminate: false);
    final progress = widget.progress!.clamp(0.0, 1.0);
    final morphProgress = determinateMorphProgress(progress, polygons.length);

    return Semantics(
      label: widget.semanticsLabel ?? 'Loading',
      value: widget.semanticsValue ?? '${(progress * 100).round()}%',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: MorphPainter(
            polygons: polygons,
            morphProgress: morphProgress,
            rotation: 0,
            color: color,
          ),
          size: Size(widget.size, widget.size),
        ),
      ),
    );
  }

  Widget _buildIndeterminate(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.primary;
    final polygons = _effectivePolygons(isIndeterminate: true);

    return Semantics(
      label: widget.semanticsLabel ?? 'Loading',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final timeFraction = _controller.value; // 0..1 linear
            final springFraction = _springFraction.value; // 0..1.14->1
            final n = polygons.length;
            final base = _baseCount % n;
            final next = (base + 1) % n;
            // Two-polygon morph for this cycle
            final pair = [polygons[base], polygons[next]];

            // AOSP rotation: (50+90)*base + 50*timeFraction + 90*springFraction
            const constantPerShape = 50.0;
            const extraPerShape = 90.0;
            final rotationDeg =
                (constantPerShape + extraPerShape) * _baseCount +
                constantPerShape * timeFraction +
                extraPerShape * springFraction;
            final rotationRad = rotationDeg * math.pi / 180;

            return CustomPaint(
              painter: MorphPainter(
                polygons: pair,
                morphProgress: springFraction.clamp(0.0, 1.14),
                rotation: rotationRad % (2 * math.pi),
                color: color,
              ),
              size: Size(widget.size, widget.size),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatic(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.primary;
    final polygons = _effectivePolygons(isIndeterminate: true);
    return Semantics(
      label: widget.semanticsLabel ?? 'Loading',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: MorphPainter(
            polygons: [polygons.first, polygons[1 % polygons.length]],
            morphProgress: 0,
            rotation: 0,
            color: color,
          ),
          size: Size(widget.size, widget.size),
        ),
      ),
    );
  }
}
