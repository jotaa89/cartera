import '../models/usuario_model.dart';
import '../datasources/local/database_helper.dart';

class UsuarioRepositoryImpl {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Crear usuario
  Future<UsuarioModel> crearUsuario(UsuarioModel usuario) async {
    final db = await _db.database;
    final id = await db.insert('usuarios', usuario.toMap());
    return usuario.copyWith(id: id);
  }

  // Obtener usuario por ID
  Future<UsuarioModel?> obtenerUsuarioPorId(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UsuarioModel.fromMap(maps.first);
  }

  // Obtener usuario por PIN
  Future<UsuarioModel?> obtenerUsuarioPorPin(String pin) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'pin = ? AND activo = 1',
      whereArgs: [pin],
    );

    if (maps.isEmpty) return null;
    return UsuarioModel.fromMap(maps.first);
  }

  // Obtener todos los usuarios activos
  Future<List<UsuarioModel>> obtenerUsuariosActivos() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'activo = 1',
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => UsuarioModel.fromMap(maps[i]));
  }

  // Obtener todos los cobradores
  Future<List<UsuarioModel>> obtenerCobradores() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'rol = ? AND activo = 1',
      whereArgs: ['cobrador'],
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) => UsuarioModel.fromMap(maps[i]));
  }

  // Actualizar usuario
  Future<int> actualizarUsuario(UsuarioModel usuario) async {
    final db = await _db.database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Desactivar usuario (soft delete)
  Future<int> desactivarUsuario(int id) async {
    final db = await _db.database;
    return await db.update(
      'usuarios',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar usuario (hard delete)
  Future<int> eliminarUsuario(int id) async {
    final db = await _db.database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Verificar si existe un PIN
  Future<bool> existePin(String pin) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'pin = ?',
      whereArgs: [pin],
    );
    return maps.isNotEmpty;
  }

  // Cambiar PIN de usuario
  Future<int> cambiarPin(int usuarioId, String nuevoPin) async {
    final db = await _db.database;
    return await db.update(
      'usuarios',
      {'pin': nuevoPin},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  // Actualizar comisión
  Future<int> actualizarComision(int usuarioId, double comision) async {
    final db = await _db.database;
    return await db.update(
      'usuarios',
      {'comision_porcentaje': comision},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }
}
