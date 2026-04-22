import 'package:flutter/material.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:vad_app/core/app_text_styles.dart';
import 'package:vad_app/core/utils/error_utils.dart';

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
                    /// Top Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 28,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_square,
                              size: 24,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/vehicle-manage',
                                arguments: vehicle,
                              );

                              if (result == true && context.mounted) {
                                try {
                                  final updated = await VehicleRepository()
                                      .getVehicleById(vehicle.id);
                                  setState(() {
                                    _vehicle = updated;
                                  });
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ErrorUtils.mensajeLegible(
                                            e,
                                            contexto:
                                                'actualizar los datos del vehículo',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Imagen
                    Container(
                      child: vehicle.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: NetworkImage(vehicle.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
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
                            Text(marcaModelo, style: AppTextStyles.heading3),
                            const SizedBox(height: 8),

                            /// Matrícula (Formato para destacar)
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
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.carbonBlack,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// Bastidor/VIN
                            Text(
                              'Bastidor/VIN: ${vehicle.bastidor ?? 'N/A'}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 21),

                    /// Datos (km, tipo, año) en fila de 3 tarjetas
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

                    /// BOTÓN HISTORIAL
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
                              try {
                                final updated = await VehicleRepository()
                                    .getVehicleById(vehicle.id);
                                setState(() {
                                  _vehicle = updated;
                                });
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ErrorUtils.mensajeLegible(
                                          e,
                                          contexto:
                                              'refrescar los datos del vehículo',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: Text(
                            'Historial',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.cardWhite,
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

            /// BOTTOM TAB BAR
            AppBottomNavBar(
              currentIndex: -1, //Ninguno seleccionado, detalle para mejorar UI
              vehicle: vehicle,
            ),
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
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.carbonBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
