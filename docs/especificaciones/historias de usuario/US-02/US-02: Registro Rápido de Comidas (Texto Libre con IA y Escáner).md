Como usuario con poco tiempo,
Quiero registrar mis comidas usando texto natural o escaneando un código de barras desde un panel rápido,
Para que pueda registrar mis macros en menos de 10 segundos sin tener que buscar cada ingrediente por separado.

Criterios de Aceptación (Acceptance Criteria)
Apertura y Contexto (Triggers):

El modal debe abrirse desde abajo (Bottom Sheet) al tocar el botón central "Registrar" (FAB) o al tocar los botones + de cualquier tarjeta de comida (Desayuno, Almuerzo, etc.).

Si se abre desde el FAB central, debe haber un selector visual (ej. pills o botones pequeños) para elegir en qué comida guardarlo (Desayuno, Almuerzo, Cena, Merienda). Por defecto, debe autoseleccionar la comida más lógica según la hora del día.

Si se abre desde un botón + específico (ej. "Almuerzo"), ese contexto ya debe estar preseleccionado

UI del Bottom Sheet (Estado Inicial):

El teclado del teléfono debe desplegarse automáticamente al abrir el modal (auto-focus en el campo de texto) para ahorrarle un tap al usuario.

Input de Texto Natural: Un área de texto grande y de múltiples líneas. El placeholder debe educar al usuario (ej. "Ej: 200g de pollo con arroz, o escanea un código...").

Botón de Escáner: Un ícono de código de barras muy visible dentro o al lado del input de texto.

Botón de Acción (Submit): Un botón claro (ej. "Analizar ✨" o flecha de envío) que se habilita solo cuando hay texto ingresado.

Flujo de IA (Texto Natural):

Al tocar "Analizar", el teclado se oculta y se muestra un estado de carga (shimmer o spinner) indicando que la IA está procesando ("Calculando macros...").

La vista debe transicionar a un "Resumen de Confirmación", mostrando los alimentos detectados, sus cantidades y los macros totales.

El usuario debe tener un botón de "Confirmar y Guardar" y la opción de editar manualmente si la IA se equivocó en alguna cantidad.

Flujo del Escáner (Barcode):

Al tocar el ícono del escáner, si es la primera vez, se deben pedir permisos de cámara a nivel sistema operativo.

La vista del Bottom Sheet se expande o transiciona a la cámara con una retícula de escaneo.

Al detectar el código, debe hacer fetch a la base de datos (ej. OpenFoodFacts) y mostrar la pantalla de "Resumen de Confirmación" con la opción de ajustar la porción (ej. "1 paquete", "Medio paquete").

Cierre y Actualización:

Al "Confirmar y Guardar", el Bottom Sheet se cierra con una animación fluida hacia abajo.

El Dashboard (Home) se actualiza instantáneamente: el anillo principal suma las calorías, las barras de macros avanzan y el ítem aparece en la lista de la comida correspondiente.

Notas Técnicas para el Dev (Tech Specs preliminares)
Componente UI: Te sugiero usar un componente tipo BottomSheet (ej. @gorhom/bottom-sheet si usas React Native) en lugar de una pantalla completa. Permite que el usuario siga viendo su dashboard de fondo (ligeramente oscurecido), lo que reduce la sensación de "salir" de la app.

Manejo del Teclado: Es vital usar un KeyboardAvoidingView o equivalente para asegurar que el input de texto y el botón de enviar nunca queden ocultos debajo del teclado del teléfono.

Estado (Contexto): Pasa el meal_type (desayuno, almuerzo, etc.) como un parámetro al abrir el Bottom Sheet para que el backend sepa dónde insertar los datos en la tabla MealEntry.