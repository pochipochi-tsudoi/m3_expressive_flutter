import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../loading_indicator/m3e_loading_indicator.dart';

/// A Material 3 Expressive tactile button that morphs from a rounded pill to a
/// rounded rectangle on press using spring physics.
class ExpressiveMorphButton extends StatefulWidget {
  const ExpressiveMorphButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 64.0,
    this.restRadius = 32.0,
    this.pressedRadius = 16.0,
    this.pressScale = 1.0,
    this.backgroundColor,
    this.foregroundColor,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double restRadius;
  final double pressedRadius;
  final double pressScale;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool busy;

  @override
  State<ExpressiveMorphButton> createState() => _ExpressiveMorphButtonState();
}

class _ExpressiveMorphButtonState extends State<ExpressiveMorphButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? cs.primary;
    final fg = widget.foregroundColor ?? cs.onPrimary;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.expressiveSpatialFast(),
      value: _pressed ? 1.0 : 0.0,
      active: !reduceMotion,
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        final radius =
            widget.restRadius + (widget.pressedRadius - widget.restRadius) * tc;

        return Transform.scale(
          scale: 1.0 - (1.0 - widget.pressScale) * tc,
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.busy ? null : widget.onPressed,
              onHighlightChanged: (v) {
                if (_pressed != v) setState(() => _pressed = v);
              },
              child: child,
            ),
          ),
        );
      },
      child: SizedBox(
        height: widget.height,
        child: Center(
          child:
              widget.busy
                  ? SizedBox.square(
                    dimension: widget.height * 0.6,
                    child: FittedBox(
                      child: M3eLoadingIndicator(color: fg),
                    ),
                  )
                  : IconTheme.merge(
                    data: IconThemeData(color: fg),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                      child: widget.child,
                    ),
                  ),
        ),
      ),
    );
  }
}
