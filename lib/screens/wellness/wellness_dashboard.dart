import 'package:flutter/material.dart';
import 'package:docai/models/wellness/cycle_data.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/services/wellness_service.dart';
import 'package:docai/widgets/cycle_history_chart.dart';
import 'package:intl/intl.dart';

class WellnessDashboard extends StatelessWidget {
  final WellnessData data;
  final VoidCallback onDataChanged;

  const WellnessDashboard({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final nextPeriod = WellnessService().predictNextPeriod(data);
    final fertileWindow = WellnessService().predictFertileWindow(data);

    // Calculate days until next period
    int? daysUntil;
    if (nextPeriod != null) {
      daysUntil = nextPeriod.difference(DateTime.now()).inDays;
      if (daysUntil < 0) daysUntil = 0; // Or handle overdue
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, daysUntil, nextPeriod),
          const SizedBox(height: 16),
          if (fertileWindow != null)
             _buildFertileWindowCard(context, fertileWindow),
          const SizedBox(height: 24),
          CycleHistoryChart(data: data),
          const SizedBox(height: 16),
          _buildRecentLogs(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int? daysUntil, DateTime? nextPeriod) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [Colors.pink[900]!, Colors.purple[900]!]
            : [Colors.pink[100]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            localizations?.wellnessNextPeriod ?? 'Next Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          if (daysUntil != null) ...[
            Text(
              '$daysUntil',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.pink[800],
              ),
            ),
            Text(
              localizations?.wellnessDays ?? 'Days',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.pink[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(nextPeriod!),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ] else ...[
            Text(
              '--',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.pink[800],
              ),
            ),
            Text(
              localizations?.wellnessPrediction ?? 'Not enough data',
               style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFertileWindowCard(BuildContext context, CyclePeriod window) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.teal[400]),
              const SizedBox(width: 8),
              Text(
                localizations?.wellnessFertileWindow ?? 'Fertile Window',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${DateFormat.MMMd().format(window.startDate)} - ${window.endDate != null ? DateFormat.MMMd().format(window.endDate!) : "?"}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'High chance of conception',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogs(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final logs = List<DailyLog>.from(data.logs)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentLogs = logs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Recent Logs', // Needs localization
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (recentLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No logs yet',
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          ...recentLogs.map((log) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getFlowColor(log.flow),
                radius: 6,
              ),
              title: Text(DateFormat.yMMMd().format(log.date)),
              subtitle: Text(
                [
                  if (log.flow != null) log.flow,
                  if (log.mood != null) log.mood,
                  if (log.symptoms.isNotEmpty) log.symptoms.join(', '),
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
      ],
    );
  }

  Color _getFlowColor(String? flow) {
    if (flow == null) return Colors.grey;
    switch (flow.toLowerCase()) {
      case 'heavy': return Colors.red[900]!;
      case 'medium': return Colors.red;
      case 'light': return Colors.red[200]!;
      case 'spotting': return Colors.brown[200]!;
      default: return Colors.grey;
    }
  }
}
