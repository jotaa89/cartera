import 'package:flutter/foundation.dart';
import '../../data/models/usuario_model.dart';
import '../../data/repositories/usuario_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final UsuarioRepositoryImpl _usuarioRepo = UsuarioRepositoryImpl();

  UsuarioModel? _usuarioActual;
  bool _isLoading = false;
  String? _error;

  UsuarioModel? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _usuarioActual != null;
  bool get isAdmin => _usuarioActual?.rol == 'admin';
  bool get isCobrador => _usuarioActual?.rol == 'cobrador';

  // Login con PIN
  Future<bool> login(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _usuarioRepo.obtenerUsuarioPorPin(pin);

      if (usuario == null) {
        _error = 'PIN incorrecto';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _usuarioActual = usuario;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _usuarioActual = null;
    _error = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Actualizar usuario actual
  void updateUsuarioActual(UsuarioModel usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }
}
