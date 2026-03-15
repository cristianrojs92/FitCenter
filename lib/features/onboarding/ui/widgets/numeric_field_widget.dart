import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget reutilizable para campos numéricos del formulario de onboarding.
/// Muestra una label, un campo de texto con teclado numérico, una unidad
/// de medida superpuesta y un mensaje de error opcional al perder el foco.
class NumericFieldWidget extends StatefulWidget {
  /// Etiqueta que se muestra sobre el campo (ej. "Edad", "Peso")
  final String label;

  /// Unidad de medida que aparece a la derecha del campo (ej. "años", "kg")
  final String unidad;

  /// Texto de ayuda que se muestra cuando el campo está vacío
  final String placeholder;

  /// Indica si el campo acepta decimales (true para Peso, false para Edad/Altura)
  final bool aceptaDecimales;

  /// Callback que se llama al perder el foco con el valor ingresado (muestra errores)
  final ValueChanged<String> alPerderFoco;

  /// Callback que se llama en tiempo real al cambiar el texto (sin mostrar errores).
  /// Permite al botón Continuar habilitarse mientras el usuario tipea.
  final ValueChanged<String>? alCambiar;

  /// Mensaje de error externo, controlado por el proveedor de estado
  final String? textoError;

  const NumericFieldWidget({
    super.key,
    required this.label,
    required this.unidad,
    required this.placeholder,
    required this.alPerderFoco,
    this.alCambiar,
    this.aceptaDecimales = false,
    this.textoError,
  });

  @override
  State<NumericFieldWidget> createState() => _NumericFieldWidgetState();
}

class _NumericFieldWidgetState extends State<NumericFieldWidget> {
  // Controlador del campo de texto para leer su valor cuando sea necesario
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador vacío al arrancar el widget
    _controlador = TextEditingController();
  }

  @override
  void dispose() {
    // Liberamos los recursos del controlador para evitar fugas de memoria
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de la sección del campo
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        // Campo de texto con unidad de medida superpuesta a la derecha
        TextFormField(
          controller: _controlador,
          // Abrimos el teclado numérico, con o sin teclado decimal según el campo
          keyboardType: TextInputType.numberWithOptions(
            decimal: widget.aceptaDecimales,
          ),
          // Filtramos la entrada para aceptar solo dígitos (y punto si es decimal)
          inputFormatters: [
            widget.aceptaDecimales
                ? FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          // Llamamos al callback silencioso en tiempo real para habilitar el botón
          onChanged: (texto) => widget.alCambiar?.call(texto),
          onEditingComplete: () => widget.alPerderFoco(_controlador.text),
          onTapOutside: (_) {
            // Disparamos la validación al tocar fuera del campo
            FocusScope.of(context).unfocus();
            widget.alPerderFoco(_controlador.text);
          },
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                fontSize: 18,
              ),
          // Personalizamos la decoración para mostrar la unidad a la derecha
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: AppColors.placeholderText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            // Ícono de sufijo con la unidad de medida
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                widget.unidad,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.placeholderText,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            // Mostramos el border rojo de error si hay mensaje de error
            errorText: widget.textoError,
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
