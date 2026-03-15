import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../logic/onboarding_provider.dart';

/// Modelo de datos interno para configurar cada tarjeta de nivel de actividad
class _DatosTarjetaActividad {
  /// Nombre visible de la tarjeta (ej. "Sedentario")
  final String titulo;

  /// Descripción corta del nivel de actividad
  final String descripcion;

  /// Ícono de Material que representa visualmente el nivel
  final IconData icon;

  /// El enum correspondiente en el modelo de datos
  final ActivityLevel nivel;

  const _DatosTarjetaActividad({
    required this.titulo,
    required this.descripcion,
    required this.icon,
    required this.nivel,
  });
}

/// Widget que muestra la lista de tarjetas seleccionables de nivel de actividad.
/// Solo una tarjeta puede estar activa a la vez; la seleccionada resalta con border verde.
class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({super.key});

  // Lista de configuraciones de las tarjetas disponibles
  static const List<_DatosTarjetaActividad> _niveles = [
    _DatosTarjetaActividad(
      titulo: 'Sedentario',
      descripcion: 'Poco o nada de ejercicio, trabajo de escritorio',
      icon: Icons.chair_outlined,
      nivel: ActivityLevel.sedentary,
    ),
    _DatosTarjetaActividad(
      titulo: 'Ligero',
      descripcion: 'Ejercicio light 1-3 veces por semana',
      icon: Icons.directions_walk,
      nivel: ActivityLevel.light,
    ),
    _DatosTarjetaActividad(
      titulo: 'Moderado',
      descripcion: 'Ejercicio moderate 3-5 veces por semana',
      icon: Icons.directions_bike_outlined,
      nivel: ActivityLevel.moderate,
    ),
    _DatosTarjetaActividad(
      titulo: 'Intenso',
      descripcion: 'Ejercicio intense 6-7 veces por semana',
      icon: Icons.fitness_center,
      nivel: ActivityLevel.intense,
    ),
    _DatosTarjetaActividad(
      titulo: 'Atleta',
      descripcion: 'Entrenamiento profesional o trabajo muy exigente',
      icon: Icons.sports_gymnastics,
      nivel: ActivityLevel.athlete,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Leemos el nivel de actividad actualmente seleccionado del proveedor
    final nivelSeleccionado =
        context.watch<OnboardingProvider>().perfil.activityLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de la sección
        Text('Nivel de Actividad', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        // Iteramos sobre los datos de cada nivel para construir las tarjetas
        ...List.generate(_niveles.length, (indice) {
          final datos = _niveles[indice];
          // Verificamos si este nivel es el que está seleccionado actualmente
          final isSelected = nivelSeleccionado == datos.nivel;
          return _TarjetaActividad(
            datos: datos,
            estaSeleccionada: isSelected,
            onPressed: () => context
                .read<OnboardingProvider>()
                .actualizarActivityLevel(datos.nivel),
          );
        }),
      ],
    );
  }
}

/// Tarjeta individual de nivel de actividad con estado activo/inactivo animado
class _TarjetaActividad extends StatelessWidget {
  final _DatosTarjetaActividad datos;
  final bool estaSeleccionada;
  final VoidCallback onPressed;

  const _TarjetaActividad({
    required this.datos,
    required this.estaSeleccionada,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Separación vertical entre tarjetas
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          // Animamos el cambio de border para suavizar la transición de selección
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            // El border cambia a verde cuando la tarjeta está seleccionada
            border: Border.all(
              color: estaSeleccionada ? AppColors.activeBorder : AppColors.border,
              width: estaSeleccionada ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Contenedor del ícono con background verde suave o verde sólido si seleccionado
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: estaSeleccionada
                      ? AppColors.primary
                      : AppColors.softPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  datos.icon,
                  // Ícono oscuro si está seleccionado (contraste con verde), verde si no
                  color: estaSeleccionada
                      ? AppColors.primaryText
                      : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Columna con el título y descripción de la tarjeta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datos.titulo,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      datos.descripcion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              // Ícono de check verde que solo aparece cuando la tarjeta está seleccionada
              if (estaSeleccionada)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
