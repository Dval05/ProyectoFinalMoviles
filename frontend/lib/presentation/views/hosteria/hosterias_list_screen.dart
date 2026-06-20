import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/hosteria_card.dart';

class HosteriasListScreen extends StatefulWidget {
  const HosteriasListScreen({super.key});

  @override
  State<HosteriasListScreen> createState() => _HosteriasListScreenState();
}

class _HosteriasListScreenState extends State<HosteriasListScreen> {
  final _searchController = TextEditingController();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => viewModel.filtrarHosterias(value),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                      onRefresh: () => viewModel.cargarHosterias(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.hosterias.length,
                        itemBuilder: (context, index) {
                          final hosteria = viewModel.hosterias[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: HosteriaCard(
                              hosteria: hosteria,
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
}
