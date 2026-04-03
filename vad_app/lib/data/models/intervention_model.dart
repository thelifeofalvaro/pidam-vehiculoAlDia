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
}
