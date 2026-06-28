import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/hosteria.dart';
import '../../../domain/entities/promocion.dart';
import '../../../domain/entities/reserva.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/habitacion_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/promocion_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';

class PropietarioDashboardScreen extends StatefulWidget {
  const PropietarioDashboardScreen({super.key});

  @override
  State<PropietarioDashboardScreen> createState() =>
      _PropietarioDashboardScreenState();
}

class _PropietarioDashboardScreenState
    extends State<PropietarioDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar hosterías al iniciar el dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HosteriaViewModel>().cargarHosterias();
      context.read<ReservaViewModel>().cargarTodasLasReservas();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.logoutUseCase();
    authViewModel.setUsuarioActual(null);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().usuarioActual;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            backgroundColor: Colors.white,
            extended: MediaQuery.of(context).size.width >= 800,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_center_outlined),
                selectedIcon: Icon(Icons.business_center),
                label: Text('Mis Hosterías'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online_outlined),
                selectedIcon: Icon(Icons.book_online),
                label: Text('Reservas de Clientes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon: Icon(Icons.local_offer),
                label: Text('Promociones'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.landscape_rounded,
                  size: 40,
                  color: ColorSchemeApp.primaryGreen,
                ),
                const SizedBox(height: 8),
                if (MediaQuery.of(context).size.width >= 800)
                  const Text(
                    'HostSigchos\nAdmin Web',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorSchemeApp.darkGreen,
                    ),
                  ),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () => _logout(context),
                    tooltip: 'Cerrar Sesión',
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal
          Expanded(
            child: _buildContent(usuario?.nombre ?? 'Propietario'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String nombre) {
    switch (_selectedIndex) {
      case 0:
        return _DashboardView(nombre: nombre);
      case 1:
        return const _MisHosteriasView();
      case 2:
        return const _ReservasAdminView();
      case 3:
        return const _PromocionesAdminView();
      default:
        return _DashboardView(nombre: nombre);
    }
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().usuarioActual;
    final isPropietario = usuario?.rol == 'propietario';

    var hosterias = context.watch<HosteriaViewModel>().hosterias;
    if (isPropietario && usuario != null) {
      hosterias = hosterias
          .where((h) => h.propietarioId == usuario.id)
          .toList();
    }
    var reservas = context.watch<ReservaViewModel>().reservas;
    if (isPropietario) {
      final hosteriaIds = hosterias.map((h) => h.id).toSet();
      reservas = reservas
          .where((r) => hosteriaIds.contains(r.hosteriaId))
          .toList();
    }

    final hosteriasActivas = hosterias.where((h) => h.activa).length;
    final reservasNuevas = reservas
        .where((r) => r.estado == 'pendiente' || r.estado == 'en_revision')
        .length;

    double ingresosTotales = 0;
    for (final r in reservas) {
      if (r.estado == 'confirmada') {
        ingresosTotales += r.precioTotal;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, $nombre!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ColorSchemeApp.darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resumen de tu plataforma web de administración B2B.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard(
                context,
                'Hosterías Activas',
                hosteriasActivas.toString(),
                Icons.business_center,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                context,
                'Reservas Activas',
                reservasNuevas.toString(),
                Icons.book_online,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                context,
                'Ingresos Totales',
                '\$${ingresosTotales.toStringAsFixed(2)}',
                Icons.attach_money,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: ColorSchemeApp.primaryGreen),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ColorSchemeApp.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MisHosteriasView extends StatelessWidget {
  const _MisHosteriasView();

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().usuarioActual;
    final isPropietario = usuario?.rol == 'propietario';

    var hosterias = context.watch<HosteriaViewModel>().hosterias;
    if (isPropietario && usuario != null) {
      hosterias = hosterias
          .where((h) => h.propietarioId == usuario.id)
          .toList();
    }
    final isLoading = context.watch<HosteriaViewModel>().isLoading;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Hosterías',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ColorSchemeApp.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _HosteriaFormDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Añadir Hostería'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSchemeApp.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hosterias.isEmpty
                ? const Center(child: Text('No tienes hosterías registradas.'))
                : ListView.builder(
                    itemCount: hosterias.length,
                    itemBuilder: (context, index) {
                      final h = hosterias[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  h.imagenes.isNotEmpty
                                      ? h.imagenes.first
                                      : 'https://via.placeholder.com/150',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            h.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(h.direccion),
                          trailing: const Icon(
                            Icons.edit,
                            color: ColorSchemeApp.primaryGreen,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => _HosteriaFormDialog(hosteria: h),
                            );
                          },
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

class _HosteriaFormDialog extends StatefulWidget {
  const _HosteriaFormDialog({this.hosteria});
  final Hosteria? hosteria;

  @override
  State<_HosteriaFormDialog> createState() => _HosteriaFormDialogState();
}

class _HosteriaFormDialogState extends State<_HosteriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _sitioWebController;
  late TextEditingController _imagenesController; // comma separated URLs
  late TextEditingController _propietarioIdController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.hosteria?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.hosteria?.descripcion ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.hosteria?.direccion ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.hosteria?.telefono ?? '',
    );
    _emailController = TextEditingController(
      text: widget.hosteria?.email ?? '',
    );
    _sitioWebController = TextEditingController(
      text: widget.hosteria?.sitioWeb ?? '',
    );
    _imagenesController = TextEditingController(
      text: widget.hosteria?.imagenes.join(', ') ?? '',
    );
    _propietarioIdController = TextEditingController(
      text: widget.hosteria?.propietarioId ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _sitioWebController.dispose();
    _imagenesController.dispose();
    _propietarioIdController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final viewmodel = context.read<HosteriaViewModel>();
    final isEditing = widget.hosteria != null;

    final imagenes = _imagenesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final nuevaHosteria = Hosteria(
      id: isEditing
          ? widget.hosteria!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      direccion: _direccionController.text.trim(),
      latitud: widget.hosteria?.latitud ?? 0.0,
      longitud: widget.hosteria?.longitud ?? 0.0,
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      sitioWeb: _sitioWebController.text.trim(),
      imagenes: imagenes,
      rating: widget.hosteria?.rating ?? 0.0,
      servicios: widget.hosteria?.servicios ?? [],
      activa: widget.hosteria?.activa ?? true,
      propietarioId: _propietarioIdController.text.trim().isEmpty
          ? null
          : _propietarioIdController.text.trim(),
    );

    bool success = false;
    if (isEditing) {
      success = await viewmodel.actualizarHosteria(nuevaHosteria);
    } else {
      success = await viewmodel.crearHosteria(nuevaHosteria);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hostería guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = viewmodel.errorMessage ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.hosteria == null ? 'Añadir Hostería' : 'Editar Hostería',
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción *'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sitioWebController,
                  decoration: const InputDecoration(labelText: 'Sitio Web'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imagenesController,
                  decoration: const InputDecoration(
                    labelText: 'Imágenes (URLs separadas por coma)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _propietarioIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID del Propietario (Opcional)',
                    helperText: 'El UID de Firebase del usuario Propietario',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorSchemeApp.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _ReservasAdminView extends StatefulWidget {
  const _ReservasAdminView();

  @override
  State<_ReservasAdminView> createState() => _ReservasAdminViewState();
}

class _ReservasAdminViewState extends State<_ReservasAdminView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().usuarioActual;
    final isPropietario = usuario?.rol == 'propietario';

    var reservas = context.watch<ReservaViewModel>().reservas;
    final isLoading = context.watch<ReservaViewModel>().isLoading;

    if (isPropietario && usuario != null) {
      final hosterias = context
          .read<HosteriaViewModel>()
          .hosterias
          .where((h) => h.propietarioId == usuario.id)
          .map((h) => h.id)
          .toSet();
      reservas = reservas
          .where((r) => hosterias.contains(r.hosteriaId))
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Reservas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ColorSchemeApp.darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorSchemeApp.divider),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reservas.isEmpty
                  ? const Center(child: Text('No hay reservas registradas.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID Reserva')),
                            DataColumn(label: Text('Usuario ID')),
                            DataColumn(label: Text('Fechas')),
                            DataColumn(label: Text('Precio Total')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acción')),
                          ],
                          rows: reservas.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r.id.substring(0, 8))),
                                DataCell(Text(r.usuarioId.substring(0, 8))),
                                DataCell(
                                  Text(
                                    '${r.fechaCheckIn.toLocal().toString().split(' ')[0]} - ${r.fechaCheckOut.toLocal().toString().split(' ')[0]}',
                                  ),
                                ),
                                DataCell(
                                  Text('\$${r.precioTotal.toStringAsFixed(2)}'),
                                ),
                                DataCell(
                                  Chip(
                                    label: Text(
                                      r.estado,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: r.estado == 'pendiente'
                                        ? Colors.orange.shade100
                                        : (r.estado == 'confirmada'
                                              ? Colors.green.shade100
                                              : Colors.red.shade100),
                                  ),
                                ),
                                DataCell(
                                  r.estado == 'pendiente' ||
                                          r.estado == 'confirmada' ||
                                          r.estado == 'en_revision'
                                      ? ElevatedButton(
                                          onPressed: () {
                                            _mostrarDialogoGestion(context, r);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorSchemeApp.primaryGreen,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Gestionar'),
                                        )
                                      : const Text('-'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoGestion(BuildContext context, Reserva r) {
    String selectedEstado = r.estado;
    final estados = ['pendiente', 'confirmada', 'en_revision', 'cancelada'];
    if (!estados.contains(selectedEstado)) {
      estados.add(selectedEstado);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gestionar Reserva'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserva ID: ${r.id}'),
                  const SizedBox(height: 16),
                  const Text('Cambiar estado:'),
                  DropdownButton<String>(
                    value: selectedEstado,
                    isExpanded: true,
                    items: estados
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedEstado = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final success = await context
                        .read<ReservaViewModel>()
                        .actualizarEstadoReserva(r.id, selectedEstado);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Estado actualizado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        final error =
                            context.read<ReservaViewModel>().errorMessage ??
                            'Error desconocido';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PromocionesAdminView extends StatefulWidget {
  const _PromocionesAdminView();

  @override
  State<_PromocionesAdminView> createState() => _PromocionesAdminViewState();
}

class _PromocionesAdminViewState extends State<_PromocionesAdminView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromocionViewModel>().cargarPromociones();
    });
  }

  void _mostrarFormularioPromocion([Promocion? p]) {
    showDialog(
      context: context,
      builder: (context) => _PromocionFormDialog(promocion: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PromocionViewModel>();
    final usuario = context.watch<AuthViewModel>().usuarioActual;
    final isPropietario = usuario?.rol == 'propietario';

    var promociones = viewModel.promociones;
    if (isPropietario && usuario != null) {
      final hosterias = context
          .read<HosteriaViewModel>()
          .hosterias
          .where((h) => h.propietarioId == usuario.id)
          .map((h) => h.id)
          .toSet();
      promociones = promociones
          .where((p) => hosterias.contains(p.hosteriaId))
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestión de Promociones',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ColorSchemeApp.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _mostrarFormularioPromocion,
                icon: const Icon(Icons.add),
                label: const Text('Nueva Promoción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSchemeApp.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorSchemeApp.divider),
              ),
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : promociones.isEmpty
                  ? const Center(child: Text('No hay promociones registradas.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: promociones.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final p = promociones[index];
                        return ListTile(
                          title: Text(
                            p.titulo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${p.descripcion}\nDescuento: ${p.descuentoPorcentaje}%',
                          ),
                          trailing: Switch(
                            value: p.activa,
                            activeThumbColor: ColorSchemeApp.primaryGreen,
                            onChanged: (val) {
                              context
                                  .read<PromocionViewModel>()
                                  .actualizarPromocion(p.copyWith(activa: val));
                            },
                          ),
                          onTap: () => _mostrarFormularioPromocion(p),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromocionFormDialog extends StatefulWidget {
  const _PromocionFormDialog({this.promocion});
  final Promocion? promocion;

  @override
  State<_PromocionFormDialog> createState() => _PromocionFormDialogState();
}

class _PromocionFormDialogState extends State<_PromocionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _descuentoController = TextEditingController();

  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 30));
  String? _selectedHosteriaId;
  String? _selectedHabitacionId;

  @override
  void initState() {
    super.initState();
    if (widget.promocion != null) {
      _tituloController.text = widget.promocion!.titulo;
      _descripcionController.text = widget.promocion!.descripcion;
      _descuentoController.text = widget.promocion!.descuentoPorcentaje
          .toString();
      _fechaInicio = widget.promocion!.fechaInicio;
      _fechaFin = widget.promocion!.fechaFin;
      _selectedHosteriaId = widget.promocion!.hosteriaId;
      _selectedHabitacionId = widget.promocion!.habitacionId;

      if (_selectedHosteriaId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<HabitacionViewModel>().cargarHabitacionesPorHosteria(
            _selectedHosteriaId!,
          );
        });
      }
    }
  }

  Future<void> _seleccionarFechas() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fechaInicio, end: _fechaFin),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked.start;
        _fechaFin = picked.end;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<PromocionViewModel>();

    final desc = double.tryParse(_descuentoController.text) ?? 0.0;

    bool success;
    if (widget.promocion == null) {
      success = await viewModel.crearPromocion(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        descuentoPorcentaje: desc,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        hosteriaId: _selectedHosteriaId,
        habitacionId: _selectedHabitacionId,
      );
    } else {
      success = await viewModel.actualizarPromocion(
        widget.promocion!.copyWith(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          descuentoPorcentaje: desc,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
          hosteriaId: _selectedHosteriaId,
          habitacionId: _selectedHabitacionId,
        ),
      );
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promoción guardada exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.promocion == null ? 'Añadir Promoción' : 'Editar Promoción',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción *'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descuentoController,
                decoration: const InputDecoration(labelText: 'Descuento (%) *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rango de Fechas'),
                subtitle: Text(
                  '${_fechaInicio.toString().split(' ')[0]} - ${_fechaFin.toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFechas,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _selectedHosteriaId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Hostería (Opcional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas (Global)'),
                  ),
                  ...context.read<HosteriaViewModel>().hosterias.map(
                    (h) => DropdownMenuItem(value: h.id, child: Text(h.nombre)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedHosteriaId = val;
                    _selectedHabitacionId = null;
                  });
                  if (val != null) {
                    context
                        .read<HabitacionViewModel>()
                        .cargarHabitacionesPorHosteria(val);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedHosteriaId != null)
                Consumer<HabitacionViewModel>(
                  builder: (context, habVm, child) {
                    if (habVm.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final habitacionesDeHosteria = habVm.habitaciones
                        .where((h) => h.hosteriaId == _selectedHosteriaId)
                        .toList();
                    final exists =
                        _selectedHabitacionId == null ||
                        habitacionesDeHosteria.any(
                          (h) => h.id == _selectedHabitacionId,
                        );
                    final currentValue = exists ? _selectedHabitacionId : null;

                    return DropdownButtonFormField<String?>(
                      initialValue: currentValue,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Habitación (Opcional)',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas las habitaciones'),
                        ),
                        ...habitacionesDeHosteria.map(
                          (h) => DropdownMenuItem(
                            value: h.id,
                            child: Text(h.tipo),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedHabitacionId = val;
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorSchemeApp.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
