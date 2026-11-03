import 'package:material_ui/material_ui.dart' hide MaterialShapes;
import 'package:m3_expressive_flutter/src/shapes/expressive_shapes.dart';
import 'package:m3_expressive_flutter/src/shapes/shape_border.dart';

import 'show_expressive_sheet.dart';

/// An M3 Expressive floating confirmation sheet with concentric nesting radii.
///
/// Features:
/// - Outer border radius: 52dp (inner 28dp button radius + 24dp internal padding)
/// - Floating margin: 16dp
/// - Hero shape badge: 72x72dp with [MaterialShapes.cookie7Sided] (regular)
///   or [MaterialShapes.sunny] (destructive).
class ExpressiveConfirmSheet extends StatelessWidget {
  const ExpressiveConfirmSheet({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.icon,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final heroShape =
        isDestructive ? MaterialShapes.sunny : MaterialShapes.cookie7Sided;
    final heroBg =
        isDestructive ? cs.errorContainer : cs.secondaryContainer;
    final heroFg =
        isDestructive ? cs.onErrorContainer : cs.onSecondaryContainer;
    final defaultIcon =
        isDestructive ? Icons.warning_rounded : Icons.check_circle_outline_rounded;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(52.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72.0,
                  height: 72.0,
                  decoration: ShapeDecoration(
                    color: heroBg,
                    shape: M3eShapeBorder(polygon: heroShape),
                  ),
                  child: Icon(
                    icon ?? defaultIcon,
                    size: 32.0,
                    color: heroFg,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 28.0),
              SizedBox(
                height: 56.0,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isDestructive ? cs.error : cs.primary,
                    foregroundColor: isDestructive ? cs.onError : cs.onPrimary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 56.0,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
                    foregroundColor: cs.onSurfaceVariant,
                  ),
                  onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience function to show an [ExpressiveConfirmSheet].
Future<bool?> showExpressiveConfirmSheet({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  IconData? icon,
  bool isDestructive = false,
}) {
  return showExpressiveSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    builder: (context) => ExpressiveConfirmSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      isDestructive: isDestructive,
    ),
  );
}
