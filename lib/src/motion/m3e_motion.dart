import 'package:material_ui/material_ui.dart';

export 'package:motor/motor.dart'
    show
        MaterialSpringMotion,
        SingleMotionBuilder,
        SingleMotionController;

/// Utility helpers and presets for Material 3 Expressive spring motion.
class M3eMotion {
  const M3eMotion._();

  /// Checks if motion/animations should be reduced or disabled based on the OS settings.
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  /// Clamps a spatial spring progress value `t` to the `0.0..1.0` range.
  ///
  /// Useful for properties that cannot accept overshoot (such as [Opacity],
  /// [Color.lerp], [ShapeBorder.lerp], or [BorderRadius.circular]).
  static double clampSpatial(double t) => t.clamp(0.0, 1.0);
}
