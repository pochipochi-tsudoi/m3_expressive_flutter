import 'dart:math' as math;
import 'package:material_ui/material_ui.dart' hide MaterialShapes;
import 'package:m3_expressive_flutter/src/shapes/expressive_shapes.dart';
import 'package:m3_expressive_flutter/src/shapes/shape_border.dart';

import 'snack.dart';

/// A Material 3 Expressive pill-shaped snack view with an arch-shaped icon chip.
class SnackView extends StatelessWidget {
  const SnackView({
    super.key,
    required this.snack,
    this.depth = 0,
    this.shakeOffset = 0.0,
    this.onDismiss,
  });

  final Snack snack;
  final int depth;
  final double shakeOffset;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final bg = snack.isError ? cs.errorContainer : cs.inverseSurface;
    final fg = snack.isError ? cs.onErrorContainer : cs.onInverseSurface;
    final iconBg =
        snack.isError ? cs.error : cs.inversePrimary;
    final iconFg =
        snack.isError ? cs.onError : cs.onInverseSurface;

    // Stack transformation for depth (0 = front, 1, 2 = behind)
    final dy = -depth * 12.0;
    final scale = 1.0 - (depth * 0.05);
    final shadowOverlayOpacity = (depth * 0.15).clamp(0.0, 0.4);

    // Arch angle: -90 deg for LTR, +90 deg for RTL
    final archAngle = (isRtl ? 90.0 : -90.0) * (math.pi / 180.0);

    return Transform.translate(
      offset: Offset(shakeOffset, dy),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: ShapeDecoration(
            color: bg,
            shape: const StadiumBorder(),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snack.icon != null) ...[
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: ShapeDecoration(
                          color: iconBg,
                          shape: M3eShapeBorder(
                            polygon: MaterialShapes.arch,
                            startAngle: archAngle,
                          ),
                        ),
                        child: Icon(
                          snack.icon,
                          size: 18.0,
                          color: iconFg,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                    ],
                    Flexible(
                      child: Text(
                        snack.message,
                        style: TextStyle(
                          color: fg,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (snack.actionLabel != null && snack.onAction != null) ...[
                      const SizedBox(width: 12.0),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              snack.isError ? cs.error : cs.inversePrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          minimumSize: const Size(48, 36),
                        ),
                        onPressed: () {
                          snack.onAction?.call();
                          onDismiss?.call();
                        },
                        child: Text(
                          snack.actionLabel!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (shadowOverlayOpacity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: shadowOverlayOpacity),
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
