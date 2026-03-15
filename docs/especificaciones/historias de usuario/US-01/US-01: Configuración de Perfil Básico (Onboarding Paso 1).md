US-01: Configuración de Perfil Básico (Onboarding Paso 1)
Como usuario nuevo de la app,
Quiero ingresar mi información física básica, nivel de actividad y mi objetivo principal,
Para que la aplicación pueda calcular de forma precisa mis requerimientos diarios de calorías y macronutrientes.

Criterios de Aceptación (Acceptance Criteria)
Estado Inicial de la Pantalla:

Ningún campo debe estar preseleccionado por defecto (para obligar al usuario a tomar una decisión consciente), excepto quizás valores placeholder nulos en los inputs numéricos.

El botón principal inferior ("Continuar") debe estar deshabilitado o en estado inactivo hasta que todos los campos obligatorios estén completos.

Validación de Inputs Numéricos (Edad, Peso, Altura):

El teclado del dispositivo debe abrirse en formato numérico (keyboardType="numeric" en React Native/Flutter).

Edad: Debe ser un número entero mayor a 13 (por restricciones de edad estándar) y menor a 120.

Peso: Debe aceptar decimales (ej. 70.5 kg) y ser mayor a 20 kg.

Altura: Debe ser un número entero (en cm) mayor a 100 cm y menor a 250 cm.

Si el usuario ingresa un valor fuera de rango, debe mostrarse un sutil mensaje de error debajo del input al perder el foco (onBlur).

Interacción de Selectores (Género, Actividad, Objetivo):

Género y Objetivo: Deben funcionar como botones de opción exclusiva (Radio Buttons visuales). Solo se puede seleccionar uno a la vez.

Nivel de Actividad: Al tocar una tarjeta (ej. "Moderado"), esta debe cambiar a su estado activo (borde verde, ícono de check) y desmarcar cualquier otra previamente seleccionada.

Transición y Guardado (Call to Action):

Una vez que los 6 campos (Género, Edad, Peso, Altura, Actividad, Objetivo) tengan un valor válido, el botón "Continuar" se vuelve verde y clickable.

Al hacer clic en "Continuar", los datos deben guardarse temporalmente en el estado global de la app (ej. Redux, Zustand o Context API) para ser procesados al final del onboarding.

El usuario debe navegar a la pantalla "Paso 2 de 3" mediante una transición fluida (slide hacia la izquierda).

Notas Técnicas para el Dev (Tech Specs preliminares)
Modelo de Datos Frontend (Payload esperado):

JSON
{
  "gender": "male", // o "female"
  "age": 25,
  "weight_kg": 70.0,
  "height_cm": 175,
  "activity_level": "moderate", // Enum: sedentary, light, moderate, active, very_active
  "goal": "lose_fat" // Enum: lose_fat, gain_muscle, maintain
}
Accesibilidad (a11y): Asegurarse de que los selectores de tarjeta ("Ganar Músculo", "Sedentario") tengan las etiquetas de accesibilidad correctas para lectores de pantalla, ya que visualmente no son radio buttons estándar.