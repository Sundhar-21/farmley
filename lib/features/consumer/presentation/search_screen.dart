import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/shared/widgets/category_chip.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/search_provider.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FFF8), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(DesignSpacing.m, isDesktop ? 24.0 : DesignSpacing.m, DesignSpacing.m, DesignSpacing.m),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('localMarkets'),
                              style: GoogleFonts.outfit(
                                color: DesignColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('findFreshProduce'),
                              style: GoogleFonts.outfit(
                                color: DesignColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignRadius.l),
                            boxShadow: DesignShadows.small,
                          ),
                          child: Stack(
                            children: [
                              const Icon(Icons.shopping_basket_outlined, color: DesignColors.textPrimary),
                              if (ref.watch(cartProvider).isNotEmpty)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      gradient: DesignGradients.primaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${ref.watch(cartProvider).length}',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchAndFilterDelegate(
                  height: isDesktop ? 130 : 130,
                  child: Container(
                    color: const Color(0xFFF8FFF8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(DesignRadius.xxl),
                                    boxShadow: DesignShadows.small,
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: GoogleFonts.poppins(
                                      fontSize: isDesktop ? 13 : 15,
                                      color: DesignColors.textPrimary,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: (value) {
                                      ref.read(searchQueryProvider.notifier).state = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      hintStyle: GoogleFonts.poppins(color: DesignColors.textTertiary, fontSize: isDesktop ? 13 : 14),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(DesignSpacing.s),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: DesignColors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.search_rounded, color: DesignColors.primary, size: 18),
                                      ),
                                      suffixIcon: searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, color: DesignColors.textSecondary),
                                              onPressed: () {
                                                _searchController.clear();
                                                ref.read(searchQueryProvider.notifier).state = '';
                                              },
                                            )
                                          : null,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(DesignRadius.xxl),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(DesignRadius.xxl),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(DesignRadius.xxl),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: DesignSpacing.s),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(DesignRadius.l),
                                  boxShadow: DesignShadows.small,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.tune_rounded, color: DesignColors.primary, size: 24),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // Filter logic placeholder
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignSpacing.s),
                        SizedBox(
                          height: 60,
                          child: ref.watch(categoriesProvider).when(
                            data: (categories) {
                              final forcedOrder = ['All', 'Vegetables', 'Fruits', 'Meat', 'Grains', 'Dairy', 'Others'];
                              
                              IconData getCategoryIcon(String dbName) {
                                switch (dbName) {
                                  case 'All': return Icons.grid_view_rounded;
                                  case 'Vegetables': return Icons.eco_rounded;
                                  case 'Fruits': return Icons.apple_rounded;
                                  case 'Meat': return Icons.kebab_dining_rounded;
                                  case 'Grains': return Icons.grass_rounded;
                                  case 'Dairy': return Icons.egg_rounded;
                                  case 'Others': return Icons.more_horiz_rounded;
                                  default: return Icons.category_rounded;
                                }
                              }

                              String getLocalizedName(String dbName) {
                                switch (dbName) {
                                  case 'All': return context.tr('all');
                                  case 'Vegetables': return context.tr('vegetables');
                                  case 'Fruits': return context.tr('fruits');
                                  case 'Meat': return context.tr('meat');
                                  case 'Grains': return context.tr('grains');
                                  case 'Dairy': return context.tr('dairy');
                                  case 'Others': return context.tr('others');
                                  default: return dbName;
                                }
                              }

                                return SizedBox(
                                  height: 60,
                                  child: isDesktop 
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                                        child: Row(
                                          children: forcedOrder.map((catName) => Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 0),
                                              child: CategoryChip(
                                                label: getLocalizedName(catName),
                                                isSelected: _selectedCategory == catName,
                                                onTap: () => setState(() => _selectedCategory = catName),
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      )
                                    : ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                                        children: forcedOrder.map((catName) => Padding(
                                          padding: const EdgeInsets.only(right: DesignSpacing.s),
                                          child: CategoryChip(
                                            label: getLocalizedName(catName),
                                            isSelected: _selectedCategory == catName,
                                            onTap: () => setState(() => _selectedCategory = catName),
                                          ),
                                        )).toList(),
                                      ),
                                );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, stack) => const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.m)),
              ref.watch(productsProvider).when(
                data: (products) {
                  var filteredProducts = products.where((p) {
                    final categoryMatch = _selectedCategory == 'All' || _selectedCategory == 'All Items' 
                        ? true 
                        : p['categories']?['name'] == _selectedCategory;
                    
                    if (!categoryMatch) return false;
                    
                    if (searchQuery.isEmpty) return true;
                    
                    final name = (p['name'] as String).toLowerCase();
                    final description = (p['description'] as String?)?.toLowerCase() ?? '';
                    return name.contains(searchQuery.toLowerCase()) || description.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: DesignColors.textSecondary.withOpacity(0.3)),
                            const SizedBox(height: DesignSpacing.m),
                            Text(
                              'No products found',
                              style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(DesignSpacing.m, 0, DesignSpacing.m, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 190,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: DesignSpacing.m,
                        mainAxisSpacing: DesignSpacing.m,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          return FarmProductCard(
                            product: product,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(product: product),
                              ),
                            ),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator(color: DesignColors.primary))),
                error: (e, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Error: $e'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickySearchAndFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickySearchAndFilterDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickySearchAndFilterDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
