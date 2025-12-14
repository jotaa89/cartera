import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class FechaUtils {
  /// Verifica si una fecha es domingo
  static bool esDomingo(DateTime fecha) {
    return fecha.weekday == DateTime.sunday;
  }

  /// Verifica si una fecha es festivo dominicano
  static bool esFestivo(DateTime fecha) {
    for (var festivo in AppConstants.festivosDominicanos) {
      if (fecha.day == festivo['dia'] && fecha.month == festivo['mes']) {
        return true;
      }
    }
    return false;
  }

  /// Verifica si una fecha es día hábil (no domingo ni festivo)
  static bool esDiaHabil(DateTime fecha) {
    return !esDomingo(fecha) && !esFestivo(fecha);
  }

  /// Calcula la fecha de vencimiento excluyendo domingos y festivos
  /// [fechaInicio] fecha desde la que se empieza a contar
  /// [diasHabiles] cantidad de días hábiles que dura el préstamo
  static DateTime calcularFechaVencimiento(
      DateTime fechaInicio, int diasHabiles) {
    DateTime fechaActual = fechaInicio;
    int diasContados = 0;

    while (diasContados < diasHabiles) {
      fechaActual = fechaActual.add(const Duration(days: 1));

      // Solo contar si es día hábil
      if (esDiaHabil(fechaActual)) {
        diasContados++;
      }
    }

    return fechaActual;
  }

  /// Calcula los días de mora desde la fecha de vencimiento
  /// [fechaVencimiento] fecha límite de pago
  /// Retorna 0 si no hay mora, o el número de días de mora
  static int calcularDiasMora(DateTime fechaVencimiento) {
    final hoy = DateTime.now();

    // Si aún no ha vencido, no hay mora
    if (hoy.isBefore(fechaVencimiento) || _esMismoDia(hoy, fechaVencimiento)) {
      return 0;
    }

    // Contar solo días hábiles de mora
    int diasMora = 0;
    DateTime fechaActual = fechaVencimiento.add(const Duration(days: 1));

    while (fechaActual.isBefore(hoy) || _esMismoDia(fechaActual, hoy)) {
      if (esDiaHabil(fechaActual)) {
        diasMora++;
      }
      fechaActual = fechaActual.add(const Duration(days: 1));
    }

    return diasMora;
  }

  /// Verifica si dos fechas son el mismo día
  static bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  /// Formatea una fecha a string según el formato de la app
  static String formatearFecha(DateTime fecha) {
    return DateFormat(AppConstants.formatoFecha).format(fecha);
  }

  /// Formatea una fecha con hora
  static String formatearFechaHora(DateTime fecha) {
    return DateFormat(AppConstants.formatoFechaHora).format(fecha);
  }

  /// Parsea un string a DateTime
  static DateTime? parsearFecha(String fechaStr) {
    try {
      return DateFormat(AppConstants.formatoFecha).parse(fechaStr);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el nombre del día de la semana en español
  static String obtenerNombreDia(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return dias[fecha.weekday - 1];
  }

  /// Obtiene el nombre del mes en español
  static String obtenerNombreMes(DateTime fecha) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[fecha.month - 1];
  }

  /// Formatea una fecha de forma legible: "Lunes, 15 de Enero de 2024"
  static String formatearFechaCompleta(DateTime fecha) {
    return '${obtenerNombreDia(fecha)}, ${fecha.day} de ${obtenerNombreMes(fecha)} de ${fecha.year}';
  }

  /// Obtiene el número de días entre dos fechas (solo días hábiles)
  static int diasHabilesEntre(DateTime fechaInicio, DateTime fechaFin) {
    int dias = 0;
    DateTime fechaActual = fechaInicio;

    while (
        fechaActual.isBefore(fechaFin) || _esMismoDia(fechaActual, fechaFin)) {
      if (esDiaHabil(fechaActual)) {
        dias++;
      }
      fechaActual = fechaActual.add(const Duration(days: 1));
    }

    return dias;
  }

  /// Verifica si una fecha es hoy
  static bool esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return _esMismoDia(fecha, hoy);
  }

  /// Verifica si una fecha fue ayer
  static bool esAyer(DateTime fecha) {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    return _esMismoDia(fecha, ayer);
  }

  /// Obtiene el inicio del día (00:00:00)
  static DateTime inicioDia(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  /// Obtiene el fin del día (23:59:59)
  static DateTime finDia(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);
  }
}
