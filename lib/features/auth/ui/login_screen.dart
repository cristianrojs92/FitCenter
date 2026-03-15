import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/auth_provider.dart';
import 'widgets/login_widgets.dart';
import '../../onboarding/ui/onboarding_step1_screen.dart';
import '../../home/ui/home_screen.dart';

/// Pantalla de autenticación y acceso (US-00).
/// Es el punto de entrada de la app para usuarios nuevos y recurrentes.
/// Ofrece inicio de sesión por email+contraseña, Google y Apple.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// Maneja la navegación post-autenticación según si el usuario es nuevo o existente
  void _navegar(BuildContext context, bool esNuevo) {
    if (esNuevo) {
      // El usuario es nuevo: lo enviamos al formulario de onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingStep1Screen()),
      );
    } else {
      // El usuario ya existe con datos físicos: lo llevamos al Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Proveemos el AuthProvider al árbol de esta pantalla
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // Padding horizontal que encuadra el contenido del formulario de login
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card blanca con todo el contenido del login
                  _TarjetaLogin(alNavegar: _navegar),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta contenedora del formulario de login con esquinas redondeadas y sombra
class _TarjetaLogin extends StatelessWidget {
  /// Callback que recibe si el usuario es nuevo para navegar a la pantalla correcta
  final void Function(BuildContext context, bool esNuevo) alNavegar;

  const _TarjetaLogin({required this.alNavegar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Sombra sutil para dar profundidad a la tarjeta de login
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de logo, título y propuesta de valor
          const LogoAppWidget(),
          const SizedBox(height: 24),
          const _EncabezadoModoAuth(),
          const SizedBox(height: 24),
          // Campo de email electrónico con validación
          const CampoEmailWidget(),
          const SizedBox(height: 14),
          // Campo de contraseña para login clásico con Supabase
          const CampoContrasenaWidget(),
          const _CampoConfirmarContrasena(),
          // Acción para recuperación de contraseña por email
          const _BotonRecuperarContrasena(),
          const SizedBox(height: 4),
          // Botón principal de autenticación con email y contraseña
          BotonAutenticacionWidget(
            alIniciarSesionExitoso: () => alNavegar(context, false),
          ),
          const SizedBox(height: 14),
          const CambioModoAuthWidget(),
          const SizedBox(height: 14),
          // Banner de error del servidor (visible solo si hubo error de red o Supabase)
          _BannerErrorServidor(),
          // Banner de feedback informativo para recuperación de contraseña
          _BannerInformacion(),
          _OpcionesSociales(alNavegar: alNavegar),
          const SizedBox(height: 20),
          // Footer con los términos y política de privacidad
          const _FooterTerminos(),
        ],
      ),
    );
  }
}

/// Encabezado corto que aclara si el formulario está en login o registro.
class _EncabezadoModoAuth extends StatelessWidget {
  const _EncabezadoModoAuth();

  @override
  Widget build(BuildContext context) {
    final isSignUpMode =
        context.select<AuthProvider, bool>((p) => p.isSignUpMode);

    return Column(
      children: [
        Text(
          isSignUpMode ? 'Crea tu cuenta' : 'Inicia sesión',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUpMode
              ? 'Regístrate con tu email y contraseña para empezar tu onboarding.'
              : 'Accede con tu cuenta para continuar donde lo dejaste.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

/// Muestra el campo de confirmar contraseña solo en modo registro.
class _CampoConfirmarContrasena extends StatelessWidget {
  const _CampoConfirmarContrasena();

  @override
  Widget build(BuildContext context) {
    final isSignUpMode =
        context.select<AuthProvider, bool>((p) => p.isSignUpMode);
    if (!isSignUpMode) return const SizedBox.shrink();

    return const Column(
      children: [
        SizedBox(height: 14),
        CampoConfirmarContrasenaWidget(),
      ],
    );
  }
}

/// Muestra la recuperación de contraseña solo durante el login.
class _BotonRecuperarContrasena extends StatelessWidget {
  const _BotonRecuperarContrasena();

  @override
  Widget build(BuildContext context) {
    final isSignUpMode =
        context.select<AuthProvider, bool>((p) => p.isSignUpMode);
    if (isSignUpMode) return const SizedBox.shrink();
    return const BotonRecuperarContrasenaWidget();
  }
}

/// Muestra el banner informativo cuando se completa una acción no crítica.
class _BannerInformacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Escuchamos solo el mensaje informativo para evitar rebuilds innecesarios
    final infoMessage =
        context.select<AuthProvider, String?>((p) => p.infoMessage);
    if (infoMessage == null) return const SizedBox.shrink();
    return Column(
      children: [
        BannerInformativoWidget(mensaje: infoMessage),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Muestra el banner de error del servidor cuando Supabase retorna un AuthException
class _BannerErrorServidor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Escuchamos solo el mensaje de error para redibujar solo cuando cambie
    final errorMessage =
        context.select<AuthProvider, String?>((p) => p.errorMessage);
    if (errorMessage == null) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Agrupa las opciones sociales solo cuando el usuario está en login.
class _OpcionesSociales extends StatelessWidget {
  final void Function(BuildContext context, bool esNuevo) alNavegar;

  const _OpcionesSociales({required this.alNavegar});

  @override
  Widget build(BuildContext context) {
    final isSignUpMode =
        context.select<AuthProvider, bool>((p) => p.isSignUpMode);
    if (isSignUpMode) return const SizedBox.shrink();

    return Column(
      children: [
        _Divisor(),
        BotonGoogleWidget(
          alAutenticar: (esNuevo) => alNavegar(context, esNuevo),
        ),
        const SizedBox(height: 12),
        BotonAppleWidget(
          alAutenticar: (esNuevo) => alNavegar(context, esNuevo),
        ),
      ],
    );
  }
}



/// Divisor horizontal con texto "O de forma más rápida" en el centro
class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Línea izquierda del divisor
          const Expanded(child: Divider(color: AppColors.border)),
          // Texto central del divisor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'O de forma más rápida',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          // Línea derecha del divisor
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}

/// Footer con los textos legales de términos y política de privacidad
class _FooterTerminos extends StatelessWidget {
  const _FooterTerminos();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Al continuar, aceptas nuestros ',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w400,
            ),
        children: [
          // Enlace de Términos en texto más oscuro y subrayado
          TextSpan(
            text: 'Términos',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' y '),
          // Enlace de Política de Privacidad en texto más oscuro y subrayado
          TextSpan(
            text: 'Política de Privacidad',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
