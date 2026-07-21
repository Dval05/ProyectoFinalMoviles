import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/notificacion_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/hosteria_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCercanosGridView = false; // Toggle for "Cerca de ti" section

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HosteriaViewModel>().cargarHosterias();
      context.read<WeatherViewModel>().fetchWeather(); // Fetch weather on load
      final authVm = context.read<AuthViewModel>();
      if (authVm.usuarioActual != null) {
        context.read<NotificacionViewModel>().listenToNotificaciones(authVm.usuarioActual!.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final viewModel = context.read<HosteriaViewModel>();
    final initialDateRange = viewModel.filtroFechas ?? 
        DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 1)));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorSchemeApp.primaryGreen,
              onPrimary: Colors.white,
              onSurface: ColorSchemeApp.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != viewModel.filtroFechas) {
      viewModel.aplicarFiltrosAvanzados(fechas: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hosteriaVm = context.watch<HosteriaViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final weatherVm = context.watch<WeatherViewModel>();
    
    final userName = authVm.usuarioActual?.nombre.split(' ').first ?? 'Viajero';
    final hosterias = List<Hosteria>.from(hosteriaVm.todasHosterias);
    
    // Sort logic
    // 1. Top Valorados (Top 3)
    final topValorados = List<Hosteria>.from(hosterias)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top3 = topValorados.take(3).toList();

    // 2. Cerca de Ti (Mock distance based on name length or random for visual purposes, 
    // real app would calculate haversine distance to user location)
    final cercanos = List<Hosteria>.from(hosterias)
      ..sort((a, b) => a.nombre.length.compareTo(b.nombre.length)); // Mock sort
    final cercanosTop = cercanos.take(4).toList();

    return Scaffold(
      backgroundColor: ColorSchemeApp.pearlWhite,
      body: Column(
        children: [
          // CABECERA FIJA
          Container(
            color: ColorSchemeApp.pearlWhite,
            padding: EdgeInsets.only(
              left: 20, 
              right: 20, 
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.helloUser(userName),
                            style: const TextStyle(
                              color: ColorSchemeApp.softGray,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            l10n.discoverSigchos,
                            style: const TextStyle(
                              color: ColorSchemeApp.primaryGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Consumer<NotificacionViewModel>(
                          builder: (context, notifVm, _) {
                            final noLeidas = notifVm.notificaciones.where((n) => !n.leida).length;
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: ColorSchemeApp.darkText),
                                  onPressed: () {
                                    Navigator.pushNamed(context, AppRoutes.notificaciones);
                                  },
                                ),
                                if (noLeidas > 0)
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: ColorSchemeApp.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.perfil);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                            backgroundImage: (authVm.usuarioActual?.fotoUrl != null && authVm.usuarioActual!.fotoUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(authVm.usuarioActual!.fotoUrl!)
                                : null,
                            child: (authVm.usuarioActual?.fotoUrl == null || authVm.usuarioActual!.fotoUrl!.isEmpty)
                                ? Text(
                                    userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: ColorSchemeApp.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Fila con Clima y Filtro de Fechas
                Row(
                  children: [
                    // Weather Widget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          if (weatherVm.isLoading)
                            const SizedBox(
                              width: 16, height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          else ...[
                            Icon(weatherVm.getWeatherIcon(), color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              weatherVm.temperature != null 
                                ? '${weatherVm.temperature!.round()}°C' 
                                : '--°C',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: ColorSchemeApp.darkText),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date Filter Widget
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDateRange(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_month, color: ColorSchemeApp.primaryGreen, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hosteriaVm.filtroFechas != null
                                      ? '${DateFormat('d MMM').format(hosteriaVm.filtroFechas!.start)} - ${DateFormat('d MMM').format(hosteriaVm.filtroFechas!.end)}'
                                      : l10n.chooseDates,
                                  style: const TextStyle(
                                    color: ColorSchemeApp.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // CUERPO DESPLAZABLE
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: hosteriaVm.isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(child: CircularProgressIndicator(color: ColorSchemeApp.primaryGreen)),
                        )
                      : hosterias.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Center(child: Text(l10n.noPlacesAvailable)),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                
                                // SECCIÓN 1: Top Valorados (Horizontal Scroll)
                                if (top3.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.topRated,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: ColorSchemeApp.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 260, // Altura de tarjeta lista apaisada + márgenes
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(left: 20, right: 4),
                                      itemCount: top3.length,
                                      itemBuilder: (context, index) {
                                        final hosteria = top3[index];
                                        return Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          margin: const EdgeInsets.only(right: 16),
                                          child: HosteriaCard(
                                            hosteria: hosteria,
                                            isGrid: false,
                                            onTap: () {
                                              Navigator.pushNamed(context, AppRoutes.hosteriaDetail, arguments: hosteria.id);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],

                                // SECCIÓN 2: Cerca de ti (Toggleable)
                                if (cercanosTop.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, color: ColorSchemeApp.primaryGreen),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.nearYou,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: ColorSchemeApp.darkText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isCercanosGridView ? Icons.view_list : Icons.grid_view_rounded,
                                            color: ColorSchemeApp.softGray,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isCercanosGridView = !_isCercanosGridView;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_isCercanosGridView)
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.4, // Cartas rectangulares (horizontales)
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: cercanosTop.length,
                                      itemBuilder: (context, index) {
                                        final hosteria = cercanosTop[index];
                                        return HosteriaCard(
                                          hosteria: hosteria,
                                          isGrid: true,
                                          distancia: '1.${index + 1} km',
                                          onTap: () => Navigator.pushNamed(context, AppRoutes.hosteriaDetail, arguments: hosteria.id),
                                        );
                                      },
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: cercanosTop.length,
                                      itemBuilder: (context, index) {
                                        final hosteria = cercanosTop[index];
                                        return HosteriaCard(
                                          hosteria: hosteria,
                                          isGrid: false,
                                          distancia: '1.${index + 1} km',
                                          onTap: () => Navigator.pushNamed(context, AppRoutes.hosteriaDetail, arguments: hosteria.id),
                                        );
                                      },
                                    ),
                                ],
                                const SizedBox(height: 80), // Padding inferior
                              ],
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
