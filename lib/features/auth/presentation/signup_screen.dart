import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/auth/data/auth_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/presentation/main_screen.dart';
import 'package:farmconnect/features/farmer/presentation/home_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedRole = 'consumer';
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 800;

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                      boxShadow: DesignShadows.small,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                if (!isDesktop) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: DesignShadows.glow,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Create Account",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Join the FarmConnect family",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  const SizedBox(height: 24),
                ],
                _buildInputField(
                  controller: _fullNameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  prefixIcon: Icons.person_outline,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Create a password",
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  obscureText: _obscurePassword,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 28),
                Text(
                  "I want to join as:",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: "Consumer",
                        icon: Icons.shopping_bag_outlined,
                        subtitle: "Buy fresh produce",
                        isSelected: _selectedRole == 'consumer',
                        onTap: () => setState(() => _selectedRole = 'consumer'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        label: "Farmer",
                        icon: Icons.agriculture_rounded,
                        subtitle: "Sell your products",
                        isSelected: _selectedRole == 'farmer',
                        onTap: () => setState(() => _selectedRole = 'farmer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                              final authNotifier = ref.read(authNotifierProvider.notifier);
                              try {
                                await authNotifier.signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                  {
                                    'full_name': _fullNameController.text,
                                    'role': _selectedRole,
                                  },
                                );
                                
                                if (mounted) {
                                   final user = ref.read(supabaseProvider).auth.currentUser;
                                   if (user != null) {
                                     final supabase = ref.read(supabaseProvider);
                                     
                                     try {
                                       await supabase.from('profiles').insert({
                                         'id': user.id,
                                         'full_name': _fullNameController.text,
                                         'role': _selectedRole,
                                       });
                                     } catch (e) {
                                       debugPrint("Error creating profile: $e");
                                     }

                                     try {
                                       if (_selectedRole == 'farmer') {
                                          await supabase.from('farmer_profiles').insert({
                                            'profile_id': user.id, 
                                            'farm_name': 'My Farm',
                                            'farm_location': 'Unknown'
                                          });
                                       } else {
                                          await supabase.from('consumer_profiles').insert({
                                            'profile_id': user.id
                                          });
                                       }
                                     } catch (e) {
                                       debugPrint("Error creating sub-profile: $e");
                                     }
                                     
                                     if (mounted) {
                                       if (_selectedRole == 'farmer') {
                                         Navigator.pushAndRemoveUntil(
                                           context,
                                           MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
                                           (route) => false,
                                         );
                                       } else {
                                         Navigator.pushAndRemoveUntil(
                                           context,
                                           MaterialPageRoute(builder: (context) => const ConsumerMainScreen()),
                                           (route) => false,
                                         );
                                       }
                                     }
                                   }
                                }
                              } catch (e) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text('Signup Failed: $e')),
                                 );
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
                                "Create Account",
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.outfit(
                        color: DesignColors.textSecondary,
                        fontSize: isDesktop ? 13 : 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Login",
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
                      Text('Join the farm fresh community', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18)),
                            const SizedBox(width: 12),
                            Text('Organic & fresh produce', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Padding(
                         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18)),
                             const SizedBox(width: 12),
                             Text('Farm-to-door delivery', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                           ],
                         ),
                      ),
                      Padding(
                         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18)),
                             const SizedBox(width: 12),
                             Text('Verified local farmers', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                           ],
                         ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    bool isDesktop = false,
  }) {
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
          prefixIcon: Icon(prefixIcon, color: DesignColors.primary),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: DesignColors.textSecondary),
                  onPressed: onSuffixTap,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.l),
            borderSide: const BorderSide(color: DesignColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? DesignGradients.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xl),
          border: Border.all(
            color: isSelected ? Colors.transparent : DesignColors.secondary,
            width: 2,
          ),
          boxShadow: isSelected ? DesignShadows.glow : DesignShadows.small,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : DesignColors.surfaceVariant,
                borderRadius: BorderRadius.circular(DesignRadius.m),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : DesignColors.primaryDark,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : DesignColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white70 : DesignColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
