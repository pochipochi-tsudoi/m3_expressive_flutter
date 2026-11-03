import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

/// A Material 3 Expressive circular progress indicator that renders a circular wavy stroke.
///
/// Follows the official Material Design 3 Expressive specification:
/// - When [value] is non-null, displays a determinate circular progress indicator where
///   the active wave smoothly travels along the circumference, attenuates amplitude near
///   0% and 100%, and leaves a proper track gap to the remaining circular track.
/// - When [value] is null, displays an indeterminate indicator with an expanding/contracting
///   wavy arc undergoing continuous global rotation and fluid waveform motion.
class CircularWavyProgressIndicator extends StatefulWidget {
  const CircularWavyProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.trackColor,
    this.strokeWidth = 4.0,
    this.amplitude,
    this.wavelength,
    this.waveSpeed,
    this.trackGap = 4.0,
  });

  /// The progress value between 0.0 and 1.0. If null, the indicator is indeterminate.
  final double? value;

  /// The color of the active wavy stroke. Defaults to [ColorScheme.primary].
  final Color? color;

  /// The color of the remaining circular track.
  final Color? trackColor;

  /// The thickness of the stroke. Defaults to 4.0 dp (M3 token).
  final double strokeWidth;

  /// The radial amplitude of the wave from baseline radius. Defaults to 1.6 dp (M3 token).
  final double? amplitude;

  /// The linear wavelength along the circumference. Defaults to 15.0 dp (M3 token).
  final double? wavelength;

  /// The wave speed in dp per second. Defaults to matching the wavelength (1 wave cycle/sec).
  final double? waveSpeed;

  /// The gap between the active wave arc and the remaining circular track. Defaults to 4.0 dp.
  final double trackGap;

  @override
  State<CircularWavyProgressIndicator> createState() =>
      _CircularWavyProgressIndicatorState();
}

class _CircularWavyProgressIndicatorState
    extends State<CircularWavyProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _indeterminateDurationMs = 2000;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _calculateDuration(),
    );
    _startAnimationIfNeeded();
  }

  Duration _calculateDuration() {
    if (widget.value == null) {
      return const Duration(milliseconds: _indeterminateDurationMs);
    }
    final effectiveWavelength = widget.wavelength ?? 15.0;
    final effectiveWaveSpeed = widget.waveSpeed ?? effectiveWavelength;
    if (effectiveWaveSpeed <= 0) {
      return const Duration(milliseconds: 1000);
    }
    final ms = ((effectiveWavelength / effectiveWaveSpeed) * 1000).round();
    return Duration(milliseconds: math.max(50, ms));
  }

  void _startAnimationIfNeeded() {
    final effectiveAmplitude = widget.amplitude ?? 1.6;
    if (effectiveAmplitude > 0 || widget.value == null) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(CircularWavyProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isIndeterminateChanged = (oldWidget.value == null) != (widget.value == null);
    final wavelengthChanged = oldWidget.wavelength != widget.wavelength;
    final waveSpeedChanged = oldWidget.waveSpeed != widget.waveSpeed;
    final amplitudeChanged = oldWidget.amplitude != widget.amplitude;

    if (isIndeterminateChanged || wavelengthChanged || waveSpeedChanged) {
      _controller.duration = _calculateDuration();
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    }

    if (amplitudeChanged || isIndeterminateChanged) {
      _startAnimationIfNeeded();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = widget.color ?? cs.primary;
    final effectiveTrackColor =
        widget.trackColor ?? cs.onSurface.withValues(alpha: 0.12);
    final effectiveAmplitude = widget.amplitude ?? 1.6;
    final effectiveWavelength = widget.wavelength ?? 15.0;
    final effectiveWaveSpeed = widget.waveSpeed ?? effectiveWavelength;

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _controller.isAnimating) {
      _controller.stop();
    }

    // Default container size: 48.0 dp (M3 WaveSize token)
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularWavyPainter(
              value: widget.value,
              animationValue: reduceMotion ? 0.0 : _controller.value,
              color: effectiveColor,
              trackColor: effectiveTrackColor,
              strokeWidth: widget.strokeWidth,
              amplitude: effectiveAmplitude,
              wavelength: effectiveWavelength,
              waveSpeed: effectiveWaveSpeed,
              trackGap: widget.trackGap,
            ),
          );
        },
      ),
    );
  }
}

class _CircularWavyPainter extends CustomPainter {
  _CircularWavyPainter({
    required this.value,
    required this.animationValue,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.amplitude,
    required this.wavelength,
    required this.waveSpeed,
    required this.trackGap,
  });

  final double? value;
  final double animationValue;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double amplitude;
  final double wavelength;
  final double waveSpeed;
  final double trackGap;

  static const Curve _sweepCurve = Cubic(0.4, 0.0, 0.2, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final baseRadius =
        (math.min(size.width, size.height) - strokeWidth) / 2.0 - amplitude;
    if (baseRadius <= 0) return;

    final circumference = 2.0 * math.pi * baseRadius;
    final waveCount = math.max(5, (circumference / wavelength).round());

    final trackPaint =
        Paint()
          ..color = trackColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final activePaint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    if (value != null) {
      // -------------------------------------------------------------
      // Determinate Mode
      // -------------------------------------------------------------
      final clampedValue = value!.clamp(0.0, 1.0);

      // Smooth wave flattening at beginning and end
      double ampFraction = 1.0;
      if (clampedValue <= 0.1) {
        ampFraction = clampedValue / 0.1;
      } else if (clampedValue >= 0.95) {
        ampFraction = ((1.0 - clampedValue) / 0.05).clamp(0.0, 1.0);
      }
      final currentAmp = amplitude * ampFraction;

      final totalAngle = 2.0 * math.pi * clampedValue;
      final startAngle = -math.pi / 2.0;

      // Draw active wavy arc
      if (clampedValue > 0) {
        final phaseOffset = (animationValue % 1.0) * (2.0 * math.pi / waveCount);
        final path = Path();
        const step = 0.02; // Fine resolution for smooth curves
        bool started = false;

        for (double theta = 0.0; theta <= totalAngle; theta += step) {
          final r =
              baseRadius +
              currentAmp * math.sin(waveCount * (theta - phaseOffset));
          final angle = startAngle + theta;
          final x = center.dx + r * math.cos(angle);
          final y = center.dy + r * math.sin(angle);
          if (!started) {
            path.moveTo(x, y);
            started = true;
          } else {
            path.lineTo(x, y);
          }
        }

        // Connect exact end point
        final finalR =
            baseRadius +
            currentAmp * math.sin(waveCount * (totalAngle - phaseOffset));
        final finalAngle = startAngle + totalAngle;
        path.lineTo(
          center.dx + finalR * math.cos(finalAngle),
          center.dy + finalR * math.sin(finalAngle),
        );

        canvas.drawPath(path, activePaint);
      }

      // Draw remaining track with gap
      if (clampedValue < 1.0) {
        final gapAngle = trackGap / baseRadius;
        final trackStartAngle = startAngle + totalAngle + (clampedValue > 0 ? gapAngle : 0.0);
        final trackEndAngle = startAngle + 2.0 * math.pi - (clampedValue > 0 ? gapAngle : 0.0);
        final trackSweep = trackEndAngle - trackStartAngle;

        if (trackSweep > 0) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: baseRadius),
            trackStartAngle,
            trackSweep,
            false,
            trackPaint,
          );
        }
      }
    } else {
      // -------------------------------------------------------------
      // Indeterminate Mode (M3 Specification)
      // -------------------------------------------------------------
      // Dynamic arc expanding/contracting between minSweep and maxSweep
      const minSweep = 0.1 * 2.0 * math.pi;
      const maxSweep = 0.8 * 2.0 * math.pi;

      final cycleProgress = animationValue;
      final sweepProgress =
          cycleProgress < 0.5
              ? _sweepCurve.transform(cycleProgress * 2.0)
              : _sweepCurve.transform((1.0 - cycleProgress) * 2.0);

      final sweepAngle = minSweep + (maxSweep - minSweep) * sweepProgress;
      final globalRotation = cycleProgress * 2.0 * math.pi * 2.0;
      final startAngle = -math.pi / 2.0 + globalRotation;

      // Draw full underlying track
      canvas.drawCircle(center, baseRadius, trackPaint);

      // Draw wavy active arc
      final phaseOffset = (animationValue * 2.0) * (2.0 * math.pi / waveCount);
      final path = Path();
      const step = 0.03;
      bool started = false;

      for (double theta = 0.0; theta <= sweepAngle; theta += step) {
        final r =
            baseRadius +
            amplitude * math.sin(waveCount * (theta - phaseOffset));
        final angle = startAngle + theta;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }

      final finalR =
          baseRadius +
          amplitude * math.sin(waveCount * (sweepAngle - phaseOffset));
      final finalAngle = startAngle + sweepAngle;
      path.lineTo(
        center.dx + finalR * math.cos(finalAngle),
        center.dy + finalR * math.sin(finalAngle),
      );

      canvas.drawPath(path, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularWavyPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength ||
        oldDelegate.waveSpeed != waveSpeed ||
        oldDelegate.trackGap != trackGap;
  }
}
