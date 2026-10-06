import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

/// A [ShapeBorder] that draws a [RoundedPolygon] (one of the 35 M3 Expressive
/// iconic shapes) scaled to the widget's [Rect].
///
/// Thin wrapper around [RoundedPolygonBorder] / [MorphBorder] from `material_3p`
/// with an expressive-friendly API and lerp support.
///
/// Example (static):
/// ```dart
/// Container(
///   decoration: ShapeDecoration(
///     color: Colors.purple,
///     shape: M3eShapeBorder(polygon: MaterialShapes.flower),
///   ),
///   width: 100, height: 100,
/// )
/// ```
///
/// Example (morph via lerp):
/// ```dart
/// ShapeBorder.lerp(
///   M3eShapeBorder(polygon: MaterialShapes.circle),
///   M3eShapeBorder(polygon: MaterialShapes.square),
///   t,
/// )
/// ```
class M3eShapeBorder extends RoundedPolygonBorder {
  M3eShapeBorder({
    super.side = BorderSide.none,
    super.strokeCap,
    super.strokeJoin,
    super.strokeMiterLimit,
    super.squash = 0.0,
    required super.polygon,
    super.startAngle = 0.0,
  });

  @override
  M3eShapeBorder copyWith({
    BorderSide? side,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? squash,
    RoundedPolygon? polygon,
    double? startAngle,
  }) => M3eShapeBorder(
    side: side ?? this.side,
    strokeCap: strokeCap ?? this.strokeCap,
    strokeJoin: strokeJoin ?? this.strokeJoin,
    strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
    squash: squash ?? this.squash,
    polygon: polygon ?? this.polygon,
    startAngle: startAngle ?? this.startAngle,
  );

  @override
  M3eShapeBorder scale(double t) => M3eShapeBorder(
    side: side.scale(t),
    strokeCap: strokeCap,
    strokeJoin: strokeJoin,
    strokeMiterLimit: strokeMiterLimit,
    squash: squash,
    polygon: polygon,
    startAngle: startAngle,
  );

  @override
  String toString() =>
      'M3eShapeBorder($polygon, startAngle: $startAngle, $side)';
}

/// A [ShapeBorder] that morphs between two [RoundedPolygon]s.
///
/// Progress 0 = [start], 1 = [end]. Values outside [0,1] produce overshoot
/// (useful for bouncy springs).
///
/// ```dart
/// M3eMorphBorder(
///   morph: Morph(MaterialShapes.circle, MaterialShapes.heart),
///   progress: animation.value,
/// )
/// ```
class M3eMorphBorder extends MorphBorder {
  // ignore: prefer_const_constructors_in_immutables
  M3eMorphBorder({
    super.side = BorderSide.none,
    super.strokeCap,
    super.strokeJoin,
    super.strokeMiterLimit,
    super.squash = 0.0,
    required super.morph,
    required super.progress,
    super.startAngle = 0.0,
  });

  /// Convenience constructor from two polygons.
  factory M3eMorphBorder.fromPolygons({
    BorderSide side = BorderSide.none,
    StrokeCap strokeCap = StrokeCap.butt,
    StrokeJoin strokeJoin = StrokeJoin.miter,
    double strokeMiterLimit = 4.0,
    double squash = 0.0,
    required RoundedPolygon start,
    required RoundedPolygon end,
    required double progress,
    double startAngle = 0.0,
  }) => M3eMorphBorder(
    side: side,
    strokeCap: strokeCap,
    strokeJoin: strokeJoin,
    strokeMiterLimit: strokeMiterLimit,
    squash: squash,
    morph: Morph(start, end),
    progress: progress,
    startAngle: startAngle,
  );

  @override
  M3eMorphBorder copyWith({
    BorderSide? side,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? squash,
    Morph? morph,
    double? progress,
    double? startAngle,
  }) => M3eMorphBorder(
    side: side ?? this.side,
    strokeCap: strokeCap ?? this.strokeCap,
    strokeJoin: strokeJoin ?? this.strokeJoin,
    strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
    squash: squash ?? this.squash,
    morph: morph ?? this.morph,
    progress: progress ?? this.progress,
    startAngle: startAngle ?? this.startAngle,
  );

  @override
  M3eMorphBorder scale(double t) => M3eMorphBorder(
    side: side.scale(t),
    strokeCap: strokeCap,
    strokeJoin: strokeJoin,
    strokeMiterLimit: strokeMiterLimit,
    squash: squash,
    morph: morph,
    progress: progress,
    startAngle: startAngle,
  );
}

/// Extension for converting a [RoundedPolygon] to a [ShapeBorder] succinctly.
extension RoundedPolygonToBorder on RoundedPolygon {
  /// Create a [M3eShapeBorder] from this polygon.
  M3eShapeBorder toShapeBorder({
    BorderSide side = BorderSide.none,
    double squash = 0.0,
    double startAngle = 0.0,
  }) => M3eShapeBorder(
    side: side,
    squash: squash,
    polygon: this,
    startAngle: startAngle,
  );
}
