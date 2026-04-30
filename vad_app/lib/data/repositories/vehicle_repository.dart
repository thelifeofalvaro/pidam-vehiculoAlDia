import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

/// Repositorio de vehículos. Encapsula todas las operaciones con Supabase.

class VehicleRepository {
  final _client = Supabase.instance.client;

  /// Obtiene todos los vehículos del usuario autenticado,
  /// ordenados por fecha de creación (más antiguo primero).
  Future<List<Vehicle>> getVehicles() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('vehiculos')
        .select()
        .eq('usuario_id', user.id)
        .order('fecha_creacion', ascending: true);

    return (response as List).map((e) => Vehicle.fromJson(e)).toList();
  }

  /// Crea un nuevo vehículo. El usuario_id se extrae de Auth
  /// en lugar de recibirlo como parámetro, para garantizar que
  /// nadie puede crear un vehículo con el usuario_id de otro usuario.
  Future<void> createVehicle(Vehicle vehicle) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final payload = vehicle.toJson();
    payload['usuario_id'] = user.id;

    await _client.from('vehiculos').insert(payload);
  }

  /// Actualizar vehículo
  Future<void> updateVehicle(Vehicle vehicle) async {
    // No enviamos id al JSON
    final data = vehicle.toJson();

    await _client.from('vehiculos').update(data).eq('id', vehicle.id);
  }

  /// Eliminar vehículo
  Future<void> deleteVehicle(String vehicleId) async {
    await _client.from('vehiculos').delete().eq('id', vehicleId);
  }

  /// Obtiene un vehículo por ID. Se usa tras editar o volver del
  /// historial para refrescar los datos de pantalla sin recargar toda la lista.
  Future<Vehicle> getVehicleById(String id) async {
    final response = await _client
        .from('vehiculos')
        .select()
        .eq('id', id)
        .single();

    return Vehicle.fromJson(response);
  }
}
