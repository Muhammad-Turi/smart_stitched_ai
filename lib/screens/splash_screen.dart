import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/auth_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import '../utils/color_pallete.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProv = context.read<AuthProvider>();
    final orderProv = context.read<OrderProvider>();
    final invProv = context.read<InventoryProvider>();

    await Future.delayed(const Duration(seconds: 1));

    if (authProv.user != null) {
      debugPrint("Splash: User logged in, initializing data...");

      try {
        orderProv.initOrdersListener();

        await invProv.fetchInventory();

        debugPrint("Splash Data: Stream started and Inventory loaded.");
      } catch (e) {
        debugPrint("Data Fetch Error: $e");
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      debugPrint("User is not logged in, showing buttons.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F3A5F),
              Color(0xFF2C5364),
              Color(0xFF3FB7A5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 30),
                _buildAppTitle(),
                const SizedBox(height: 60),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'lib/assets/images/app_logo.jpeg',
        fit: BoxFit.cover
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: [
        const Text(
          'Smart Stitched AI',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Smart Digital Tailoring Management',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildButton(
          text: 'Login',
          color: ColorPalette.primary,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
        ),
        const SizedBox(height: 16),
        _buildButton(
          text: 'Sign Up',
          color: ColorPalette.warning,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
        ),
      ],
    );
  }

  Widget _buildButton({required String text, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}