import 'package:flutter/material.dart';
import '../models/user_medical_preferences.dart';
import '../services/medical_preferences_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multi_select_field.dart';

class MedicalPreferencesScreen extends StatefulWidget {
  const MedicalPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<MedicalPreferencesScreen> createState() => _MedicalPreferencesScreenState();
}

class _MedicalPreferencesScreenState extends State<MedicalPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicalService = MedicalPreferencesService();
  
  bool _isLoading = false;
  UserMedicalPreferences? _currentPreferences;
  
  // Controllers para campos de texto
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _dietTypeController;
  
  // Variables para campos complejos
  DateTime? _dateOfBirth;
  String _gender = '';
  String _medicinePreference = 'both';
  String _smokingStatus = 'never';
  String _alcoholConsumption = 'occasional';
  String _exerciseFrequency = 'moderate';
  String _communicationStyle = 'balanced';
  String _languagePreference = 'es';
  
  // Listas para multi-select
  List<String> _allergies = [];
  List<String> _medicationAllergies = [];
  List<String> _foodIntolerances = [];
  List<String> _avoidMedications = [];
  List<String> _preferredTreatments = [];
  List<String> _chronicConditions = [];
  List<String> _currentMedications = [];
  List<String> _previousSurgeries = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadMedicalPreferences();
  }

  void _initializeControllers() {
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _dietTypeController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _dietTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalPreferences() async {
    setState(() => _isLoading = true);
    
    try {
      final preferences = await _medicalService.getUserMedicalPreferences();
      if (preferences != null) {
        setState(() {
          _currentPreferences = preferences;
          _populateFields(preferences);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar preferencias: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(UserMedicalPreferences preferences) {
    _dateOfBirth = preferences.dateOfBirth;
    _gender = preferences.gender ?? '';
    _weightController.text = preferences.weight?.toString() ?? '';
    _heightController.text = preferences.height?.toString() ?? '';
    _medicinePreference = preferences.medicinePreference;
    _smokingStatus = preferences.smokingStatus;
    _alcoholConsumption = preferences.alcoholConsumption;
    _exerciseFrequency = preferences.exerciseFrequency;
    _communicationStyle = preferences.communicationStyle;
    _languagePreference = preferences.languagePreference;
    _emergencyNameController.text = preferences.emergencyContactName ?? '';
    _emergencyPhoneController.text = preferences.emergencyContactPhone ?? '';
    _dietTypeController.text = preferences.dietType ?? '';
    
    // Listas
    _allergies = List.from(preferences.allergies);
    _medicationAllergies = List.from(preferences.medicationAllergies);
    _foodIntolerances = List.from(preferences.foodIntolerances);
    _avoidMedications = List.from(preferences.avoidMedications);
    _preferredTreatments = List.from(preferences.preferredTreatments);
    _chronicConditions = List.from(preferences.chronicConditions);
    _currentMedications = List.from(preferences.currentMedications);
    _previousSurgeries = List.from(preferences.previousSurgeries);
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final preferences = UserMedicalPreferences(
        id: _currentPreferences?.id,
        userId: '', // Será asignado por el servicio
        dateOfBirth: _dateOfBirth,
        gender: _gender.isEmpty ? null : _gender,
        weight: _weightController.text.isEmpty ? null : double.tryParse(_weightController.text),
        height: _heightController.text.isEmpty ? null : int.tryParse(_heightController.text),
        allergies: _allergies,
        medicationAllergies: _medicationAllergies,
        foodIntolerances: _foodIntolerances,
        medicinePreference: _medicinePreference,
        avoidMedications: _avoidMedications,
        preferredTreatments: _preferredTreatments,
        chronicConditions: _chronicConditions,
        currentMedications: _currentMedications,
        previousSurgeries: _previousSurgeries,
        smokingStatus: _smokingStatus,
        alcoholConsumption: _alcoholConsumption,
        exerciseFrequency: _exerciseFrequency,
        dietType: _dietTypeController.text.isEmpty ? null : _dietTypeController.text,
        languagePreference: _languagePreference,
        communicationStyle: _communicationStyle,
        emergencyContactName: _emergencyNameController.text.isEmpty ? null : _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text.isEmpty ? null : _emergencyPhoneController.text,
      );

      await _medicalService.saveMedicalPreferences(preferences);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas exitosamente')),
      );
      
      Navigator.of(context).pop(true); // Retornar true para indicar que se guardaron cambios
    } catch (e) {
      _showErrorSnackBar('Error al guardar preferencias: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850], // Cambio de Colors.black a un gris más suave
      appBar: AppBar(
        backgroundColor: Colors.grey[850], // Mantener consistencia con el fondo
        foregroundColor: Colors.white,
        title: const Text('Personalización Médica'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePreferences,
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDisclaimerCard(),
                    const SizedBox(height: 20),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 20),
                    _buildAllergiesSection(),
                    const SizedBox(height: 20),
                    _buildTreatmentPreferencesSection(),
                    const SizedBox(height: 20),
                    _buildMedicalConditionsSection(),
                    const SizedBox(height: 20),
                    _buildLifestyleSection(),
                    const SizedBox(height: 20),
                    _buildEmergencyContactSection(),
                    const SizedBox(height: 20),
                    _buildPreferencesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      color: Colors.grey[800], // Cambio de Colors.grey[900] a Colors.grey[800] para mejor contraste
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.warning_amber, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Aviso Importante',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'DocAI no sustituye el consejo médico profesional. La información proporcionada tiene fines educativos. Para diagnósticos, tratamientos o emergencias acude a un profesional de la salud.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      'Información Básica',
      Icons.person,
      [
        _buildDateField(
          'Fecha de Nacimiento',
          _dateOfBirth,
          (date) => setState(() => _dateOfBirth = date),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Género',
          _gender,
          ['', 'Masculino', 'Femenino', 'No binario', 'Prefiero no decir'],
          (value) => setState(() => _gender = value ?? ''),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _weightController,
                labelText: 'Peso (kg)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _heightController,
                labelText: 'Altura (cm)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSection(
      'Alergias e Intolerancias',
      Icons.warning,
      [
        MultiSelectField(
          title: 'Alergias Generales',
          items: _allergies,
          onChanged: (items) => setState(() => _allergies = items),
          suggestions: ['Polen', 'Polvo', 'Ácaros', 'Pelo de animales', 'Látex'],
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Alergias a Medicamentos',
          items: _medicationAllergies,
          onChanged: (items) => setState(() => _medicationAllergies = items),
          suggestions: ['Penicilina', 'Aspirina', 'Ibuprofeno', 'Sulfa', 'Morfina'],
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Intolerancias Alimentarias',
          items: _foodIntolerances,
          onChanged: (items) => setState(() => _foodIntolerances = items),
          suggestions: ['Lactosa', 'Gluten', 'Frutos secos', 'Mariscos', 'Huevos'],
        ),
      ],
    );
  }

  Widget _buildTreatmentPreferencesSection() {
    return _buildSection(
      'Preferencias de Tratamiento',
      Icons.healing,
      [
        _buildDropdownField(
          'Tipo de Medicina Preferida',
          _medicinePreference,
          [
            {'value': 'natural', 'label': 'Medicina Natural'},
            {'value': 'conventional', 'label': 'Medicina Convencional'},
            {'value': 'both', 'label': 'Ambas'},
          ],
          (value) => setState(() => _medicinePreference = value!),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Medicamentos a Evitar',
          items: _avoidMedications,
          onChanged: (items) => setState(() => _avoidMedications = items),
          suggestions: ['Opiáceos', 'Esteroides', 'Antibióticos', 'Benzodiacepinas'],
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Tratamientos Preferidos',
          items: _preferredTreatments,
          onChanged: (items) => setState(() => _preferredTreatments = items),
          suggestions: ['Fisioterapia', 'Acupuntura', 'Homeopatía', 'Yoga', 'Meditación'],
        ),
      ],
    );
  }

  Widget _buildMedicalConditionsSection() {
    return _buildSection(
      'Historial Médico',
      Icons.medical_services,
      [
        MultiSelectField(
          title: 'Condiciones Crónicas',
          items: _chronicConditions,
          onChanged: (items) => setState(() => _chronicConditions = items),
          suggestions: ['Diabetes', 'Hipertensión', 'Asma', 'Artritis', 'Migraña'],
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Medicamentos Actuales',
          items: _currentMedications,
          onChanged: (items) => setState(() => _currentMedications = items),
          suggestions: ['Metformina', 'Lisinopril', 'Omeprazol', 'Simvastatina'],
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Cirugías Previas',
          items: _previousSurgeries,
          onChanged: (items) => setState(() => _previousSurgeries = items),
          suggestions: ['Apendicectomía', 'Colecistectomía', 'Cesárea', 'Artroscopia'],
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSection(
      'Estilo de Vida',
      Icons.fitness_center,
      [
        _buildDropdownField(
          'Hábito de Fumar',
          _smokingStatus,
          [
            {'value': 'never', 'label': 'Nunca'},
            {'value': 'former', 'label': 'Ex-fumador'},
            {'value': 'current_light', 'label': 'Fumador ligero'},
            {'value': 'current_moderate', 'label': 'Fumador moderado'},
            {'value': 'current_heavy', 'label': 'Fumador intenso'},
          ],
          (value) => setState(() => _smokingStatus = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Consumo de Alcohol',
          _alcoholConsumption,
          [
            {'value': 'never', 'label': 'Nunca'},
            {'value': 'occasional', 'label': 'Ocasional'},
            {'value': 'moderate', 'label': 'Moderado'},
            {'value': 'frequent', 'label': 'Frecuente'},
            {'value': 'daily', 'label': 'Diario'},
          ],
          (value) => setState(() => _alcoholConsumption = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Frecuencia de Ejercicio',
          _exerciseFrequency,
          [
            {'value': 'none', 'label': 'Ninguno'},
            {'value': 'light', 'label': 'Ligero'},
            {'value': 'moderate', 'label': 'Moderado'},
            {'value': 'intense', 'label': 'Intenso'},
            {'value': 'daily', 'label': 'Diario'},
          ],
          (value) => setState(() => _exerciseFrequency = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Tipo de Dieta',
          _dietTypeController.text,
          [
            {'value': '', 'label': 'No especificado'},
            {'value': 'omnivore', 'label': 'Omnívora'},
            {'value': 'vegetarian', 'label': 'Vegetariana'},
            {'value': 'vegan', 'label': 'Vegana'},
            {'value': 'pescatarian', 'label': 'Pescatariana'},
            {'value': 'keto', 'label': 'Cetogénica'},
            {'value': 'mediterranean', 'label': 'Mediterránea'},
            {'value': 'other', 'label': 'Otro'},
          ],
          (value) => _dietTypeController.text = value ?? '',
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return _buildSection(
      'Contacto de Emergencia',
      Icons.emergency,
      [
        CustomTextField(
          controller: _emergencyNameController,
          labelText: 'Nombre del Contacto',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emergencyPhoneController,
          labelText: 'Teléfono de Emergencia',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      'Preferencias Adicionales',
      Icons.settings,
      [
        _buildDropdownField(
          'Idioma Preferido',
          _languagePreference,
          [
            {'value': 'es', 'label': 'Español'},
            {'value': 'en', 'label': 'Inglés'},
            {'value': 'ca', 'label': 'Catalán'},
            {'value': 'fr', 'label': 'Francés'},
            {'value': 'de', 'label': 'Alemán'},
          ],
          (value) => setState(() => _languagePreference = value!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Estilo de Comunicación',
          _communicationStyle,
          [
            {'value': 'direct', 'label': 'Directo'},
            {'value': 'detailed', 'label': 'Detallado'},
            {'value': 'balanced', 'label': 'Balanceado'},
            {'value': 'gentle', 'label': 'Suave'},
          ],
          (value) => setState(() => _communicationStyle = value!),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      color: Colors.grey[800], // Cambio de Colors.grey[900] a Colors.grey[800] para mejor contraste
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, Function(DateTime?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark( // Mejora del tema para mejor visibilidad
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: Colors.grey[800]!,
                  onSurface: Colors.white,
                  background: Colors.grey[850]!,
                  onBackground: Colors.white,
                ),
                dialogBackgroundColor: Colors.grey[800],
              ),
              child: child!,
            );
          },
        );
        if (date != null) onChanged(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[800], // Añadir color de fondo para consistencia
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? '${value.day}/${value.month}/${value.year}'
                  : label,
              style: TextStyle(
                color: value != null ? Colors.white : Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, dynamic options, Function(String?) onChanged) {
    // Manejar diferentes formatos de opciones
    List<DropdownMenuItem<String>> items;
    
    if (options is List<String>) {
      items = options.map<DropdownMenuItem<String>>((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option.isEmpty ? label : option, 
            style: const TextStyle(color: Colors.white), // Asegurar texto blanco
          ),
        );
      }).toList();
    } else if (options is List<Map<String, String>>) {
      items = options.map<DropdownMenuItem<String>>((Map<String, String> option) {
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Text(
            option['label']!, 
            style: const TextStyle(color: Colors.white), // Asegurar texto blanco
          ),
        );
      }).toList();
    } else {
      items = [];
    }

    return Theme(
      data: Theme.of(context).copyWith(
        // Forzar el tema oscuro para el dropdown
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800], // Fondo gris oscuro
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Texto blanco
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[800], // Fondo gris oscuro del contenedor
        ),
        child: DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            filled: true,
            fillColor: Colors.grey[800], // Fondo gris oscuro del campo
          ),
          dropdownColor: Colors.grey[700], // Color del menú desplegable
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white), // Texto blanco para el valor seleccionado
          iconEnabledColor: Colors.white, // Icono blanco
          iconDisabledColor: Colors.grey,
        ),
      ),
    );
  }
}