import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

/// Defaults for [M3eLoadingIndicator] / [M3eContainedLoadingIndicator].
///
/// Mirrors `LoadingIndicatorDefaults` from Compose Material 3 Expressive.
abstract final class M3eLoadingIndicatorDefaults {
  const M3eLoadingIndicatorDefaults._();

  /// Default indicator size (active morphing shape) — 38dp.
  static const double indicatorSize = 38.0;

  /// Default container size — 48dp (square).
  static const double containerSize = 48.0;

  /// Default container shape — fully rounded (pill / StadiumBorder).
  static const ShapeBorder containerShape = StadiumBorder();

  /// Indeterminate polygons — 7 shapes cycled indefinitely.
  ///
  /// AOSP: [SoftBurst, Cookie9Sided, Pentagon, Pill, Sunny, Cookie4Sided, Oval]
  static List<RoundedPolygon> get indeterminatePolygons => [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];

  /// Determinate polygons — 2 shapes interpolated by progress 0..1.
  ///
  /// AOSP: [Circle rotated 18°, SoftBurst]
  static List<RoundedPolygon> get determinatePolygons => [
    _rotatedCircle,
    MaterialShapes.softBurst,
  ];

  // Circle rotated 18° (360/20) for smoother morph to SoftBurst.
  static final RoundedPolygon _rotatedCircle = MaterialShapes.circle
      .transformedWithMatrix4(Matrix4.rotationZ(18 * math.pi / 180));
}
