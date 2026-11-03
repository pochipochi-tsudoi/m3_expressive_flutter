import 'package:material_ui/material_ui.dart';

import '../m3e_fab.dart';

/// Menu付きのレギュラーFAB。
/// 使い方: `M3e.WithMenu(child: Column(children:[CircularIconButton(...), ...]))`
/// - required: [child]
/// - 押す前のアイコンは [icon] で設定（デフォルト: Icons.add）。
/// - 押すとアイコンがバツ（Icons.close）になり、[child] のメニューが表示。
/// - 押下後の色は [openColor] で指定可能。
class WithMenu extends StatefulWidget {
  final Widget child; // メニューの中身（丸ボタンを縦に並べる想定）
  final IconData icon; // 閉じているときのアイコン（デフォルト: add）
  final Color? color; // FABの塗り色。未指定ならテーマに従う
  final Color? openColor; // 開いているときのFAB色。未指定なら color と同じ
  final bool openAsCircle; // 開いているときにボタン自体を丸にする

  const WithMenu({
    super.key,
    required this.child,
    required this.icon,
    this.color,
    this.openColor,
    this.openAsCircle = false,
  });

  @override
  State<WithMenu> createState() => _WithMenuState();
}

class _WithMenuState extends State<WithMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turns; // 0 -> 0.25 turns (90度回転)
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _turns = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ).drive(Tween<double>(begin: 0.0, end: 0.25));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<M3eFabTheme>() ?? const M3eFabTheme();

    // メニュー本体（子要素のアニメーション表示）
    final animatedMenu = _animation(
      child: widget.child,
      controller: _controller,
      theme: theme,
    );

    // 状態に応じてアイコンを切替（閉: 指定icon / 開: バツ）+ 回転アニメーション
    final currentIcon = _open ? Icons.close : widget.icon;
    final icon = RotationTransition(turns: _turns, child: Icon(currentIcon));

    // 状態に応じて色を切り替え
    final currentColor = _open
        ? (widget.openColor ?? widget.color)
        : widget.color;

    Widget fabCore = M3eFabCore(
      icon: icon,
      color: currentColor,
      size: FabSize.regular,
      onPressed: _toggle,
    );

    // 開いているときに丸ボタンへ（見た目を円形にクリップ＆アニメーション）
    final fab = (_open && widget.openAsCircle)
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: ClipOval(child: fabCore),
          )
        : fabCore;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // メニュー（上に展開）
        animatedMenu,
        const SizedBox(height: 12),
        fab,
      ],
    );
  }

  // _animation() でプライベートクラスを返す実装
  Widget _animation({
    required Widget child,
    required AnimationController controller,
    required M3eFabTheme theme,
  }) {
    return _MenuAnimation(child: child, controller: controller, theme: theme);
  }
}

/// メニュー部分のアニメーション（非公開）
class _MenuAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final M3eFabTheme theme;

  const _MenuAnimation({
    required this.child,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    return Align(
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      ),
    );
  }
}
