import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/cobranza/lista_dia_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrestaApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }

          // Si es cobrador, ir directo a lista del día
          return const ListaDiaScreen();
        },
      ),
    );
  }
}
