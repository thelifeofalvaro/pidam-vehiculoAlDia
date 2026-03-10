-- Añadir campo auth_id para relación con auth.users (tabla automatica Supabase)

ALTER TABLE usuarios
ADD COLUMN auth_id UUID UNIQUE;