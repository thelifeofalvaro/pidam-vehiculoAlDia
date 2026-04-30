/// Modelo que representa un vehículo registrado por el usuario.
/// Corresponde a la tabla [vehiculos] en Supabase.

class Vehicle {
  final String id;
  final String usuarioId;
  final String? tipo;
  final String? marca;
  final String? modelo;
  final String? matricula;
  final int? anioMatriculacion;
  final String? bastidor;
  final int? kmVh;
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.usuarioId,
    this.tipo,
    this.marca,
    this.modelo,
    this.matricula,
    this.anioMatriculacion,
    this.bastidor,
    this.kmVh,
    this.imageUrl,
  });

  /// JSON → objeto
  /// Construye un Vehicle desde la respuesta JSON de Supabase.
  /// Nota: el año se almacena como [a_matricula] en la BBDD.
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      usuarioId: json['usuario_id'],
      tipo: json['tipo'],
      marca: json['marca'],
      modelo: json['modelo'],
      matricula: json['matricula'],
      anioMatriculacion: json['a_matricula'],
      bastidor: json['bastidor'],
      kmVh: json['km_vh'],
      imageUrl: json['image_url'],
    );
  }

  /// objeto → JSON
  /// Serializa para insertar o actualizar en Supabase.
  /// No incluye [id] en creaciones — Supabase lo genera con gen_random_uuid().
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'matricula': matricula,
      'a_matricula': anioMatriculacion,
      'bastidor': bastidor,
      'km_vh': kmVh,
      'image_url': imageUrl,
    };
  }

  /// Actualizar datos en memoria
  Vehicle copyWith({
    String? id,
    String? usuarioId,
    String? tipo,
    String? marca,
    String? modelo,
    String? matricula,
    int? anioMatriculacion,
    String? bastidor,
    int? kmVh,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      anioMatriculacion: anioMatriculacion ?? this.anioMatriculacion,
      bastidor: bastidor ?? this.bastidor,
      kmVh: kmVh ?? this.kmVh,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
