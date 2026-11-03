import 'dart:math' as math;
import 'package:material_ui/material_ui.dart'
    hide MaterialShapes, RoundedPolygon;
import 'package:motor/motor.dart';
import 'package:m3_expressive_flutter/src/shapes/expressive_shapes.dart';
import 'package:m3_expressive_flutter/src/shapes/shape_border.dart';

/// A Material 3 Expressive shape toggle button with press-preview morphing.
class ExpressiveShapeToggle extends StatefulWidget {
  const ExpressiveShapeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.icon,
    this.selectedIcon,
    this.unselectedShape,
    this.selectedShape,
    this.unselectedColor,
    this.selectedColor,
    this.unselectedForegroundColor,
    this.selectedForegroundColor,
    this.rotationTurnsOnSelect = 0.0,
    this.previewOnPress = true,
    this.size = 48.0,
  });

  final bool selected;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final IconData? selectedIcon;
  final RoundedPolygon? unselectedShape;
  final RoundedPolygon? selectedShape;
  final Color? unselectedColor;
  final Color? selectedColor;
  final Color? unselectedForegroundColor;
  final Color? selectedForegroundColor;
  final double rotationTurnsOnSelect;
  final bool previewOnPress;
  final double size;

  @override
  State<ExpressiveShapeToggle> createState() => _ExpressiveShapeToggleState();
}

class _ExpressiveShapeToggleState extends State<ExpressiveShapeToggle> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final effectiveShapeTarget =
        (widget.previewOnPress && _down && !reduce)
            ? !widget.selected
            : widget.selected;

    final offBorder = M3eShapeBorder(
      polygon: widget.unselectedShape ?? MaterialShapes.circle,
    );
    final onBorder = M3eShapeBorder(
      polygon: widget.selectedShape ?? MaterialShapes.gem,
    );

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.expressiveEffectsFast(),
      value: widget.selected ? 1.0 : 0.0,
      active: !reduce,
      builder: (context, colorT, child) {
        final tc = colorT.clamp(0.0, 1.0);
        final bg =
            Color.lerp(
              widget.unselectedColor ?? cs.surfaceContainerHighest,
              widget.selectedColor ?? cs.tertiary,
              tc,
            )!;
        final fg =
            Color.lerp(
              widget.unselectedForegroundColor ?? cs.onSurface,
              widget.selectedForegroundColor ?? cs.onTertiary,
              tc,
            )!;

        return SingleMotionBuilder(
          motion: const MaterialSpringMotion.expressiveSpatialFast(),
          value: effectiveShapeTarget ? 1.0 : 0.0,
          active: !reduce,
          builder: (context, shapeT, _) {
            final stc = shapeT.clamp(0.0, 1.0);
            final border =
                ShapeBorder.lerp(offBorder, onBorder, stc) ?? offBorder;

            return SizedBox.square(
              dimension: widget.size,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: border),
                child: Material(
                  color: bg,
                  child: InkWell(
                    onTap: () => widget.onChanged(!widget.selected),
                    onTapDown: (_) => setState(() => _down = true),
                    onTapUp: (_) => setState(() => _down = false),
                    onTapCancel: () => setState(() => _down = false),
                    child: Center(
                      child: Transform.rotate(
                        angle:
                            shapeT * widget.rotationTurnsOnSelect * 2 * math.pi,
                        child: Icon(
                          widget.selected
                              ? (widget.selectedIcon ?? widget.icon)
                              : widget.icon,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
