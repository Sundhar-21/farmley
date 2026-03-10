import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/category_chip.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/shared/widgets/shimmer_loading.dart';
import 'package:farmconnect/features/consumer/presentation/product_details_screen.dart';
import 'package:farmconnect/features/consumer/presentation/dedicated_search_screen.dart';
import 'package:farmconnect/features/consumer/presentation/search_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';
import 'package:farmconnect/features/consumer/presentation/category_products_screen.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/features/consumer/presentation/orders_screen.dart';
import 'package:farmconnect/features/auth/presentation/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmconnect/shared/widgets/vertical_category_tile.dart';


class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Container(
      decoration: const BoxDecoration(
        color: DesignColors.dullLightGreen,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
        },
        color: DesignColors.primary,
        backgroundColor: Colors.white,
        displacement: 100,
        edgeOffset: 50,
        child: SafeArea(
          bottom: false,
          child: Builder(builder: (context) {
            final isDesktop = MediaQuery.sizeOf(context).width >= 800;
            final content = Container(
              color: Colors.white,
              child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 500,
              slivers: [
            
            SliverToBoxAdapter(
              child: Container(
                color: DesignColors.dullLightGreen,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: profileAsync.when(
                  data: (profile) => Padding(
                    padding: EdgeInsets.only(
                      left: DesignSpacing.m,
                      right: DesignSpacing.m,
                      top: isDesktop ? 24.0 : 0.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => _showAddressUpdateDialog(context, ref, profile?['address'] ?? ''),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: DesignSpacing.s),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: DesignColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.location_on, color: DesignColors.primary, size: 16),
                                  ),
                                  const SizedBox(width: DesignSpacing.s),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'DELIVER TO',
                                          style: GoogleFonts.poppins(color: DesignColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                profile?['address']?.isEmpty ?? true ? 'Select Address' : profile!['address'],
                                                style: GoogleFonts.poppins(color: DesignColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: DesignColors.textSecondary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          offset: const Offset(0, 56), // Position below the icon
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.l)),
                          onSelected: (value) async {
                            HapticFeedback.lightImpact();
                            switch (value) {
                              case 'profile':
                                ref.read(navigationIndexProvider.notifier).state = 4;
                                break;
                              case 'orders':
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
                                break;
                              case 'favorites':
                                ref.read(navigationIndexProvider.notifier).state = 2;
                                break;
                              case 'logout':
                                final supabase = ref.read(supabaseProvider);
                                await supabase.auth.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 20, color: DesignColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text('Profile', style: GoogleFonts.poppins(fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'orders',
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_outlined, size: 20, color: DesignColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text('My Orders', style: GoogleFonts.poppins(fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'favorites',
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_border_rounded, size: 20, color: DesignColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text('Favorites', style: GoogleFonts.poppins(fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_rounded, size: 20, color: DesignColors.error),
                                  const SizedBox(width: 12),
                                  Text('Logout', style: GoogleFonts.poppins(fontSize: 14, color: DesignColors.error, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: DesignGradients.primaryGradient,
                              boxShadow: DesignShadows.glow,
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              backgroundImage: profile?['avatar_url'] != null && profile!['avatar_url'].toString().isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      profile['avatar_url'],
                                      maxWidth: 80,
                                      maxHeight: 80,
                                    )
                                  : null,
                              child: profile?['avatar_url'] == null || profile!['avatar_url'].toString().isEmpty
                                  ? Text(
                                      (profile?['full_name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: DesignColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(height: 50),
                  error: (_, __) => const SizedBox(height: 50),
                ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                color: DesignColors.dullLightGreen,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('freshFromTheFarm'),
                          style: GoogleFonts.poppins(
                            color: DesignColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          context.tr('discoverOrganicProduce'),
                          style: GoogleFonts.poppins(
                            color: DesignColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
                  ),
                ),
              ),
            ),
            
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                height: 130, // 8 (top gap) + 50 (search) + 12 (bottom gap) + 60 (categories)
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                  children: [
                  const SizedBox(height: DesignSpacing.s),
                  // Search Bar row
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
                              readOnly: true,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const DedicatedSearchScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop ? 13 : 15,
                                color: DesignColors.textPrimary,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: 14),
                                hintText: 'Search fresh produce...',
                                hintStyle: GoogleFonts.poppins(color: DesignColors.textTertiary, fontSize: isDesktop ? 13 : 14),
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
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 50,
                                  minHeight: 50,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.mic_none_rounded, color: DesignColors.primary, size: 20),
                                  onPressed: () {
                                    // Separate voice search logic placeholder
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(DesignSpacing.s),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: DesignColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.search_rounded, color: DesignColors.primary, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignSpacing.m),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: DesignGradients.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: DesignShadows.glow,
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                    // Categories list
                    categoriesAsync.when(
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
                                  children: forcedOrder.map((catName) {
                                    return Expanded(
                                      child: VerticalCategoryTile(
                                        label: getLocalizedName(catName),
                                        icon: getCategoryIcon(catName),
                                        isSelected: _selectedCategory == catName,
                                        isVertical: false,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _selectedCategory = catName;
                                            _searchQuery = '';
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : ListView.builder(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                                itemCount: forcedOrder.length,
                                itemBuilder: (context, index) {
                                  final catName = forcedOrder[index];
                                  return VerticalCategoryTile(
                                    label: getLocalizedName(catName),
                                    icon: getCategoryIcon(catName),
                                    isSelected: _selectedCategory == catName,
                                    width: 75.0,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _selectedCategory = catName;
                                        _searchQuery = '';
                                      });
                                    },
                                  );
                                },
                              ),
                        );
                      },
                      loading: () => const SizedBox(height: 60),
                      error: (error, stackTrace) => const SizedBox(height: 60),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: DesignSpacing.l)),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: profileAsync.when(
                data: (profile) {
                  if (_selectedCategory != 'All') {
                    return _buildCategoryGrid(context, ref, productsAsync, _selectedCategory);
                  } else {
                    return _buildSectionedContent(context, ref, productsAsync);
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
                  ),
                ),
            ),
          ],
        ),
      );
      return content;
    }),
        ),
      ),
    );
  }

  Widget _buildSectionedContent(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox();

        // Get categories from data
        final vegetables = products.where((p) => (p['categories'] as Map?)?['name'] == 'Vegetables').toList();
        final fruits = products.where((p) => (p['categories'] as Map?)?['name'] == 'Fruits').toList();
        final meat = products.where((p) => (p['categories'] as Map?)?['name'] == 'Meat').toList();
        final grains = products.where((p) => (p['categories'] as Map?)?['name'] == 'Grains').toList();
        final dairy = products.where((p) => (p['categories'] as Map?)?['name'] == 'Dairy').toList();
        final others = products.where((p) => (p['categories'] as Map?)?['name'] == 'Others').toList();

        final featuredProduct = products.isNotEmpty ? products.first : null;

        return Column(
          children: [
            if (featuredProduct != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: featuredProduct)),
                  ),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: DesignGradients.darkGradient,
                      borderRadius: BorderRadius.circular(DesignRadius.xxl),
                      boxShadow: DesignShadows.large,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(DesignRadius.xxl),
                            child: CachedNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=70&w=600',
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.4),
                              colorBlendMode: BlendMode.darken,
                              placeholder: (context, url) => Container(color: DesignColors.surface),
                              errorWidget: (context, url, error) => Container(color: DesignColors.surface),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(DesignSpacing.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignColors.primary,
                                  borderRadius: BorderRadius.circular(DesignRadius.full),
                                ),
                                child: Text(
                                  'Featured',
                                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                featuredProduct['name'] ?? 'Fresh Harvest Box',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Fresh harvest delivered to your door',
                                style: GoogleFonts.poppins(color: DesignColors.primaryLight, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$${featuredProduct['price']}',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(DesignRadius.full),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Order Now',
                                          style: GoogleFonts.poppins(color: DesignColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_rounded, color: DesignColors.primaryDark, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: DesignSpacing.m),

            // Recommended for you
            ref.watch(recommendedProductsProvider).when(
              data: (recommended) => _buildSection(
                context, 
                'Recommended for you', 
                recommended,
                onSeeAll: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const SearchScreen())
                ),
              ),
              loading: () => const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(),
            ),
            
            _buildSection(context, 'Vegetables', vegetables, onSeeAll: () => _navigateToCategory(context, 'Vegetables')),
            _buildSection(context, 'Fruits', fruits, onSeeAll: () => _navigateToCategory(context, 'Fruits')),
            _buildSection(context, 'Meat', meat, onSeeAll: () => _navigateToCategory(context, 'Meat')),
            _buildSection(context, 'Grains', grains, onSeeAll: () => _navigateToCategory(context, 'Grains')),
            _buildSection(context, 'Dairy', dairy, onSeeAll: () => _navigateToCategory(context, 'Dairy')),
            _buildSection(context, 'Others', others, onSeeAll: () => _navigateToCategory(context, 'Others')),
            
            const SizedBox(height: DesignSpacing.xxl),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(categoryName: categoryName),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Map<String, dynamic>> products, {required VoidCallback onSeeAll}) {
    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: DesignColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    color: DesignColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: DesignSpacing.m),
                child: SizedBox(
                  width: 170,
                  child: FarmProductCard(product: products[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: DesignSpacing.m),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> productsAsync, String category) {
    return productsAsync.when(
      data: (products) {
        final filteredProducts = products.where((p) => (p['categories'] as Map?)?['name'] == category).toList();

        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7), // Lower opacity for better Image 2 match
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    size: 64,
                    color: DesignColors.primary.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products available in $category',
                  style: GoogleFonts.poppins(
                    color: DesignColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(DesignSpacing.m),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            childAspectRatio: 0.72,
            crossAxisSpacing: DesignSpacing.m,
            mainAxisSpacing: DesignSpacing.m,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return FarmProductCard(product: filteredProducts[index]);
          },
        );
      },
      loading: () => const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: DesignColors.primary)),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  void _showAddressUpdateDialog(BuildContext context, WidgetRef ref, String currentAddress) {
    final controller = TextEditingController(text: currentAddress);
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
                'Update Delivery Address',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: DesignColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignRadius.l),
                ),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.poppins(color: DesignColors.textPrimary),
                  cursorColor: DesignColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: DesignColors.primary),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 2,
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
                        style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontWeight: FontWeight.bold),
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
                            final newAddress = controller.text.trim();
                            if (newAddress.isNotEmpty) {
                              final supabase = ref.read(supabaseProvider);
                              final user = supabase.auth.currentUser;
                              if (user != null) {
                                await supabase
                                    .from('profiles')
                                    .update({'address': newAddress})
                                    .eq('id', user.id);
                                ref.invalidate(userProfileProvider);
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Update',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
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
              // Added SliverToBoxAdapter to ensure content isn't permanently blocked by the nav bar.
              // This is placed within the Column's children list, effectively adding space at the bottom.
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: DesignColors.dullLightGreen,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
