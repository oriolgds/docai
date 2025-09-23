class UserPreferences {
  final String? id;
  final String userId;
  final List<String> allergies;
  final MedicinePreference medicinePreference;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final AgeRange? ageRange;
  final Gender? gender;
  final String? additionalNotes;
  final bool isFirstTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    required this.userId,
    this.allergies = const [],
    this.medicinePreference = MedicinePreference.both,
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.ageRange,
    this.gender,
    this.additionalNotes,
    this.isFirstTime = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      medicinePreference: MedicinePreference.fromString(json['medicine_preference'] ?? 'both'),
      chronicConditions: (json['chronic_conditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      currentMedications: (json['current_medications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ageRange: json['age_range'] != null ? AgeRange.fromString(json['age_range']) : null,
      gender: json['gender'] != null ? Gender.fromString(json['gender']) : null,
      additionalNotes: json['additional_notes'],
      isFirstTime: json['is_first_time'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'allergies': allergies,
      'medicine_preference': medicinePreference.value,
      'chronic_conditions': chronicConditions,
      'current_medications': currentMedications,
      'age_range': ageRange?.value,
      'gender': gender?.value,
      'additional_notes': additionalNotes,
      'is_first_time': isFirstTime,
      'updated_at': 'now()',
    };
  }

  UserPreferences copyWith({
    String? id,
    String? userId,
    List<String>? allergies,
    MedicinePreference? medicinePreference,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    AgeRange? ageRange,
    Gender? gender,
    String? additionalNotes,
    bool? isFirstTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      allergies: allergies ?? this.allergies,
      medicinePreference: medicinePreference ?? this.medicinePreference,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum MedicinePreference {
  natural('natural', 'Medicina Natural'),
  conventional('conventional', 'Medicina Convencional'),
  both('both', 'Ambas');

  const MedicinePreference(this.value, this.displayName);
  final String value;
  final String displayName;

  static MedicinePreference fromString(String value) {
    return MedicinePreference.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MedicinePreference.both,
    );
  }
}

enum AgeRange {
  child('0-17', 'Menor de 18 años'),
  youngAdult('18-35', '18-35 años'),
  middleAge('36-55', '36-55 años'),
  senior('56-75', '56-75 años'),
  elderly('75+', 'Más de 75 años');

  const AgeRange(this.value, this.displayName);
  final String value;
  final String displayName;

  static AgeRange fromString(String value) {
    return AgeRange.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AgeRange.middleAge,
    );
  }
}

enum Gender {
  male('male', 'Masculino'),
  female('female', 'Femenino'),
  other('other', 'Otro'),
  preferNotToSay('prefer_not_to_say', 'Prefiero no decirlo');

  const Gender(this.value, this.displayName);
  final String value;
  final String displayName;

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gender.preferNotToSay,
    );
  }
}