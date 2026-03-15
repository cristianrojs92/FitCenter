import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/onboarding_provider.dart';

/// Botón de acción principal del formulario de onboarding.
/// Se muestra en el footer fijo de la pantalla y solo se activa cuando
/// todos los campos del formulario tienen un valor válido.
class ContinueButtonWidget extends StatelessWidget {
  /// Callback que se ejecuta cuando el usuario presiona el botón habilitado
  final Future<void> Function() onPressed;

  const ContinueButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Leemos si el formulario está completo para determinar el estado del botón
    final proveedor = context.watch<OnboardingProvider>();
    final isFormValid = proveedor.isFormValid;
    final isSaving = proveedor.isSaving;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: AnimatedContainer(
          // Animamos el cambio de color del botón al habilitarse/deshabilitarse
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          child: ElevatedButton(
            // Si el formulario no es válido, pasamos null para deshabilitar el botón
            onPressed: isFormValid && !isSaving ? () async => onPressed() : null,
            style: ElevatedButton.styleFrom(
              // Color de background verde si está habilitado, grisáceo si no
              backgroundColor: isFormValid && !isSaving
                  ? AppColors.primary
                  : AppColors.disabledButton,
              // Color del texto ajustado al estado del botón
              foregroundColor: isFormValid && !isSaving
                  ? AppColors.primaryText
                  : AppColors.disabledButtonText,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // Sombra verde sutil solo cuando el botón está activo
              elevation: isFormValid && !isSaving ? 6 : 0,
              // Sombra verde sutil con withValues para evitar pérdida de precisión
              shadowColor: isFormValid && !isSaving
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  isSaving ? 'Guardando...' : 'Continuar',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        color: isFormValid && !isSaving
                            ? AppColors.primaryText
                            : AppColors.disabledButtonText,
                      ),
                ),
                const SizedBox(width: 8),
                // Flecha de avance para indicar que la acción lleva a la siguiente pantalla
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: isFormValid && !isSaving
                      ? AppColors.primaryText
                      : AppColors.disabledButtonText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
