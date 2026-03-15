import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../logic/onboarding_provider.dart';

/// Widget de selección de género biológico.
/// Presenta dos opciones ("Hombre" y "Mujer") como botones de radio visuales
/// dentro de un contenedor pill. Solo una opción puede estar activa a la vez.
class SelectorGenderWidget extends StatelessWidget {
  /// Constructor constante para optimizar la reconstrucción del widget
  const SelectorGenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el proveedor de onboarding para acceder al género seleccionado
    final proveedor = context.watch<OnboardingProvider>();
    // Obtenemos el género actual del perfil que se muestra en la UI
    final genderSeleccionado = proveedor.perfil.gender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de la sección
        Text(
          'Género Biológico',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        // Contenedor pill que alberga las dos opciones
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Opción "Hombre"
              _BotonOpcionGender(
                label: 'Hombre',
                isSelected: genderSeleccionado == Gender.male,
                onPressed: () =>
                    context.read<OnboardingProvider>().actualizarGender(Gender.male),
              ),
              // Opción "Mujer"
              _BotonOpcionGender(
                label: 'Mujer',
                isSelected: genderSeleccionado == Gender.female,
                onPressed: () =>
                    context.read<OnboardingProvider>().actualizarGender(Gender.female),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sub-widget privado que representa un botón de opción individual dentro del selector.
/// Se activa con background blanco y texto oscuro; si está inactivo permanece transparente.
class _BotonOpcionGender extends StatelessWidget {
  /// Texto que se muestra en el botón
  final String label;

  /// Indica si esta opción está actualmente seleccionada
  final bool isSelected;

  /// Callback que se ejecuta al presionar el botón
  final VoidCallback onPressed;

  const _BotonOpcionGender({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        // Ejecutamos el callback al tocar el botón
        onTap: onPressed,
        child: AnimatedContainer(
          // Animamos el cambio de estado para suavizar la transición visual
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // El background blanco solo aparece cuando la opción está seleccionada
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            // Añadimos sombra sutil solo en el estado seleccionado
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      // Usamos withValues en lugar del deprecado withOpacity
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  // Texto oscuro si está seleccionado, secundario si no
                  color: isSelected
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
          ),
        ),
      ),
    );
  }
}
