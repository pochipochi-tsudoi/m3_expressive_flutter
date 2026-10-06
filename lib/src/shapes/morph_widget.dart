import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

import 'shape_clipper.dart';

/// Animates between two [RoundedPolygon] shapes.
///
/// Internally uses [Morph] with an [AnimationController]-driven progress.
///
/// Respects [MediaQuery.disableAnimations] — if true, jumps to the end shape.
///
/// ```dart
/// MorphShape(
///   start: MaterialShapes.circle,
///   end: MaterialShapes.flower,
///   progress: _selected ? 1.0 : 0.0,
///   size: 80,
///   color: Colors.purple,
/// )
/// ```
class MorphShape extends StatelessWidget {
  const MorphShape({
    super.key,
    required this.start,
    required this.end,
    required this.progress,
    this.size = 42,
    this.color = Colors.purple,
    this.image,
    this.startAngle = 0.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubic,
    this.animate = true,
    this.rtlAware = false,
  });

  final RoundedPolygon start;
  final RoundedPolygon end;
  final double progress; // 0..1 (or outside for overshoot)
  final double size;
  final Color color;
  final ImageProvider? image;
  final double startAngle;
  final Duration duration;
  final Curve curve;
  final bool animate;
  final bool rtlAware;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final effectiveProgress = progress.clamp(0.0, 1.0);

    if (!animate || disableAnimations) {
      return _MorphShapeStatic(
        start: start,
        end: end,
        progress: effectiveProgress,
        size: size,
        color: color,
        image: image,
        startAngle: startAngle,
        rtlAware: rtlAware,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: effectiveProgress, end: effectiveProgress),
      duration: duration,
      curve: curve,
      builder:
          (context, value, _) => _MorphShapeStatic(
            start: start,
            end: end,
            progress: value,
            size: size,
            color: color,
            image: image,
            startAngle: startAngle,
            rtlAware: rtlAware,
          ),
    );
  }
}

class _MorphShapeStatic extends StatelessWidget {
  const _MorphShapeStatic({
    required this.start,
    required this.end,
    required this.progress,
    required this.size,
    required this.color,
    this.image,
    required this.startAngle,
    required this.rtlAware,
  });

  final RoundedPolygon start;
  final RoundedPolygon end;
  final double progress;
  final double size;
  final Color color;
  final ImageProvider? image;
  final double startAngle;
  final bool rtlAware;

  @override
  Widget build(BuildContext context) {
    final isRtl =
        rtlAware && Directionality.maybeOf(context) == TextDirection.rtl;

    Widget content = SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: M3eMorphClipper(
          start: start,
          end: end,
          progress: progress,
          startAngle: startAngle,
        ),
        child:
            image != null
                ? Image(
                  image: image!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                )
                : ColoredBox(color: color),
      ),
    );

    if (isRtl) {
      content = Transform.flip(flipX: true, child: content);
    }

    return SizedBox(width: size, height: size, child: content);
  }
}

/// Implicitly animated shape morph driven by changing [shape].
///
/// When [shape] changes, this widget animates from the old shape to the new
/// one using [Morph].
///
/// ```dart
/// AnimatedM3eShape(
///   shape: _isFlower ? MaterialShapes.flower : MaterialShapes.circle,
///   size: 80,
///   color: Colors.purple,
/// )
/// ```
class AnimatedM3eShape extends ImplicitlyAnimatedWidget {
  const AnimatedM3eShape({
    super.key,
    required this.shape,
    this.size = 42,
    this.color = Colors.purple,
    this.image,
    this.startAngle = 0.0,
    this.rtlAware = false,
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.easeInOutCubic,
    super.onEnd,
  });

  final RoundedPolygon shape;
  final double size;
  final Color color;
  final ImageProvider? image;
  final double startAngle;
  final bool rtlAware;

  @override
  AnimatedWidgetBaseState<AnimatedM3eShape> createState() =>
      _AnimatedM3eShapeState();
}

class _AnimatedM3eShapeState extends AnimatedWidgetBaseState<AnimatedM3eShape> {
  _ShapeTween? _tween;

  @override
  void initState() {
    super.initState();
    _tween = _ShapeTween(begin: widget.shape, end: widget.shape);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tween =
        visitor(
              _tween,
              widget.shape,
              (dynamic value) => _ShapeTween(
                begin: value as RoundedPolygon,
                end: widget.shape,
              ),
            )
            as _ShapeTween?;
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: ClipPath(
          clipper: M3eShapeClipper(
            polygon: widget.shape,
            startAngle: widget.startAngle,
          ),
          child:
              widget.image != null
                  ? Image(
                    image: widget.image!,
                    fit: BoxFit.cover,
                    width: widget.size,
                    height: widget.size,
                  )
                  : ColoredBox(color: widget.color),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final morph = _tween!.morphFor(t);
        final isRtl =
            widget.rtlAware &&
            Directionality.maybeOf(context) == TextDirection.rtl;
        Widget content = SizedBox(
          width: widget.size,
          height: widget.size,
          child: ClipPath(
            clipper: _AnimatedMorphClipper(
              morph: morph,
              progress: t,
              startAngle: widget.startAngle,
            ),
            child:
                widget.image != null
                    ? Image(
                      image: widget.image!,
                      fit: BoxFit.cover,
                      width: widget.size,
                      height: widget.size,
                    )
                    : ColoredBox(color: widget.color),
          ),
        );
        if (isRtl) content = Transform.flip(flipX: true, child: content);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: content,
        );
      },
    );
  }
}

class _ShapeTween extends Tween<RoundedPolygon> {
  _ShapeTween({required super.begin, required super.end});

  Morph? _morph;

  Morph morphFor(double t) {
    _morph ??= Morph(begin!, end!);
    return _morph!;
  }

  @override
  RoundedPolygon lerp(double t) {
    // Not used directly; we use morph.
    return begin!;
  }
}

class _AnimatedMorphClipper extends CustomClipper<Path> {
  _AnimatedMorphClipper({
    required this.morph,
    required this.progress,
    required this.startAngle,
  });

  final Morph morph;
  final double progress;
  final double startAngle;

  @override
  Path getClip(Size size) {
    final path = morph.toPath(progress: progress, startAngle: startAngle);
    final matrix =
        Matrix4.identity()..scaleByDouble(size.width, size.height, 1.0, 1.0);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldReclip(covariant _AnimatedMorphClipper oldClipper) =>
      oldClipper.morph != morph ||
      oldClipper.progress != progress ||
      oldClipper.startAngle != startAngle;
}

/// Convenience for sequencing through multiple shapes (e.g. for showcase).
///
/// Progress is driven externally (e.g. via PageView or animation).
class ShapeSequenceMorph extends StatelessWidget {
  const ShapeSequenceMorph({
    super.key,
    required this.shapes,
    required this.progress,
    this.size = 42,
    this.color = Colors.purple,
    this.startAngle = 0.0,
  }) : assert(shapes.length >= 2);

  final List<RoundedPolygon> shapes;
  final double progress; // 0..1 maps across whole sequence
  final double size;
  final Color color;
  final double startAngle;

  @override
  Widget build(BuildContext context) {
    final n = shapes.length;
    final scaled = progress * (n - 1);
    final index = scaled.floor().clamp(0, n - 2);
    final localT = scaled - index;
    final start = shapes[index];
    final end = shapes[index + 1];
    return MorphShape(
      start: start,
      end: end,
      progress: localT,
      size: size,
      color: color,
      startAngle: startAngle,
      animate: false,
    );
  }
}
