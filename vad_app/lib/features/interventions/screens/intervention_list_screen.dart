import 'package:flutter/material.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/models/intervention_model.dart';
import '../../../data/repositories/intervention_repository.dart';

// Color tokens from Figma design
const Color primaryBlue = Color(0xFF0047AB);
const Color actionOrange = Color(0xFFFF8C00);
const Color titleBlack = Color(0xFF1A1A1A);
const Color textGray = Color(0xFF4A4A4A);
const Color secondaryGray = Color(0xFF708090);
const Color cardWhite = Color(0xFFFFFFFF);
const Color bgLightBlue = Color(0xFFF4F7F6);

class InterventionListScreen extends StatefulWidget {
  final Vehicle vehicle;

  const InterventionListScreen({super.key, required this.vehicle});

  @override
  State<InterventionListScreen> createState() => _InterventionListScreenState();
}

class _InterventionListScreenState extends State<InterventionListScreen> {
  final InterventionRepository _repository = InterventionRepository();
  List<Intervention> interventions = [];
  bool isLoading = true;
  String selectedFilterType = 'Todo';

  @override
  void initState() {
    super.initState();
    loadInterventions();
  }

  Future<void> loadInterventions() async {
    try {
      print('Cargando intervenciones...');
      final data = await _repository.getInterventionsByVehicle(
        widget.vehicle.id,
      );
      print('Intervenciones obtenidas: ${data.length}');
      setState(() {
        interventions = data;
        isLoading = false;
      });
    } catch (e) {
      print('ERROR CARGANDO INTERVENCIONES: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando intervenciones: $e')),
        );
      }
    }
  }

  Future<void> goToCreate() async {
    final result = await Navigator.pushNamed(
      context,
      '/intervention-manage',
      arguments: widget.vehicle,
    );
    if (result == true) {
      print('Recargando lista tras crear intervención...');
      loadInterventions();
    }
  }

  double getTotalCost() {
    return interventions.fold<double>(
      0,
      (sum, item) => sum + (item.coste ?? 0.0),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}. ${date.year}';
  }

  String formatCost(double? cost) {
    if (cost == null) return '0,00€';
    return '${cost.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardWhite,
      appBar: AppBar(
        backgroundColor: cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historial Vehículo',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      floatingActionButton: interventions.isNotEmpty
          ? FloatingActionButton(
              onPressed: goToCreate,
              backgroundColor: actionOrange,
              child: const Icon(Icons.add, color: titleBlack),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : interventions.isEmpty
          ? _buildEmptyState()
          : _buildDataState(),
    );
  }

  // Empty state design
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 160),
            Center(
              child: Column(
                children: [
                  // Icon placeholder (clipboard icon)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: bgLightBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: secondaryGray, width: 1),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 50,
                      color: secondaryGray,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Aún no tienes intervenciones registradas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: titleBlack,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Añade tu primera intervención',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: textGray,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 206,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: goToCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Añadir Intervención',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleBlack,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Data state design with timeline
  Widget _buildDataState() {
    return Column(
      children: [
        // Filter buttons and vehicle info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter buttons row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('Todo', 'Todo' == selectedFilterType),
                    const SizedBox(width: 7),
                    _buildFilterButton(
                      'Revisión',
                      'Revisión' == selectedFilterType,
                    ),
                    const SizedBox(width: 7),
                    _buildFilterButton(
                      'Reparación',
                      'Reparación' == selectedFilterType,
                    ),
                    const SizedBox(width: 7),
                    _buildFilterButton(
                      'Mejoras',
                      'Mejoras' == selectedFilterType,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Vehicle info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgLightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.vehicle.marca} ${widget.vehicle.modelo}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: titleBlack,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cardWhite,
                            border: Border.all(color: titleBlack, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.vehicle.matricula ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: titleBlack,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Gasto total en este vehículo: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: textGray,
                              fontFamily: 'Inter',
                            ),
                          ),
                          TextSpan(
                            text: formatCost(getTotalCost()),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: titleBlack,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Timeline of interventions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: interventions.length,
            itemBuilder: (context, index) {
              return _buildTimelineItem(interventions[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Intervention intervention, int index) {
    final isLast = index == interventions.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Icon circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgLightBlue,
                shape: BoxShape.circle,
                border: Border.all(color: secondaryGray, width: 2),
              ),
              child: Icon(
                _getInterventionIcon(intervention.tipoIntervencion),
                size: 16,
                color: secondaryGray,
              ),
            ),
            // Vertical line
            if (!isLast)
              Container(
                width: 2,
                height: 72,
                color: secondaryGray,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Card with intervention details (tappable for editing)
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/intervention-manage',
                arguments: intervention,
              );
              if (result == true) {
                loadInterventions();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgLightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intervention.tipoIntervencion ?? 'Sin tipo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleBlack,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formatDate(intervention.fechaIntervencion)} • ${intervention.kmIntervencion ?? 0} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: secondaryGray,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        formatCost(intervention.coste),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleBlack,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryBlue : cardWhite,
        border: Border.all(
          color: isSelected ? primaryBlue : primaryBlue,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isSelected ? cardWhite : primaryBlue,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  IconData _getInterventionIcon(String? type) {
    return switch (type?.toLowerCase()) {
      'cambio de aceite' => Icons.oil_barrel_outlined,
      'cambio de neumáticos' => Icons.tire_repair_outlined,
      'revisión' => Icons.assignment_outlined,
      'reparación' => Icons.handyman_outlined,
      'mejora' => Icons.star_outline,
      _ => Icons.build_outlined,
    };
  }
}
