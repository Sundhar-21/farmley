import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FarmProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;
  final bool isLarge;
  final VoidCallback? onTap;

  const FarmProductCard({
    super.key,
    required this.product,
    this.isLarge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLarge) {
      return _buildLargeCard(context, ref);
    }
    return _buildSmallCard(context, ref);
  }

  Widget _buildLargeCard(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((item) => item['id'] == product['id']);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: DesignGradients.primaryGradient,
          borderRadius: BorderRadius.circular(DesignRadius.xl),
          boxShadow: DesignShadows.large,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product Name',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product['description'] ?? 'Free Delivery',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'PRICE',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${product['price']}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.m),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product, product['unit'] ?? '500g', 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product['name']} added to cart!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(DesignSpacing.m),
                          decoration: const BoxDecoration(
                            color: DesignColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.s),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(DesignRadius.xl),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: DesignSpacing.xs),
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: -20,
              bottom: 20,
              top: 20,
              child: Hero(
                tag: 'product_${product['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignRadius.xl),
                  child: CachedNetworkImage(
                    imageUrl: product['image_url'] ?? '',
                    fit: BoxFit.contain,
                    width: 200,
                    memCacheWidth: 400,
                    errorWidget: (context, url, error) => const Icon(Icons.image, size: 100),
                    placeholder: (context, url) => Container(color: DesignColors.surface),
                  ),
                ),
              ),
            ),
            Positioned(
              top: DesignSpacing.l,
              right: DesignSpacing.l,
              child: GestureDetector(
                onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
                child: Container(
                  padding: const EdgeInsets.all(DesignSpacing.s),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((item) => item['id'] == product['id']);

    return RepaintBoundary(
      child: GestureDetector(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.xl),
          boxShadow: DesignShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: DesignColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(DesignRadius.xl),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignRadius.xl),
                      child: Hero(
                        tag: 'product_small_${product['id']}',
                        child: CachedNetworkImage(
                          imageUrl: product['image_url'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          memCacheWidth: 300,
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: DesignColors.primary.withOpacity(0.1),
                            ),
                            child: const Icon(Icons.eco, color: DesignColors.primary, size: 32),
                          ),
                          placeholder: (context, url) => Container(color: DesignColors.surfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: DesignGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignRadius.full),
                      ),
                      child: Text(
                        'Fresh',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: DesignShadows.small,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: isFav ? Colors.redAccent : DesignColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: GoogleFonts.poppins(
                      color: DesignColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['unit'] ?? '500g'}',
                    style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: DesignSpacing.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '\$${product['price']}',
                                style: GoogleFonts.poppins(
                                  color: DesignColors.primaryDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product, product['unit'] ?? '500g', 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product['name']} added to cart"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: DesignColors.primaryDark,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: DesignGradients.primaryGradient,
                            borderRadius: BorderRadius.circular(DesignRadius.m),
                            boxShadow: [
                              BoxShadow(
                                color: DesignColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

