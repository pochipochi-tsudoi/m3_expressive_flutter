import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

/// Shows a Material 3 Expressive spring-driven modal bottom sheet.
Future<T?> showExpressiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    _ExpressiveSheetRoute<T>(
      builder: builder,
      barrierColor: barrierColor ?? Colors.black54,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      sheetBackgroundColor: backgroundColor,
      sheetElevation: elevation,
      sheetShape: shape,
      sheetClipBehavior: clipBehavior,
    ),
  );
}

class _ExpressiveSheetRoute<T> extends PopupRoute<T> {
  _ExpressiveSheetRoute({
    required this.builder,
    required Color barrierColor,
    required this.isDismissible,
    required this.enableDrag,
    this.sheetBackgroundColor,
    this.sheetElevation,
    this.sheetShape,
    this.sheetClipBehavior,
  }) : _barrierColor = barrierColor;

  final WidgetBuilder builder;
  final Color _barrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final Color? sheetBackgroundColor;
  final double? sheetElevation;
  final ShapeBorder? sheetShape;
  final Clip? sheetClipBehavior;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  AnimationController createAnimationController() {
    return AnimationController(
      vsync: navigator!.overlay!,
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final cs = Theme.of(context).colorScheme;
    final defaultShape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: _ExpressiveSheetContainer(
        enableDrag: enableDrag,
        child: Material(
          color: sheetBackgroundColor ?? cs.surfaceContainerLow,
          elevation: sheetElevation ?? 1.0,
          shape: sheetShape ?? defaultShape,
          clipBehavior: sheetClipBehavior ?? Clip.antiAlias,
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}

class _ExpressiveSheetContainer extends StatefulWidget {
  const _ExpressiveSheetContainer({
    required this.enableDrag,
    required this.child,
  });

  final bool enableDrag;
  final Widget child;

  @override
  State<_ExpressiveSheetContainer> createState() =>
      _ExpressiveSheetContainerState();
}

class _ExpressiveSheetContainerState extends State<_ExpressiveSheetContainer>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late final AnimationController _settleController;
  late Animation<double> _settleAnimation;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
      setState(() => _dragOffset = _settleAnimation.value);
    });
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;
    _settleController.stop();
    setState(() {
      _dragOffset = math.max(0.0, _dragOffset + (details.primaryDelta ?? 0.0));
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;
    final height = context.size?.height ?? 1.0;
    final velocity = details.primaryVelocity ?? 0.0;

    if (velocity > 350 || _dragOffset > height * 0.35) {
      Navigator.of(context).pop();
    } else {
      _settleAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _settleController,
          curve: Curves.easeOutCubic,
        ),
      );
      _settleController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Transform.translate(
      offset: Offset(0.0, _dragOffset),
      child: widget.child,
    );

    if (widget.enableDrag) {
      result = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: result,
      );
    }

    return result;
  }
}
