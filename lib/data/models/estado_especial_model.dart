class EstadoEspecialModel {
  final int? id;
  final int clienteId;
  final DateTime fecha;
  final String tipoEstado;
  final String? notas;
  final DateTime fechaCreacion;

  EstadoEspecialModel({
    this.id,
    required this.clienteId,
    required this.fecha,
    required this.tipoEstado,
    this.notas,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory EstadoEspecialModel.fromMap(Map<String, dynamic> map) {
    return EstadoEspecialModel(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      tipoEstado: map['tipo_estado'] as String,
      notas: map['notas'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'fecha': fecha.toIso8601String(),
      'tipo_estado': tipoEstado,
      'notas': notas,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'fecha': fecha.toIso8601String(),
      'tipoEstado': tipoEstado,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory EstadoEspecialModel.fromJson(Map<String, dynamic> json) {
    return EstadoEspecialModel(
      id: json['id'] as int?,
      clienteId: json['clienteId'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      tipoEstado: json['tipoEstado'] as String,
      notas: json['notas'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  EstadoEspecialModel copyWith({
    int? id,
    int? clienteId,
    DateTime? fecha,
    String? tipoEstado,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return EstadoEspecialModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      tipoEstado: tipoEstado ?? this.tipoEstado,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'EstadoEspecialModel(id: $id, clienteId: $clienteId, tipoEstado: $tipoEstado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EstadoEspecialModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
