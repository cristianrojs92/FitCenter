import 'package:flutter/material.dart';

/// Enumeración de los types de comida disponibles en el diario diario
enum MealType {
  /// Comida de la mañana
  breakfast,

  /// Comida del mediodía
  lunch,

  /// Comida de la noche
  dinner,

  /// Refrigerios entre meals
  snacks,
}

/// Extensión para obtener el name y el ícono de cada type de comida
extension MealTypeExtension on MealType {
  /// Devuelve el name legible del type de comida en español
  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snacks:
        return 'Meriendas';
    }
  }

  /// Devuelve el ícono representativo de cada type de comida
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
      case MealType.snacks:
        return Icons.cookie_outlined;
    }
  }
}

/// Modelo que representa un ítem de alimento registrado en una comida
class FoodItemModel {
  /// Nombre del alimento tal como fue registrado o detectado por la IA
  final String name;

  /// Calorías del alimento en kcal
  final int calories;

  const FoodItemModel({required this.name, required this.calories});
}

/// Modelo que representa una comida del día con sus ítems registrados
class MealModel {
  /// Tipo de comida (breakfast, lunch, etc.)
  final MealType type;

  /// Lista de alimentos registrados en esta comida
  final List<FoodItemModel> items;

  const MealModel({required this.type, this.items = const []});

  /// Calcula el total de calorías sumando todos los ítems registrados
  int get totalCalories =>
      items.fold(0, (suma, item) => suma + item.calories);

  /// Retorna un texto descriptivo para mostrar en la cabecera de la comida
  String get summaryText =>
      items.isEmpty ? 'Pendiente' : '$totalCalories kcal';
}

/// Modelo de macros diarios con progreso relativo a la meta
class DailyMacros {
  /// Gramos de proteína consumidos hoy
  final double proteinGramos;

  /// Meta diaria de proteína en gramos
  final double proteinMeta;

  /// Gramos de carbs consumidos hoy
  final double carbsGramos;

  /// Meta diaria de carbs en gramos
  final double carbsMeta;

  /// Gramos de fats consumidas hoy
  final double fatsGramos;

  /// Meta diaria de fats en gramos
  final double fatsMeta;

  const DailyMacros({
    required this.proteinGramos,
    required this.proteinMeta,
    required this.carbsGramos,
    required this.carbsMeta,
    required this.fatsGramos,
    required this.fatsMeta,
  });

  /// Porcentaje de proteína consumida respecto a la meta (0.0 a 1.0)
  double get proteinPercentage =>
      (proteinGramos / proteinMeta).clamp(0.0, 1.0);

  /// Porcentaje de carbs consumidos respecto a la meta (0.0 a 1.0)
  double get carbsPercentage =>
      (carbsGramos / carbsMeta).clamp(0.0, 1.0);

  /// Porcentaje de fats consumidas respecto a la meta (0.0 a 1.0)
  double get fatsPercentage =>
      (fatsGramos / fatsMeta).clamp(0.0, 1.0);
}

/// Proveedor de estado para la pantalla Home del Dashboard.
/// Maneja el resumen diario de calorías, macros, meals y el estado del Bottom Sheet.
class HomeProvider extends ChangeNotifier {
  // ── Estado del diario de calorías ──────────────────────────────────────────

  /// Meta diaria de calorías calculada en el onboarding
  final int calorieGoal = 1850;

  /// Total de calorías consumidas hoy (suma de todas las meals)
  int get consumedCalories =>
      _meals.fold(0, (suma, comida) => suma + comida.totalCalories);

  /// Calorías restantes del día (meta menos consumido, mínimo 0)
  int get remainingCalories =>
      (calorieGoal - consumedCalories).clamp(0, calorieGoal);

  /// Porcentaje completado del día (0.0 a 1.0) para el anillo de progreso
  double get completionPercentage =>
      (consumedCalories / calorieGoal).clamp(0.0, 1.0);

  // ── Estado de las meals del día ──────────────────────────────────────────

  /// Lista de meals del día con sus ítems registrados
  List<MealModel> _meals = [
    const MealModel(
      type: MealType.breakfast,
      items: [FoodItemModel(name: 'Avena con leche', calories: 420)],
    ),
    const MealModel(
      type: MealType.lunch,
      items: [
        FoodItemModel(name: 'Pollo a la plancha', calories: 350),
        FoodItemModel(name: 'Arroz integral', calories: 120),
        FoodItemModel(name: 'Ensalada verde', calories: 110),
      ],
    ),
    const MealModel(type: MealType.dinner, items: []),
    const MealModel(
      type: MealType.snacks,
      items: [FoodItemModel(name: 'Yogur griego', calories: 200)],
    ),
  ];

  /// Retorna la lista inmutable de meals del día
  List<MealModel> get meals => List.unmodifiable(_meals);

  // ── Macros diarios ─────────────────────────────────────────────────────────

  /// Estado actual de los macronutrientes diarios del usuario
  final DailyMacros macros = const DailyMacros(
    proteinGramos: 120,
    proteinMeta: 150,
    carbsGramos: 180,
    carbsMeta: 277,
    fatsGramos: 45,
    fatsMeta: 100,
  );

  // ── Estado del Bottom Sheet de registro ───────────────────────────────────

  /// Tipo de comida actualmente seleccionado en el Bottom Sheet
  MealType _selectedMealType = MealType.breakfast;

  /// Expone el type de comida seleccionado para el Bottom Sheet
  MealType get selectedMealType => _selectedMealType;

  /// Detecta automáticamente el type de comida sugerido según la hora del día
  MealType detectMealByHour() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 11) return MealType.breakfast;
    if (hora >= 11 && hora < 15) return MealType.lunch;
    if (hora >= 15 && hora < 20) return MealType.snacks;
    return MealType.dinner;
  }

  /// Actualiza el type de comida seleccionado en el Bottom Sheet
  void selectMealType(MealType type) {
    // Guardamos el type elegido y notificamos para actualizar los pills del selector
    _selectedMealType = type;
    notifyListeners();
  }

  /// Abre el Bottom Sheet y autoselecciona la comida según la hora del día
  void openQuickLogFromCenterButton() {
    // Detectamos la comida más lógica y la preseleccionamos
    _selectedMealType = detectMealByHour();
    notifyListeners();
  }

  /// Abre el Bottom Sheet preseleccionando el type de comida del botón + presionado
  void openQuickLogFromMeal(MealType type) {
    // Usamos el contexto de la comida que originó la apertura del Bottom Sheet
    _selectedMealType = type;
    notifyListeners();
  }

  /// Agrega un nuevo ítem de alimento a la comida correspondiente
  void addFoodItem(FoodItemModel item, MealType type) {
    // Reemplazamos la comida del type indicado con la nueva versión que incluye el ítem
    _meals = _meals.map((comida) {
      if (comida.type == type) {
        return MealModel(
          type: comida.type,
          items: [...comida.items, item],
        );
      }
      return comida;
    }).toList();
    // Notificamos para que el dashboard se actualice con las nuevas calorías
    notifyListeners();
  }
}
