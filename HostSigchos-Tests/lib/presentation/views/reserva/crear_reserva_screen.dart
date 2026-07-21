import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/habitacion.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/carrito_reserva_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class CrearReservaScreen extends StatefulWidget {
  const CrearReservaScreen({super.key});

  @override
  State<CrearReservaScreen> createState() => _CrearReservaScreenState();
}

class _CrearReservaScreenState extends State<CrearReservaScreen> {
  Habitacion? _habitacion;
  DateTime? _fechaCheckIn;
  DateTime? _fechaCheckOut;
  int _numHuespedes = 1;
  int _numHabitaciones = 1;
  bool _esParaOtraPersona = false;
  final _notasController = TextEditingController();
  final _nombreOtraPersonaController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _habitacion ??= ModalRoute.of(context)?.settings.arguments as Habitacion?;
  }

  @override
  void dispose() {
    _notasController.dispose();
    _nombreOtraPersonaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechas() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorSchemeApp.primaryGreen,
              onSurface: ColorSchemeApp.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _fechaCheckIn = result.start;
        _fechaCheckOut = result.end;
      });
    }
  }

  int get _noches {
    if (_fechaCheckIn == null || _fechaCheckOut == null) return 0;
    // Si seleccionan el mismo día, cuenta como 1 noche mínimo
    final diff = _fechaCheckOut!.difference(_fechaCheckIn!).inDays;
    return diff == 0 ? 1 : diff;
  }

  double get _precioTotal {
    if (_habitacion == null) return 0;

    final bool esCompartida = _habitacion!.tipo.toLowerCase().contains(
      'compartida',
    );
    if (esCompartida) {
      return _noches * _habitacion!.precioPorNoche * _numHuespedes;
    } else {
      return _noches * _habitacion!.precioPorNoche * _numHabitaciones;
    }
  }

  Future<void> _agregarAlCarrito() async {
    if (_fechaCheckIn == null || _fechaCheckOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectDates),
        ),
      );
      return;
    }

    if (_esParaOtraPersona &&
        _nombreOtraPersonaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterOtherPersonName),
        ),
      );
      return;
    }

    // Verificar disponibilidad real
    final reservaVm = context.read<ReservaViewModel>();
    final hayDisponibilidad = await reservaVm.verificarDisponibilidad(
      _habitacion!,
      _fechaCheckIn!,
      _fechaCheckOut!,
      _numHabitaciones,
    );

    if (!hayDisponibilidad) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notEnoughRooms),
        ),
      );
      return;
    }

    // Si la reserva es para la misma persona, chequear que no se solape con otras propias
    if (!_esParaOtraPersona) {
      final usuario = context.read<AuthViewModel>().usuarioActual;
      if (usuario != null) {
        final haySolapamiento = await reservaVm.existeSolapamiento(
          usuario.id,
          _fechaCheckIn!,
          _fechaCheckOut!,
        );
        if (haySolapamiento) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.overlappingBooking),
            ),
          );
          return;
        }
      }
    }

    final item = ItemCarrito(
      habitacion: _habitacion!,
      fechaCheckIn: _fechaCheckIn!,
      fechaCheckOut: _fechaCheckOut!,
      numHuespedes: _numHuespedes,
      numHabitaciones: _numHabitaciones,
      notas: _notasController.text.trim(),
      esParaOtraPersona: _esParaOtraPersona,
      nombreOtraPersona: _esParaOtraPersona
          ? _nombreOtraPersonaController.text.trim()
          : null,
    );

    context.read<CarritoReservaViewModel>().agregarItem(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.addedToCart)),
      );
      Navigator.pop(context); // Volver a lista de habitaciones
    }
  }

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final reservaVm = context.watch<ReservaViewModel>();

    if (_habitacion == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.addRoom)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.roomDataNotAvailable),
        ),
      );
    }

    final esCompartida = _habitacion!.tipo.toLowerCase().contains('compartida');
    final String precioTexto = esCompartida
        ? '${CurrencyFormatter.formatear(_habitacion!.precioPorNoche)} / ${AppLocalizations.of(context)!.perBedPerNight}'
        : '${CurrencyFormatter.formatear(_habitacion!.precioPorNoche)} / ${AppLocalizations.of(context)!.night}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.roomDetails),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: reservaVm.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrusel estilo Card Dashboard con puntos
              if (_habitacion!.imagenes.isNotEmpty)
                Column(
                  children: [
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 240,
                                viewportFraction: 1,
                                autoPlay: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                              ),
                              items: _habitacion!.imagenes.map((url) {
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  memCacheWidth: 800,
                                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                );
                              }).toList(),
                            ),
                            // Gradiente
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.5, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Puntos (Dots indicator)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _habitacion!.imagenes.asMap().entries.map((entry) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                          alpha: _currentImageIndex == entry.key ? 0.9 : 0.4),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

              // Info de la habitación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorSchemeApp.divider),
                ),
                child: Row(
                  children: [
                    if (_habitacion!.imagenes.isEmpty) ...[
                      const Icon(Icons.hotel, size: 40, color: ColorSchemeApp.primaryGreen),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _habitacion!.tipo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            precioTexto,
                            style: const TextStyle(color: ColorSchemeApp.darkGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Selección de fechas
              Text(
                AppLocalizations.of(context)!.dates,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _seleccionarFechas,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorSchemeApp.offWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: ColorSchemeApp.primaryGreen),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _fechaCheckIn != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppDateUtils.formatearFechaCorta(_fechaCheckIn!)} - ${AppDateUtils.formatearFechaCorta(_fechaCheckOut!)}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '$_noches ${AppLocalizations.of(context)!.nights}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              )
                            : Text(AppLocalizations.of(context)!.selectDates),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Huéspedes
              Text(
                esCompartida ? AppLocalizations.of(context)!.guestsBedsToBook : AppLocalizations.of(context)!.guests,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _numHuespedes > 1 ? () => setState(() => _numHuespedes--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: ColorSchemeApp.primaryGreen,
                  ),
                  Text('$_numHuespedes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _numHuespedes < _habitacion!.capacidad ? () => setState(() => _numHuespedes++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: ColorSchemeApp.primaryGreen,
                  ),
                  const Spacer(),
                  Text('${AppLocalizations.of(context)!.max} ${_habitacion!.capacidad}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              // Habitaciones
              if (!esCompartida) ...[
                Text(
                  AppLocalizations.of(context)!.rooms,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: _numHabitaciones > 1 ? () => setState(() => _numHabitaciones--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: ColorSchemeApp.primaryGreen,
                    ),
                    Text('$_numHabitaciones', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _numHabitaciones < 5 ? () => setState(() => _numHabitaciones++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: ColorSchemeApp.primaryGreen,
                    ),
                    const Spacer(),
                    Text('${AppLocalizations.of(context)!.max} 5', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Titular de Reserva
              const Text('Titular de la Reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.bookForOtherPerson),
                subtitle: Text(AppLocalizations.of(context)!.activateIfYouWontStay),
                value: _esParaOtraPersona,
                activeThumbColor: ColorSchemeApp.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _esParaOtraPersona = value;
                    if (!value) _nombreOtraPersonaController.clear();
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (_esParaOtraPersona) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _nombreOtraPersonaController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.otherPersonName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                ),
              ],
              const SizedBox(height: 24),

              // Notas adicionales
              TextField(
                controller: _notasController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.specialRequests,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // Resumen de precio
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorSchemeApp.sandBeige.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.totalToPay),
                        Text(
                          CurrencyFormatter.formatear(_precioTotal),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColorSchemeApp.darkGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.payInNextStep, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              GradientButton(
                text: AppLocalizations.of(context)!.addToMyBooking,
                onPressed: _agregarAlCarrito,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
