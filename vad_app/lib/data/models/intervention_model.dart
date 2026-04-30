/// Modelo que representa una intervención sobre un vehículo.
/// Corresponde a la tabla [intervenciones] en Supabase.
/// La relación con el vehículo es a través de [vehiculoId] (FK).
/// Si el vehículo se elimina, la intervención se elimina en cascada
/// automáticamente gracias a la restricción ON DELETE CASCADE de la BBDD.

class Intervention {
  final String id;
  final String vehiculoId;
  final String? tipoIntervencion;
  final String? descripcion;
  final double? coste;
  final String? notas;
  final int? kmIntervencion;
  final String? urlAdjunto;
  final DateTime? fechaIntervencion;
  final String? lugar;

  Intervention({
    required this.id,
    required this.vehiculoId,
    this.tipoIntervencion,
    this.descripcion,
    this.coste,
    this.notas,
    this.kmIntervencion,
    this.urlAdjunto,
    this.fechaIntervencion,
    this.lugar,
  });

  /// Los timestamps llegan como String desde Supabase.
  /// Se parsean con DateTime.parse() para evitar excepciones
  /// si el campo es null o tiene formato inesperado.

  factory Intervention.fromMap(Map<String, dynamic> map) {
    return Intervention(
      id: map['id'],
      vehiculoId: map['vehiculo_id'],
      tipoIntervencion: map['tipo_intervencion'],
      descripcion: map['descripcion'],
      coste: (map['coste'] as num?)?.toDouble(),
      notas: map['notas'],
      kmIntervencion: map['km_intervencion'],
      urlAdjunto: map['url_adjunto'],
      fechaIntervencion: map['fecha_intervencion'] != null
          ? DateTime.parse(map['fecha_intervencion'])
          : null,
      lugar: map['lugar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehiculo_id': vehiculoId,
      'tipo_intervencion': tipoIntervencion,
      'descripcion': descripcion,
      'coste': coste,
      'notas': notas,
      'km_intervencion': kmIntervencion,
      'url_adjunto': urlAdjunto,
      'fecha_intervencion': fechaIntervencion?.toIso8601String(),
      'lugar': lugar,
    };
  }

  Intervention copyWith({
    String? id,
    String? vehiculoId,
    String? tipoIntervencion,
    String? descripcion,
    double? coste,
    String? notas,
    int? kmIntervencion,
    String? urlAdjunto,
    DateTime? fechaIntervencion,
    String? lugar,
  }) {
    return Intervention(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      tipoIntervencion: tipoIntervencion ?? this.tipoIntervencion,
      descripcion: descripcion ?? this.descripcion,
      coste: coste ?? this.coste,
      notas: notas ?? this.notas,
      kmIntervencion: kmIntervencion ?? this.kmIntervencion,
      urlAdjunto: urlAdjunto ?? this.urlAdjunto,
      fechaIntervencion: fechaIntervencion ?? this.fechaIntervencion,
      lugar: lugar ?? this.lugar,
    );
  }
}
