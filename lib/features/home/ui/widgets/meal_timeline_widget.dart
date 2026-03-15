import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/home_provider.dart';

/// Widget que muestra la línea de tiempo de meals del día.
/// Cada comida es una tarjeta expandible con sus ítems y botón de añadir.
class MealTimelineWidget extends StatelessWidget {
  /// Callback que se invoca al presionar el botón + de una comida
  final void Function(MealType type) onPressedAnadir;

  const MealTimelineWidget({
    super.key,
    required this.onPressedAnadir,
  });

  @override
  Widget build(BuildContext context) {
    // Leemos la lista de meals del día desde el proveedor
    final meals = context.watch<HomeProvider>().meals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección de meals del día
        Text(
          'Registro de Comidas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
        ),
        const SizedBox(height: 12),
        // Generamos una tarjeta por cada type de comida del día
        ...meals.map(
          (comida) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TarjetaComida(
              comida: comida,
              onPressedAnadir: () => onPressedAnadir(comida.type),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de comida que muestra el encabezado y, si tiene ítems, la lista de alimentos
class _TarjetaComida extends StatelessWidget {
  /// Datos de la comida que se muestra en la tarjeta
  final MealModel comida;

  /// Callback para abrir el Bottom Sheet de registro pre-seleccionando esta comida
  final VoidCallback onPressedAnadir;

  const _TarjetaComida({
    required this.comida,
    required this.onPressedAnadir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            // Sombra suave para dar profundidad a la tarjeta
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabecera de la tarjeta con ícono, name, resumen y botón +
          _CabeceraComida(
            comida: comida,
            onPressedAnadir: onPressedAnadir,
          ),
          // Si la comida tiene ítems registrados, los mostramos debajo de la cabecera
          if (comida.items.isNotEmpty)
            _ListaItemsComida(items: comida.items),
        ],
      ),
    );
  }
}

/// Cabecera de la tarjeta de comida con ícono circular, name y botón de acción
class _CabeceraComida extends StatelessWidget {
  final MealModel comida;
  final VoidCallback onPressedAnadir;

  const _CabeceraComida({
    required this.comida,
    required this.onPressedAnadir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Contenedor del ícono con background verde suave
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              comida.type.icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Columna con el name y resumen calórico de la comida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comida.type.name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  comida.summaryText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          // Botón circular verde para añadir un alimento a esta comida
          GestureDetector(
            onTap: onPressedAnadir,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // Sombra verde para el efecto de elevación del botón
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: AppColors.primaryText, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de ítems de alimento registrados dentro de una comida expandida
class _ListaItemsComida extends StatelessWidget {
  final List<FoodItemModel> items;

  const _ListaItemsComida({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        // Fondo ligeramente diferenciado para la sección de ítems
        color: AppColors.secondaryBackground.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        // Generamos una fila por cada alimento registrado en la comida
        children: items.map((item) => _FilaItem(item: item)).toList(),
      ),
    );
  }
}

/// Fila individual de un alimento con su name y calorías
class _FilaItem extends StatelessWidget {
  final FoodItemModel item;

  const _FilaItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre del alimento a la izquierda
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          // Calorías del alimento a la derecha en negrita
          Text(
            '${item.calories} kcal',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
          ),
        ],
      ),
    );
  }
}
