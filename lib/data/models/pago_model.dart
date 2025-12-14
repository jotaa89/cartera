class PagoModel {
  final int? id;
  final int prestamoId;
  final DateTime fecha;
  final double monto;
  final double moraExtra;
  final String metodoPago;
  final String? notas;
  final bool sincronizado;
  final DateTime fechaCreacion;

  PagoModel({
    this.id,
    required this.prestamoId,
    required this.fecha,
    required this.monto,
    this.moraExtra = 0.0,
    required this.metodoPago,
    this.notas,
    this.sincronizado = false,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory PagoModel.fromMap(Map<String, dynamic> map) {
    return PagoModel(
      id: map['id'] as int?,
      prestamoId: map['prestamo_id'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      monto: (map['monto'] as num).toDouble(),
      moraExtra: (map['mora_extra'] as num?)?.toDouble() ?? 0.0,
      metodoPago: map['metodo_pago'] as String,
      notas: map['notas'] as String?,
      sincronizado: (map['sincronizado'] as int) == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'prestamo_id': prestamoId,
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'mora_extra': moraExtra,
      'metodo_pago': metodoPago,
      'notas': notas,
      'sincronizado': sincronizado ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prestamoId': prestamoId,
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'moraExtra': moraExtra,
      'metodoPago': metodoPago,
      'notas': notas,
      'sincronizado': sincronizado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] as int?,
      prestamoId: json['prestamoId'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      monto: (json['monto'] as num).toDouble(),
      moraExtra: (json['moraExtra'] as num?)?.toDouble() ?? 0.0,
      metodoPago: json['metodoPago'] as String,
      notas: json['notas'] as String?,
      sincronizado: json['sincronizado'] as bool? ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  PagoModel copyWith({
    int? id,
    int? prestamoId,
    DateTime? fecha,
    double? monto,
    double? moraExtra,
    String? metodoPago,
    String? notas,
    bool? sincronizado,
    DateTime? fechaCreacion,
  }) {
    return PagoModel(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      fecha: fecha ?? this.fecha,
      monto: monto ?? this.monto,
      moraExtra: moraExtra ?? this.moraExtra,
      metodoPago: metodoPago ?? this.metodoPago,
      notas: notas ?? this.notas,
      sincronizado: sincronizado ?? this.sincronizado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'PagoModel(id: $id, prestamoId: $prestamoId, monto: $monto, fecha: $fecha)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PagoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
