import 'dart:convert';

class CyclePeriod {
  final DateTime startDate;
  final DateTime? endDate;

  CyclePeriod({required this.startDate, this.endDate});

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory CyclePeriod.fromJson(Map<String, dynamic> json) {
    return CyclePeriod(
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class DailyLog {
  final DateTime date;
  final String? flow; // 'low', 'medium', 'high', 'spotting'
  final List<String> symptoms;
  final String? mood;
  final String? notes;
  final double? temperature; // Basal body temperature
  final double? weight;

  DailyLog({
    required this.date,
    this.flow,
    this.symptoms = const [],
    this.mood,
    this.notes,
    this.temperature,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'flow': flow,
    'symptoms': symptoms,
    'mood': mood,
    'notes': notes,
    'temperature': temperature,
    'weight': weight,
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date']),
      flow: json['flow'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood'],
      notes: json['notes'],
      temperature: json['temperature'],
      weight: json['weight'],
    );
  }

  DailyLog copyWith({
    DateTime? date,
    String? flow,
    List<String>? symptoms,
    String? mood,
    String? notes,
    double? temperature,
    double? weight,
  }) {
    return DailyLog(
      date: date ?? this.date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
    );
  }
}

class WellnessData {
  final List<CyclePeriod> periods;
  final List<DailyLog> logs;
  final int averageCycleLength; // in days

  WellnessData({
    this.periods = const [],
    this.logs = const [],
    this.averageCycleLength = 28,
  });

  Map<String, dynamic> toJson() => {
    'periods': periods.map((e) => e.toJson()).toList(),
    'logs': logs.map((e) => e.toJson()).toList(),
    'averageCycleLength': averageCycleLength,
  };

  factory WellnessData.fromJson(Map<String, dynamic> json) {
    return WellnessData(
      periods: (json['periods'] as List?)
          ?.map((e) => CyclePeriod.fromJson(e))
          .toList() ?? [],
      logs: (json['logs'] as List?)
          ?.map((e) => DailyLog.fromJson(e))
          .toList() ?? [],
      averageCycleLength: json['averageCycleLength'] ?? 28,
    );
  }

  WellnessData copyWith({
    List<CyclePeriod>? periods,
    List<DailyLog>? logs,
    int? averageCycleLength,
  }) {
    return WellnessData(
      periods: periods ?? this.periods,
      logs: logs ?? this.logs,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
    );
  }
}
