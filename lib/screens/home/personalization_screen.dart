import 'package:flutter/material.dart';
import '../../models/user_preferences.dart';
import '../../services/supabase_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  final _allergiesController = TextEditingController();
  final _chronicConditionsController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Form values
  MedicinePreference _medicinePreference = MedicinePreference.both;
  AgeRange? _ageRange;
  Gender? _gender;

  UserPreferences? _currentPreferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    _currentMedicationsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await SupabaseService.getUserPreferences();
      if (preferences != null && mounted) {
        setState(() {
          _currentPreferences = preferences;
          _allergiesController.text = preferences.allergies.join(', ');
          _chronicConditionsController.text = preferences.chronicConditions.join(', ');
          _currentMedicationsController.text = preferences.currentMedications.join(', ');
          _additionalNotesController.text = preferences.additionalNotes ?? '';
          _medicinePreference = preferences.medicinePreference;
          _ageRange = preferences.ageRange;
          _gender = preferences.gender;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar preferencias: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<String> _parseCommaSeparated(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('Usuario no encontrado');

      final preferences = UserPreferences(
        id: _currentPreferences?.id,
        userId: user.id,
        allergies: _parseCommaSeparated(_allergiesController.text),
        medicinePreference: _medicinePreference,
        chronicConditions: _parseCommaSeparated(_chronicConditionsController.text),
        currentMedications: _parseCommaSeparated(_currentMedicationsController.text),
        ageRange: _ageRange,
        gender: _gender,
        additionalNotes: _additionalNotesController.text.trim().isEmpty 
            ? null 
            : _additionalNotesController.text.trim(),
        isFirstTime: false,
      );

      await SupabaseService.upsertUserPreferences(preferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate preferences were saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalización'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferences,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.black),
                        const SizedBox(width: 8),
                        const Text(
                          'Personaliza tu experiencia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ayúdanos a ofrecerte recomendaciones más precisas y personalizadas.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información básica
              _buildSectionTitle('Información básica', Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Rango de edad',
                value: _ageRange,
                items: AgeRange.values,
                displayName: (age) => age.displayName,
                onChanged: (value) => setState(() => _ageRange = value),
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Género',
                value: _gender,
                items: Gender.values,
                displayName: (gender) => gender.displayName,
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 24),

              // Preferencias médicas
              _buildSectionTitle('Preferencias médicas', Icons.local_hospital_outlined),
              const SizedBox(height: 16),
              
              // Medicine preference card with consistent styling
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de medicina preferida',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...MedicinePreference.values.map((preference) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => setState(() => _medicinePreference = preference),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Radio<MedicinePreference>(
                                  value: preference,
                                  groupValue: _medicinePreference,
                                  onChanged: (value) => setState(() => _medicinePreference = value!),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    preference.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información médica
              _buildSectionTitle('Información médica', Icons.medical_information_outlined),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _allergiesController,
                label: 'Alergias',
                hint: 'Ej: penicilina, frutos secos, polen (separadas por comas)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _chronicConditionsController,
                label: 'Condiciones crónicas',
                hint: 'Ej: diabetes, hipertensión, asma (separadas por comas)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _currentMedicationsController,
                label: 'Medicamentos actuales',
                hint: 'Ej: aspirina, omeprazol (separados por comas)',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Notas adicionales
              _buildSectionTitle('Notas adicionales', Icons.note_outlined),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _additionalNotesController,
                label: 'Información adicional',
                hint: 'Cualquier otra información relevante para tu atención médica...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta información nos ayuda a personalizar las respuestas, pero no reemplaza una consulta médica profesional.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayName,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(displayName(item)),
      )).toList(),
      onChanged: onChanged,
    );
  }
}