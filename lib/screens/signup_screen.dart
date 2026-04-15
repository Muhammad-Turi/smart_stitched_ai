import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/auth_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import 'package:smart_stitched_ai1/widgets/terms_bottom_sheet.dart';
import '../utils/app_colors.dart';
import '../utils/color_pallete.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _termsAccepted = false;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAction = context.read<AuthProvider>();
    return PopScope(
      canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            authAction.clearErrors();
          }
        },

    child:  Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                  ),
                ),

                const SizedBox(height: 20),
                _buildHeader(),

                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  onChanged: (value) {
                    authAction.setName(value);
                    if (authAction.getFieldError('name') != null) {
                      authAction.clearErrors();
                    }
                  },
                ),
                Selector<AuthProvider, String?>(
                  selector: (_, prov) => prov.getFieldError('name'),
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
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  onChanged: (value) {
                    authAction.setEmail(value);
                    if (authAction.getFieldError('email') != null) {
                      authAction.clearErrors();
                    }
                  },
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
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                  onChanged: (value) {
                    authAction.setPassword(value);
                    if (authAction.getFieldError('password') != null) {
                      authAction.clearErrors();
                    }
                  },
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

                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => TermsBottomSheet.show(context),
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to ',
                            style: TextStyle(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Selector<AuthProvider, String?>(
                  selector: (_, prov) => prov.error,
                  builder: (context, errorMsg, child) {
                    if (errorMsg == null) return const SizedBox.shrink();
                    return _buildErrorWidget(errorMsg);
                  },
                ),

                Selector<AuthProvider, bool>(
                  selector: (_, prov) => prov.isLoading,
                  builder: (context, loading, child) {
                    return CustomButton(
                      text: 'Create Account',
                      isLoading: loading,
                      onPressed: () async {
                        if (!mounted) return;

                        String name = _nameController.text.trim();
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();

                        authAction.setName(name);
                        authAction.setEmail(email);
                        authAction.setPassword(password);

                        if (name.isEmpty || email.isEmpty || !email.contains('@') || password.length < 8) {
                          authAction.signup();
                          return;
                        }

                        if (!_termsAccepted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please accept Terms & Conditions'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        bool success = await authAction.signup();
                        if (success && mounted) {
                          Provider.of<OrderProvider>(context, listen: false).initOrdersListener();
                          await Provider.of<InventoryProvider>(context, listen: false).fetchInventory();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          }
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 40),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    )
    );

  }


  Widget _buildHeader() {
    return Column(
      children: [
        Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 10),
        Text('Fill your details to get started', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
      ],
    );
  }


  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.error, color: ColorPalette.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(error, style: const TextStyle(color: ColorPalette.error))),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () {
            Provider.of<AuthProvider>(context, listen: false).clearErrors();
            Navigator.pop(context);
          },
          child: Text('Login', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}