import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/daily_nutrition_repository.dart';
import '../data/models/daily_nutrition_summary_model.dart';

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
      proteinMeta > 0 ? (proteinGramos / proteinMeta).clamp(0.0, 1.0) : 0.0;

  /// Porcentaje de carbs consumidos respecto a la meta (0.0 a 1.0)
  double get carbsPercentage =>
      carbsMeta > 0 ? (carbsGramos / carbsMeta).clamp(0.0, 1.0) : 0.0;

  /// Porcentaje de fats consumidas respecto a la meta (0.0 a 1.0)
  double get fatsPercentage =>
      fatsMeta > 0 ? (fatsGramos / fatsMeta).clamp(0.0, 1.0) : 0.0;
}

/// Proveedor de estado para la pantalla Home del Dashboard.
/// Maneja el resumen diario de calorías, macros, meals y el estado del Bottom Sheet.
class HomeProvider extends ChangeNotifier {
  /// Repositorio para consultar datos nutricionales desde Supabase
  final DailyNutritionRepository _nutritionRepository =
      DailyNutritionRepository();

  /// Callback que se ejecuta cuando se detectan metas nutricionales incompletas (null)
  VoidCallback? onGoalsIncomplete;

  /// Fecha actualmente seleccionada para mostrar el resumen (por defecto hoy)
  DateTime _selectedDate = DateTime.now();

  /// Resumen nutricional del día obtenido desde Supabase (null si aún no se carga)
  DailyNutritionSummaryModel? _nutritionSummary;

  /// Indica si se está cargando el resumen nutricional desde el servidor
  bool _isLoading = false;

  /// Mensaje de error si falla la carga del resumen nutricional
  String? _errorMessage;

  // ── Estado del diario de calorías ──────────────────────────────────────────

  /// Meta diaria de calorías obtenida desde Supabase o 0 si aún no se carga o es null
  int get calorieGoal => _nutritionSummary?.metaCalories ?? 0;

  /// Total de calorías consumidas hoy obtenido desde Supabase o 0 si aún no se carga
  int get consumedCalories => _nutritionSummary?.consumedCalories ?? 0;

  /// Calorías restantes del día (meta menos consumido, mínimo 0) o 0 si la meta es null
  int get remainingCalories => _nutritionSummary?.remainingCalories ?? 0;

  /// Porcentaje completado del día (0.0 a 1.0) para el anillo de progreso
  double get completionPercentage {
    // Evitamos división por cero si no hay meta definida
    if (calorieGoal == 0) return 0.0;
    return (consumedCalories / calorieGoal).clamp(0.0, 1.0);
  }

  /// Expone el estado de carga para mostrar indicadores en la UI
  bool get isLoading => _isLoading;

  /// Expone el mensaje de error si hubo un problema al cargar datos
  String? get errorMessage => _errorMessage;

  /// Expone la fecha actualmente seleccionada
  DateTime get selectedDate => _selectedDate;

  /// Verifica si las metas nutricionales están incompletas (null)
  /// Retorna true solo cuando hay datos cargados y las metas son null
  bool get hasIncompleteGoals {
    // Solo retornamos true si hay datos cargados y las metas están incompletas
    if (_nutritionSummary == null) return false;
    return _nutritionSummary!.hasCompletedGoals == false;
  }

  /// Indica si hay datos nutricionales cargados (para verificar antes de navegar)
  bool get hasNutritionData => _nutritionSummary != null;

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

  /// Estado actual de los macronutrientes diarios obtenido desde Supabase
  /// Retorna valores por defecto si aún no se han cargado los datos o las metas son null
  DailyMacros get macros {
    // Si tenemos datos del servidor, los usamos
    if (_nutritionSummary != null) {
      return DailyMacros(
        proteinGramos: _nutritionSummary!.macros.protein.consumed,
        // Usamos 0 si la meta es null para evitar errores en la UI
        proteinMeta: _nutritionSummary!.macros.protein.meta ?? 0.0,
        carbsGramos: _nutritionSummary!.macros.carbs.consumed,
        carbsMeta: _nutritionSummary!.macros.carbs.meta ?? 0.0,
        fatsGramos: _nutritionSummary!.macros.fats.consumed,
        fatsMeta: _nutritionSummary!.macros.fats.meta ?? 0.0,
      );
    }
    // Valores por defecto mientras se cargan los datos reales
    return const DailyMacros(
      proteinGramos: 0,
      proteinMeta: 0,
      carbsGramos: 0,
      carbsMeta: 0,
      fatsGramos: 0,
      fatsMeta: 0,
    );
  }

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
    // Recargamos los datos desde el servidor para sincronizar con la base de datos
    loadDailyNutrition(_selectedDate);
  }

  /// Carga el resumen nutricional del día desde Supabase.
  /// Obtiene el userId del usuario autenticado y consulta el repositorio.
  /// Si detecta que las metas son null, ejecuta el callback onGoalsIncomplete.
  Future<void> loadDailyNutrition(DateTime date) async {
    // Obtenemos el usuario autenticado actual
    final currentUser = Supabase.instance.client.auth.currentUser;

    // Si no hay usuario autenticado, no podemos cargar datos
    if (currentUser == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    // Actualizamos el estado de carga antes de iniciar la consulta
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Llamamos al repositorio para obtener el resumen nutricional del día
      final summary = await _nutritionRepository.getDailyNutritionSummary(
        currentUser.id,
        date,
      );

      // Guardamos el resumen obtenido y actualizamos la fecha seleccionada
      _nutritionSummary = summary;
      _selectedDate = date;
      _errorMessage = null;

      // Notificamos a los listeners para que la UI se actualice
      notifyListeners();

      // Verificamos si las metas están incompletas (null) después de notificar
      // Esto permite que el build se ejecute y detecte el cambio
      if (summary.hasCompletedGoals == false) {
        // Ejecutamos el callback para navegar al onboarding
        onGoalsIncomplete?.call();
      }
    } catch (e) {
      // Capturamos cualquier error y guardamos el mensaje para mostrarlo al usuario
      _errorMessage = e.toString();
      _nutritionSummary = null;
    } finally {
      // Siempre actualizamos el estado de carga al finalizar
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia la fecha seleccionada y recarga los datos para esa fecha.
  void changeDate(DateTime newDate) {
    // Solo recargamos si la fecha es diferente a la actual
    if (newDate.year != _selectedDate.year ||
        newDate.month != _selectedDate.month ||
        newDate.day != _selectedDate.day) {
      loadDailyNutrition(newDate);
    }
  }
}
