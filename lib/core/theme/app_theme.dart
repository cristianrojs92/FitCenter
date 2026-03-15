import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clase que centraliza la configuración visual de la app (ThemeData).
/// Toda la app consume este tema; nunca se definen colores o estilos en los widgets.
abstract final class AppTheme {
  /// Retorna el ThemeData completo en modo claro para pasar al MaterialApp
  static ThemeData get light {
    // Definimos el esquema de colores base usando el verde primary de la marca
    final esquemaDeColores = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryText,
      surface: AppColors.surface,
      onSurface: AppColors.primaryText,
      error: AppColors.error,
    );

    // Configuramos el tema del texto usando la fuente Inter de Google Fonts
    final temaDeTexto = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      // Estilo para títulos grandes de pantalla
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
      // Estilo para subtítulos descriptivos
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.secondaryText,
      ),
      // Estilo para labels de secciones del formulario
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );

    return ThemeData(
      // Establecemos el esquema de colores definido arriba
      colorScheme: esquemaDeColores,
      // Aplicamos el tema typegráfico con Inter
      textTheme: temaDeTexto,
      // Usamos el background claro del diseño en la pantalla principal
      scaffoldBackgroundColor: AppColors.background,
      // Desactivamos el banner de debug para mostrar la UI limpia
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
      ),
      // Configuramos el tema de los campos de texto para consistencia
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.activeBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
