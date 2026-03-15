import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../logic/onboarding_provider.dart';

/// Widget de selección de goal nutricional principal.
/// Presenta dos tarjetas cuadradas: "Ganar Músculo" y "Perder Grasa".
/// Solo una puede estar activa al mismo tiempo.
class GoalSelectorWidget extends StatelessWidget {
  const GoalSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el goal actualmente seleccionado desde el proveedor
    final goalSeleccionado =
        context.watch<OnboardingProvider>().perfil.goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de la sección
        Text(
          '¿Cuál es tu goal principal?',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        // Grid de dos columnas para las tarjetas de goal
        Row(
          children: [
            // Tarjeta para el goal de ganar músculo (volumen)
            Expanded(
              child: _TarjetaObjetivo(
                icon: Icons.fitness_center,
                label: 'Ganar Músculo',
                goal: NutritionGoal.gainMuscle,
                estaSeleccionada:
                    goalSeleccionado == NutritionGoal.gainMuscle,
                onPressed: () => context
                    .read<OnboardingProvider>()
                    .updateGoal(NutritionGoal.gainMuscle),
              ),
            ),
            const SizedBox(width: 14),
            // Tarjeta para el goal de perder grasa (déficit)
            Expanded(
              child: _TarjetaObjetivo(
                icon: Icons.monitor_weight_outlined,
                label: 'Perder Grasa',
                goal: NutritionGoal.loseFat,
                estaSeleccionada:
                    goalSeleccionado == NutritionGoal.loseFat,
                onPressed: () => context
                    .read<OnboardingProvider>()
                    .updateGoal(NutritionGoal.loseFat),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tarjeta cuadrada de goal nutricional con estado activo/inactivo animado
class _TarjetaObjetivo extends StatelessWidget {
  /// Ícono que representa visualmente el goal
  final IconData icon;

  /// Texto corto que describe el goal
  final String label;

  /// El enum de goal nutricional que representa esta tarjeta
  final NutritionGoal goal;

  /// Indica si esta tarjeta está actualmente seleccionada
  final bool estaSeleccionada;

  /// Callback que se ejecuta al presionar la tarjeta
  final VoidCallback onPressed;

  const _TarjetaObjetivo({
    required this.icon,
    required this.label,
    required this.goal,
    required this.estaSeleccionada,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        // Animamos el cambio visual al seleccionar la tarjeta
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          // El border cambia a verde cuando está seleccionado
          border: Border.all(
            color: estaSeleccionada ? AppColors.activeBorder : AppColors.border,
            width: estaSeleccionada ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono grande de Material que ilustra el goal
            Icon(
              icon,
              size: 42,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            // Texto descriptivo del goal
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
