import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _cedulaController;

  DateTime? _fechaNacimiento;
  late TextEditingController _fechaNacimientoController;

  String _tipoIdentificacion = 'Cédula';
  String _selectedPhonePrefix = '+593';
  late TextEditingController _telefonoController;

  String? _selectedCountry;
  final _customCityController = TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AuthViewModel>().usuarioActual;
    _nombreController = TextEditingController(text: usuario?.nombre);
    _cedulaController = TextEditingController(text: usuario?.cedula);
    _fechaNacimiento = usuario?.fechaNacimiento;
    _fechaNacimientoController = TextEditingController(
      text: _fechaNacimiento != null
          ? "${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}"
          : '',
    );

    // Parse phone prefix (simple detection)
    String phoneText = usuario?.telefono ?? '';
    if (phoneText.startsWith('+')) {
      // Find the space or just extract prefix
      if (phoneText.length > 4) {
        _selectedPhonePrefix = phoneText.substring(0, 4); // basic fallback
        // Un enfoque más robusto usaría country_picker parse, pero esto es temporal
      }
    }
    _telefonoController = TextEditingController(
      text: phoneText.replaceFirst(_selectedPhonePrefix, ''),
    );

    final String locText = usuario?.ubicacion ?? '';
    if (locText.isNotEmpty) {
      final parts = locText.split(', ');
      if (parts.length >= 2) {
        _selectedCountry = parts.last;
        _customCityController.text = parts
            .sublist(0, parts.length - 1)
            .join(', ');
      } else {
        _selectedCountry = 'Ecuador';
        _customCityController.text = locText;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _customCityController.dispose();
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

  Future<void> _seleccionarFechaNacimiento() async {
    final DateTime hoy = DateTime.now();
    final DateTime hace18Anios = DateTime(hoy.year - 18, hoy.month, hoy.day);

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: hace18Anios,
      firstDate: DateTime(1900),
      lastDate: hace18Anios, // Restringe el calendario a solo mayores de 18
      helpText: AppLocalizations.of(context)!.selectBirthDate,
      errorFormatText: AppLocalizations.of(context)!.invalidDateFormat,
      errorInvalidText: AppLocalizations.of(context)!.mustBeAdult,
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimiento = fechaSeleccionada;
        _fechaNacimientoController.text =
            "${fechaSeleccionada.day.toString().padLeft(2, '0')}/${fechaSeleccionada.month.toString().padLeft(2, '0')}/${fechaSeleccionada.year}";
      });
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

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final imageBytes = _imageFile != null
          ? await _imageFile!.readAsBytes()
          : null;

      if (!mounted) return;

      final authViewModel = context.read<AuthViewModel>();
      final usuarioActual = authViewModel.usuarioActual;
      if (usuarioActual == null) return;

      final success = await authViewModel.actualizarPerfil(
        uid: usuarioActual.id,
        nombre: _nombreController.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.success),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final usuario = authViewModel.usuarioActual;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        title: Text(l10n.editProfile),
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
                              : (usuario?.fotoUrl != null
                                    ? CachedNetworkImageProvider(
                                        usuario!.fotoUrl!,
                                      )
                                    : null),
                          child: _imageFile == null && usuario?.fotoUrl == null
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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
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
                        isExpanded: true,
                        items: ['Cédula', 'Pasaporte']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
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
                        label: _tipoIdentificacion == 'Cédula'
                            ? 'Cédula'
                            : 'Pasaporte',
                        prefixIcon: Icons.badge_outlined,
                        controller: _cedulaController,
                        keyboardType: _tipoIdentificacion == 'Cédula'
                            ? TextInputType.number
                            : TextInputType.text,
                        validator: (val) =>
                            Validators.identificacion(val, _tipoIdentificacion),
                        inputFormatters: _tipoIdentificacion == 'Cédula'
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[a-zA-Z0-9]'),
                                ),
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

                CustomTextField(
                  label: l10n.cityOrProvince,
                  prefixIcon: Icons.location_city_outlined,
                  controller: _customCityController,
                  validator: (val) => Validators.requerido(val, l10n.city),
                ),

                const SizedBox(height: 32),

                GradientButton(
                  text: l10n.save,
                  onPressed: _guardarCambios,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
