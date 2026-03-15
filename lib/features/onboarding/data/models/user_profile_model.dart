/// Enumeración de los géneros biológicos disponibles en el onboarding
enum Gender { male, female }

/// Enumeración de los niveles de actividad física del usuario
enum ActivityLevel {
  /// Poco o nada de ejercicio, trabajo de escritorio
  sedentary,

  /// Ejercicio light 1-3 veces por semana
  light,

  /// Ejercicio moderate 3-5 veces por semana
  moderate,

  /// Ejercicio intense 6-7 veces por semana
  intense,

  /// Atleta o trabajo físico muy exigente
  athlete,
}

/// Enumeración del goal nutricional principal del usuario
enum NutritionGoal {
  /// Reducir el porcentaje de grasa corporal mediante déficit calórico
  loseFat,

  /// Aumentar masa muscular mediante superávit calórico
  gainMuscle,
}

/// Modelo de datos que representa el perfil físico básico del usuario.
/// Contiene los 6 campos requeridos para calcular el TDEE y los macros.
class UserProfileModel {
  /// Género biológico seleccionado por el usuario
  final Gender? gender;

  /// Edad en años completos (rango válido: 13–120)
  final int? age;

  /// Peso corporal en kilogramos (mínimo: 20 kg, acepta decimales)
  final double? weightKg;

  /// Altura en centímetros (rango válido: 100–250 cm)
  final int? heightCm;

  /// Nivel de actividad física seleccionado
  final ActivityLevel? activityLevel;

  /// Objetivo nutricional principal del usuario
  final NutritionGoal? goal;

  /// Constructor con todos los campos opcionales para representar el estado parcial del formulario
  const UserProfileModel({
    this.gender,
    this.age,
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.goal,
  });

  /// Retorna verdadero solo cuando los 6 campos tienen un valor válido asignado.
  /// Este getter es la fuente de verdad para habilitar el botón "Continuar".
  bool get isComplete =>
      gender != null &&
      age != null &&
      weightKg != null &&
      heightCm != null &&
      activityLevel != null &&
      goal != null;

  /// Crea una copia del modelo reemplazando solo los campos que se pasen como argumento.
  /// Permite actualizar campos individuales sin mutar el objeto original.
  UserProfileModel copyWith({
    Gender? gender,
    int? age,
    double? weightKg,
    int? heightCm,
    ActivityLevel? activityLevel,
    NutritionGoal? goal,
  }) {
    return UserProfileModel(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  /// Serializa el perfil al esquema persistido en Supabase.
  Map<String, dynamic> toDatabaseRow({required String userId}) {
    return {
      'id': userId,
      'gender': gender?.name,
      'age': age,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel?.name,
      'goal': goal?.name,
      'onboarding_completed': isComplete,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
