import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/language_buttons.dart';
import 'package:genetic_engine_lab/lab_copy.dart';

void main() {
  testWidgets(
    'circular flags have accessible names, selected state, touch targets and keyboard focus',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        var language = LabLanguage.english;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, update) => LanguageButtons(
                  language: language,
                  onChanged: (value) => update(() => language = value),
                ),
              ),
            ),
          ),
        );
        final brazil = find.byKey(const ValueKey('language-pt'));
        final uk = find.byKey(const ValueKey('language-en'));
        expect(
          find.descendant(
            of: brazil,
            matching: find.byWidgetPredicate(
              (w) => w is Tooltip && w.message == 'Português (Brasil)',
            ),
          ),
          findsOneWidget,
        );
        expect(tester.getSize(brazil), const Size(48, 48));
        expect(tester.getSize(uk), const Size(48, 48));
        expect(
          tester.getSemantics(uk).flagsCollection.isSelected.toBoolOrNull(),
          isTrue,
        );
        expect(
          tester.getSemantics(brazil).flagsCollection.isSelected.toBoolOrNull(),
          isFalse,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(language, LabLanguage.portuguese);
        expect(
          tester.getSemantics(brazil).flagsCollection.isSelected.toBoolOrNull(),
          isTrue,
        );
        await tester.tap(uk);
        await tester.pump();
        expect(language, LabLanguage.english);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      } finally {
        semantics.dispose();
      }
    },
  );
}
