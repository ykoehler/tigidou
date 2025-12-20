import 'package:flutter_test/flutter_test.dart';
import 'package:tigidou/utils/tool_parser.dart';

void main() {
  group('ToolParser', () {
    test('parses @tomorrow as date', () {
      final result = ToolParser.parse('Call dad @tomorrow');
      expect(result.tags.length, 1);
      expect(result.tags.first.type, ToolType.date);
      expect(result.tags.first.data, 'tomorrow');

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      expect(result.derivedDate?.day, tomorrow.day);
    });

    test('parses @14h as time', () {
      final result = ToolParser.parse('Meeting @14h');
      expect(result.tags.length, 1);
      expect(result.tags.first.type, ToolType.time);
      expect(result.tags.first.data, '14h');
      expect(result.derivedDate?.hour, 14);
      expect(result.derivedDate?.minute, 0);
    });

    test('parses @father as person', () {
      final result = ToolParser.parse('Call @father');
      expect(result.tags.length, 1);
      expect(result.tags.first.type, ToolType.person);
      expect(result.tags.first.data, 'father');
    });

    test('parses explicit @date:tomorrow', () {
      final result = ToolParser.parse('Call @date:tomorrow');
      expect(result.tags.first.type, ToolType.date);
      expect(result.derivedDate, isNotNull);
    });

    test('parses explicit @time:14:30', () {
      final result = ToolParser.parse('Call @time:14:30');
      expect(result.tags.first.type, ToolType.time);
      expect(result.derivedDate?.hour, 14);
      expect(result.derivedDate?.minute, 30);
    });

    test('parses explicit @person:mom', () {
      final result = ToolParser.parse('Call @person:mom');
      expect(result.tags.first.type, ToolType.person);
      expect(result.tags.first.data, 'mom');
    });

    test('parses @in-two-days as unknown with date hint', () {
      final result = ToolParser.parse('Call @in-two-days');
      expect(result.tags.length, 1);
      expect(result.tags.first.type, ToolType.unknown);
      expect(result.tags.first.probableType, ToolType.date);
      expect(result.tags.first.data, 'in-two-days');
    });

    test('parses @invalid-user as unknown without hint', () {
      final result = ToolParser.parse('Call @invalid-user');
      expect(result.tags.length, 1);
      expect(result.tags.first.type, ToolType.unknown);
      // No specific hint for generic hyphenated words unless they contain "day"
      expect(result.tags.first.probableType, isNull);
    });

    test('parses multiple tags', () {
      final result = ToolParser.parse('Call @father @tomorrow @10h');
      expect(result.tags.length, 3);

      // Order depends on regex finding
      expect(result.tags[0].data, 'father');
      expect(result.tags[0].type, ToolType.person);

      expect(result.tags[1].data, 'tomorrow');
      expect(result.tags[1].type, ToolType.date);

      expect(result.tags[2].data, '10h');
      expect(result.tags[2].type, ToolType.time);

      expect(result.derivedDate?.hour, 10);
      expect(
        result.derivedDate?.day,
        DateTime.now().add(const Duration(days: 1)).day,
      );
    });
  });
}
