import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notificacion_viewmodel.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.usuarioActual != null) {
        context
            .read<NotificacionViewModel>()
            .listenToNotificaciones(authVm.usuarioActual!.id);
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} d';
    }
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'reserva':
        return Icons.calendar_today;
      case 'oferta':
        return Icons.local_offer;
      case 'sistema':
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'reserva':
        return ColorSchemeApp.primaryGreen;
      case 'oferta':
        return ColorSchemeApp.goldenAccent;
      case 'sistema':
      default:
        return ColorSchemeApp.skyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifVm = context.watch<NotificacionViewModel>();
    final notificaciones = notifVm.notificaciones;
    final isLoading = notifVm.isLoading;

    final noLeidas = notificaciones.where((n) => !n.leida).length;

    return Scaffold(
      backgroundColor: ColorSchemeApp.pearlWhite,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: ColorSchemeApp.darkText,
        elevation: 0,
        actions: [
          if (notificaciones.isNotEmpty && noLeidas > 0)
            TextButton(
              onPressed: () {
                final authVm = context.read<AuthViewModel>();
                if (authVm.usuarioActual != null) {
                  notifVm.marcarTodasComoLeidas(authVm.usuarioActual!.id);
                }
              },
              child: Text(l10n.markAsRead, style: const TextStyle(color: ColorSchemeApp.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          if (notificaciones.isNotEmpty)
            TextButton(
              onPressed: () {
                final authVm = context.read<AuthViewModel>();
                if (authVm.usuarioActual != null) {
                  notifVm.borrarTodas(authVm.usuarioActual!.id);
                }
              },
              child: Text(l10n.deleteAll, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: ColorSchemeApp.primaryGreen))
                : notificaciones.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No tienes notificaciones', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificaciones.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notif = notificaciones[index];
                    final color = _getColorForTipo(notif.tipo);
                    
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!notif.leida) notifVm.marcarLeida(notif.id);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: notif.leida ? null : LinearGradient(
                              colors: [Colors.white, color.withValues(alpha: 0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            color: notif.leida ? Colors.white : null,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notif.leida ? Colors.grey.withValues(alpha: 0.1) : color.withValues(alpha: 0.3),
                            ),
                            boxShadow: notif.leida
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getIconForTipo(notif.tipo), color: color, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.titulo,
                                            style: TextStyle(
                                              fontWeight: notif.leida ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 16,
                                              color: ColorSchemeApp.darkText,
                                            ),
                                          ),
                                        ),
                                        if (!notif.leida)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withValues(alpha: 0.5),
                                                  blurRadius: 4,
                                                )
                                              ]
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif.mensaje,
                                      style: TextStyle(
                                        color: ColorSchemeApp.softGray,
                                        fontSize: 14,
                                        fontWeight: notif.leida ? FontWeight.normal : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(notif.fecha),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
