import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

import 'wavy_linear_progress_indicator_theme.dart';

/// A Material 3 Expressive linear progress indicator that renders a wavy active line.
///
/// Follows the official Material Design 3 Expressive specification:
/// - When [value] is non-null, displays a determinate progress bar where the active
///   indicator smoothly undulates with an animated wave offset, attenuates its amplitude
///   near 0% and 100%, maintains a track gap, and includes a stop indicator at the track end.
/// - When [value] is null, displays an indeterminate indicator with two wavy line segments
///   animated across the track using the standard M3 emphasized acceleration curve.
class WavyLinearProgressIndicator extends StatefulWidget {
  const WavyLinearProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.trackColor,
    this.stopIndicatorColor,
    this.strokeWidth = 4.0,
    this.stopIndicatorWidth = 4.0,
    this.trackGap = 4.0,
    this.amplitude,
    this.wavelength,
    this.waveSpeed,
  });

  /// The progress value between 0.0 and 1.0. If null, the indicator is indeterminate.
  final double? value;

  /// The color of the active progress wave.
  final Color? color;

  /// The color of the remaining track.
  final Color? trackColor;

  /// The color of the stop indicator at the end of the track.
  final Color? stopIndicatorColor;

  /// The thickness of the progress stroke. Defaults to 4.0 dp.
  final double strokeWidth;

  /// The diameter of the circular stop indicator at the end of the track. Defaults to 4.0 dp.
  final double stopIndicatorWidth;

  /// The gap between the active progress and the remaining track. Defaults to 4.0 dp.
  final double trackGap;

  /// The peak amplitude of the wave from baseline. Defaults to 3.0 dp.
  final double? amplitude;

  /// The wavelength of one full sine cycle.
  /// Defaults to 40.0 dp for determinate, 20.0 dp for indeterminate.
  final double? wavelength;

  /// The wave movement speed in dp per second. Defaults to matching the wavelength (1 wave cycle/sec).
  final double? waveSpeed;

  @override
  State<WavyLinearProgressIndicator> createState() =>
      _WavyLinearProgressIndicatorState();
}

class _WavyLinearProgressIndicatorState
    extends State<WavyLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _indeterminateDurationMs = 1750;

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
    final effectiveWavelength = widget.wavelength ?? 40.0;
    final effectiveWaveSpeed = widget.waveSpeed ?? effectiveWavelength;
    if (effectiveWaveSpeed <= 0) {
      return const Duration(milliseconds: 1000);
    }
    final ms = ((effectiveWavelength / effectiveWaveSpeed) * 1000).round();
    return Duration(milliseconds: math.max(50, ms));
  }

  void _startAnimationIfNeeded() {
    final effectiveAmplitude = widget.amplitude ?? 3.0;
    if (effectiveAmplitude > 0 || widget.value == null) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(WavyLinearProgressIndicator oldWidget) {
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
    final theme = WavyLinearProgressIndicatorTheme.of(context);
    final cs = Theme.of(context).colorScheme;

    final effectiveColor = widget.color ?? theme.color ?? cs.primary;
    final effectiveTrackColor =
        widget.trackColor ??
        theme.trackColor ??
        cs.onSurface.withValues(alpha: 0.12);
    final effectiveStopColor =
        widget.stopIndicatorColor ??
        theme.stopIndicatorColor ??
        effectiveColor;
    final effectiveStrokeWidth =
        widget.strokeWidth;
    final effectiveStopWidth =
        theme.stopIndicatorWidth ?? widget.stopIndicatorWidth;
    final effectiveTrackGap = theme.trackGap ?? widget.trackGap;
    final effectiveAmplitude = theme.amplitude ?? widget.amplitude ?? 3.0;
    final effectiveWavelength =
        theme.wavelength ??
        widget.wavelength ??
        (widget.value != null ? 40.0 : 20.0);
    final effectiveWaveSpeed =
        theme.waveSpeed ?? widget.waveSpeed ?? effectiveWavelength;

    // Container height: Material token WaveHeight = 10.0 dp
    final containerHeight = math.max(
      10.0,
      effectiveAmplitude * 2 + effectiveStrokeWidth,
    );

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _controller.isAnimating) {
      _controller.stop();
    }

    return SizedBox(
      height: containerHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavyLinearPainter(
              value: widget.value,
              animationValue: reduceMotion ? 0.0 : _controller.value,
              color: effectiveColor,
              trackColor: effectiveTrackColor,
              stopIndicatorColor: effectiveStopColor,
              strokeWidth: effectiveStrokeWidth,
              stopIndicatorWidth: effectiveStopWidth,
              trackGap: effectiveTrackGap,
              amplitude: effectiveAmplitude,
              wavelength: effectiveWavelength,
              waveSpeed: effectiveWaveSpeed,
            ),
          );
        },
      ),
    );
  }
}

class _WavyLinearPainter extends CustomPainter {
  _WavyLinearPainter({
    required this.value,
    required this.animationValue,
    required this.color,
    required this.trackColor,
    required this.stopIndicatorColor,
    required this.strokeWidth,
    required this.stopIndicatorWidth,
    required this.trackGap,
    required this.amplitude,
    required this.wavelength,
    required this.waveSpeed,
  });

  final double? value;
  final double animationValue;
  final Color color;
  final Color trackColor;
  final Color stopIndicatorColor;
  final double strokeWidth;
  final double stopIndicatorWidth;
  final double trackGap;
  final double amplitude;
  final double wavelength;
  final double waveSpeed;

  static const Curve _indeterminateCurve = Cubic(0.2, 0.0, 0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final totalWidth = size.width;
    if (totalWidth <= 0) return;

    final capWidth = strokeWidth / 2.0;

    final activePaint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final trackPaint =
        Paint()
          ..color = trackColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final stopPaint =
        Paint()
          ..color = stopIndicatorColor
          ..style = PaintingStyle.fill;

    if (value != null) {
      // -------------------------------------------------------------
      // Determinate Mode
      // -------------------------------------------------------------
      final clampedValue = value!.clamp(0.0, 1.0);

      // Wave Flattening: amplitude smooth attenuation near 0.0 and 1.0
      double ampFraction = 1.0;
      if (clampedValue <= 0.1) {
        ampFraction = clampedValue / 0.1;
      } else if (clampedValue >= 0.95) {
        ampFraction = ((1.0 - clampedValue) / 0.05).clamp(0.0, 1.0);
      }
      final currentAmp = amplitude * ampFraction;

      final barHead = clampedValue * totalWidth;
      final activeVisible = barHead >= capWidth;

      // Draw active wavy segment
      if (clampedValue > 0) {
        final adjustedHead = barHead.clamp(capWidth, totalWidth - capWidth);
        final adjustedTail = capWidth;

        if (adjustedHead > adjustedTail) {
          final waveShift =
              currentAmp > 0 ? (animationValue % 1.0) * wavelength : 0.0;
          _drawWavySegment(
            canvas: canvas,
            startPx: adjustedTail,
            endPx: adjustedHead,
            midY: midY,
            totalWidth: totalWidth,
            amplitude: currentAmp,
            wavelength: wavelength,
            waveShift: waveShift,
            paint: activePaint,
          );
        }
      }

      // Track remaining
      final adaptiveGap = activeVisible ? trackGap + capWidth * 2 : trackGap;
      final trackStartX = clampedValue > 0 ? barHead + adaptiveGap : capWidth;
      final trackEndX = totalWidth - capWidth;

      if (trackStartX < trackEndX) {
        canvas.drawLine(
          Offset(trackStartX, midY),
          Offset(trackEndX, midY),
          trackPaint,
        );
      }

      // Stop indicator at end of track
      if (stopIndicatorWidth > 0 && clampedValue < 1.0) {
        var currentStopSize = math.min(strokeWidth, stopIndicatorWidth);
        var indicatorX = totalWidth - currentStopSize;
        final progressX = barHead + capWidth;

        if (indicatorX <= progressX) {
          currentStopSize = math.max(0.0, currentStopSize - (progressX - indicatorX));
          indicatorX = progressX;
        }

        if (currentStopSize > 0) {
          canvas.drawCircle(
            Offset(indicatorX + currentStopSize / 2, midY),
            currentStopSize / 2,
            stopPaint,
          );
        }
      }
    } else {
      // -------------------------------------------------------------
      // Indeterminate Mode (M3 Specification)
      // -------------------------------------------------------------
      // 1750ms cycle with 2 line segments moving with Cubic(0.2, 0.0, 0.0, 1.0)
      final t = animationValue * 1750.0;

      // Line 1:
      // Head: 0ms..1000ms
      // Tail: 250ms..1250ms
      final line1HeadFrac = (t / 1000.0).clamp(0.0, 1.0);
      final line1TailFrac = ((t - 250.0) / 1000.0).clamp(0.0, 1.0);
      final line1Head = _indeterminateCurve.transform(line1HeadFrac);
      final line1Tail = _indeterminateCurve.transform(line1TailFrac);

      // Line 2:
      // Head: 650ms..1500ms (duration 850ms)
      // Tail: 900ms..1750ms (duration 850ms)
      final line2HeadFrac = ((t - 650.0) / 850.0).clamp(0.0, 1.0);
      final line2TailFrac = ((t - 900.0) / 850.0).clamp(0.0, 1.0);
      final line2Head = _indeterminateCurve.transform(line2HeadFrac);
      final line2Tail = _indeterminateCurve.transform(line2TailFrac);

      // Draw full background track
      canvas.drawLine(
        Offset(capWidth, midY),
        Offset(totalWidth - capWidth, midY),
        trackPaint,
      );

      final waveShift =
          amplitude > 0
              ? (animationValue * (1750.0 / 1000.0) * waveSpeed) % wavelength
              : 0.0;

      // Draw Line 1
      if (line1Head > line1Tail) {
        final startX = (line1Tail * totalWidth).clamp(capWidth, totalWidth - capWidth);
        final endX = (line1Head * totalWidth).clamp(capWidth, totalWidth - capWidth);
        if (endX > startX) {
          _drawWavySegment(
            canvas: canvas,
            startPx: startX,
            endPx: endX,
            midY: midY,
            totalWidth: totalWidth,
            amplitude: amplitude,
            wavelength: wavelength,
            waveShift: waveShift,
            paint: activePaint,
          );
        }
      }

      // Draw Line 2
      if (line2Head > line2Tail) {
        final startX = (line2Tail * totalWidth).clamp(capWidth, totalWidth - capWidth);
        final endX = (line2Head * totalWidth).clamp(capWidth, totalWidth - capWidth);
        if (endX > startX) {
          _drawWavySegment(
            canvas: canvas,
            startPx: startX,
            endPx: endX,
            midY: midY,
            totalWidth: totalWidth,
            amplitude: amplitude,
            wavelength: wavelength,
            waveShift: waveShift,
            paint: activePaint,
          );
        }
      }
    }
  }

  /// Draws a smooth wave segment from [startPx] to [endPx] using quadratic bezier curves
  /// and path metric extraction for mathematically precise M3 waveform continuity.
  void _drawWavySegment({
    required Canvas canvas,
    required double startPx,
    required double endPx,
    required double midY,
    required double totalWidth,
    required double amplitude,
    required double wavelength,
    required double waveShift,
    required Paint paint,
  }) {
    if (endPx <= startPx) return;

    if (amplitude <= 0) {
      // Completely flat line optimization
      canvas.drawLine(Offset(startPx, midY), Offset(endPx, midY), paint);
      return;
    }

    final halfWavelength = wavelength / 2.0;
    if (halfWavelength <= 0) return;

    // Generate smooth quadratic bezier sine-wave path with extra phases to cover waveShift
    final fullPath = Path();
    fullPath.moveTo(0, 0);

    final maxWidthWithExtra = totalWidth + wavelength * 2.0;
    double anchorX = halfWavelength;
    double controlX = halfWavelength / 2.0;
    // With quadratic plotting, control point at ±2*amp produces a wave peak at ±amp
    double controlY = amplitude * 2.0;

    while (anchorX <= maxWidthWithExtra) {
      fullPath.quadraticBezierTo(controlX, controlY, anchorX, 0);
      anchorX += halfWavelength;
      controlX += halfWavelength;
      controlY = -controlY;
    }

    // Compute metric for precise extraction
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalPathLength = metric.length;
    final actualPathWidth = anchorX - halfWavelength;
    final pathScale =
        actualPathWidth > 0 ? totalPathLength / actualPathWidth : 1.0;

    final startDistance = (startPx + waveShift) * pathScale;
    final stopDistance = (endPx + waveShift) * pathScale;

    if (stopDistance <= startDistance) return;

    final segment = metric.extractPath(startDistance, stopDistance);

    canvas.save();
    canvas.translate(-waveShift, midY);
    canvas.drawPath(segment, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WavyLinearPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.stopIndicatorColor != stopIndicatorColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.stopIndicatorWidth != stopIndicatorWidth ||
        oldDelegate.trackGap != trackGap ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength ||
        oldDelegate.waveSpeed != waveSpeed;
  }
}
