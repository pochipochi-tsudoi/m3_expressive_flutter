import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

/// Clips a widget to a [RoundedPolygon] shape.
///
/// The polygon is expected to be normalized (0..1). It is scaled to the
/// incoming [Size] via [Path] transform.
///
/// Example:
/// ```dart
/// ClipPath(
///   clipper: M3eShapeClipper(polygon: MaterialShapes.flower),
///   child: Image.asset('avatar.png', fit: BoxFit.cover),
/// )
/// ```
class M3eShapeClipper extends CustomClipper<Path> {
  const M3eShapeClipper({required this.polygon, this.startAngle = 0.0});

  final RoundedPolygon polygon;
  final double startAngle;

  @override
  Path getClip(Size size) {
    final path = polygon.toPath(startAngle: startAngle);
    final matrix =
        Matrix4.identity()..scaleByDouble(size.width, size.height, 1.0, 1.0);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldReclip(covariant M3eShapeClipper oldClipper) =>
      oldClipper.polygon != polygon || oldClipper.startAngle != startAngle;
}

/// Clips a widget to a morphed shape between two polygons.
///
/// `progress` 0 = [start], 1 = [end].
class M3eMorphClipper extends CustomClipper<Path> {
  M3eMorphClipper({
    required this.start,
    required this.end,
    required this.progress,
    this.startAngle = 0.0,
  }) : morph = Morph(start, end);

  final RoundedPolygon start;
  final RoundedPolygon end;
  final double progress;
  final double startAngle;
  final Morph morph;

  @override
  Path getClip(Size size) {
    final path = morph.toPath(progress: progress, startAngle: startAngle);
    final matrix =
        Matrix4.identity()..scaleByDouble(size.width, size.height, 1.0, 1.0);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldReclip(covariant M3eMorphClipper oldClipper) =>
      oldClipper.start != start ||
      oldClipper.end != end ||
      oldClipper.progress != progress ||
      oldClipper.startAngle != startAngle;
}

/// Convenience for directly creating a path from polygon + size.
extension PolygonPath on RoundedPolygon {
  /// Returns a [Path] scaled to [size].
  Path toPathForSize(Size size, {double startAngle = 0.0}) {
    final path = toPath(startAngle: startAngle);
    final matrix =
        Matrix4.identity()..scaleByDouble(size.width, size.height, 1.0, 1.0);
    return path.transform(matrix.storage);
  }
}

/// Convenience for morph.
extension MorphPath on Morph {
  Path toPathForSize(
    Size size, {
    required double progress,
    double startAngle = 0.0,
  }) {
    final path = toPath(progress: progress, startAngle: startAngle);
    final matrix =
        Matrix4.identity()..scaleByDouble(size.width, size.height, 1.0, 1.0);
    return path.transform(matrix.storage);
  }
}
