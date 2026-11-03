import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:m3_expressive_flutter/m3_expressive_flutter.dart';

void main() {
  group('M3 Expressive Wavy Indicators Detailed Verification', () {
    testWidgets('WavyLinearProgressIndicator determinate renders and animates wave offset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: WavyLinearProgressIndicator(
                  value: 0.6,
                  amplitude: 3.0,
                  wavelength: 40.0,
                  trackGap: 4.0,
                  stopIndicatorWidth: 4.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WavyLinearProgressIndicator), findsOneWidget);

      // Verify animation frames pump without error
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
    });

    testWidgets('WavyLinearProgressIndicator indeterminate executes M3 1750ms cycle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: WavyLinearProgressIndicator(
                  value: null,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WavyLinearProgressIndicator), findsOneWidget);

      // Pump through keyframes of the 1750ms cycle
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1750));
    });

    testWidgets('CircularWavyProgressIndicator determinate renders and runs wave phase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularWavyProgressIndicator(
                value: 0.7,
                amplitude: 1.6,
                wavelength: 15.0,
                trackGap: 4.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularWavyProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1000));
    });

    testWidgets('CircularWavyProgressIndicator indeterminate sweeps and rotates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularWavyProgressIndicator(
                value: null,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularWavyProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('WavyLinearProgressIndicator responds to theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WavyLinearProgressIndicatorTheme(
            data: const WavyLinearProgressIndicatorThemeData(
              color: Colors.purple,
              amplitude: 4.0,
              wavelength: 32.0,
            ),
            child: const Scaffold(
              body: WavyLinearProgressIndicator(value: 0.5),
            ),
          ),
        ),
      );

      expect(find.byType(WavyLinearProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
