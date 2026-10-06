library m3e_fab;

import 'package:flutter/material.dart';
import 'package:m3_expressive_flutter/src/fab/components/large.dart';
import 'package:m3_expressive_flutter/src/fab/components/menu.dart';
import 'package:m3_expressive_flutter/src/fab/components/regular.dart';
import 'package:m3_expressive_flutter/src/fab/components/small.dart';

/// 利用側は `M3eFab.Small(icon: ..., color: ...)` のように呼ぶ
class M3eFab {
  const M3eFab._(); // namespacing用途。インスタンス化しない

  static Small small({
    required Widget icon,
    Color? color,
    required VoidCallback? onPressed,
  }) => Small(icon: icon, color: color, onPressed: onPressed);

  static Regular regular({
    required Widget icon,
    Color? color,
    required VoidCallback? onPressed,
  }) => Regular(icon: icon, color: color, onPressed: onPressed);

  static Large large({
    required Widget icon,
    Color? color,
    required VoidCallback? onPressed,
  }) => Large(icon: icon, color: color, onPressed: onPressed);

  static WithMenu menu({
    Key? key,
    required Widget child,
    IconData icon = Icons.add,
    Color? color,
    Color? openColor,
    bool openAsCircle = false,
  }) => WithMenu(
    key: key,
    child: child,
    icon: icon,
    color: color,
    openColor: openColor,
    openAsCircle: openAsCircle,
  );
}

/* ---------------- 共通テーマ & コア実装（非公開） ---------------- */

class M3eFabTheme extends ThemeExtension<M3eFabTheme> {
  final Size smallSize;
  final double smallRadius;
  final Size regularSize;
  final double regularRadius;
  final Size largeSize;
  final double largeRadius;
  final double elevation;
  final Duration duration;
  final Curve curve;

  const M3eFabTheme({
    this.smallSize = const Size(48, 48),
    this.smallRadius = 12,
    this.regularSize = const Size(64, 64),
    this.regularRadius = 16,
    this.largeSize = const Size(108, 108),
    this.largeRadius = 28,
    this.elevation = 3,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
  });

  @override
  M3eFabTheme copyWith({
    Size? smallSize,
    double? smallRadius,
    Size? regularSize,
    double? regularRadius,
    Size? largeSize,
    double? largeRadius,
    double? elevation,
    Duration? duration,
    Curve? curve,
  }) {
    return M3eFabTheme(
      smallSize: smallSize ?? this.smallSize,
      smallRadius: smallRadius ?? this.smallRadius,
      regularSize: regularSize ?? this.regularSize,
      regularRadius: regularRadius ?? this.regularRadius,
      largeSize: largeSize ?? this.largeSize,
      largeRadius: largeRadius ?? this.largeRadius,
      elevation: elevation ?? this.elevation,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  @override
  ThemeExtension<M3eFabTheme> lerp(
    ThemeExtension<M3eFabTheme>? other,
    double t,
  ) {
    if (other is! M3eFabTheme) return this;
    double _ld(double a, double b) => a + (b - a) * t;
    Duration _lDur(Duration a, Duration b) => Duration(
      milliseconds:
          (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t)
              .round(),
    );
    return M3eFabTheme(
      smallSize: Size.lerp(smallSize, other.smallSize, t)!,
      smallRadius: _ld(smallRadius, other.smallRadius),
      regularSize: Size.lerp(regularSize, other.regularSize, t)!,
      regularRadius: _ld(regularRadius, other.regularRadius),
      largeSize: Size.lerp(largeSize, other.largeSize, t)!,
      largeRadius: _ld(largeRadius, other.largeRadius),
      elevation: _ld(elevation, other.elevation),
      duration: _lDur(duration, other.duration),
      curve: t < 0.5 ? curve : other.curve,
    );
  }
}

enum FabSize { small, regular, large }

/// 各サイズクラスが使う共通描画
class M3eFabCore extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final FabSize size;
  final VoidCallback? onPressed;

  const M3eFabCore({
    required this.icon,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<M3eFabTheme>() ?? const M3eFabTheme();

    final (boxSize, radius) = switch (size) {
      FabSize.small => (t.smallSize, t.smallRadius),
      FabSize.regular => (t.regularSize, t.regularRadius),
      FabSize.large => (t.largeSize, t.largeRadius),
    };

    final containerColor =
        color ?? Theme.of(context).colorScheme.primaryContainer;
    final iconColor = _onColorFor(containerColor);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return AnimatedContainer(
      duration: t.duration,
      curve: t.curve,
      height: boxSize.height,
      width: boxSize.width,
      // Size animation only; style is handled by Material below
      child: Material(
        color: containerColor,
        elevation: t.elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(
                color: iconColor,
                size: _iconSizeFor(boxSize),
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  double _iconSizeFor(Size s) {
    if (s.shortestSide <= 40) return 18;
    if (s.shortestSide <= 56) return 24;
    return 36;
  }

  Color _onColorFor(Color bg) =>
      bg.computeLuminance() < 0.5 ? Colors.white : Colors.black87;
}
