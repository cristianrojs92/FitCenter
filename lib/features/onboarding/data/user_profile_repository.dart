import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_profile_model.dart';

/// Repositorio para consultar y persistir el perfil del usuario autenticado.
class UserProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna true cuando el usuario ya terminó el onboarding.
  Future<bool> hasCompletedOnboarding(String userId) async {
    final row = await _supabase
        .from('users')
        .select('onboarding_completed')
        .eq('id', userId)
        .maybeSingle();

    return row?['onboarding_completed'] == true;
  }

  /// Guarda o actualiza el perfil del usuario autenticado.
  /// Llama a la edge function calculate-targets para calcular y guardar las metas nutricionales.
  Future<void> saveProfile(String userId, UserProfileModel profile) async {
    // #region agent log
    final profileData = profile.toDatabaseRow(userId: userId);
    try {
      final logFile = File('/Users/cristian/Proyectos/DietX/.cursor/debug.log');
      await logFile.writeAsString(
        '${jsonEncode({'location': 'user_profile_repository.dart:28', 'message': 'saveProfile called', 'data': {'userId': userId, 'profileData': profileData}, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'hypothesisId': 'FIX'})}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Convertimos los enums a los valores que espera la edge function
    final genderValue = profile.gender == Gender.male ? 'male' : 'female';
    final activityLevelValue = _mapActivityLevel(profile.activityLevel!);
    final goalValue = _mapGoal(profile.goal!);

    // Preparamos el payload para la edge function
    final payload = {
      'user_id': userId,
      'gender': genderValue,
      'age': profile.age,
      'weight_kg': profile.weightKg,
      'height_cm': profile.heightCm,
      'activity_level': activityLevelValue,
      'goal': goalValue,
    };

    // #region agent log
    try {
      final logFile = File('/Users/cristian/Proyectos/DietX/.cursor/debug.log');
      await logFile.writeAsString(
        '${jsonEncode({'location': 'user_profile_repository.dart:53', 'message': 'calling calculate-targets edge function (NO AUTH)', 'data': {'payload': payload}, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'hypothesisId': 'FIX'})}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Llamamos a la edge function de Supabase para calcular las metas nutricionales
    // NOTA: La función ahora NO requiere autenticación (modo debugging)
    final response = await _supabase.functions.invoke(
      'calculate-targets',
      body: payload,
    );

    // #region agent log
    try {
      final logFile = File('/Users/cristian/Proyectos/DietX/.cursor/debug.log');
      await logFile.writeAsString(
        '${jsonEncode({'location': 'user_profile_repository.dart:85', 'message': 'edge function response received', 'data': {'status': response.status, 'data': response.data}, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'hypothesisId': 'FIX'})}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // Verificamos si la llamada fue exitosa
    if (response.status != 200) {
      throw Exception(
        'Error al calcular metas nutricionales: ${response.data}',
      );
    }

    // La edge function ya actualiza la tabla users con las metas calculadas,
    // por lo que no necesitamos hacer el upsert manual aquí.
    // Sin embargo, aún necesitamos asegurar que onboarding_completed esté en true
    await _supabase.from('users').update({
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);

    // #region agent log
    try {
      final logFile = File('/Users/cristian/Proyectos/DietX/.cursor/debug.log');
      await logFile.writeAsString(
        '${jsonEncode({'location': 'user_profile_repository.dart:109', 'message': 'profile saved successfully with nutrition targets', 'data': {'userId': userId}, 'timestamp': DateTime.now().millisecondsSinceEpoch, 'hypothesisId': 'FIX'})}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
  }

  /// Mapea el ActivityLevel enum a los valores que espera la edge function
  String _mapActivityLevel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'sedentario';
      case ActivityLevel.light:
        return 'ligero';
      case ActivityLevel.moderate:
        return 'moderado';
      case ActivityLevel.intense:
        return 'intenso';
      case ActivityLevel.athlete:
        return 'atleta';
    }
  }

  /// Mapea el NutritionGoal enum a los valores que espera la edge function
  String _mapGoal(NutritionGoal goal) {
    switch (goal) {
      case NutritionGoal.loseFat:
        return 'lose_fat';
      case NutritionGoal.gainMuscle:
        return 'gain_muscle';
    }
  }
}
