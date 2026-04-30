# BBDD Vehículo Al Día
Documentación completa del esquema de base de datos, políticas de seguridad e integración con Supabase Auth.

La base de datos es PostgreSQL gestionada por Supabase. Toda la lógica de seguridad se implementa directamente en la base de datos mediante políticas RLS, de modo que el código Flutter no necesita filtrar manualmente por usuario — Supabase aplica las restricciones antes de devolver cualquier dato.

## Esquema de tablas
 
### `usuarios`
 
Almacena el perfil de cada usuario registrado. El campo `id` es una clave foránea hacia `auth.users` (la tabla interna de Supabase Auth), lo que vincula cada perfil con su cuenta de autenticación.
 
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, NOT NULL | Mismo UUID que `auth.users.id` |
| `nombre` | `text` | nullable | Nombre de usuario (sin espacios) |
| `rol` | `rol_usuario` (ENUM) | default `'usuario'` | Rol del usuario en la app |
| `fecha_registro` | `timestamp` | default `now()` | Fecha de creación del perfil |
| `avatar_url` | `text` | nullable | URL pública de la foto de perfil en Storage |

### `vehiculos`
 
Almacena los vehículos registrados por cada usuario.
 
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, default `gen_random_uuid()` | Identificador único del vehículo |
| `usuario_id` | `uuid` | FK → `usuarios.id` | Propietario del vehículo |
| `tipo` | `text` | nullable | Tipo de vehículo (Coche, Moto, etc.) |
| `marca` | `text` | nullable | Marca del vehículo |
| `modelo` | `text` | nullable | Modelo del vehículo |
| `matricula` | `text` | nullable | Matrícula |
| `a_matricula` | `integer` | nullable | Año de matriculación |
| `bastidor` | `text` | nullable | Número de bastidor / VIN |
| `km_vh` | `integer` | nullable | Kilometraje actual |
| `fecha_creacion` | `timestamp` | default `now()` | Fecha de alta en la app |

### `intervenciones`
 
Almacena cada intervención registrada sobre un vehículo.
 
| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `uuid` | PK, default `gen_random_uuid()` | Identificador único de la intervención |
| `vehiculo_id` | `uuid` | FK → `vehiculos.id` ON DELETE CASCADE | Vehículo al que pertenece |
| `tipo_intervencion` | `tipo_intervencion` (ENUM) | nullable | Categoría de la intervención |
| `descripcion` | `text` | nullable | Descripción libre |
| `coste` | `numeric` | nullable | Coste económico (acepta decimales) |
| `notas` | `text` | nullable | Notas adicionales |
| `km_intervencion` | `integer` | nullable | Kilometraje en el momento de la intervención |
| `url_adjunto` | `text` | nullable | URL del documento adjunto en Storage |
| `fecha_intervencion` | `timestamp` | nullable | Fecha en que se realizó la intervención |
| `lugar` | `lugar_intervencion` (ENUM) | nullable | Casa o taller |
| `image_url` | `text` | nullable | URL pública de la foto del vehículo en Storage |

## Relaciones entre tablas
 
```
auth.users (Supabase Auth)
    │
    │ id = id
    │
    ▼
usuarios
    │
    │ usuario_id
    │
    ▼
vehiculos
    │
    │ ON DELETE CASCADE
    │
    ▼
intervenciones (vehiculo_id)
```
La relación `ON DELETE CASCADE` entre `vehiculos` e `intervenciones` garantiza que al eliminar un vehículo, todas sus intervenciones se eliminan automáticamente en la base de datos, sin necesidad de lógica adicional en el código Flutter.

## Integración con Supabase Auth
 
Supabase gestiona la autenticación en la tabla interna `auth.users`, separada del esquema `public`. La tabla `usuarios` del esquema público actúa como tabla de perfil extendido.
 
**Flujo de registro:**
 
1. El usuario se registra mediante `supabase.auth.signUp()` — Supabase crea una fila en `auth.users`.
2. Un trigger de base de datos (o la app en el primer login) crea la fila correspondiente en `public.usuarios` con el mismo `id`.
3. El email y la contraseña viven exclusivamente en `auth.users` — la tabla `usuarios` nunca almacena credenciales.

**Función `auth.uid()`:**
 
Supabase expone `auth.uid()` como función SQL que devuelve el UUID del usuario autenticado en la sesión actual. Todas las políticas RLS la utilizan para filtrar filas por propietario.
 
## Row Level Security (RLS)
 
RLS está activado en las tres tablas del esquema público. Esto significa que aunque un usuario tenga la `anonKey` de Supabase, **solo puede acceder a sus propios datos** — las políticas se evalúan en el servidor antes de devolver cualquier resultado.

| Política | Operación | Expresión |
|---|---|---|
| Usuario puede ver su perfil | SELECT | `auth.uid() = id` |
| Usuario puede insertarse | INSERT | `auth.uid() = id` |
| Usuario actualiza su perfil | UPDATE | `auth.uid() = id` |
| Usuario puede eliminar su perfil | DELETE | `auth.uid() = id` |
 
La condición `auth.uid() = id` garantiza que un usuario solo puede leer y modificar su propia fila.

### Tabla `vehiculos`
 
| Política | Operación | Expresión |
|---|---|---|
| Ver vehículos propios | SELECT | `usuario_id = auth.uid()` |
| Insertar vehículos propios | INSERT (WITH CHECK) | `auth.uid() = usuario_id` |
| Actualizar vehículos propios | UPDATE | `auth.uid() = usuario_id` |
| Eliminar vehículos propios | DELETE | `auth.uid() = usuario_id` |
 
Gracias a estas políticas, la consulta del repositorio no necesita filtrar manualmente.

### Tabla `intervenciones`
 
Las intervenciones se relacionan con `vehiculos`, que a su vez se relaciona con `usuarios`. Las políticas usan una subconsulta `EXISTS` para verificar la propiedad de forma indirecta:
 
| Política | Operación | Expresión |
|---|---|---|
| Ver intervenciones propias | SELECT | `EXISTS (SELECT 1 FROM vehiculos v WHERE v.id = vehiculo_id AND v.usuario_id = auth.uid())` |
| Insertar intervenciones propias | INSERT (WITH CHECK) | `EXISTS (SELECT 1 FROM vehiculos v WHERE v.id = vehiculo_id AND v.usuario_id = auth.uid())` |
| Actualizar intervenciones propias | UPDATE | `EXISTS (SELECT 1 FROM vehiculos WHERE id = vehiculo_id AND usuario_id = auth.uid())` |
| Eliminar intervenciones propias | DELETE | `EXISTS (SELECT 1 FROM vehiculos v WHERE v.id = vehiculo_id AND v.usuario_id = auth.uid())` |
 
Este patrón garantiza que un usuario no puede ver ni modificar intervenciones de vehículos que no le pertenecen, aunque conozca el `vehiculo_id`.

- **USING**: se evalúa sobre las filas existentes. Se usa en SELECT, UPDATE y DELETE para filtrar qué filas puede leer o afectar el usuario.
- **WITH CHECK**: se evalúa sobre los datos nuevos que el usuario quiere escribir. Se usa en INSERT y UPDATE para validar que los datos a insertar son válidos.
En las políticas de INSERT de este proyecto, `WITH CHECK` asegura que un usuario no pueda crear un vehículo con el `usuario_id` de otra persona.

## ENUM personalizados
 
La base de datos utiliza tipos ENUM para campos con valores controlados, evitando que se inserten valores arbitrarios:

### `rol_usuario`
 
Valores permitidos para el campo `rol` de `usuarios` (admin o usuario)
 
### `tipo_intervencion`
 
Valores permitidos para el campo `tipo_intervencion` en las `intervenciones` (reparación, modificación, mejora, revisión, otros)
 
### `lugar_intervencion`
 
Valores permitidos para el campo `lugar` donde se realizan las  `intervenciones`(casa, taller)

### Para consultar los scripts ve a `/database` de este repositorio
 
