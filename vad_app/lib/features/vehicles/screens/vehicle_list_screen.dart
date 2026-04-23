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
      final data = await _repository.getVehicles();

      setState(() {
        vehicles = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando vehículos: $e')));
    }
  }

  Future<void> goToCreate() async {
    final result = await Navigator.pushNamed(context, '/vehicle-manage');

    // Recarga al crear algo
    if (result == true) {
      loadVehicles();
    }
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
                  leading: v.imageUrl != null
                      ? Image.network(
                          v.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.directions_car),
                );
              },
            ),
    );
  }
}
