import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../widgets/hosteria_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _profileChecked = false;

  @override
  void initState() {
    super.initState();
    // Cargar hosterías al iniciar el home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HosteriaViewModel>().cargarHosterias();

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

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final hosteriaViewModel = context.watch<HosteriaViewModel>();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, ${authViewModel.usuarioActual == null ? 'Viajero' : authViewModel.usuarioActual!.nombre.split(' ').first}!",
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
                        l10n.popularHosterias,
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
                      items: hosteriaViewModel.hosterias.take(3).map((
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
                                          child: Text(
                                            hosteria.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                        l10n.exploreHosterias,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.hosteriasList),
                      child: Text(l10n.viewAll),
                    ),
                  ],
                ),
              ),

              if (!hosteriaViewModel.isLoading)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: hosteriaViewModel.hosterias.length,
                  itemBuilder: (context, index) {
                    final hosteria = hosteriaViewModel.hosterias[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HosteriaCard(
                        hosteria: hosteria,
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
