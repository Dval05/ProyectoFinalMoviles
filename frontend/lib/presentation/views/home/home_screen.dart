import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../../themes/esquema_color.dart';
import '../../widgets/hosteria_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar hosterías al iniciar el home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HosteriaViewModel>().cargarHosterias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final hosteriaViewModel = context.watch<HosteriaViewModel>();

    final theme = Theme.of(context);

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
              'Descubre la magia de Sigchos',
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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  readOnly: true,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.hosteriasList),
                  decoration: InputDecoration(
                    hintText: '¿Dónde te gustaría hospedarte?',
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
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (hosteriaViewModel.hosterias.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Destacados',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        viewportFraction: 0.85,
                      ),
                      items: hosteriaViewModel.hosterias.take(3).map((hosteria) {
                        return Builder(
                          builder: (BuildContext context) {
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
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
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
                                      hosteria.imagenes.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: hosteria.imagenes.first,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey[300],
                                              ),
                                            )
                                          : Container(color: Colors.grey[300]),
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
                                                Colors.black.withValues(alpha: 0.8),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            hosteria.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explorar Hosterías',
                      style: theme.textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.hosteriasList),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
              ),

              if (!hosteriaViewModel.isLoading)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: hosteriaViewModel.hosterias.length,
                  itemBuilder: (context, index) {
                    final hosteria = hosteriaViewModel.hosterias[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
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
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en Home
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.hosteriasList);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.historialReservas);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.mapa);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }
}
