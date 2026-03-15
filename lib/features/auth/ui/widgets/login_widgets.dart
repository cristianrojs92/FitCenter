import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/auth_provider.dart';

/// Widget que muestra el logo y name de la aplicación DietX.
/// Se ubica en la parte superior de la pantalla de login.
class LogoAppWidget extends StatelessWidget {
  const LogoAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila con el ícono del logo y el name de la app
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor cuadrado redondeado con background verde suave para el ícono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            // Nombre de la app en texto grande y negrita
            Text(
              'DietX',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Título principal de la propuesta de valor
        Text(
          'Tu nutrición en\npiloto automático',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 12),
        // Subtítulo descriptivo del valor de la app
        Text(
          'Registra tus meals con IA y alcanza tus metas\nde nutrición sin esfuerzo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

/// Campo de email con ícono de sobre y validación de formato.
/// Muestra el error debajo del campo cuando el formato es inválido.
class CampoEmailWidget extends StatelessWidget {
  const CampoEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos solo el error del email para redibujar solo cuando sea necesario
    final emailError = context.select<AuthProvider, String?>(
      (p) => p.emailError,
    );
    final proveedor = context.read<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto con ícono de sobre al inicio
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            // Borde rojo sutil cuando hay error de validación
            border: Border.all(
              color: emailError != null ? AppColors.error : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Ícono de sobre a la izquierda del campo
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.mail_outline,
                  color: emailError != null
                      ? AppColors.error
                      : AppColors.placeholderText,
                  size: 22,
                ),
              ),
              // Campo de texto principal para el email
              Expanded(
                child: TextField(
                  onChanged: proveedor.updateEmail,
                  onEditingComplete: proveedor.validateEmail,
                  onTapOutside: (_) => proveedor.validateEmail(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Tu email electrónico',
                    hintStyle: const TextStyle(
                      color: AppColors.placeholderText,
                      fontSize: 15,
                    ),
                    // Quitamos el border del TextField porque decoramos el Container
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Mensaje de error de validación debajo del campo
        if (emailError != null) ...[
          const SizedBox(height: 6),
          Text(
            emailError,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Campo de contraseña con control de visibilidad y feedback de validación.
class CampoContrasenaWidget extends StatelessWidget {
  const CampoContrasenaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el error para actualizar solo cuando cambie el feedback del campo
    final passwordError = context.select<AuthProvider, String?>(
      (p) => p.passwordError,
    );
    // Escuchamos el estado de visibilidad para pintar el icon y obscureText
    final isPasswordHidden = context.select<AuthProvider, bool>(
      (p) => p.isPasswordHidden,
    );
    final isSignUpMode = context.select<AuthProvider, bool>(
      (p) => p.isSignUpMode,
    );
    // Leemos la instancia para invocar callbacks de actualización/validación
    final proveedor = context.read<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de contraseña con ícono de candado y botón de visibilidad
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: passwordError != null
                  ? AppColors.error
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Ícono de candado a la izquierda del campo
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.lock_outline,
                  color: passwordError != null
                      ? AppColors.error
                      : AppColors.placeholderText,
                  size: 22,
                ),
              ),
              // Campo de texto principal para la contraseña
              Expanded(
                child: TextField(
                  onChanged: proveedor.updatePassword,
                  onEditingComplete: proveedor.validatePassword,
                  onTapOutside: (_) => proveedor.validatePassword(),
                  obscureText: isPasswordHidden,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: isSignUpMode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Tu contraseña',
                    hintStyle: const TextStyle(
                      color: AppColors.placeholderText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    // Ícono para ocultar/mostrar contraseña dentro del campo
                    suffixIcon: IconButton(
                      onPressed: proveedor.togglePasswordVisibility,
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Mensaje de error debajo del campo cuando la validación falla
        if (passwordError != null) ...[
          const SizedBox(height: 6),
          Text(
            passwordError,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Campo de confirmar contraseña visible solo durante el registro.
class CampoConfirmarContrasenaWidget extends StatelessWidget {
  const CampoConfirmarContrasenaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final confirmPasswordError = context.select<AuthProvider, String?>(
      (p) => p.confirmPasswordError,
    );
    final isPasswordHidden = context.select<AuthProvider, bool>(
      (p) => p.isPasswordHidden,
    );
    final proveedor = context.read<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: confirmPasswordError != null
                  ? AppColors.error
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.lock_clock_outlined,
                  color: confirmPasswordError != null
                      ? AppColors.error
                      : AppColors.placeholderText,
                  size: 22,
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: proveedor.updateConfirmPassword,
                  onEditingComplete: proveedor.validateConfirmPassword,
                  onTapOutside: (_) => proveedor.validateConfirmPassword(),
                  obscureText: isPasswordHidden,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Confirma tu contraseña',
                    hintStyle: const TextStyle(
                      color: AppColors.placeholderText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: proveedor.togglePasswordVisibility,
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (confirmPasswordError != null) ...[
          const SizedBox(height: 6),
          Text(
            confirmPasswordError,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Botón principal de autenticación para login o registro.
class BotonAutenticacionWidget extends StatelessWidget {
  /// Callback ejecutado cuando el login se completa exitosamente.
  final VoidCallback alIniciarSesionExitoso;

  const BotonAutenticacionWidget({
    super.key,
    required this.alIniciarSesionExitoso,
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos estado del proveedor para pintar spinner y estado del botón
    final proveedor = context.watch<AuthProvider>();
    final isSignUpMode = proveedor.isSignUpMode;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        // Enviamos el formulario y navegamos solo si el login responde éxito.
        onPressed: proveedor.isLoading
            ? null
            : () async {
                final exito = isSignUpMode
                    ? await proveedor.signUpWithEmailAndPassword()
                    : await proveedor.signInWithEmailAndPassword();
                if (exito && context.mounted) {
                  if (!isSignUpMode) {
                    alIniciarSesionExitoso();
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.disabledButton,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.disabledButtonText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        // Mostramos spinner cuando hay autenticación en curso
        icon: proveedor.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isSignUpMode ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                size: 18,
              ),
        label: Text(
          proveedor.isLoading
              ? (isSignUpMode ? 'Creando cuenta...' : 'Iniciando...')
              : (isSignUpMode ? 'Crear cuenta' : 'Iniciar sesión'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Alterna entre el flujo de login y el de registro.
class CambioModoAuthWidget extends StatelessWidget {
  const CambioModoAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isSignUpMode = context.select<AuthProvider, bool>(
      (p) => p.isSignUpMode,
    );
    final proveedor = context.read<AuthProvider>();

    return Center(
      child: TextButton(
        onPressed: () => proveedor.setFormMode(
          isSignUpMode ? AuthFormMode.signIn : AuthFormMode.signUp,
        ),
        child: Text.rich(
          TextSpan(
            text: isSignUpMode ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: isSignUpMode ? 'Inicia sesión' : 'Crear cuenta',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Botón de texto para enviar email de recuperación de contraseña.
class BotonRecuperarContrasenaWidget extends StatelessWidget {
  const BotonRecuperarContrasenaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos la bandera de carga para evitar dobles envíos del email
    final isLoading =
        context.select<AuthProvider, bool>((p) => p.isLoading);
    // Leemos la instancia para ejecutar la acción al presionar el botón
    final proveedor = context.read<AuthProvider>();

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        // Disparamos recuperación solo si no hay request en curso
        onPressed: isLoading ? null : proveedor.recoverPasswordWithEmail,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryText,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Olvidé mi contraseña',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Banner de feedback informativo para eventos no críticos de autenticación.
class BannerInformativoWidget extends StatelessWidget {
  /// Mensaje que se mostrará dentro del banner.
  final String mensaje;

  const BannerInformativoWidget({
    super.key,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Ícono informativo para indicar acción completada
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Mensaje de confirmación de la acción de recuperación
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de inicio de sesión con Google con su logotype como ícono.
class BotonGoogleWidget extends StatelessWidget {
  /// Callback que se ejecuta al completar la autenticación con Google
  final void Function(bool esNuevo) alAutenticar;

  const BotonGoogleWidget({super.key, required this.alAutenticar});

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<AuthProvider>();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: proveedor.isLoading
            ? null
            : () async {
                // Llamamos al método simulado de Google OAuth
                final esNuevo = await proveedor.continueWithGoogle();
                // Navegamos según si el usuario es nuevo o ya existe
                if (context.mounted) alAutenticar(esNuevo);
              },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          backgroundColor: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo usando colores semánticos
            const _LogoGoogle(),
            const SizedBox(width: 12),
            Text(
              'Continuar con Google',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo de Google dibujado con texto colorido siguiendo las guidelines de branding.
class _LogoGoogle extends StatelessWidget {
  const _LogoGoogle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

/// Painter que dibuja la "G" de Google en sus colores oficiales.
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radio = size.width / 2;
    final centro = Offset(radio, radio);

    // Dibujamos cuatro cuartos del círculo con los colores de Google
    final sectores = [
      const Color(0xFF4285F4), // Azul (superior derecho)
      const Color(0xFF34A853), // Verde (inferior derecho)
      const Color(0xFFFBBC05), // Amarillo (inferior izquierdo)
      const Color(0xFFEA4335), // Rojo (superior izquierdo)
    ];

    for (int i = 0; i < sectores.length; i++) {
      final pintura = Paint()
        ..color = sectores[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        (i * 3.14159 / 2) - 3.14159 / 4,
        3.14159 / 2,
        true,
        pintura,
      );
    }

    // Tapamos el centro con blanco para crear el efecto de la "G"
    canvas.drawCircle(centro, radio * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter antiguo) => false;
}

/// Botón de inicio de sesión con Apple con background negro.
class BotonAppleWidget extends StatelessWidget {
  /// Callback que se ejecuta al completar la autenticación con Apple
  final void Function(bool esNuevo) alAutenticar;

  const BotonAppleWidget({super.key, required this.alAutenticar});

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<AuthProvider>();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: proveedor.isLoading
            ? null
            : () async {
                // Llamamos al método simulado de Apple OAuth
                final esNuevo = await proveedor.continueWithApple();
                // Navegamos según si el usuario es nuevo o ya existe
                if (context.mounted) alAutenticar(esNuevo);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de Apple (usamos el ícono de iOS como referencia)
            const Icon(Icons.apple, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Continuar con Apple',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
