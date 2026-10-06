import 'package:flutter/material.dart';
import 'package:material_3p/material_shapes.dart';

import 'loading_indicator_defaults.dart';
import 'm3e_loading_indicator.dart';

/// Material 3 Expressive Contained Loading Indicator.
///
/// A [M3eLoadingIndicator] centered inside a colored container (default 48dp).
///
/// - `progress == null` → indeterminate
/// - `progress` 0..1 → determinate
///
/// ```dart
/// M3eContainedLoadingIndicator()
/// M3eShapes.ContainedLoadingIndicator(progress: 0.5)
/// ```
class M3eContainedLoadingIndicator extends StatelessWidget {
  const M3eContainedLoadingIndicator({
    super.key,
    this.progress,
    this.containerColor,
    this.indicatorColor,
    this.containerShape,
    this.containerSize = M3eLoadingIndicatorDefaults.containerSize,
    this.indicatorSize = M3eLoadingIndicatorDefaults.indicatorSize,
    this.polygons,
    this.semanticsLabel,
    this.semanticsValue,
  }) : assert(containerSize > 0),
       assert(indicatorSize > 0),
       assert(
         progress == null || (progress >= 0.0 && progress <= 1.0),
         'progress must be between 0.0 and 1.0',
       );

  final double? progress;
  final Color? containerColor;
  final Color? indicatorColor;
  final ShapeBorder? containerShape;
  final double containerSize;
  final double indicatorSize;
  final List<RoundedPolygon>? polygons;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // AOSP: containedContainerColor ~ secondaryContainer / surfaceContainer
    // Use surfaceContainerHighest as fallback which is close.
    final bg = containerColor ?? scheme.secondaryContainer;
    final fg = indicatorColor ?? scheme.primary;
    final shape = containerShape ?? M3eLoadingIndicatorDefaults.containerShape;

    return Semantics(
      label: semanticsLabel,
      value: semanticsValue,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: ShapeDecoration(color: bg, shape: shape),
        child: Center(
          child: M3eLoadingIndicator(
            progress: progress,
            color: fg,
            size: indicatorSize,
            polygons: polygons,
            semanticsLabel: semanticsLabel,
            semanticsValue: semanticsValue,
          ),
        ),
      ),
    );
  }
}
