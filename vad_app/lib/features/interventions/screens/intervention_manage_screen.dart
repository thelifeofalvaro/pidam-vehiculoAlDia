import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/core/utils/file_utils.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/models/intervention_model.dart' as model;
import '../../../data/repositories/intervention_repository.dart';

class InterventionManageScreen extends StatefulWidget {
  const InterventionManageScreen({super.key});

  @override
  State<InterventionManageScreen> createState() =>
      _InterventionManageScreenState();
}

class _InterventionManageScreenState extends State<InterventionManageScreen> {
  final repo = InterventionRepository();

  // Controllers
  final kmController = TextEditingController();
  final costeController = TextEditingController();
  final notasController = TextEditingController();
  final descripcionController = TextEditingController();

  // State variables
  String? lugarSeleccionado;
  String? tipoSeleccionado;
  DateTime? fechaSeleccionada;
  String? documentoAdjunto;

  // Data
  late dynamic argumentos;
  late Vehicle vehicle;
  model.Intervention? interventionToEdit;
  bool isEditing = false;

  // Dropdown options
  final tipos = ['reparación', 'modificación', 'mejora', 'revisión', 'otros'];
  String formatTipos(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  final lugares = ['casa', 'taller'];
  String formatLugar(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    argumentos = ModalRoute.of(context)!.settings.arguments;

    // Ver si se edita o se crea la intervención
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> delete() async {
    if (!isEditing || interventionToEdit == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar intervención'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta intervención?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await repo.deleteIntervention(interventionToEdit!.id);
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      final fileBytes = file.bytes;
      if (fileBytes == null) throw Exception('Archivo inválido');

      final processedBytes = await FileUtils.processFile(
        bytes: fileBytes,
        extension: file.extension ?? '',
        context: context,
      );
      if (processedBytes == null) return;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${file.extension}';

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
          .from('interventions')
          .getPublicUrl(path);

      setState(() {
        documentoAdjunto = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo subido correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error subiendo archivo: $e')));
    }
  }

  Future<void> _deleteFile() async {
    try {
      if (documentoAdjunto == null) return;

      final supabase = Supabase.instance.client;

      /// Extraer path desde URL
      final uri = Uri.parse(documentoAdjunto!);
      final filePath = uri.pathSegments.skip(2).join('/');

      await supabase.storage.from('archive').remove([filePath]);

      setState(() {
        documentoAdjunto = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Archivo eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error eliminando archivo: $e')));
    }
  }

  @override
  void dispose() {
    kmController.dispose();
    costeController.dispose();
    notasController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editar Intervención' : 'Nueva Intervención',
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // Selector Lugar Intervención
              _buildDropdownField(
                label: 'Casa o Taller',
                value: lugarSeleccionado,
                items: lugares,
                onChanged: (v) => setState(() => lugarSeleccionado = v),
              ),
              const SizedBox(height: 21),

              // Kilometraje actual
              _buildTextField(
                controller: kmController,
                label: 'Kilometraje actual',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 21),

              // Tipo de Intervención dropdown
              _buildDropdownField(
                label: 'Tipo de Intervención',
                value: tipoSeleccionado,
                items: tipos,
                onChanged: (v) => setState(() => tipoSeleccionado = v),
              ),
              const SizedBox(height: 21),

              // Descripción
              _buildTextField(
                controller: descripcionController,
                label: 'Descripción',
              ),
              const SizedBox(height: 21),

              // Coste
              _buildTextField(
                controller: costeController,
                label: 'Coste (€)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 21),

              // Fecha
              _buildDateField(),
              const SizedBox(height: 21),

              // Adjuntar Documento
              _buildFileUploadField(),
              const SizedBox(height: 21),

              // Notas
              _buildNotesField(),
              const SizedBox(height: 32),

              // Guardar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar Intervención',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.carbonBlack,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Eliminar (solo si está editando)
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: delete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Eliminar Intervención',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cardWhite,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.carbonBlack,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.carbonBlack,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cloudWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.carbonBlack,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              fechaSeleccionada != null
                  ? DateFormat('dd/MM/yyyy').format(fechaSeleccionada!)
                  : 'Fecha',
              style: const TextStyle(
                color: AppColors.carbonBlack,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
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
          border: Border.all(color: AppColors.cloudWhite, width: 1.5),
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
              style: TextStyle(
                color: hasFile ? AppColors.errorRed : AppColors.carbonBlack,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Notas...',
          hintStyle: TextStyle(
            color: AppColors.carbonBlack,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
