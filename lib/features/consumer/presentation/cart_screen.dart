import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/empty_state_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/features/consumer/presentation/payment_selection_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartProvider.notifier).totalPrice;
    final profileAsync = ref.watch(userProfileProvider);

    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSpacing.m),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: DesignSpacing.s),
                  ],
                  Expanded(
                    child: Text(
                      'Your Basket',
                      style: GoogleFonts.outfit(
                        color: DesignColors.textPrimary,
                        fontSize: isDesktop ? 22 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (cartItems.isNotEmpty)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l, vertical: DesignSpacing.m),
                    child: Row(
                      children: [
                        Text(
                          '${cartItems.length} items from 2 local farms',
                          style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.l),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, ref, item);
                    },
                  ),
                  _buildCarbonFootprint(),
                  _buildCheckoutPanel(context, ref, totalPrice, profileAsync.value?['address'] ?? 'No Address Provided'),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.shopping_basket_outlined,
      title: 'Your basket is empty',
      subtitle: 'Start shopping to add items to your basket',
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    return Dismissible(
      key: Key('cart_${item.cartKey}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DesignSpacing.l),
        decoration: BoxDecoration(
          color: DesignColors.error,
          borderRadius: BorderRadius.circular(DesignRadius.m),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        ref.read(cartProvider.notifier).removeFromCart(item.cartKey);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignSpacing.l),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignColors.surface,
                borderRadius: BorderRadius.circular(DesignRadius.m),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignRadius.m),
                child: CachedNetworkImage(
                  imageUrl: item.product['image_url'] ?? '',
                  fit: BoxFit.cover,
                  memCacheWidth: 200,
                  errorWidget: (context, url, error) => const Icon(Icons.eco, color: DesignColors.primary),
                  placeholder: (context, url) => Container(color: DesignColors.surface),
                ),
              ),
            ),
            const SizedBox(width: DesignSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product['name'] ?? 'Product',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, size: 14, color: DesignColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Sunny Peaks Farm',
                        style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.weight} bag',
                    style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(item.product['price'] * (item.weight == '1kg' ? 2 : 1) * item.quantity).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: DesignColors.surface,
                    borderRadius: BorderRadius.circular(DesignRadius.s),
                  ),
                  child: Row(
                    children: [
                      _buildQtyBtn(context, ref, item.cartKey, item.quantity - 1, Icons.remove),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${item.quantity}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ),
                      _buildQtyBtn(context, ref, item.cartKey, item.quantity + 1, Icons.add, isPrimary: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(BuildContext context, WidgetRef ref, String cartKey, int newQty, IconData icon, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: () => ref.read(cartProvider.notifier).updateQuantity(cartKey, newQty),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPrimary ? DesignColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: isPrimary ? Colors.white : DesignColors.textPrimary),
      ),
    );
  }

  Widget _buildCarbonFootprint() {
    return Container(
      margin: const EdgeInsets.all(DesignSpacing.l),
      padding: const EdgeInsets.all(DesignSpacing.m),
      decoration: BoxDecoration(
        color: DesignColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignRadius.m),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: DesignColors.primary, size: 24),
          ),
          const SizedBox(width: DesignSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carbon Footprint Saved', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                    children: [
                      const TextSpan(text: 'You saved '),
                      TextSpan(text: '2.4kg of CO2', style: TextStyle(color: DesignColors.primary, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' by shopping directly from local farms.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, WidgetRef ref, double total, String shippingAddress) {
    const deliveryFee = 2.50;
    final hasAddress = shippingAddress.isNotEmpty && shippingAddress != 'No Address Provided';
    
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: DesignSpacing.s),
          _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
          const Divider(height: DesignSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('\$${(total + deliveryFee).toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),
          GestureDetector(
            onTap: () => _showAddressDialog(context, ref, shippingAddress),
            child: Container(
              padding: const EdgeInsets.all(DesignSpacing.m),
              decoration: BoxDecoration(
                color: hasAddress ? DesignColors.primary.withOpacity(0.1) : DesignColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignRadius.m),
                border: hasAddress ? null : Border.all(color: DesignColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    hasAddress ? Icons.location_on_outlined : Icons.add_location_alt_outlined,
                    color: hasAddress ? DesignColors.primary : DesignColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasAddress ? 'Shipping to: $shippingAddress' : 'Tap to add delivery address',
                      style: GoogleFonts.poppins(
                        color: hasAddress ? DesignColors.textPrimary : DesignColors.error,
                        fontSize: 13,
                        fontWeight: hasAddress ? FontWeight.normal : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    color: hasAddress ? DesignColors.primary : DesignColors.error,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignSpacing.m),
          
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: DesignColors.textSecondary, size: 20),
              const SizedBox(width: DesignSpacing.s),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text('Next: Tomorrow, 8am-10am', style: GoogleFonts.poppins(color: DesignColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () {}, child: Text('CHANGE', style: GoogleFonts.poppins(color: DesignColors.primary, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: DesignSpacing.m),

          ElevatedButton(
            onPressed: () async {
              if (!hasAddress) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.location_off, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Please add your delivery address', style: GoogleFonts.poppins()),
                      ],
                    ),
                    backgroundColor: DesignColors.error,
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSelectionScreen(
                    totalAmount: total + deliveryFee,
                    shippingAddress: shippingAddress,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008000), 
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(BuildContext context, WidgetRef ref, String currentAddress) {
    final controller = TextEditingController(text: currentAddress == 'No Address Provided' ? '' : currentAddress);
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
                'Delivery Address',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your delivery address for this order',
                style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: DesignColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignRadius.l),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: DesignColors.primary),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 2,
                  autofocus: true,
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
                                'Save Address',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 16)),
        Text(value, style: GoogleFonts.poppins(color: DesignColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

