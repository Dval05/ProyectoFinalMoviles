import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/hosteria_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _profileChecked = false;
  DateTimeRange? _selectedDateRange;
  bool _isGridView = false;
  Position? _currentPosition;

  Future<void> _seleccionarFechas() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
    // Cargar hosterías y clima al iniciar el home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HosteriaViewModel>().cargarHosterias();
      context.read<WeatherViewModel>().fetchWeather();

      if (!_profileChecked) {
        _profileChecked = true;
        final authViewModel = context.read<AuthViewModel>();
        final usuario = authViewModel.usuarioActual;
        if (usuario != null) {
          final isIncomplete =
              usuario.cedula == null ||
              usuario.cedula!.isEmpty ||
              usuario.telefono == null ||
              usuario.telefono!.isEmpty ||
              usuario.fechaNacimiento == null;
          if (isIncomplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.profileIncomplete),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.edit,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editarPerfil);
                  },
                ),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final hosteriaViewModel = context.watch<HosteriaViewModel>();
    final weatherViewModel = context.watch<WeatherViewModel>();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.helloUser(authViewModel.usuarioActual == null ? 'Viajero' : authViewModel.usuarioActual!.nombre.split(' ').first),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.appTagline,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HosteriaViewModel>().cargarHosterias(),
        color: ColorSchemeApp.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Hero Section - Fechas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: _seleccionarFechas,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorSchemeApp.primaryGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: ColorSchemeApp.primaryGreen, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.whatDates,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorSchemeApp.darkGreen),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDateRange == null 
                                  ? AppLocalizations.of(context)!.tapToChoose
                                  : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                                style: TextStyle(color: Colors.grey[700]),
                              )
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: ColorSchemeApp.primaryGreen),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Buscador rápido
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  readOnly: true,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.hosteriasList),
                  decoration: InputDecoration(
                    hintText: l10n.searchHosterias,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Widget de Clima
              if (!weatherViewModel.isLoading && weatherViewModel.temperature != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ColorSchemeApp.primaryGreen, ColorSchemeApp.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clima en Sigchos',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weatherViewModel.temperature}°C',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(
                          weatherViewModel.getWeatherIcon(),
                          size: 48,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

              // Carrusel de destacadas
              if (hosteriaViewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (hosteriaViewModel.hosterias.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selectedDateRange == null 
                            ? l10n.popularHosterias 
                            : AppLocalizations.of(context)!.availableDatesTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 0.85,
                      ),
                      items: hosteriaViewModel.destacadas.map((
                        hosteria,
                      ) {
                        return Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.hosteriaDetail,
                                  arguments: hosteria.id,
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (hosteria.imagenes.isNotEmpty) CachedNetworkImage(
                                              imageUrl: hosteria.imagenes.first,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                    color: Colors.grey[300],
                                                  ),
                                            ) else Container(color: Colors.grey[300]),
                                      // Gradiente inferior para texto
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withValues(
                                                  alpha: 0.8,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  hosteria.nombre,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    hosteria.rating.toStringAsFixed(1),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Lista de "Cerca de ti" o "Todas"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDateRange == null 
                            ? l10n.nearYou 
                            : AppLocalizations.of(context)!.availableDatesTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                          onPressed: () => setState(() => _isGridView = !_isGridView),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.hosteriasList),
                          child: Text(l10n.viewAll),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!hosteriaViewModel.isLoading)
                Builder(
                  builder: (context) {
                    final lat = _currentPosition?.latitude ?? AppConstants.sigchosLatitud;
                    final lng = _currentPosition?.longitude ?? AppConstants.sigchosLongitud;
                    final cercanas = hosteriaViewModel.obtenerCercanas(lat, lng, count: 4);

                    if (_isGridView) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: cercanas.length,
                        itemBuilder: (context, index) {
                          final hosteria = cercanas[index];
                          String? distanciaTexto;
                          if (_currentPosition != null) {
                            final dist = Geolocator.distanceBetween(
                              _currentPosition!.latitude, 
                              _currentPosition!.longitude, 
                              hosteria.latitud, 
                              hosteria.longitud
                            );
                            distanciaTexto = '${(dist / 1000).toStringAsFixed(1)} km';
                          }
                          return HosteriaCard(
                            hosteria: hosteria,
                            isGrid: true,
                            distancia: distanciaTexto,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.hosteriaDetail,
                                arguments: hosteria.id,
                              );
                            },
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cercanas.length,
                      itemBuilder: (context, index) {
                        final hosteria = cercanas[index];
                        String? distanciaTexto;
                        if (_currentPosition != null) {
                          final dist = Geolocator.distanceBetween(
                            _currentPosition!.latitude, 
                            _currentPosition!.longitude, 
                            hosteria.latitud, 
                            hosteria.longitud
                          );
                          distanciaTexto = '${(dist / 1000).toStringAsFixed(1)} km';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HosteriaCard(
                            hosteria: hosteria,
                            distancia: distanciaTexto,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.hosteriaDetail,
                                arguments: hosteria.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en Home
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.hosteriasList);
            case 2:
              Navigator.pushNamed(context, AppRoutes.historialReservas);
            case 3:
              Navigator.pushNamed(context, AppRoutes.mapa);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: l10n.search,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: l10n.reservations,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.map,
          ),
        ],
      ),
    );
  }
}
