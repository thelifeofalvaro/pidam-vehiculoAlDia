import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de autenticación. Centraliza las operaciones de
/// login, registro y cierre de sesión con Supabase Auth.

class AuthService {
  // Cliente de Supabase
  final SupabaseClient _client = Supabase.instance.client;

  /// Registra un nuevo usuario en Supabase Auth.
  /// Supabase envía un email de confirmación automáticamente.
  /// El usuario no puede iniciar sesión hasta validar el correo.
  Future<void> signUp({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final cleanName = nombre.trim().replaceAll(' ', '');

    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': cleanName},
    );
  }

  /// Inicia sesión con email y contraseña.
  /// Lanza excepción si las credenciales son incorrectas
  /// o si el email no ha sido confirmado todavía.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cerrar Sesión
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Usuario Actual
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
