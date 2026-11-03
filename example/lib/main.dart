import 'package:material_ui/material_ui.dart' hide MaterialShapes;
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M3 Expressive Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.grey;

    return Scaffold(
      appBar: M3eAppBar(
        child: SearchAppBar(onChanged: (q) {}, hintText: '検索'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('FABs'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              M3eFab.small(
                icon: const Icon(Icons.add),
                color: Colors.purple,
                onPressed: () {},
              ),
              M3eFab.regular(
                icon: const Icon(Icons.add),
                color: Colors.purple,
                onPressed: () {},
              ),
              M3eFab.large(
                icon: const Icon(Icons.add),
                color: Colors.purple,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('FlexIconButton'),
          const SizedBox(height: 8),
          FlexIconButton(
            icon: const Icon(Icons.edit),
            fillColor: Theme.of(context).colorScheme.primary,
            text: 'Edit',
            onPressed: () {},
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // ── Button Groups ──────────────────────────────────────────────
          Text('Button Groups', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),

          // Standard
          Text(
            'Standard (アクション)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ButtonGroup.standard(
            children: [
              ButtonGroupItem(
                icon: const Icon(Icons.edit),
                label: 'Edit',
                onPressed: () {},
              ),
              ButtonGroupItem(
                icon: const Icon(Icons.share),
                label: 'Share',
                onPressed: () {},
              ),
              ButtonGroupItem(
                icon: const Icon(Icons.delete),
                label: 'Delete',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Connected — Required (Segmented Button 相当)
          Text(
            'Connected — Required (1つ必須選択)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _ConnectedRequiredDemo(),
          const SizedBox(height: 24),

          // Connected — Multi select
          Text(
            'Connected — Multi (複数選択)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _ConnectedMultiDemo(),
          const SizedBox(height: 24),

          // Connected — Single select
          Text(
            'Connected — Single (単一選択)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _ConnectedSingleDemo(),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 14),
          Text('Shapes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const SizedBox(height: 12),
          const _ShapesGrid(),
          _LoadingIndicator(),
          const Divider(),
          const SizedBox(height: 14),
          const _ExpressiveWidgetsDemo(),
          const SizedBox(height: 40),
        ],
      ),
      floatingActionButton: M3eFab.menu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FlexIconButton(
              icon: const Icon(Icons.edit),
              fillColor: primaryColor,
              text: 'Edit',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            FlexIconButton(
              icon: const Icon(Icons.share),
              fillColor: primaryColor,
              text: 'Share',
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            FlexIconButton(
              icon: const Icon(Icons.calendar_month),
              fillColor: primaryColor,
              text: 'Calendar Month',
              onPressed: () {},
            ),
          ],
        ),
        color: Theme.of(context).colorScheme.primary,
        icon: Icons.menu,
        openColor: Colors.grey.shade400,
        openAsCircle: true,
      ),
    );
  }
}

class _ConnectedRequiredDemo extends StatefulWidget {
  @override
  State<_ConnectedRequiredDemo> createState() => _ConnectedRequiredDemoState();
}

class _ConnectedRequiredDemoState extends State<_ConnectedRequiredDemo> {
  Set<int> _selected = {0};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ButtonGroup.connected(
          selectionMode: ButtonGroupSelectionMode.required,
          initialSelection: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          children: const [
            ButtonGroupItem(label: 'Day'),
            ButtonGroupItem(label: 'Week'),
            ButtonGroupItem(label: 'Month'),
            ButtonGroupItem(label: 'Year'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '選択中: ${_selected.map((i) => ['Day', 'Week', 'Month', 'Year'][i]).join(', ')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ConnectedMultiDemo extends StatefulWidget {
  @override
  State<_ConnectedMultiDemo> createState() => _ConnectedMultiDemoState();
}

class _ConnectedMultiDemoState extends State<_ConnectedMultiDemo> {
  Set<int> _selected = {0, 2};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ButtonGroup.connected(
          selectionMode: ButtonGroupSelectionMode.multi,
          initialSelection: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          children: const [
            ButtonGroupItem(icon: Icon(Icons.format_bold), label: 'Bold'),
            ButtonGroupItem(icon: Icon(Icons.format_italic), label: 'Italic'),
            ButtonGroupItem(
              icon: Icon(Icons.format_underline),
              label: 'Underline',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '選択中 インデックス: $_selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ShapesGrid extends StatelessWidget {
  const _ShapesGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 6×6 = 36 cells, 35 shapes + 1 empty
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: 36,
      itemBuilder: (context, index) {
        if (index >= M3eShapes.all.length) {
          // 36th cell — empty placeholder
          return const SizedBox.shrink();
        }
        final id = M3eShapes.all[index];
        return _ShapeCell(id: id, scheme: scheme);
      },
    );
  }
}

class _ShapeCell extends StatelessWidget {
  const _ShapeCell({required this.id, required this.scheme});

  final M3eShapeId id;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: M3eShape.fromId(
            id: id,
            size: 56,
            color: scheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          id.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 9,
            color: scheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ConnectedSingleDemo extends StatefulWidget {
  @override
  State<_ConnectedSingleDemo> createState() => _ConnectedSingleDemoState();
}

class _ConnectedSingleDemoState extends State<_ConnectedSingleDemo> {
  Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ButtonGroup.connected(
          selectionMode: ButtonGroupSelectionMode.single,
          initialSelection: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          children: const [
            ButtonGroupItem(icon: Icon(Icons.wb_sunny), label: 'Light'),
            ButtonGroupItem(icon: Icon(Icons.brightness_auto), label: 'Auto'),
            ButtonGroupItem(icon: Icon(Icons.dark_mode), label: 'Dark'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _selected.isEmpty
              ? '未選択'
              : '選択中: ${['Light', 'Auto', 'Dark'][_selected.first]}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        M3eShapes.LoadingIndicator(),
        const SizedBox(width: 16),
        M3eShapes.ContainedLoadingIndicator(),
      ],
    );
  }
}

class _ExpressiveWidgetsDemo extends StatefulWidget {
  const _ExpressiveWidgetsDemo();

  @override
  State<_ExpressiveWidgetsDemo> createState() => _ExpressiveWidgetsDemoState();
}

class _ExpressiveWidgetsDemoState extends State<_ExpressiveWidgetsDemo> {
  double _sliderValue = 0.5;
  bool _toggleSelected = false;
  bool _buttonBusy = false;
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Wavy Indicators ──────────────────────────────────────────
        Text(
          'Wavy Indicators',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        const WavyLinearProgressIndicator(value: 0.5),
        const SizedBox(height: 12),
        const WavyLinearProgressIndicator(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            CircularWavyProgressIndicator(value: 0.75),
            CircularWavyProgressIndicator(),
          ],
        ),
        const SizedBox(height: 24),

        // ── Wavy Slider ──────────────────────────────────────────────
        Text(
          'Wavy Slider',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ExpressiveWavySlider(
          value: _sliderValue,
          onChanged: (val) => setState(() => _sliderValue = val),
        ),
        const SizedBox(height: 24),

        // ── Morph Button & Shape Toggle ──────────────────────────────
        Text(
          'Morph Button & Shape Toggle',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ExpressiveMorphButton(
                busy: _buttonBusy,
                onPressed: () {
                  setState(() => _buttonBusy = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _buttonBusy = false);
                  });
                },
                child: const Text('Morph Button'),
              ),
            ),
            const SizedBox(width: 16),
            ExpressiveShapeToggle(
              selected: _toggleSelected,
              icon: Icons.star_border,
              selectedIcon: Icons.star,
              rotationTurnsOnSelect: 0.25,
              onChanged: (val) => setState(() => _toggleSelected = val),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Grouped Section ──────────────────────────────────────────
        Text(
          'Grouped Section',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ExpressiveGroupedSection(
          children: [
            ExpressiveGroupedTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Sound Quality'),
              subtitle: const Text('Lossless streaming enabled'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ExpressiveGroupedTile(
              leading: const Icon(Icons.equalizer),
              title: const Text('Equalizer'),
              subtitle: const Text('Custom curve active'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ExpressiveGroupedTile(
              leading: const Icon(Icons.spatial_audio),
              title: const Text('Spatial Audio'),
              subtitle: const Text('Dynamic head tracking'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Filter Chip Bar ──────────────────────────────────────────
        Text(
          'Filter Chip Bar',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ExpressiveFilterChipBar<String>(
          selectedValue: _selectedCategory,
          items: const [
            ExpressiveFilterItem(
              value: 'all',
              label: 'All',
              icon: Icons.apps,
            ),
            ExpressiveFilterItem(
              value: 'audio',
              label: 'Audio',
              icon: Icons.headphones,
            ),
            ExpressiveFilterItem(
              value: 'video',
              label: 'Video',
              icon: Icons.movie,
            ),
            ExpressiveFilterItem(
              value: 'playlists',
              label: 'Playlists',
              icon: Icons.queue_music,
            ),
          ],
          onSelected: (val) => setState(() => _selectedCategory = val),
        ),
        const SizedBox(height: 24),

        // ── Badge & Expandable Text ──────────────────────────────────
        Text(
          'Badge & Expandable Text',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MorphingShapeBadge(
              fromShape: MaterialShapes.circle,
              toShape: MaterialShapes.cookie7Sided,
              size: 56.0,
              child: const Icon(Icons.auto_awesome, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: ExpressiveExpandableText(
                text:
                    'Material 3 Expressive introduces fluid, tactile UI patterns with physics-based spring motions. '
                    'Polygons seamlessly morph into different shapes, progress indicators expressively wave and breathe, '
                    'and sheets snap to place with spring dynamics for a lively mobile experience.',
                collapsedMaxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Sheets & Snacks ──────────────────────────────────────────
        Text(
          'Sheets & Snacks',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.tonal(
              onPressed: () {
                showExpressiveConfirmSheet(
                  context: context,
                  title: 'Publish Track?',
                  message: 'Your track will be accessible to public listeners.',
                  confirmLabel: 'Publish',
                );
              },
              child: const Text('Confirm Sheet'),
            ),
            FilledButton.tonal(
              onPressed: () {
                showExpressiveConfirmSheet(
                  context: context,
                  title: 'Delete Playlist?',
                  message: 'This action is irreversible.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
              },
              child: const Text('Destructive Sheet'),
            ),
            FilledButton(
              onPressed: () {
                showExpressiveSnack(
                  context: context,
                  message: 'Added to your favorites queue',
                  icon: Icons.favorite,
                  actionLabel: 'UNDO',
                  onAction: () {},
                );
              },
              child: const Text('Stack Snack'),
            ),
          ],
        ),
      ],
    );
  }
}
