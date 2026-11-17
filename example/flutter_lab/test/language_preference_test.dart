import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/main.dart';
import 'package:genetic_engine_lab/lab_copy.dart';
import 'package:genetic_engine_lab/language_preference.dart';

void main() {
  testWidgets('first visit follows the browser Portuguese regional locale', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('pt', 'BR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const EvolutionLab());
    await tester.pumpAndSettle();
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('Cenário'), findsOneWidget);
    expect(find.text('0 / 300'), findsOneWidget);
  });
  test('saved supported choice wins over browser languages', () {
    final preference = LanguagePreference(read: () => 'en');
    expect(preference.initialLanguage(['pt-BR', 'en-US']), LabLanguage.english);
    expect(
      LanguagePreference(read: () => 'pt').initialLanguage(['en-GB']),
      LabLanguage.portuguese,
    );
  });

  test(
    'absent or invalid preferences follow ordered supported browser languages',
    () {
      for (final stored in [null, '', 'fr', 'PT', 'corrupt']) {
        final preference = LanguagePreference(read: () => stored);
        expect(
          preference.initialLanguage(['fr-FR', 'pt-PT', 'en-US']),
          LabLanguage.portuguese,
        );
        expect(
          preference.initialLanguage(['en-AU', 'pt-BR']),
          LabLanguage.english,
        );
        expect(preference.initialLanguage(['fr-FR']), LabLanguage.english);
        expect(preference.initialLanguage([]), LabLanguage.english);
      }
    },
  );

  test('unavailable browser storage does not prevent locale detection or switching', () {
    final preference = LanguagePreference(
      read: () => throw StateError('Storage denied'),
      write: (_) => throw StateError('Quota exceeded'),
    );
    expect(preference.initialLanguage(['pt-BR']), LabLanguage.portuguese);
    expect(() => preference.remember(LabLanguage.english), returnsNormally);
  });

  testWidgets(
    'explicit choices survive app recreation and override browser locale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      String? stored;
      LanguagePreference preference() => LanguagePreference(
        read: () => stored,
        write: (value) => stored = value,
      );
      await tester.pumpWidget(EvolutionLab(languagePreference: preference()));
      await tester.pumpAndSettle();
      expect(
        stored,
        isNull,
      ); // Detection does not create an explicit preference.
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português').last);
      await tester.pumpAndSettle();
      expect(stored, 'pt');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(EvolutionLab(languagePreference: preference()));
      await tester.pumpAndSettle();
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('Cenário'), findsOneWidget);
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(stored, 'en');
      await tester.pumpWidget(const SizedBox.shrink());
      tester.platformDispatcher.localesTestValue = [const Locale('pt', 'BR')];
      await tester.pumpWidget(EvolutionLab(languagePreference: preference()));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Scenario'), findsOneWidget);
    },
  );

  testWidgets('storage failures keep the selected language usable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      EvolutionLab(
        languagePreference: LanguagePreference(
          read: () => throw StateError('Denied'),
          write: (_) => throw StateError('Denied'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Português').last);
    await tester.pumpAndSettle();
    expect(find.text('Cenário'), findsOneWidget);
    await tester.tap(find.text('Avançar'));
    await tester.pump();
    expect(find.text('1 / 300'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
