import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/resena.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/resena_viewmodel.dart';

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
          context.read<ResenaViewModel>().listenToResenas(hosteriaId!);
        });
      }
    }
  }

  void _mostrarModalResena(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final usuario = authVm.usuarioActual;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.signInToReview)),
      );
      return;
    }

    double rating = 5;
    final TextEditingController comentarioController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 24,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.howWasThePlace,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ColorSchemeApp.darkText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.yourOpinionHelps,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: ColorSchemeApp.goldenAccent,
                              size: 40,
                            ),
                            onPressed: () {
                              setStateModal(() {
                                rating = index + 1.0;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: comentarioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.writeYourRecommendation,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (comentarioController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.pleaseWriteAComment)),
                            );
                            return;
                          }
                          
                          final resena = Resena(
                            id: '',
                            hosteriaId: hosteriaId!,
                            usuarioId: usuario.id,
                            nombreUsuario: usuario.nombre,
                            comentario: comentarioController.text.trim(),
                            rating: rating,
                            fecha: DateTime.now(),
                          );
                          
                          Navigator.pop(context); // Cerrar modal inmediatamente
                          final exito = await context.read<ResenaViewModel>().agregarResena(resena);
                          
                          if (mounted) {
                            if (exito) {
                              // Refrescar el detalle de la hostería para obtener el nuevo promedio
                              context.read<HosteriaViewModel>().cargarHosteriaDetalle(hosteriaId!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.thanksForYourOpinion)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.errorSendingReview)),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorSchemeApp.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(AppLocalizations.of(context)!.publishReview, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HosteriaViewModel>();
    final hosteria = viewModel.hosteriaSeleccionada;
    final resenaVm = context.watch<ResenaViewModel>();
    final l10n = AppLocalizations.of(context)!;

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: ColorSchemeApp.primaryGreen)),
      );
    }

    if (hosteria == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context)!.couldNotLoadInformation)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: hosteria.imagenes.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 380,
                        viewportFraction: 1,
                        autoPlay: true,
                      ),
                      items: hosteria.imagenes.map((url) {
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          memCacheWidth: 800,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                        );
                      }).toList(),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 100, color: Colors.grey),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24), // Aumentado padding top a 48
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
                            style: const TextStyle(
                              color: ColorSchemeApp.darkText,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: ColorSchemeApp.goldenAccent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                hosteria.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
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
                        const Icon(Icons.location_on, color: ColorSchemeApp.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hosteria.direccion,
                            style: TextStyle(color: Colors.grey[700], fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Generar la ruta en RoutingService y luego ir a MapaScreen.
                          // Primero, nos aseguramos que el HosteriaViewModel sea el seleccionado.
                          context.read<HosteriaViewModel>().cargarHosteriaDetalle(hosteria.id);
                          
                          // Regresar al inicio (que tiene el tab 0). 
                          // Nota: Al usar popUntil('home'), no podemos cambiar el tab del MainScreen directamente a menos 
                          // que usemos un GlobalKey o Provider para el tabIndex de MainScreen. 
                          // Por ahora, como es un tab independiente (AppRoutes.mapa se usa en MainScreen), 
                          // podemos hacer un push a una nueva pantalla MapaScreen con el botón atrás, 
                          // O simplemente hacer Navigator.pushNamed(context, AppRoutes.mapa).
                          Navigator.pushNamed(context, AppRoutes.mapa, arguments: hosteria);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorSchemeApp.primaryGreen,
                          side: const BorderSide(color: ColorSchemeApp.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.directions),
                        label: Text(AppLocalizations.of(context)!.getDirections, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Descripción
                    Text(l10n.about, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorSchemeApp.darkText)),
                    const SizedBox(height: 12),
                    Text(
                      hosteria.descripcion,
                      style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 15),
                    ),
                    const SizedBox(height: 32),

                    // Servicios
                    Text(l10n.popularServices, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorSchemeApp.darkText)),
                    const SizedBox(height: 16),
                    if (hosteria.servicios.isEmpty)
                      Text(l10n.servicesNotSpecified, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: hosteria.servicios.map((servicio) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              servicio,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: ColorSchemeApp.primaryGreen),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 32),
                    const Divider(height: 1),
                    const SizedBox(height: 32),

                    // Opiniones y Reseñas
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.reviews, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorSchemeApp.darkText)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: Text('${resenaVm.resenas.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => _mostrarModalResena(context),
                          icon: const Icon(Icons.edit, color: ColorSchemeApp.primaryGreen, size: 18),
                          label: Text(l10n.writeReview, style: const TextStyle(color: ColorSchemeApp.primaryGreen, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (resenaVm.isLoading && resenaVm.resenas.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (resenaVm.resenas.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.noReviewsYet, style: TextStyle(color: Colors.grey[500])),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _mostrarModalResena(context),
                                child: Text(AppLocalizations.of(context)!.beTheFirstToReview, style: const TextStyle(fontWeight: FontWeight.w600, color: ColorSchemeApp.primaryGreen)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: resenaVm.resenas.length,
                        separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                        itemBuilder: (context, index) {
                          final resena = resenaVm.resenas[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                                    child: Text(
                                      resena.nombreUsuario[0].toUpperCase(),
                                      style: const TextStyle(color: ColorSchemeApp.primaryGreen, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(resena.nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          'Hace ${DateTime.now().difference(resena.fecha).inDays} días',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: ColorSchemeApp.goldenAccent, size: 16),
                                      const SizedBox(width: 4),
                                      Text(resena.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                              if (resena.comentario.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(resena.comentario, style: TextStyle(color: Colors.grey[700], height: 1.4)),
                              ]
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 120), // Espacio inferior para el botón
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.habitaciones,
                arguments: hosteria.id,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSchemeApp.darkText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            child: Text(
              AppLocalizations.of(context)!.seeAvailableRooms,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
