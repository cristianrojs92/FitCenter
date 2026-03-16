import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/home_provider.dart';

/// Widget que muestra las tres tarjetas de macronutrientes del día:
/// Proteína (verde), Carbohidratos (ámbar) y Grasas (naranja).
class MacroCardsWidget extends StatelessWidget {
  const MacroCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos los macros del proveedor para mostrar el progreso
    final macros = context.watch<HomeProvider>().macros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección de macros
        Text(
          'Macros Diarios',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
        ),
        const SizedBox(height: 12),
        // Fila de tres tarjetas de macros en igualdad de ancho
        Row(
          children: [
            // Tarjeta de Proteína con color verde semántico
            Expanded(
              child: _TarjetaMacro(
                icon: Icons.fitness_center,
                name: 'Proteína',
                gramos: macros.proteinMeta,
                porcentaje: macros.proteinPercentage,
                color: AppColors.protein,
                colorFondo: AppColors.softProtein,
              ),
            ),
            const SizedBox(width: 10),
            // Tarjeta de Carbohidratos con color ámbar semántico
            Expanded(
              child: _TarjetaMacro(
                icon: Icons.bakery_dining_outlined,
                name: 'Carbo',
                gramos: macros.carbsMeta,
                porcentaje: macros.carbsPercentage,
                color: AppColors.carbs,
                colorFondo: AppColors.softCarbs,
              ),
            ),
            const SizedBox(width: 10),
            // Tarjeta de Grasas con color naranja semántico
            Expanded(
              child: _TarjetaMacro(
                icon: Icons.water_drop_outlined,
                name: 'Grasas',
                gramos: macros.fatsMeta,
                porcentaje: macros.fatsPercentage,
                color: AppColors.fats,
                colorFondo: AppColors.softFats,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tarjeta individual de macronutriente con ícono, gramos, name y barra de progreso
class _TarjetaMacro extends StatelessWidget {
  /// Ícono de Material que representa el macronutriente
  final IconData icon;

  /// Nombre corto del macro (ej. "Proteína", "Carbo", "Grasas")
  final String name;

  /// Gramos consumidos del macronutriente
  final double gramos;

  /// Porcentaje de progreso (0.0 a 1.0) para la barra inferior
  final double porcentaje;

  /// Color principal del macro para el ícono, texto de porcentaje y barra
  final Color color;

  /// Color de background suave del contenedor de la tarjeta
  final Color colorFondo;

  const _TarjetaMacro({
    required this.icon,
    required this.name,
    required this.gramos,
    required this.porcentaje,
    required this.color,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos el porcentaje en formato de texto para mostrar al usuario
    final textoPorcentaje = '${(porcentaje * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con el ícono del macro y el porcentaje en la esquina
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícono representativo del macronutriente
              Icon(icon, color: color, size: 18),
              // Porcentaje completado de la meta
              Text(
                textoPorcentaje,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Gramos consumidos en texto grande
          Text(
            '${gramos.toInt()}g',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
          ),
          // Nombre del macro
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          // Barra de progreso que rellena según el porcentaje del macro
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
