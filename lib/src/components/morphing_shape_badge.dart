import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart'
    hide MaterialShapes, RoundedPolygon;
import 'package:motor/motor.dart';
import 'package:m3_expressive_flutter/src/shapes/expressive_shapes.dart';
import 'package:m3_expressive_flutter/src/shapes/shape_border.dart';

/// An autonomous breathing badge that morphs between two shapes with a resting pause.
class MorphingShapeBadge extends StatefulWidget {
  const MorphingShapeBadge({
    super.key,
    required this.fromShape,
    required this.toShape,
    this.child,
    this.size = 56.0,
    this.color,
    this.turns = 0.25,
    this.restBetween = const Duration(milliseconds: 1000),
  });

  final RoundedPolygon fromShape;
  final RoundedPolygon toShape;
  final Widget? child;
  final double size;
  final Color? color;
  final double turns;
  final Duration restBetween;

  @override
  State<MorphingShapeBadge> createState() => _MorphingShapeBadgeState();
}

class _MorphingShapeBadgeState extends State<MorphingShapeBadge> {
  bool _forward = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(widget.restBetween + const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _forward = !_forward);
        _scheduleNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.color ?? cs.primaryContainer;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final borderFrom = M3eShapeBorder(polygon: widget.fromShape);
    final borderTo = M3eShapeBorder(polygon: widget.toShape);

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.expressiveSpatialSlow(),
      value: _forward ? 1.0 : 0.0,
      active: !reduce,
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        final border = ShapeBorder.lerp(borderFrom, borderTo, tc) ?? borderFrom;

        return SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: t * widget.turns * 2 * math.pi,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: ShapeDecoration(
                    color: bg,
                    shape: border,
                  ),
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

/// A subtle background bloom decoration that gently breathes with a large expressive shape.
class ShapeBloomBackdrop extends StatefulWidget {
  const ShapeBloomBackdrop({
    super.key,
    this.shape,
    this.size = 280.0,
    this.color,
    this.period = const Duration(seconds: 4),
  });

  final RoundedPolygon? shape;
  final double size;
  final Color? color;
  final Duration period;

  @override
  State<ShapeBloomBackdrop> createState() => _ShapeBloomBackdropState();
}

class _ShapeBloomBackdropState extends State<ShapeBloomBackdrop> {
  bool _expanded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLoop() {
    _timer = Timer.periodic(widget.period, (_) {
      if (mounted) {
        setState(() => _expanded = !_expanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.color ?? cs.primary.withValues(alpha: 0.06);
    final effectiveShape = widget.shape ?? MaterialShapes.clover4Leaf;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.standardSpatialSlow(),
      value: _expanded ? 1.0 : 0.0,
      active: !reduce,
      builder: (context, t, _) {
        final scale = 0.92 + 0.16 * t;
        final rotation = t * 0.1 * math.pi;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: ShapeDecoration(
                color: bg,
                shape: M3eShapeBorder(polygon: effectiveShape),
              ),
            ),
          ),
        );
      },
    );
  }
}
