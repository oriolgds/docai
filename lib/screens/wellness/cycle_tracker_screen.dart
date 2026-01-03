import 'package:flutter/material.dart';
import 'package:docai/models/wellness/cycle_data.dart';
import 'package:docai/services/wellness_service.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:docai/services/app_haptics.dart';

class CycleTrackerScreen extends StatefulWidget {
  final WellnessData data;
  final VoidCallback onDataChanged;

  const CycleTrackerScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  DateTime _selectedDate = DateTime.now();

  // Form State
  String? _selectedFlow;
  List<String> _selectedSymptoms = [];
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = WellnessService().normalizeDate(DateTime.now());
    _loadLogForDate(_selectedDate);
  }

  void _loadLogForDate(DateTime date) {
    // Check if log exists
    final log = widget.data.logs.firstWhere(
      (l) => isSameDay(l.date, date),
      orElse: () => DailyLog(date: date),
    );

    setState(() {
      _selectedFlow = log.flow;
      _selectedSymptoms = List.from(log.symptoms);
      _selectedMood = log.mood;
      _notesController.text = log.notes ?? '';
      _temperatureController.text = log.temperature?.toString() ?? '';
      _weightController.text = log.weight?.toString() ?? '';
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _saveLog() async {
    final newLog = DailyLog(
      date: _selectedDate,
      flow: _selectedFlow,
      symptoms: _selectedSymptoms,
      mood: _selectedMood,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      temperature: double.tryParse(_temperatureController.text),
      weight: double.tryParse(_weightController.text),
    );

    // Update logs
    final updatedLogs = List<DailyLog>.from(widget.data.logs);
    updatedLogs.removeWhere((l) => isSameDay(l.date, _selectedDate));
    updatedLogs.add(newLog);

    // Update Period data if Flow is present
    List<CyclePeriod> updatedPeriods = List.from(widget.data.periods);

    // Simple logic: if flow is present, ensure we have a period covering this date
    // This is a simplified logic. A real tracker has complex rules for merging periods.
    if (_selectedFlow != null) {
      // Check if this date is adjacent to an existing period
      // ... For simplicity, we just save the log.
      // Advanced period detection would run here to update 'periods' list.
    }

    final newData = widget.data.copyWith(
      logs: updatedLogs,
      periods: updatedPeriods,
    );

    await WellnessService().saveData(newData);
    widget.onDataChanged();

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.wellnessLogSaved ?? 'Log Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 24),
          _buildLogForm(localizations),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    // Simple week view for now, or use a package if allowed.
    // Since I can't add packages easily, I'll build a simple horizontal date picker.
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30, // Last 30 days
        reverse: true, // Show today first? No, let's show range.
        itemBuilder: (context, index) {
          // Index 0 is Today? Let's make it centered around today.
          // Let's just show last 15 days and next 15 days?
          // Simplest: Last 30 days
          final rawDate = DateTime.now().subtract(Duration(days: index));
          final date = WellnessService().normalizeDate(rawDate);
          final isSelected = isSameDay(date, _selectedDate);
          final hasLog = widget.data.logs.any((l) => isSameDay(l.date, date));

          return GestureDetector(
            onTap: () {
              AppHaptics.selectionClick(context);
              setState(() {
                _selectedDate = date;
                _loadLogForDate(date);
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasLog ? Colors.pink : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogForm(AppLocalizations? loc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMMd().format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),

            // Flow
            Text(loc?.wellnessFlow ?? 'Flow', style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: ['Light', 'Medium', 'Heavy', 'Spotting'].map((flow) {
                final isSelected = _selectedFlow == flow;
                return ChoiceChip(
                  label: Text(flow),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFlow = selected ? flow : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Mood
            Text(loc?.wellnessMood ?? 'Mood', style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: ['Happy', 'Sad', 'Irritable', 'Anxious', 'Tired'].map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? mood : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

             // Symptoms
            Text(loc?.wellnessSymptoms ?? 'Symptoms', style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: ['Cramps', 'Headache', 'Acne', 'Bloating', 'Fatigue'].map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Period Toggle Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _togglePeriodStart(_selectedDate);
                    },
                    child: Text(loc?.wellnessPeriodStart ?? 'Period Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _togglePeriodEnd(_selectedDate);
                    },
                    child: Text(loc?.wellnessPeriodEnd ?? 'Period End'),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(loc?.saveLabel ?? 'Save Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePeriodStart(DateTime date) async {
    // Logic to start a new period
    final newPeriod = CyclePeriod(startDate: date);
    final updatedPeriods = List<CyclePeriod>.from(widget.data.periods)..add(newPeriod);
    final newData = widget.data.copyWith(periods: updatedPeriods);
    await WellnessService().saveData(newData);
    widget.onDataChanged();
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Period Started')));
    }
  }

  void _togglePeriodEnd(DateTime date) async {
    // Logic to end the latest open period
    // Find the MOST RECENT period without end date to avoid closing stale ones
    try {
      final openPeriodIndex = widget.data.periods.lastIndexWhere((p) => p.endDate == null);
      if (openPeriodIndex != -1) {
        final openPeriod = widget.data.periods[openPeriodIndex];

        // Ensure this open period is somewhat recent (e.g., started within last 60 days)
        // to avoid closing a very old forgotten period.
        if (date.difference(openPeriod.startDate).inDays > 60) {
           // Maybe prompt user? For now just treat as error or ignore.
           // Better to just start a new one if it's that old?
           // Let's close it anyway but user might want to edit history.
        }

        if (date.isBefore(openPeriod.startDate)) {
           if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date cannot be before start date')));
           return;
        }
        final updatedPeriod = CyclePeriod(startDate: openPeriod.startDate, endDate: date);
        final updatedPeriods = List<CyclePeriod>.from(widget.data.periods);
        updatedPeriods[openPeriodIndex] = updatedPeriod;

        final newData = widget.data.copyWith(periods: updatedPeriods);
        await WellnessService().saveData(newData);
        widget.onDataChanged();
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Period Ended')));
      } else {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active period found')));
      }
    } catch(e) {
      // ignore
    }
  }
}
