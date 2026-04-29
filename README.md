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
- Actualización de nombre de usuario y contraseña
- Posibilidad de añadir foto de perfil (Supabase Storage)
- Posiblidad de eliminación de cuenta (lógica)
### Seguridad
- Datos protegidos con Row Level Security (RLS) en PostgreSQL
- Cada usuario solo accede a sus propios datos
- Credenciales nunca en el código fuente
## Estructura de carpetas
[EN CONSTRUCCIÓN]

## Documentación adicional
 
- [`database/database.md`](database/database.md) — Esquema de la base de datos, políticas RLS e integración con Supabase Auth
- [`docs/supabase/supabase.md`](docs/supabase/supabase.md) — Configuración del entorno Supabase, Storage y despliegue
 

## Estado del proyecto
Pendiente de entrega final.

## Autor
Alvaro Medina - 2ºDAM Prometeo FP
