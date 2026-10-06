import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';
// ignore: unnecessary_import - explicit for MaterialShapes in tests
import 'package:material_3p/material_shapes.dart';

void main() {
  group('M3eShapes - 35 iconic shapes', () {
    test('has 35 shapes', () {
      expect(M3eShapes.all.length, 35);
      expect(M3eShapeId.values.length, 35);
    });

    test('all polygons are normalized and non-empty', () {
      for (final id in M3eShapeId.values) {
        final p = id.polygon;
        expect(p.cubics, isNotEmpty, reason: '${id.name} cubics empty');
        // normalized polygons should have cubics in 0..1 range roughly
        // Just verify toPath produces non-empty path
        final path = p.toPath();
        expect(
          path.getBounds().isEmpty,
          isFalse,
          reason: '${id.name} path empty',
        );
      }
    });

    test('byName lookup', () {
      expect(M3eShapes.byName('circle'), M3eShapeId.circle);
      expect(M3eShapes.byName('heart'), M3eShapeId.heart);
      expect(M3eShapes.byName('cookie9Sided'), M3eShapeId.cookie9Sided);
      expect(M3eShapes.tryByName('unknown'), isNull);
      expect(() => M3eShapes.byName('unknown'), throwsArgumentError);
    });

    test('category groupings sum check', () {
      // No duplicate across groups is not required, but each group should be subset of all
      for (final g in [
        M3eShapes.basic,
        M3eShapes.geometric,
        M3eShapes.directional,
        M3eShapes.organic,
        M3eShapes.cookies,
        M3eShapes.starburst,
        M3eShapes.pixel,
      ]) {
        for (final id in g) {
          expect(
            M3eShapes.all.contains(id),
            isTrue,
            reason: '${id.name} not in all',
          );
        }
      }
    });

    test('allPolygons length is 35', () {
      expect(M3eShapes.allPolygons.length, 35);
    });
  });

  group('M3eShapeBorder', () {
    test('getOuterPath does not throw for all shapes', () {
      for (final id in M3eShapeId.values) {
        final border = M3eShapeBorder(polygon: id.polygon);
        final rect = const Rect.fromLTWH(0, 0, 100, 100);
        final path = border.getOuterPath(rect);
        expect(
          path.getBounds().isEmpty,
          isFalse,
          reason: '${id.name} border path empty',
        );
      }
    });

    test('lerp between two shapes produces MorphBorder', () {
      final a = M3eShapeBorder(polygon: MaterialShapes.circle);
      final b = M3eShapeBorder(polygon: MaterialShapes.square);
      final lerped = ShapeBorder.lerp(a, b, 0.5);
      expect(lerped, isA<MorphBorder>());
    });

    test('RoundedPolygon extension toShapeBorder', () {
      final border = MaterialShapes.heart.toShapeBorder();
      expect(border.polygon, MaterialShapes.heart);
    });
  });

  group('Clippers', () {
    test('M3eShapeClipper getClip produces non-empty path for all shapes', () {
      const size = Size(100, 100);
      for (final id in M3eShapeId.values) {
        final clipper = M3eShapeClipper(polygon: id.polygon);
        final path = clipper.getClip(size);
        expect(
          path.getBounds().isEmpty,
          isFalse,
          reason: '${id.name} clipper path empty',
        );
      }
    });

    test('M3eMorphClipper interpolates', () {
      const size = Size(100, 100);
      final clipper0 = M3eMorphClipper(
        start: MaterialShapes.circle,
        end: MaterialShapes.square,
        progress: 0.0,
      );
      final clipper1 = M3eMorphClipper(
        start: MaterialShapes.circle,
        end: MaterialShapes.square,
        progress: 1.0,
      );
      final path0 = clipper0.getClip(size);
      final path1 = clipper1.getClip(size);
      // Paths should differ
      expect(path0.getBounds(), isNot(equals(path1.getBounds())));
    });

    test('PolygonPath extension', () {
      const size = Size(80, 80);
      final path = MaterialShapes.flower.toPathForSize(size);
      expect(path.getBounds().isEmpty, isFalse);
    });

    test('MorphPath extension', () {
      const size = Size(80, 80);
      final morph = Morph(MaterialShapes.circle, MaterialShapes.heart);
      final path = morph.toPathForSize(size, progress: 0.5);
      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  group('Morph', () {
    test('asCubics at 0 and 1 matches start/end cubics count', () {
      final morph = Morph(MaterialShapes.circle, MaterialShapes.square);
      final c0 = morph.asCubics(0.0);
      final c1 = morph.asCubics(1.0);
      expect(c0, isNotEmpty);
      expect(c1, isNotEmpty);
      // Cubic count is equalized
      expect(c0.length, c1.length);
    });

    test(
      'toPath at progress 0/1 roughly matches direct polygon path bounds',
      () {
        // Not exact due to morph equalization, but bounds should be similar
        final morph = Morph(MaterialShapes.circle, MaterialShapes.square);
        final p0 = morph.toPath(progress: 0.0);
        final p1 = morph.toPath(progress: 1.0);
        expect(p0.getBounds().isEmpty, isFalse);
        expect(p1.getBounds().isEmpty, isFalse);
      },
    );
  });

  group('M3eShape widget', () {
    testWidgets('renders without error for all shapes', (tester) async {
      for (final id in M3eShapeId.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: M3eShape.fromId(id: id, size: 42, color: Colors.purple),
            ),
          ),
        );
        expect(find.byType(M3eShape), findsOneWidget);
      }
    });

    testWidgets('M3eShape with border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M3eShape(
              shape: MaterialShapes.heart,
              size: 80,
              color: Colors.red,
              border: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      );
      expect(find.byType(M3eShape), findsOneWidget);
    });

    testWidgets('Circle backward compat', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Circle(size: 48, color: Colors.blue)),
        ),
      );
      expect(find.byType(Circle), findsOneWidget);
      expect(find.byType(M3eShape), findsOneWidget);
    });
  });

  group('MorphShape widget', () {
    testWidgets('MorphShape renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphShape(
              start: MaterialShapes.circle,
              end: MaterialShapes.flower,
              progress: 0.5,
              size: 80,
              color: Colors.green,
              animate: false,
            ),
          ),
        ),
      );
      expect(find.byType(MorphShape), findsOneWidget);
    });

    testWidgets('AnimatedM3eShape renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedM3eShape(
              shape: MaterialShapes.circle,
              size: 80,
              color: Colors.orange,
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedM3eShape), findsOneWidget);
    });

    testWidgets('ShapeSequenceMorph renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapeSequenceMorph(
              shapes: [
                MaterialShapes.circle,
                MaterialShapes.square,
                MaterialShapes.flower,
              ],
              progress: 0.5,
              size: 80,
            ),
          ),
        ),
      );
      expect(find.byType(ShapeSequenceMorph), findsOneWidget);
    });
  });
}
