import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/user_profile_repository.dart';
import '../data/models/user_profile_model.dart';

/// Proveedor de estado para el onboarding usando ChangeNotifier.
/// Contiene el estado mutable del formulario de perfil y notifica a los widgets
/// cuando hay cambios, para que se redibuje solo lo necesario.
class OnboardingProvider extends ChangeNotifier {
  final UserProfileRepository _repository = UserProfileRepository();

  /// El perfil que se va completando conforme el usuario llena el formulario
  UserProfileModel _perfil = const UserProfileModel();

  /// Indica si el perfil se está guardando en Supabase.
  bool _isSaving = false;

  /// Error al persistir el perfil del usuario.
  String? _saveErrorMessage;

  /// Expone el perfil actual de forma inmutable para lectura desde la UI
  UserProfileModel get perfil => _perfil;

  /// Indica si todos los campos son válidos para habilitar el botón Continuar
  bool get isFormValid => _perfil.isComplete;

  /// Indica si hay una petición de guardado en curso.
  bool get isSaving => _isSaving;

  /// Expone el error del último intento de guardado.
  String? get saveErrorMessage => _saveErrorMessage;

  // ── Mensajes de error de validación ─────────────────────────────────────────

  /// Mensaje de error para el campo Edad (null si el campo está vacío o es válido)
  String? ageError;

  /// Mensaje de error para el campo Peso
  String? weightError;

  /// Mensaje de error para el campo Altura
  String? heightError;

  // ── Métodos de actualización ─────────────────────────────────────────────────

  /// Actualiza el género seleccionado y notifica a los widgets suscritos
  void actualizarGender(Gender gender) {
    // Creamos un nuevo perfil con el género actualizado, manteniendo el resto
    _perfil = _perfil.copyWith(gender: gender);
    _clearSaveError();
    // Notificamos el cambio para que los widgets se redibujen
    notifyListeners();
  }

  // Métodos silenciosos (onChanged): guardan el valor sin mostrar errores ──────

  /// Guarda la age en el perfil si es válida, sin activar mensajes de error.
  /// Se llama en onChanged para que el botón Continuar se habilite en tiempo real.
  void saveAgeSilently(String valor) {
    // Parseamos el valor sin modificar el estado de error del campo
    final entero = int.tryParse(valor);
    if (entero != null && entero >= 13 && entero <= 120) {
      // El valor es válido: lo guardamos en el perfil inmediatamente
      _perfil = _perfil.copyWith(age: entero);
      _clearSaveError();
      notifyListeners();
    } else if (_perfil.age != null) {
      // Si había un valor válido y ahora el campo está incompleto, lo invalidamos
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: null,
        weightKg: _perfil.weightKg,
        heightCm: _perfil.heightCm,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
      _clearSaveError();
      notifyListeners();
    }
  }

  /// Guarda el peso en el perfil si es válido, sin activar mensajes de error.
  void saveWeightSilently(String valor) {
    // Parseamos con soporte de coma decimal para facilitar la entrada
    final decimal = double.tryParse(valor.replaceAll(',', '.'));
    if (decimal != null && decimal >= 20) {
      _perfil = _perfil.copyWith(weightKg: decimal);
      _clearSaveError();
      notifyListeners();
    } else if (_perfil.weightKg != null) {
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: _perfil.age,
        weightKg: null,
        heightCm: _perfil.heightCm,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
      _clearSaveError();
      notifyListeners();
    }
  }

  /// Guarda la altura en el perfil si es válida, sin activar mensajes de error.
  void saveHeightSilently(String valor) {
    // Parseamos como entero en centímetros
    final entero = int.tryParse(valor);
    if (entero != null && entero >= 100 && entero <= 250) {
      _perfil = _perfil.copyWith(heightCm: entero);
      _clearSaveError();
      notifyListeners();
    } else if (_perfil.heightCm != null) {
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: _perfil.age,
        weightKg: _perfil.weightKg,
        heightCm: null,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
      _clearSaveError();
      notifyListeners();
    }
  }

  /// Valida y actualiza la age al perder el foco el campo de texto
  void updateAge(String valor) {
    // Intentamos parsear el texto a entero
    final entero = int.tryParse(valor);
    // Verificamos si el valor está dentro del rango permitido
    if (entero == null || entero < 13 || entero > 120) {
      // Asignamos el mensaje de error y limpiamos la age del perfil
      ageError = 'Ingresa una age válida (13–120 años)';
      _perfil = _perfil.copyWith();
      // Creamos un perfil con age nula para invalidar el formulario
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: null,
        weightKg: _perfil.weightKg,
        heightCm: _perfil.heightCm,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
    } else {
      // El valor es válido: limpiamos el error y guardamos la age
      ageError = null;
      _perfil = _perfil.copyWith(age: entero);
    }
    _clearSaveError();
    notifyListeners();
  }

  /// Valida y actualiza el peso corporal en kilogramos
  void updateWeight(String valor) {
    // Intentamos parsear el texto a número decimal
    final decimal = double.tryParse(valor.replaceAll(',', '.'));
    // Verificamos el rango mínimo permitido
    if (decimal == null || decimal < 20) {
      weightError = 'El peso debe ser mayor a 20 kg';
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: _perfil.age,
        weightKg: null,
        heightCm: _perfil.heightCm,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
    } else {
      weightError = null;
      _perfil = _perfil.copyWith(weightKg: decimal);
    }
    _clearSaveError();
    notifyListeners();
  }

  /// Valida y actualiza la altura en centímetros
  void updateHeight(String valor) {
    // Intentamos parsear el texto a entero
    final entero = int.tryParse(valor);
    // Verificamos el rango permitido para altura humana
    if (entero == null || entero < 100 || entero > 250) {
      heightError = 'La altura debe estar entre 100 y 250 cm';
      _perfil = UserProfileModel(
        gender: _perfil.gender,
        age: _perfil.age,
        weightKg: _perfil.weightKg,
        heightCm: null,
        activityLevel: _perfil.activityLevel,
        goal: _perfil.goal,
      );
    } else {
      heightError = null;
      _perfil = _perfil.copyWith(heightCm: entero);
    }
    _clearSaveError();
    notifyListeners();
  }

  /// Actualiza el nivel de actividad seleccionado en las tarjetas
  void actualizarActivityLevel(ActivityLevel nivel) {
    _perfil = _perfil.copyWith(activityLevel: nivel);
    _clearSaveError();
    notifyListeners();
  }

  /// Actualiza el goal nutricional seleccionado
  void updateGoal(NutritionGoal goal) {
    _perfil = _perfil.copyWith(goal: goal);
    _clearSaveError();
    notifyListeners();
  }

  /// Persiste el perfil del onboarding para el usuario autenticado.
  Future<bool> saveProfile() async {
    if (!_perfil.isComplete) return false;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _saveErrorMessage =
          'No encontramos una sesión activa. Inicia sesión nuevamente.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _saveErrorMessage = null;
    notifyListeners();

    try {
      await _repository.saveProfile(userId, _perfil);
      _isSaving = false;
      notifyListeners();
      return true;
    } on PostgrestException catch (error) {
      _isSaving = false;
      _saveErrorMessage = error.message;
    } catch (_) {
      _isSaving = false;
      _saveErrorMessage =
          'No pudimos guardar tu perfil. Intenta nuevamente.';
    }

    notifyListeners();
    return false;
  }

  void _clearSaveError() {
    if (_saveErrorMessage != null) {
      _saveErrorMessage = null;
    }
  }
}
