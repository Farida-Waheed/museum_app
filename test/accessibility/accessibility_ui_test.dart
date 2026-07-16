import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';


Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  group('AccessibilityNeedCard (multi-select atom)', () {
    testWidgets('renders localized label + description and fires onTap',
        (tester) async {
      var taps = 0;
      const t = AccessibilityL10n(false);
      final pres = AccessibilityCategoryPresentation.resolve(
        AccessibilityCategory.wheelchairUser,
        t,
      );

      await tester.pumpWidget(_wrap(
        AccessibilityNeedCard(
          presentation: pres,
          selected: false,
          onTap: () => taps++,
        ),
      ));

      expect(find.text(pres.label), findsOneWidget);
      expect(find.text(pres.description), findsOneWidget);

      await tester.tap(find.byType(AccessibilityNeedCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('exposes selected state to semantics as a checked button',
        (tester) async {
      final handle = tester.ensureSemantics();
      const t = AccessibilityL10n(false);
      final pres = AccessibilityCategoryPresentation.resolve(
        AccessibilityCategory.visualImpairment,
        t,
      );

      await tester.pumpWidget(_wrap(
        AccessibilityNeedCard(
          presentation: pres,
          selected: true,
          onTap: () {},
        ),
      ));

      // Version-stable assertion via the semantics matcher rather than the
      // deprecated SemanticsFlag/hasFlag API.
      expect(
        tester.getSemantics(
          find
              .descendant(
                of: find.byType(AccessibilityNeedCard),
                matching: find.byType(Semantics),
              )
              .first,
        ),
        matchesSemantics(
          isButton: true,
          hasCheckedState: true,
          isChecked: true,
          label: pres.label,
          hint: pres.description,
        ),
      );
      handle.dispose();
    });
  });

  group('AccessibilityL10n bilingual', () {
    test('switches strings by language', () {
      const en = AccessibilityL10n(false);
      const ar = AccessibilityL10n(true);
      expect(en.welcomeTitle, 'Welcome to Horus');
      expect(ar.welcomeTitle, isNot('Welcome to Horus'));
      expect(ar.welcomeTitle.contains('حورس'), isTrue);
    });

    test('greeting includes the visitor name when provided', () {
      const en = AccessibilityL10n(false);
      expect(en.greeting('Sarah'), contains('Sarah'));
      expect(en.greeting('  '), isNot(contains('  ,')));
    });

    test('value labels resolve for every enum value', () {
      const t = AccessibilityL10n(false);
      for (final p in TourPace.values) {
        expect(t.paceLabel(p), isNotEmpty);
      }
      for (final e in ExplanationLevel.values) {
        expect(t.explanationLabel(e), isNotEmpty);
      }
      for (final r in SpeechRate.values) {
        expect(t.speechRateLabel(r), isNotEmpty);
      }
    });
  });

  group('AccessibilityCategoryPresentation', () {
    test('resolves an icon + non-empty copy for every category', () {
      const t = AccessibilityL10n(false);
      for (final c in AccessibilityCategory.values) {
        final p = AccessibilityCategoryPresentation.resolve(c, t);
        expect(p.label, isNotEmpty);
        expect(p.description, isNotEmpty);
      }
    });

    test('selectable list offers the four real needs plus standard', () {
      expect(AccessibilityCategoryPresentation.selectable, hasLength(5));
      expect(
        AccessibilityCategoryPresentation.selectable,
        contains(AccessibilityCategory.standard),
      );
    });
  });
}
