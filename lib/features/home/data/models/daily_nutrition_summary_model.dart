/// Modelo que representa el resumen nutricional diario devuelto por la función RPC de Supabase.
/// Contiene las calorías y macros (meta vs consumido) para un día específico.
class DailyNutritionSummaryModel {
  /// Meta diaria de calorías del usuario (null si no está configurada)
  final int? metaCalories;

  /// Calorías consumidas durante el día
  final int consumedCalories;

  /// Calorías restantes del día (null si la meta no está configurada)
  final int? remainingCalories;

  /// Resumen de macronutrientes (proteína, carbs, grasas)
  final MacroSummary macros;

  const DailyNutritionSummaryModel({
    required this.metaCalories,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.macros,
  });

  /// Construye el modelo desde el JSON devuelto por Supabase
  factory DailyNutritionSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parseamos el objeto de macros anidado
    final macrosJson = json['macros'] as Map<String, dynamic>? ?? {};

    return DailyNutritionSummaryModel(
      // Preservamos null si viene null, solo convertimos a int si tiene valor
      metaCalories: json['meta_calories'] == null
          ? null
          : (json['meta_calories'] as num).toInt(),
      consumedCalories: (json['consumed_calories'] as num?)?.toInt() ?? 0,
      remainingCalories: json['remaining_calories'] == null
          ? null
          : (json['remaining_calories'] as num).toInt(),
      macros: MacroSummary.fromJson(macrosJson),
    );
  }

  /// Verifica si todas las metas nutricionales están configuradas (no null)
  bool get hasCompletedGoals =>
      metaCalories != null && macros.hasCompletedGoals;
}

/// Modelo que representa el resumen de un macronutriente (meta vs consumido).
class MacroSummary {
  /// Resumen de proteína
  final MacroDetail protein;

  /// Resumen de carbohidratos
  final MacroDetail carbs;

  /// Resumen de grasas
  final MacroDetail fats;

  const MacroSummary({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  /// Construye el resumen desde el JSON anidado de macros
  factory MacroSummary.fromJson(Map<String, dynamic> json) {
    return MacroSummary(
      // Parseamos cada macro individual desde su objeto anidado
      protein: MacroDetail.fromJson(
        json['protein'] as Map<String, dynamic>? ?? {},
      ),
      carbs: MacroDetail.fromJson(
        json['carbs'] as Map<String, dynamic>? ?? {},
      ),
      fats: MacroDetail.fromJson(
        json['fats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Verifica si todas las metas de macros están configuradas (no null)
  bool get hasCompletedGoals =>
      protein.meta != null &&
      carbs.meta != null &&
      fats.meta != null;
}

/// Modelo que representa los valores de meta y consumido para un macronutriente específico.
class MacroDetail {
  /// Meta diaria en gramos (null si no está configurada)
  final double? meta;

  /// Cantidad consumida en gramos
  final double consumed;

  const MacroDetail({
    required this.meta,
    required this.consumed,
  });

  /// Construye el detalle desde el JSON del macronutriente
  factory MacroDetail.fromJson(Map<String, dynamic> json) {
    return MacroDetail(
      // Preservamos null si viene null, solo convertimos a double si tiene valor
      meta: json['meta'] == null
          ? null
          : (json['meta'] as num).toDouble(),
      consumed: (json['consumed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
