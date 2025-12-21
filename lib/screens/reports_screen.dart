import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:docai/services/firestore_service.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.reportsTitle)),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${localizations.errorLoadingReports}: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null || data.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noReportsFound,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              final report = doc.data() as Map<String, dynamic>;
              final status = report['status'] as String? ?? 'pending';
              final timestamp = (report['reportedAt'] as Timestamp?)?.toDate();
              final reasonKey = report['reason'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(context, status),
                          if (timestamp != null)
                            Text(
                              timeago.format(timestamp, locale: locale),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: localizations.reportReasonLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: _getLocalizedReason(
                                localizations,
                                reasonKey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black26
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Tooltip(
                          message: report['messageContent'] ?? '',
                          child: Text(
                            report['messageContent'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getLocalizedReason(AppLocalizations localizations, String? reason) {
    if (reason == null) return '';

    switch (reason.toLowerCase()) {
      case 'inappropriate':
        return localizations.reportReasonInappropriate;
      case 'incorrect':
        return localizations.reportReasonIncorrect;
      case 'harmful':
        return localizations.reportReasonHarmful;
      case 'other':
        return localizations.reportReasonOther;
      default:
        // Try to map English strings if stored as text
        if (reason == 'Inappropriate content') {
          return localizations.reportReasonInappropriate;
        }
        if (reason == 'Incorrect information') {
          return localizations.reportReasonIncorrect;
        }
        if (reason == 'Harmful or dangerous') {
          return localizations.reportReasonHarmful;
        }
        if (reason == 'Other') return localizations.reportReasonOther;

        return reason;
    }
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final localizations = AppLocalizations.of(context)!;
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'solved':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = localizations.reportStatusSolved;
        break;
      case 'refused':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = localizations.reportStatusRefused;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.access_time;
        label = localizations.reportStatusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
