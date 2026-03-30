import 'package:flutter/material.dart';

class VehicleItem {
  const VehicleItem({
    required this.brandModel,
    required this.plate,
    required this.km,
  });

  final String brandModel;
  final String plate;
  final String km;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.vehicles = const []});

  static const Color _screenBackground = Color(0xFFEAEAEA);

  final List<VehicleItem> vehicles;

  @override
  Widget build(BuildContext context) {
    final bool hasVehicles = vehicles.isNotEmpty;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: hasVehicles
                  ? _HomeWithData(vehicles: vehicles)
                  : const _HomeEmptyState(),
            ),
            const _BottomTabBar(),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  static const Color _primaryBlue = Color(0xFF0047AB);
  static const Color _actionOrange = Color(0xFFFF8C00);
  static const Color _textSteel = Color(0xFF4A4A4A);
  static const Color _carbonBlack = Color(0xFF1A1A1A);

  static const String _emptyStateIconUrl =
      'https://www.figma.com/api/mcp/asset/5823caa8-d23d-4df0-b6f7-6a03c9fef920';

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
              color: _primaryBlue,
            ),
          ),
          const Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 312),
              child: Column(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Image.network(
                      _emptyStateIconUrl,
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
                      color: _carbonBlack,
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
                      color: _textSteel,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 206,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente: añadir vehículo'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _actionOrange,
                        foregroundColor: _carbonBlack,
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
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _HomeWithData extends StatelessWidget {
  const _HomeWithData({required this.vehicles});

  static const Color _primaryBlue = Color(0xFF0047AB);
  static const Color _actionOrange = Color(0xFFFF8C00);
  static const Color _textSteel = Color(0xFF4A4A4A);
  static const Color _cloudWhite = Color(0xFFF4F7F6);
  static const Color _carbonBlack = Color(0xFF1A1A1A);

  static const String _carCardImageUrl =
      'https://www.figma.com/api/mcp/asset/49c5018a-4aa6-4777-adc1-d3bf83796122';

  final List<VehicleItem> vehicles;

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
                  color: _primaryBlue,
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
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 17),
              Expanded(
                child: ListView.separated(
                  itemCount: vehicles.length,
                  padding: const EdgeInsets.only(bottom: 92),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = vehicles[index];
                    return Container(
                      height: 110,
                      padding: const EdgeInsets.fromLTRB(16, 15, 20, 13),
                      decoration: BoxDecoration(
                        color: _cloudWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              _carCardImageUrl,
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
                                  item.brandModel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 24 / 18,
                                    color: _carbonBlack,
                                  ),
                                ),
                                Text(
                                  item.plate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 18 / 13,
                                    color: _textSteel,
                                  ),
                                ),
                                Text(
                                  item.km,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 22 / 16,
                                    color: _textSteel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.chevron_right,
                            color: _actionOrange,
                            size: 24,
                          ),
                        ],
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: añadir vehículo'),
                  ),
                );
              },
              backgroundColor: _actionOrange,
              foregroundColor: _carbonBlack,
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

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar();

  static const Color _primaryBlue = Color(0xFF0047AB);
  static const Color _secondarySteel = Color(0xFF708090);

  @override
  Widget build(BuildContext context) {
    Widget tabItem({
      required IconData icon,
      required String label,
      required bool isActive,
      VoidCallback? onTap,
    }) {
      final Color color = isActive ? _primaryBlue : _secondarySteel;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 18 / 13,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 17),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _secondarySteel, width: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          tabItem(icon: Icons.home, label: 'Inicio', isActive: true),
          tabItem(
            icon: Icons.build,
            label: 'Historial',
            isActive: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial: próximamente')),
              );
            },
          ),
          tabItem(
            icon: Icons.account_circle_outlined,
            label: 'Perfil',
            isActive: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil: próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }
}
