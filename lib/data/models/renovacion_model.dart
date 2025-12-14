class RenovacionModel {
  final int? id;
  final int prestamoOriginalId;
  final int prestamoNuevoId;
  final double abonoRealizado;
  final DateTime fechaRenovacion;
  final DateTime fechaCreacion;

  RenovacionModel({
    this.id,
    required this.prestamoOriginalId,
    required this.prestamoNuevoId,
    required this.abonoRealizado,
    required this.fechaRenovacion,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory RenovacionModel.fromMap(Map<String, dynamic> map) {
    return RenovacionModel(
      id: map['id'] as int?,
      prestamoOriginalId: map['prestamo_original_id'] as int,
      prestamoNuevoId: map['prestamo_nuevo_id'] as int,
      abonoRealizado: (map['abono_realizado'] as num).toDouble(),
      fechaRenovacion: DateTime.parse(map['fecha_renovacion'] as String),
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'prestamo_original_id': prestamoOriginalId,
      'prestamo_nuevo_id': prestamoNuevoId,
      'abono_realizado': abonoRealizado,
      'fecha_renovacion': fechaRenovacion.toIso8601String(),
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prestamoOriginalId': prestamoOriginalId,
      'prestamoNuevoId': prestamoNuevoId,
      'abonoRealizado': abonoRealizado,
      'fechaRenovacion': fechaRenovacion.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory RenovacionModel.fromJson(Map<String, dynamic> json) {
    return RenovacionModel(
      id: json['id'] as int?,
      prestamoOriginalId: json['prestamoOriginalId'] as int,
      prestamoNuevoId: json['prestamoNuevoId'] as int,
      abonoRealizado: (json['abonoRealizado'] as num).toDouble(),
      fechaRenovacion: DateTime.parse(json['fechaRenovacion'] as String),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }

  RenovacionModel copyWith({
    int? id,
    int? prestamoOriginalId,
    int? prestamoNuevoId,
    double? abonoRealizado,
    DateTime? fechaRenovacion,
    DateTime? fechaCreacion,
  }) {
    return RenovacionModel(
      id: id ?? this.id,
      prestamoOriginalId: prestamoOriginalId ?? this.prestamoOriginalId,
      prestamoNuevoId: prestamoNuevoId ?? this.prestamoNuevoId,
      abonoRealizado: abonoRealizado ?? this.abonoRealizado,
      fechaRenovacion: fechaRenovacion ?? this.fechaRenovacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'RenovacionModel(id: $id, prestamoOriginalId: $prestamoOriginalId, abonoRealizado: $abonoRealizado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RenovacionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
