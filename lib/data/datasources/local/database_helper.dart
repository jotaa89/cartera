import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla Usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        pin TEXT NOT NULL,
        rol TEXT NOT NULL,
        comision_porcentaje REAL DEFAULT 0.10,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL
      )
    ''');

    // Tabla Clientes
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        cedula TEXT NOT NULL,
        telefono TEXT NOT NULL,
        tel_referencia TEXT NOT NULL,
        nombre_referencia TEXT NOT NULL,
        direccion TEXT NOT NULL,
        sector TEXT NOT NULL,
        foto_path TEXT,
        referencia1_nombre TEXT,
        referencia1_tel TEXT,
        referencia2_nombre TEXT,
        referencia2_tel TEXT,
        observaciones TEXT,
        fecha_creacion TEXT NOT NULL,
        cobrador_id INTEGER NOT NULL,
        activo INTEGER DEFAULT 1,
        FOREIGN KEY (cobrador_id) REFERENCES usuarios (id)
      )
    ''');

    // Tabla Préstamos
    await db.execute('''
      CREATE TABLE prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        codigo TEXT NOT NULL UNIQUE,
        capital REAL NOT NULL,
        tipo_prestamo TEXT NOT NULL,
        tasa_interes REAL NOT NULL,
        cuota_diaria REAL NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_vencimiento TEXT NOT NULL,
        dias_plazo INTEGER NOT NULL,
        saldo_pendiente REAL NOT NULL,
        estado TEXT NOT NULL,
        prestamo_padre_id INTEGER,
        cobrador_id INTEGER NOT NULL,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id),
        FOREIGN KEY (cobrador_id) REFERENCES usuarios (id),
        FOREIGN KEY (prestamo_padre_id) REFERENCES prestamos (id)
      )
    ''');

    // Tabla Pagos
    await db.execute('''
      CREATE TABLE pagos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prestamo_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        monto REAL NOT NULL,
        mora_extra REAL DEFAULT 0,
        metodo_pago TEXT NOT NULL,
        notas TEXT,
        sincronizado INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (prestamo_id) REFERENCES prestamos (id)
      )
    ''');

    // Tabla Estados Especiales
    await db.execute('''
      CREATE TABLE estados_especiales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        tipo_estado TEXT NOT NULL,
        notas TEXT,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id)
      )
    ''');

    // Tabla Renovaciones
    await db.execute('''
      CREATE TABLE renovaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prestamo_original_id INTEGER NOT NULL,
        prestamo_nuevo_id INTEGER NOT NULL,
        abono_realizado REAL NOT NULL,
        fecha_renovacion TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        FOREIGN KEY (prestamo_original_id) REFERENCES prestamos (id),
        FOREIGN KEY (prestamo_nuevo_id) REFERENCES prestamos (id)
      )
    ''');

    // Tabla Historial de Direcciones
    await db.execute('''
      CREATE TABLE historial_direcciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        direccion_anterior TEXT NOT NULL,
        sector_anterior TEXT NOT NULL,
        fecha_cambio TEXT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id)
      )
    ''');

    // Índices para mejorar rendimiento
    await db
        .execute('CREATE INDEX idx_clientes_cobrador ON clientes(cobrador_id)');
    await db.execute('CREATE INDEX idx_clientes_codigo ON clientes(codigo)');
    await db
        .execute('CREATE INDEX idx_prestamos_cliente ON prestamos(cliente_id)');
    await db.execute(
        'CREATE INDEX idx_prestamos_cobrador ON prestamos(cobrador_id)');
    await db.execute('CREATE INDEX idx_prestamos_estado ON prestamos(estado)');
    await db.execute('CREATE INDEX idx_pagos_prestamo ON pagos(prestamo_id)');
    await db.execute('CREATE INDEX idx_pagos_fecha ON pagos(fecha)');

    // Crear usuario administrador por defecto
    await db.insert('usuarios', {
      'nombre': 'Administrador',
      'pin': '1234',
      'rol': AppConstants.rolAdmin,
      'comision_porcentaje': 0.0,
      'activo': 1,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Aquí se manejarán las migraciones futuras
    if (oldVersion < 2) {
      // Ejemplo de migración
      // await db.execute('ALTER TABLE usuarios ADD COLUMN nuevo_campo TEXT');
    }
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Método para eliminar la base de datos (útil para desarrollo)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Método para ejecutar consultas raw (útil para reportes complejos)
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Método para ejecutar inserts/updates/deletes raw
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }
}
