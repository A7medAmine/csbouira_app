import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/core/text_search.dart';

void main() {
  group('normalizeForSearch', () {
    test('lowercases and strips French accents', () {
      expect(normalizeForSearch('Résumé Électronique'), 'resume electronique');
    });

    test('turns punctuation into single spaces', () {
      expect(normalizeForSearch('TD_01 - Analyse.pdf'), 'td 01 analyse pdf');
    });

    test('unifies Arabic letter variants and removes diacritics', () {
      expect(normalizeForSearch('أَلْخَوَارِزْمِيَّة'), normalizeForSearch('الخوارزمية'));
      expect(normalizeForSearch('إمتحان'), 'امتحان');
      expect(normalizeForSearch('مادة'), 'ماده');
    });
  });

  group('boundedEditDistance', () {
    test('computes small distances', () {
      expect(boundedEditDistance('kitten', 'sitten', 2), 1);
      expect(boundedEditDistance('algo', 'algo', 1), 0);
    });

    test('gives up above the bound', () {
      expect(boundedEditDistance('abc', 'xyz', 1), greaterThan(1));
      expect(boundedEditDistance('a', 'abcdef', 2), greaterThan(2));
    });
  });

  group('matchScore', () {
    int score(String q, String text) =>
        matchScore(normalizeForSearch(q), normalizeForSearch(text));

    test('matches regardless of accents and case', () {
      expect(score('resume', 'Résumé chapitre 1.pdf'), greaterThan(0));
      expect(score('ANALYSE', 'analyse 2'), greaterThan(0));
    });

    test('requires every query word to match', () {
      expect(score('analyse exam', 'Analyse 1 Exam 2022.pdf'), greaterThan(0));
      expect(score('analyse physique', 'Analyse 1 Exam 2022.pdf'), 0);
    });

    test('tolerates a typo in longer words', () {
      expect(score('algoritme', 'Algorithme et structures'), greaterThan(0));
      expect(score('corige', 'Corrigé TD 3'), greaterThan(0));
    });

    test('does not fuzz very short words', () {
      expect(score('tp', 'td 01'), 0);
    });

    test('ranks exact words above prefixes and typos', () {
      final exact = score('exam', 'exam 2021');
      final prefix = score('exam', 'examen 2021');
      final typo = score('exan', 'examen 2021');
      expect(exact, greaterThan(prefix));
      expect(prefix, greaterThan(typo));
    });

    test('empty query matches nothing', () {
      expect(score('', 'anything'), 0);
    });
  });
}
