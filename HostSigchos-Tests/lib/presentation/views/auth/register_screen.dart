import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector.dart';
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

  bool _acceptedTerms = false;

  final List<String> _provinciasEcuador = [
    'Azuay', 'Bolívar', 'Cañar', 'Carchi', 'Chimborazo', 'Cotopaxi', 
    'El Oro', 'Esmeraldas', 'Galápagos', 'Guayas', 'Imbabura', 'Loja', 
    'Los Ríos', 'Manabí', 'Morona Santiago', 'Napo', 'Orellana', 'Pastaza', 
    'Pichincha', 'Santa Elena', 'Santo Domingo de los Tsáchilas', 
    'Sucumbíos', 'Tungurahua', 'Zamora Chinchipe'
  ];
  String? _selectedProvincia;

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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al intentar abrir el enlace')),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los Términos y Condiciones y Políticas de Privacidad para registrarte.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final imageBytes = _imageFile != null
          ? await _imageFile!.readAsBytes()
          : null;

      if (!mounted) return;

      var finalEmail = _emailController.text.trim();
      var finalPassword = _passwordController.text;

      final success = await context.read<AuthViewModel>().register(
        nombre: _nombreController.text.trim(),
        email: finalEmail,
        password: finalPassword,
        cedula: _cedulaController.text.trim(),
        fechaNacimiento: _fechaNacimiento,
        telefono: _telefonoController.text.isNotEmpty
            ? '$_selectedPhonePrefix${_telefonoController.text.trim()}'
            : null,
        ubicacion: _selectedCountry != null
            ? '${_customCityController.text.trim()}, $_selectedCountry'
            : null,
        fotoBytes: imageBytes,
      );

      if (success && mounted) {
        // Cierra la sesión de autofill antes de navegar: si Android sigue
        // mostrando el aviso de "guardar contraseña" cuando este árbol de
        // widgets se destruye, Flutter lanza
        // "_dependents.isEmpty is not true" al desmontar los campos.
        TextInput.finishAutofillContext();
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
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: authViewModel.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
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
                              ? FileImage(File(_imageFile!.path))
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
                const SizedBox(height: 16),

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
                  const SizedBox(height: 12),
                ],

                CustomTextField(
                  label: l10n.name,
                  prefixIcon: Icons.person_outline,
                  controller: _nombreController,
                  validator: Validators.nombre,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                    ),
                  ],
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
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _tipoIdentificacion,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'Cédula', child: Text(l10n.idTypeCedula)),
                          DropdownMenuItem(value: 'Pasaporte', child: Text(l10n.idTypePassport)),
                        ],
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
                      flex: 4,
                      child: CustomTextField(
                        label: _tipoIdentificacion == 'Cédula'
                            ? l10n.idTypeCedula
                            : l10n.idTypePassport,
                        prefixIcon: Icons.badge_outlined,
                        controller: _cedulaController,
                        keyboardType: _tipoIdentificacion == 'Cédula'
                            ? TextInputType.number
                            : TextInputType.text,
                        validator: (val) =>
                            Validators.identificacion(val, _tipoIdentificacion, _selectedCountry ?? 'Ecuador'),
                        inputFormatters: _tipoIdentificacion == 'Cédula'
                            ? [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ]
                            : [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[a-zA-Z0-9]'),
                                ),
                                LengthLimitingTextInputFormatter(15),
                              ],
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
                              color: ColorSchemeApp.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _selectedPhonePrefix == '+593' ? 10 : 15,
                          ),
                        ],
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
                          _selectedPhonePrefix = '+${country.phoneCode}';
                          if (_selectedCountry != 'Ecuador') {
                            _selectedProvincia = null;
                            _customCityController.clear();
                          }
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorSchemeApp.primaryGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: ColorSchemeApp.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedCountry ?? l10n.countryOfOrigin,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedCountry == null
                                ? Colors.black54
                                : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedCountry == null || _selectedCountry == 'Ecuador')
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.cityOrProvince,
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    initialValue: _selectedProvincia,
                    items: _provinciasEcuador.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProvincia = newValue;
                        _customCityController.text = newValue ?? '';
                      });
                    },
                    validator: (val) => Validators.requerido(val, l10n.cityOrProvince),
                  )
                else
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

                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) {
                        setState(() {
                          _acceptedTerms = val ?? false;
                        });
                      },
                      activeColor: ColorSchemeApp.primaryGreen,
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Acepto los ', style: TextStyle(fontSize: 13)),
                          InkWell(
                            onTap: () {
                              _launchUrl('https://hostsigchos.com/terminos');
                            },
                            child: const Text(
                              'Términos y Condiciones',
                              style: TextStyle(
                                fontSize: 13,
                                color: ColorSchemeApp.primaryGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(' y las ', style: TextStyle(fontSize: 13)),
                          InkWell(
                            onTap: () {
                              _launchUrl('https://hostsigchos.com/privacidad');
                            },
                            child: const Text(
                              'Políticas de Privacidad',
                              style: TextStyle(
                                fontSize: 13,
                                color: ColorSchemeApp.primaryGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
