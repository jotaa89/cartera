import '../models/estado_especial_model.dart';
import '../datasources/local/database_helper.dart';

class EstadoEspecialRepositoryImpl {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Registrar estado especial
  Future<EstadoEspecialModel> registrarEstado(
      EstadoEspecialModel estado) async {
    final db = await _db.database;
    final id = await db.insert('estados_especiales', estado.toMap());
    return estado.copyWith(id: id);
  }

  // Obtener estados por cliente
  Future<List<EstadoEspecialModel>> obtenerEstadosPorCliente(
      int clienteId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'estados_especiales',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha DESC',
    );

    return List.generate(
        maps.length, (i) => EstadoEspecialModel.fromMap(maps[i]));
  }

  // Obtener último estado del cliente
  Future<EstadoEspecialModel?> obtenerUltimoEstado(int clienteId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'estados_especiales',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return EstadoEspecialModel.fromMap(maps.first);
  }

  // Obtener estados del día
  Future<List<Map<String, dynamic>>> obtenerEstadosDelDia(
      int cobradorId, DateTime fecha) async {
    final db = await _db.database;

    final inicioDia =
        DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();
    final finDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59)
        .toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        e.*,
        c.nombre as cliente_nombre,
        c.sector
      FROM estados_especiales e
      INNER JOIN clientes c ON e.cliente_id = c.id
      WHERE c.cobrador_id = ?
        AND e.fecha >= ?
        AND e.fecha <= ?
      ORDER BY e.fecha DESC
    ''', [cobradorId, inicioDia, finDia]);

    return maps;
  }

  // Contar estados por tipo en un rango de fechas
  Future<Map<String, int>> contarEstadosPorTipo(
    int cobradorId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        e.tipo_estado,
        COUNT(*) as cantidad
      FROM estados_especiales e
      INNER JOIN clientes c ON e.cliente_id = c.id
      WHERE c.cobrador_id = ?
        AND e.fecha >= ?
        AND e.fecha <= ?
      GROUP BY e.tipo_estado
    ''', [
      cobradorId,
      fechaInicio.toIso8601String(),
      fechaFin.toIso8601String(),
    ]);

    final Map<String, int> resultado = {};
    for (var map in maps) {
      resultado[map['tipo_estado'] as String] = map['cantidad'] as int;
    }

    return resultado;
  }

  // Eliminar estado
  Future<int> eliminarEstado(int estadoId) async {
    final db = await _db.database;
    return await db.delete(
      'estados_especiales',
      where: 'id = ?',
      whereArgs: [estadoId],
    );
  }

  // Actualizar estado
  Future<int> actualizarEstado(EstadoEspecialModel estado) async {
    final db = await _db.database;
    return await db.update(
      'estados_especiales',
      estado.toMap(),
      where: 'id = ?',
      whereArgs: [estado.id],
    );
  }
}
