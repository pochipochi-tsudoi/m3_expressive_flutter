import 'package:material_ui/material_ui.dart';

import 'snack.dart';
import 'snack_overlay.dart';

export 'snack.dart';
export 'snack_view.dart';
export 'snack_stack.dart';
export 'snack_overlay.dart';

/// Shows a Material 3 Expressive stacked snack bar.
///
/// Features:
/// - Maximum of 3 stacked cards with spring depth offsets
/// - Duplicate message/icon triggers promotion to front with an impulse physical shake
/// - Arch-shaped icon chip container on the leading edge
void showExpressiveSnack({
  required BuildContext context,
  required String message,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  bool isError = false,
}) {
  final snack = Snack(
    message: message,
    icon: icon,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
    isError: isError,
  );
  SnackOverlay.instance.show(context, snack);
}
