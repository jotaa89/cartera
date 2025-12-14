import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class FormatoUtils {
  /// Formatea un monto de dinero con el símbolo de moneda
  static String formatearMoneda(double monto) {
    final formatter = NumberFormat(AppConstants.formatoMoneda, 'es_DO');
    return '${AppConstants.moneda} ${formatter.format(monto)}';
  }

  /// Parsea un string de moneda a double
  static double? parsearMoneda(String montoStr) {
    try {
      // Remover símbolo de moneda, comas y espacios
      String limpio = montoStr
          .replaceAll(AppConstants.moneda, '')
          .replaceAll(',', '')
          .trim();
      return double.parse(limpio);
    } catch (e) {
      return null;
    }
  }

  /// Formatea un número de teléfono dominicano
  /// Ejemplo: 8091234567 -> (809) 123-4567
  static String formatearTelefono(String telefono) {
    // Remover caracteres no numéricos
    String limpio = telefono.replaceAll(RegExp(r'\D'), '');

    if (limpio.length == 10) {
      return '(${limpio.substring(0, 3)}) ${limpio.substring(3, 6)}-${limpio.substring(6)}';
    }

    return telefono; // Retornar original si no tiene formato válido
  }

  /// Valida formato de cédula dominicana (XXX-XXXXXXX-X)
  static bool validarCedula(String cedula) {
    // Remover guiones
    String limpia = cedula.replaceAll('-', '');

    // Debe tener 11 dígitos
    if (limpia.length != 11) return false;

    // Debe ser solo números
    return RegExp(r'^\d{11}$').hasMatch(limpia);
  }

  /// Formatea una cédula dominicana
  /// Ejemplo: 00112345678 -> 001-1234567-8
  static String formatearCedula(String cedula) {
    String limpia = cedula.replaceAll('-', '');

    if (limpia.length == 11) {
      return '${limpia.substring(0, 3)}-${limpia.substring(3, 10)}-${limpia.substring(10)}';
    }

    return cedula;
  }

  /// Genera un código único para cliente
  /// Formato: C-XXXX (donde XXXX es un número incremental)
  static String generarCodigoCliente(int numero) {
    return 'C-${numero.toString().padLeft(4, '0')}';
  }

  /// Genera un código único para préstamo
  /// Formato: P-XXXX-YYYY (donde XXXX es el cliente y YYYY es el préstamo)
  static String generarCodigoPrestamo(int numeroCliente, int numeroPrestamo) {
    String codCliente = numeroCliente.toString().padLeft(4, '0');
    String codPrestamo = numeroPrestamo.toString().padLeft(4, '0');
    return 'P-$codCliente-$codPrestamo';
  }

  /// Capitaliza la primera letra de cada palabra
  static String capitalizarPalabras(String texto) {
    if (texto.isEmpty) return texto;

    return texto.split(' ').map((palabra) {
      if (palabra.isEmpty) return palabra;
      return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formatea un porcentaje
  static String formatearPorcentaje(double valor) {
    return '${(valor * 100).toStringAsFixed(0)}%';
  }

  /// Limpia un string removiendo espacios extras y convirtiéndolo a mayúsculas
  static String limpiarTexto(String texto) {
    return texto.trim().toUpperCase();
  }

  /// Valida un número de teléfono dominicano
  static bool validarTelefono(String telefono) {
    String limpio = telefono.replaceAll(RegExp(r'\D'), '');

    // Debe tener 10 dígitos y empezar con 809, 829, 849
    if (limpio.length != 10) return false;

    return limpio.startsWith('809') ||
        limpio.startsWith('829') ||
        limpio.startsWith('849');
  }

  /// Trunca un texto a una longitud específica y agrega "..."
  static String truncarTexto(String texto, int longitudMaxima) {
    if (texto.length <= longitudMaxima) return texto;
    return '${texto.substring(0, longitudMaxima)}...';
  }

  /// Formatea días de mora con color semántico
  static String formatearDiasMora(int dias) {
    if (dias == 0) return 'Al día';
    if (dias == 1) return '1 día de mora';
    return '$dias días de mora';
  }

  /// Obtiene iniciales de un nombre
  static String obtenerIniciales(String nombreCompleto) {
    List<String> palabras = nombreCompleto.trim().split(' ');

    if (palabras.isEmpty) return '';
    if (palabras.length == 1) return palabras[0][0].toUpperCase();

    return '${palabras[0][0]}${palabras[palabras.length - 1][0]}'.toUpperCase();
  }

  /// Formatea el estado de un préstamo de forma legible
  static String formatearEstadoPrestamo(String estado) {
    switch (estado) {
      case AppConstants.prestamoActivo:
        return 'Activo';
      case AppConstants.prestamoCompletado:
        return 'Completado';
      case AppConstants.prestamoRenovado:
        return 'Renovado';
      case AppConstants.prestamoCancelado:
        return 'Cancelado';
      default:
        return estado;
    }
  }

  /// Formatea el tipo de préstamo de forma legible
  static String formatearTipoPrestamo(String tipo) {
    switch (tipo) {
      case AppConstants.prestamoDiario:
        return 'Diario';
      case AppConstants.prestamoSemanal:
        return 'Semanal';
      case AppConstants.prestamoQuincenal:
        return 'Quincenal';
      default:
        return tipo;
    }
  }
}
