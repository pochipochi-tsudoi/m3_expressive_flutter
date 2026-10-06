library button_groups;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Public types
// ---------------------------------------------------------------------------

/// 選択モードの定義。
enum ButtonGroupSelectionMode {
  /// 選択状態なし（アクションボタン群）
  none,

  /// 1つだけ選択可能
  single,

  /// 複数同時選択可能
  multi,

  /// 必ず1つは選択されている（Segmented Button 相当）
  required,
}

/// [ButtonGroup] の各ボタンの設定データ。
class ButtonGroupItem {
  /// ボタンのラベルテキスト。
  final String? label;

  /// ボタンのアイコン（省略可）。
  final Widget? icon;

  /// ボタンタップ時のコールバック。[selectionMode] が none のときのみ有効。
  final VoidCallback? onPressed;

  /// false の場合はボタンが無効化される。
  final bool enabled;

  const ButtonGroupItem({
    this.label,
    this.icon,
    this.onPressed,
    this.enabled = true,
  }) : assert(
         label != null || icon != null,
         'ButtonGroupItem must have at least one of label or icon',
       );
}

// ---------------------------------------------------------------------------
// Theme extension
// ---------------------------------------------------------------------------

/// [ButtonGroup] のテーマ設定。[ThemeExtension] として利用可能。
class ButtonGroupTheme extends ThemeExtension<ButtonGroupTheme> {
  /// Standard バリアントのボタン間ギャップ（デフォルト 8dp）。
  final double standardGap;

  /// Connected バリアントのボタン間ギャップ（デフォルト 2dp）。
  final double connectedGap;

  /// Connected バリアントの外側コーナー半径（デフォルト 50% = full pill）。
  final double connectedOuterRadius;

  /// Connected バリアントの内側コーナー半径（未選択時、デフォルト 8dp）。
  final double connectedInnerRadius;

  /// Connected バリアントの内側コーナー半径（プレス中、デフォルト 4dp）。
  final double connectedInnerRadiusPressed;

  /// アニメーション時間。
  final Duration duration;

  /// アニメーションカーブ。
  final Curve curve;

  const ButtonGroupTheme({
    this.standardGap = 8,
    this.connectedGap = 2,
    this.connectedOuterRadius = 50,
    this.connectedInnerRadius = 8,
    this.connectedInnerRadiusPressed = 4,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  ButtonGroupTheme copyWith({
    double? standardGap,
    double? connectedGap,
    double? connectedOuterRadius,
    double? connectedInnerRadius,
    double? connectedInnerRadiusPressed,
    Duration? duration,
    Curve? curve,
  }) {
    return ButtonGroupTheme(
      standardGap: standardGap ?? this.standardGap,
      connectedGap: connectedGap ?? this.connectedGap,
      connectedOuterRadius: connectedOuterRadius ?? this.connectedOuterRadius,
      connectedInnerRadius: connectedInnerRadius ?? this.connectedInnerRadius,
      connectedInnerRadiusPressed:
          connectedInnerRadiusPressed ?? this.connectedInnerRadiusPressed,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  @override
  ButtonGroupTheme lerp(ThemeExtension<ButtonGroupTheme>? other, double t) {
    if (other is! ButtonGroupTheme) return this;
    double ld(double a, double b) => a + (b - a) * t;
    Duration lDur(Duration a, Duration b) => Duration(
      milliseconds:
          (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t)
              .round(),
    );
    return ButtonGroupTheme(
      standardGap: ld(standardGap, other.standardGap),
      connectedGap: ld(connectedGap, other.connectedGap),
      connectedOuterRadius: ld(
        connectedOuterRadius,
        other.connectedOuterRadius,
      ),
      connectedInnerRadius: ld(
        connectedInnerRadius,
        other.connectedInnerRadius,
      ),
      connectedInnerRadiusPressed: ld(
        connectedInnerRadiusPressed,
        other.connectedInnerRadiusPressed,
      ),
      duration: lDur(duration, other.duration),
      curve: t < 0.5 ? curve : other.curve,
    );
  }
}

// ---------------------------------------------------------------------------
// ButtonGroup widget
// ---------------------------------------------------------------------------

/// M3 Expressive Button Groups ウィジェット。
///
/// [ButtonGroup.standard] — 8dp ギャップで並べたボタン群。
/// [ButtonGroup.connected] — 2dp ギャップ＋シェイプモーフィングのボタン群。
///
/// ```dart
/// // Standard
/// ButtonGroup.standard(
///   children: [
///     ButtonGroupItem(label: 'One', onPressed: () {}),
///     ButtonGroupItem(label: 'Two', icon: Icon(Icons.edit), onPressed: () {}),
///   ],
/// )
///
/// // Connected (単一選択)
/// ButtonGroup.connected(
///   selectionMode: ButtonGroupSelectionMode.required,
///   initialSelection: {0},
///   onSelectionChanged: (indices) {},
///   children: [
///     ButtonGroupItem(label: 'Day'),
///     ButtonGroupItem(label: 'Week'),
///     ButtonGroupItem(label: 'Month'),
///   ],
/// )
/// ```
class ButtonGroup extends StatefulWidget {
  /// Standard バリアント（アクションボタン群）。
  const ButtonGroup.standard({
    super.key,
    required this.children,
    this.buttonStyle,
  }) : _isConnected = false,
       selectionMode = ButtonGroupSelectionMode.none,
       initialSelection = const {},
       onSelectionChanged = null;

  /// Connected バリアント（選択可能ボタン群）。
  const ButtonGroup.connected({
    super.key,
    required this.children,
    this.selectionMode = ButtonGroupSelectionMode.single,
    this.initialSelection = const {},
    this.onSelectionChanged,
    this.buttonStyle,
  }) : _isConnected = true;

  final List<ButtonGroupItem> children;
  final bool _isConnected;
  final ButtonGroupSelectionMode selectionMode;
  final Set<int> initialSelection;
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// ベースとなるボタンスタイル（省略時は FilledButton.tonal デフォルト）。
  final ButtonStyle? buttonStyle;

  @override
  State<ButtonGroup> createState() => _ButtonGroupState();
}

class _ButtonGroupState extends State<ButtonGroup> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelection);
  }

  void _onTap(int index) {
    if (!widget.children[index].enabled) return;

    setState(() {
      switch (widget.selectionMode) {
        case ButtonGroupSelectionMode.none:
          widget.children[index].onPressed?.call();
          return;

        case ButtonGroupSelectionMode.single:
          if (_selected.contains(index)) {
            _selected = {};
          } else {
            _selected = {index};
          }

        case ButtonGroupSelectionMode.required:
          if (_selected.contains(index) && _selected.length == 1) return;
          _selected = {index};

        case ButtonGroupSelectionMode.multi:
          if (_selected.contains(index)) {
            _selected = {..._selected}..remove(index);
          } else {
            _selected = {..._selected, index};
          }
      }
    });

    widget.onSelectionChanged?.call(Set.unmodifiable(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<ButtonGroupTheme>() ??
        const ButtonGroupTheme();
    final gap = widget._isConnected ? theme.connectedGap : theme.standardGap;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          widget._isConnected
              ? _ConnectedButton(
                item: widget.children[i],
                index: i,
                total: widget.children.length,
                isSelected: _selected.contains(i),
                leftSelected: i > 0 && _selected.contains(i - 1),
                rightSelected:
                    i < widget.children.length - 1 && _selected.contains(i + 1),
                onTap: () => _onTap(i),
                buttonStyle: widget.buttonStyle,
                theme: theme,
              )
              : _StandardButton(
                item: widget.children[i],
                onTap: () => _onTap(i),
                buttonStyle: widget.buttonStyle,
              ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Standard button
// ---------------------------------------------------------------------------

class _StandardButton extends StatelessWidget {
  const _StandardButton({
    required this.item,
    required this.onTap,
    this.buttonStyle,
  });

  final ButtonGroupItem item;
  final VoidCallback onTap;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle ?? FilledButton.styleFrom();

    Widget child;
    if (item.icon != null && item.label != null) {
      child = FilledButton.tonalIcon(
        onPressed: item.enabled ? onTap : null,
        style: style,
        icon: item.icon!,
        label: Text(item.label!),
      );
    } else if (item.icon != null) {
      child = FilledButton.tonal(
        onPressed: item.enabled ? onTap : null,
        style: style,
        child: item.icon!,
      );
    } else {
      child = FilledButton.tonal(
        onPressed: item.enabled ? onTap : null,
        style: style,
        child: Text(item.label!),
      );
    }

    return Semantics(button: true, enabled: item.enabled, child: child);
  }
}

// ---------------------------------------------------------------------------
// Connected button (with shape morphing)
// ---------------------------------------------------------------------------

class _ConnectedButton extends StatefulWidget {
  const _ConnectedButton({
    required this.item,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.leftSelected,
    required this.rightSelected,
    required this.onTap,
    required this.theme,
    this.buttonStyle,
  });

  final ButtonGroupItem item;
  final int index;
  final int total;
  final bool isSelected;
  final bool leftSelected;
  final bool rightSelected;
  final VoidCallback onTap;
  final ButtonGroupTheme theme;
  final ButtonStyle? buttonStyle;

  @override
  State<_ConnectedButton> createState() => _ConnectedButtonState();
}

class _ConnectedButtonState extends State<_ConnectedButton> {
  bool _isPressed = false;

  bool get _isFirst => widget.index == 0;
  bool get _isLast => widget.index == widget.total - 1;

  /// 選択時に内側コーナーがpill形（外側コーナーと同じ大きな丸）になるため
  /// outer radius は ButtonGroupTheme.connectedOuterRadius を使う。
  BorderRadius _computeBorderRadius() {
    final t = widget.theme;
    final outer = t.connectedOuterRadius;
    final inner =
        _isPressed ? t.connectedInnerRadiusPressed : t.connectedInnerRadius;

    // 選択されているボタン → 指定コーナーが pill 形 (outer) になる
    // 隣接ボタン → 接触コーナーが inner になる
    // 非接触コーナーは outer のまま

    double topLeft;
    double topRight;
    double bottomLeft;
    double bottomRight;

    if (widget.isSelected) {
      // 選択中: 全コーナー pill
      topLeft = outer;
      topRight = outer;
      bottomLeft = outer;
      bottomRight = outer;
    } else {
      // 右隣が選択されているか
      final adjacentRight = widget.rightSelected;
      // 左隣が選択されているか
      final adjacentLeft = widget.leftSelected;

      topLeft = adjacentLeft ? inner : outer;
      bottomLeft = adjacentLeft ? inner : outer;
      topRight = adjacentRight ? inner : outer;
      bottomRight = adjacentRight ? inner : outer;

      // 端は常に outer
      if (_isFirst) {
        topLeft = outer;
        bottomLeft = outer;
      }
      if (_isLast) {
        topRight = outer;
        bottomRight = outer;
      }
    }

    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = widget.theme;

    final borderRadius = _computeBorderRadius();

    // 選択時 → secondaryContainer、非選択 → surfaceVariant (tonal style)
    final bgColor =
        widget.isSelected
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest;
    final fgColor =
        widget.isSelected
            ? scheme.onSecondaryContainer
            : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      enabled: widget.item.enabled,
      child: AnimatedContainer(
        duration: t.duration,
        curve: t.curve,
        decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.item.enabled ? widget.onTap : null,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: IconTheme.merge(
                data: IconThemeData(color: fgColor, size: 20),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final item = widget.item;
    if (item.icon != null && item.label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [item.icon!, const SizedBox(width: 8), Text(item.label!)],
      );
    } else if (item.icon != null) {
      return item.icon!;
    } else {
      return Text(item.label!);
    }
  }
}
