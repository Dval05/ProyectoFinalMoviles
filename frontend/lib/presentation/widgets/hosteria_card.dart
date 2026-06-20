import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/hosteria.dart';

class HosteriaCard extends StatelessWidget {
  final Hosteria hosteria;
  final VoidCallback onTap;

  const HosteriaCard({
    super.key,
    required this.hosteria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            SizedBox(
              height: 160,
              width: double.infinity,
              child: hosteria.imagenes.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: hosteria.imagenes.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
            ),
            
            // Detalles
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hosteria.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            hosteria.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hosteria.direccion,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
