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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}
