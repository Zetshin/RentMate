import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import 'theme.dart';

class RentMateApp extends StatelessWidget {
  const RentMateApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RentMate',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    initialRoute: '/login',
    routes: {
      '/login': (_) => const LoginScreen(),
      '/register': (_) => const RegisterScreen(),
    },
  );
}
