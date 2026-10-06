import 'package:flutter/material.dart';

import 'expressive_shapes.dart';
import 'shape_clipper.dart';

/// A versatile widget that displays any of the 35 M3 Expressive shapes.
///
/// Handles solid color fill, image clipping, border, and optional RTL mirroring
/// for directional shapes.
///
/// ```dart
/// // Static shape
/// M3eShape(
///   shape: MaterialShapes.flower,
///   size: 80,
///   color: Colors.purple,
/// )
///
/// // With image
/// M3eShape(
///   shape: MaterialShapes.heart,
///   size: 80,
///   image: AssetImage('assets/avatar.jpg'),
/// )
///
/// // Enum shorthand
/// M3eShape.fromId(
///   id: M3eShapeId.flower,
///   size: 80,
///   color: Colors.purple,
/// )
/// ```
class M3eShape extends StatelessWidget {
  const M3eShape({
    super.key,
    required this.shape,
    this.size = 42,
    this.color = Colors.purple,
    this.image,
    this.border,
    this.startAngle = 0.0,
    this.rtlAware = false,
    this.semanticsLabel,
  }) : id = null,
       assert(size > 0);

  /// Create from [M3eShapeId] enum.
  const M3eShape.fromId({
    super.key,
    required M3eShapeId id,
    this.size = 42,
    this.color = Colors.purple,
    this.image,
    this.border,
    this.startAngle = 0.0,
    this.rtlAware = false,
    this.semanticsLabel,
  }) : id = id,
       shape = null;

  /// Direct polygon.
  final RoundedPolygon? shape;

  /// Enum-based shape id (alternative to [shape]).
  final M3eShapeId? id;

  /// Diameter / width+height. Square bounding box.
  final double size;

  /// Fill color when [image] is null.
  final Color color;

  /// Optional image clipped to shape.
  final ImageProvider? image;

  /// Optional border drawn around the shape.
  final BorderSide? border;

  /// Rotation of the shape in degrees.
  final double startAngle;

  /// If true, mirrors directional shapes in RTL.
  final bool rtlAware;

  /// Semantics label.
  final String? semanticsLabel;

  RoundedPolygon get _polygon {
    if (shape != null) return shape!;
    if (id != null) return id!.polygon;
    throw StateError('M3eShape requires either shape or id');
  }

  @override
  Widget build(BuildContext context) {
    final polygon = _polygon;
    final direction = Directionality.maybeOf(context);
    final isRtl = direction == TextDirection.rtl;
    // Directional mirroring: scaleX = -1 when rtlAware && isRtl && directional-ish.
    // For generic polygon we apply horizontal flip via Transform when needed.
    // Detect if id is directional, or if not, allow manual rtlAware to flip any shape.
    final shouldMirror = rtlAware && isRtl;

    Widget content = SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: M3eShapeClipper(polygon: polygon, startAngle: startAngle),
        child:
            image != null
                ? Image(
                  image: image!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (_, __, ___) => ColoredBox(color: color),
                )
                : ColoredBox(color: color),
      ),
    );

    if (border != null &&
        border!.style != BorderStyle.none &&
        border!.width > 0) {
      // Overlay border using ShapeDecoration with same shape.
      // We use a Stack to keep clipping consistent.
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: RoundedPolygonBorder(
                  polygon: polygon,
                  side: border!,
                  startAngle: startAngle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (shouldMirror) {
      content = Transform.flip(flipX: true, child: content);
    }

    if (semanticsLabel != null) {
      content = Semantics(
        label: semanticsLabel,
        image: image != null,
        child: content,
      );
    }

    // Ensure outer SizedBox for flip to work correctly.
    return SizedBox(width: size, height: size, child: content);
  }
}
