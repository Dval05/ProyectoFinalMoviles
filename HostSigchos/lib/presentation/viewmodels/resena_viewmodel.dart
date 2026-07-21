import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/resena.dart';
import '../../domain/usecases/resena/agregar_resena_usecase.dart';
import '../../domain/usecases/resena/get_resenas_por_hosteria_usecase.dart';

class ResenaViewModel extends ChangeNotifier {
  ResenaViewModel({
    required this.agregarResenaUseCase,
    required this.getResenasPorHosteriaUseCase,
  });

  final AgregarResenaUseCase agregarResenaUseCase;
  final GetResenasPorHosteriaUseCase getResenasPorHosteriaUseCase;

  List<Resena> _resenas = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Resena>>? _subscription;

  List<Resena> get resenas => _resenas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToResenas(String hosteriaId) {
    _setLoading(true);
    _subscription?.cancel();
    _subscription = getResenasPorHosteriaUseCase(hosteriaId).listen(
      (resenasList) {
        _resenas = resenasList;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = ErrorHandler.getFriendlyMessage(e);
        _setLoading(false);
      },
    );
  }

  Future<bool> agregarResena(Resena resena) async {
    _setLoading(true);
    try {
      await agregarResenaUseCase(resena);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
