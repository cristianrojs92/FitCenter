import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/ui/login_screen.dart';
import '../theme/app_colors.dart';

/// Muestra un diálogo de confirmación para cerrar sesión.
/// 
/// Retorna `true` si el usuario confirma y cierra sesión exitosamente,
/// `false` si cancela o hay un error.
Future<bool> mostrarDialogoCerrarSesion(
  BuildContext context, {
  String mensaje = '¿Estás seguro de que deseas cerrar sesión?',
}) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '¿Cerrar sesión?',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
      ),
      content: Text(
        mensaje,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Cerrar sesión',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmar != true) {
    return false;
  }

  try {
    await Supabase.instance.client.auth.signOut();
    
    if (!context.mounted) return false;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    
    return true;
  } catch (e) {
    if (!context.mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cerrar sesión: ${e.toString()}'),
        backgroundColor: AppColors.error,
      ),
    );
    
    return false;
  }
}
