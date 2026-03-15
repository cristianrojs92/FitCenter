import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado del flujo de autenticación del usuario.
enum AuthStatus {
  /// Estado inicial: el usuario no ha realizado acciones.
  initial,

  /// Estado de carga mientras se ejecuta una petición de autenticación.
  loading,

  /// Estado de éxito al completar el login correctamente.
  authenticated,

  /// Estado informativo cuando se envía el email de recuperación.
  recoverySent,

  /// Estado informativo cuando la cuenta se crea y queda pendiente de confirmar.
  signUpEmailSent,

  /// Estado de error de negocio o red.
  error,
}

/// Modo visual del formulario de autenticación.
enum AuthFormMode { signIn, signUp }

/// Proveedor de estado para la pantalla de autenticación con email+contraseña.
class AuthProvider extends ChangeNotifier {
  /// Cliente de Supabase compartido para ejecutar autenticación.
  final GoTrueClient _auth = Supabase.instance.client.auth;

  /// Correo electrónico ingresado por el usuario en el formulario.
  String _email = '';

  /// Contraseña ingresada por el usuario en el formulario.
  String _password = '';

  /// Confirmación de contraseña usada en el registro.
  String _confirmPassword = '';

  /// Error de validación del campo email.
  String? _emailError;

  /// Error de validación del campo contraseña.
  String? _passwordError;

  /// Error de validación del campo confirmar contraseña.
  String? _confirmPasswordError;

  /// Estado actual del flujo de autenticación.
  AuthStatus _estado = AuthStatus.initial;

  /// Mensaje de error que proviene de Supabase o de conectividad.
  String? _errorMessage;

  /// Mensaje informativo no crítico (ej. recuperación enviada).
  String? _infoMessage;

  /// Controla la visibilidad del campo de contraseña.
  bool _isPasswordHidden = true;

  /// Controla si la UI está mostrando login o registro.
  AuthFormMode _formMode = AuthFormMode.signIn;

  /// Expone el email para los widgets de UI.
  String get email => _email;

  /// Expone la contraseña para los widgets de UI.
  String get password => _password;

  /// Expone la confirmación de contraseña para los widgets de UI.
  String get confirmPassword => _confirmPassword;

  /// Expone el error de email para renderizar feedback de validación.
  String? get emailError => _emailError;

  /// Expone el error de contraseña para renderizar feedback de validación.
  String? get passwordError => _passwordError;

  /// Expone el error de confirmación de contraseña.
  String? get confirmPasswordError => _confirmPasswordError;

  /// Expone el estado actual del flujo de autenticación.
  AuthStatus get estado => _estado;

  /// Expone el último mensaje de error para mostrar en banner.
  String? get errorMessage => _errorMessage;

  /// Expone el último mensaje informativo para mostrar en banner.
  String? get infoMessage => _infoMessage;

  /// Expone si la contraseña está oculta para alternar el ícono del ojo.
  bool get isPasswordHidden => _isPasswordHidden;

  /// Expone el modo visual actual del formulario.
  AuthFormMode get formMode => _formMode;

  /// Retorna true cuando existe una petición de red en curso.
  bool get isLoading => _estado == AuthStatus.loading;

  /// Retorna true cuando la recuperación de contraseña fue enviada.
  bool get recoverySent => _estado == AuthStatus.recoverySent;

  /// Retorna true cuando el registro terminó y falta confirmar el email.
  bool get signUpEmailSent => _estado == AuthStatus.signUpEmailSent;

  /// Retorna true si el formulario está en modo registro.
  bool get isSignUpMode => _formMode == AuthFormMode.signUp;

  /// Retorna true cuando el email tiene formato válido.
  bool get isEmailValid =>
      _email.isNotEmpty && _emailError == null && _isEmailValidFormat(_email);

  /// Retorna true cuando la contraseña cumple validación mínima.
  bool get isPasswordValid =>
      _password.isNotEmpty &&
      _passwordError == null &&
      _password.length >= 6;

  /// Retorna true cuando la confirmación coincide con la contraseña.
  bool get isConfirmPasswordValid =>
      _confirmPassword.isNotEmpty &&
      _confirmPasswordError == null &&
      _confirmPassword == _password;

  /// Retorna true cuando el formulario completo está listo para enviar.
  bool get isFormValid =>
      isEmailValid &&
      isPasswordValid &&
      (!isSignUpMode || isConfirmPasswordValid);

  /// Actualiza el email en tiempo real y limpia errores obsoletos.
  void updateEmail(String value) {
    _email = value.trim();
    if (_emailError != null && _isEmailValidFormat(_email)) {
      _emailError = null;
    }
    _clearTransientMessages();
    notifyListeners();
  }

  /// Actualiza la contraseña en tiempo real y limpia errores obsoletos.
  void updatePassword(String value) {
    _password = value;
    if (_passwordError != null && _password.length >= 6) {
      _passwordError = null;
    }
    if (_confirmPasswordError != null && _confirmPassword == _password) {
      _confirmPasswordError = null;
    }
    _clearTransientMessages();
    notifyListeners();
  }

  /// Actualiza la confirmación de contraseña en tiempo real.
  void updateConfirmPassword(String value) {
    _confirmPassword = value;
    if (_confirmPasswordError != null && _confirmPassword == _password) {
      _confirmPasswordError = null;
    }
    _clearTransientMessages();
    notifyListeners();
  }

  /// Alterna la visibilidad del campo de contraseña en UI.
  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  /// Cambia entre login y registro limpiando feedback obsoleto.
  void setFormMode(AuthFormMode mode) {
    if (_formMode == mode) return;
    _formMode = mode;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _clearTransientMessages();
    notifyListeners();
  }

  /// Valida el email al perder foco o antes de enviar.
  void validateEmail() {
    if (_email.isEmpty) {
      _emailError = 'Ingresa tu email electrónico';
    } else if (!_isEmailValidFormat(_email)) {
      _emailError = 'Formato de email inválido';
    } else {
      _emailError = null;
    }
    notifyListeners();
  }

  /// Valida la contraseña al perder foco o antes de enviar.
  void validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Ingresa tu contraseña';
    } else if (_password.length < 6) {
      _passwordError = 'La contraseña debe tener al menos 6 caracteres';
    } else {
      _passwordError = null;
    }
    notifyListeners();
  }

  /// Valida la confirmación de contraseña antes de registrar al usuario.
  void validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirma tu contraseña';
    } else if (_confirmPassword != _password) {
      _confirmPasswordError = 'Las contraseñas no coinciden';
    } else {
      _confirmPasswordError = null;
    }
    notifyListeners();
  }

  /// Inicia sesión con email+contraseña usando Supabase Auth.
  Future<bool> signInWithEmailAndPassword() async {
    validateEmail();
    validatePassword();
    if (!isFormValid) {
      return false;
    }

    _estado = AuthStatus.loading;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithPassword(
        email: _email,
        password: _password,
      );
      _estado = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _estado = AuthStatus.error;
      _errorMessage = _mapAuthErrorMessage(error.message);
    } catch (_) {
      _estado = AuthStatus.error;
      _errorMessage = 'Error de conexión. Intenta nuevamente.';
    }

    notifyListeners();
    return false;
  }

  /// Crea una cuenta con email+contraseña y solicita confirmación por correo.
  Future<bool> signUpWithEmailAndPassword() async {
    validateEmail();
    validatePassword();
    validateConfirmPassword();
    if (!isFormValid) {
      return false;
    }

    _estado = AuthStatus.loading;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final response = await _auth.signUp(
        email: _email,
        password: _password,
      );

      // Si el proyecto no exige confirmación, evitamos dejar la app en un
      // estado inesperado y mantenemos el mismo flujo manual de acceso.
      if (response.session != null) {
        await _auth.signOut();
      }

      _estado = AuthStatus.signUpEmailSent;
      _infoMessage =
          'Cuenta creada. Revisa tu correo para confirmar tu email antes de iniciar sesión.';
      _formMode = AuthFormMode.signIn;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _estado = AuthStatus.error;
      _errorMessage = _mapAuthErrorMessage(error.message);
    } catch (_) {
      _estado = AuthStatus.error;
      _errorMessage = 'Error de conexión. Intenta nuevamente.';
    }

    notifyListeners();
    return false;
  }

  /// Envía email de recuperación para que el usuario cree/restablezca contraseña.
  Future<void> recoverPasswordWithEmail() async {
    validateEmail();
    if (!isEmailValid) {
      return;
    }

    _estado = AuthStatus.loading;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await _auth.resetPasswordForEmail(_email);
      _estado = AuthStatus.recoverySent;
      _infoMessage =
          'Te enviamos un email para restablecer tu contraseña.';
    } on AuthException catch (error) {
      _estado = AuthStatus.error;
      _errorMessage = _mapAuthErrorMessage(error.message);
    } catch (_) {
      _estado = AuthStatus.error;
      _errorMessage = 'Error de conexión. Intenta nuevamente.';
    }

    notifyListeners();
  }

  /// Simula el inicio de sesión con Google OAuth.
  Future<bool> continueWithGoogle() async {
    _estado = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _estado = AuthStatus.initial;
    notifyListeners();
    return true;
  }

  /// Simula el inicio de sesión con Apple OAuth.
  Future<bool> continueWithApple() async {
    _estado = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _estado = AuthStatus.initial;
    notifyListeners();
    return true;
  }

  /// Limpia mensajes de estado para evitar feedback viejo al editar campos.
  void _clearTransientMessages() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
    if (_infoMessage != null) {
      _infoMessage = null;
    }
    if (_estado == AuthStatus.error ||
        _estado == AuthStatus.recoverySent ||
        _estado == AuthStatus.signUpEmailSent) {
      _estado = AuthStatus.initial;
    }
  }

  /// Valida formato de email con expresión regular básica.
  bool _isEmailValidFormat(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  /// Traduce mensajes comunes de Supabase a mensajes claros para la UI.
  String _mapAuthErrorMessage(String originalMessage) {
    final normalizedMessage = originalMessage.toLowerCase();

    if (normalizedMessage.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (normalizedMessage.contains('email not confirmed')) {
      return 'Debes confirmar tu email antes de iniciar sesión.';
    }
    if (normalizedMessage.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento y vuelve a intentar.';
    }
    if (normalizedMessage.contains('user already registered')) {
      return 'Ya existe una cuenta con ese email.';
    }
    if (normalizedMessage.contains('signup is disabled')) {
      return 'El registro no está disponible temporalmente.';
    }
    return originalMessage;
  }
}
