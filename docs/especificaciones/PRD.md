Especificaciones de Diseño UI/UX: MVP App de Nutrición
1. Visión General para Diseño
Objetivo Principal: Minimizar la fricción cognitiva. El usuario debe poder abrir la app, registrar su comida en menos de 10 segundos y ver el impacto inmediato en sus macros diarios.
Guía de Estilo Sugerida: Limpia y funcional. Tipografía de alta legibilidad (números grandes para métricas clave) y uso de colores semánticos (ej. verde para proteínas, amarillo para carbohidratos, rojo/naranja para grasas) para facilitar el escaneo visual rápido.

2. Flujo 1: Onboarding y Setup Físico
Propósito: Capturar los datos necesarios para calcular el Gasto Energético (TDEE) y definir la meta nutricional.

Pantallas requeridas: Flujo paso a paso (Wizard).

Elementos UI:

Inputs Base: Género, Edad, Altura, Peso actual.

Selector de Nivel de Actividad: Botones grandes y descriptivos (Sedentario, Ligero, Moderado, Intenso, Atleta).

Selector de Objetivo: Pérdida de Grasa (Déficit) vs. Ganancia Muscular / Volumen (Superávit). El diseño debe hacer sentir ambos objetivos igual de importantes y respaldados por la app.

Pantalla de Éxito: Un panel de resumen celebratorio que muestre el cálculo final (ej. "Tus calorías diarias: 2800 kcal") y la división de macros sugerida en gramos. Botón de Call to Action (CTA) principal: "Comenzar mi Diario".

3. Flujo 2: Dashboard Principal (Home)
Propósito: La pantalla de aterrizaje diaria. Debe responder a la pregunta "¿Cómo voy hoy?" en un solo vistazo.

Elementos UI:

Cabecera (Resumen de Calorías): Un elemento visual prominente, preferiblemente un anillo circular o barra de progreso horizontal gruesa.

Estructura de datos visual: Calorías Meta - Calorías Consumidas = Calorías Restantes.

Tarjetas de Macros: 3 indicadores visuales más pequeños justo debajo del anillo principal. Deben mostrar gramos consumidos vs. meta para Proteínas, Carbohidratos y Grasas, rellenándose según el progreso.

Línea de Tiempo de Comidas (Diario): Secciones colapsables o tarjetas apiladas para "Desayuno", "Almuerzo", "Cena" y "Snacks".

Cada sección debe tener un ícono de + o botón de "Añadir" muy accesible para iniciar el flujo de registro sin tener que hacer scroll.

4. Flujo 3: Búsqueda y Registro (El "Core" del MVP)
Propósito: La pantalla que define el éxito de la app. Debe ser ultrarrápida y versátil.

Elementos UI:

Barra de Búsqueda Universal (Top): El campo principal al abrir esta vista.

Input de "Texto Natural" (Destacado): Un área de texto grande donde el usuario pueda escribir libremente su comida (ej. "200g de pechuga de pollo y 150g de arroz blanco"). Debe incluir un botón CTA distintivo (ej. "Analizar" o un ícono de destello) para indicar que la IA procesará el texto.

Botón de Escáner de Código de Barras: Integrado dentro de la barra de búsqueda. Al tocarlo, debe abrir la cámara en pantalla completa con una retícula de escaneo.

Lista de "Recientes / Frecuentes": Debajo del buscador, una lista que pueble automáticamente los alimentos más usados por el usuario (ej. avena, huevos, whey protein) para permitir un registro de "1 solo clic".

Pantalla de Ajuste de Porción (Bottom Sheet): Al seleccionar un alimento, debe emerger un panel desde abajo (bottom sheet) con un teclado numérico grande o rueda de selección para ajustar la cantidad (gramos, unidades) y un botón de confirmación.

5. Flujo 4: Seguimiento de Progreso (Tracking de Peso)
Propósito: Validar visualmente si el déficit o superávit está funcionando.

Elementos UI:

Gráfico de Tendencias: Un gráfico de líneas simple y limpio que grafique el peso en el eje Y y el tiempo en el eje X, con filtros rápidos (1S, 1M, 3M).

Botón CTA "Registrar Peso Hoy": Debe abrir un modal rápido con un teclado numérico para ingresar el peso actual.

Indicador de Variación: Un pequeño distintivo visual en verde o rojo indicando la diferencia respecto al último registro (ej. "↓ 0.5 kg esta semana").