import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../domain/entities/hosteria.dart';
import '../../themes/esquema_color.dart';
import '../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/hosteria_viewmodel.dart';
import '../widgets/hosteria_card.dart';
import '../widgets/language_selector.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
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

  void _navigateToLogin([Hosteria? hosteria]) {
    final isLoggedIn = context.read<AuthViewModel>().usuarioActual != null;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      if (hosteria != null) {
        Navigator.pushNamed(context, AppRoutes.hosteriaDetail, arguments: hosteria.id);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login, arguments: hosteria);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HosteriaViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final isLoggedIn = authViewModel.usuarioActual != null;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      body: RefreshIndicator(
        onRefresh: viewModel.cargarHosterias,
        color: ColorSchemeApp.primaryGreen,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: ColorSchemeApp.primaryGreen,
              actions: [
                const LanguageSelector(iconColor: Colors.white),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLoggedIn ? (l10n?.home ?? 'Inicio') : (l10n?.login ?? 'Ingresar'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image Placeholder (Can be an asset)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1B5133), // Verde medio
                            Color(0xFF0D2B1A), // Muy oscuro
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Optional Graphic/Pattern overlay here
                    const Positioned.fill(
                      child: Icon(Icons.landscape, size: 200, color: Colors.white10),
                    ),
                    Positioned(
                      bottom: 80,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.landingTitle ?? 'Descubre HostSigchos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.landingSubtitle ?? 'Encuentra el lugar perfecto para tu próxima aventura en la naturaleza.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: ColorSchemeApp.offWhite,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: viewModel.filtrarHosterias,
                            decoration: InputDecoration(
                              hintText: l10n?.searchHint ?? 'Buscar por nombre, ubicación...',
                              prefixIcon: const Icon(Icons.search, color: ColorSchemeApp.primaryGreen),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: ColorSchemeApp.softGray),
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
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: ColorSchemeApp.primaryGreen, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view, color: ColorSchemeApp.primaryGreen),
                            onPressed: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            if (viewModel.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: ColorSchemeApp.primaryGreen)),
              )
            else if (viewModel.errorMessage != null)
              SliverFillRemaining(
                child: Center(child: Text('${l10n?.error ?? 'Error'}: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.red))),
              )
            else if (viewModel.hosterias.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(l10n?.noHosteriasFound ?? 'No se encontraron hosterías.', style: const TextStyle(fontSize: 16))),
              )
            else if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hosteria = viewModel.hosterias[index];
                      return HosteriaCard(
                        hosteria: hosteria,
                        isGrid: true,
                        onTap: () => _navigateToLogin(hosteria),
                      );
                    },
                    childCount: viewModel.hosterias.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hosteria = viewModel.hosterias[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HosteriaCard(
                          hosteria: hosteria,
                          isGrid: false,
                          onTap: () => _navigateToLogin(hosteria),
                        ),
                      );
                    },
                    childCount: viewModel.hosterias.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
