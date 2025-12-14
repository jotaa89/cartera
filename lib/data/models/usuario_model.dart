class UsuarioModel {
  final int? id;
  final String nombre;
  final String pin;
  final String rol;
  final double comisionPorcentaje;
  final bool activo;
  final DateTime fechaCreacion;

  UsuarioModel({
    this.id,
    required this.nombre,
    required this.pin,
    required this.rol,
    this.comisionPorcentaje = 0.10,
    this.activo = true,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Convertir de Map (SQLite) a Modelo
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      pin: map['pin'] as String,
      rol: map['rol'] as String,
      comisionPorcentaje:
          (map['comision_porcentaje'] as num?)?.toDouble() ?? 0.10,
      activo: (map['activo'] as int) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  // Convertir de Modelo a Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'pin': pin,
      'rol': rol,
      'comision_porcentaje': comisionPorcentaje,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  // Convertir a JSON (para sincronización futura)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'pin': pin,
      'rol': rol,
      'comisionPorcentaje': comisionPorcentaje,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      pin: json['pin'] as String,
      rol: json['rol'] as String,
      comisionPorcentaje:
          (json['comisionPorcentaje'] as num?)?.toDouble() ?? 0.10,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  // Método copyWith para crear copias modificadas
  UsuarioModel copyWith({
    int? id,
    String? nombre,
    String? pin,
    String? rol,
    double? comisionPorcentaje,
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      pin: pin ?? this.pin,
      rol: rol ?? this.rol,
      comisionPorcentaje: comisionPorcentaje ?? this.comisionPorcentaje,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'UsuarioModel(id: $id, nombre: $nombre, rol: $rol, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsuarioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
