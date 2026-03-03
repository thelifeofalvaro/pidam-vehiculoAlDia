# Archivos relacionados con la BBDD

Insertar referencias a archivos esquema y politicas rls

# Almacenamiento de archivos

Se utiliza Supabase Storage para guardar archivos asociados a intervenciones.

## Restricciones
- Tamaño máximo: 2MB
- Formatos: PDF, JPG, PNG

## Seguridad
Los archivos se almacenan en carpetas por usuario:
user_id/nombre_archivo

Se aplican políticas de acceso mediante RLS.
