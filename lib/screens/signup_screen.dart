import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeTerms = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 840;
    final double formPadding = isWide ? 60 : 24;

    Widget headerSection() {
      return Container(
        width: isWide ? size.width * 0.35 : double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1464), Color(0xFF3B2FD8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/icon-ai.png',
                width: 90,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/smartai.png',
                  width: 90,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.smart_toy_outlined,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('SmartAI',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('Join SmartAI',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text('Your AI journey starts here',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ],
        ),
      );
    }

    Widget formSection() {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: formPadding, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Center(
                  child: Text('Create Account',
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark))),
              const SizedBox(height: 6),
              Center(
                  child: Text('Join SmartAI and start your AI journey',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textGrey))),
              const SizedBox(height: 24),
              Text('Full Name',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              const CustomTextField(
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded),
              const SizedBox(height: 16),
              Text('Email Address',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              const CustomTextField(
                  hint: 'Enter your email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              Text('Password',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              const CustomTextField(
                  hint: 'Create a password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true),
              const SizedBox(height: 16),
              Text('Confirm Password',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              const CustomTextField(
                  hint: 'Confirm your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true),
              const SizedBox(height: 20),
              _checkbox('I agree to the Terms of Service and Privacy Policy',
                  _agreeTerms, (v) => setState(() => _agreeTerms = v!)),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Sign Up', onPressed: () {}),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or sign up with',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textGrey))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              isWide
                  ? Row(children: [
                      Expanded(
                        child: SocialButton(
                            label: 'Google',
                            iconWidget: SvgPicture.asset(
                              'assets/images/google-icon-logo-svgrepo-com.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, size: 20),
                            ),
                            onPressed: () {}),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SocialButton(
                            label: 'GitHub',
                            iconWidget: SvgPicture.asset(
                              'assets/images/github-svgrepo-com.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.code, size: 20),
                            ),
                            onPressed: () {}),
                      ),
                    ])
                  : Column(children: [
                      SizedBox(
                        width: double.infinity,
                        child: SocialButton(
                            label: 'Google',
                            iconWidget: SvgPicture.asset(
                              'assets/images/google-icon-logo-svgrepo-com.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, size: 20),
                            ),
                            onPressed: () {}),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SocialButton(
                            label: 'GitHub',
                            iconWidget: SvgPicture.asset(
                              'assets/images/github-svgrepo-com.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.code, size: 20),
                            ),
                            onPressed: () {}),
                      ),
                    ]),
              const SizedBox(height: 24),
              Center(
                  child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text('Already have an account? ',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textGrey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      );
    }

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: size.width * 0.35,
                height: size.height,
                child: headerSection(),
              ),
              Expanded(
                child: Container(
                  color: AppColors.backgroundLight,
                  child: Center(child: formSection()),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile layout (Android/iOS)
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            headerSection(),
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                width: double.infinity,
                child: Center(child: formSection()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(children: [
      Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      Expanded(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textGrey))),
    ]);
  }
}
