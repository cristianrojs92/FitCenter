import 'package:flutter/material.dart';

/// Clase que centraliza todos los colores del sistema de diseño de DietX.
/// Ningún widget debe usar colores directamente; siempre debe referenciar aquí.
abstract final class AppColors {
  // ── Primario ────────────────────────────────────────────────────────────────

  /// Color primary de la marca: verde vibrante para acciones principales
  static const Color primary = Color(0xFF13EC5B);

  /// Versión traslúcida del primary para backgrounds de íconos y anillos de foco
  static const Color softPrimary = Color(0x2213EC5B);

  // ── Fondos ──────────────────────────────────────────────────────────────────

  /// Fondo general de la app en modo claro
  static const Color background = Color(0xFFF6F8F6);

  /// Fondo de tarjetas y campos de texto en modo claro
  static const Color surface = Color(0xFFFFFFFF);

  /// Fondo del selector de género y áreas secundarias
  static const Color secondaryBackground = Color(0xFFE8EDE9);

  // ── Macronutrientes ────────────────────────────────────────────────────────

  /// Color para la proteína en tarjetas de macros (verde primary)
  static const Color protein = Color(0xFF13EC5B);

  /// Fondo suave para la tarjeta de proteína
  static const Color softProtein = Color(0x1413EC5B);

  /// Color para los carbs en tarjetas de macros (ámbar/dorado)
  static const Color carbs = Color(0xFFF59E0B);

  /// Fondo suave para la tarjeta de carbs
  static const Color softCarbs = Color(0x14F59E0B);

  /// Color para las fats en tarjetas de macros (naranja)
  static const Color fats = Color(0xFFF97316);

  /// Fondo suave para la tarjeta de fats
  static const Color softFats = Color(0x14F97316);

  // ── Texto ───────────────────────────────────────────────────────────────────

  /// Color de texto principal sobre backgrounds claros
  static const Color primaryText = Color(0xFF0D1C12);

  /// Color de texto secundario para descripciones y placeholders
  static const Color secondaryText = Color(0xFF6B7C70);

  /// Color de texto del placeholder en campos de entrada
  static const Color placeholderText = Color(0xFFABB8AF);

  // ── Bordes ──────────────────────────────────────────────────────────────────

  /// Borde estándar para campos y tarjetas en estado inactivo
  static const Color border = Color(0xFFDDE4DE);

  /// Borde usado cuando un elemento está seleccionado/activo
  static const Color activeBorder = Color(0xFF13EC5B);

  // ── Estados ─────────────────────────────────────────────────────────────────

  /// Color para mensajes de error de validación
  static const Color error = Color(0xFFE53935);

  /// Color del botón Continuar cuando el formulario está deshabilitado
  static const Color disabledButton = Color(0xFFCDD8CE);

  /// Color del texto sobre el botón deshabilitado
  static const Color disabledButtonText = Color(0xFF8E9E91);
}
