import 'package:material_ui/material_ui.dart';

/// A flexible-width icon + text filled button that sizes itself to its content width.
/// API: [icon], [fillColor], [text]. Label text is white by default.
class FlexIconButton extends StatelessWidget {
  /// Leading icon widget.
  final Widget icon;

  /// Filled background color. If null, falls back to Theme.primary.
  final Color? fillColor;

  /// Button label. Defaults to white text color.
  final String text;

  /// Optional tap handler.
  final VoidCallback? onPressed;

  /// Height of the button surface.
  final double height;

  /// Internal horizontal padding.
  final EdgeInsetsGeometry padding;

  /// Corner radius.
  final BorderRadiusGeometry borderRadius;

  const FlexIconButton({
    super.key,
    required this.icon,
    required this.text,
    this.fillColor,
    this.onPressed,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = fillColor ?? scheme.primary;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(height / 2),
    );

    Widget child = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Material(
        color: bg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(
                  data: const IconThemeData(color: Colors.white),
                  child: icon,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return child;
  }
}
