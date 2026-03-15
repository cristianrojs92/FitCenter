import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/home_provider.dart';

/// Widget que muestra el resumen de calorías del día con un anillo circular animado.
/// Muestra las calorías restantes en el centro y la meta/consumido debajo.
class CalorieRingWidget extends StatelessWidget {
  const CalorieRingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el proveedor solo para los valores de calorías que necesitamos
    final proveedor = context.watch<HomeProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Sombra sutil para dar profundidad a la tarjeta principal
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Anillo SVG personalizado con el progreso de calorías
          SizedBox(
            width: 200,
            height: 200,
            child: _AnilloProgreso(
              porcentaje: proveedor.completionPercentage,
              remainingCalories: proveedor.remainingCalories,
            ),
          ),
          const SizedBox(height: 24),
          // Línea divisoria antes del resumen numérico
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 20),
          // Fila con meta calórica y calorías consumidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Columna con la meta calórica del día
              _DatoCaloria(
                label: 'META',
                valor: proveedor.calorieGoal,
              ),
              // Columna con las calorías consumidas hasta ahora
              _DatoCaloria(
                label: 'CONSUMIDO',
                valor: proveedor.consumedCalories,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pinta el anillo de progreso circular con Canvas personalizado
class _AnilloProgreso extends StatelessWidget {
  /// Progreso del anillo entre 0.0 y 1.0
  final double porcentaje;

  /// Número de calorías restantes a mostrar en el centro
  final int remainingCalories;

  const _AnilloProgreso({
    required this.porcentaje,
    required this.remainingCalories,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // Pasamos el porcentaje al painter para dibujar el arco de progreso
      painter: _AnilloPainter(porcentaje: porcentaje),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Número grande de calorías restantes en el centro del anillo
            Text(
              '$remainingCalories',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                    fontSize: 48,
                  ),
            ),
            // Etiqueta descriptiva debajo del número
            Text(
              'RESTANTES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter personalizado que dibuja el anillo circular de progreso
class _AnilloPainter extends CustomPainter {
  /// Porcentaje de progreso (0.0 a 1.0) para calcular el ángulo del arco
  final double porcentaje;

  const _AnilloPainter({required this.porcentaje});

  @override
  void paint(Canvas canvas, Size size) {
    // Centro y radio del anillo calculados desde el tamaño del widget
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = (size.width / 2) - 14;
    const grosor = 14.0;

    // Pintamos primero el background del anillo con el color suave del primary
    final pinturaFondo = Paint()
      ..color = AppColors.softPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(centro, radio, pinturaFondo);

    // Pintamos el arco de progreso encima con el verde primary
    final pinturaProgreso = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;

    // El ángulo de barrido se calcula desde la posición 12 en punto (-π/2)
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -math.pi / 2,
      2 * math.pi * porcentaje,
      false,
      pinturaProgreso,
    );
  }

  @override
  bool shouldRepaint(_AnilloPainter antiguo) =>
      antiguo.porcentaje != porcentaje;
}

/// Widget que muestra el dato numérico de caloría con su label
class _DatoCaloria extends StatelessWidget {
  /// Texto de la label descriptiva (ej. "META")
  final String label;

  /// Valor numérico de calorías a mostrar
  final int valor;

  const _DatoCaloria({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Etiqueta en mayúsculas con tracking amplio
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryText,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        // Valor numérico grande y en negrita
        Text(
          valor.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
        ),
      ],
    );
  }
}
