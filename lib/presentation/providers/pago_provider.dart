import 'package:flutter/foundation.dart';
import '../../data/models/pago_model.dart';
import '../../data/repositories/pago_repository_impl.dart';

class PagoProvider extends ChangeNotifier {
  final PagoRepositoryImpl _pagoRepo = PagoRepositoryImpl();

  List<PagoModel> _pagos = [];
  bool _isLoading = false;
  String? _error;
  double _totalCobradoHoy = 0.0;
  double _moraCobradaHoy = 0.0;

  List<PagoModel> get pagos => _pagos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalCobradoHoy => _totalCobradoHoy;
  double get moraCobradaHoy => _moraCobradaHoy;

  // Registrar pago
  Future<PagoModel?> registrarPago(PagoModel pago) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoPago = await _pagoRepo.registrarPago(pago);
      _pagos.insert(0, nuevoPago);
      _isLoading = false;
      notifyListeners();
      return nuevoPago;
    } catch (e) {
      _error = 'Error al registrar pago: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Cargar pagos por préstamo
  Future<void> cargarPagosPorPrestamo(int prestamoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pagos = await _pagoRepo.obtenerPagosPorPrestamo(prestamoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar pagos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar totales del día
  Future<void> cargarTotalesDelDia(int cobradorId, DateTime fecha) async {
    try {
      _totalCobradoHoy =
          await _pagoRepo.obtenerTotalCobradoDelDia(cobradorId, fecha);
      _moraCobradaHoy =
          await _pagoRepo.obtenerMoraCobradaDelDia(cobradorId, fecha);
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar totales: $e';
      notifyListeners();
    }
  }

  // Verificar si ya pagó hoy
  Future<bool> yaPagoHoy(int prestamoId) async {
    try {
      return await _pagoRepo.yaPagoHoy(prestamoId);
    } catch (e) {
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refrescar(int cobradorId) async {
    await cargarTotalesDelDia(cobradorId, DateTime.now());
  }
}
