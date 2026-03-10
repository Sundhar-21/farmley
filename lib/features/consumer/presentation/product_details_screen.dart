import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/favorites_provider.dart';
import 'package:farmconnect/features/consumer/presentation/cart_screen.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> with TickerProviderStateMixin {
  final int _quantity = 1;
  bool _isBaseWeightSelected = true;
  late AnimationController _favController;
  late Animation<double> _favScaleAnimation;
  late AnimationController _cartController;
  late Animation<double> _cartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _favScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _favController, curve: Curves.easeOut));
    _favController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _favController.reverse();
      }
    });

    _cartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _cartScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _cartController, curve: Curves.easeInOut));
    _cartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cartController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _favController.dispose();
    _cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((item) => item['id'] == widget.product['id']);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          return CustomScrollView(
        slivers: [
          // Large Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: DesignSpacing.l),
              child: _buildFloatingIcon(Icons.arrow_back_rounded, () => Navigator.pop(context)),
            ),
            actions: [
              _buildFloatingIcon(Icons.ios_share_rounded, () {}),
              const SizedBox(width: DesignSpacing.m),
              ScaleTransition(
                scale: _favScaleAnimation,
                child: _buildFloatingIcon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(widget.product);
                    _favController.forward();
                  },
                  color: isFav ? DesignColors.primary : DesignColors.textPrimary,
                ),
              ),
              const SizedBox(width: DesignSpacing.l),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => _showImageZoom(context, widget.product['image_url'] ?? ''),
                    child: CachedNetworkImage(
                      imageUrl: widget.product['image_url'] ?? '',
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      placeholder: (context, url) => Container(color: DesignColors.surface),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DesignColors.primary,
                        borderRadius: BorderRadius.circular(DesignRadius.m),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'HARVESTED 4 HOURS AGO',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(DesignSpacing.l),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product['name'] ?? 'Product Name',
                        style: GoogleFonts.poppins(fontSize: isDesktop ? 22 : 28, fontWeight: FontWeight.bold, color: DesignColors.textPrimary),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: DesignColors.primary, size: 24),
                        const SizedBox(width: 4),
                        Text('4.9', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: DesignColors.primary)),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Naturally sun-ripened, non-GMO',
                  style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: DesignSpacing.xl),
                
                Text(
                    'SELECT WEIGHT',
                    style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DesignSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: _buildWeightOption(
                        '500g', 
                        '\$${widget.product['price'].toStringAsFixed(2)}', 
                        _isBaseWeightSelected, 
                        () => setState(() => _isBaseWeightSelected = true),
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.m),
                    Expanded(
                      child: _buildWeightOption(
                        '1kg', 
                        '\$${(widget.product['price'] * 2).toStringAsFixed(2)}', 
                        !_isBaseWeightSelected, 
                        () => setState(() => _isBaseWeightSelected = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.xl),

                // Farm Card
                Container(
                  padding: const EdgeInsets.all(DesignSpacing.m),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignRadius.xl),
                    border: Border.all(color: DesignColors.secondary),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(DesignRadius.m),
                        child: CachedNetworkImage(
                          imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400&q=70',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          memCacheWidth: 120,
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sunny Oaks Farm', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: DesignColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Napa Valley, California', 
                                    style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(onPressed: () {}, child: Text('View Farm', style: GoogleFonts.poppins(color: DesignColors.primary, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: DesignSpacing.xl),

                // Farmer's Note
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: isDesktop ? 450 : double.infinity,
                    padding: const EdgeInsets.all(DesignSpacing.m),
                    decoration: BoxDecoration(
                      color: DesignColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                      border: const Border(left: BorderSide(color: DesignColors.primary, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FARMER\'S NOTE', style: GoogleFonts.poppins(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: isDesktop ? 10 : 12)),
                        const SizedBox(height: 8),
                        Text(
                          '"These Heirlooms are peaking this week. We picked them early this morning while the dew was still on the leaves..."',
                          style: GoogleFonts.poppins(color: DesignColors.textPrimary, fontStyle: FontStyle.italic, fontSize: isDesktop ? 12 : 14),
                        ),
                        const SizedBox(height: 8),
                        Text('— Silas Green, Head Grower', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isDesktop ? 10 : 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignSpacing.xl),

                Text('Nutritional Facts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: DesignSpacing.m),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNutrient('CAL', '22'),
                      const SizedBox(width: 8),
                      _buildNutrient('VIT A', '15%'),
                      const SizedBox(width: 8),
                      _buildNutrient('VIT C', '20%'),
                      const SizedBox(width: 8),
                      _buildNutrient('FIBER', '1.5g'),
                    ],
                  ),
                ),
                const SizedBox(height: DesignSpacing.xl),

                Text('GROWN AT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: DesignSpacing.m),
                ClipRRect(
                  borderRadius: BorderRadius.circular(DesignRadius.xl),
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=800&q=70',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      );
    },
    ),
      bottomSheet: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL PRICE', style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('\$${(widget.product['price'] * (_isBaseWeightSelected ? 1 : 2) * _quantity).toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Spacer(),
            ScaleTransition(
              scale: _cartScaleAnimation,
              child: SizedBox(
                width: 120,
                child: ElevatedButton(
                    onPressed: () {
                      _cartController.forward();
                      final cartNotifier = ref.read(cartProvider.notifier);
                      cartNotifier.addToCart(widget.product, _isBaseWeightSelected ? '500g' : '1kg', _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${widget.product['name']} added to basket"),
                          backgroundColor: DesignColors.primary,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.m),
                        side: const BorderSide(color: DesignColors.primary, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: DesignColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Add to Cart', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ), // Added missing closing parenthesis for ScaleTransition
            const SizedBox(width: DesignSpacing.s),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                  onPressed: () {
                    final cartNotifier = ref.read(cartProvider.notifier);
                    cartNotifier.addToCart(widget.product, _isBaseWeightSelected ? '500g' : '1kg', _quantity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Buy Now', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? DesignColors.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildWeightOption(String weight, String price, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignSpacing.m),
        decoration: BoxDecoration(
          color: isSelected ? DesignColors.primary.withOpacity(0.05) : DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.m),
          border: Border.all(color: isSelected ? DesignColors.primary : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(weight, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(price, style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        borderRadius: BorderRadius.circular(DesignRadius.m),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _showImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.9),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

