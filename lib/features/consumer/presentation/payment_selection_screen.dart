import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/presentation/order_success_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class PaymentSelectionScreen extends ConsumerStatefulWidget {
  final double totalAmount;
  final String shippingAddress;

  const PaymentSelectionScreen({
    super.key,
    required this.totalAmount,
    required this.shippingAddress,
  });

  @override
  ConsumerState<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends ConsumerState<PaymentSelectionScreen> {
  late Razorpay _razorpay;
  String _selectedPaymentMethod = 'cod';

  final List<Map<String, dynamic>> _paymentOptions = [
    {'id': 'cod', 'name': 'Cash on Delivery', 'icon': Icons.money_rounded},
    {'id': 'netbanking', 'name': 'Netbanking', 'icon': Icons.account_balance_rounded, 'razorpayMethod': 'netbanking'},
    {'id': 'upi', 'name': 'UPI', 'icon': Icons.qr_code_scanner_rounded, 'razorpayMethod': 'upi'},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card_rounded, 'razorpayMethod': 'card'},
    {'id': 'gpay', 'name': 'Google Pay', 'icon': Icons.g_mobiledata_rounded, 'razorpayMethod': 'upi'},
    {'id': 'phonepe', 'name': 'PhonePe', 'icon': Icons.phone_android_rounded, 'razorpayMethod': 'upi'},
    {'id': 'paytm', 'name': 'Paytm', 'icon': Icons.account_balance_wallet_rounded, 'razorpayMethod': 'wallet'},
  ];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _placeOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message ?? "Unknown error"}'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet Selected: ${response.walletName ?? "Unknown"}'), backgroundColor: Colors.blue),
      );
    }
  }

  Future<void> _placeOrder() async {
    try {
      final supabase = ref.read(supabaseProvider);
      await ref.read(cartProvider.notifier).checkout(supabase, widget.shippingAddress);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (Route<dynamic> route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _processPayment() {
    if (_selectedPaymentMethod == 'cod') {
      _placeOrder();
      return;
    }

    final selectedOption = _paymentOptions.firstWhere((opt) => opt['id'] == _selectedPaymentMethod);
    final razorpayMethod = selectedOption['razorpayMethod'];

    final amountInPaise = (widget.totalAmount * 100).toInt();
    final profileData = ref.read(userProfileProvider).value;
    final String contact = profileData?['phone'] ?? '';
    final String email = profileData?['email'] ?? '';

    final prefill = <String, String>{};
    if (contact.isNotEmpty) prefill['contact'] = contact;
    if (email.isNotEmpty) prefill['email'] = email;

    var options = <String, dynamic>{
      'key': 'rzp_test_SBy7RqVhpX270G',
      'amount': amountInPaise,
      'name': 'FarmConnect',
      'description': 'FarmConnect Secure Checkout',
    };

    if (prefill.isNotEmpty) {
      options['prefill'] = prefill;
    }

    try {
      if (kIsWeb) {
        // Mock success for Web platform since Razorpay SDK does not natively support Web initialization the same way
        // Alternatively, you would use Razorpay Web hooks specifically or dart:js. Let's redirect to success directly 
        // for Chrome views as an MVP placeholder for Web payments right now.
        _handlePaymentSuccess(PaymentSuccessResponse('WEB_PAYMENT_MOCK_SUCCESS', 'MOCK_ORDER_ID', 'MOCK_SIGNATURE', null));
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      debugPrint('Razorpay execution error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open Razorpay: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Payment', style: GoogleFonts.outfit(color: DesignColors.textPrimary, fontSize: isDesktop ? 22 : 28, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(DesignSpacing.l),
                itemCount: _paymentOptions.length,
                separatorBuilder: (context, index) => const SizedBox(height: DesignSpacing.m),
                itemBuilder: (context, index) {
                  final option = _paymentOptions[index];
                  final isSelected = _selectedPaymentMethod == option['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = option['id'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(DesignSpacing.m),
                      decoration: BoxDecoration(
                        color: isSelected ? DesignColors.primary.withOpacity(0.1) : Colors.white,
                        border: Border.all(
                          color: isSelected ? DesignColors.primary : DesignColors.surfaceVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(DesignRadius.l),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DesignSpacing.s),
                            decoration: BoxDecoration(
                              color: isSelected ? DesignColors.primary.withOpacity(0.2) : DesignColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              option['icon'],
                              color: isSelected ? DesignColors.primary : DesignColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: DesignSpacing.m),
                          Expanded(
                            child: Text(
                              option['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? DesignColors.textPrimary : DesignColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: DesignColors.primary),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(DesignSpacing.l),
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
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 16)),
                        Text('\$${widget.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: DesignSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignRadius.l),
                          ),
                        ),
                        child: Text(
                          _selectedPaymentMethod == 'cod' ? 'Place Order (COD)' : 'Proceed to Pay',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }
}

