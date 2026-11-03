import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

/// An accordion-style expandable text component powered by M3 Expressive spring physics.
class ExpressiveExpandableText extends StatefulWidget {
  const ExpressiveExpandableText({
    super.key,
    required this.text,
    this.collapsedMaxLines = 2,
    this.expandLabel = 'Show more',
    this.collapseLabel = 'Show less',
    this.style,
    this.actionStyle,
  });

  final String text;
  final int collapsedMaxLines;
  final String expandLabel;
  final String collapseLabel;
  final TextStyle? style;
  final TextStyle? actionStyle;

  @override
  State<ExpressiveExpandableText> createState() =>
      _ExpressiveExpandableTextState();
}

class _ExpressiveExpandableTextState extends State<ExpressiveExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final defaultStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface);
    final defaultActionStyle = TextStyle(
      color: cs.primary,
      fontWeight: FontWeight.w700,
      fontSize: 13.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleMotionBuilder(
          motion:
              _expanded
                  ? const MaterialSpringMotion.expressiveSpatialDefault()
                  : const MaterialSpringMotion.standardSpatialFast(),
          value: _expanded ? 1.0 : 0.0,
          active: !reduce,
          builder: (context, t, child) {
            return AnimatedCrossFade(
              firstChild: Text(
                widget.text,
                maxLines: widget.collapsedMaxLines,
                overflow: TextOverflow.ellipsis,
                style: widget.style ?? defaultStyle,
              ),
              secondChild: Text(
                widget.text,
                style: widget.style ?? defaultStyle,
              ),
              crossFadeState:
                  _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeOutCubic,
            );
          },
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              _expanded ? widget.collapseLabel : widget.expandLabel,
              style: widget.actionStyle ?? defaultActionStyle,
            ),
          ),
        ),
      ],
    );
  }
}
