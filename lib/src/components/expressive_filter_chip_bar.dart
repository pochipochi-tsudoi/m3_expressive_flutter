import 'package:material_ui/material_ui.dart' hide MaterialShapes;
import 'package:motor/motor.dart';
import 'package:m3_expressive_flutter/src/shapes/expressive_shapes.dart';
import 'package:m3_expressive_flutter/src/shapes/shape_border.dart';

/// An item data model for [ExpressiveFilterChipBar].
@immutable
class ExpressiveFilterItem<T> {
  const ExpressiveFilterItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// A horizontal scrollable filter chip bar with morphing pill radii and spring-driven scrolling.
class ExpressiveFilterChipBar<T> extends StatefulWidget {
  const ExpressiveFilterChipBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.spacing = 8.0,
  });

  final List<ExpressiveFilterItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  State<ExpressiveFilterChipBar<T>> createState() =>
      _ExpressiveFilterChipBarState<T>();
}

class _ExpressiveFilterChipBarState<T>
    extends State<ExpressiveFilterChipBar<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index, GlobalKey itemKey) {
    final context = itemKey.currentContext;
    if (context == null || !_scrollController.hasClients) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final viewport = _scrollController.position.viewportDimension;
    final itemOffset = box.localToGlobal(Offset.zero).dx;
    final itemWidth = box.size.width;

    // Check if the item is outside the 25% boundary
    final leftThreshold = viewport * 0.25;
    final rightThreshold = viewport * 0.75;

    if (itemOffset < leftThreshold || itemOffset + itemWidth > rightThreshold) {
      final targetScroll =
          _scrollController.offset + itemOffset - leftThreshold;
      _scrollController.animateTo(
        targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            if (i > 0) SizedBox(width: widget.spacing),
            _FilterChipItem<T>(
              item: widget.items[i],
              isSelected: widget.items[i].value == widget.selectedValue,
              onTap: (key) {
                widget.onSelected(widget.items[i].value);
                _scrollToIndex(i, key);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChipItem<T> extends StatelessWidget {
  _FilterChipItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : _key = GlobalKey();

  final ExpressiveFilterItem<T> item;
  final bool isSelected;
  final void Function(GlobalKey key) onTap;
  final GlobalKey _key;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SingleMotionBuilder(
      key: _key,
      motion: const MaterialSpringMotion.standardSpatialFast(),
      value: isSelected ? 1.0 : 0.0,
      active: !reduce,
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        final radius = 12.0 + (22.0 - 12.0) * tc;
        final bg = Color.lerp(cs.surfaceContainerHigh, cs.secondaryContainer, tc)!;
        final fg = Color.lerp(cs.onSurfaceVariant, cs.onSecondaryContainer, tc)!;

        final offShape = MaterialShapes.circle;
        final onShape = MaterialShapes.cookie7Sided;
        final shapeBorder = ShapeBorder.lerp(
          M3eShapeBorder(polygon: offShape),
          M3eShapeBorder(polygon: onShape),
          tc,
        );

        return Material(
          animationDuration: Duration.zero,
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(_key),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: ShapeDecoration(
                        color: fg.withValues(alpha: 0.12),
                        shape: shapeBorder ?? M3eShapeBorder(polygon: offShape),
                      ),
                      child: Icon(item.icon, size: 14.0, color: fg),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
