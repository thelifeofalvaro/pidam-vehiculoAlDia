# Supabase — Vehículo Al Día

Documentación del entorno Supabase: configuración, Storage, autenticación y consideraciones de producción.

## Estructura del proyecto en Supabase
 
El proyecto Supabase de Vehículo Al Día tiene los siguientes componentes activos:
 
| Componente | Estado | Descripción |
|---|---|---|
| Authentication | Activo | Gestión de usuarios con email/contraseña |
| Database (PostgreSQL) | Activo | 3 tablas públicas con RLS |
| Storage | Activo | 1 bucket (`archive`) para imágenes y documentos |

Otras funcionalidades no se han usado en este proyecto (Edge functions o Realtime).

## Autenticación y verificación de mail
 
La app usa exclusivamente **email + contraseña** a través de `supabase_flutter`.
 
Una vez registrado, Supabase envía un email de confirmación. El usuario no puede iniciar sesión hasta que valida su correo. Este comportamiento está activado por defecto en el dashboard de Supabase en **Authentication → Providers → Email**.

## Sesión persistente
 
`supabase_flutter` persiste la sesión automáticamente en el dispositivo usando `SharedPreferences`. Al reabrir la app, `SplashScreen` comprueba si hay sesión activa y redirige al home o al login según corresponda.

## Storage

Se utiliza un único bucket (**`archive`**) para todos los archivos de la app:
 
| Prefijo de ruta | Contenido |
|---|---|
| `profiles/` | Fotos de perfil de usuario |
| `vehiculos/` | Imágenes de vehículos |
| `interventions/` | Documentos adjuntos a intervenciones (facturas, tickets) |
 
Al ser un bucket **público** las URLs generadas son accesibles directamente sin autenticación, lo que permite mostrar imágenes en las diferentes pantallas sin headers adicionales.

### Políticas de Storage
 
Las políticas controlan qué operaciones puede realizar un usuario autenticado sobre el bucket `archive`:
 
| Política | Operación | Condición |
|---|---|---|
| Usuarios autenticados pueden subir | INSERT | `bucket_id = 'archive'` |
| Usuarios autenticados pueden leer | SELECT | `bucket_id = 'archive'` |
| Usuarios autenticados pueden actualizar | UPDATE | `bucket_id = 'archive'` |
| Usuarios autenticados pueden eliminar | DELETE | `bucket_id = 'archive'` |
 
Solo los usuarios con sesión activa pueden subir o eliminar archivos. La lectura también requiere autenticación, aunque las URLs públicas son accesibles por diseño.

### Compresión de imágenes
 
Antes de subir cualquier imagen, `FileUtils.processFile()` valida el tamaño y comprime si es necesario:
 
- Imágenes menores de **1MB**: se suben sin modificar.
- Imágenes entre **1MB y 2MB**: se comprimen al 80% de calidad. Si siguen siendo grandes, al 60%.
- Imágenes mayores de **2MB** tras comprimir: se rechazan con mensaje al usuario.
- PDFs: se valida que no superen 2MB, sin compresión.

### Eliminación de archivos
 
Al eliminar una foto de vehículo, foto de perfil o adjunto de intervención, el archivo también se elimina del bucket.

## Credenciales y seguridad
 
### Variables de entorno
 
Las credenciales de Supabase **no se han incluido en el código**. Se inyectan en tiempo de compilación mediante `--dart-define-from-file`, el archivo `dart_defines.json` no se ha subido al repositorio.

## Integración en Flutter

Supabase se inicializa una vez en `main()` antes de arrancar la app.

Cada entidad tiene su propio repositorio que encapsula todas las operaciones con Supabase:
 
| Repositorio | Tabla | Operaciones |
|---|---|---|
| `VehicleRepository` | `vehiculos` | getVehicles, createVehicle, updateVehicle, deleteVehicle, getVehicleById |
| `InterventionRepository` | `intervenciones` | getInterventionsByVehicle, createIntervention, updateIntervention, deleteIntervention |
| `ProfileRepository` | `usuarios` | getProfile, updateProfile 

# Limitaciones de la capa gratuita
Al haber usado la capa grauita de Supabase para el proyecto academico, hemos encontrado estas limitaciones que penalizarían en un entrono de producción:
- Límite de 500MB de almacenamiento de la BBDD.
- Límite de 1GB para el Storage.
- Ancho de banda 2GB/mes.
- Peticiones API 50.000/mes
- No se pueden hacer backups desde el dashboard

Los usuarios si pueden ser ilimitados

### Consideraciones RGPD
Como parte de las mejoras futuras, y para complementar el borrado lógico de usuarios en un entorno de producción, se debería añadir una columna a la tabla `usuarios` para ver si está activo o no, y poder anonimizar datos cuando se desactive la cuenta para cumplir con las leyes vigentes.
