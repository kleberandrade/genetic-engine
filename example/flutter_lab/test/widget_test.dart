import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/main.dart';
import 'package:genetic_engine_lab/plots.dart';

void main() {
  testWidgets('step, pause, resume, cancel and restart preserve lifecycle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EvolutionLab());
    expect(find.text('0 / 300'), findsOneWidget);
    final chart = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is HistoryPainter,
    );
    expect(tester.getSize(chart).width, greaterThan(300));
    await tester.tap(find.text('Step'));
    await tester.pump();
    expect(find.text('1 / 300'), findsOneWidget);
    await tester.tap(find.text('Run'));
    await tester.pump(const Duration(milliseconds: 210));
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    final before = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList(),
      before,
    );
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Cancelled'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.text('0 / 300'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('mobile layout and accessible targets at large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const LabPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.ensureVisible(find.text('Step'));
    await tester.tap(find.text('Step'));
    await tester.pump();
    expect(find.text('1 / 300'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('invalid seed reports error without replacing the run', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EvolutionLab());
    await tester.enterText(find.byType(TextField), '-1');
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.text('Enter an integer from 0 to 2147483647.'), findsOneWidget);
    expect(find.text('0 / 300'), findsOneWidget);
  });
}
