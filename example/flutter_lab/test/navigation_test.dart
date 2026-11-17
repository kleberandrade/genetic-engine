import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/main.dart';
import 'package:genetic_engine_lab/learning_content.dart';
import 'package:genetic_engine_lab/lab_copy.dart';

void main() {
  testWidgets('learning navigation preserves the experiment and language', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EvolutionLab());
    await tester.tap(find.text('Step'));
    await tester.pump();
    expect(find.text('1 / 300'), findsOneWidget);
    await tester.tap(find.text('Run'));
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(find.text('Pause'));
    await tester.pump();
    final generation = tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data)
        .whereType<String>()
        .singleWhere((value) => RegExp(r'^\d+ / 300$').hasMatch(value));
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    expect(find.text('Selection is not survival'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('language-pt')));
    await tester.pumpAndSettle();
    expect(find.text('Seleção não é sobrevivência'), findsOneWidget);
    await tester.tap(find.text('Laboratório'));
    await tester.pumpAndSettle();
    expect(find.text(generation), findsOneWidget);
    expect(find.text('Pausado'), findsOneWidget);
    expect(find.text('Retomar'), findsOneWidget);
  });
  testWidgets('every executable preset opens a configured generation zero', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EvolutionLab());
    for (var i = 0; i < labPresets.length; i++) {
      await tester.tap(find.text('Examples'));
      await tester.pumpAndSettle();
      final load = find.text('Load in laboratory').at(i);
      await tester.ensureVisible(load);
      await tester.tap(load);
      await tester.pumpAndSettle();
      final config = labPresets[i].config;
      expect(find.text('0 / 300'), findsOneWidget);
      expect(find.text(config.problem.label), findsOneWidget);
      expect(find.text('${config.population} individuals'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '${config.seed}',
      );
      expect(
        find.text('Preset loaded: ${labPresets[i].title.en}'),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'mobile menu supports keyboard selection and accessible targets',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(const EvolutionLab());
        await tester.tap(find.byKey(const Key('navigation-menu')));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Understand the search'), findsOneWidget);
        const formula = 'mean = sum(fitness[i], i = 0..N-1) / N';
        await tester.ensureVisible(find.text(formula));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel(formula), findsOneWidget);
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await tester.tap(find.byKey(const ValueKey('language-pt')));
        await tester.pumpAndSettle();
        expect(find.text('Entenda a busca'), findsOneWidget);
        await tester.tap(find.byKey(const Key('navigation-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Exemplos'));
        await tester.pumpAndSettle();
        final load = find.text('Carregar no laboratório').first;
        await tester.ensureVisible(load);
        await tester.tap(load);
        await tester.pumpAndSettle();
        expect(find.text('0 / 300'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'documentation and GitHub controls use real repository resources',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final opened = <LabResource>[];
      await tester.pumpWidget(EvolutionLab(onOpenResource: opened.add));
      await tester.tap(find.text('Documentation'));
      await tester.tap(find.text('GitHub'));
      expect(opened, [LabResource.gettingStarted, LabResource.github]);
      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      const copy = LabCopy(LabLanguage.english);
      for (final resource in LabResource.values) {
        final link = find.text(resource.label.inLanguage(copy));
        await tester.ensureVisible(link);
        await tester.tap(link);
        await tester.pump();
        expect(opened.last, resource);
        expect(Uri.parse(resource.url).host, 'github.com');
      }
      expect(learningExercises.length, 5);
    },
  );
}
