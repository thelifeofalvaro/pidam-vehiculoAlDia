import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

/// Repositorio de perfil de usuario.

class ProfileRepository {
  final supabase = Supabase.instance.client;

  /// Obtiene el perfil del usuario autenticado.
  /// Usa maybeSingle() para evitar excepciones
  /// Aunque se gestiona externamente con la
  /// condición de Supabase de validar mail
  /// para poder iniciar sesión

  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    /// Datos de la tabla usuarios
    final data = await supabase
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return Profile(
      id: user.id,
      nombre: data?['nombre'],
      email: user.email, //Mail viene de Auth
      avatarUrl: data?['avatar_url'],
    );
  }

  /// Actualiza nombre y avatar en la tabla usuarios.
  /// No se toca el email, pprque es de Supabase Auth
  Future<void> updateProfile(Profile profile) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) throw Exception('Usuario no autenticado');

    /// Actualizar tabla usuarios
    await supabase
        .from('usuarios')
        .update({'nombre': profile.nombre})
        .eq('id', user.id);

    /// Sincronizar con Auth
    await supabase.auth.updateUser(
      UserAttributes(data: {'display_name': profile.nombre}),
    );
  }
}
