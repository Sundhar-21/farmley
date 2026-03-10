import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/supabase_service.dart';

final productsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('products')
      .select('*, categories(*)')
      .eq('is_available', true)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final recommendedProductsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  // Get all available products first
  final allProducts = await ref.watch(productsProvider.future);
  if (allProducts.isEmpty) return [];

  if (user == null) {
    // If not logged in, just return some recent products
    return allProducts.take(8).toList();
  }

  try {
    // Get recently ordered product IDs
    final orderedItems = await supabase
        .from('order_items')
        .select('product_id')
        .limit(20);
    
    final orderedIds = List<int>.from(orderedItems.map((item) => item['product_id']));
    
    // Sort products: recently ordered first, then others
    final recommended = <Map<String, dynamic>>[];
    final seenIds = <int>{};

    // Add ordered products first (preserving order of recency if possible)
    for (final id in orderedIds.reversed) {
      if (seenIds.contains(id)) continue;
      final product = allProducts.firstWhere((p) => p['id'] == id, orElse: () => {});
      if (product.isNotEmpty) {
        recommended.add(product);
        seenIds.add(id);
      }
    }

    // Fill remaining with other products
    for (final product in allProducts) {
      if (!seenIds.contains(product['id'])) {
        recommended.add(product);
        seenIds.add(product['id']);
      }
      if (recommended.length >= 10) break;
    }

    return recommended;
  } catch (e) {
    // Fallback to recent products on error
    return allProducts.take(8).toList();
  }
});

final categoriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('categories')
      .select()
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});
