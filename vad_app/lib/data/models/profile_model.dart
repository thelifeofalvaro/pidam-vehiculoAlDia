// Modelo que combina datos de Supabase Auth (auth.users)
// - [id] y [email] y [nombre] y [avatarUrl] de la tabla [usuarios]
// El email  solo se almacena en auth.users para evitar
// duplicidades en [usuarios]
// Se lee de: supabase.auth.currentUser?.email

class Profile {
  final String id;
  final String? nombre;
  final String? email;
  final String? avatarUrl;

  Profile({required this.id, this.nombre, this.email, this.avatarUrl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }

  /// No incluye 'email' en toJson() por lo mencionado anteriormente
  /// Intentar actualizarlo daría error de permisos

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'avatar_url': avatarUrl};
  }

  Profile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? avatarUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
