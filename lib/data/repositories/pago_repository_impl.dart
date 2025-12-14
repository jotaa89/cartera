import '../models/pago_model.dart';
import '../datasources/local/database_helper.dart';
import '../../core/utils/fecha_utils.dart';

class PagoRepositoryImpl {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Registrar pago
  Future<PagoModel> registrarPago(PagoModel pago) async {
    final db = await _db.database;

    // Iniciar transacción para actualizar el saldo del préstamo
    return await db.transaction((txn) async {
      // 1. Insertar pago
      final id = await txn.insert('pagos', pago.toMap());

      // 2. Actualizar saldo del préstamo
      final prestamo = await txn.query(
        'prestamos',
        where: 'id = ?',
        whereArgs: [pago.prestamoId],
      );

      if (prestamo.isNotEmpty) {
        final saldoActual =
            (prestamo.first['saldo_pendiente'] as num).toDouble();
        final nuevoSaldo = saldoActual - pago.monto;

        // Si el saldo llega a 0 o menos, marcar como completado
        final estado = nuevoSaldo <= 0 ? 'COMPLETADO' : 'ACTIVO';

        await txn.update(
          'prestamos',
          {
            'saldo_pendiente': nuevoSaldo > 0 ? nuevoSaldo : 0,
            'estado': estado,
          },
          where: 'id = ?',
          whereArgs: [pago.prestamoId],
        );
      }

      return pago.copyWith(id: id);
    });
  }

  // Obtener pagos por préstamo
  Future<List<PagoModel>> obtenerPagosPorPrestamo(int prestamoId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pagos',
      where: 'prestamo_id = ?',
      whereArgs: [prestamoId],
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) => PagoModel.fromMap(maps[i]));
  }

  // Obtener pagos del día por cobrador
  Future<List<Map<String, dynamic>>> obtenerPagosDelDia(
      int cobradorId, DateTime fecha) async {
    final db = await _db.database;

    final inicioDia = FechaUtils.inicioDia(fecha).toIso8601String();
    final finDia = FechaUtils.finDia(fecha).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        pa.*, 
        pr.codigo as prestamo_codigo,
        pr.cliente_id,
        c.nombre as cliente_nombre,
        c.sector
      FROM pagos pa
      INNER JOIN prestamos pr ON pa.prestamo_id = pr.id
      INNER JOIN clientes c ON pr.cliente_id = c.id
      WHERE pr.cobrador_id = ?
        AND pa.fecha >= ?
        AND pa.fecha <= ?
      ORDER BY pa.fecha DESC
    ''', [cobradorId, inicioDia, finDia]);

    return maps;
  }

  // Obtener total cobrado en un día
  Future<double> obtenerTotalCobradoDelDia(
      int cobradorId, DateTime fecha) async {
    final db = await _db.database;

    final inicioDia = FechaUtils.inicioDia(fecha).toIso8601String();
    final finDia = FechaUtils.finDia(fecha).toIso8601String();

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(pa.monto + pa.mora_extra), 0) as total
      FROM pagos pa
      INNER JOIN prestamos pr ON pa.prestamo_id = pr.id
      WHERE pr.cobrador_id = ?
        AND pa.fecha >= ?
        AND pa.fecha <= ?
    ''', [cobradorId, inicioDia, finDia]);

    return (result.first['total'] as num).toDouble();
  }

  // Obtener total de mora cobrada en un día
  Future<double> obtenerMoraCobradaDelDia(
      int cobradorId, DateTime fecha) async {
    final db = await _db.database;

    final inicioDia = FechaUtils.inicioDia(fecha).toIso8601String();
    final finDia = FechaUtils.finDia(fecha).toIso8601String();

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(pa.mora_extra), 0) as total_mora
      FROM pagos pa
      INNER JOIN prestamos pr ON pa.prestamo_id = pr.id
      WHERE pr.cobrador_id = ?
        AND pa.fecha >= ?
        AND pa.fecha <= ?
    ''', [cobradorId, inicioDia, finDia]);

    return (result.first['total_mora'] as num).toDouble();
  }

  // Verificar si ya se pagó hoy
  Future<bool> yaPagoHoy(int prestamoId) async {
    final db = await _db.database;

    final hoy = DateTime.now();
    final inicioDia = FechaUtils.inicioDia(hoy).toIso8601String();
    final finDia = FechaUtils.finDia(hoy).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'pagos',
      where: 'prestamo_id = ? AND fecha >= ? AND fecha <= ?',
      whereArgs: [prestamoId, inicioDia, finDia],
    );

    return maps.isNotEmpty;
  }

  // Obtener último pago
  Future<PagoModel?> obtenerUltimoPago(int prestamoId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pagos',
      where: 'prestamo_id = ?',
      whereArgs: [prestamoId],
      orderBy: 'fecha DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return PagoModel.fromMap(maps.first);
  }

  // Obtener pagos en un rango de fechas
  Future<List<PagoModel>> obtenerPagosEnRango(
    int cobradorId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT pa.*
      FROM pagos pa
      INNER JOIN prestamos pr ON pa.prestamo_id = pr.id
      WHERE pr.cobrador_id = ?
        AND pa.fecha >= ?
        AND pa.fecha <= ?
      ORDER BY pa.fecha DESC
    ''', [
      cobradorId,
      fechaInicio.toIso8601String(),
      fechaFin.toIso8601String(),
    ]);

    return List.generate(maps.length, (i) => PagoModel.fromMap(maps[i]));
  }

  // Obtener pagos no sincronizados
  Future<List<PagoModel>> obtenerPagosNoSincronizados() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pagos',
      where: 'sincronizado = 0',
      orderBy: 'fecha ASC',
    );

    return List.generate(maps.length, (i) => PagoModel.fromMap(maps[i]));
  }

  // Marcar pago como sincronizado
  Future<int> marcarComoSincronizado(int pagoId) async {
    final db = await _db.database;
    return await db.update(
      'pagos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [pagoId],
    );
  }

  // Actualizar pago
  Future<int> actualizarPago(PagoModel pago) async {
    final db = await _db.database;
    return await db.update(
      'pagos',
      pago.toMap(),
      where: 'id = ?',
      whereArgs: [pago.id],
    );
  }

  // Eliminar pago (usar con precaución)
  Future<int> eliminarPago(int pagoId) async {
    final db = await _db.database;
    return await db.delete(
      'pagos',
      where: 'id = ?',
      whereArgs: [pagoId],
    );
  }

  // Obtener estadísticas de pagos
  Future<Map<String, dynamic>> obtenerEstadisticasPagos(
      int cobradorId, DateTime mes) async {
    final db = await _db.database;

    final inicioMes = DateTime(mes.year, mes.month, 1).toIso8601String();
    final finMes =
        DateTime(mes.year, mes.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_pagos,
        SUM(pa.monto) as total_capital,
        SUM(pa.mora_extra) as total_mora,
        SUM(pa.monto + pa.mora_extra) as total_general
      FROM pagos pa
      INNER JOIN prestamos pr ON pa.prestamo_id = pr.id
      WHERE pr.cobrador_id = ?
        AND pa.fecha >= ?
        AND pa.fecha <= ?
    ''', [cobradorId, inicioMes, finMes]);

    return result.first;
  }
}
