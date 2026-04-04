import 'package:flutter/material.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/presentation/widgets/app_bottom_nav_bar.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  Vehicle? _vehicle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_vehicle == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Vehicle;
      _vehicle = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_vehicle == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final vehicle = _vehicle!;
    final String marcaModelo = '${vehicle.marca ?? ''} ${vehicle.modelo ?? ''}'
        .trim();

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            /// Contenido principal (ficha)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// 🔹 TOP BAR
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 28,
                              color: AppColors.carbonBlack,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_square,
                              size: 24,
                              color: AppColors.carbonBlack,
                            ),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/vehicle-manage',
                                arguments: vehicle,
                              );

                              if (result == true && context.mounted) {
                                final updated = await VehicleRepository()
                                    .getVehicleById(vehicle.id);
                                setState(() {
                                  _vehicle = updated;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Imagen
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cloudWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://via.placeholder.com/400x200?text=Vehículo',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.cloudWhite,
                            child: const Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 80,
                                color: AppColors.secondarySteel,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 21),

                    /// Tarjeta Datos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cloudWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Marca/Modelo (bold)
                            Text(
                              marcaModelo,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: AppColors.carbonBlack,
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// Matrícula (tagged style)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vehicle.matricula ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// Bastidor/VIN
                            Text(
                              'Bastidor/VIN: ${vehicle.bastidor ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Roboto',
                                color: AppColors.secondarySteel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 21),

                    /// 🔹 STAT CARDS (3 columnas: km, tipo, año)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          /// Km
                          Expanded(
                            child: _statCard(
                              icon: Icons.speed,
                              value: '${vehicle.kmVh ?? 0}',
                              label: 'km',
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// Tipo
                          Expanded(
                            child: _statCard(
                              icon: Icons.bolt,
                              value: vehicle.tipo ?? 'N/A',
                              label: 'Tipo',
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// Año
                          Expanded(
                            child: _statCard(
                              icon: Icons.calendar_today,
                              value:
                                  vehicle.anioMatriculacion?.toString() ??
                                  'N/A',
                              label: 'Año',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 21),

                    /// 🔹 BOTÓN HISTORIAL (orange)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.actionOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/intervention-list',
                              arguments: vehicle,
                            );

                            /// Función de refresco, tambien cambia al añadir una nueva intervención
                            if (result == true) {
                              final updated = await VehicleRepository()
                                  .getVehicleById(vehicle.id);

                              setState(() {
                                _vehicle = updated;
                              });
                            }
                          },
                          child: const Text(
                            'Historial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            /// 🔹 BOTTOM TAB BAR
            AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.actionOrange),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: AppColors.carbonBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Roboto',
              color: AppColors.secondarySteel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
