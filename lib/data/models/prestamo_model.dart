class PrestamoModel {
  final int? id;
  final int clienteId;
  final String codigo;
  final double capital;
  final String tipoPrestamo;
  final double tasaInteres;
  final double cuotaDiaria;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final int diasPlazo;
  final double saldoPendiente;
  final String estado;
  final int? prestamoPadreId;
  final int cobradorId;
  final DateTime fechaCreacion;

  PrestamoModel({
    this.id,
    required this.clienteId,
    required this.codigo,
    required this.capital,
    required this.tipoPrestamo,
    required this.tasaInteres,
    required this.cuotaDiaria,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.diasPlazo,
    required this.saldoPendiente,
    required this.estado,
    this.prestamoPadreId,
    required this.cobradorId,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory PrestamoModel.fromMap(Map<String, dynamic> map) {
    return PrestamoModel(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int,
      codigo: map['codigo'] as String,
      capital: (map['capital'] as num).toDouble(),
      tipoPrestamo: map['tipo_prestamo'] as String,
      tasaInteres: (map['tasa_interes'] as num).toDouble(),
      cuotaDiaria: (map['cuota_diaria'] as num).toDouble(),
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      fechaVencimiento: DateTime.parse(map['fecha_vencimiento'] as String),
      diasPlazo: map['dias_plazo'] as int,
      saldoPendiente: (map['saldo_pendiente'] as num).toDouble(),
      estado: map['estado'] as String,
      prestamoPadreId: map['prestamo_padre_id'] as int?,
      cobradorId: map['cobrador_id'] as int,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'codigo': codigo,
      'capital': capital,
      'tipo_prestamo': tipoPrestamo,
      'tasa_interes': tasaInteres,
      'cuota_diaria': cuotaDiaria,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'dias_plazo': diasPlazo,
      'saldo_pendiente': saldoPendiente,
      'estado': estado,
      'prestamo_padre_id': prestamoPadreId,
      'cobrador_id': cobradorId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'codigo': codigo,
      'capital': capital,
      'tipoPrestamo': tipoPrestamo,
      'tasaInteres': tasaInteres,
      'cuotaDiaria': cuotaDiaria,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'diasPlazo': diasPlazo,
      'saldoPendiente': saldoPendiente,
      'estado': estado,
      'prestamoPadreId': prestamoPadreId,
      'cobradorId': cobradorId,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    return PrestamoModel(
      id: json['id'] as int?,
      clienteId: json['clienteId'] as int,
      codigo: json['codigo'] as String,
      capital: (json['capital'] as num).toDouble(),
      tipoPrestamo: json['tipoPrestamo'] as String,
      tasaInteres: (json['tasaInteres'] as num).toDouble(),
      cuotaDiaria: (json['cuotaDiaria'] as num).toDouble(),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento'] as String),
      diasPlazo: json['diasPlazo'] as int,
      saldoPendiente: (json['saldoPendiente'] as num).toDouble(),
      estado: json['estado'] as String,
      prestamoPadreId: json['prestamoPadreId'] as int?,
      cobradorId: json['cobradorId'] as int,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  PrestamoModel copyWith({
    int? id,
    int? clienteId,
    String? codigo,
    double? capital,
    String? tipoPrestamo,
    double? tasaInteres,
    double? cuotaDiaria,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    int? diasPlazo,
    double? saldoPendiente,
    String? estado,
    int? prestamoPadreId,
    int? cobradorId,
    DateTime? fechaCreacion,
  }) {
    return PrestamoModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      codigo: codigo ?? this.codigo,
      capital: capital ?? this.capital,
      tipoPrestamo: tipoPrestamo ?? this.tipoPrestamo,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      cuotaDiaria: cuotaDiaria ?? this.cuotaDiaria,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      diasPlazo: diasPlazo ?? this.diasPlazo,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      estado: estado ?? this.estado,
      prestamoPadreId: prestamoPadreId ?? this.prestamoPadreId,
      cobradorId: cobradorId ?? this.cobradorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'PrestamoModel(id: $id, codigo: $codigo, capital: $capital, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrestamoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
