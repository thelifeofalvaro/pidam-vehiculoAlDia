# 🚗 Vehículo al Día

Aplicación multiplataforma para gestionar el historial de mantenimiento, reparaciones e intervenciones de diferentes vehículos.

Desarrollada con **Flutter, Dart, Supabase y PostgreSQL**, permite a cada usuario gestionar sus vehículos, registrar intervenciones y conservar documentación asociada, con los datos protegidos mediante **Row Level Security (RLS)**.

> Proyecto final del CFGS en Desarrollo de Aplicaciones Multiplataforma (DAM).

## 📱 Sobre el proyecto

**Vehículo al Día** nace con un objetivo sencillo: facilitar a los usuarios particulares el seguimiento del mantenimiento y las intervenciones realizadas en sus vehículos.

La aplicación permite registrar revisiones, reparaciones y mejoras, consultar el historial de cada vehículo y conservar documentos como facturas o tickets asociados a las intervenciones.

Al estar desarrollada con Flutter, la misma base de código permite ejecutar la aplicación en **Android, iOS y web**.

### Modelo principal

    Usuario
       │
       └── Vehículos
              │
              └── Intervenciones
                     │
                     └── Documentos

Cada usuario gestiona únicamente sus propios vehículos e intervenciones.

## ✨ Funcionalidades

### 👤 Usuarios

- Registro e inicio de sesión.
- Validación de email y contraseña.
- Verificación de sesión activa al iniciar la aplicación.
- Cierre de sesión con confirmación.
- Gestión del perfil.
- Actualización del nombre de usuario y contraseña.
- Foto de perfil.
- Eliminación de cuenta.

### 🚗 Vehículos

- Alta, edición y eliminación de vehículos.
- Información de marca, modelo, matrícula, bastidor, tipo, año y kilometraje.
- Fotografía del vehículo.
- Eliminación en cascada de las intervenciones asociadas al eliminar un vehículo.

### 🔧 Intervenciones

- Registro, edición y eliminación de intervenciones.
- Tipo de intervención.
- Lugar: casa o taller.
- Fecha y kilometraje.
- Coste.
- Descripción y notas adicionales.
- Filtrado por tipo de intervención.
- Cálculo del gasto total acumulado por vehículo.

### 📎 Documentación

- Adjuntar facturas y tickets a las intervenciones.
- Formatos admitidos: JPG, PNG y PDF.
- Archivos de hasta 2 MB.
- Compresión automática de imágenes que superen 1 MB.
- Almacenamiento mediante Supabase Storage.

## 🔐 Seguridad y datos

La aplicación utiliza **Supabase** como backend y **PostgreSQL** como sistema gestor de base de datos.

La seguridad de los datos se basa en **Row Level Security (RLS)**, de forma que cada usuario solo puede acceder a la información que le corresponde.

La autenticación se gestiona mediante **Supabase Auth**, integrada con el modelo de datos de la aplicación.

Las credenciales de Supabase se proporcionan mediante `dart_defines.json`, incluido en `.gitignore`, por lo que no se almacenan en el repositorio.

## 🏗️ Arquitectura

El proyecto utiliza una aproximación a **Clean Architecture**, adaptada a la escala de la aplicación, separando las principales responsabilidades:

    lib/
    ├── core/
    │   ├── configuración y estilos
    │   └── utilidades compartidas
    │
    ├── data/
    │   ├── models/
    │   ├── repositories/
    │   └── services/
    │
    ├── features/
    │   ├── auth/
    │   ├── vehicles/
    │   ├── interventions/
    │   └── profile/
    │
    └── presentation/
        ├── screens/
        └── widgets/

### Capas principales

**Core**  
Utilidades y elementos compartidos de la aplicación, como estilos, colores, configuración y gestión de errores y archivos.

**Data**  
Modelos de datos, repositorios para el acceso a Supabase y servicios externos, incluyendo autenticación.

**Features**  
Módulos funcionales de la aplicación: autenticación, vehículos, intervenciones y perfil.

**Presentation**  
Pantallas y widgets compartidos utilizados por diferentes funcionalidades.

La gestión de estados se realiza mediante el mecanismo nativo `setState` de Flutter.

```
## 🖼️ Aplicación

<!-- Añadir aquí las capturas reales de la aplicación -->
```
## 🛠️ Stack tecnológico 

### Aplicación

- **Flutter 3.x**
- **Dart ^3.10.8**

### Backend y datos

- **Supabase ^2.12.2**
- **PostgreSQL**
- **Supabase Auth**
- **Supabase Storage**

### Librerías principales

- `flutter_image_compress` — compresión de imágenes.
- `file_picker` — selección de archivos e imágenes.
- `intl` — formatos de fecha e internacionalización.
- `flutter_locations` — localización en español.


## 📂 Estructura del repositorio

    pidam-vehiculoAlDia/
    │
    ├── database/
    │   ├── 01.schema.sql
    │   ├── 02.rls.sql
    │   ├── 03.integracion_authUsers.sql
    │   ├── 04.modificaciones_bbdd.sql
    │   └── database.md
    │
    ├── docs/
    │   ├── anteproyecto/
    │   ├── diagramas/
    │   └── supabase/
    │
    ├── vad_app/
    │   ├── android/
    │   ├── ios/
    │   ├── lib/
    │   ├── linux/
    │   ├── macos/
    │   ├── web/
    │   ├── windows/
    │   └── pubspec.yaml
    │
    └── README.md

### Documentación técnica

La carpeta `docs/` contiene documentación y diagramas del proyecto, incluyendo:

- Arquitectura.
- Casos de uso.
- Diagrama entidad-relación.
- Diagrama de clases.
- Esquema de base de datos.
- Esquema de red.
- Documentación de configuración de Supabase.

La carpeta `database/` contiene los scripts SQL utilizados para crear y modificar el esquema, configurar las políticas RLS e integrar la autenticación.

## 🚀 Instalación y configuración

### Requisitos

- Flutter SDK instalado y configurado.
- Cuenta de Supabase con el proyecto configurado.
- Android Studio o VS Code con las extensiones de Flutter/Dart.
- Para compilar para iOS: macOS con Xcode.

### 1. Clonar el repositorio

    git clone https://github.com/thelifeofalvaro/pidam-vehiculoAlDia.git
    cd pidam-vehiculoAlDia/vad_app

### 2. Instalar dependencias

    flutter pub get

### 3. Configurar Supabase

Crear `dart_defines.json` con las credenciales del proyecto propias:

    {
      "SUPABASE_URL": "https://tu-proyecto.supabase.co",
      "SUPABASE_ANON_KEY": "tu-anon-key"
    }

Mi archivo no está subido al repositorio.

### 4. Ejecutar la aplicación

    flutter run --dart-define-from-file=dart_defines.json

## 📚 Documentación adicional

- [`database/database.md`](database/database.md) — esquema de la base de datos, políticas RLS e integración con Supabase Auth.
- [`docs/supabase/supabase.md`](docs/supabase/supabase.md) — configuración de Supabase, Storage y despliegue.
- [`docs/diagramas/`](docs/diagramas/) — diagramas técnicos del proyecto.

## 📌 Estado

**Completado.**

Proyecto desarrollado como parte del **CFGS en Desarrollo de Aplicaciones Multiplataforma (DAM)**.

## 👤 Autor

**Álvaro Medina**

Desarrollo de Aplicaciones Multiplataforma · Data & Analytics · Software Development

[GitHub](https://github.com/thelifeofalvaro)
