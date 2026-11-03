import 'package:material_ui/material_ui.dart';

import 'snack.dart';
import 'snack_stack.dart';

/// Overlay manager for stacking Expressive snacks across the application.
class SnackOverlay {
  SnackOverlay._();
  static final SnackOverlay instance = SnackOverlay._();

  OverlayEntry? _entry;
  final GlobalKey<SnackStackState> _stackKey = GlobalKey<SnackStackState>();

  void show(BuildContext context, Snack snack) {
    if (_entry == null) {
      final overlay = Overlay.of(context, rootOverlay: true);
      _entry = OverlayEntry(
        builder: (context) {
          final bottomPadding = MediaQuery.viewPaddingOf(context).bottom + 24.0;
          return Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: Material(
              type: MaterialType.transparency,
              child: SnackStack(
                key: _stackKey,
                onEmpty: () {
                  _entry?.remove();
                  _entry = null;
                },
              ),
            ),
          );
        },
      );
      overlay.insert(_entry!);
    }

    // Schedule frame if entry was just inserted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stackKey.currentState?.push(snack);
    });
  }
}
