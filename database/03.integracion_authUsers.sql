-- Añadir campo auth_id para relación con auth.users (tabla automatica Supabase)

ALTER TABLE usuarios
ADD COLUMN auth_id UUID UNIQUE;

-- Funcion para relacionar nombre (en tabla usuarios) con display_name (en tabla users) 
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.usuarios (id, email, nombre)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'display_name'
  );
  return new;
end;
$$ language plpgsql security definer;
