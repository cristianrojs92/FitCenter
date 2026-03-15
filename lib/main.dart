import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/session_router_screen.dart';
import 'features/home/logic/home_provider.dart';
import 'features/onboarding/logic/onboarding_provider.dart';

/// Punto de entrada de la aplicación DietX.
/// Inicializamos Supabase de forma asíncrona antes de correr la app.
Future<void> main() async {
  // Aseguramos que los bindings de Flutter estén listos antes de inicializar Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el cliente de Supabase con las credenciales del proyecto
  await Supabase.initialize(
    url: 'https://eqpoykkflxladnxygaug.supabase.co',
    // La anon key es segura para el cliente: solo tiene permisos acorde a las RLS
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcG95a2tmbHhsYWRueHlnYXVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MTI4NTksImV4cCI6MjA4OTA4ODg1OX0.UhbK2gZ60CQIRO9XI4a3lp0iJhiCVSqNzPMXCaJ8HhM',
  );

  runApp(const DietXApp());
}

/// Widget raíz de la aplicación.
/// Configura el tema global, los proveedores de estado y la navegación inicial.
class DietXApp extends StatelessWidget {
  const DietXApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveemos los proveedores de estado en la raíz del árbol de widgets
    return MultiProvider(
      providers: [
        // Proveedor de estado del flujo de onboarding inicial
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // Proveedor de estado del dashboard principal de la app
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(
        // Nombre visible de la app en el Switcher de aplicaciones del SO
        title: 'DietX',
        // Desactivamos el banner rojo de debug en la esquina de la pantalla
        debugShowCheckedModeBanner: false,
        // Aplicamos el tema visual centralizado definido en AppTheme
        theme: AppTheme.light,
        // La pantalla inicial enruta según sesión activa o no activa
        home: const SessionRouterScreen(),
      ),
    );
  }
}
