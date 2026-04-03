import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/intervention_model.dart';

class InterventionRepository {
  final _client = Supabase.instance.client;

  // Obtener intervenciones por vehículo
  Future<List<Intervention>> getInterventionsByVehicle(
    String vehiculoId,
  ) async {
    final response = await _client
        .from('intervenciones')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('fecha_intervencion', ascending: false);

    return (response as List).map((e) => Intervention.fromMap(e)).toList();
  }

  // Crear intervención
  Future<void> createIntervention(Intervention intervention) async {
    await _client.from('intervenciones').insert(intervention.toMap());
  }

  // Actualizar intervención
  Future<void> updateIntervention(Intervention intervention) async {
    await _client
        .from('intervenciones')
        .update(intervention.toMap())
        .eq('id', intervention.id);
  }

  // Eliminar intervención
  Future<void> deleteIntervention(String id) async {
    await _client.from('intervenciones').delete().eq('id', id);
  }
}
