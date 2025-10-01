import 'package:flutter_test/flutter_test.dart';

import 'package:civexam_pro/utils/rank_display_helper.dart';

void main() {
  group('formatRankLabel', () {
    test('returns 1er for first rank', () {
      expect(formatRankLabel(1), equals('1er'));
    });

    test('returns e suffix for second and third ranks', () {
      expect(formatRankLabel(2), equals('2e'));
      expect(formatRankLabel(3), equals('3e'));
    });

    test('returns e suffix for ranks above three', () {
      expect(formatRankLabel(4), equals('4e'));
      expect(formatRankLabel(10), equals('10e'));
    });

    test('returns rank as string for non-positive values', () {
      expect(formatRankLabel(0), equals('0'));
      expect(formatRankLabel(-5), equals('-5'));
    });
  });
}
