import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final Map<String, dynamic> product;
  final String weight;
  int quantity;

  CartItem({required this.product, required this.weight, this.quantity = 1});

  String get cartKey => '${product['id']}_$weight';
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Map<String, dynamic> product, String weight, int quantity) {
    final cartKey = '${product['id']}_$weight';
    final existingItemIndex = state.indexWhere((item) => item.cartKey == cartKey);

    if (existingItemIndex != -1) {
      final existingItem = state[existingItemIndex];
      updateQuantity(cartKey, existingItem.quantity + quantity);
    } else {
      state = [...state, CartItem(product: product, weight: weight, quantity: quantity)];
    }
  }

  void removeFromCart(String cartKey) {
    state = state.where((item) => item.cartKey != cartKey).toList();
  }

  void incrementQuantity(String cartKey) {
    state = [
      for (final item in state)
        if (item.cartKey == cartKey)
          CartItem(product: item.product, weight: item.weight, quantity: item.quantity + 1)
        else
          item
    ];
  }

  void decrementQuantity(String cartKey) {
    state = [
      for (final item in state)
        if (item.cartKey == cartKey)
          if (item.quantity > 1)
            CartItem(product: item.product, weight: item.weight, quantity: item.quantity - 1)
          else
            item
        else
          item
    ];
  }

  void updateQuantity(String cartKey, int newQuantity) {
    if (newQuantity < 1) {
      removeFromCart(cartKey);
      return;
    }
    state = [
      for (final item in state)
        if (item.cartKey == cartKey)
          CartItem(product: item.product, weight: item.weight, quantity: newQuantity)
        else
          item
    ];
  }

  double get totalPrice {
    return state.fold(0, (total, item) {
      final multiplier = item.weight == '1kg' ? 2 : 1;
      return total + (item.product['price'] * multiplier * item.quantity);
    });
  }

  Future<void> checkout(SupabaseClient supabase, String shippingAddress) async {
    if (state.isEmpty) return;
    
    // 1. Get User
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 2. Create Order
    final total = totalPrice;
    final orderResponse = await supabase.from('orders').insert({
      'user_id': user.id,
      'total_amount': total,
      'status': 'pending',
      'shipping_address': shippingAddress,
    }).select().single();

    final orderId = orderResponse['id'];

    // 3. Create Order Items
    final itemsData = state.map((item) {
      final multiplier = item.weight == '1kg' ? 2 : 1;
      return {
        'order_id': orderId,
        'product_id': item.product['id'], // Integer ID retained
        'farmer_id': item.product['farmer_id'],
        'quantity': item.quantity,
        'price_at_time_of_order': item.product['price'] * multiplier,
      };
    }).toList();

    await supabase.from('order_items').insert(itemsData);

    // 4. Clear Cart
    state = [];
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
