-- Activar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE intervenciones ENABLE ROW LEVEL SECURITY;

-- =========================
-- USUARIOS
-- =========================

-- El usuario solo ve su perfil
CREATE POLICY "Usuario ve su perfil"
ON usuarios
FOR SELECT
USING (auth.uid() = id);

-- El usuario puede insertar su perfil
CREATE POLICY "Usuario crea su perfil"
ON usuarios
FOR INSERT
WITH CHECK (auth.uid() = id);

-- =========================
-- VEHICULOS
-- =========================

-- Ver solo sus vehículos
CREATE POLICY "Ver vehiculos propios"
ON vehiculos
FOR SELECT
USING (auth.uid() = usuario_id);

-- Insertar solo propios
CREATE POLICY "Insertar vehiculos propios"
ON vehiculos
FOR INSERT
WITH CHECK (auth.uid() = usuario_id);

-- Actualizar solo propios
CREATE POLICY "Actualizar vehiculos propios"
ON vehiculos
FOR UPDATE
USING (auth.uid() = usuario_id);

-- Eliminar solo propios
CREATE POLICY "Eliminar vehiculos propios"
ON vehiculos
FOR DELETE
USING (auth.uid() = usuario_id);

-- =========================
-- INTERVENCIONES
-- =========================

-- Ver intervenciones de sus vehículos
CREATE POLICY "Ver intervenciones propias"
ON intervenciones
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM vehiculos
    WHERE vehiculos.id = intervenciones.vehiculo_id
    AND vehiculos.usuario_id = auth.uid()
  )
);

-- Insertar intervenciones
CREATE POLICY "Insertar intervenciones propias"
ON intervenciones
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM vehiculos
    WHERE vehiculos.id = vehiculo_id
    AND vehiculos.usuario_id = auth.uid()
  )
);

-- Actualizar intervenciones
CREATE POLICY "Actualizar intervenciones propias"
ON intervenciones
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM vehiculos
    WHERE vehiculos.id = vehiculo_id
    AND vehiculos.usuario_id = auth.uid()
  )
);

-- Eliminar intervenciones
CREATE POLICY "Eliminar intervenciones propias"
ON intervenciones
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM vehiculos
    WHERE vehiculos.id = vehiculo_id
    AND vehiculos.usuario_id = auth.uid()
  )
);

-- Ver archivos usuario
CREATE POLICY "Usuarios solo ven sus archivos"
ON storage.objects
FOR SELECT
USING (auth.uid()::text = (storage.foldername(name))[1]);