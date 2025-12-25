import 'package:flutter/material.dart';

enum ToolType {
  date,
  time,
  person,
  group,
  recordType,
  quantity,
  price,
  unknown,
}

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
  final List<String> hashtags;
  final String? recordType;
  final double? quantity;
  final double? price;

  ToolParseResult({
    required this.tags,
    this.derivedDate,
    this.hashtags = const [],
    this.recordType,
    this.quantity,
    this.price,
  });
}

class ToolParser {
  static ToolParseResult parse(String input) {
    final List<ToolTag> tags = [];
    final List<String> hashtags = [];
    DateTime now = DateTime.now();
    DateTime? datePart;
    TimeOfDay? timePart;
    String? recordType;
    double? quantity;
    double? price;

    // Regex to find all @tokens, #hashtags, !types
    // Note: $price is handled separately with stricter rules
    final tokenRegex = RegExp(r'(@|#|!)([a-zA-Z0-9:\-\.\$]+)');

    // Price regex: $15.00, $15, $1,234.56 ($ followed by digits, periods, commas only)
    final priceRegex = RegExp(
      r'\$(\d{1,3}(,\d{3})*(\.\d{1,2})?|\d+(\.\d{1,2})?)',
    );

    // Separate regex for quantities like 2x, 1.5x, q:2
    final qtyRegex = RegExp(r'\b(\d+(\.\d+)?)(x|qty)\b|\bq:(\d+(\.\d+)?)\b');

    // First, parse standalone $price patterns
    final priceMatches = priceRegex.allMatches(input);
    for (final match in priceMatches) {
      final fullMatch = match.group(0)!;
      final priceValue = match.group(1)!.replaceAll(',', '');

      // Skip if this is part of an @$15.00 pattern (will be handled by tokenRegex)
      final beforeIndex = match.start - 1;
      if (beforeIndex >= 0 && input[beforeIndex] == '@') {
        continue;
      }

      price = double.tryParse(priceValue);
      tags.add(
        ToolTag(
          type: ToolType.price,
          originalText: fullMatch,
          data: priceValue,
          startIndex: match.start,
          endIndex: match.end,
        ),
      );
    }

    final matches = tokenRegex.allMatches(input);

    for (final match in matches) {
      final prefix = match.group(1)!;
      final fullMatch = match.group(0)!;
      final content = match.group(2)!;
      final startIndex = match.start;
      final endIndex = match.end;

      if (prefix == '#') {
        // Hierarchical group tag
        final parts = content.split('.');
        String currentPath = '';
        for (final part in parts) {
          if (currentPath.isEmpty) {
            currentPath = part;
          } else {
            currentPath = '$currentPath.$part';
          }
          if (!hashtags.contains(currentPath)) {
            hashtags.add(currentPath);
          }
        }
        for (final part in parts) {
          if (!hashtags.contains(part)) {
            hashtags.add(part);
          }
        }

        tags.add(
          ToolTag(
            type: ToolType.group,
            originalText: fullMatch,
            data: content,
            startIndex: startIndex,
            endIndex: endIndex,
          ),
        );
        continue;
      }

      if (prefix == '!') {
        recordType = content;
        tags.add(
          ToolTag(
            type: ToolType.recordType,
            originalText: fullMatch,
            data: content,
            startIndex: startIndex,
            endIndex: endIndex,
          ),
        );
        continue;
      }

      // Handle @ tools
      ToolType type = ToolType.unknown;
      ToolType? probableType;
      String data = content;

      // Check for @$15.00 shortcut (price)
      if (content.startsWith('\$')) {
        final priceStr = content.substring(1).replaceAll(',', '');
        final parsedPrice = double.tryParse(priceStr);
        if (parsedPrice != null) {
          price = parsedPrice;
          tags.add(
            ToolTag(
              type: ToolType.price,
              originalText: fullMatch,
              data: priceStr,
              startIndex: startIndex,
              endIndex: endIndex,
            ),
          );
          continue;
        }
      }

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
          if (!hashtags.contains('person')) hashtags.add('person');
          if (!hashtags.contains(toolData)) hashtags.add(toolData);
          handled = true;
        } else if (toolName == 'price') {
          // @price:15.00 or @price:$15.00
          final priceStr = toolData.replaceAll('\$', '').replaceAll(',', '');
          final parsedPrice = double.tryParse(priceStr);
          if (parsedPrice != null) {
            price = parsedPrice;
            tags.add(
              ToolTag(
                type: ToolType.price,
                originalText: fullMatch,
                data: priceStr,
                startIndex: startIndex,
                endIndex: endIndex,
              ),
            );
            continue;
          }
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
          data = content;
          timePart = _parseTimeData(data);
        } else {
          // Check hints
          if (_isValidUsername(content)) {
            type = ToolType.person;
            data = content;
            if (!hashtags.contains('person')) hashtags.add('person');
            if (!hashtags.contains(content)) hashtags.add(content);
          } else {
            type = ToolType.unknown;
            data = content;

            if (content.toLowerCase().contains('day')) {
              probableType = ToolType.date;
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

    // Parse quantities
    final qtyMatches = qtyRegex.allMatches(input);
    for (final match in qtyMatches) {
      final fullMatch = match.group(0)!;
      final val1 = match.group(1); // \d+(\.\d+)?
      final val2 = match.group(4); // q:\d+(\.\d+)?
      final value = val1 ?? val2;

      if (value != null) {
        quantity = double.tryParse(value);
        tags.add(
          ToolTag(
            type: ToolType.quantity,
            originalText: fullMatch,
            data: value,
            startIndex: match.start,
            endIndex: match.end,
          ),
        );
      }
    }

    // Sort tags by start index
    tags.sort((a, b) => a.startIndex.compareTo(b.startIndex));

    // Combine date and time
    DateTime? finalDate;
    if (datePart != null || timePart != null) {
      final d = datePart ?? DateTime(now.year, now.month, now.day);
      final t = timePart ?? const TimeOfDay(hour: 0, minute: 0);
      finalDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    }

    if (recordType != null) {
      return ToolParseResult(
        tags: tags.where((t) => t.type == ToolType.recordType).toList(),
        derivedDate: null,
        hashtags: [],
        recordType: recordType,
        quantity: null,
        price: null,
      );
    }

    return ToolParseResult(
      tags: tags,
      derivedDate: finalDate,
      hashtags: hashtags,
      recordType: recordType,
      quantity: quantity,
      price: price,
    );
  }

  static bool _isDate(String s) {
    final lower = s.toLowerCase();
    return lower == 'tomorrow' ||
        lower == 'today' ||
        lower == 'yesterday' ||
        RegExp(r'^\d+days$').hasMatch(lower) ||
        _getDayOfWeek(lower) != null;
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

  static int? _getDayOfWeek(String s) {
    switch (s) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  static DateTime? _parseDateData(String data, DateTime now) {
    final lower = data.toLowerCase();
    if (lower == 'tomorrow') {
      return now.add(const Duration(days: 1));
    } else if (lower == 'today') {
      return now;
    } else if (lower == 'yesterday') {
      return now.subtract(const Duration(days: 1));
    }

    final daysMatch = RegExp(r'^(\d+)days$').firstMatch(lower);
    if (daysMatch != null) {
      final days = int.parse(daysMatch.group(1)!);
      return now.add(Duration(days: days));
    }

    final dow = _getDayOfWeek(lower);
    if (dow != null) {
      int daysToAdd = dow - now.weekday;
      if (daysToAdd <= 0) daysToAdd += 7;
      return now.add(Duration(days: daysToAdd));
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

  static List<String> getDateSuggestions(String query) {
    final suggestions = [
      'today',
      'tomorrow',
      '2days',
      '3days',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    if (query.isEmpty) return suggestions;
    return suggestions.where((s) => s.startsWith(query.toLowerCase())).toList();
  }

  /// Formats a name for display.
  /// - Extracts the leaf from hierarchical names (e.g., "store.groceries" → "Groceries")
  /// - Splits CamelCase into words (e.g., "HomeDepot" → "Home Depot")
  static String formatDisplayName(String name) {
    if (name.isEmpty) return name;
    final parts = name.split('.');
    final leaf = parts.last;
    if (leaf.isEmpty) return name;

    // Split CamelCase: insert space before each uppercase letter (except first)
    final spaced = leaf.replaceAllMapped(
      RegExp(r'(?<=[a-z])([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    // Capitalize first letter
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
