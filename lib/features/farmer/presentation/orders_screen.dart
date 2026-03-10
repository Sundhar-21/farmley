import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:timeago/timeago.dart' as timeago;

final farmerOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  // Fetch items assigned to this farmer with order details
  final response = await supabase
      .from('order_items')
      .select('*, products(name, image_url), orders(status, created_at, shipping_address)')
      .eq('farmer_id', user.id)
      .order('id', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
});

class FarmerOrdersScreen extends ConsumerWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(farmerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Orders to Fulfill", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF111111))),
      ),
      body: ordersAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text("No orders yet", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF666666))));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item['products'] as Map<String, dynamic>?;
              final order = item['orders'] as Map<String, dynamic>?;
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Product Row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: product != null && product['image_url'] != null 
                                  ? DecorationImage(image: NetworkImage(product['image_url']), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: product == null || product['image_url'] == null
                                ? Icon(Icons.eco, color: DesignColors.primary)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?['name'] ?? 'Unknown Item',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF111111)),
                                ),
                                Text(
                                  "Qty: ${item['quantity']}",
                                  style: GoogleFonts.outfit(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Date: ${DateTime.parse(order!['created_at']).toLocal().toString().substring(0, 16)}',
                                  style: GoogleFonts.outfit(color: DesignColors.textSecondary, fontSize: 12),
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: DesignColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Ship to: ${order['shipping_address'] ?? 'No address provided'}',
                                        style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF111111)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Revenue", style: GoogleFonts.outfit(color: const Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w600)),
                              Text(
                                "\$${(item['quantity'] * item['price_at_time_of_order']).toStringAsFixed(2)}",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF111111)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    
                    // Customer Details Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.delivery_dining, size: 18, color: DesignColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                "Delivery Information",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF111111)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.location_on, order['shipping_address'] ?? 'No address', const Color(0xFF111111)),
                          _buildInfoRow(
                            Icons.access_time,
                            order['created_at'] != null 
                                ? timeago.format(DateTime.parse(order['created_at']))
                                : 'Recently',
                            const Color(0xFF888888),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status'] ?? 'pending'),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (order['status'] ?? 'pending').toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w600))),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF666666)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
