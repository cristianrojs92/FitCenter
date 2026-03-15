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
  Future<void> saveProfile(String userId, UserProfileModel profile) async {
    await _supabase.from('users').upsert(profile.toDatabaseRow(userId: userId));
  }
}
