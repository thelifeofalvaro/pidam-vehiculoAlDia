import 'package:flutter/material.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

const Color secondarySteel = Color(0xFF708090);

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  static const Color _screenBackground = Color(0xFFEAEAEA);
  static const Color _primaryBlue = Color(0xFF0047AB);
  static const Color _cloudWhite = Color(0xFFF4F7F6);
  static const Color _carbonBlack = Color(0xFF1A1A1A);
  static const Color _actionOrange = Color(0xFFFF8C00);
  static const Color _errorRed = Color(0xFFD32F2F);

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
      backgroundColor: _screenBackground,
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
                              color: _carbonBlack,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_square,
                              size: 24,
                              color: _carbonBlack,
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
                        color: _cloudWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://via.placeholder.com/400x200?text=Vehículo',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _cloudWhite,
                            child: const Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 80,
                                color: secondarySteel,
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
                          color: _cloudWhite,
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
                                color: _carbonBlack,
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
                                color: _primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vehicle.matricula ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                  color: _primaryBlue,
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
                                color: secondarySteel,
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
                            backgroundColor: _actionOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Historial próximamente'),
                              ),
                            );
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
            _BottomTabBar(
              onInicioTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
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
        color: _cloudWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: _actionOrange),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: _carbonBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Roboto',
              color: secondarySteel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 🔹 BOTTOM TAB BAR COMPONENT
class _BottomTabBar extends StatelessWidget {
  final VoidCallback? onInicioTap;

  const _BottomTabBar({this.onInicioTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 1, color: const Color(0xFFEAEAEA)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onInicioTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 24,
                          color: Color(0xFF708090),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Inicio',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF708090),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Historial próximamente')),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 24,
                          color: Color(0xFF708090),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Historial',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF708090),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil próximamente')),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 24,
                          color: Color(0xFF708090),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Perfil',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF708090),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
