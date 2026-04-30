# PIDAM-VehiculoAlDia
Repositorio completo del Proyecto Intermodular de Desarrollo de Aplicaciones Multiplataforma. VehículoAlDía es una aplicación multiplataforma que permite llevar un seguimiento de todas las intervenciones realizadas en vehículos registados.

## Descripción ampliada
Vehículo Al Día permite a los usuarios particulares llevar un registro detallado de todas las intervenciones realizadas a sus vehículos (revisiones, reparaciones, mejoras, etc...). El funcionamiento multiplataforma permite que funcione tanto en Android, como iOS y en web, con una única base de codigo (Flutter)

Cada usuario gestiona sus propios vehículos y las intervenciones relacionadas con ellos de forma individual. Los datos se almacenan en Supabase (PostgreSQL), con politicas Row Level Security (RLS) para garantizar que cada usuario solo acceda a su propia información

## Tecnologías
|Tecnología | Versión | Uso |
|------------|------------|------------|
|Flutter|3.x|Framework multiplataforma|
|Dart|^3.10.8|Lenguaje de programación|
|Supabase|^2.12.2|Backend(Auth, BBDD, Storage)|
|PostgreSQL| - |Sistema Gestor Base de Datos (SGBD)|
|flutter_image_compress|^2.0.04|Compresión de imagenes antes de subirlas|
|file_picker|^8.0.0|Selección de archivos e imagenes|
|intl|^0.20.2|Internacionalización y formatos de fecha|
|flutter_locations|SDK|Localización en Español|

## Arquitectura del proyecto
Se ha usado la Clean Architecture, adaptada a la escala de este proyecto para separar todo en capas:
- Presentación: Widgets comunes, pantallas de navegación principal, splash screen.
- Features: Cada módulo Funcional tiene sus propias pantallas (auth, vehicles, intervention, profile).
- Data: Modelos de datos, repositorios para el acceso a Supabase y servicios de autenticación.
- Core: Utilidades compartidas (colores, estilos de texto, gestión de errores, ficheros, etc...).

Para la gestión de estados se usa el ```setState``` nativo de Flutter

## Funcionalidades
### Autenticación
- Registro de nuevos usuarios con validación de email y contraseña.
- Inicio de sesión.
- Cierre de sesión con confirmación.
- Verificación de sesión activa al arrancar (SplashScreen).
### Gestión de vehículos
- CRUD Completo de vehículos.
- Campos: marca/modelo, matrícula, bastidor, tipo, año, kilometraje.
- Posibilidad de subir foto del vehículo a Supabase Storage.
- Eliminación en cascada: al borrar un vehículo se eliminan todas sus intervenciones.
### Registro de intervenciones
- CRUD Completo de intervenciones.
- Registro datos: tipo, lugar (casa/taller), fecha, kilometraje, coste, descripción y notas adicionales.
- Posibilidad de adjuntar documentos (facturas, tickets) relacionados (formato JPG, PNG o PDF hasta 2MB).
- Compresión automática de imágenes que superen 1MB.
- Filtro de intervenciones por tipo de intervención.
- Suma gasto total acumulado por vehículo.
### Perfil de usuario
- Modo vista y edición separados.
- Actualización de nombre de usuario y contraseña.
- Posibilidad de añadir foto de perfil (Supabase Storage).
- Posiblidad de eliminación de cuenta (lógica).
### Seguridad
- Datos protegidos con Row Level Security (RLS) en PostgreSQL.
- Cada usuario solo accede a sus propios datos.
- Credenciales de Supabase en `dart_defines.json` (archivo dentro del .gitignore por seguridad, no se sube a GitHub)
## Estructura de carpetas
```
pidam-vehiculoAlDia/
├── database/
│   ├── 01.schema.sql
│   ├── 02.rls.sql
│   ├── 03.integracion_authUsers.sql
│   ├── 04.modificaciones_bbdd.sql
│   └── database.md
├── docs/
│   ├── anteproyecto/
│   │   └── Anterproyecto PIDAM VehiculoAlDia.pdf
│   ├── diagramas/
│   │   ├── Arquitectura.jpg
│   │   ├── CasosDeUso.jpg
│   │   ├── DER.jpg
│   │   ├── DiagramaDeClases.jpg
│   │   ├── db_schema.png
│   │   └── esquema_red.png
│   └── supabase/
│        └── supbase.md
├── node_modules/
├── vad_app/                                   # Aplicación principal Flutter
│   │   ├── android/
│   │   ├── assets/images/                     # Imagenes varias
│   │   ├── ios/
│   │   ├── lib/
│   │   │   ├── core/                          # Utilidades y constantes reutilizables
│   │   │   │   ├── app_color.dart             # Paleta de colores de la app
│   │   │   │   ├── app_config.dart            # Configuración (credenciales Supabase)
│   │   │   │   ├── app_text_styles.dart       # Estilos de texto centralizados
│   │   │   │   └── utils/
│   │   │   │       ├── error_utils.dart       # Mensajes de error legibles
│   │   │   │       └── file_utils.dart        # Validación y compresión de archivos
│   │   │   │
│   │   │   ├── data/                          # Capa de datos
│   │   │   │   ├── models/                    # Modelos de datos (fromJson/toJson)
│   │   │   │   │   ├── intervention_model.dart
│   │   │   │   │   ├── profile_model.dart
│   │   │   │   │   └── vehicle_model.dart
│   │   │   │   ├── repositories/              # Acceso a Supabase
│   │   │   │   │   ├── intervention_repository.dart
│   │   │   │   │   ├── profile_repository.dart
│   │   │   │   │   └── vehicle_repository.dart
│   │   │   │   └── services/                  # Servicios externos
│   │   │   │       └── auth_service.dart      # Autenticación con Supabase Auth
│   │   │   │
│   │   │   ├── features/                      # Módulos funcionales (pantallas)
│   │   │   │   ├── auth/screens/              # Login y registro
│   │   │   │   ├── interventions/screens/     # Listado y gestión de intervenciones
│   │   │   │   ├── profile/screens/           # Perfil de usuario
│   │   │   │   └── vehicles/screens/          # Gestión de vehículos
│   │   │   │
│   │   │   ├── presentation/                  # Componentes de presentación compartidos
│   │   │   │   ├── screens/                   # Pantallas globales (home, splash)
│   │   │   │   └── widgets/                   # Widgets reutilizables
│   │   │   │       └── app_bottom_nav_bar.dart
│   │   │   │
│   │   │   └── main.dart                      # Punto de entrada, rutas y configuración
│   │   ├── linux/
│   │   ├── macos/
│   │   ├── web/
│   │   ├── windows/
│   │   ├── .gitignore
│   │   ├── .metadata
│   │   ├── analysis_option.yaml
│   │   ├── devtools_options.yaml
│   │   ├── pubspec.lock
│   │   └── pubspec.yaml
├── README.md         # Este archivo
├── package-lock.json
└── package.json
```
## Documentación adicional
 
- [`database/database.md`](database/database.md) — Esquema de la base de datos, políticas RLS e integración con Supabase Auth
- [`docs/supabase/supabase.md`](docs/supabase/supabase.md) — Configuración del entorno Supabase, Storage y despliegue

## Instalación y configuración

### Requisitos previos
 
- Flutter SDK instalado y configurado
- Cuenta en Supabase con el proyecto configurado
- Android Studio o VS Code con las extensiones de Flutter/Dart
- Para build iOS: Mac con Xcode instalado o emuladores.

### 1. Clonar el repositorio
 
```bash
git clone https://github.com/thelifeofalvaro/pidam-vehiculoAlDia.git
cd pidam-vehiculoAlDia/vad_app
```
 
### 2. Instalar dependencias
 
```bash
flutter pub get
```
 
### 3. Configurar las credenciales de Supabase
 
Crea el archivo `dart_defines.json` en la raíz del proyecto, con tus credenciales:
 
```json
{
  "SUPABASE_URL": "https://tu-proyecto.supabase.co",
  "SUPABASE_ANON_KEY": "tu-anon-key"
}
```
 
Las credenciales se encuentran en el dashboard de Supabase en **Settings → API**.

### 4. Lanzar el proyecto en modo localhost

#### Opción 1
 
Ejecuta en la terminal:
 
```bash
flutter run --dart-define-from-file=dart_defines.json
```
#### Opción 2

Crea el archivo `run_dev.bat` que contenga el comando
```bat
--dart-define-from-file=dart_defines.json
```
Y ejecuta en la terminal

```bash
.\run_dev.bat 
```

## Estado del proyecto
Finalizado. Pendiente de evaluación y defensa.

## Autor
Alvaro Medina - 2ºDAM Prometeo FP
