import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import 'snack.dart';
import 'snack_view.dart';

/// A widget that manages and renders up to 3 stacked [SnackView] items.
class SnackStack extends StatefulWidget {
  const SnackStack({
    super.key,
    required this.onEmpty,
  });

  final VoidCallback onEmpty;

  @override
  State<SnackStack> createState() => SnackStackState();
}

class SnackStackState extends State<SnackStack> with TickerProviderStateMixin {
  final List<Snack> _snacks = [];
  final Map<String, Timer> _timers = {};
  late final AnimationController _shakeController;
  String? _shakingSnackId;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void push(Snack snack) {
    final existingIndex = _snacks.indexWhere((s) => s.matches(snack));
    if (existingIndex != -1) {
      // Duplicate: promote to front and shake
      final existing = _snacks.removeAt(existingIndex);
      _snacks.insert(0, existing);
      _restartTimer(existing);
      _triggerShake(existing.id);
      setState(() {});
      return;
    }

    _snacks.insert(0, snack);
    if (_snacks.length > 3) {
      final removed = _snacks.removeLast();
      _timers[removed.id]?.cancel();
      _timers.remove(removed.id);
    }
    _startTimer(snack);
    setState(() {});
  }

  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _snacks.removeWhere((s) => s.id == id);
    setState(() {});
    if (_snacks.isEmpty) {
      widget.onEmpty();
    }
  }

  void _startTimer(Snack snack) {
    _timers[snack.id]?.cancel();
    _timers[snack.id] = Timer(snack.duration, () => dismiss(snack.id));
  }

  void _restartTimer(Snack snack) {
    _startTimer(snack);
  }

  void _triggerShake(String id) {
    _shakingSnackId = id;
    _shakeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _shakingSnackId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_snacks.isEmpty) return const SizedBox.shrink();

    // Render back-to-front so front item is on top
    final displayed = _snacks.take(3).toList();
    final reversedWithDepth = <(Snack, int)>[];
    for (int i = displayed.length - 1; i >= 0; i--) {
      reversedWithDepth.add((displayed[i], i));
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, _) {
        final shakeValue = _shakeController.value;
        final shakeOffset =
            (_shakingSnackId != null && _shakeController.isAnimating)
                ? (math.sin(shakeValue * 4 * math.pi) * 8.0 * (1.0 - shakeValue))
                : 0.0;

        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            for (final (snack, depth) in reversedWithDepth)
              SingleMotionBuilder(
                key: ValueKey(snack.id),
                motion: const MaterialSpringMotion.expressiveSpatialFast(),
                value: 1.0,
                builder: (context, t, child) {
                  return SnackView(
                    snack: snack,
                    depth: depth,
                    shakeOffset: snack.id == _shakingSnackId ? shakeOffset : 0.0,
                    onDismiss: () => dismiss(snack.id),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
