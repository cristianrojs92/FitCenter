Como usuario nuevo o recurrente,
Quiero registrarme o iniciar sesión de forma instantánea usando mi cuenta de Google, Apple o mi correo electrónico (sin contraseña),
Para que pueda acceder a mi perfil, sincronizar mis datos en la nube y empezar a registrar mis comidas sin perder tiempo creando credenciales complejas.

Criterios de Aceptación (Acceptance Criteria):
Estado Inicial: La pantalla debe ser el punto de entrada de la app. Debe mostrar el logo de DietX y una propuesta de valor corta (ej. "Tu nutrición en piloto automático").

Social Logins (Baja Fricción): Deben existir dos botones muy prominentes: "Continuar con Google" y "Continuar con Apple" (Requisito obligatorio si lanzas en iOS con otros social logins).

Magic Link (Email sin contraseña): Debe haber un input de texto para "Correo electrónico" y un botón secundario que diga "Continuar con Email". Al tocarlo, debe mostrar un mensaje: "Te hemos enviado un enlace mágico para entrar".

Manejo de Errores: Si el usuario ingresa un email inválido, el input debe marcarse en rojo sutil con un mensaje de "Formato de correo inválido".

Transición al Éxito: Al autenticarse correctamente mediante Supabase Auth, la app debe verificar si el usuario ya tiene datos físicos. Si es nuevo, lo envía al Onboarding (Formulario 1). Si ya existe, lo envía al Dashboard (Home).

Notas Técnicas para Supabase (Tech Specs):
Usaremos los métodos supabase.auth.signInWithOAuth({ provider: 'google' }) y supabase.auth.signInWithOAuth({ provider: 'apple' }).

Para el correo usaremos supabase.auth.signInWithOtp({ email: '...' }). No gestionaremos contraseñas (encriptación, reseteo, etc.) en el MVP para ahorrar tiempo de desarrollo y mejorar la seguridad.