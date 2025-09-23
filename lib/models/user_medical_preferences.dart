class UserMedicalPreferences {
  final String? id;
  final String userId;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final int? height;
  
  // Alergias e intolerancias
  final List<String> allergies;
  final List<String> medicationAllergies;
  final List<String> foodIntolerances;
  
  // Preferencias de tratamiento
  final String medicinePreference; // 'natural', 'conventional', 'both'
  final List<String> avoidMedications;
  final List<String> preferredTreatments;
  
  // Condiciones médicas
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final List<String> previousSurgeries;
  
  // Estilo de vida
  final String smokingStatus;
  final String alcoholConsumption;
  final String exerciseFrequency;
  final String? dietType;
  
  // Preferencias adicionales
  final String languagePreference;
  final String communicationStyle;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserMedicalPreferences({
    this.id,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.allergies = const [],
    this.medicationAllergies = const [],
    this.foodIntolerances = const [],
    this.medicinePreference = 'both',
    this.avoidMedications = const [],
    this.preferredTreatments = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.previousSurgeries = const [],
    this.smokingStatus = 'never',
    this.alcoholConsumption = 'occasional',
    this.exerciseFrequency = 'moderate',
    this.dietType,
    this.languagePreference = 'es',
    this.communicationStyle = 'balanced',
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory UserMedicalPreferences.fromJson(Map<String, dynamic> json) {
    return UserMedicalPreferences(
      id: json['id'],
      userId: json['user_id'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'],
      weight: json['weight']?.toDouble(),
      height: json['height'],
      allergies: List<String>.from(json['allergies'] ?? []),
      medicationAllergies: List<String>.from(json['medication_allergies'] ?? []),
      foodIntolerances: List<String>.from(json['food_intolerances'] ?? []),
      medicinePreference: json['medicine_preference'] ?? 'both',
      avoidMedications: List<String>.from(json['avoid_medications'] ?? []),
      preferredTreatments: List<String>.from(json['preferred_treatments'] ?? []),
      chronicConditions: List<String>.from(json['chronic_conditions'] ?? []),
      currentMedications: List<String>.from(json['current_medications'] ?? []),
      previousSurgeries: List<String>.from(json['previous_surgeries'] ?? []),
      smokingStatus: json['smoking_status'] ?? 'never',
      alcoholConsumption: json['alcohol_consumption'] ?? 'occasional',
      exerciseFrequency: json['exercise_frequency'] ?? 'moderate',
      dietType: json['diet_type'],
      languagePreference: json['language_preference'] ?? 'es',
      communicationStyle: json['communication_style'] ?? 'balanced',
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'allergies': allergies,
      'medication_allergies': medicationAllergies,
      'food_intolerances': foodIntolerances,
      'medicine_preference': medicinePreference,
      'avoid_medications': avoidMedications,
      'preferred_treatments': preferredTreatments,
      'chronic_conditions': chronicConditions,
      'current_medications': currentMedications,
      'previous_surgeries': previousSurgeries,
      'smoking_status': smokingStatus,
      'alcohol_consumption': alcoholConsumption,
      'exercise_frequency': exerciseFrequency,
      'diet_type': dietType,
      'language_preference': languagePreference,
      'communication_style': communicationStyle,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserMedicalPreferences copyWith({
    String? id,
    String? userId,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    int? height,
    List<String>? allergies,
    List<String>? medicationAllergies,
    List<String>? foodIntolerances,
    String? medicinePreference,
    List<String>? avoidMedications,
    List<String>? preferredTreatments,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    List<String>? previousSurgeries,
    String? smokingStatus,
    String? alcoholConsumption,
    String? exerciseFrequency,
    String? dietType,
    String? languagePreference,
    String? communicationStyle,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserMedicalPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
      medicationAllergies: medicationAllergies ?? this.medicationAllergies,
      foodIntolerances: foodIntolerances ?? this.foodIntolerances,
      medicinePreference: medicinePreference ?? this.medicinePreference,
      avoidMedications: avoidMedications ?? this.avoidMedications,
      preferredTreatments: preferredTreatments ?? this.preferredTreatments,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      previousSurgeries: previousSurgeries ?? this.previousSurgeries,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dietType: dietType ?? this.dietType,
      languagePreference: languagePreference ?? this.languagePreference,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Genera un prompt personalizado basado en las preferencias del usuario
  String generateMedicalContext() {
    List<String> contextParts = [];
    
    // Información básica
    if (dateOfBirth != null) {
      final age = DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
      contextParts.add("Paciente de $age años");
    }
    
    if (gender != null) contextParts.add("género $gender");
    if (weight != null && height != null) {
      final bmi = weight! / ((height! / 100) * (height! / 100));
      contextParts.add("IMC ${bmi.toStringAsFixed(1)}");
    }
    
    // Alergias importantes
    if (allergies.isNotEmpty) {
      contextParts.add("Alergias: ${allergies.join(', ')}");
    }
    if (medicationAllergies.isNotEmpty) {
      contextParts.add("Alergias a medicamentos: ${medicationAllergies.join(', ')}");
    }
    
    // Preferencias de tratamiento
    switch (medicinePreference) {
      case 'natural':
        contextParts.add("Prefiere medicina natural y remedios alternativos");
        break;
      case 'conventional':
        contextParts.add("Prefiere medicina convencional");
        break;
      case 'both':
        contextParts.add("Está abierto tanto a medicina convencional como natural");
        break;
    }
    
    // Condiciones existentes
    if (chronicConditions.isNotEmpty) {
      contextParts.add("Condiciones crónicas: ${chronicConditions.join(', ')}");
    }
    if (currentMedications.isNotEmpty) {
      contextParts.add("Medicamentos actuales: ${currentMedications.join(', ')}");
    }
    
    // Estilo de vida relevante
    if (smokingStatus != 'never') {
      contextParts.add("Fumador: $smokingStatus");
    }
    if (alcoholConsumption != 'never') {
      contextParts.add("Consumo de alcohol: $alcoholConsumption");
    }
    
    if (contextParts.isEmpty) {
      return "Por favor, proporciona consejos médicos generales.";
    }
    
    return "Contexto médico del paciente: ${contextParts.join('. ')}. "
           "Ten en cuenta estas características al proporcionar consejos médicos. "
           "IMPORTANTE: Esta información es solo para fines educativos y no sustituye "
           "el consejo médico profesional.";
  }
}
