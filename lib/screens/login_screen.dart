import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/auth_provider.dart';
import 'package:smart_stitched_ai1/providers/bottom_nav_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import '../utils/app_colors.dart';
import '../utils/color_pallete.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearErrors();
    });
  }
  Widget build(BuildContext context) {
    final authAction = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [

                // Logo and Title Section
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.cut, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  onChanged: authAction.setEmail,
                ),
                Selector<AuthProvider, String?>(
                  selector: (_, prov) => prov.getFieldError('email'),
                  builder: (context, fieldError, child) {
                    if (fieldError == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(fieldError, style: const TextStyle(color: ColorPalette.error, fontSize: 12)),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                  onChanged: authAction.setPassword,
                ),
                Selector<AuthProvider, String?>(
                  selector: (_, prov) => prov.getFieldError('password'),
                  builder: (context, fieldError, child) {
                    if (fieldError == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(fieldError, style: const TextStyle(color: ColorPalette.error, fontSize: 12)),
                      ),
                    );
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog(context);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ),

                Selector<AuthProvider, String?>(
                  selector: (_, prov) => prov.error,
                  builder: (context, errorMsg, child) {
                    if (errorMsg == null) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color:ColorPalette.secondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMsg,
                              style: const TextStyle(color: ColorPalette.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),


                Selector<AuthProvider, bool>(
                  selector: (_, prov) => prov.isLoading,
                  builder: (context, loading, child) {

                    return CustomButton(
                      text: 'Login',
                      isLoading: loading,

                      onPressed: () async {
                        if (!mounted) return;

                        authAction.clearErrors();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        authAction.setEmail(email);
                        authAction.setPassword(password);

                        bool success = await authAction.login();

                        if (success && mounted) {
                          Provider.of<OrderProvider>(context, listen: false).initOrdersListener();

                          await Provider.of<InventoryProvider>(context, listen: false).fetchInventory();
                          Provider.of<BottomNavProvider>(context, listen: false).changeTab(0);

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/dashboard',
                                (route) => false,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),

                  ],
                ),
                SizedBox(height: 5,),
                Selector<AuthProvider, bool>(
                  selector: (_, prov) => prov.loading,
                  builder: (context, loading, child) {
                    final authAction = context.read<AuthProvider>();
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: loading ? null : () async {
                          if (!mounted) return;

                          bool success = await authAction.signInWithGoogle();
                          if (success && context.mounted) {
                            Provider.of<OrderProvider>(context, listen: false).initOrdersListener();
                            await Provider.of<InventoryProvider>(context, listen: false).fetchInventory();
                            Provider.of<BottomNavProvider>(context, listen: false).changeTab(0);
                            Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                          }
                        },
                        child: loading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                        )
                            : Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                height: 24,
                                'lib/assets/images/google_logo.png',
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false).clearErrors();
                        Navigator.pushNamed(context, '/signup');
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final authAction = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email, we will send you a password reset link.'),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: 'Email address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (!mounted) return;

              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                bool sent = await authAction.resetPassword(email);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sent
                          ? 'A reset link has been sent to your email.'
                          : 'Failed to send email. Please try again.'),
                      backgroundColor: sent ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),

        ],
      )
    ).whenComplete(() => resetEmailController.dispose());
  }
}