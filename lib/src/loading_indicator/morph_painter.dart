import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

/// Paints a morphing [RoundedPolygon] shape.
///
/// Handles sequential morphing across [polygons] and optional rotation.
class MorphPainter extends CustomPainter {
  MorphPainter({
    required this.polygons,
    required this.morphProgress,
    required this.rotation,
    required this.color,
    this.startAngle = 0.0,
  }) : assert(polygons.length >= 2, 'polygons must have at least 2 items'),
       super();

  /// Sequence of polygons to morph through.
  final List<RoundedPolygon> polygons;

  /// Progress across the sequence: 0..(polygons.length - 1) continuous,
  /// or 0..1 for two-polygon determinate case.
  /// For indeterminate, this is driven by animation controller.
  final double morphProgress;

  /// Rotation in radians (applied after morph).
  final double rotation;

  final Color color;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final n = polygons.length;
    if (n == 0) return;
    if (n == 1) {
      _paintSingle(canvas, size, polygons.first);
      return;
    }

    // Fast path for 2-polygon case (indeterminate per-cycle): morphProgress
    // is springFraction 0..1.14 which should be passed directly to Morph
    // to allow overshoot (AOSP Spring overshoot 14% → 102.6°).
    if (n == 2) {
      final path = Morph(
        polygons[0],
        polygons[1],
      ).toPath(progress: morphProgress, startAngle: startAngle);
      final matrix =
          Matrix4.identity()
            ..translateByDouble(size.width / 2, size.height / 2, 0, 1)
            ..rotateZ(rotation)
            ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1)
            ..scaleByDouble(size.width, size.height, 1.0, 1.0);
      final transformed = path.transform(matrix.storage);
      canvas.drawPath(
        transformed,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
      return;
    }

    // General n-polygon case (determinate 0..n-1, no overshoot)
    final clamped = morphProgress.clamp(0.0, (n - 1).toDouble());
    final idx = clamped.floor().clamp(0, n - 2);
    final localT = (clamped - idx).clamp(0.0, 1.0);
    final morph = Morph(polygons[idx], polygons[idx + 1]);

    // Build path in 0..1 normalized space, then scale + rotate
    final path = morph.toPath(progress: localT, startAngle: startAngle);

    // Scale to size
    final matrix =
        Matrix4.identity()
          ..translateByDouble(size.width / 2, size.height / 2, 0, 1)
          ..rotateZ(rotation)
          ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1)
          ..scaleByDouble(size.width, size.height, 1.0, 1.0);

    final transformed = path.transform(matrix.storage);

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    canvas.drawPath(transformed, paint);
  }

  void _paintSingle(Canvas canvas, Size size, RoundedPolygon polygon) {
    final path = polygon.toPath(startAngle: startAngle);
    final matrix =
        Matrix4.identity()
          ..translateByDouble(size.width / 2, size.height / 2, 0, 1)
          ..rotateZ(rotation)
          ..translateByDouble(-size.width / 2, -size.height / 2, 0, 1)
          ..scaleByDouble(size.width, size.height, 1.0, 1.0);
    final transformed = path.transform(matrix.storage);
    canvas.drawPath(
      transformed,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant MorphPainter oldDelegate) =>
      oldDelegate.morphProgress != morphProgress ||
      oldDelegate.rotation != rotation ||
      oldDelegate.color != color ||
      oldDelegate.polygons != polygons ||
      oldDelegate.startAngle != startAngle;
}

/// Determinate helper: maps 0..1 progress to polygon sequence.
double determinateMorphProgress(double progress, int polygonCount) {
  final clamped = progress.clamp(0.0, 1.0);
  return clamped * (polygonCount - 1);
}
