import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/routing_service.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/hosteria_viewmodel.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();

  List<LatLng> _rutaActual = [];
  LatLng? _ubicacionUsuario;
  Hosteria? _destinoActual;
  bool _isLoadingRuta = false;
  bool _isRecalculating = false;
  
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;
  final ValueNotifier<double> _currentHeadingNotifier = ValueNotifier<double>(0);
  bool _rutaInicialTrazada = false;

  @override
  void initState() {
    super.initState();
    // Cargar hosterías si no están cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinarUbicacionInicial();
    });

    _compassStream = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null && !event.heading!.isNaN) {
        // Calcular la diferencia mínima de ángulo considerando el salto de 360 grados
        double diff = (event.heading! - _currentHeadingNotifier.value).abs();
        if (diff > 180) {
          diff = 360 - diff;
        }
        
        // Aplicar un umbral de 2.0 grados para evitar que el mapa tiemble
        if (diff > 2.0) {
          _currentHeadingNotifier.value = event.heading!;
          // Eliminamos el auto-rotar del mapa para evitar crash con paneo manual.
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_rutaInicialTrazada) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Hosteria) {
        _rutaInicialTrazada = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _trazarRuta(args);
        });
      }
    }
  }

  Future<void> _determinarUbicacionInicial() async {
    final hosteriaVm = context.read<HosteriaViewModel>();
    if (hosteriaVm.todasHosterias.isEmpty) {
      hosteriaVm.cargarHosterias();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    _currentHeadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _trazarRuta(Hosteria hosteria) async {
    setState(() {
      _isLoadingRuta = true;
    });

    try {
      // Pedir permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente.');
      }

      // Obtener ubicación actual
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final origen = LatLng(position.latitude, position.longitude);
      final destino = LatLng(hosteria.latitud, hosteria.longitud);

      // Obtener ruta
      final ruta = await _routingService.getRoute(origen, destino);

      setState(() {
        _ubicacionUsuario = origen;
        _rutaActual = ruta;
        _destinoActual = hosteria;
      });

      // Encuadrar la cámara para mostrar origen y destino
      if (ruta.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints([origen, destino, ...ruta]);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ),
        );
      } else {
        throw Exception('No se pudo encontrar una ruta.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al trazar la ruta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRuta = false;
        });
      }
    }
  }

  double _distanciaAlSegmento(LatLng p, LatLng a, LatLng b) {
    final double latMid = (a.latitude + b.latitude) / 2.0;
    final double cosLat = math.cos(latMid * math.pi / 180.0);
    
    final px = p.longitude * cosLat;
    final py = p.latitude;
    final ax = a.longitude * cosLat;
    final ay = a.latitude;
    final bx = b.longitude * cosLat;
    final by = b.latitude;

    final l2 = math.pow(bx - ax, 2) + math.pow(by - ay, 2);
    if (l2 == 0) {
      return const Distance().as(LengthUnit.Meter, p, a);
    }

    double t = ((px - ax) * (bx - ax) + (py - ay) * (by - ay)) / l2;
    t = math.max(0, math.min(1, t)); 

    final projX = ax + t * (bx - ax);
    final projY = ay + t * (by - ay);

    final projLng = projX / cosLat;
    final projLat = projY;

    return const Distance().as(LengthUnit.Meter, p, LatLng(projLat, projLng));
  }

  bool _isOffRoute(LatLng currentPos) {
    if (_rutaActual.isEmpty) return false;
    double minDistance = double.infinity;

    for (int i = 0; i < _rutaActual.length - 1; i++) {
      final a = _rutaActual[i];
      final b = _rutaActual[i + 1];
      final d = _distanciaAlSegmento(currentPos, a, b);
      if (d < 50) return false; 
      if (d < minDistance) minDistance = d;
    }
    return true; // Alejado más de 50 metros
  }

  Future<void> _recalcularRuta() async {
    if (_destinoActual == null || _ubicacionUsuario == null) return;
    
    setState(() {
      _isRecalculating = true;
    });

    try {
      final destino = LatLng(_destinoActual!.latitud, _destinoActual!.longitud);
      final ruta = await _routingService.getRoute(_ubicacionUsuario!, destino);
      if (mounted && ruta.isNotEmpty) {
        setState(() {
          _rutaActual = ruta;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.routeRecalculated), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      // Ignorar errores de recálculo
    } finally {
      if (mounted) {
        setState(() {
          _isRecalculating = false;
        });
      }
    }
  }

  void _toggleTracking() {
    if (_isTracking) {
      // Detener seguimiento
      _positionStream?.cancel();
      setState(() {
        _isTracking = false;
      });
      // Ya no rotamos a 0 porque no rotamos el mapa completo
    } else {
      // Iniciar seguimiento
      setState(() {
        _isTracking = true;
      });

      // Si tenemos ubicación, acercar el zoom al usuario
      if (_ubicacionUsuario != null) {
        _mapController.move(_ubicacionUsuario!, 17);
      }

      // Suscribirse a cambios de ubicación
      // (Se elimina rotación automática del mapa para evitar crashes y textos al revés)

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Notificar cada 5 metros
        ),
      ).listen((Position position) {
        if (mounted && _isTracking) {
          final nuevaUbicacion = LatLng(position.latitude, position.longitude);
          setState(() {
            _ubicacionUsuario = nuevaUbicacion;
          });
          // Centrar la cámara en la nueva ubicación
          _mapController.move(nuevaUbicacion, 17);

          // Verificar si salió de la ruta
          if (!_isRecalculating && _destinoActual != null) {
            if (_isOffRoute(nuevaUbicacion)) {
              _recalcularRuta();
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hosteriaVm = context.watch<HosteriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hotelMap),
        centerTitle: true,
      ),
      body: hosteriaVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(
                      AppConstants.sigchosLatitud,
                      AppConstants.sigchosLongitud,
                    ),
                    initialZoom: 14,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(-5.01, -81.01), // SurOeste (Aprox límites de Ecuador)
                        const LatLng(1.5, -75),   // NorEste
                      ),
                    ),
                  ),children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hostsigchos',
                    ),
                    if (_rutaActual.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _rutaActual,
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        ...hosteriaVm.todasHosterias.map((hosteria) {
                          return Marker(
                            point: LatLng(hosteria.latitud, hosteria.longitud),
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () {
                                _mostrarInfoHosteria(context, hosteria);
                              },
                              child: Image.asset(
                                'assets/images/personita.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          );
                        }),
                        if (_ubicacionUsuario != null)
                    Marker(
                      point: _ubicacionUsuario!,
                      width: 120,
                      height: 120,
                      child: ValueListenableBuilder<double>(
                        valueListenable: _currentHeadingNotifier,
                        builder: (context, heading, child) {
                          return Transform.rotate(
                            angle: (heading + _mapController.camera.rotation) * math.pi / 180,
                            child: child,
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cono de visión
                            CustomPaint(
                              size: const Size(120, 120),
                              painter: _VisionConePainter(),
                            ),
                            // Sombra pulsante base
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Punto central
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      ],
                    ),
                  ],
                ),
                // Botón de brújula interactivo que rota según el mapa
                Positioned(
                  top: 20,
                  right: 20,
                  child: StreamBuilder<MapEvent>(
                    stream: _mapController.mapEventStream,
                    builder: (context, snapshot) {
                      // rotation está en grados, Transform.rotate usa radianes
                      final rotation = _mapController.camera.rotation;
                      final radians = rotation * 3.1415926535897932 / 180;
                      
                      // Solo mostrar la brújula si hay rotación (opcional, pero lo dejamos visible siempre)
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _mapController.rotate(0);
                          },
                          child: Transform.rotate(
                            angle: -radians,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Círculo interior
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade200, width: 2),
                                  ),
                                ),
                                // Puntos cardinales con más espacio
                                const Positioned(top: 2, child: Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red))),
                                const Positioned(bottom: 2, child: Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87))),
                                const Positioned(right: 4, child: Text('E', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87))),
                                const Positioned(left: 4, child: Text('O', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87))),
                                
                                // Aguja de la brújula tipo diamante
                                CustomPaint(
                                  size: const Size(10, 26),
                                  painter: _CompassNeedlePainter(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoadingRuta)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.calculatingRoute,
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _rutaActual.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _toggleTracking,
              backgroundColor: _isTracking ? Colors.red : ColorSchemeApp.primaryGreen,
              icon: Icon(
                _isTracking ? Icons.stop : Icons.navigation,
                color: Colors.white,
              ),
              label: Text(
                _isTracking ? AppLocalizations.of(context)!.stop : AppLocalizations.of(context)!.followRoute,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _mostrarInfoHosteria(BuildContext context, Hosteria hosteria) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hosteria.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorSchemeApp.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hosteria.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: ColorSchemeApp.softGray),
              ),
              const SizedBox(height: 16),
              if (hosteria.imagenes.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hosteria.imagenes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: hosteria.imagenes[index],
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 160,
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 160,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar modal
                    // Redirigir al detalle de la hosteria
                    context.read<HosteriaViewModel>().cargarHosteriaDetalle(
                      hosteria.id,
                    );
                    Navigator.pushNamed(
                      context,
                      AppRoutes.habitaciones,
                      arguments: hosteria.id,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.reservationDetails),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar modal
                    _trazarRuta(hosteria); // Llamar a nuestra nueva función
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorSchemeApp.primaryGreen,
                    side: const BorderSide(color: ColorSchemeApp.primaryGreen),
                  ),
                  icon: const Icon(Icons.directions),
                  label: Text(AppLocalizations.of(context)!.getDirections),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _VisionConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);

    // Cono de visión que apunta hacia "arriba" (270 grados = -pi/2)
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withValues(alpha: 0.5),
          Colors.blue.withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    // Ángulo de apertura de 60 grados (pi/3)
    const double startAngle = -math.pi / 2 - math.pi / 6;
    const double sweepAngle = math.pi / 3;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    
    // Punta Norte (Roja)
    final Path pathNorth = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, height / 2)
      ..lineTo(0, height / 2)
      ..close();
      
    final Paint paintNorth = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
      
    // Punta Sur (Gris)
    final Path pathSouth = Path()
      ..moveTo(0, height / 2)
      ..lineTo(width, height / 2)
      ..lineTo(width / 2, height)
      ..close();
      
    final Paint paintSouth = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas
      ..drawPath(pathNorth, paintNorth)
      ..drawPath(pathSouth, paintSouth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
