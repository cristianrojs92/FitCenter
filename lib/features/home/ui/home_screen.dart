import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logout_dialog.dart';
import '../logic/home_provider.dart';
import '../../onboarding/ui/onboarding_step1_screen.dart';
import 'widgets/calorie_ring_widget.dart';
import 'widgets/navigation_bar_widget.dart';
import 'widgets/meal_timeline_widget.dart';
import 'widgets/quick_log_bottom_sheet.dart';
import 'widgets/macro_cards_widget.dart';

/// Pantalla principal del Dashboard de DietX.
/// Orquesta todos los widgets del home: anillo de calorías, macros,
/// línea de tiempo de meals y la barra de navegación con FAB.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasNavigatedToOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos nutricionales del día actual cuando se monta la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      provider.loadDailyNutrition(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos cambios en el provider para detectar cuando las metas están incompletas
    final provider = context.watch<HomeProvider>();
    
    // Verificamos si las metas están incompletas después de que se carguen los datos
    // Solo verificamos si no estamos cargando, hay datos cargados, las metas están incompletas, y aún no hemos navegado
    if (!provider.isLoading && 
        provider.hasNutritionData &&
        provider.hasIncompleteGoals && 
        !_hasNavigatedToOnboarding) {
      // Marcamos que ya navegamos para evitar múltiples navegaciones
      _hasNavigatedToOnboarding = true;
      
      // Esperamos al siguiente frame para asegurar que el contexto esté listo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        // Navegamos al onboarding usando pushReplacement para evitar volver atrás
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OnboardingStep1Screen(),
          ),
        );
      });
    }

    return Scaffold(
      // Fondo coherente con el tema general de la app
      backgroundColor: AppColors.background,
      // Barra de navegación inferior con el FAB central de registro
      bottomNavigationBar: const NavigationBarWidget(),
      body: CustomScrollView(
        // Usamos CustomScrollView para el efecto de scroll con header fijo
        slivers: [
          // AppBar que se reduce al hacer scroll con el name del día
          _AppBarHome(),
          // Contenido principal con padding lateral consistente
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                // Anillo circular de calorías del día
                const CalorieRingWidget(),
                const SizedBox(height: 24),
                // Tarjetas de progreso de macros diarios
                const MacroCardsWidget(),
                const SizedBox(height: 24),
                // Lista de meals del día con sus ítems registrados
                MealTimelineWidget(
                  onPressedAnadir: (type) =>
                      QuickLogBottomSheet.mostrarDesdeComida(
                    context,
                    type,
                  ),
                ),
                // Espacio inferior para que el último elemento no quede bajo el FAB
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar del home con avatar del usuario y fecha del día con navegación
class _AppBarHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // El AppBar se mantiene visible al hacer scroll (sticky header)
      floating: true,
      snap: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      elevation: 0,
      // Borde inferior sutil para separarlo del contenido
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.softPrimary),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar del usuario a la izquierda
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.softPrimary,
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          // Fecha del día con navegación entre días
          _SelectorFecha(),
          // Botón de logout a la derecha
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.secondaryText,
            ),
            onPressed: () => mostrarDialogoCerrarSesion(context),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

/// Selector de fecha del día con flechas de navegación izquierda y derecha
class _SelectorFecha extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón para ir al día anterior
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.secondaryText,
          ),
          onPressed: () {},
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        // Fecha del día en formato legible
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HOY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
            ),
            Text(
              'Octubre 24',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
            ),
          ],
        ),
        // Botón para ir al día siguiente
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: AppColors.secondaryText,
          ),
          onPressed: () {},
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}
