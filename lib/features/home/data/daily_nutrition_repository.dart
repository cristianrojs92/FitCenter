import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/daily_nutrition_summary_model.dart';

/// Repositorio para consultar el resumen nutricional diario desde Supabase.
/// Invoca la función RPC que calcula calorías y macros consumidos vs metas.
class DailyNutritionRepository {
  /// Cliente de Supabase compartido para ejecutar llamadas RPC
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Verifica si el usuario tiene metas nutricionales configuradas.
  ///
  /// [userId] ID del usuario autenticado (UUID)
  ///
  /// Retorna true si meta_calories NO es null, false en caso contrario.
  /// Este método es más ligero que [getDailyNutritionSummary] ya que solo
  /// verifica la existencia de metas sin crear el modelo completo.
  Future<bool> hasNutritionGoalsConfigured(String userId) async {
    try {
      // Usamos la fecha actual para la consulta
      final dateString = DateTime.now().toIso8601String().split('T').first;

      // Invocamos la función RPC de Supabase con los parámetros requeridos
      final response = await _supabase.rpc(
        'get_daily_summary',
        params: {
          'p_date': dateString,
          'p_user_id': userId,
        },
      );

      // La respuesta de RPC viene como Map<String, dynamic>
      final jsonData = response as Map<String, dynamic>;

      // Verificamos si meta_calories NO es null
      return jsonData['meta_calories'] != null;
    } catch (e) {
      // Si hay error, asumimos que NO tiene metas configuradas
      // para forzar al usuario a completar el onboarding
      return false;
    }
  }

  /// Obtiene el resumen nutricional diario para un usuario y fecha específicos.
  ///
  /// [userId] ID del usuario autenticado (UUID)
  /// [date] Fecha para la cual se quiere obtener el resumen (por defecto hoy)
  ///
  /// Retorna un [DailyNutritionSummaryModel] con las calorías y macros del día.
  /// Lanza una excepción si hay error de conexión o la función RPC falla.
  Future<DailyNutritionSummaryModel> getDailyNutritionSummary(
    String userId,
    DateTime date,
  ) async {
    try {
      // Convertimos la fecha a formato ISO string (YYYY-MM-DD) que espera Supabase
      final dateString = date.toIso8601String().split('T').first;

      // Invocamos la función RPC de Supabase con los parámetros requeridos
      // Nota: El orden de parámetros debe coincidir con la definición de la función (p_date, p_user_id)
      final response = await _supabase.rpc(
        'get_daily_summary',
        params: {
          'p_date': dateString,
          'p_user_id': userId,
        },
      );

      // La respuesta de RPC viene como Map<String, dynamic>
      final jsonData = response as Map<String, dynamic>;

      // Parseamos el JSON al modelo tipado
      return DailyNutritionSummaryModel.fromJson(jsonData);
    } on PostgrestException catch (e) {
      // Capturamos errores específicos de Supabase/PostgreSQL
      throw Exception(
        'Error al obtener resumen nutricional: ${e.message}',
      );
    } catch (e) {
      // Capturamos cualquier otro error inesperado
      throw Exception(
        'Error inesperado al consultar resumen nutricional: $e',
      );
    }
  }
}
