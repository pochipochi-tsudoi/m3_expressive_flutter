import 'package:material_ui/material_ui.dart' hide MaterialShapes;
import 'package:flutter_test/flutter_test.dart';
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';

void main() {
  group('M3eMotion', () {
    test('clampSpatial clamps between 0.0 and 1.0', () {
      expect(M3eMotion.clampSpatial(-0.2), 0.0);
      expect(M3eMotion.clampSpatial(0.5), 0.5);
      expect(M3eMotion.clampSpatial(1.2), 1.0);
    });

    testWidgets('shouldReduceMotion reads from context', (tester) async {
      late bool reduceMotion;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              reduceMotion = M3eMotion.shouldReduceMotion(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reduceMotion, isFalse);
    });
  });

  group('WavyLinearProgressIndicator', () {
    testWidgets('determinate renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WavyLinearProgressIndicator(value: 0.5),
          ),
        ),
      );
      expect(find.byType(WavyLinearProgressIndicator), findsOneWidget);
    });

    testWidgets('indeterminate renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WavyLinearProgressIndicator(),
          ),
        ),
      );
      expect(find.byType(WavyLinearProgressIndicator), findsOneWidget);
    });
  });

  group('CircularWavyProgressIndicator', () {
    testWidgets('determinate and indeterminate render without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CircularWavyProgressIndicator(value: 0.75),
                CircularWavyProgressIndicator(),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CircularWavyProgressIndicator), findsNWidgets(2));
    });
  });

  group('ExpressiveRefreshIndicator', () {
    testWidgets('renders child properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpressiveRefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                children: const [Text('Item 1'), Text('Item 2')],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
    });
  });

  group('ExpressiveConfirmSheet', () {
    testWidgets('renders title, message and buttons', (tester) async {
      bool confirmed = false;
      bool canceled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpressiveConfirmSheet(
              title: 'Delete Item?',
              message: 'This cannot be undone.',
              confirmLabel: 'Delete',
              isDestructive: true,
              onConfirm: () => confirmed = true,
              onCancel: () => canceled = true,
            ),
          ),
        ),
      );

      expect(find.text('Delete Item?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      expect(confirmed, isTrue);

      await tester.tap(find.text('Cancel'));
      expect(canceled, isTrue);
    });
  });

  group('SnackView', () {
    testWidgets('renders message and icon', (tester) async {
      final snack = Snack(
        message: 'Saved to library',
        icon: Icons.check,
        actionLabel: 'Undo',
        onAction: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnackView(snack: snack),
          ),
        ),
      );

      expect(find.text('Saved to library'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('ExpressiveMorphButton', () {
    testWidgets('tap triggers onPressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpressiveMorphButton(
              onPressed: () => tapped = true,
              child: const Text('Action'),
            ),
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
      await tester.tap(find.text('Action'));
      expect(tapped, isTrue);
    });

    testWidgets('busy state shows indicator and disables tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpressiveMorphButton(
              busy: true,
              onPressed: () => tapped = true,
              child: const Text('Action'),
            ),
          ),
        ),
      );

      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
      await tester.tap(find.byType(ExpressiveMorphButton));
      expect(tapped, isFalse);
    });
  });

  group('ExpressiveShapeToggle', () {
    testWidgets('toggles on tap', (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ExpressiveShapeToggle(
                  selected: selected,
                  icon: Icons.star_border,
                  selectedIcon: Icons.star,
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      await tester.tap(find.byType(ExpressiveShapeToggle));
      await tester.pumpAndSettle();

      expect(selected, isTrue);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('ExpressiveWavySlider & ExpressiveWavyBar', () {
    testWidgets('renders bar and slider', (tester) async {
      double value = 0.4;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const ExpressiveWavyBar(value: 0.5, dragging: false),
                ExpressiveWavySlider(
                  value: value,
                  onChanged: (v) => value = v,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ExpressiveWavyBar), findsNWidgets(2));
      expect(find.byType(ExpressiveWavySlider), findsOneWidget);
    });
  });

  group('ExpressiveGroupedSection', () {
    testWidgets('renders section and tiles with nested radii', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpressiveGroupedSection(
              children: [
                ExpressiveGroupedTile(
                  title: const Text('Tile 1'),
                  subtitle: const Text('Sub 1'),
                  onTap: () {},
                ),
                ExpressiveGroupedTile(
                  title: const Text('Tile 2'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tile 1'), findsOneWidget);
      expect(find.text('Sub 1'), findsOneWidget);
      expect(find.text('Tile 2'), findsOneWidget);
    });
  });

  group('ExpressiveFilterChipBar', () {
    testWidgets('selects chip on tap', (tester) async {
      String selected = 'all';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ExpressiveFilterChipBar<String>(
                  selectedValue: selected,
                  items: const [
                    ExpressiveFilterItem(value: 'all', label: 'All'),
                    ExpressiveFilterItem(value: 'music', label: 'Music'),
                    ExpressiveFilterItem(value: 'podcasts', label: 'Podcasts'),
                  ],
                  onSelected: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);

      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();

      expect(selected, 'music');
    });
  });

  group('MorphingShapeBadge & ShapeBloomBackdrop', () {
    testWidgets('renders badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const ShapeBloomBackdrop(),
                MorphingShapeBadge(
                  fromShape: MaterialShapes.circle,
                  toShape: MaterialShapes.cookie7Sided,
                  child: const Icon(Icons.star),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShapeBloomBackdrop), findsOneWidget);
      expect(find.byType(MorphingShapeBadge), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('ExpressiveRemovalCollapse', () {
    testWidgets('renders child when not removed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpressiveRemovalCollapse(
              isRemoved: false,
              child: Text('Item to remove'),
            ),
          ),
        ),
      );

      expect(find.text('Item to remove'), findsOneWidget);
    });
  });

  group('ExpressiveExpandableText', () {
    testWidgets('expands and collapses on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpressiveExpandableText(
              text: 'Very long text that spans multiple lines...',
              expandLabel: 'More',
              collapseLabel: 'Less',
            ),
          ),
        ),
      );

      expect(find.text('More'), findsOneWidget);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Less'), findsOneWidget);
    });
  });
}
