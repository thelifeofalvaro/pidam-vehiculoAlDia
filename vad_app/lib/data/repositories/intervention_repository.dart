import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/intervention_model.dart';

/// Repositorio de intervenciones.
class InterventionRepository {
  final _client = Supabase.instance.client;

  /// Obtiene las intervenciones de un vehículo ordenadas por fecha
  /// descendente (la más reciente aparece primero en el historial).
  /// RLS garantiza que solo se devuelven intervenciones de vehículos propios.
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

  /// Crea una nueva intervención.
  Future<void> createIntervention(Intervention intervention) async {
    await _client.from('intervenciones').insert(intervention.toMap());
  }

  /// Actualiza una intervención existente.
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
