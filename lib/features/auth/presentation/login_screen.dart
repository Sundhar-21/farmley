import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';
import 'package:farmconnect/features/auth/presentation/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
      
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      if (email.isEmpty) {
        _emailError = 'Email is required';
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email';
        isValid = false;
      }
      
      if (password.isEmpty) {
        _passwordError = 'Password is required';
        isValid = false;
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 800;

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                if (!isDesktop) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: DesignShadows.glow,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      "FarmConnect",
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Fresh from farm to your table",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
                Text(
                  "Welcome Back",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to continue your journey",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: DesignColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  isDesktop: isDesktop,
                ),
                if (_emailError != null && _emailError!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      _emailError!,
                      style: GoogleFonts.outfit(
                        color: DesignColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  obscureText: _obscurePassword,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  errorText: _passwordError,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 12),
                if (_passwordError != null && _passwordError!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      _passwordError!,
                      style: GoogleFonts.outfit(
                        color: DesignColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showForgotPasswordDialog(context, ref);
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.outfit(
                        color: DesignColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 13 : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: DesignGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(DesignRadius.xxl),
                    boxShadow: DesignShadows.glow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: authState.isLoading
                          ? null
                          : () async {
                              HapticFeedback.lightImpact();
                              if (_validateInputs()) {
                                try {
                                  await ref.read(authNotifierProvider.notifier).signIn(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      );
                                } catch (e) {
                                  // Setup generic or specific matching message based on error 
                                  if (mounted) {
                                    setState(() {
                                      _emailError = ' ';
                                      _passwordError = 'Wrong username or password';
                                    });
                                  }
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(DesignRadius.xxl),
                      child: Center(
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: GoogleFonts.outfit(
                                  fontSize: isDesktop ? 15 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: DesignColors.textTertiary)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or continue with",
                        style: GoogleFonts.outfit(
                          color: DesignColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: DesignColors.textTertiary)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: const Color(0xFF4285F4),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        try {
                          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google sign-in failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.apple_rounded,
                      iconColor: Colors.black,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        try {
                          await ref.read(authNotifierProvider.notifier).signInWithApple();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Apple sign-in failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.outfit(
                        color: DesignColors.textSecondary,
                        fontSize: isDesktop ? 13 : 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.outfit(
                          color: DesignColors.primaryDark,
                          fontSize: isDesktop ? 13 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          );

    Widget content;
    if (isDesktop) {
      content = Padding(
        padding: const EdgeInsets.all(40.0),
        child: formColumn,
      );
    } else {
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: formColumn,
      );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // ── Left branding panel ───────────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B9E26), Color(0xFF28D339)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 56),
                      ),
                      const SizedBox(height: 28),
                      Text('FarmConnect', style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Fresh from farm to your table', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                      const SizedBox(height: 32),
                      _FeatureBullet(icon: Icons.eco_rounded, text: 'Organic & fresh produce'),
                      _FeatureBullet(icon: Icons.local_shipping_rounded, text: 'Farm-to-door delivery'),
                      _FeatureBullet(icon: Icons.verified_rounded, text: 'Verified local farmers'),
                    ],
                  ),
                ),
              ),
            ),
            // ── Right form panel ─────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.white,
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: content,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FFF0), Color(0xFFFFFFFF), Color(0xFFF8FFF8)],
          ),
        ),
        child: SafeArea(child: content),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onSuffixTap,
    String? errorText,
    bool isDesktop = false,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.l),
        boxShadow: DesignShadows.small,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: 15),
        cursorColor: DesignColors.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: isDesktop ? 15 : null),
          hintStyle: GoogleFonts.outfit(color: DesignColors.textTertiary, fontSize: isDesktop ? 14 : null),
          prefixIcon: Icon(prefixIcon, color: hasError ? DesignColors.error : DesignColors.primary),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: DesignColors.textSecondary),
                  onPressed: onSuffixTap,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: hasError ? const BorderSide(color: DesignColors.error, width: 1.5) : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: hasError ? const BorderSide(color: DesignColors.error, width: 1.5) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: BorderSide(color: hasError ? DesignColors.error : DesignColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: const BorderSide(color: DesignColors.error, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    String? imageIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.l),
          boxShadow: DesignShadows.small,
        ),
        child: imageIcon != null
            ? Center(
                child: Image.asset(
                  imageIcon,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    icon,
                    color: iconColor ?? DesignColors.textPrimary,
                    size: 30,
                  ),
                ),
              )
            : Icon(
                icon,
                color: iconColor ?? DesignColors.textPrimary,
                size: 30,
              ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reset Password',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you a reset link',
                style: GoogleFonts.outfit(color: DesignColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: DesignColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignRadius.l),
                ),
                child: TextField(
                  controller: emailController,
                  style: GoogleFonts.outfit(color: DesignColors.textPrimary),
                  cursorColor: DesignColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.email_outlined, color: DesignColors.primary),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                        ),
                        side: BorderSide(color: DesignColors.secondary),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontWeight: FontWeight.bold, fontSize: MediaQuery.sizeOf(context).width >= 800 ? 13 : null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignRadius.l),
                        boxShadow: DesignShadows.glow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter your email', style: GoogleFonts.outfit()),
                                  backgroundColor: DesignColors.error,
                                ),
                              );
                              return;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid email', style: GoogleFonts.outfit()),
                                  backgroundColor: DesignColors.error,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password reset link sent to $email', style: GoogleFonts.outfit()),
                                backgroundColor: DesignColors.success,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Send Link',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: MediaQuery.sizeOf(context).width >= 800 ? 15 : null),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
