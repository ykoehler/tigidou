import 'package:flutter_test/flutter_test.dart';
import 'package:tigidou/utils/date_parser.dart';

void main() {
  group('DateParser', () {
    test('parses @tomorrow', () {
      final result = DateParser.parse('Call dad @tomorrow');
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      expect(result.date?.year, tomorrow.year);
      expect(result.date?.month, tomorrow.month);
      expect(result.date?.day, tomorrow.day);
      expect(result.matchStrings, contains('@tomorrow'));
    });

    test('parses @14:15', () {
      final result = DateParser.parse('Meeting @14:15');
      expect(result.date?.hour, 14);
      expect(result.date?.minute, 15);
      expect(result.matchStrings, contains('@14:15'));
    });

    test('parses @14h', () {
      final result = DateParser.parse('Meeting @14h');
      expect(result.date?.hour, 14);
      expect(result.date?.minute, 0);
      expect(result.matchStrings, contains('@14h'));
    });

    test('parses @time:14h', () {
      final result = DateParser.parse('Meeting @time:14h');
      expect(result.date?.hour, 14);
      expect(result.date?.minute, 0);
      expect(result.matchStrings, contains('@time:14h'));
    });

    test('parses @tomorrow @14h', () {
      final result = DateParser.parse('Meeting @tomorrow @14h');
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      expect(result.date?.year, tomorrow.year);
      expect(result.date?.month, tomorrow.month);
      expect(result.date?.day, tomorrow.day);
      expect(result.date?.hour, 14);
      expect(result.matchStrings, contains('@tomorrow'));
      expect(result.matchStrings, contains('@14h'));
    });

    test('returns null if no date', () {
      final result = DateParser.parse('Just a normal todo');
      expect(result.date, isNull);
      expect(result.matchStrings, isEmpty);
    });
  });
}
