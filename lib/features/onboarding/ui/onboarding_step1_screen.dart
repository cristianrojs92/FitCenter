import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logout_dialog.dart';
import '../logic/onboarding_provider.dart';
import 'widgets/continue_button_widget.dart';
import 'widgets/numeric_field_widget.dart';
import 'widgets/gender_selector_widget.dart';
import 'widgets/goal_selector_widget.dart';
import 'widgets/activity_card_widget.dart';
import '../../home/ui/home_screen.dart';

/// Pantalla del Paso 1 del onboarding: captura de información física básica.
/// Actúa como orquestadora de los widgets del formulario y el proveedor de estado.
class OnboardingStep1Screen extends StatelessWidget {
  const OnboardingStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accedemos al proveedor para pasar los callbacks de validación a los campos
    final proveedor = context.read<OnboardingProvider>();

    return Scaffold(
      // Fondo coherente con el tema de la app
      backgroundColor: AppColors.background,
      // AppBar con botón de logout
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.secondaryText,
            ),
            onPressed: () => mostrarDialogoCerrarSesion(
              context,
              mensaje: 'Se perderán los cambios no guardados. ¿Deseas cerrar sesión?',
            ),
          ),
        ],
      ),
      // Footer sticky con el botón de acción principal
      bottomNavigationBar: ContinueButtonWidget(
        onPressed: () async {
          final exito = await proveedor.saveProfile();
          if (!context.mounted) return;

          if (exito) {
            // Navegamos al Dashboard Home cuando el perfil ya quedó persistido.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            return;
          }

          final mensaje = proveedor.saveErrorMessage ??
              'No pudimos guardar tu perfil. Intenta nuevamente.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje)),
          );
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          // Padding lateral uniforme para todos los elementos de la pantalla
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio superior antes del título
              const SizedBox(height: 32),
              // Título principal de la pantalla centrado
              _EncabezadoPantalla(),
              const SizedBox(height: 28),
              // Selector de género biológico (Hombre / Mujer)
              const SelectorGenderWidget(),
              const SizedBox(height: 22),
              // Fila con los campos de Edad y Peso en paralelo
              _FilaCamposEdadYPeso(proveedor: proveedor),
              const SizedBox(height: 22),
              // Campo de altura a ancho completo
              _CampoAltura(proveedor: proveedor),
              const SizedBox(height: 28),
              // Lista de tarjetas de nivel de actividad
              const ActivityCardWidget(),
              const SizedBox(height: 28),
              // Grid de goal nutricional 
              const GoalSelectorWidget(),
              // Espacio inferior para que el contenido no quede tapado por el botón
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado con el título y subtítulo de la pantalla de onboarding
class _EncabezadoPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título grande centrado de la pantalla
        Center(
          child: Text(
            'Información Básica',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        // Subtítulo descriptivo centrado debajo del título
        Center(
          child: Text(
            'Empecemos con lo básico para personalizar\ntu plan de nutrición.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Fila con los campos numéricos de Edad (int) y Peso (decimal) en paralelo
class _FilaCamposEdadYPeso extends StatelessWidget {
  final OnboardingProvider proveedor;

  const _FilaCamposEdadYPeso({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    // Usamos Selector para redibujar solo cuando cambian los errores de estos campos
    return Selector<OnboardingProvider, (String?, String?)>(
      selector: (_, p) => (p.ageError, p.weightError),
      builder: (_, errores, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de age (solo enteros, rango 13–120)
          Expanded(
            child: NumericFieldWidget(
              label: 'Edad',
              unidad: 'años',
              placeholder: '25',
              textoError: errores.$1,
              alPerderFoco: proveedor.updateAge,
              // Guarda el valor en tiempo real para habilitar el botón Continuar
              alCambiar: proveedor.saveAgeSilently,
            ),
          ),
          const SizedBox(width: 14),
          // Campo de peso (acepta decimales, mínimo 20 kg)
          Expanded(
            child: NumericFieldWidget(
              label: 'Peso',
              unidad: 'kg',
              placeholder: '70',
              aceptaDecimales: true,
              textoError: errores.$2,
              alPerderFoco: proveedor.updateWeight,
              // Guarda el valor en tiempo real para habilitar el botón Continuar
              alCambiar: proveedor.saveWeightSilently,
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo numérico de altura a ancho completo de pantalla
class _CampoAltura extends StatelessWidget {
  final OnboardingProvider proveedor;

  const _CampoAltura({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    // Redibujar solo cuando cambia el error de altura
    return Selector<OnboardingProvider, String?>(
      selector: (_, p) => p.heightError,
      builder: (_, heightError, _) => NumericFieldWidget(
        label: 'Altura',
        unidad: 'cm',
        placeholder: '175',
        textoError: heightError,
        alPerderFoco: proveedor.updateHeight,
        // Guarda el valor en tiempo real para habilitar el botón Continuar
        alCambiar: proveedor.saveHeightSilently,
      ),
    );
  }
}
