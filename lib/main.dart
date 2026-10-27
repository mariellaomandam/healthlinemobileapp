import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/appointments.dart';
import 'screens/messages.dart';
import 'screens/profileandsettings.dart';
import 'screens/organization_login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: HealthLineApp(),
    ),
  );
}

class HealthLineApp extends StatelessWidget {
  const HealthLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthLine PH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF101010),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        late final Widget page;

        switch (settings.name) {
          case '/':
            page = const LoginScreen();
            break;
          case '/dashboard':
            page = const DashboardScreen();
            break;
          case '/appointments':
            page = const AppointmentsScreen();
            break;
          case '/messages':
            page = const MessagesScreen();
            break;
          case '/profile-settings':
            page = const ProfileSettingsScreen();
            break;
          case '/organization-login':
            page = const OrganizationLoginScreen();
            break;
          default:
            page = const LoginScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
