import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../domain/entities/hosteria.dart';
import '../../themes/esquema_color.dart';

class HosteriaCard extends StatelessWidget {
  const HosteriaCard({
    required this.hosteria,
    required this.onTap,
    this.isGrid = false,
    this.distancia,
    super.key,
  });
  final Hosteria hosteria;
  final VoidCallback onTap;
  final bool isGrid;
  final String? distancia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isGrid) {
      return _buildGridCard(context, theme);
    }
    return _buildListCard(context, theme);
  }

  Widget _buildListCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 24),
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
              Hero(
                tag: 'hosteria_image_${hosteria.id}',
                child: hosteria.imagenes.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: hosteria.imagenes.first,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.landscape, size: 50, color: Colors.grey),
                      ),
              ),
              // Gradiente Metálico Oscuro
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Información Inferior
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            hosteria.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ColorSchemeApp.goldenAccent.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                hosteria.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.8), size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distancia != null
                                ? '$distancia - ${hosteria.direccion}'
                                : hosteria.direccion,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '\$${hosteria.precioPorNoche.toInt()}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' / ${AppLocalizations.of(context)!.night}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'hosteria_image_${hosteria.id}_grid',
                child: hosteria.imagenes.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: hosteria.imagenes.first,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                      )
                    : Container(color: Colors.grey[200]),
              ),
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
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hosteria.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (distancia != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.8), size: 10),
                          const SizedBox(width: 2),
                          Text(
                            distancia!,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 10),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${hosteria.precioPorNoche.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: ColorSchemeApp.goldenAccent, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              hosteria.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
