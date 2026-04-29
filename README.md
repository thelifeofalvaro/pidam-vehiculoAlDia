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
### Gestión de vehículos
### Registro de intervenciones
### Perfil de usuario
### Seguridad

## Estructura de carpetas
[EN CONSTRUCCIÓN]

## Estado del proyecto
Pendiente de entrega final.

## Autor
Alvaro Medina - 2ºDAM Prometeo FP
