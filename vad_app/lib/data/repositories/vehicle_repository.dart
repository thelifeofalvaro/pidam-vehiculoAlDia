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
        .eq('usuario_id', user.id);

    // 🔥 DEBUG IMPORTANTE
    print('USER ID: ${user.id}');
    print('RESPONSE: $response');

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
}
