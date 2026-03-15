import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'quick_log_bottom_sheet.dart';


/// Barra de navegación inferior con 5 ítems y el FAB central elevado de Registrar.
/// El botón central de "Registrar" abre el Bottom Sheet de registro rápido.
class NavigationBarWidget extends StatelessWidget {
  const NavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        // Borde superior sutil para separar la barra del contenido principal
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            // Sombra suave hacia arriba para dar profundidad a la barra
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ítem de Inicio (activo, con ícono relleno)
              _ItemNavegacion(
                icon: Icons.home,
                label: 'Inicio',
                estaActivo: true,
              ),
              // Ítem de Comidas (inactivo)
              _ItemNavegacion(
                icon: Icons.restaurant_menu_outlined,
                label: 'Comidas',
                estaActivo: false,
              ),
              // Botón FAB central elevado de Registrar (el elemento más importante)
              _BotonFabRegistrar(),
              // Ítem de Progreso (inactivo)
              _ItemNavegacion(
                icon: Icons.insights_outlined,
                label: 'Progreso',
                estaActivo: false,
              ),
              // Ítem de Perfil (inactivo)
              _ItemNavegacion(
                icon: Icons.person_outline,
                label: 'Perfil',
                estaActivo: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ítem genérico de navegación con ícono y label
class _ItemNavegacion extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool estaActivo;

  const _ItemNavegacion({
    required this.icon,
    required this.label,
    required this.estaActivo,
  });

  @override
  Widget build(BuildContext context) {
    // El color cambia entre verde (activo) y gris (inactivo)
    final color =
        estaActivo ? AppColors.primary : AppColors.secondaryText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 9,
                    fontWeight: estaActivo ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón FAB central elevado que abre el Bottom Sheet de registro rápido
class _BotonFabRegistrar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Abrimos el Bottom Sheet detectando la comida según la hora
      onTap: () => QuickLogBottomSheet.mostrarDesdeBotonCentral(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón circular grande elevado sobre la barra de navegación
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      // Sombra verde intensiva para el efecto de elevación del FAB
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primaryText,
                  size: 28,
                ),
              ),
              // Badge de IA en la esquina superior derecha del FAB
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Etiqueta verde del botón central
          Text(
            'REGISTRAR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
