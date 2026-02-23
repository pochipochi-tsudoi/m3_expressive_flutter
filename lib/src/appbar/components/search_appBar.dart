import 'package:flutter/material.dart';

/// Material 3 style Search App Bar:
/// ┌ menu ── [   pill-shaped search field (centered text)   ] ── avatar ┐
///
/// - Use as a child of M3eAppBar (PreferredSizeWidget).
/// - `onChanged` is required for search behavior.
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    this.hintText = 'Search',
    required this.onChanged,
    this.height = kToolbarHeight,
    this.autofocus = false,
    this.leading,
    this.onLeadingPressed,
    this.trailing,
    this.actions,
  });

  /// Center hint text shown inside the pill field.
  final String hintText;

  /// Required: called on text change.
  final ValueChanged<String> onChanged;

  /// AppBar height (defaults to kToolbarHeight ~56).
  final double height;

  final bool autofocus;

  /// Optional custom leading widget. If null, shows a hamburger IconButton.
  final Widget? leading;

  /// Leading button callback. Defaults to opening the Drawer if any.
  final VoidCallback? onLeadingPressed;

  /// Optional single trailing widget (e.g., avatar). If null and [actions] is null,
  /// a default CircleAvatar is shown.
  final Widget? trailing;

  /// Optional trailing actions (rendered instead of [trailing] if provided).
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;

    Widget buildLeading() {
      if (leading != null) return leading!;
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed:
            onLeadingPressed ?? () => Scaffold.maybeOf(context)?.openDrawer(),
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    }

    Widget buildTrailing() {
      if (actions != null && actions!.isNotEmpty) {
        return Row(mainAxisSize: MainAxisSize.min, children: actions!);
      }
      if (trailing != null) return trailing!;
      return const CircleAvatar(
        radius: 16,
        child: Icon(Icons.person, size: 18),
      );
    }

    final pill = Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999), // Stadium shape
        border: Border.all(color: outline),
      ),
      child: TextField(
        autofocus: autofocus,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            buildLeading(),
            const SizedBox(width: 12),
            Expanded(child: pill),
            const SizedBox(width: 12),
            buildTrailing(),
          ],
        ),
      ),
    );
  }
}
