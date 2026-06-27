import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

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

  DateTime? _fechaNacimiento;
  final _fechaNacimientoController = TextEditingController();

  String _tipoIdentificacion = 'Cédula';
  String _selectedPhonePrefix = '+593';
  final _telefonoController = TextEditingController();

  String? _selectedCountry;
  final _customCityController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final String _selectedRol = kIsWeb ? 'propietario' : 'usuario';

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _customCityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGettingImage),
        ),
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
              leading: const Icon(
                Icons.camera_alt,
                color: ColorSchemeApp.primaryGreen,
              ),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: ColorSchemeApp.primaryGreen,
              ),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
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

    final l10n = AppLocalizations.of(context)!;
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: hace18Anios,
      firstDate: DateTime(1900),
      lastDate: hace18Anios, // Restringe el calendario a solo mayores de 18
      helpText: l10n.selectBirthDate,
      errorFormatText: l10n.invalidDateFormat,
      errorInvalidText: l10n.mustBeAdult,
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimiento = fechaSeleccionada;
        _fechaNacimientoController.text =
            "${fechaSeleccionada.day.toString().padLeft(2, '0')}/${fechaSeleccionada.month.toString().padLeft(2, '0')}/${fechaSeleccionada.year}";
      });
    }
  }

  Future<void> _loginGoogle() async {
    final success = await context.read<AuthViewModel>().loginConGoogle();
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final imageBytes = _imageFile != null
          ? await _imageFile!.readAsBytes()
          : null;

      if (!mounted) return;

      final success = await context.read<AuthViewModel>().register(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cedula: _cedulaController.text.trim(),
        fechaNacimiento: _fechaNacimiento,
        telefono: _telefonoController.text.isNotEmpty
            ? '$_selectedPhonePrefix${_telefonoController.text.trim()}'
            : null,
        ubicacion: _selectedCountry != null
            ? '${_customCityController.text.trim()}, $_selectedCountry'
            : null,
        fotoBytes: imageBytes,
        rol: _selectedRol,
      );

      if (success && mounted) {
        // Navegar a la pantalla de verificación de cuenta
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.verificacion,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        title: Text(l10n.register),
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
          padding: const EdgeInsets.all(24),
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
                          backgroundColor: ColorSchemeApp.lightGreen.withValues(
                            alpha: 0.3,
                          ),
                          backgroundImage: _imageFile != null
                              ? (kIsWeb
                                    ? NetworkImage(_imageFile!.path)
                                          as ImageProvider
                                    : FileImage(File(_imageFile!.path)))
                              : null,
                          child: _imageFile == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: ColorSchemeApp.primaryGreen,
                                )
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
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
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
                  label: l10n.name,
                  prefixIcon: Icons.person_outline,
                  controller: _nombreController,
                  validator: Validators.nombre,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                ),

                CustomTextField(
                  label: l10n.email,
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoIdentificacion,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ['Cédula', 'Pasaporte']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _tipoIdentificacion = val!;
                            _cedulaController.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: CustomTextField(
                        label: _tipoIdentificacion == 'Cédula' ? 'Cédula' : 'Pasaporte',
                        prefixIcon: Icons.badge_outlined,
                        controller: _cedulaController,
                        keyboardType: _tipoIdentificacion == 'Cédula' 
                            ? TextInputType.number 
                            : TextInputType.text,
                        validator: (val) => Validators.identificacion(val, _tipoIdentificacion),
                        inputFormatters: _tipoIdentificacion == 'Cédula' 
                            ? [FilteringTextInputFormatter.digitsOnly] 
                            : [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                      ),
                    ),
                  ],
                ),

                CustomTextField(
                  label: l10n.birthDate,
                  hint: l10n.tapToChoose,
                  prefixIcon: Icons.cake_outlined,
                  controller: _fechaNacimientoController,
                  readOnly: true,
                  onTap: _seleccionarFechaNacimiento,
                  validator: (_) =>
                      Validators.fechaNacimiento(_fechaNacimiento),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                _selectedPhonePrefix = '+${country.phoneCode}';
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedPhonePrefix,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: CustomTextField(
                        label: l10n.phone,
                        prefixIcon: Icons.phone_outlined,
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.telefono,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country.name;
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map_outlined, color: ColorSchemeApp.primaryGreen),
                        const SizedBox(width: 12),
                        Text(
                          _selectedCountry ?? l10n.countryOfOrigin,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedCountry == null ? Colors.black54 : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: l10n.cityOrProvince,
                  prefixIcon: Icons.location_city_outlined,
                  controller: _customCityController,
                  validator: (val) => Validators.requerido(val, l10n.city),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: l10n.password,
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.password,
                ),

                CustomTextField(
                  label: l10n.confirmPassword,
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (val) =>
                      Validators.confirmPassword(val, _passwordController.text),
                ),

                const SizedBox(height: 16),
                


                const SizedBox(height: 32),

                GradientButton(
                  text: l10n.createAccount,
                  onPressed: _register,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orContinueWith,
                        style: const TextStyle(color: ColorSchemeApp.softGray),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: _loginGoogle,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: ColorSchemeApp.primaryGreen,
                  ),
                  label: const Text(
                    'Google',
                    style: TextStyle(color: ColorSchemeApp.darkText),
                  ),
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
