import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';

void main() {
  group('M3eLoadingIndicatorDefaults', () {
    test('indeterminate polygons has 7', () {
      expect(M3eLoadingIndicatorDefaults.indeterminatePolygons.length, 7);
      expect(
        M3eLoadingIndicatorDefaults.indeterminatePolygons,
        contains(MaterialShapes.softBurst),
      );
    });

    test('determinate polygons has 2', () {
      expect(M3eLoadingIndicatorDefaults.determinatePolygons.length, 2);
    });

    test('sizes', () {
      expect(M3eLoadingIndicatorDefaults.indicatorSize, 38.0);
      expect(M3eLoadingIndicatorDefaults.containerSize, 48.0);
    });

    test('containerShape is StadiumBorder', () {
      expect(M3eLoadingIndicatorDefaults.containerShape, isA<StadiumBorder>());
    });
  });

  group('MorphPainter', () {
    test('determinate helper maps 0..1 to 0..n-1', () {
      expect(determinateMorphProgress(0.0, 2), 0.0);
      expect(determinateMorphProgress(1.0, 2), 1.0);
      expect(determinateMorphProgress(0.5, 7), 3.0);
      expect(determinateMorphProgress(2.0, 2), 1.0); // clamped
      expect(determinateMorphProgress(-1.0, 2), 0.0);
    });

    test('paints without error for indeterminate polygons', () {
      final painter = MorphPainter(
        polygons: M3eLoadingIndicatorDefaults.indeterminatePolygons,
        morphProgress: 2.5,
        rotation: 0.5,
        color: Colors.purple,
      );
      // Should produce a path via shouldRepaint
      expect(painter.shouldRepaint(painter), isFalse);
      final other = MorphPainter(
        polygons: M3eLoadingIndicatorDefaults.indeterminatePolygons,
        morphProgress: 3.0,
        rotation: 0.5,
        color: Colors.purple,
      );
      expect(painter.shouldRepaint(other), isTrue);
    });
  });

  group('M3eLoadingIndicator widget', () {
    testWidgets('indeterminate renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M3eLoadingIndicator())),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('determinate renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M3eLoadingIndicator(progress: 0.5)),
        ),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('custom color and size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M3eLoadingIndicator(
              color: Colors.red,
              size: 48,
              progress: 0.3,
            ),
          ),
        ),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('custom polygons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M3eLoadingIndicator(
              polygons: [MaterialShapes.circle, MaterialShapes.square],
              progress: 0.5,
            ),
          ),
        ),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('M3eShapes.LoadingIndicator shorthand indeterminate', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: M3eShapes.LoadingIndicator())),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('M3eShapes.LoadingIndicator shorthand determinate', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M3eShapes.LoadingIndicator(progress: 0.6)),
        ),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('lowerCamel alias', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M3eShapes.loadingIndicator(progress: 0.2)),
        ),
      );
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });
  });

  group('M3eContainedLoadingIndicator widget', () {
    testWidgets('indeterminate renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M3eContainedLoadingIndicator())),
      );
      expect(find.byType(M3eContainedLoadingIndicator), findsOneWidget);
      expect(find.byType(M3eLoadingIndicator), findsOneWidget);
    });

    testWidgets('determinate renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M3eContainedLoadingIndicator(progress: 0.75)),
        ),
      );
      expect(find.byType(M3eContainedLoadingIndicator), findsOneWidget);
    });

    testWidgets('custom container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M3eContainedLoadingIndicator(
              containerColor: Colors.grey.shade300,
              indicatorColor: Colors.purple,
              containerShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              containerSize: 56,
              indicatorSize: 42,
              progress: 0.4,
            ),
          ),
        ),
      );
      expect(find.byType(M3eContainedLoadingIndicator), findsOneWidget);
    });

    testWidgets('M3eShapes.ContainedLoadingIndicator shorthand', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M3eShapes.ContainedLoadingIndicator()),
        ),
      );
      expect(find.byType(M3eContainedLoadingIndicator), findsOneWidget);
    });

    testWidgets('lowerCamel contained alias', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M3eShapes.containedLoadingIndicator(progress: 0.1),
          ),
        ),
      );
      expect(find.byType(M3eContainedLoadingIndicator), findsOneWidget);
    });
  });
}
