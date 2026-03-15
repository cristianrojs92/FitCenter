import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/home_provider.dart';

/// Bottom Sheet de registro rápido de meals con texto libre o escáner.
/// Se muestra como un modal que emerge desde abajo con un input de texto
/// y un botón para analizar los macros mediante IA.
class QuickLogBottomSheet extends StatefulWidget {
  const QuickLogBottomSheet({super.key});

  /// Abre el Bottom Sheet de registro pre-seleccionando el type de comida por hora
  static Future<void> mostrarDesdeBotonCentral(BuildContext context) {
    // Notificamos al proveedor para que detecte la comida por hora antes de abrir
    context.read<HomeProvider>().openQuickLogFromCenterButton();
    return mostrar(context);
  }

  /// Abre el Bottom Sheet preseleccionando el type de comida específico
  static Future<void> mostrarDesdeComida(
    BuildContext context,
    MealType type,
  ) {
    // Notificamos con el type de comida que originó la apertura
    context.read<HomeProvider>().openQuickLogFromMeal(type);
    return mostrar(context);
  }

  /// Método interno que muestra el ModalBottomSheet con configuración estándar
  static Future<void> mostrar(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      // Usamos el builder con un Provider para mantener el contexto del proveedor
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<HomeProvider>(),
        child: const QuickLogBottomSheet(),
      ),
      // Permitimos que el sheet sea de altura variable según el teclado
      isScrollControlled: true,
      // Esquinas redondeadas en la parte superior del modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
    );
  }

  @override
  State<QuickLogBottomSheet> createState() =>
      _QuickLogBottomSheetState();
}

class _QuickLogBottomSheetState
    extends State<QuickLogBottomSheet> {
  // Controlador del campo de texto para acceder a su contenido
  late final TextEditingController _controladorTexto;

  // FocusNode para hacer auto-focus al abrir el sheet
  late final FocusNode _focoTexto;

  // Indica si el botón Analizar debe estar habilitado
  bool _textoTieneContenido = false;

  // Indica si la IA está procesando el texto ingresado
  bool _isLoading = false;

  // Indica si la IA terminó y se muestran los resultados
  bool _muestraResultado = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador vacío
    _controladorTexto = TextEditingController();
    // Creamos el nodo de foco para controlar cuándo aparece el teclado
    _focoTexto = FocusNode();
    // Escuchamos cambios en el texto para habilitar/deshabilitar el botón
    _controladorTexto.addListener(_alCambiarTexto);
    // Auto-focus: desplegamos el teclado al abrir el sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focoTexto.requestFocus();
    });
  }

  /// Actualiza el estado de habilitación del botón según si hay texto ingresado
  void _alCambiarTexto() {
    final tieneTexto = _controladorTexto.text.trim().isNotEmpty;
    if (tieneTexto != _textoTieneContenido) {
      setState(() => _textoTieneContenido = tieneTexto);
    }
  }

  /// Simula el procesamiento de IA al presionar Analizar
  Future<void> _analizarTexto() async {
    // Ocultamos el teclado antes de mostrar el estado de carga
    _focoTexto.unfocus();
    setState(() => _isLoading = true);
    // Simulamos una espera de red de 1.5 segundos para el modo de demostración
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      // Mostramos los resultados simulados tras la "respuesta" de la IA
      setState(() {
        _isLoading = false;
        _muestraResultado = true;
      });
    }
  }

  /// Confirma el registro del alimento y cierra el sheet
  void _confirmarYGuardar() {
    final proveedor = context.read<HomeProvider>();
    // Creamos un ítem simulado con los datos del texto ingresado
    proveedor.addFoodItem(
      const FoodItemModel(name: 'Pollo con arroz', calories: 480),
      proveedor.selectedMealType,
    );
    // Cerramos el Bottom Sheet con una animación hacia abajo
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Liberamos todos los recursos para evitar fugas de memoria
    _controladorTexto.dispose();
    _focoTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Padding inferior para que el campo de texto no quede oculto bajo el teclado
    final paddingTeclado = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: paddingTeclado),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador visual de arrastre del bottom sheet
              _IndicadorArrastre(),
              const SizedBox(height: 16),
              // Selector de comida con pills para elegir en cuál guardar
              _SelectorComidaPills(),
              const SizedBox(height: 20),
              // Si estamos mostrando resultados de IA, mostramos el resumen
              if (_muestraResultado) ...[
                _ResumenIA(alConfirmar: _confirmarYGuardar),
              ] else if (_isLoading) ...[
                // Estado de carga con shimmer mientras la IA procesa
                _EstadoCargando(),
              ] else ...[
                // Campo de texto de entrada libre y botón de acción
                _CampoTextoLibre(
                  controlador: _controladorTexto,
                  foco: _focoTexto,
                  textoTieneContenido: _textoTieneContenido,
                  alAnalizar: _analizarTexto,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicador visual en la parte superior del sheet para indicar que puede arrastrarse
class _IndicadorArrastre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

/// Pills horizontales para seleccionar en qué comida guardar el registro
class _SelectorComidaPills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Leemos el type de comida seleccionado del proveedor
    final typeSeleccionado =
        context.watch<HomeProvider>().selectedMealType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Añadir a',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        const SizedBox(height: 10),
        // Fila de pills de comida con scroll horizontal si no caben
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MealType.values.map((type) {
              final isSelected = type == typeSeleccionado;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => context
                      .read<HomeProvider>()
                      .selectMealType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      // Fondo verde si está seleccionado, gris si no
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondaryBackground,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      type.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? AppColors.primaryText
                                : AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Campo de texto libre y botón de acción para analizar con IA
class _CampoTextoLibre extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode foco;
  final bool textoTieneContenido;
  final VoidCallback alAnalizar;

  const _CampoTextoLibre({
    required this.controlador,
    required this.foco,
    required this.textoTieneContenido,
    required this.alAnalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo de texto
        Text(
          'Describe tu comida',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        // Área de texto con el placeholder educativo
        TextField(
          controller: controlador,
          focusNode: foco,
          maxLines: 4,
          minLines: 3,
          // Texto de ayuda que educa al usuario sobre cómo usar el campo
          decoration: InputDecoration(
            hintText:
                'Ej: 200g de pechuga de pollo con 150g de arroz blanco...',
            hintStyle: TextStyle(
              color: AppColors.placeholderText,
              fontSize: 14,
            ),
            // Botón de escáner dentro del campo como sufijo
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.primary,
                size: 26,
              ),
              tooltip: 'Escanear código de barras',
              // Por ahora muestra un mensaje informativo al presionar el escáner
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Escáner disponible en la siguiente versión'),
                ),
              ),
            ),
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.all(16),
          ),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        // Botón de acción que se habilita cuando hay texto
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // Habilitamos el botón solo cuando el campo tiene contenido
            onPressed: textoTieneContenido ? alAnalizar : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.disabledButton,
              foregroundColor: AppColors.primaryText,
              disabledForegroundColor: AppColors.disabledButtonText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            // Ícono de destello para indicar que la IA procesará el texto
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(
              'Analizar con IA',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Estado de carga mientras la IA procesa el texto ingresado
class _EstadoCargando extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Indicador circular de progreso con el color primary
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          // Texto descriptivo del proceso en curso
          Text(
            'Calculando macros...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
        ],
      ),
    );
  }
}

/// Resumen simulado de los resultados de la IA tras analizar el texto
class _ResumenIA extends StatelessWidget {
  final VoidCallback alConfirmar;

  const _ResumenIA({required this.alConfirmar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del resumen detectado
        Text(
          'Macros detectados',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        // Tarjeta con el resumen del alimento detectado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // Nombre del alimento detectado por la IA
              _FilaResumen(
                label: 'Pechuga de pollo (200g)',
                valor: '330 kcal',
              ),
              const Divider(height: 16),
              // Macros desglosados del alimento
              _FilaResumen(label: 'Proteína', valor: '62g'),
              _FilaResumen(label: 'Carbohidratos', valor: '0g'),
              _FilaResumen(label: 'Grasas', valor: '7g'),
              const Divider(height: 16),
              // Fila total del resumen en negrita
              _FilaResumen(
                label: 'Arroz blanco (150g)',
                valor: '150 kcal',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Botón de confirmación para guardar el registro
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: alConfirmar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Confirmar y Guardar',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila de resumen con label y valor alineados a los extremos
class _FilaResumen extends StatelessWidget {
  final String label;
  final String valor;

  const _FilaResumen({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre del campo en color secundario
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          // Valor en negrita a la derecha
          Text(
            valor,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
          ),
        ],
      ),
    );
  }
}
