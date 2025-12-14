import '../models/prestamo_model.dart';
import '../models/renovacion_model.dart';
import '../datasources/local/database_helper.dart';
import '../../core/utils/formato_utils.dart';
import '../../core/constants/app_constants.dart';

class PrestamoRepositoryImpl {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Crear préstamo
  Future<PrestamoModel> crearPrestamo(PrestamoModel prestamo) async {
    final db = await _db.database;

    // Generar código único
    String codigo = prestamo.codigo;
    if (codigo.isEmpty) {
      final countCliente = await _contarPrestamosPorCliente(prestamo.clienteId);
      codigo = FormatoUtils.generarCodigoPrestamo(
          prestamo.clienteId, countCliente + 1);
    }

    final prestamoConCodigo = prestamo.copyWith(codigo: codigo);
    final id = await db.insert('prestamos', prestamoConCodigo.toMap());
    return prestamoConCodigo.copyWith(id: id);
  }

  // Obtener préstamo por ID
  Future<PrestamoModel?> obtenerPrestamoPorId(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prestamos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PrestamoModel.fromMap(maps.first);
  }

  // Obtener préstamos por cliente
  Future<List<PrestamoModel>> obtenerPrestamosPorCliente(int clienteId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prestamos',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha_inicio DESC',
    );

    return List.generate(maps.length, (i) => PrestamoModel.fromMap(maps[i]));
  }

  // Obtener préstamos activos por cobrador
  Future<List<PrestamoModel>> obtenerPrestamosActivosPorCobrador(
      int cobradorId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prestamos',
      where: 'cobrador_id = ? AND estado = ?',
      whereArgs: [cobradorId, AppConstants.prestamoActivo],
      orderBy: 'fecha_vencimiento ASC',
    );

    return List.generate(maps.length, (i) => PrestamoModel.fromMap(maps[i]));
  }

  // Obtener préstamo activo de un cliente
  Future<PrestamoModel?> obtenerPrestamoActivoDelCliente(int clienteId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prestamos',
      where: 'cliente_id = ? AND estado = ?',
      whereArgs: [clienteId, AppConstants.prestamoActivo],
      orderBy: 'fecha_inicio DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return PrestamoModel.fromMap(maps.first);
  }

  // Actualizar préstamo
  Future<int> actualizarPrestamo(PrestamoModel prestamo) async {
    final db = await _db.database;
    return await db.update(
      'prestamos',
      prestamo.toMap(),
      where: 'id = ?',
      whereArgs: [prestamo.id],
    );
  }

  // Actualizar saldo
  Future<int> actualizarSaldo(int prestamoId, double nuevoSaldo) async {
    final db = await _db.database;

    // Si el saldo llega a 0, marcar como completado
    String estado = nuevoSaldo <= 0
        ? AppConstants.prestamoCompletado
        : AppConstants.prestamoActivo;

    return await db.update(
      'prestamos',
      {
        'saldo_pendiente': nuevoSaldo,
        'estado': estado,
      },
      where: 'id = ?',
      whereArgs: [prestamoId],
    );
  }

  // Renovar préstamo
  Future<Map<String, dynamic>> renovarPrestamo(
    int prestamoOriginalId,
    double abonoRealizado,
    PrestamoModel nuevoPrestamo,
  ) async {
    final db = await _db.database;

    // Iniciar transacción
    return await db.transaction((txn) async {
      // 1. Marcar préstamo original como renovado
      await txn.update(
        'prestamos',
        {'estado': AppConstants.prestamoRenovado},
        where: 'id = ?',
        whereArgs: [prestamoOriginalId],
      );

      // 2. Crear nuevo préstamo
      final nuevoPrestamoId =
          await txn.insert('prestamos', nuevoPrestamo.toMap());

      // 3. Registrar renovación
      await txn.insert('renovaciones', {
        'prestamo_original_id': prestamoOriginalId,
        'prestamo_nuevo_id': nuevoPrestamoId,
        'abono_realizado': abonoRealizado,
        'fecha_renovacion': DateTime.now().toIso8601String(),
        'fecha_creacion': DateTime.now().toIso8601String(),
      });

      return {
        'prestamo_original_id': prestamoOriginalId,
        'prestamo_nuevo_id': nuevoPrestamoId,
      };
    });
  }

  // Obtener historial de renovaciones
  Future<List<RenovacionModel>> obtenerHistorialRenovaciones(
      int clienteId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT r.* FROM renovaciones r
      INNER JOIN prestamos p ON r.prestamo_original_id = p.id
      WHERE p.cliente_id = ?
      ORDER BY r.fecha_renovacion DESC
    ''', [clienteId]);

    return List.generate(maps.length, (i) => RenovacionModel.fromMap(maps[i]));
  }

  // Contar préstamos por cliente
  Future<int> _contarPrestamosPorCliente(int clienteId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM prestamos WHERE cliente_id = ?',
      [clienteId],
    );
    return result.first['count'] as int;
  }

  // Obtener estadísticas de préstamos
  Future<Map<String, dynamic>> obtenerEstadisticas(int cobradorId) async {
    final db = await _db.database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_prestamos,
        SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as activos,
        SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as completados,
        SUM(capital) as capital_total,
        SUM(saldo_pendiente) as saldo_total
      FROM prestamos
      WHERE cobrador_id = ?
    ''', [
      AppConstants.prestamoActivo,
      AppConstants.prestamoCompletado,
      cobradorId
    ]);

    return result.first;
  }

  // Buscar préstamos
  Future<List<PrestamoModel>> buscarPrestamos(String query,
      {int? cobradorId}) async {
    final db = await _db.database;

    String whereClause = 'codigo LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];

    if (cobradorId != null) {
      whereClause += ' AND cobrador_id = ?';
      whereArgs.add(cobradorId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'prestamos',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'fecha_inicio DESC',
    );

    return List.generate(maps.length, (i) => PrestamoModel.fromMap(maps[i]));
  }
}
