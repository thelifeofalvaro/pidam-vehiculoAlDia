// Recogemos las credenciales de Supabase desde variables de entorno del dart_defines.json
// Con esto mantenemos las credenciales fuera del código fuente y podemos configurarlas fácilmente para diferentes entornos (desarrollo, producción, etc.)

class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
}
