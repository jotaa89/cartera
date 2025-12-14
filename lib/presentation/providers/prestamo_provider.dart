import 'package:flutter/foundation.dart';
import '../../data/models/prestamo_model.dart';
import '../../data/repositories/prestamo_repository_impl.dart';

class PrestamoProvider extends ChangeNotifier {
  final PrestamoRepositoryImpl _prestamoRepo = PrestamoRepositoryImpl();

  List<PrestamoModel> _prestamos = [];
  PrestamoModel? _prestamoSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<PrestamoModel> get prestamos => _prestamos;
  PrestamoModel? get prestamoSeleccionado => _prestamoSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar préstamos activos por cobrador
  Future<void> cargarPrestamosActivos(int cobradorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prestamos =
          await _prestamoRepo.obtenerPrestamosActivosPorCobrador(cobradorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar préstamos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar préstamos por cliente
  Future<void> cargarPrestamosPorCliente(int clienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prestamos = await _prestamoRepo.obtenerPrestamosPorCliente(clienteId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar préstamos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear préstamo
  Future<PrestamoModel?> crearPrestamo(PrestamoModel prestamo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoPrestamo = await _prestamoRepo.crearPrestamo(prestamo);
      _prestamos.insert(0, nuevoPrestamo);
      _isLoading = false;
      notifyListeners();
      return nuevoPrestamo;
    } catch (e) {
      _error = 'Error al crear préstamo: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Renovar préstamo
  Future<Map<String, dynamic>?> renovarPrestamo(
    int prestamoOriginalId,
    double abonoRealizado,
    PrestamoModel nuevoPrestamo,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _prestamoRepo.renovarPrestamo(
        prestamoOriginalId,
        abonoRealizado,
        nuevoPrestamo,
      );

      // Actualizar la lista local
      final index = _prestamos.indexWhere((p) => p.id == prestamoOriginalId);
      if (index != -1) {
        _prestamos[index] = _prestamos[index].copyWith(estado: 'RENOVADO');
      }

      _isLoading = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _error = 'Error al renovar préstamo: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Seleccionar préstamo
  void seleccionarPrestamo(PrestamoModel prestamo) {
    _prestamoSeleccionado = prestamo;
    notifyListeners();
  }

  // Cargar préstamo por ID
  Future<void> cargarPrestamoPorId(int prestamoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prestamoSeleccionado =
          await _prestamoRepo.obtenerPrestamoPorId(prestamoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar préstamo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar saldo
  Future<bool> actualizarSaldo(int prestamoId, double nuevoSaldo) async {
    try {
      await _prestamoRepo.actualizarSaldo(prestamoId, nuevoSaldo);

      // Actualizar en la lista local
      final index = _prestamos.indexWhere((p) => p.id == prestamoId);
      if (index != -1) {
        _prestamos[index] =
            _prestamos[index].copyWith(saldoPendiente: nuevoSaldo);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar saldo: $e';
      notifyListeners();
      return false;
    }
  }

  // Limpiar selección
  void limpiarSeleccion() {
    _prestamoSeleccionado = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> obtenerEstadisticas(int cobradorId) async {
    try {
      return await _prestamoRepo.obtenerEstadisticas(cobradorId);
    } catch (e) {
      return {};
    }
  }
}
