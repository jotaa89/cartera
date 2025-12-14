import 'package:flutter/foundation.dart';
import '../../data/models/cliente_model.dart';
import '../../data/repositories/cliente_repository_impl.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteRepositoryImpl _clienteRepo = ClienteRepositoryImpl();

  List<ClienteModel> _clientes = [];
  ClienteModel? _clienteSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<ClienteModel> get clientes => _clientes;
  ClienteModel? get clienteSeleccionado => _clienteSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar clientes por cobrador
  Future<void> cargarClientesPorCobrador(int cobradorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clientes = await _clienteRepo.obtenerClientesPorCobrador(cobradorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar clientes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar clientes
  Future<void> buscarClientes(String query, {int? cobradorId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clientes =
          await _clienteRepo.buscarClientes(query, cobradorId: cobradorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al buscar clientes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear cliente
  Future<ClienteModel?> crearCliente(ClienteModel cliente) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoCliente = await _clienteRepo.crearCliente(cliente);
      _clientes.insert(0, nuevoCliente);
      _isLoading = false;
      notifyListeners();
      return nuevoCliente;
    } catch (e) {
      _error = 'Error al crear cliente: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Actualizar cliente
  Future<bool> actualizarCliente(ClienteModel cliente) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _clienteRepo.actualizarCliente(cliente);

      final index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        _clientes[index] = cliente;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar cliente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Seleccionar cliente
  void seleccionarCliente(ClienteModel cliente) {
    _clienteSeleccionado = cliente;
    notifyListeners();
  }

  // Cargar cliente por ID
  Future<void> cargarClientePorId(int clienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clienteSeleccionado = await _clienteRepo.obtenerClientePorId(clienteId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar cliente: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar selección
  void limpiarSeleccion() {
    _clienteSeleccionado = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener sectores únicos
  Future<List<String>> obtenerSectores(int cobradorId) async {
    try {
      return await _clienteRepo.obtenerSectoresUnicos(cobradorId);
    } catch (e) {
      return [];
    }
  }
}
