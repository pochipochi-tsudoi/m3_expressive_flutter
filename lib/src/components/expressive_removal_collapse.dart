import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

/// A 2-beat physical collision collapse wrapper for list item removals.
///
/// - Beat 1 (Implode): The element scales down and fades out using `standardSpatialFast`.
/// - Beat 2 (Snap & Rebound): The empty slot snaps shut using `expressiveSpatialDefault`
///   with collision clamping at 0.0 and a brief physical rebound.
class ExpressiveRemovalCollapse extends StatefulWidget {
  const ExpressiveRemovalCollapse({
    super.key,
    required this.isRemoved,
    required this.child,
    this.onCollapsed,
  });

  final bool isRemoved;
  final Widget child;
  final VoidCallback? onCollapsed;

  @override
  State<ExpressiveRemovalCollapse> createState() =>
      _ExpressiveRemovalCollapseState();
}

class _ExpressiveRemovalCollapseState extends State<ExpressiveRemovalCollapse> {
  bool _startCollapse = false;

  @override
  void didUpdateWidget(ExpressiveRemovalCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRemoved && !oldWidget.isRemoved) {
      // Trigger collapse sequence
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) {
          setState(() => _startCollapse = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduce && widget.isRemoved) {
      return const SizedBox.shrink();
    }

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.expressiveSpatialDefault(),
      value: _startCollapse ? 0.0 : 1.0,
      active: !reduce,
      onAnimationStatusChanged: (status) {
        if (_startCollapse && status == AnimationStatus.completed) {
          widget.onCollapsed?.call();
        }
      },
      builder: (context, slot, child) {
        final heightFactor = slot < 0.0 ? 0.0 : slot;

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: heightFactor,
            child: SingleMotionBuilder(
              motion: const MaterialSpringMotion.standardSpatialFast(),
              value: widget.isRemoved ? 0.0 : 1.0,
              active: !reduce,
              builder: (context, implode, innerChild) {
                final scale = implode.clamp(0.0, 1.0);
                final opacity = implode.clamp(0.0, 1.0);

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: innerChild,
                  ),
                );
              },
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
