import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/hosteria_viewmodel.dart';

class ChatbotSuggestionsScreen extends StatelessWidget {
  const ChatbotSuggestionsScreen({required this.suggestions, super.key});

  final List<dynamic> suggestions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.suggestionsForYou, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: ColorSchemeApp.primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: suggestions.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noSuggestionsAvailable))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final hotelSuggestion = suggestions[index] as Map<String, dynamic>;
                final String hosteriaId = hotelSuggestion['hosteriaId'] ?? '';
                final List<dynamic> habitaciones = hotelSuggestion['habitaciones'] ?? [];

                // Obtener datos reales de la hostería desde el ViewModel
                final hosteriaVm = context.read<HosteriaViewModel>();
                final Hosteria? hosteria = hosteriaVm.todasHosterias.where((h) => h.id == hosteriaId).firstOrNull;

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 150)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30.0 * (1.0 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _HotelCard(
                      hosteriaId: hosteriaId,
                      fallbackName: hotelSuggestion['hosteriaNombre'] ?? AppLocalizations.of(context)!.unknownHotel,
                      hosteria: hosteria,
                      habitacionesSugeridas: habitaciones,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _HotelCard extends StatefulWidget {
  const _HotelCard({
    required this.hosteriaId,
    required this.fallbackName,
    required this.hosteria,
    required this.habitacionesSugeridas,
  });

  final String hosteriaId;
  final String fallbackName;
  final Hosteria? hosteria;
  final List<dynamic> habitacionesSugeridas;

  @override
  State<_HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<_HotelCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImages = widget.hosteria != null && widget.hosteria!.imagenes.isNotEmpty;
    final rating = widget.hosteria?.rating ?? 0.0;
    final nombre = widget.hosteria?.nombre ?? widget.fallbackName;
    final direccion = widget.hosteria?.direccion ?? l10n.addressNotAvailable;

    return GestureDetector(
      onTap: () {
        if (widget.hosteriaId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.habitaciones,
            arguments: widget.hosteriaId,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Imágenes tipo Airbnb
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: hasImages
                      ? PageView.builder(
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: widget.hosteria!.imagenes.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: widget.hosteria!.imagenes[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel, size: 64, color: Colors.grey),
                        ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Botón de Favorito (Visual)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 28,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
                // Puntos del Carrusel (Indicators)
                if (hasImages && widget.hosteria!.imagenes.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.hosteria!.imagenes.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 10.0 : 6.0,
                          height: _currentImageIndex == index ? 10.0 : 6.0,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 2)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Detalles del Hotel y Habitaciones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Calificación
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorSchemeApp.darkText,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: ColorSchemeApp.goldenAccent),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ColorSchemeApp.darkText,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Dirección
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          direccion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Chips de Habitaciones
                  if (widget.habitacionesSugeridas.isNotEmpty) ...[
                    Text(
                      l10n.suggestedRooms,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorSchemeApp.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.habitacionesSugeridas.map((h) {
                        final hab = h as Map<String, dynamic>;
                        String tipo = hab['tipo'] ?? l10n.roomFallback;
                        
                        // Traducción manual básica para los tipos de habitación si estamos en inglés
                        if (AppLocalizations.of(context)!.localeName == 'en') {
                          final tipoLower = tipo.toLowerCase();
                          if (tipoLower.contains('dormitorio compartido')) {
                            tipo = tipoLower.replaceAll('dormitorio compartido', 'Shared dormitory');
                          } else if (tipoLower.contains('habitación compartida')) {
                            tipo = tipoLower.replaceAll('habitación compartida', 'Shared room');
                          } else if (tipoLower.contains('simple')) {
                            tipo = tipoLower.replaceAll('simple', 'Single');
                          } else if (tipoLower.contains('doble')) {
                            tipo = tipoLower.replaceAll('doble', 'Double');
                          } else if (tipoLower.contains('familiar')) {
                            tipo = tipoLower.replaceAll('familiar', 'Family');
                          } else if (tipoLower.contains('matrimonial')) {
                            tipo = tipoLower.replaceAll('matrimonial', 'Matrimonial');
                          }
                          // Capitalizar primera letra
                          if (tipo.isNotEmpty) {
                            tipo = tipo[0].toUpperCase() + tipo.substring(1);
                          }
                        }
                        
                        final double precio = (hab['precio'] as num?)?.toDouble() ?? 0.0;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: ColorSchemeApp.sandBeige,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bed, size: 16, color: ColorSchemeApp.primaryGreen),
                              const SizedBox(width: 6),
                              Text(
                                tipo,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ColorSchemeApp.darkText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${precio.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSchemeApp.goldenAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
