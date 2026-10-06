library expressive_shapes;

import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

// LoadingIndicator widgets — shapes/ -> loading_indicator/ is one-way, no cycle.
import '../loading_indicator/m3e_loading_indicator.dart';
import '../loading_indicator/m3e_contained_loading_indicator.dart';

/// Re-export core shape types for convenience.
///
/// Users can also import directly from `material_3p` or
/// `androidx_graphics_shapes` if needed.
export 'package:androidx_graphics_shapes/androidx_graphics_shapes.dart'
    show RoundedPolygon, Morph, CornerRounding, Cubic, Feature;

export 'package:material_3p/material_shapes.dart'
    show
        MaterialShapes,
        RoundedPolygonBorder,
        MorphBorder,
        DynamicPathBorder,
        StaticPathBorder,
        RoundedPolygonExtension,
        MorphExtension;

/// All 35 M3 Expressive iconic shapes.
///
/// Provides a unified enumeration over [MaterialShapes] with metadata
/// for iteration, lookup by name, and category grouping.
///
/// Usage:
/// ```dart
/// // By enum
/// final polygon = M3eShapeId.flower.polygon;
///
/// // By name
/// final polygon = M3eShapes.byName('heart');
///
/// // All
/// for (final entry in M3eShapes.all) { ... }
/// ```
enum M3eShapeId {
  circle,
  square,
  slanted,
  arch,
  fan,
  arrow,
  semiCircle,
  oval,
  pill,
  triangle,
  diamond,
  clamShell,
  pentagon,
  gem,
  sunny,
  verySunny,
  cookie4Sided,
  cookie6Sided,
  cookie7Sided,
  cookie9Sided,
  cookie12Sided,
  ghostish,
  clover4Leaf,
  clover8Leaf,
  burst,
  softBurst,
  boom,
  softBoom,
  flower,
  puffy,
  puffyDiamond,
  pixelCircle,
  pixelTriangle,
  bun,
  heart;

  /// The underlying [RoundedPolygon] for this shape.
  RoundedPolygon get polygon {
    switch (this) {
      case M3eShapeId.circle:
        return MaterialShapes.circle;
      case M3eShapeId.square:
        return MaterialShapes.square;
      case M3eShapeId.slanted:
        return MaterialShapes.slanted;
      case M3eShapeId.arch:
        return MaterialShapes.arch;
      case M3eShapeId.fan:
        return MaterialShapes.fan;
      case M3eShapeId.arrow:
        return MaterialShapes.arrow;
      case M3eShapeId.semiCircle:
        return MaterialShapes.semiCircle;
      case M3eShapeId.oval:
        return MaterialShapes.oval;
      case M3eShapeId.pill:
        return MaterialShapes.pill;
      case M3eShapeId.triangle:
        return MaterialShapes.triangle;
      case M3eShapeId.diamond:
        return MaterialShapes.diamond;
      case M3eShapeId.clamShell:
        return MaterialShapes.clamShell;
      case M3eShapeId.pentagon:
        return MaterialShapes.pentagon;
      case M3eShapeId.gem:
        return MaterialShapes.gem;
      case M3eShapeId.sunny:
        return MaterialShapes.sunny;
      case M3eShapeId.verySunny:
        return MaterialShapes.verySunny;
      case M3eShapeId.cookie4Sided:
        return MaterialShapes.cookie4Sided;
      case M3eShapeId.cookie6Sided:
        return MaterialShapes.cookie6Sided;
      case M3eShapeId.cookie7Sided:
        return MaterialShapes.cookie7Sided;
      case M3eShapeId.cookie9Sided:
        return MaterialShapes.cookie9Sided;
      case M3eShapeId.cookie12Sided:
        return MaterialShapes.cookie12Sided;
      case M3eShapeId.ghostish:
        return MaterialShapes.ghostish;
      case M3eShapeId.clover4Leaf:
        return MaterialShapes.clover4Leaf;
      case M3eShapeId.clover8Leaf:
        return MaterialShapes.clover8Leaf;
      case M3eShapeId.burst:
        return MaterialShapes.burst;
      case M3eShapeId.softBurst:
        return MaterialShapes.softBurst;
      case M3eShapeId.boom:
        return MaterialShapes.boom;
      case M3eShapeId.softBoom:
        return MaterialShapes.softBoom;
      case M3eShapeId.flower:
        return MaterialShapes.flower;
      case M3eShapeId.puffy:
        return MaterialShapes.puffy;
      case M3eShapeId.puffyDiamond:
        return MaterialShapes.puffyDiamond;
      case M3eShapeId.pixelCircle:
        return MaterialShapes.pixelCircle;
      case M3eShapeId.pixelTriangle:
        return MaterialShapes.pixelTriangle;
      case M3eShapeId.bun:
        return MaterialShapes.bun;
      case M3eShapeId.heart:
        return MaterialShapes.heart;
    }
  }

  /// Whether this shape is directional and should mirror in RTL.
  ///
  /// Directional shapes have a clear forward direction (e.g. arrow points
  /// right in LTR). They are mirrored when [TextDirection.rtl].
  bool get isDirectional {
    switch (this) {
      case M3eShapeId.arrow:
      case M3eShapeId.fan:
      case M3eShapeId.slanted:
      case M3eShapeId.semiCircle:
      case M3eShapeId.ghostish:
      case M3eShapeId.pixelTriangle:
      case M3eShapeId.bun:
        return true;
      default:
        return false;
    }
  }
}

/// Helper for [M3eShapeId].
abstract final class M3eShapes {
  const M3eShapes._();

  /// All 35 shapes in definition order.
  static const List<M3eShapeId> all = M3eShapeId.values;

  /// Lookup by case-sensitive name (e.g. 'heart', 'cookie9Sided').
  /// Returns null if not found.
  static M3eShapeId? tryByName(String name) {
    for (final id in M3eShapeId.values) {
      if (id.name == name) return id;
    }
    return null;
  }

  /// Lookup by name, throws if not found.
  static M3eShapeId byName(String name) {
    final id = tryByName(name);
    if (id == null) throw ArgumentError('Unknown M3e shape: $name');
    return id;
  }

  /// All polygons in [all] order.
  static List<RoundedPolygon> get allPolygons => [
    for (final id in all) id.polygon,
  ];

  // Category groupings (for docs / UI grouping)
  static const List<M3eShapeId> basic = [
    M3eShapeId.circle,
    M3eShapeId.square,
    M3eShapeId.pill,
    M3eShapeId.oval,
  ];

  static const List<M3eShapeId> geometric = [
    M3eShapeId.triangle,
    M3eShapeId.diamond,
    M3eShapeId.pentagon,
  ];

  static const List<M3eShapeId> directional = [
    M3eShapeId.arrow,
    M3eShapeId.fan,
    M3eShapeId.arch,
    M3eShapeId.semiCircle,
    M3eShapeId.slanted,
  ];

  static const List<M3eShapeId> organic = [
    M3eShapeId.clamShell,
    M3eShapeId.flower,
    M3eShapeId.puffy,
    M3eShapeId.puffyDiamond,
    M3eShapeId.gem,
    M3eShapeId.clover4Leaf,
    M3eShapeId.clover8Leaf,
    M3eShapeId.ghostish,
    M3eShapeId.bun,
    M3eShapeId.heart,
  ];

  static const List<M3eShapeId> cookies = [
    M3eShapeId.cookie4Sided,
    M3eShapeId.cookie6Sided,
    M3eShapeId.cookie7Sided,
    M3eShapeId.cookie9Sided,
    M3eShapeId.cookie12Sided,
  ];

  static const List<M3eShapeId> starburst = [
    M3eShapeId.sunny,
    M3eShapeId.verySunny,
    M3eShapeId.burst,
    M3eShapeId.softBurst,
    M3eShapeId.boom,
    M3eShapeId.softBoom,
  ];

  static const List<M3eShapeId> pixel = [
    M3eShapeId.pixelCircle,
    M3eShapeId.pixelTriangle,
  ];

  // ---------------------------------------------------------------------------
  // LoadingIndicator factories — shorthand for M3eLoadingIndicator
  // ---------------------------------------------------------------------------

  /// Shorthand for [M3eLoadingIndicator].
  ///
  /// Prefer `M3eLoadingIndicator()` directly; this is provided to satisfy
  /// `M3eShapes.LoadingIndicator()` as requested.
  ///
  /// ```dart
  /// M3eShapes.LoadingIndicator()
  /// M3eShapes.LoadingIndicator(progress: 0.6)
  /// M3eShapes.ContainedLoadingIndicator()
  /// ```
  // ignore: non_constant_identifier_names
  static Widget LoadingIndicator({
    double? progress,
    Color? color,
    double size = 38.0,
    List<RoundedPolygon>? polygons,
    String? semanticsLabel,
    String? semanticsValue,
    Key? key,
  }) => M3eLoadingIndicator(
    key: key,
    progress: progress,
    color: color,
    size: size,
    polygons: polygons,
    semanticsLabel: semanticsLabel,
    semanticsValue: semanticsValue,
  );

  /// Lower-camel alias for [LoadingIndicator].
  static Widget loadingIndicator({
    double? progress,
    Color? color,
    double size = 38.0,
    List<RoundedPolygon>? polygons,
    String? semanticsLabel,
    String? semanticsValue,
    Key? key,
  }) => LoadingIndicator(
    progress: progress,
    color: color,
    size: size,
    polygons: polygons,
    semanticsLabel: semanticsLabel,
    semanticsValue: semanticsValue,
    key: key,
  );

  /// Shorthand for [M3eContainedLoadingIndicator].
  // ignore: non_constant_identifier_names
  static Widget ContainedLoadingIndicator({
    double? progress,
    Color? containerColor,
    Color? indicatorColor,
    ShapeBorder? containerShape,
    double containerSize = 48.0,
    double indicatorSize = 38.0,
    List<RoundedPolygon>? polygons,
    String? semanticsLabel,
    String? semanticsValue,
    Key? key,
  }) => M3eContainedLoadingIndicator(
    key: key,
    progress: progress,
    containerColor: containerColor,
    indicatorColor: indicatorColor,
    containerShape: containerShape,
    containerSize: containerSize,
    indicatorSize: indicatorSize,
    polygons: polygons,
    semanticsLabel: semanticsLabel,
    semanticsValue: semanticsValue,
  );

  /// Lower-camel alias for [ContainedLoadingIndicator].
  static Widget containedLoadingIndicator({
    double? progress,
    Color? containerColor,
    Color? indicatorColor,
    ShapeBorder? containerShape,
    double containerSize = 48.0,
    double indicatorSize = 38.0,
    List<RoundedPolygon>? polygons,
    String? semanticsLabel,
    String? semanticsValue,
    Key? key,
  }) => ContainedLoadingIndicator(
    progress: progress,
    containerColor: containerColor,
    indicatorColor: indicatorColor,
    containerShape: containerShape,
    containerSize: containerSize,
    indicatorSize: indicatorSize,
    polygons: polygons,
    semanticsLabel: semanticsLabel,
    semanticsValue: semanticsValue,
    key: key,
  );
}
