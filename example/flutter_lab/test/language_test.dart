import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/main.dart';

void main() {
  testWidgets(
    'language switch translates a paused experiment without resetting it',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const EvolutionLab());
      await tester.tap(find.text('Run'));
      await tester.pump(const Duration(milliseconds: 140));
      await tester.tap(find.text('Pause'));
      await tester.pump();
      final generation = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .singleWhere((text) => RegExp(r'^\d+ / 300$').hasMatch(text));
      await tester.tap(find.byKey(const ValueKey('language-pt')));
      await tester.pumpAndSettle();
      expect(find.text('Pausado'), findsOneWidget);
      expect(find.text('Retomar'), findsOneWidget);
      expect(find.text('Cenário'), findsOneWidget);
      expect(
        find.text('Ative os 32 genes. A aptidão conta os bits que faltam.'),
        findsOneWidget,
      );
      expect(find.text(generation), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(generation), findsOneWidget);
      final context = tester.element(find.text('Retomar'));
      expect(Localizations.localeOf(context).languageCode, 'pt');
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(find.text('Cancelado'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('language-en')));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text(generation), findsOneWidget);
    },
  );
  testWidgets(
    'Portuguese scenarios and validation messages switch back to English',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const EvolutionLab());
      await tester.tap(find.byKey(const ValueKey('language-pt')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OneMax'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oito rainhas').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Posicione oito rainhas sem conflitos nas diagonais.'),
        findsOneWidget,
      );
      expect(find.text('Melhor indivíduo · Oito rainhas'), findsOneWidget);
      await tester.tap(find.text('Oito rainhas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Caixeiro viajante').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Visite oito cidades e retorne ao ponto de partida.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'A rota retorna à primeira cidade. As distâncias usam coordenadas normalizadas.',
        ),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), '-1');
      await tester.tap(find.text('Reiniciar'));
      await tester.pumpAndSettle();
      expect(find.text('Digite um inteiro de 0 a 2147483647.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('language-en')));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter an integer from 0 to 2147483647.'),
        findsOneWidget,
      );
      expect(find.text('Travelling salesman'), findsOneWidget);
      expect(find.text('0 / 300'), findsOneWidget);
    },
  );

  testWidgets('Portuguese remains accessible at 390px and 150 percent text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const EvolutionLab());
      await tester.tap(find.byKey(const ValueKey('language-pt')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await tester.ensureVisible(find.text('Avançar'));
      await tester.tap(find.text('Avançar'));
      await tester.pump();
      expect(find.text('1 / 300'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
