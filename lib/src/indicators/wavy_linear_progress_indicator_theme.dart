import 'package:material_ui/material_ui.dart';

/// Defines default property values for descendant [WavyLinearProgressIndicator] widgets.
@immutable
class WavyLinearProgressIndicatorThemeData {
  const WavyLinearProgressIndicatorThemeData({
    this.color,
    this.trackColor,
    this.stopIndicatorColor,
    this.strokeWidth,
    this.stopIndicatorWidth,
    this.trackGap,
    this.amplitude,
    this.wavelength,
    this.waveSpeed,
  });

  final Color? color;
  final Color? trackColor;
  final Color? stopIndicatorColor;
  final double? strokeWidth;
  final double? stopIndicatorWidth;
  final double? trackGap;
  final double? amplitude;
  final double? wavelength;
  final double? waveSpeed;

  WavyLinearProgressIndicatorThemeData copyWith({
    Color? color,
    Color? trackColor,
    Color? stopIndicatorColor,
    double? strokeWidth,
    double? stopIndicatorWidth,
    double? trackGap,
    double? amplitude,
    double? wavelength,
    double? waveSpeed,
  }) => WavyLinearProgressIndicatorThemeData(
    color: color ?? this.color,
    trackColor: trackColor ?? this.trackColor,
    stopIndicatorColor: stopIndicatorColor ?? this.stopIndicatorColor,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    stopIndicatorWidth: stopIndicatorWidth ?? this.stopIndicatorWidth,
    trackGap: trackGap ?? this.trackGap,
    amplitude: amplitude ?? this.amplitude,
    wavelength: wavelength ?? this.wavelength,
    waveSpeed: waveSpeed ?? this.waveSpeed,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is WavyLinearProgressIndicatorThemeData &&
        other.color == color &&
        other.trackColor == trackColor &&
        other.stopIndicatorColor == stopIndicatorColor &&
        other.strokeWidth == strokeWidth &&
        other.stopIndicatorWidth == stopIndicatorWidth &&
        other.trackGap == trackGap &&
        other.amplitude == amplitude &&
        other.wavelength == wavelength &&
        other.waveSpeed == waveSpeed;
  }

  @override
  int get hashCode => Object.hash(
    color,
    trackColor,
    stopIndicatorColor,
    strokeWidth,
    stopIndicatorWidth,
    trackGap,
    amplitude,
    wavelength,
    waveSpeed,
  );
}

/// Applies a [WavyLinearProgressIndicatorThemeData] to descendant [WavyLinearProgressIndicator] widgets.
class WavyLinearProgressIndicatorTheme extends InheritedTheme {
  const WavyLinearProgressIndicatorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final WavyLinearProgressIndicatorThemeData data;

  static WavyLinearProgressIndicatorThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<
      WavyLinearProgressIndicatorTheme
    >();
    return theme?.data ?? const WavyLinearProgressIndicatorThemeData();
  }

  @override
  bool updateShouldNotify(WavyLinearProgressIndicatorTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return WavyLinearProgressIndicatorTheme(data: data, child: child);
  }
}
