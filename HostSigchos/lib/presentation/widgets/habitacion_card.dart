import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/habitacion.dart';
import '../../themes/esquema_color.dart';

class HabitacionCard extends StatelessWidget {
  const HabitacionCard({
    required this.habitacion,
    required this.onTap,
    super.key,
  });
  final Habitacion habitacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Builder(
          builder: (context) {
            final bool esCompartida = habitacion.tipo.toLowerCase().contains(
              'compartida',
            );
            final String textoPrecio = esCompartida
                ? '${CurrencyFormatter.formatear(habitacion.precioPorNoche)} / cama'
                : CurrencyFormatter.formatear(habitacion.precioPorNoche);
            final String textoCapacidad = esCompartida
                ? 'Habitación de ${habitacion.capacidad} camas'
                : 'Capacidad: ${habitacion.capacidad} personas';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                SizedBox(
                  width: 120,
                  height: 140,
                  child: habitacion.imagenes.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: habitacion.imagenes.first,
                          fit: BoxFit.cover,
                          memCacheWidth: 600,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.hotel,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),

                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                habitacion.tipo,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ColorSchemeApp.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                textoPrecio,
                                style: const TextStyle(
                                  color: ColorSchemeApp.darkGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          textoCapacidad,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ColorSchemeApp.softGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: habitacion.amenidades.take(3).map((
                            amenidad,
                          ) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                amenidad,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
