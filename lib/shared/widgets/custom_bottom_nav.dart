import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';

class CustomBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).length;
    final favCount = ref.watch(favoritesProvider).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(0, CupertinoIcons.house_fill, CupertinoIcons.house, context.tr('home')),
        _buildNavItem(1, CupertinoIcons.search, CupertinoIcons.search, context.tr('markets')),
        _buildNavItem(2, CupertinoIcons.heart_fill, CupertinoIcons.heart, context.tr('favorites'), badge: favCount > 0 ? favCount : null),
        _buildNavItem(3, CupertinoIcons.cart_fill, CupertinoIcons.cart, context.tr('cart'), badge: cartCount > 0 ? cartCount : null),
        _buildNavItem(4, CupertinoIcons.person_fill, CupertinoIcons.person, context.tr('profile')),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {int? badge}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    key: ValueKey(isSelected),
                    color: isSelected ? DesignColors.primary : CupertinoColors.systemGrey,
                    size: 24.sp,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -6.h,
                    right: -8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.destructiveRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : badge.toString(),
                          style: TextStyle(color: CupertinoColors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                color: isSelected ? DesignColors.primary : CupertinoColors.systemGrey,
                fontSize: 9.sp, // Slightly smaller
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

