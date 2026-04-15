import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TermsBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsContent(),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const Divider(height: 24),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _SectionTitle('1. Account Responsibility'),
                    _SectionBody(
                      'You are responsible for maintaining the confidentiality of your account credentials. '
                          'Please provide accurate and truthful information during registration. '
                          'Do not share your account with others.',
                    ),

                    _SectionTitle('2. Acceptable Use'),
                    _SectionBody(
                      'Smart Stitched AI is intended solely for managing tailoring orders and inventory. '
                          'Any misuse, unauthorized access, or harmful activity is strictly prohibited.',
                    ),

                    _SectionTitle('3. Privacy & Data'),
                    _SectionBody(
                      'Your personal data is stored securely and will never be shared with third parties '
                          'without your consent. We collect only the information necessary to provide our services.',
                    ),

                    _SectionTitle('4. Order Management'),
                    _SectionBody(
                      'This app is a management tool only. Smart Stitched AI does not guarantee the quality '
                          'or delivery of any stitching services. All business commitments are solely between '
                          'you and your customers.',
                    ),

                    _SectionTitle('5. Account Suspension'),
                    _SectionBody(
                      'We reserve the right to suspend or terminate any account found violating these terms, '
                          'engaging in fraudulent activity, or misusing the platform.',
                    ),

                    _SectionTitle('6. Changes to Terms'),
                    _SectionBody(
                      'We may update these Terms & Conditions from time to time. '
                          'Continued use of the app after changes means you accept the updated terms.',
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'I Understand',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;
  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}