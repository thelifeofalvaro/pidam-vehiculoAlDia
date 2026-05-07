import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/core/app_text_styles.dart';
import 'package:vad_app/core/utils/file_utils.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/models/intervention_model.dart' as model;
import '../../../data/repositories/intervention_repository.dart';

/// Pantalla de alta y edición de intervenciones.
/// Funciona en dos modos según el argumento de navegación:
/// - Vehicle → modo creación (nueva intervención para ese vehículo)
/// - Intervention → modo edición (campos pre-rellenos)

class InterventionManageScreen extends StatefulWidget {
  const InterventionManageScreen({super.key});

  @override
  State<InterventionManageScreen> createState() =>
      _InterventionManageScreenState();
}

class _InterventionManageScreenState extends State<InterventionManageScreen> {
  final supabase = Supabase.instance.client;
  final repo = InterventionRepository();

  // Controllers
  final kmController = TextEditingController();
  final costeController = TextEditingController();
  final notasController = TextEditingController();
  final descripcionController = TextEditingController();

  //Variables de estado
  String? lugarSeleccionado;
  String? tipoSeleccionado;
  DateTime? fechaSeleccionada;
  String? documentoAdjunto;

  // Datos recibidos por navegación (pueden ser Vehicle o Intervention según modo)
  late dynamic argumentos;
  late Vehicle vehicle;
  model.Intervention? interventionToEdit;
  bool isEditing = false;

  // Los valores de los dropdowns deben coincidir EXACTAMENTE con el ENUM de PostgreSQL.
  // Ej: 'revisión' con tilde es válido; 'revision' sin tilde da error de BBDD.
  final tipos = ['reparación', 'modificación', 'mejora', 'revisión', 'otros'];
  final lugares = ['casa', 'taller'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    argumentos = ModalRoute.of(context)!.settings.arguments;

    // Ver si es edición o creación de intervención.
    if (argumentos is model.Intervention) {
      // Edición, se recibe pantalla con datos
      interventionToEdit = argumentos as model.Intervention;
      isEditing = true;
      _fillFormWithIntervention(interventionToEdit!);
    } else if (argumentos is Vehicle) {
      // Creación, recibe pantalla vacia
      vehicle = argumentos as Vehicle;
      isEditing = false;
    }
  }

  void _fillFormWithIntervention(model.Intervention intervention) {
    vehicle = Vehicle(id: intervention.vehiculoId, usuarioId: '');
    kmController.text = intervention.kmIntervencion?.toString() ?? '';
    costeController.text = intervention.coste?.toString() ?? '';
    lugarSeleccionado = intervention.lugar;
    tipoSeleccionado = intervention.tipoIntervencion;
    fechaSeleccionada = intervention.fechaIntervencion;
    notasController.text = intervention.notas ?? '';
    descripcionController.text = intervention.descripcion ?? '';
    documentoAdjunto = intervention.urlAdjunto;
  }

  /// El documento adjunto se sube a Storage antes de llamar a save().
  /// Su URL pública se almacena en url_adjunto de la tabla intervenciones.
  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      await Future.delayed(const Duration(milliseconds: 500));

      final file = result.files.first;

      final processResult = await FileUtils.processFile(
        bytes: file.bytes!,
        extension: file.extension ?? '',
      );

      if (!processResult.isSuccess || !mounted) return;

      final fileName =
          'doc_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final path = 'interventions/$fileName';

      await supabase.storage
          .from(FileUtils.bucket)
          .uploadBinary(path, processResult.bytes!);

      final publicUrl = supabase.storage
          .from(FileUtils.bucket)
          .getPublicUrl(path);

      setState(() {
        documentoAdjunto = publicUrl;
      });
    } catch (e) {
      debugPrint('Error subida: $e');
    }
  }

  /// La función de borrado elimina el archivo adjunto y actualiza el estado.
  void _deleteFile() {
    setState(() {
      documentoAdjunto = null;
    });
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  Future<void> save() async {
    if (!mounted) return;

    if (tipoSeleccionado == null || lugarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final intervention = model.Intervention(
      id: interventionToEdit?.id ?? '',
      vehiculoId: vehicle.id,
      tipoIntervencion: tipoSeleccionado!.toLowerCase(),
      descripcion: descripcionController.text,
      coste: double.tryParse(costeController.text),
      notas: notasController.text,
      kmIntervencion: int.tryParse(kmController.text),
      urlAdjunto: documentoAdjunto,
      fechaIntervencion: fechaSeleccionada ?? DateTime.now(),
      lugar: lugarSeleccionado!.toLowerCase(),
    );

    try {
      if (isEditing && interventionToEdit != null) {
        await repo.updateIntervention(intervention);
      } else {
        await repo.createIntervention(intervention);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error al guardar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Intervención' : 'Nueva Intervención'),
        actions: [IconButton(onPressed: save, icon: const Icon(Icons.check))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildFileUploadField(),
            const SizedBox(height: 16),
            _buildNotesField(),
          ],
        ),
      ),
    );
  }

  // 4. WIDGETS DE LA UI (Corregidos cierres de paréntesis)
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cloudWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 24),
            const SizedBox(width: 10),
            Text(
              fechaSeleccionada != null
                  ? DateFormat('dd/MM/yyyy').format(fechaSeleccionada!)
                  : 'Seleccionar Fecha',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadField() {
    final hasFile = documentoAdjunto != null && documentoAdjunto!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasFile) {
          _deleteFile();
        } else {
          _pickAndUploadFile();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cloudWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasFile ? AppColors.errorRed : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFile ? Icons.delete_outline : Icons.attach_file,
              color: hasFile ? AppColors.errorRed : AppColors.carbonBlack,
            ),
            const SizedBox(width: 8),
            Text(
              hasFile ? 'Eliminar documento' : 'Adjuntar documento',
              style: AppTextStyles.bodySmall.copyWith(
                color: hasFile ? AppColors.errorRed : AppColors.carbonBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: notasController,
        maxLines: 5,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Añade aquí tus notas',
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.carbonBlack,
          ),
        ),
      ),
    );
  }
}
