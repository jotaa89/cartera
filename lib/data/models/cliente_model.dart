class ClienteModel {
  final int? id;
  final String codigo;
  final String nombre;
  final String cedula;
  final String telefono;
  final String telReferencia;
  final String nombreReferencia;
  final String direccion;
  final String sector;
  final String? fotoPath;
  final String? referencia1Nombre;
  final String? referencia1Tel;
  final String? referencia2Nombre;
  final String? referencia2Tel;
  final String? observaciones;
  final DateTime fechaCreacion;
  final int cobradorId;
  final bool activo;

  ClienteModel({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.telReferencia,
    required this.nombreReferencia,
    required this.direccion,
    required this.sector,
    this.fotoPath,
    this.referencia1Nombre,
    this.referencia1Tel,
    this.referencia2Nombre,
    this.referencia2Tel,
    this.observaciones,
    DateTime? fechaCreacion,
    required this.cobradorId,
    this.activo = true,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Convertir de Map (SQLite) a Modelo
  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      id: map['id'] as int?,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      cedula: map['cedula'] as String,
      telefono: map['telefono'] as String,
      telReferencia: map['tel_referencia'] as String,
      nombreReferencia: map['nombre_referencia'] as String,
      direccion: map['direccion'] as String,
      sector: map['sector'] as String,
      fotoPath: map['foto_path'] as String?,
      referencia1Nombre: map['referencia1_nombre'] as String?,
      referencia1Tel: map['referencia1_tel'] as String?,
      referencia2Nombre: map['referencia2_nombre'] as String?,
      referencia2Tel: map['referencia2_tel'] as String?,
      observaciones: map['observaciones'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      cobradorId: map['cobrador_id'] as int,
      activo: (map['activo'] as int) == 1,
    );
  }

  // Convertir de Modelo a Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'tel_referencia': telReferencia,
      'nombre_referencia': nombreReferencia,
      'direccion': direccion,
      'sector': sector,
      'foto_path': fotoPath,
      'referencia1_nombre': referencia1Nombre,
      'referencia1_tel': referencia1Tel,
      'referencia2_nombre': referencia2Nombre,
      'referencia2_tel': referencia2Tel,
      'observaciones': observaciones,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'cobrador_id': cobradorId,
      'activo': activo ? 1 : 0,
    };
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'telReferencia': telReferencia,
      'nombreReferencia': nombreReferencia,
      'direccion': direccion,
      'sector': sector,
      'fotoPath': fotoPath,
      'referencia1Nombre': referencia1Nombre,
      'referencia1Tel': referencia1Tel,
      'referencia2Nombre': referencia2Nombre,
      'referencia2Tel': referencia2Tel,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'cobradorId': cobradorId,
      'activo': activo,
    };
  }

  // Crear desde JSON
  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int?,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      cedula: json['cedula'] as String,
      telefono: json['telefono'] as String,
      telReferencia: json['telReferencia'] as String,
      nombreReferencia: json['nombreReferencia'] as String,
      direccion: json['direccion'] as String,
      sector: json['sector'] as String,
      fotoPath: json['fotoPath'] as String?,
      referencia1Nombre: json['referencia1Nombre'] as String?,
      referencia1Tel: json['referencia1Tel'] as String?,
      referencia2Nombre: json['referencia2Nombre'] as String?,
      referencia2Tel: json['referencia2Tel'] as String?,
      observaciones: json['observaciones'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      cobradorId: json['cobradorId'] as int,
      activo: json['activo'] as bool? ?? true,
    );
  }

  // Método copyWith
  ClienteModel copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? cedula,
    String? telefono,
    String? telReferencia,
    String? nombreReferencia,
    String? direccion,
    String? sector,
    String? fotoPath,
    String? referencia1Nombre,
    String? referencia1Tel,
    String? referencia2Nombre,
    String? referencia2Tel,
    String? observaciones,
    DateTime? fechaCreacion,
    int? cobradorId,
    bool? activo,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      telefono: telefono ?? this.telefono,
      telReferencia: telReferencia ?? this.telReferencia,
      nombreReferencia: nombreReferencia ?? this.nombreReferencia,
      direccion: direccion ?? this.direccion,
      sector: sector ?? this.sector,
      fotoPath: fotoPath ?? this.fotoPath,
      referencia1Nombre: referencia1Nombre ?? this.referencia1Nombre,
      referencia1Tel: referencia1Tel ?? this.referencia1Tel,
      referencia2Nombre: referencia2Nombre ?? this.referencia2Nombre,
      referencia2Tel: referencia2Tel ?? this.referencia2Tel,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      cobradorId: cobradorId ?? this.cobradorId,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'ClienteModel(id: $id, codigo: $codigo, nombre: $nombre, cedula: $cedula)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClienteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
