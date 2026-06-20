import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener la imagen')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: ColorSchemeApp.primaryGreen),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: ColorSchemeApp.primaryGreen),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final DateTime hoy = DateTime.now();
    final DateTime hace18Anios = DateTime(hoy.year - 18, hoy.month, hoy.day);
    
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: hace18Anios,
      firstDate: DateTime(1900),
      lastDate: hace18Anios, // Restringe el calendario a solo mayores de 18
      helpText: 'Selecciona tu fecha de nacimiento',
      errorFormatText: 'Formato de fecha inválido',
      errorInvalidText: 'Debes ser mayor de 18 años',
    );

    if (fechaSeleccionada != null) {
      setState(() {
        int edadCalculada = hoy.year - fechaSeleccionada.year;
        if (hoy.month < fechaSeleccionada.month || 
            (hoy.month == fechaSeleccionada.month && hoy.day < fechaSeleccionada.day)) {
          edadCalculada--;
        }
        _edadController.text = edadCalculada.toString();
      });
    }
  }

  void _loginGoogle() async {
    final success = await context.read<AuthViewModel>().loginConGoogle();
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final imageBytes = _imageFile != null ? await _imageFile!.readAsBytes() : null;

      if (!mounted) return;

      final success = await context.read<AuthViewModel>().register(
            nombre: _nombreController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            cedula: _cedulaController.text.trim(),
            edad: int.tryParse(_edadController.text.trim()),
            telefono: _telefonoController.text.trim(),
            ubicacion: _ubicacionController.text.trim(),
            fotoBytes: imageBytes,
          );

      if (success && mounted) {
        // Regresar al login o ir directo al home
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();


    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.read<AuthViewModel>().clearError();
            Navigator.pop(context);
          },
        ),
      ),
      body: LoadingOverlay(
        isLoading: authViewModel.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector de Foto de Perfil
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: ColorSchemeApp.lightGreen.withValues(alpha: 0.3),
                          backgroundImage: _imageFile != null
                              ? (kIsWeb
                                  ? NetworkImage(_imageFile!.path) as ImageProvider
                                  : FileImage(File(_imageFile!.path)))
                              : null,
                          child: _imageFile == null
                              ? const Icon(Icons.person, size: 50, color: ColorSchemeApp.primaryGreen)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: ColorSchemeApp.goldenAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                if (authViewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorSchemeApp.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorSchemeApp.error),
                    ),
                    child: Text(
                      authViewModel.errorMessage!,
                      style: const TextStyle(color: ColorSchemeApp.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  label: 'Nombre completo',
                  prefixIcon: Icons.person_outline,
                  controller: _nombreController,
                  validator: Validators.nombre,
                ),
                
                CustomTextField(
                  label: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                CustomTextField(
                  label: 'Cédula de Identidad',
                  prefixIcon: Icons.badge_outlined,
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  validator: Validators.cedula,
                ),

                CustomTextField(
                  label: 'Edad (calculada)',
                  hint: 'Toca para elegir fecha de nacimiento',
                  prefixIcon: Icons.calendar_today_outlined,
                  controller: _edadController,
                  readOnly: true,
                  onTap: _seleccionarFechaNacimiento,
                  validator: Validators.edad,
                ),

                CustomTextField(
                  label: 'Teléfono',
                  prefixIcon: Icons.phone_outlined,
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.telefono,
                ),

                CustomTextField(
                  label: 'Ubicación (Ciudad/Provincia)',
                  prefixIcon: Icons.location_city_outlined,
                  controller: _ubicacionController,
                  validator: (val) => Validators.requerido(val, 'La ubicación'),
                ),
                
                CustomTextField(
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.password,
                ),

                CustomTextField(
                  label: 'Confirmar Contraseña',
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (val) => Validators.confirmPassword(val, _passwordController.text),
                ),
                
                const SizedBox(height: 32),
                
                GradientButton(
                  text: 'Crear Cuenta',
                  onPressed: _register,
                ),
                
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O continúa con', style: TextStyle(color: ColorSchemeApp.softGray)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                
                OutlinedButton.icon(
                  onPressed: _loginGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: ColorSchemeApp.primaryGreen),
                  label: const Text('Google', style: TextStyle(color: ColorSchemeApp.darkText)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: ColorSchemeApp.divider),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
