Esta guía establece las normas para mantener el código simple, modular y, sobre todo, fácil de leer y entender paso a paso.

0. Idioma del Código
Regla obligatoria: Todo el código fuente debe escribirse en inglés.

Incluye: nombres de variables, funciones, clases, métodos, propiedades, archivos, carpetas, enums y constantes.

Excepción única: los comentarios y documentación inline (//, ///, /* */) deben escribirse en español.

1. Arquitectura de Carpetas (Feature-First)
El proyecto se organiza por funcionalidades, no por tipos de archivos. Esto permite localizar toda la lógica de una característica en un solo lugar.

lib/core/: Código compartido (temas, constantes, clientes de red).

lib/features/: Una carpeta por cada funcionalidad (ej. login, home, profile).

data/: Modelos y repositorios.

logic/: Gestión de estado (Providers, Signals, etc.).

ui/: Pantallas y widgets específicos.

2. Composición de Widgets
Para evitar el "infierno de widgets", aplicamos la Regla de las 100 líneas:

Ningún archivo de widget debe superar las 100-150 líneas.

Si un widget se vuelve complejo, se fragmenta en widgets más pequeños en archivos independientes.

Uso obligatorio de const en constructores siempre que sea posible para mejorar el rendimiento y la legibilidad.

3. Separación de Preocupaciones
Interfaz (UI): Solo se encarga de mostrar datos y emitir eventos de usuario. No debe contener cálculos ni llamadas a APIs.

Lógica: La lógica de negocio reside fuera del método build. Se prohíbe procesar datos directamente dentro de los widgets.

4. Estilos y Temas
Cero "Hardcoding": No se permiten colores (Colors.blue) ni estilos de texto manuales dentro de los widgets.

Fuente de Verdad: Todo estilo debe provenir de Theme.of(context). Esto garantiza consistencia y facilita cambios globales.

5. Nomenclatura Semántica
Los nombres deben ser descriptivos y evitar abreviaturas ambiguas:

Variables: Deben indicar contenido o estado y estar en inglés (ej. isLoading, userList).

Funciones: Deben indicar una acción y estar en inglés (ej. onSubmitPressed, fetchProfileData).

6. Regla de Oro: Comentarios por Línea
Para garantizar la máxima claridad, cada línea de código con contenido debe ser documentada.

Normas de comentarios:
Idioma: Todos los comentarios deben escribirse en español.

Contenido: Explicar la intención de la línea, no solo repetir lo que dicta la sintaxis.

Exclusión Estructural: No se deben comentar las líneas que contengan únicamente símbolos de apertura o cierre ({, }, (, ), [, ], ),, };).

Ejemplo de Referencia:
Dart
// Definimos el estado para controlar el contador
final counter = signal(0);

// Función para incrementar el valor de forma segura
void increment() {
  // Sumamos uno al valor actual del signal
  counter.value++;
}
// Las llaves de cierre se mantienen limpias para ver la estructura
7. Calidad de Código (Linter)
El archivo analysis_options.yaml es el guardián de la consistencia. Es obligatorio seguir sus sugerencias, especialmente:

prefer_const_constructors

always_declare_return_types

prefer_final_locals

sort_child_properties_last

8. Documentación de Clases
Toda clase pública o método complejo debe usar la documentación de tres barras (///) para que la ayuda esté disponible al pasar el cursor sobre el código en el editor.