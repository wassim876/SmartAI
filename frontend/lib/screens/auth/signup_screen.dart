import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_button.dart';
import '../../providers/auth_provider.dart';

// Define constants for the terms and privacy policy text
const String _termsAndConditionsText = '''
1. Acceptance of Terms

Welcome to SmartAI. By creating an account, accessing, or using our services, you agree to be bound by these Terms and Conditions and our Privacy Policy.

If you do not agree with any part of these terms, please do not use SmartAI.

2. Description of Service

SmartAI provides AI-powered tools and services through web and mobile applications.

Features may include:

AI assistance
Smart recommendations
User account management
Data storage and processing
Other AI-related services

We reserve the right to modify, suspend, or discontinue any feature at any time.

3. User Accounts

When creating an account, you agree to:

Provide accurate information
Keep your password secure
Maintain the confidentiality of your account
Notify us immediately of unauthorized access

You are responsible for all activities performed under your account.

4. Acceptable Use

You agree not to:

Violate any applicable laws
Upload harmful or malicious content
Attempt unauthorized access to our systems
Interfere with the operation of the platform
Use SmartAI for fraudulent activities

Violation of these rules may result in account suspension or termination.

5. Intellectual Property

All content, branding, logos, software, and design elements of SmartAI are the property of SmartAI or its licensors.

Users may not copy, distribute, or modify platform content without permission.

6. AI Generated Content

SmartAI may generate responses, recommendations, or content using artificial intelligence.

Users acknowledge that:

AI-generated content may contain inaccuracies
Results should be independently verified when necessary
SmartAI is not liable for decisions made solely based on AI-generated outputs
7. Privacy

Your privacy is important to us.

Information collected may include:

Account information
Usage data
Device information
User-generated content

Data is processed according to our Privacy Policy.

8. Limitation of Liability

SmartAI is provided on an "as is" basis.

We are not liable for:

Service interruptions
Data loss
Indirect damages
Business losses resulting from platform use

Use of the service is at your own risk.

9. Termination

We reserve the right to suspend or terminate accounts that violate these Terms and Conditions.

Users may discontinue use of the service at any time.

10. Changes to Terms

We may update these Terms and Conditions periodically.

Continued use of SmartAI after updates constitutes acceptance of the revised terms.

11. Contact Information

For questions regarding these Terms and Conditions, please contact the SmartAI support team.
''';

const String _privacyPolicyText = '''
Information We Collect

We may collect:

Name
Email address
Profile information
Device information
Usage analytics
How We Use Information

Information may be used to:

Provide and improve services
Authenticate users
Enhance security
Deliver customer support
Analyze platform performance
Data Security

We implement reasonable security measures to protect user information.

However, no internet transmission is completely secure.

Third-Party Services

SmartAI may use third-party services for:

Authentication
Analytics
Cloud hosting

These providers may process information according to their own privacy policies.

User Rights

Users may request:

Access to personal data
Correction of inaccurate data
Deletion of personal data where applicable
Policy Updates

This Privacy Policy may be updated periodically.

Continued use of SmartAI indicates acceptance of the updated policy.
''';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
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

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Basic username validation
    if (username.contains('@') || username.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot contain @ or spaces')),
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
            username: username,
            email: email,
            password: password,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
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

  Future<bool?> _showTermsAndConditionsDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext dialogContext) =>
          _TermsAndConditionsDialogContent(),
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
            Text('Username',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            CustomTextField(
                hint: 'Enter Your Username',
                controller: _usernameController,
                prefixIcon: Icons.alternate_email_rounded),
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
                _agreeTerms, (bool? newValue) async {
              if (newValue == true) {
                final bool? accepted = await _showTermsAndConditionsDialog();
                if (accepted == true) {
                  setState(() {
                    _agreeTerms = true;
                  });
                }
                // If not accepted, _agreeTerms remains false, and checkbox won't be checked.
              } else {
                setState(() {
                  _agreeTerms = false;
                });
              }
            }),
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

// New StatefulWidget for the dialog content
class _TermsAndConditionsDialogContent extends StatefulWidget {
  @override
  __TermsAndConditionsDialogContentState createState() =>
      __TermsAndConditionsDialogContentState();
}

class __TermsAndConditionsDialogContentState
    extends State<_TermsAndConditionsDialogContent> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Check if content is not scrollable (e.g., very short content)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent == 0) {
        setState(() {
          _hasScrolledToEnd = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_hasScrolledToEnd) {
      setState(() {
        _hasScrolledToEnd = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Text(
          'Legal Agreements',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Make dialog wider
        height: MediaQuery.of(context).size.height * 0.6, // Make dialog taller
        child: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('SmartAI Terms & Conditions'),
                      const SizedBox(height: 8),
                      _bodyText(_termsAndConditionsText),
                      const SizedBox(height: 24),
                      _sectionHeader('Privacy Policy'),
                      const SizedBox(height: 8),
                      _bodyText(_privacyPolicyText),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            if (!_hasScrolledToEnd)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Please scroll to the bottom to accept',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // User declined
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textGrey,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'Decline',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _hasScrolledToEnd
              ? () => Navigator.of(context).pop(true)
              : null, // Disable until scrolled to end
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
            disabledForegroundColor: Colors.white.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            elevation: _hasScrolledToEnd ? 2 : 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Accept',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.primary,
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: 13, color: AppColors.textDark, height: 1.6),
    );
  }
}
