import 'package:flutter/material.dart';
import '../../../core/app_color.dart';
import '../../../core/app_text_styles.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../presentation/widgets/app_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileRepository();
  final _authService = AuthService();

  Profile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isEditing = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _repo.getProfile();
      if (data != null) {
        _nameController.text = data.nombre ?? '';
        _emailController.text = data.email ?? '';
      }
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando perfil: $e')));
      }
    }
  }

  void _enterEditMode() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    // Restaurar valores originales
    if (_profile != null) {
      _nameController.text = _profile!.nombre ?? '';
      _emailController.text = _profile!.email ?? '';
    }
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña debe tener al menos 6 caracteres'),
          ),
        );
        return;
      }
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final updated = Profile(
        id: _profile!.id,
        nombre: _nameController.text.trim(),
        email: _profile!.email,
        avatarUrl: _profile!.avatarUrl,
      );

      await _repo.updateProfile(updated);

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _isEditing = false;
      });

      _passwordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando perfil: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error eliminando perfil: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // ── Input decoration ──────────────────────────────────
  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.cloudWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ── Campo editable con label encima ───────────────────
  Widget _formField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            enabled: enabled,
            style: AppTextStyles.bodySmall.copyWith(
              color: enabled ? AppColors.carbonBlack : AppColors.secondarySteel,
            ),
            decoration: _inputDecoration(suffixIcon: suffixIcon),
          ),
        ),
      ],
    );
  }

  // ── Campo solo lectura (modo ver) ─────────────────────
  Widget _readOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value.isEmpty ? '—' : value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.carbonBlack,
            ),
          ),
        ),
      ],
    );
  }

  // ── Campo contraseña solo lectura (••••••••) ──────────
  Widget _readOnlyPasswordField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            '••••••••',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondarySteel,
              fontSize: 18,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.screenBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    // Responsive: máximo 480px en tablet/web,
                    // ocupa todo el ancho en móvil
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top bar ─────────────────────────────
                        SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              // Izquierda: flecha atrás (ver) o X cancelar (editar)
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  onPressed: _isEditing
                                      ? _cancelEdit
                                      : () => Navigator.pop(context),
                                  icon: Icon(
                                    _isEditing
                                        ? Icons.close
                                        : Icons.chevron_left,
                                    size: _isEditing ? 24 : 28,
                                    color: _isEditing
                                        ? AppColors.secondarySteel
                                        : AppColors.actionOrange,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),

                              // Centro: título
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Perfil Usuario',
                                    style: AppTextStyles.heading2.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              // Derecha: lápiz editar (ver) o vacío (editar)
                              SizedBox(
                                width: 40,
                                child: _isEditing
                                    ? null
                                    : IconButton(
                                        onPressed: _enterEditMode,
                                        icon: const Icon(
                                          Icons.edit_square,
                                          size: 22,
                                          color: AppColors.carbonBlack,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Avatar ───────────────────────────────
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.cloudWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 44,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── MODO VER ─────────────────────────────
                        if (!_isEditing) ...[
                          _readOnlyField(
                            label: 'Nombre',
                            value: _profile?.nombre ?? '',
                          ),
                          const SizedBox(height: 16),
                          _readOnlyField(
                            label: 'Email',
                            value: _profile?.email ?? '',
                          ),
                          const SizedBox(height: 16),
                          _readOnlyPasswordField(label: 'Contraseña'),
                        ],

                        // ── MODO EDITAR ──────────────────────────
                        if (_isEditing) ...[
                          _formField(
                            label: 'Nombre',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          // Email visible pero bloqueado
                          _formField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),

                          _formField(
                            label: 'Contraseña',
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.secondarySteel,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _formField(
                            label: 'Confirmar Contraseña',
                            controller: _confirmPasswordController,
                            obscure: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.secondarySteel,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botón Guardar Cambios
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (_isSaving || _isDeleting)
                                  ? null
                                  : _saveProfile,
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
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.carbonBlack,
                                      ),
                                    )
                                  : Text(
                                      'Guardar Cambios',
                                      style: AppTextStyles.button,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botón Eliminar Perfil
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (_isSaving || _isDeleting)
                                  ? null
                                  : _deleteProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                foregroundColor: AppColors.cardWhite,
                                disabledBackgroundColor: AppColors.errorRed
                                    .withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isDeleting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.cardWhite,
                                      ),
                                    )
                                  : Text(
                                      'Eliminar Perfil',
                                      style: AppTextStyles.button.copyWith(
                                        color: AppColors.cardWhite,
                                      ),
                                    ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const AppBottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}
