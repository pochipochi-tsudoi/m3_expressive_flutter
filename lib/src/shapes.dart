export 'shapes/circle.dart';
export 'shapes/expressive_shapes.dart';
export 'shapes/shape_border.dart';
export 'shapes/shape_clipper.dart';
export 'shapes/m3e_shape.dart';
export 'shapes/morph_widget.dart';

import 'package:m3_expressive_flutter/src/shapes/circle.dart' as shapes_;

/// Legacy accessor for backward compatibility.
///
/// Prefer `M3eShape` / `M3eShapes` / `MaterialShapes` directly.
@Deprecated('Use M3eShape or MaterialShapes instead')
class Shapes {
  const Shapes();
  static const Circle = shapes_.Circle.new;

  shapes_.Circle get circle => const shapes_.Circle();
}
