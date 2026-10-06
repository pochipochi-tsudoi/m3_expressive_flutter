import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

import 'm3e_shape.dart';

/// Legacy circle widget — now delegates to [M3eShape] with [MaterialShapes.circle].
///
/// Kept for backward compatibility. Prefer [M3eShape] or [M3eShape.fromId] directly.
///
/// ```dart
/// // Old
/// Circle(size: 48, color: Colors.purple)
///
/// // New (equivalent)
/// M3eShape(shape: MaterialShapes.circle, size: 48, color: Colors.purple)
/// // or
/// M3eShape.fromId(id: M3eShapeId.circle, size: 48)
/// ```
class Circle extends StatelessWidget {
  /// Diameter of the circle. Defaults to 42.
  final double size;

  /// Fill color when [image] is not provided. Defaults to [Colors.purple].
  final Color color;

  /// If provided, the circle will display this image clipped to a circle.
  /// e.g. AssetImage('assets/foo.png'), NetworkImage('...'), MemoryImage(...)
  final ImageProvider? image;

  const Circle({
    super.key,
    this.size = 42,
    this.color = Colors.purple,
    this.image,
  }) : assert(size > 0);

  @override
  Widget build(BuildContext context) {
    // Delegate to M3eShape so all shapes share the same rendering path
    // (RoundedPolygon via ClipPath). Visual result is identical to ClipOval
    // but keeps parity with the M3 Expressive shape system.
    return M3eShape(
      shape: MaterialShapes.circle,
      size: size,
      color: color,
      image: image,
    );
  }
}
