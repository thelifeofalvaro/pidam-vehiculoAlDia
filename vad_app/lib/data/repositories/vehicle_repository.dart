import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final _client = Supabase.instance.client;

  /// Obtener vehículos del usuario
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

  /// Crear vehículo
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

  Future<Vehicle> getVehicleById(String id) async {
    final response = await _client
        .from('vehiculos')
        .select()
        .eq('id', id)
        .single();

    return Vehicle.fromJson(response);
  }
}
