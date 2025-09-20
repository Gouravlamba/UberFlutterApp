import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/dashboard_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';
import 'package:uber_drivers_app/providers/trips_provider.dart';
import 'package:uber_drivers_app/widgets/blocked_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Uber Drivers App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const RegisterScreen();
        }

        // User is logged in
        return FutureBuilder<bool>(
          future: authProvider.checkIfDriverIsBlocked(),
          builder: (context, blockedSnapshot) {
            if (blockedSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: Colors.black)),
              );
            }

            if (blockedSnapshot.hasData && blockedSnapshot.data == true) {
              return const BlockedScreen();
            }

            // Check profile completeness
            return FutureBuilder<bool>(
              future: authProvider.checkDriverFieldsFilled(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                        child: CircularProgressIndicator(color: Colors.black)),
                  );
                }

                if (profileSnapshot.hasData && profileSnapshot.data == true) {
                  return const Dashboard();
                } else {
                  return const RegisterScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
