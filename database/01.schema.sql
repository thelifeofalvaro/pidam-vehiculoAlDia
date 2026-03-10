-- Creamos el Tipo ENUM para roles de la app
CREATE TYPE rol_usuario AS ENUM ('usuario', 'admin');

-- Tabla usuarios
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  rol rol_usuario DEFAULT 'usuario',
  fecha_registro TIMESTAMP DEFAULT NOW()
);

-- Tabla vehiculos
CREATE TABLE vehiculos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo TEXT,
  marca TEXT,
  modelo TEXT,
  matricula TEXT,
  anio_matricula INT,
  bastidor TEXT,
  km_vh INT,
  fecha_creacion TIMESTAMP DEFAULT NOW()
);

-- Tabla intervenciones
CREATE TABLE intervenciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  tipo_intervencion TEXT,
  descripcion TEXT,
  coste NUMERIC,
  notas TEXT,
  km_intervencion INT,
  url_adjunto TEXT,
  fecha_intervencion TIMESTAMP
);