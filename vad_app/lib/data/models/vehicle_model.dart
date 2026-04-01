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
  });

  /// JSON → objeto
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
    );
  }

  /// objeto → JSON
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
    };
  }
}
