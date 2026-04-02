import 'package:flutter/material.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleRepository _repository = VehicleRepository();

  List<Vehicle> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      print('🔄 Cargando vehículos...');

      final data = await _repository.getVehicles();

      print('✅ Vehículos obtenidos: $data');

      setState(() {
        vehicles = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR CARGANDO VEHICULOS: $e');

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando vehículos: $e')));
    }
  }

  Future<void> goToCreate() async {
    final result = await Navigator.pushNamed(context, '/vehicle-manage');

    // 🔥 SOLO recarga si realmente se ha creado algo
    if (result == true) {
      print('🔁 Recargando lista tras crear vehículo...');
      loadVehicles();
    }
    print('🚗 ESTOY EN VEHICLE LIST SCREEN');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),

      floatingActionButton: FloatingActionButton(
        onPressed: goToCreate,
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? const Center(child: Text('No hay vehículos'))
          : ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];

                return ListTile(
                  title: Text(v.matricula ?? 'Sin matrícula'),
                  subtitle: Text('${v.marca ?? ''} ${v.modelo ?? ''}'),
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/vehicle-detail',
                      arguments: v,
                    );

                    if (result == true) {
                      loadVehicles();
                    }
                  },
                );
              },
            ),
    );
  }
}
