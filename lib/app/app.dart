import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import 'theme.dart';
import 'demo_session.dart';
import '../features/owner/owner_demo.dart';
import '../features/owner/presentation/owner_screens.dart';
import '../features/room/presentation/room_screens.dart';
import '../features/billing/presentation/billing_screens.dart';

class RentMateApp extends StatefulWidget {
  const RentMateApp({super.key});

  @override
  State<RentMateApp> createState() => _RentMateAppState();
}

class _RentMateAppState extends State<RentMateApp> {
  final _session = DemoSession();
  final _owner = OwnerDemo();

  @override
  void dispose() {
    _session.dispose();
    _owner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RentMate',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    initialRoute: '/login',
    routes: {
      '/login': (_) => const LoginScreen(),
      '/register': (_) => const RegisterScreen(),
      '/start': (_) => StartScreen(owner: _owner),
      '/create-property': (_) => CreatePropertyScreen(owner: _owner),
      '/owner': (_) => OwnerHomeScreen(owner: _owner),
      '/join': (_) => const JoinRoomScreen(),
      '/occupant': (_) => OccupantScreen(session: _session),
      '/pending-room': (_) => PendingRoomScreen(session: _session),
      '/home': (_) => HomeScreen(session: _session),
      '/bill': (_) => const BillScreen(),
      '/payment': (_) => const PaymentScreen(),
      '/receipt': (_) => ReceiptScreen(session: _session),
      '/payment-status': (_) => PaymentStatusScreen(session: _session),
    },
  );
}
