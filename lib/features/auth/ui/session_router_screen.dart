import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/data/daily_nutrition_repository.dart';
import '../../home/ui/home_screen.dart';
import '../../onboarding/data/user_profile_repository.dart';
import '../../onboarding/ui/onboarding_step1_screen.dart';
import 'login_screen.dart';

/// Pantalla de enrutamiento inicial que verifica la sesión de Supabase
/// antes de decidir a qué pantalla navegar.
///
/// Flujo de decisión:
/// - Sin sesión → Login
/// - Sesión activa + onboarding incompleto → Onboarding
/// - Sesión activa + onboarding completo + metas sin configurar → Onboarding
/// - Sesión activa + onboarding completo + metas configuradas → Dashboard Home
class SessionRouterScreen extends StatefulWidget {
  const SessionRouterScreen({super.key});

  @override
  State<SessionRouterScreen> createState() => _SessionRouterScreenState();
}

class _SessionRouterScreenState extends State<SessionRouterScreen> {
  final UserProfileRepository _profileRepository = UserProfileRepository();
  final DailyNutritionRepository _nutritionRepository =
      DailyNutritionRepository();

  @override
  void initState() {
    super.initState();
    // Verificamos la sesión tan pronto como el widget se monta
    _checkSessionAndNavigate();
  }

  /// Verifica la sesión actual de Supabase y navega a la pantalla correcta.
  /// Se ejecuta una sola vez al iniciar la app.
  Future<void> _checkSessionAndNavigate() async {
    // Obtenemos la sesión actual del cliente de Supabase (null si no hay sesión)
    final session = Supabase.instance.client.auth.currentSession;

    // Esperamos un frame para asegurar que el contexto esté listo para navegar
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (session != null) {
      try {
        final hasCompletedOnboarding = await _profileRepository
            .hasCompletedOnboarding(session.user.id);

        if (!mounted) return;

        // Si no completó onboarding, vamos directo a onboarding
        if (!hasCompletedOnboarding) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingStep1Screen()),
          );
          return;
        }

        // Si completó onboarding, verificamos si tiene metas configuradas
        final hasGoalsConfigured = await _nutritionRepository
            .hasNutritionGoalsConfigured(session.user.id);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => hasGoalsConfigured
                ? const HomeScreen()
                : const OnboardingStep1Screen(),
          ),
        );
      } catch (_) {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingStep1Screen()),
        );
      }
    } else {
      // No hay sesión: mostramos la pantalla de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras verificamos la sesión mostramos un splash minimalista con el logo
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de la app centrado como splash screen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bolt,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            // Nombre de la app durante el splash
            Text(
              'DietX',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 32),
            // Indicador de carga mientras se verifica la sesión
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
