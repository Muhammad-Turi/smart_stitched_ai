import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/auth_provider.dart';
import '../services/firebase/database_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_elevated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final dbService = DatabaseService();

  late Stream<DocumentSnapshot> _profileStream;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _profileStream = dbService.getUserProfile(auth.user?.uid ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _profileStream,
              builder: (context, snapshot) {
                String name = auth.user?.displayName ?? "User";
                String email = auth.user?.email ?? "No Email";

                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    name = data['name'] ?? name;
                    email = data['email'] ?? email;
                  }
                }
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Settings'),
            _buildListTile(Icons.info_outline, 'App Info', 'Version 1.0.0', () => _showAppInfo(context)),
            _buildListTile(Icons.language, 'Language', 'English', () {}),
            const Divider(height: 40),
            _buildListTile(Icons.logout, 'Sign Out', 'Exit from app', () => _confirmSignOut(context, auth), isError: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isError = false}) {
    return ListTile(
      leading: Icon(icon, color: isError ? Colors.red : AppColors.primary),
      title: Text(title, style: TextStyle(color: isError ? Colors.red : Colors.black, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CustomElevatedButton(
            width: 65,
            height: 50,
            text: 'Logout',
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Stitched AI',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.cut, color: AppColors.primary),
      children: [const Text("Optimizing your tailoring business with AI.")],
    );
  }
}