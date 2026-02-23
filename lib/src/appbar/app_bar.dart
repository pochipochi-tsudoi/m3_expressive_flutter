import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimal M3eAppBar that just hosts a child widget while behaving
/// correctly inside Scaffold.appBar (paints background & sets overlay style).
///
/// Only `child` is required. If the child is a PreferredSizeWidget, its
/// preferred height is used; otherwise we default to kToolbarHeight.
class M3eAppBar extends StatelessWidget implements PreferredSizeWidget {
  const M3eAppBar({super.key, required this.child});

  final Widget child;

  double get _height =>
      child is PreferredSizeWidget
          ? (child as PreferredSizeWidget).preferredSize.height
          : kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = theme.colorScheme.surface;

    // Choose an overlay style based on background brightness
    final overlay =
        ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Material(
        color: bg,
        elevation: 0,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        child: SafeArea(
          top: true,
          bottom: false,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: SizedBox(
              height: _height,
              width: double.infinity,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
