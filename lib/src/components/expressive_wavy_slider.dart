import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../indicators/wavy_linear_progress_indicator.dart';

/// An interactive or display wavy bar that dynamically straightens and thickens when grabbed.
class ExpressiveWavyBar extends StatelessWidget {
  const ExpressiveWavyBar({
    super.key,
    required this.value,
    required this.dragging,
    this.color,
    this.trackColor,
  });

  final double value;
  final bool dragging;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SingleMotionBuilder(
      motion: const MaterialSpringMotion.expressiveSpatialFast(),
      value: dragging ? 1.0 : 0.0,
      active: !reduceMotion,
      builder: (context, t, _) {
        final grab = t.clamp(0.0, 1.0);

        return WavyLinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          color: color ?? cs.primary,
          trackColor: trackColor ?? cs.onSurface.withValues(alpha: 0.14),
          stopIndicatorColor: color ?? cs.primary,
          strokeWidth: 4.0 + 2.0 * grab,
          stopIndicatorWidth: 4.0 + 2.0 * grab,
          amplitude: 3.0 * (1.0 - grab),
        );
      },
    );
  }
}

/// An interactive Material 3 Expressive seek bar / slider that morphs its wave on touch.
class ExpressiveWavySlider extends StatefulWidget {
  const ExpressiveWavySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.color,
    this.trackColor,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final Color? color;
  final Color? trackColor;

  @override
  State<ExpressiveWavySlider> createState() => _ExpressiveWavySliderState();
}

class _ExpressiveWavySliderState extends State<ExpressiveWavySlider> {
  bool _dragging = false;

  void _handleSeek(Offset localPosition, double totalWidth) {
    if (totalWidth <= 0 || widget.onChanged == null) return;
    final progress = (localPosition.dx / totalWidth).clamp(0.0, 1.0);
    widget.onChanged!(progress);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            setState(() => _dragging = true);
            _handleSeek(details.localPosition, width);
          },
          onHorizontalDragUpdate: (details) {
            _handleSeek(details.localPosition, width);
          },
          onHorizontalDragEnd: (_) {
            setState(() => _dragging = false);
          },
          onHorizontalDragCancel: () {
            setState(() => _dragging = false);
          },
          onTapDown: (details) {
            _handleSeek(details.localPosition, width);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ExpressiveWavyBar(
              value: widget.value,
              dragging: _dragging,
              color: widget.color,
              trackColor: widget.trackColor,
            ),
          ),
        );
      },
    );
  }
}
