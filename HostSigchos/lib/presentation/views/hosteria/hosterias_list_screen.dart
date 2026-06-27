import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../widgets/hosteria_card.dart';

class HosteriasListScreen extends StatefulWidget {
  const HosteriasListScreen({super.key});

  @override
  State<HosteriasListScreen> createState() => _HosteriasListScreenState();
}

class _HosteriasListScreenState extends State<HosteriasListScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    // Asegurarse de que están cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HosteriaViewModel>();
      if (vm.hosterias.isEmpty) {
        vm.cargarHosterias();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HosteriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosterías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltrosAvanzados,
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: viewModel.filtrarHosterias,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, ubicación...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.filtrarHosterias('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(child: Text('Error: ${viewModel.errorMessage}'))
          : viewModel.hosterias.isEmpty
          ? const Center(child: Text('No se encontraron hosterías'))
          : RefreshIndicator(
              onRefresh: viewModel.cargarHosterias,
              child: _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: viewModel.hosterias.length,
                      itemBuilder: (context, index) {
                        final hosteria = viewModel.hosterias[index];
                        return HosteriaCard(
                          hosteria: hosteria,
                          isGrid: true,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.hosteriaDetail,
                              arguments: hosteria.id,
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: viewModel.hosterias.length,
                      itemBuilder: (context, index) {
                        final hosteria = viewModel.hosterias[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: HosteriaCard(
                            hosteria: hosteria,
                            isGrid: false,
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
            ),
    );
  }

  void _mostrarFiltrosAvanzados() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FiltrosBottomSheet(),
    );
  }
}

class _FiltrosBottomSheet extends StatefulWidget {
  @override
  State<_FiltrosBottomSheet> createState() => _FiltrosBottomSheetState();
}

class _FiltrosBottomSheetState extends State<_FiltrosBottomSheet> {
  RangeValues? _precios;
  String? _ubicacion;
  OrdenHosterias _orden = OrdenHosterias.ninguno;
  // Agrega variables de fecha si lo necesitas (por simplificar, dejamos precios y ubicación)

  @override
  void initState() {
    super.initState();
    final vm = context.read<HosteriaViewModel>();
    _precios = vm.filtroPrecios ?? const RangeValues(10, 200);
    _ubicacion = vm.filtroUbicacion;
    _orden = vm.ordenActual;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.advancedFilters, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(l10n.priceRange),
          RangeSlider(
            values: _precios!,
            min: 10,
            max: 500,
            divisions: 49,
            labels: RangeLabels('\$${_precios!.start.round()}', '\$${_precios!.end.round()}'),
            onChanged: (values) {
              setState(() {
                _precios = values;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_precios!.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${_precios!.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _ubicacion,
            decoration: InputDecoration(
              labelText: l10n.locationFilterHint,
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              _ubicacion = val;
            },
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.sortTitle,
              prefixIcon: const Icon(Icons.sort),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OrdenHosterias>(
                value: _orden,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: OrdenHosterias.ninguno, child: Text(AppLocalizations.of(context)!.sortNone)),
                  DropdownMenuItem(value: OrdenHosterias.precioMenorAMayor, child: Text(AppLocalizations.of(context)!.sortPriceAsc)),
                  DropdownMenuItem(value: OrdenHosterias.precioMayorAMenor, child: Text(AppLocalizations.of(context)!.sortPriceDesc)),
                  DropdownMenuItem(value: OrdenHosterias.nombreAZ, child: Text(AppLocalizations.of(context)!.sortNameAsc)),
                  DropdownMenuItem(value: OrdenHosterias.nombreZA, child: Text(AppLocalizations.of(context)!.sortNameDesc)),
                  DropdownMenuItem(value: OrdenHosterias.ratingMayorAMenor, child: Text(AppLocalizations.of(context)!.sortRatingDesc)),
                  DropdownMenuItem(value: OrdenHosterias.ratingMenorAMayor, child: Text(AppLocalizations.of(context)!.sortRatingAsc)),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _orden = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<HosteriaViewModel>().limpiarFiltrosAvanzados();
                    Navigator.pop(context);
                  },
                  child: Text(l10n.clear),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<HosteriaViewModel>()
                      ..aplicarFiltrosAvanzados(
                        precios: _precios,
                        ubicacion: _ubicacion,
                      )
                      ..cambiarOrden(_orden);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.apply),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
