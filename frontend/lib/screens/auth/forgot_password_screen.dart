import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  // false → step 1 (ask for email); true → step 2 (enter code + new password).
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _snack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _snack('Please enter your email', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _snack('We sent a reset code to your email. Check your inbox.',
          Colors.green);
    } catch (e) {
      _snack('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (code.isEmpty) {
      _snack('Please enter the code from your email', Colors.red);
      return;
    }
    if (password.length < 6) {
      _snack('Password must be at least 6 characters', Colors.red);
      return;
    }
    if (password != confirm) {
      _snack('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().resetPasswordWithOtp(
            email: email,
            token: code,
            newPassword: password,
          );
      if (!mounted) return;
      _snack('Password reset! Please log in with your new password.',
          Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _snack('Error: ${e.toString()}', Colors.red);
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
          const SizedBox(height: 10),
          Text(
            'SmartAI',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We will help you recover your account',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _codeSent ? 'Enter Reset Code' : 'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _codeSent
                    ? 'Enter the code we emailed to ${_emailController.text.trim()} and choose a new password.'
                    : "Enter your email address and we'll send you a code to reset your password.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (!_codeSent) ..._emailStep() else ..._resetStep(),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'Remember your password? ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _emailStep() {
    return [
      _label('Email Address'),
      const SizedBox(height: 8),
      CustomTextField(
        hint: 'Enter your registered email',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
      ),
      const SizedBox(height: 32),
      PrimaryButton(
        label: _isLoading ? 'Sending...' : 'Send Reset Code',
        onPressed: _isLoading ? null : _handleSendCode,
      ),
    ];
  }

  List<Widget> _resetStep() {
    return [
      _label('Reset Code'),
      const SizedBox(height: 8),
      CustomTextField(
        hint: 'Enter the 6-digit code',
        prefixIcon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        controller: _codeController,
      ),
      const SizedBox(height: 20),
      _label('New Password'),
      const SizedBox(height: 8),
      CustomTextField(
        hint: 'Enter your new password',
        prefixIcon: Icons.lock_outline_rounded,
        isPassword: true,
        controller: _passwordController,
      ),
      const SizedBox(height: 20),
      _label('Confirm Password'),
      const SizedBox(height: 8),
      CustomTextField(
        hint: 'Re-enter your new password',
        prefixIcon: Icons.lock_outline_rounded,
        isPassword: true,
        controller: _confirmController,
      ),
      const SizedBox(height: 32),
      PrimaryButton(
        label: _isLoading ? 'Resetting...' : 'Reset Password',
        onPressed: _isLoading ? null : _handleResetPassword,
      ),
      const SizedBox(height: 12),
      Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _isLoading ? null : _handleSendCode,
            child: Text(
              'Resend code',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }
}
