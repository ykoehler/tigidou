class ParsedDateResult {
  final DateTime? date;
  final List<String> matchStrings;

  ParsedDateResult({this.date, this.matchStrings = const []});
}

class DateParser {
  static ParsedDateResult parse(String input) {
    DateTime now = DateTime.now();
    DateTime? resultDate;
    List<String> matches = [];

    // Regex for @tomorrow
    final tomorrowRegex = RegExp(r'@tomorrow', caseSensitive: false);
    if (tomorrowRegex.hasMatch(input)) {
      now = now.add(const Duration(days: 1));
      resultDate = DateTime(now.year, now.month, now.day);
      matches.add(tomorrowRegex.stringMatch(input)!);
    } else {
      // If not tomorrow, maybe today (default) or specific date?
      // User only mentioned @tomorrow. Let's assume today if not specified.
      resultDate = DateTime(now.year, now.month, now.day);
    }

    // Regex for time: @14:15, @14h, @time:14h
    // Patterns:
    // 1. @(\d{1,2}):(\d{2})  -> 14:15
    // 2. @(\d{1,2})h         -> 14h
    // 3. @time:(\d{1,2})h    -> time:14h

    // We need to be careful not to double match.
    // Let's look for time patterns.

    int? hour;
    int? minute;

    final timeRegex1 = RegExp(r'@(\d{1,2}):(\d{2})');
    final timeRegex2 = RegExp(r'@(\d{1,2})h');
    final timeRegex3 = RegExp(r'@time:(\d{1,2})h');

    final match1 = timeRegex1.firstMatch(input);
    final match2 = timeRegex2.firstMatch(input);
    final match3 = timeRegex3.firstMatch(input);

    if (match1 != null) {
      hour = int.parse(match1.group(1)!);
      minute = int.parse(match1.group(2)!);
      matches.add(match1.group(0)!);
    } else if (match2 != null) {
      hour = int.parse(match2.group(1)!);
      minute = 0;
      matches.add(match2.group(0)!);
    } else if (match3 != null) {
      hour = int.parse(match3.group(1)!);
      minute = 0;
      matches.add(match3.group(0)!);
    }

    if (hour != null) {
      resultDate = DateTime(
        resultDate.year,
        resultDate.month,
        resultDate.day,
        hour,
        minute ?? 0,
      );
    } else if (matches.isEmpty) {
      // No date or time found
      return ParsedDateResult(date: null, matchStrings: []);
    }

    // If we only matched @tomorrow but no time, default to maybe 9am?
    // Or just keep it as midnight?
    // For notifications, midnight is bad.
    // If user says "Call dad @tomorrow", usually implies during the day.
    // But for now, let's leave it as is (midnight) or if only time is matched, it's today at that time.

    // If the time has passed today, should we move to tomorrow?
    // "Call dad @9h" (and it's 10h).
    // User didn't specify logic, but usually todo apps default to next occurrence.
    // However, for simplicity, I'll stick to strict parsing.

    return ParsedDateResult(date: resultDate, matchStrings: matches);
  }
}
