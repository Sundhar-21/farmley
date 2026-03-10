import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/presentation/profile_screen.dart';
import 'package:farmconnect/features/consumer/presentation/favorites_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/shared/widgets/custom_bottom_nav.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/shared/widgets/voice_button.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/core/services/voice_service.dart';

/// Breakpoint above which the desktop sidebar layout is used.
const double _kDesktopBreakpoint = 800;

bool _isDesktopLayout(BuildContext context) {
  if (kIsWeb) return MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;
  return MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;
}

class ConsumerMainScreen extends ConsumerStatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  ConsumerState<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends ConsumerState<ConsumerMainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bottomNavAnimController;

  @override
  void initState() {
    super.initState();
    _bottomNavAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bottomNavAnimController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    ConsumerHomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isDesktop = _isDesktopLayout(context);

    if (isDesktop) {
      return _DesktopLayout(
        currentIndex: currentIndex,
        screens: _screens,
        onNavTap: (i) => ref.read(navigationIndexProvider.notifier).state = i,
      );
    }

    // ─── Mobile layout (unchanged) ─────────────────────────────────────────
    final voiceState = ref.watch(voiceServiceProvider);
    final isListening = voiceState.state == VoiceState.listening;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(navigationIndexProvider.notifier).state = 0;
      },
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_bottomNavAnimController.status != AnimationStatus.reverse) {
              _bottomNavAnimController.reverse();
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (_bottomNavAnimController.status != AnimationStatus.forward) {
              _bottomNavAnimController.forward();
            }
          }
          return false;
        },
        child: Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(index: currentIndex, children: _screens),
              if (isListening)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _bottomNavAnimController,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _bottomNavAnimController,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 4.h,
                    top: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomBottomNav(
                            currentIndex: currentIndex,
                            onTap: (index) =>
                                ref.read(navigationIndexProvider.notifier).state = index,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const VoiceButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Desktop Layout ──────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<Widget> screens;
  final ValueChanged<int> onNavTap;

  const _DesktopLayout({
    required this.currentIndex,
    required this.screens,
    required this.onNavTap,
  });

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, label: 'Markets'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Favorites'),
    _NavItem(icon: Icons.shopping_cart_rounded, label: 'Cart'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.background,
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────
          _DesktopSidebar(
            currentIndex: currentIndex,
            items: _navItems,
            onTap: onNavTap,
          ),
          // ── Main content ───────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.07), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: DesignGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: DesignShadows.glow,
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FarmConnect',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: DesignColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Fresh from the farm',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: DesignColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.black.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 16),
          // Nav items
          ...List.generate(items.length, (i) {
            final item = items[i];
            final selected = currentIndex == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: selected
                          ? DesignColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: selected ? DesignColors.primary : DesignColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            color: selected ? DesignColors.primary : DesignColors.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (selected) ...[
                          const Spacer(),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: DesignColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Divider(color: Colors.black.withValues(alpha: 0.06), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: DesignColors.dullLightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: DesignColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Farm Fresh\nGuaranteed',
                      style: GoogleFonts.poppins(
                        color: DesignColors.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
}
