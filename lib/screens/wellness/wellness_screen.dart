import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/screens/wellness/wellness_dashboard.dart';
import 'package:docai/screens/wellness/cycle_tracker_screen.dart';
import 'package:docai/screens/wellness/education_screen.dart';
import 'package:docai/services/wellness_service.dart';
import 'package:docai/models/wellness/cycle_data.dart';
import 'package:docai/services/app_haptics.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WellnessData _data = WellnessData();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await WellnessService().loadData();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  void _refreshData() {
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.wellnessTitle ?? 'Wellness'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => AppHaptics.selectionClick(context),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: localizations?.wellnessStats ?? 'Dashboard'),
            Tab(text: localizations?.wellnessTracker ?? 'Tracker'),
            Tab(text: localizations?.wellnessEducation ?? 'Education'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                WellnessDashboard(data: _data, onDataChanged: _refreshData),
                CycleTrackerScreen(data: _data, onDataChanged: _refreshData),
                const EducationScreen(),
              ],
            ),
    );
  }
}
