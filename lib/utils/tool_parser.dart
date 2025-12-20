import 'package:flutter/material.dart';

enum ToolType { date, time, person, group, unknown }

class ToolTag {
  final ToolType type;
  final ToolType? probableType; // Hint for unknown tags
  final String originalText;
  final String data;
  final int startIndex;
  final int endIndex;

  ToolTag({
    required this.type,
    this.probableType,
    required this.originalText,
    required this.data,
    required this.startIndex,
    required this.endIndex,
  });
}

class ToolParseResult {
  final List<ToolTag> tags;
  final DateTime? derivedDate;
  final String? group;

  ToolParseResult({required this.tags, this.derivedDate, this.group});
}

class ToolParser {
  static ToolParseResult parse(String input) {
    final List<ToolTag> tags = [];
    DateTime now = DateTime.now();
    DateTime? datePart;
    TimeOfDay? timePart;

    // Regex to find all @tokens
    // Matches: @tool:data or @data
    // We need to be careful with spaces.
    // Simple regex: @[a-zA-Z0-9:\-]+ (added hyphen for @in-two-days)
    final tokenRegex = RegExp(r'@([a-zA-Z0-9:\-]+)');

    final matches = tokenRegex.allMatches(input);

    for (final match in matches) {
      final fullMatch = match.group(0)!;
      final content = match.group(1)!;
      final startIndex = match.start;
      final endIndex = match.end;

      ToolType type = ToolType.unknown;
      ToolType? probableType;
      String data = content;

      // Check for explicit tool syntax: tool:data
      final firstColonIndex = content.indexOf(':');
      bool handled = false;
      if (firstColonIndex != -1) {
        final toolName = content.substring(0, firstColonIndex).toLowerCase();
        final toolData = content.substring(firstColonIndex + 1);

        if (toolName == 'date') {
          type = ToolType.date;
          data = toolData;
          datePart = _parseDateData(data, now);
          handled = true;
        } else if (toolName == 'time') {
          type = ToolType.time;
          data = toolData;
          timePart = _parseTimeData(data);
          handled = true;
        } else if (toolName == 'person') {
          type = ToolType.person;
          data = toolData;
          handled = true;
        }
      }

      if (!handled) {
        // Auto-detection
        if (_isDate(content)) {
          type = ToolType.date;
          data = content;
          datePart = _parseDateData(data, now);
        } else if (_isTime(content)) {
          type = ToolType.time;
          data = content; // e.g. 14h
          timePart = _parseTimeData(data);
        } else {
          // Check hints
          if (_isValidUsername(content)) {
            type = ToolType.person;
            data = content;
          } else {
            type = ToolType.unknown;
            data = content;

            // Hints for unknown
            if (content.toLowerCase().contains('day')) {
              probableType = ToolType.date;
            } else if (!_isValidUsername(content)) {
              // If it has hyphens, it's definitely not a person (per user rule)
              // Maybe it's a date?
              // For now, just leave as unknown, maybe probable date if it looks like one?
            }
          }
        }
      }

      tags.add(
        ToolTag(
          type: type,
          probableType: probableType,
          originalText: fullMatch,
          data: data,
          startIndex: startIndex,
          endIndex: endIndex,
        ),
      );
    }

    // Combine date and time
    DateTime? finalDate;
    if (datePart != null || timePart != null) {
      final d = datePart ?? DateTime(now.year, now.month, now.day);
      final t = timePart ?? const TimeOfDay(hour: 0, minute: 0);
      finalDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    }

    return ToolParseResult(tags: tags, derivedDate: finalDate);
  }

  static bool _isDate(String s) {
    final lower = s.toLowerCase();
    return lower == 'tomorrow' || lower == 'today';
  }

  static bool _isTime(String s) {
    // Matches 14h, 14:00
    return RegExp(r'^\d{1,2}h$').hasMatch(s) ||
        RegExp(r'^\d{1,2}:\d{2}$').hasMatch(s);
  }

  static bool _isValidUsername(String s) {
    // User rule: username doesn't have hyphen
    return !s.contains('-');
  }

  static DateTime? _parseDateData(String data, DateTime now) {
    final lower = data.toLowerCase();
    if (lower == 'tomorrow') {
      return now.add(const Duration(days: 1));
    } else if (lower == 'today') {
      return now;
    }

    // YYYY-MM-DD
    final dateMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(data);
    if (dateMatch != null) {
      return DateTime(
        int.parse(dateMatch.group(1)!),
        int.parse(dateMatch.group(2)!),
        int.parse(dateMatch.group(3)!),
      );
    }

    return null;
  }

  static TimeOfDay? _parseTimeData(String data) {
    // 14h
    final hMatch = RegExp(r'^(\d{1,2})h$').firstMatch(data);
    if (hMatch != null) {
      return TimeOfDay(hour: int.parse(hMatch.group(1)!), minute: 0);
    }

    // 14:00
    final colonMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(data);
    if (colonMatch != null) {
      return TimeOfDay(
        hour: int.parse(colonMatch.group(1)!),
        minute: int.parse(colonMatch.group(2)!),
      );
    }
    return null;
  }
}
