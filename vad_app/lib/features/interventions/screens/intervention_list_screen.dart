import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/core/app_text_styles.dart';
import 'package:vad_app/core/utils/file_utils.dart';
import 'package:vad_app/core/utils/error_utils.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/models/intervention_model.dart';
import '../../../data/repositories/intervention_repository.dart';
import 'dart:typed_data';

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
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    loadInterventions();
  }

  List<Intervention> get filteredInterventions {
    if (selectedFilterType == 'Todo') return interventions;

    return interventions.where((i) {
      final tipo = i.tipoIntervencion?.toLowerCase() ?? '';

      switch (selectedFilterType) {
        case 'Revisión':
          return tipo.contains('revisión');
        case 'Reparación':
          return tipo.contains('reparación');
        case 'Mejoras':
          return tipo.contains('mejora') || tipo.contains('modificación');
        default:
          return true;
      }
    }).toList();
  }

  Future<void> loadInterventions() async {
    try {
      final data = await _repository.getInterventionsByVehicle(
        widget.vehicle.id,
      );
      setState(() {
        interventions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorUtils.mensajeLegible(
                e,
                contexto: 'cargar las intervenciones',
              ),
            ),
          ),
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
      loadInterventions();
      hasChanges = true;
    }
  }

  Future<void> _pickAndUploadFile(Intervention intervention) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      final fileBytes = file.bytes;
      if (fileBytes == null) return;

      final processedBytes = await FileUtils.processFile(
        bytes: fileBytes,
        extension: file.extension ?? '',
        context: context,
      );
      if (processedBytes == null) return;

      await _uploadToSupabase(intervention, file, processedBytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorUtils.mensajeLegible(e, contexto: 'subir el archivo'),
          ),
        ),
      );
    }
  }

  Future<void> _uploadToSupabase(
    Intervention intervention,
    PlatformFile file,
    Uint8List processedBytes,
  ) async {
    try {
      final fileName =
          '${intervention.id}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';

      final path = 'interventions/$fileName';

      final supabase = Supabase.instance.client;

      await supabase.storage
          .from('archive')
          .uploadBinary(
            path,
            processedBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from(FileUtils.bucket)
          .getPublicUrl(path);

      /// Guardar URL en la intervención
      await _repository.updateIntervention(
        intervention.copyWith(urlAdjunto: publicUrl),
      );

      loadInterventions();
      hasChanges = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo subido correctamente')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorUtils.mensajeLegible(e))));
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, hasChanges);
      },
      child: Scaffold(
        backgroundColor: AppColors.cardWhite,
        appBar: AppBar(
          backgroundColor: AppColors.cardWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(context, hasChanges),
          ),
          title: const Text(
            'Historial Vehículo',
            style: AppTextStyles.heading2,
          ),
        ),
        floatingActionButton: interventions.isNotEmpty
            ? FloatingActionButton(
                onPressed: goToCreate,
                backgroundColor: AppColors.actionOrange,
                child: const Icon(Icons.add, color: AppColors.carbonBlack),
              )
            : null,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : interventions.isEmpty
            ? _buildEmptyState()
            : _buildDataState(),
      ),
    );
  }

  // Pantalla Vacia
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
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.cloudWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.textSteel, width: 1),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 50,
                      color: AppColors.textSteel,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Aún no tienes intervenciones registradas',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.carbonBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Añade tu primera intervención',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 206,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: goToCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Añadir Intervención',
                        style: AppTextStyles.button,
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

  // Pantalla con Datos
  Widget _buildDataState() {
    return Column(
      children: [
        // Botones de filtro y tarjeta de info del vehículo
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              // Tarjeta de info del vehículo + Gasto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cloudWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.vehicle.marca} ${widget.vehicle.modelo}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.carbonBlack,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            border: Border.all(
                              color: AppColors.carbonBlack,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.vehicle.matricula ?? 'N/A',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.carbonBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Gasto total en este vehículo: ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextSpan(
                            text: formatCost(getTotalCost()),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.carbonBlack,
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

        // Timeline intervenciones
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredInterventions.length,
            itemBuilder: (context, index) {
              return _buildTimelineItem(filteredInterventions[index], index);
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
                color: AppColors.cloudWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSteel, width: 2),
              ),
              child: Icon(
                _getInterventionIcon(intervention.tipoIntervencion),
                size: 16,
                color: AppColors.textSteel,
              ),
            ),
            // Vertical line
            if (!isLast)
              Container(
                width: 2,
                height: 72,
                color: AppColors.textSteel,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Ficha de Intervencion. Se pulsa para editar
        Expanded(
          child: GestureDetector(
            onTap: () => _showInterventionOptions(intervention),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cloudWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          intervention.tipoIntervencion ?? 'Sin tipo',
                          style: AppTextStyles.heading3,
                        ),
                      ),

                      if (intervention.urlAdjunto != null &&
                          intervention.urlAdjunto!.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.attach_file,
                            size: 18,
                            color: AppColors.textSteel,
                          ),
                        ),
                    ],
                  ),

                  if (intervention.descripcion != null &&
                      intervention.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        intervention.descripcion!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formatDate(intervention.fechaIntervencion)} • ${intervention.kmIntervencion ?? 0} km',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        formatCost(intervention.coste),
                        style: AppTextStyles.heading3,
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
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilterType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.cardWhite,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.cardWhite : AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  IconData _getInterventionIcon(String? type) {
    return switch (type?.toLowerCase()) {
      'revisión' => Icons.check_box_outlined,
      'reparación' => Icons.handyman_outlined,
      'mejora' => Icons.star_outline,
      'modificación' => Icons.star_outline,
      'otros' => Icons.tag_outlined,
      _ => Icons.build_outlined,
    };
  }

  void _showInterventionOptions(Intervention intervention) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              /// Editar Intervención
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryBlue),
                title: const Text('Editar intervención'),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await Navigator.pushNamed(
                    context,
                    '/intervention-manage',
                    arguments: intervention,
                  );

                  if (result == true) {
                    loadInterventions();
                    hasChanges = true;
                  }
                },
              ),

              if (intervention.urlAdjunto != null &&
                  intervention.urlAdjunto!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.errorRed),
                  title: const Text('Eliminar archivo'),
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      final supabase = Supabase.instance.client;

                      final uri = Uri.parse(intervention.urlAdjunto!);
                      final filePath = uri.pathSegments.skip(2).join('/');

                      await supabase.storage.from(FileUtils.bucket).remove([
                        filePath,
                      ]);

                      await _repository.updateIntervention(
                        intervention.copyWith(urlAdjunto: null),
                      );

                      loadInterventions();
                      hasChanges = true;

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Archivo eliminado')),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ErrorUtils.mensajeLegible(
                              e,
                              contexto: 'eliminar el archivo',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),

              /// Adjuntar Archivo (solo si no tiene ya), máx 1 Archivo 2MB
              if (intervention.urlAdjunto == null ||
                  intervention.urlAdjunto!.isEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.attach_file,
                    color: AppColors.actionOrange,
                  ),
                  title: const Text('Añadir archivo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadFile(intervention);
                  },
                ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
