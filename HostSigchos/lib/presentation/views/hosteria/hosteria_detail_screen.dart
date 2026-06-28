import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';

import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/hosteria_viewmodel.dart';

class HosteriaDetailScreen extends StatefulWidget {
  const HosteriaDetailScreen({super.key});

  @override
  State<HosteriaDetailScreen> createState() => _HosteriaDetailScreenState();
}

class _HosteriaDetailScreenState extends State<HosteriaDetailScreen> {
  String? hosteriaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hosteriaId == null) {
      hosteriaId = ModalRoute.of(context)?.settings.arguments as String?;
      if (hosteriaId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<HosteriaViewModel>().cargarHosteriaDetalle(hosteriaId!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HosteriaViewModel>();
    final hosteria = viewModel.hosteriaSeleccionada;
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hosteria == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No se pudo cargar la información')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: hosteria.imagenes.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 350,
                        viewportFraction: 1,
                        autoPlay: true,
                      ),
                      items: hosteria.imagenes.map((url) {
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[300]),
                        );
                      }).toList(),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hosteria.nombre,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColorSchemeApp.goldenAccent.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: ColorSchemeApp.goldenAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hosteria.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorSchemeApp.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: ColorSchemeApp.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hosteria.direccion,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${hosteria.latitud},${hosteria.longitud}',
                        );
                        try {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.error,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorSchemeApp.primaryGreen,
                        side: const BorderSide(
                          color: ColorSchemeApp.primaryGreen,
                        ),
                      ),
                      icon: const Icon(Icons.directions),
                      label: Text(AppLocalizations.of(context)!.getDirections),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Contacto
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: ColorSchemeApp.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hosteria.telefono,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Acerca de',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hosteria.descripcion,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: ColorSchemeApp.softGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Servicios
                  Text(
                    'Servicios Populares',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: hosteria.servicios.map((servicio) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: ColorSchemeApp.sandBeige.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          servicio,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.habitaciones,
                arguments: hosteria.id,
              );
            },
            child: const Text(
              'Ver Habitaciones Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
