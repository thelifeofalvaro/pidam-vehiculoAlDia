import 'package:flutter/material.dart';
import 'package:vad_app/data/models/vehicle_model.dart';
import 'package:vad_app/data/repositories/vehicle_repository.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/presentation/widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando vehículos: $e')));
    }
  }

  Future<void> goToCreate() async {
    final result = await Navigator.pushNamed(context, '/vehicle-manage');

    // Refresca tras crear
    if (result == true) {
      loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVehicles = vehicles.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasVehicles
                  ? _HomeWithData(
                      vehicles: vehicles,
                      onAddVehicle: goToCreate,
                      onRefresh: loadVehicles,
                    )
                  : _HomeEmptyState(onAddVehicle: goToCreate),
            ),
            AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Vehículo Al Día',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: AppColors.primaryBlue,
            ),
          ),
          const Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 312),
              child: Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/images/vacio_vehiculos.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aún no tienes vehículos registrados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: AppColors.carbonBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Añade tu primer vehículo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 22 / 15,
                      color: AppColors.textSteel,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 206,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onAddVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                        foregroundColor: AppColors.carbonBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Añadir Vehículo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 22 / 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _HomeWithData extends StatelessWidget {
  const _HomeWithData({
    required this.vehicles,
    required this.onAddVehicle,
    required this.onRefresh,
  });

  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Vehículo Al Día',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 24 / 18,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '${vehicles.length} Vehículos registrados',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 28 / 22,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 17),
              Expanded(
                child: ListView.separated(
                  itemCount: vehicles.length,
                  padding: const EdgeInsets.only(bottom: 92),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final v = vehicles[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/vehicle-detail',
                          arguments: v,
                        );

                        if (result == true) {
                          await onRefresh();
                        }
                      },
                      child: Container(
                        height: 110,
                        padding: const EdgeInsets.fromLTRB(16, 15, 20, 13),
                        decoration: BoxDecoration(
                          color: AppColors.cloudWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: v.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        v.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.asset(
                                          'assets/images/vacio_vehiculos.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/vacio_vehiculos.png',
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${v.marca ?? ''} ${v.modelo ?? ''}'.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 24 / 18,
                                      color: AppColors.carbonBlack,
                                    ),
                                  ),
                                  Text(
                                    v.matricula ?? 'Matrícula',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      height: 18 / 13,
                                      color: AppColors.textSteel,
                                    ),
                                  ),
                                  Text(
                                    '${v.kmVh ?? 0} Km',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 22 / 16,
                                      color: AppColors.textSteel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.actionOrange,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: onAddVehicle,
              backgroundColor: AppColors.actionOrange,
              foregroundColor: AppColors.carbonBlack,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 34),
            ),
          ),
        ),
      ],
    );
  }
}
