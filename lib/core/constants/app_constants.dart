class AppConstants {
  // Información de la App
  static const String appName = 'PrestaApp';
  static const String appVersion = '1.0.0';

  // Base de Datos
  static const String databaseName = 'prestamos.db';
  static const int databaseVersion = 1;

  // Roles de Usuario
  static const String rolAdmin = 'admin';
  static const String rolCobrador = 'cobrador';

  // Tasas de Interés
  static const double tasaInteres = 0.25; // 25%

  // Comisiones (por defecto)
  static const double comisionMinima = 0.08; // 8%
  static const double comisionMaxima = 0.10; // 10%

  // Configuración de Préstamos
  static const int diasMoraMaximaParaRenovacion = 5;

  // Tipos de Préstamo
  static const String prestamoDiario = 'DIARIO';
  static const String prestamoSemanal = 'SEMANAL';
  static const String prestamoQuincenal = 'QUINCENAL';

  // Estados de Préstamo
  static const String prestamoActivo = 'ACTIVO';
  static const String prestamoCompletado = 'COMPLETADO';
  static const String prestamoRenovado = 'RENOVADO';
  static const String prestamoCancelado = 'CANCELADO';

  // Estados Especiales de Cliente
  static const String estadoNoEncontrado = 'NO_ENCONTRADO';
  static const String estadoSeMudo = 'SE_MUDO';
  static const String estadoPromesa = 'PROMESA';
  static const String estadoTelefonoApagado = 'TELEFONO_APAGADO';
  static const String estadoEnfermo = 'ENFERMO';

  // Métodos de Pago
  static const String pagoEfectivo = 'EFECTIVO';
  static const String pagoTransferencia = 'TRANSFERENCIA';

  // Festivos Dominicanos 2024-2025 (día/mes)
  static const List<Map<String, int>> festivosDominicanos = [
    {'dia': 1, 'mes': 1}, // Año Nuevo
    {'dia': 6, 'mes': 1}, // Día de Reyes
    {'dia': 21, 'mes': 1}, // Día de la Altagracia
    {'dia': 27, 'mes': 2}, // Día de la Independencia
    {'dia': 1, 'mes': 5}, // Día del Trabajo
    {'dia': 16, 'mes': 8}, // Día de la Restauración
    {'dia': 24, 'mes': 9}, // Día de las Mercedes
    {'dia': 6, 'mes': 11}, // Día de la Constitución
    {'dia': 25, 'mes': 12}, // Navidad
  ];

  // Configuración de Imágenes
  static const int maxImageSize = 1024; // KB
  static const int imageQuality = 85; // Calidad de compresión

  // Formato de Moneda
  static const String moneda = 'RD\$';
  static const String formatoMoneda = '#,##0.00';

  // Formato de Fecha
  static const String formatoFecha = 'dd/MM/yyyy';
  static const String formatoFechaHora = 'dd/MM/yyyy hh:mm a';
}
