import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Cliente de Supabase
  final SupabaseClient _client = Supabase.instance.client;

  /// Registro
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Login - Inicio Sesión
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
