import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_button.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeTerms = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 8 characters long')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signup(
            name: name,
            email: email,
            password: password,
          );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 840;
    final double formPadding = isWide ? 60 : 24;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  SizedBox(
                    width: size.width * 0.35,
                    height: size.height,
                    child: _headerSection(isWide, size),
                  ),
                  Expanded(
                    child: Center(child: _formSection(isWide, formPadding)),
                  ),
                ],
              )
            : Column(
                children: [
                  _headerSection(isWide, size),
                  Expanded(
                    child: Center(child: _formSection(isWide, formPadding)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _headerSection(bool isWide, Size size) {
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
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _socialButtons(bool isWide) {
    Widget googleButton = SocialButton(
      label: 'Google',
      iconWidget: SvgPicture.asset(
        'assets/images/google-icon-logo-svgrepo-com.svg',
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 20),
      ),
      onPressed: () {},
    );

    Widget githubButton = SocialButton(
      label: 'GitHub',
      iconWidget: SvgPicture.asset(
        'assets/images/github-svgrepo-com.svg',
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.code, size: 20),
      ),
      onPressed: () {},
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: googleButton),
          const SizedBox(width: 12),
          Expanded(child: githubButton),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(width: double.infinity, child: googleButton),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: githubButton),
      ],
    );
  }

  Widget _formSection(bool isWide, double formPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: formPadding, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textDark),
              ),
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
            CustomTextField(
                hint: 'Enter your full name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            Text('Email Address',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
                hint: 'Enter your email',
                controller: _emailController,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            Text('Password',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
                hint: 'Create a password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true),
            const SizedBox(height: 16),
            Text('Confirm Password',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true),
            const SizedBox(height: 20),
            _checkbox('I agree to the Terms of Service and Privacy Policy',
                _agreeTerms, (v) => setState(() => _agreeTerms = v!)),
            const SizedBox(height: 16),
            PrimaryButton(
                label: _isLoading ? 'Creating Account...' : 'Sign Up',
                onPressed: _isLoading ? null : _handleSignup),
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
            _socialButtons(isWide),
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/');
                      }
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
                ),
              ],
            )),
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
