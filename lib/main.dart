import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/auth_provider.dart';
import 'package:smart_stitched_ai1/providers/bottom_nav_provider.dart';
import 'package:smart_stitched_ai1/providers/dashboard_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import 'package:smart_stitched_ai1/screens/signup_screen.dart';
import 'package:smart_stitched_ai1/screens/splash_screen.dart';
import 'package:smart_stitched_ai1/screens/login_screen.dart';
import 'package:smart_stitched_ai1/screens/dashboard_screen.dart';
import 'package:smart_stitched_ai1/screens/new_order_screen.dart';
import 'package:smart_stitched_ai1/screens/profile_screen.dart';
import 'package:smart_stitched_ai1/screens/splash_screen_one.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'utils/overlay_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase Initialized Freshly");
    } else {
      Firebase.app();
      debugPrint("Firebase already exists, using existing instance");
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

  } catch (e) {
    debugPrint("Firebase Init Note: $e");
  }


  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (context, auth, orders) {
            return orders!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, InventoryProvider>(
          create: (_) => InventoryProvider(),
          update: (context, auth, inventory) {
            return inventory!;
          },
        ),
        ChangeNotifierProxyProvider2<InventoryProvider, OrderProvider, DashboardProvider>(
          create: (context) => DashboardProvider(),
          update: (context, invProv, orderProv, dashboard) {
            return dashboard!..updateRefs(invProv, orderProv);
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Smart Stitched AI',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreenOne(),
          '/landed': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/new-order': (context) => const NewOrderScreen(),
        },
      ),
    );
  }
}