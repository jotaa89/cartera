import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cliente_provider.dart';
import 'presentation/providers/prestamo_provider.dart';
import 'presentation/providers/pago_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAR BASE DE DATOS ANTES DE ARRANCAR LA APP
  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database; // Fuerza la inicialización
    print('✅ Base de datos inicializada correctamente');
  } catch (e) {
    print('❌ Error al inicializar base de datos: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => PrestamoProvider()),
        ChangeNotifierProvider(create: (_) => PagoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
