import '../models/cliente_model.dart';
import '../datasources/local/database_helper.dart';
import '../../core/utils/formato_utils.dart';

class ClienteRepositoryImpl {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Crear cliente
  Future<ClienteModel> crearCliente(ClienteModel cliente) async {
    final db = await _db.database;

    // Generar código único si no existe
    String codigo = cliente.codigo;
    if (codigo.isEmpty) {
      final count = await _contarClientes() + 1;
      codigo = FormatoUtils.generarCodigoCliente(count);
    }

    final clienteConCodigo = cliente.copyWith(codigo: codigo);
    final id = await db.insert('clientes', clienteConCodigo.toMap());
    return clienteConCodigo.copyWith(id: id);
  }

  // Obtener cliente por ID
  Future<ClienteModel?> obtenerClientePorId(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ClienteModel.fromMap(maps.first);
  }

  // Obtener cliente por código
  Future<ClienteModel?> obtenerClientePorCodigo(String codigo) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );

    if (maps.isEmpty) return null;
    return ClienteModel.fromMap(maps.first);
  }

  // Obtener clientes por cobrador
  Future<List<ClienteModel>> obtenerClientesPorCobrador(int cobradorId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'cobrador_id = ? AND activo = 1',
      whereArgs: [cobradorId],
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => ClienteModel.fromMap(maps[i]));
  }

  // Obtener todos los clientes activos
  Future<List<ClienteModel>> obtenerClientesActivos() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'activo = 1',
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => ClienteModel.fromMap(maps[i]));
  }

  // Buscar clientes
  Future<List<ClienteModel>> buscarClientes(String query,
      {int? cobradorId}) async {
    final db = await _db.database;

    String whereClause =
        'activo = 1 AND (nombre LIKE ? OR cedula LIKE ? OR telefono LIKE ? OR codigo LIKE ?)';
    List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%', '%$query%'];

    if (cobradorId != null) {
      whereClause += ' AND cobrador_id = ?';
      whereArgs.add(cobradorId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => ClienteModel.fromMap(maps[i]));
  }

  // Obtener clientes por sector
  Future<List<ClienteModel>> obtenerClientesPorSector(
      String sector, int cobradorId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'sector = ? AND cobrador_id = ? AND activo = 1',
      whereArgs: [sector, cobradorId],
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => ClienteModel.fromMap(maps[i]));
  }

  // Actualizar cliente
  Future<int> actualizarCliente(ClienteModel cliente) async {
    final db = await _db.database;

    // Si cambió la dirección, guardar en historial
    final clienteAnterior = await obtenerClientePorId(cliente.id!);
    if (clienteAnterior != null &&
        (clienteAnterior.direccion != cliente.direccion ||
            clienteAnterior.sector != cliente.sector)) {
      await _guardarHistorialDireccion(
        cliente.id!,
        clienteAnterior.direccion,
        clienteAnterior.sector,
      );
    }

    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  // Desactivar cliente
  Future<int> desactivarCliente(int id) async {
    final db = await _db.database;
    return await db.update(
      'clientes',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contar clientes
  Future<int> _contarClientes() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM clientes');
    return result.first['count'] as int;
  }

  // Guardar historial de dirección
  Future<void> _guardarHistorialDireccion(
      int clienteId, String direccionAnterior, String sectorAnterior) async {
    final db = await _db.database;
    await db.insert('historial_direcciones', {
      'cliente_id': clienteId,
      'direccion_anterior': direccionAnterior,
      'sector_anterior': sectorAnterior,
      'fecha_cambio': DateTime.now().toIso8601String(),
    });
  }

  // Obtener historial de direcciones
  Future<List<Map<String, dynamic>>> obtenerHistorialDirecciones(
      int clienteId) async {
    final db = await _db.database;
    return await db.query(
      'historial_direcciones',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha_cambio DESC',
    );
  }

  // Obtener sectores únicos
  Future<List<String>> obtenerSectoresUnicos(int cobradorId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT sector FROM clientes WHERE cobrador_id = ? AND activo = 1 ORDER BY sector',
      [cobradorId],
    );

    return List.generate(maps.length, (i) => maps[i]['sector'] as String);
  }
}
