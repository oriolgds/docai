import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docai/l10n/app_localizations.dart';

class MedicalPreferencesScreen extends StatefulWidget {
  const MedicalPreferencesScreen({super.key});

  @override
  State<MedicalPreferencesScreen> createState() => _MedicalPreferencesScreenState();
}

class _MedicalPreferencesScreenState extends State<MedicalPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _dietaryController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _ageController.text = prefs.getString('pref_age') ?? '';
        _selectedGender = prefs.getString('pref_gender');
        _weightController.text = prefs.getString('pref_weight') ?? '';
        _heightController.text = prefs.getString('pref_height') ?? '';
        _allergiesController.text = prefs.getString('pref_allergies') ?? '';
        _conditionsController.text = prefs.getString('pref_conditions') ?? '';
        _medicationsController.text = prefs.getString('pref_medications') ?? '';
        _selectedActivityLevel = prefs.getString('pref_activity_level');
        _dietaryController.text = prefs.getString('pref_dietary') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_age', _ageController.text.trim());
      if (_selectedGender != null) {
        await prefs.setString('pref_gender', _selectedGender!);
      } else {
        await prefs.remove('pref_gender');
      }
      await prefs.setString('pref_weight', _weightController.text.trim());
      await prefs.setString('pref_height', _heightController.text.trim());
      await prefs.setString('pref_allergies', _allergiesController.text.trim());
      await prefs.setString('pref_conditions', _conditionsController.text.trim());
      await prefs.setString('pref_medications', _medicationsController.text.trim());
      if (_selectedActivityLevel != null) {
        await prefs.setString('pref_activity_level', _selectedActivityLevel!);
      } else {
        await prefs.remove('pref_activity_level');
      }
      await prefs.setString('pref_dietary', _dietaryController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.preferencesSaved),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.medicalPreferencesTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.medicalPreferencesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
            tooltip: localizations.saveLabel,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.medicalPreferencesSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Info Section
              _buildSectionHeader(context, localizations.sectionBasicInfo),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: localizations.labelAge,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: localizations.labelGender,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: [
                        DropdownMenuItem(value: 'male', child: Text(localizations.genderMale)),
                        DropdownMenuItem(value: 'female', child: Text(localizations.genderFemale)),
                        DropdownMenuItem(value: 'other', child: Text(localizations.genderOther)),
                      ],
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: localizations.labelWeight,
                        suffixText: 'kg',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: localizations.labelHeight,
                        suffixText: 'cm',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.height),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Medical Details Section
              _buildSectionHeader(context, localizations.sectionMedicalHistory),
              const SizedBox(height: 16),

              TextFormField(
                controller: _allergiesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: localizations.labelAllergies,
                  hintText: localizations.hintAllergies,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.warning_amber),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _conditionsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: localizations.labelConditions,
                  hintText: localizations.hintConditions,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.healing),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _medicationsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: localizations.labelMedications,
                  hintText: localizations.hintMedications,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 24),

              // Lifestyle Section
              _buildSectionHeader(context, localizations.sectionLifestyle),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: InputDecoration(
                  labelText: localizations.labelActivityLevel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.directions_run),
                ),
                items: [
                  DropdownMenuItem(value: 'sedentary', child: Text(localizations.activitySedentary)),
                  DropdownMenuItem(value: 'light', child: Text(localizations.activityLight)),
                  DropdownMenuItem(value: 'moderate', child: Text(localizations.activityModerate)),
                  DropdownMenuItem(value: 'active', child: Text(localizations.activityActive)),
                  DropdownMenuItem(value: 'very_active', child: Text(localizations.activityVeryActive)),
                ],
                onChanged: (value) => setState(() => _selectedActivityLevel = value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dietaryController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: localizations.labelDietary,
                  hintText: localizations.hintDietary,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.restaurant),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _savePreferences,
                  icon: const Icon(Icons.save),
                  label: Text(localizations.saveLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
