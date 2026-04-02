import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/vehicle_repository.dart';

const Color secondarySteel = Color(0xFF708090);

class VehicleManageScreen extends StatefulWidget {
  const VehicleManageScreen({super.key});

  @override
  State<VehicleManageScreen> createState() => _VehicleManageScreenState();
}

class _VehicleManageScreenState extends State<VehicleManageScreen> {
  static const Color _screenBackground = Color(0xFFEAEAEA);
  static const Color _cloudWhite = Color(0xFFF4F7F6);
  static const Color _primaryBlue = Color(0xFF0047AB);
  static const Color _actionOrange = Color(0xFFFF8C00);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _secondarySteel = Color(0xFF708090);
  static const Color _carbonBlack = Color(0xFF1A1A1A);

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
      final a_matricula = int.tryParse(
        _anioMatriculacionController.text.trim(),
      );

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
          anioMatriculacion: a_matricula,
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
              : a_matricula,
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
        color: _carbonBlack,
      ),
      filled: true,
      fillColor: _cloudWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: withBorder ? const Color(0xFFE0E0E0) : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryBlue, width: 1),
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
      backgroundColor: _screenBackground,
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
                                color: _primaryBlue,
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
                                  color: _primaryBlue,
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
                        color: _cloudWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: _carbonBlack,
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
                          color: _carbonBlack,
                        ),
                        decoration: _inputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      height: 48,
                      child: DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: _actionOrange,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: _carbonBlack,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Tipo de vehículo',
                        ),
                        dropdownColor: _cloudWhite,
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
                          color: _carbonBlack,
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
                          color: _carbonBlack,
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
                          color: _carbonBlack,
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
                          backgroundColor: _actionOrange,
                          foregroundColor: _carbonBlack,
                          disabledBackgroundColor: _actionOrange.withValues(
                            alpha: 0.6,
                          ),
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
                                  color: _carbonBlack,
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
                          backgroundColor: _errorRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _errorRed.withValues(
                            alpha: 0.6,
                          ),
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
            const _BottomTabBar(),
          ],
        ),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar();

  @override
  Widget build(BuildContext context) {
    Widget tabItem({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 2),
            Icon(icon, color: secondarySteel, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 18 / 13,
                color: secondarySteel,
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
        border: Border(top: BorderSide(color: secondarySteel, width: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          tabItem(
            icon: Icons.home_outlined,
            label: 'Inicio',
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
          tabItem(
            icon: Icons.build_outlined,
            label: 'Historial',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial: próximamente')),
              );
            },
          ),
          tabItem(
            icon: Icons.account_circle_outlined,
            label: 'Perfil',
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
