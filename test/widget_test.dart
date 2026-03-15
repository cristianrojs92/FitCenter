import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dietx/features/onboarding/logic/onboarding_provider.dart';
import 'package:dietx/features/onboarding/ui/onboarding_step1_screen.dart';

// Test básico que verifica que la pantalla de onboarding se renderiza sin errores
void main() {
  testWidgets('OnboardingStep1Screen carga correctamente', (tester) async {
    // Envolvemos la pantalla con el proveedor necesario para el test
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OnboardingProvider(),
        child: const MaterialApp(home: OnboardingStep1Screen()),
      ),
    );
    // Verificamos que el título principal de la pantalla esté visible
    expect(find.text('Información Básica'), findsOneWidget);
    // Verificamos que el botón Continuar esté en la pantalla
    expect(find.text('Continuar'), findsOneWidget);
  });
}
