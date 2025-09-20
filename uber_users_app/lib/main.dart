import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/register_screen.dart';
import 'package:uber_users_app/authentication/user_information_screen.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/pages/blocked_screen.dart';
import 'package:uber_users_app/pages/home_page.dart';

// ✅ Use generated Firebase config
import 'firebase_options.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.io) 'dart:io';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Stripe init
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      Stripe.publishableKey = stripePublishedKey;
    }
  }

  // ✅ Firebase init (use FlutterFire CLI config)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Permissions (only Android/iOS)
  if (!kIsWeb) {
    await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
      if (valueOfPermission) {
        Permission.locationWhenInUse.request();
      }
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInfoClass()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MaterialApp(
        title: 'Uber User App',
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
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ✅ realtime updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const RegisterScreen();
        }

        return FutureBuilder<bool>(
          future: authProvider.checkIfUserIsBlocked(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const BlockedScreen();
            }

            return FutureBuilder<bool>(
              future: authProvider.checkUserFieldsFilled(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return const HomePage();
                } else {
                  return const UserInformationScreen(); // ✅ profile setup
                }
              },
            );
          },
        );
      },
    );
  }
}
