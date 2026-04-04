import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vad_app/core/app_color.dart';
import 'package:vad_app/presentation/widgets/app_bottom_nav_bar.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

class VehicleManageScreen extends StatefulWidget {
  const VehicleManageScreen({super.key});

  @override
  State<VehicleManageScreen> createState() => _VehicleManageScreenState();
}

class _VehicleManageScreenState extends State<VehicleManageScreen> {
  final VehicleRepository _vehicleRepository = VehicleRepository();

  final TextEditingController _marcaModeloController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _bastidorController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();
  final TextEditingController _anioMatriculacionController =
      TextEditingController();

  final List<String> _tiposVehiculo = const [
    'Coche',
    'Moto',
    'Furgoneta',
    'Camión',
    'Otro',
  ];

  String? _tipoSeleccionado;
  bool _guardando = false;
  bool _eliminando = false;

  Vehicle? _vehicleEditando;
  bool get _isEditing => _vehicleEditando != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Vehicle && _vehicleEditando == null) {
      _vehicleEditando = args;
      _marcaModeloController.text = '${args.marca ?? ''} ${args.modelo ?? ''}';
      _matriculaController.text = args.matricula ?? '';
      _bastidorController.text = args.bastidor ?? '';
      _kilometrajeController.text = args.kmVh != null
          ? args.kmVh.toString()
          : '';
      _tipoSeleccionado = args.tipo;
      _anioMatriculacionController.text = args.anioMatriculacion != null
          ? args.anioMatriculacion.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _marcaModeloController.dispose();
    _matriculaController.dispose();
    _bastidorController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  Future<void> _guardarVehiculo() async {
    final textoMarcaModelo = _marcaModeloController.text.trim();

    if (textoMarcaModelo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Introduce marca y modelo')));
      return;
    }

    setState(() => _guardando = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final partes = textoMarcaModelo.split(RegExp(r'\s+'));
      final marca = partes.first;
      final modelo = partes.length > 1 ? partes.sublist(1).join(' ') : '';
      final km = int.tryParse(_kilometrajeController.text.trim());
      final aMatricula = int.tryParse(_anioMatriculacionController.text.trim());

      if (_isEditing) {
        final updatedVehicle = Vehicle(
          id: _vehicleEditando!.id,
          usuarioId: user.id,
          tipo: _tipoSeleccionado,
          marca: marca,
          modelo: modelo,
          matricula: _matriculaController.text.trim().isEmpty
              ? null
              : _matriculaController.text.trim(),
          anioMatriculacion: aMatricula,
          bastidor: _bastidorController.text.trim().isEmpty
              ? null
              : _bastidorController.text.trim(),
          kmVh: km,
        );

        await _vehicleRepository.updateVehicle(updatedVehicle);
      } else {
        final vehicle = Vehicle(
          id: '',
          usuarioId: user.id,
          tipo: _tipoSeleccionado,
          marca: marca,
          modelo: modelo,
          matricula: _matriculaController.text.trim().isEmpty
              ? null
              : _matriculaController.text.trim(),
          anioMatriculacion: _anioMatriculacionController.text.trim().isEmpty
              ? null
              : aMatricula,
          bastidor: _bastidorController.text.trim().isEmpty
              ? null
              : _bastidorController.text.trim(),
          kmVh: km,
        );

        await _vehicleRepository.createVehicle(vehicle);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Vehículo actualizado correctamente'
                : 'Vehículo guardado correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminarVehiculo() async {
    if (!_isEditing) {
      _limpiarFormulario();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Formulario limpiado')));
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar vehículo'),
          content: const Text('¿Seguro que quieres eliminar este vehículo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    setState(() => _eliminando = true);

    try {
      await _vehicleRepository.deleteVehicle(_vehicleEditando!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehículo eliminado')));
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  void _limpiarFormulario() {
    _marcaModeloController.clear();
    _matriculaController.clear();
    _bastidorController.clear();
    _kilometrajeController.clear();
    _anioMatriculacionController.clear();
    setState(() => _tipoSeleccionado = null);
  }

  InputDecoration _inputDecoration({
    String? hintText,
    bool withBorder = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        color: AppColors.carbonBlack,
      ),
      filled: true,
      fillColor: AppColors.cloudWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: withBorder ? const Color(0xFFE0E0E0) : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: withBorder ? const Color(0xFFE0E0E0) : Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.chevron_left,
                                size: 30,
                                color: AppColors.primaryBlue,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _isEditing
                                    ? 'Editar Vehículo'
                                    : 'Añadir Vehículo',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 22 / 18,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.cloudWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: AppColors.carbonBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    const Text(
                      'Marca y Modelo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 22 / 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 1),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _marcaModeloController,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.carbonBlack,
                        ),
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoSeleccionado,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.actionOrange,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.carbonBlack,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Tipo de vehículo',
                        ),
                        dropdownColor: AppColors.cloudWhite,
                        items: _tiposVehiculo
                            .map(
                              (tipo) => DropdownMenuItem<String>(
                                value: tipo,
                                child: Text(tipo),
                              ),
                            )
                            .toList(),
                        onChanged: (_guardando || _eliminando)
                            ? null
                            : (value) {
                                setState(() => _tipoSeleccionado = value);
                              },
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _matriculaController,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.carbonBlack,
                        ),
                        decoration: _inputDecoration(hintText: 'Matricula'),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _bastidorController,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.carbonBlack,
                        ),
                        decoration: _inputDecoration(hintText: 'Bastidor'),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _kilometrajeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.carbonBlack,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Kilometraje',
                          withBorder: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _anioMatriculacionController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          hintText: 'Año de matriculación',
                          withBorder: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_guardando || _eliminando)
                            ? null
                            : _guardarVehiculo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionOrange,
                          foregroundColor: AppColors.carbonBlack,
                          disabledBackgroundColor: AppColors.actionOrange
                              .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.carbonBlack,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Guardar cambios'
                                    : 'Guardar Vehículo',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_guardando || _eliminando)
                            ? null
                            : _eliminarVehiculo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.errorRed
                              .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _eliminando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Eliminar Vehículo',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}
