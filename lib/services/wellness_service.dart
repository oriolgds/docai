import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wellness/cycle_data.dart';
import 'notification_service.dart';

class WellnessService {
  static const String _storageKey = 'wellness_data';

  // Singleton pattern
  static final WellnessService _instance = WellnessService._internal();
  factory WellnessService() => _instance;
  WellnessService._internal();

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<WellnessData> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      return WellnessData();
    }
    try {
      return WellnessData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      // Return empty data if parsing fails
      return WellnessData();
    }
  }

  Future<void> saveData(WellnessData data) async {
    // Recalculate stats before saving
    final updatedData = _recalculateStats(data);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(updatedData.toJson()));
    _scheduleNotifications(updatedData);
  }

  WellnessData _recalculateStats(WellnessData data) {
    if (data.periods.length < 2) return data;

    // Sort periods
    final sortedPeriods = List<CyclePeriod>.from(data.periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    int totalDays = 0;
    int cycleCount = 0;

    for (int i = 0; i < sortedPeriods.length - 1; i++) {
      final current = sortedPeriods[i];
      final next = sortedPeriods[i + 1];
      final cycleLength = next.startDate.difference(current.startDate).inDays;

      // Filter out unreasonable cycle lengths (e.g. < 21 days or > 45 days) for calculation
      // if we want to be strict, but for MVP simple average is safer.
      // Let's just average all recorded intervals.
      totalDays += cycleLength;
      cycleCount++;
    }

    if (cycleCount == 0) return data;

    return data.copyWith(
      averageCycleLength: (totalDays / cycleCount).round(),
    );
  }

  Future<void> _scheduleNotifications(WellnessData data) async {
    final notificationService = NotificationService();

    // Cancel specific wellness notification IDs to avoid side effects
    await notificationService.cancel(1); // Period Reminder
    await notificationService.cancel(2); // Fertile Window

    final nextPeriod = predictNextPeriod(data);
    final fertileWindow = predictFertileWindow(data);

    final now = normalizeDate(DateTime.now());

    if (nextPeriod != null && nextPeriod.isAfter(now)) {
      // Notify 1 day before
      await notificationService.scheduleNotification(
        id: 1,
        title: 'Period Reminder',
        body: 'Your period is predicted to start tomorrow.',
        scheduledDate: nextPeriod.subtract(const Duration(days: 1)),
      );
    }

    if (fertileWindow != null && fertileWindow.startDate.isAfter(now)) {
      // Notify on start of fertile window
      await notificationService.scheduleNotification(
        id: 2,
        title: 'Fertile Window',
        body: 'Your fertile window starts today.',
        scheduledDate: fertileWindow.startDate,
      );
    }
  }

  // Calculate next period start date
  DateTime? predictNextPeriod(WellnessData data) {
    if (data.periods.isEmpty) return null;

    // Sort periods by date descending
    final sortedPeriods = List<CyclePeriod>.from(data.periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final lastPeriod = sortedPeriods.first;

    // If last period is recent (started within last few days), next one is in ~28 days
    // Logic: Last start date + average cycle length
    return lastPeriod.startDate.add(Duration(days: data.averageCycleLength));
  }

  // Calculate fertile window (approx 14 days before next period +/- 2 days)
  CyclePeriod? predictFertileWindow(WellnessData data) {
    final nextPeriodStart = predictNextPeriod(data);
    if (nextPeriodStart == null) return null;

    // Ovulation is roughly 14 days before next period
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

    // Window: 4 days before ovulation + 1 day after
    return CyclePeriod(
      startDate: ovulationDate.subtract(const Duration(days: 4)),
      endDate: ovulationDate.add(const Duration(days: 1)),
    );
  }

  // Helper to get formatted string for AI context
  String getWellnessContext(WellnessData data) {
    final nextPeriod = predictNextPeriod(data);
    final fertileWindow = predictFertileWindow(data);

    final buffer = StringBuffer();
    buffer.writeln('Wellness Tracking Data:');

    if (data.periods.isNotEmpty) {
      final lastPeriod = data.periods.last;
      buffer.writeln('- Last period: ${lastPeriod.startDate.toIso8601String().split('T')[0]}');
    }

    if (nextPeriod != null) {
      buffer.writeln('- Predicted next period: ${nextPeriod.toIso8601String().split('T')[0]}');
    }

    if (fertileWindow != null) {
      buffer.writeln('- Predicted fertile window: ${fertileWindow.startDate.toIso8601String().split('T')[0]} to ${fertileWindow.endDate?.toIso8601String().split('T')[0]}');
    }

    if (data.logs.isNotEmpty) {
      // Last 3 logs
      final recentLogs = List<DailyLog>.from(data.logs)
        ..sort((a, b) => b.date.compareTo(a.date));

      buffer.writeln('- Recent symptoms/moods:');
      for (var log in recentLogs.take(3)) {
        buffer.write('  ${log.date.toIso8601String().split('T')[0]}: ');
        if (log.flow != null) buffer.write('Flow: ${log.flow}, ');
        if (log.mood != null) buffer.write('Mood: ${log.mood}, ');
        if (log.symptoms.isNotEmpty) buffer.write('Symptoms: ${log.symptoms.join(", ")}');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}
