import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/models/intervention_model.dart' as model;
import '../../../data/repositories/intervention_repository.dart';

// Color tokens from Figma design
const Color primaryBlue = Color(0xFF0047AB);
const Color actionOrange = Color(0xFFFF8C00);
const Color errorRed = Color(0xFFD32F2F);
const Color titleBlack = Color(0xFF1A1A1A);
const Color textGray = Color(0xFF4A4A4A);
const Color secondaryGray = Color(0xFF708090);
const Color cardWhite = Color(0xFFFFFFFF);
const Color bgLightBlue = Color(0xFFF4F7F6);

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

    // Determinar si es edición o creación
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
      descripcion: null,
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

  @override
  void dispose() {
    kmController.dispose();
    costeController.dispose();
    notasController.dispose();
    super.dispose();
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
        title: Text(
          isEditing ? 'Editar Intervención' : 'Nueva Intervención',
          style: const TextStyle(
            color: primaryBlue,
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
              // Casa o Taller dropdown
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
                    backgroundColor: actionOrange,
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
                      color: titleBlack,
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
                      backgroundColor: errorRed,
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
                        color: cardWhite,
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
        color: bgLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            color: titleBlack,
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
        color: bgLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            color: titleBlack,
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
          color: bgLightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: titleBlack, size: 24),
            const SizedBox(width: 10),
            Text(
              fechaSeleccionada != null
                  ? DateFormat('dd/MM/yyyy').format(fechaSeleccionada!)
                  : 'Fecha',
              style: const TextStyle(
                color: titleBlack,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgLightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: bgLightBlue,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_file, color: titleBlack, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Adjuntar Documento',
            style: TextStyle(
              color: titleBlack,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: bgLightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: notasController,
        maxLines: 5,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Notas...',
          hintStyle: TextStyle(
            color: titleBlack,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
