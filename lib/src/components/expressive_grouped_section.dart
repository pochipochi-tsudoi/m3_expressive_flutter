import 'package:material_ui/material_ui.dart';

/// A Material 3 Expressive grouped containment section.
///
/// Wraps its children with outer radii (28dp) at the top and bottom,
/// inner radii (4dp) between items, and a subtle gap (2dp) instead of dividers.
class ExpressiveGroupedSection extends StatelessWidget {
  const ExpressiveGroupedSection({
    super.key,
    required this.children,
    this.outerRadius = 28.0,
    this.innerRadius = 4.0,
    this.gap = 2.0,
  });

  final List<Widget> children;
  final double outerRadius;
  final double innerRadius;
  final double gap;

  BorderRadius _radiusFor(int index, int length) {
    final outer = Radius.circular(outerRadius);
    final inner = Radius.circular(innerRadius);
    return BorderRadius.vertical(
      top: index == 0 ? outer : inner,
      bottom: index == length - 1 ? outer : inner,
    );
  }

  /// Obtains the [BorderRadius] allocated for the current tile inside an [ExpressiveGroupedSection].
  static BorderRadius? radiusOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ExpressiveSectionTileScope>()
        ?.borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          _ExpressiveSectionTileScope(
            borderRadius: _radiusFor(i, children.length),
            child: children[i],
          ),
        ],
      ],
    );
  }
}

class _ExpressiveSectionTileScope extends InheritedWidget {
  const _ExpressiveSectionTileScope({
    required this.borderRadius,
    required super.child,
  });

  final BorderRadius borderRadius;

  @override
  bool updateShouldNotify(_ExpressiveSectionTileScope old) =>
      old.borderRadius != borderRadius;
}

/// A convenience tile widget designed to sit inside an [ExpressiveGroupedSection].
class ExpressiveGroupedTile extends StatelessWidget {
  const ExpressiveGroupedTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius =
        ExpressiveGroupedSection.radiusOf(context) ??
        BorderRadius.circular(16.0);

    return Material(
      color: backgroundColor ?? cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12.0),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
