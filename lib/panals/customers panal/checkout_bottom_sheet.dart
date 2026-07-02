import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final CartProvider cart;
  const CheckoutBottomSheet({super.key, required this.cart});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      // 1. Generate Order ID
      String orderId =
          'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // 2. Save Order to Firebase
      // Using .doc(orderId).set() is often faster and cleaner than .add()
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set({
            'orderId': orderId,
            'customerName': user?.displayName ?? user?.email ?? 'Guest',
            'customerEmail': user?.email ?? 'Unknown',
            'address': _addressController.text.trim(),
            'phone': _phoneController.text.trim(),
            'paymentMethod': _paymentMethod,
            'total': widget.cart.totalAmount,
            'status': 'Pending',
            'timestamp': FieldValue.serverTimestamp(),
            'items': widget.cart.items.values.map((item) {
              return {
                'name': item.food.name,
                'quantity': item.quantity,
                'price': item.food.price,
                'variations': item.selectedVariations
                    .map((v) => v.name)
                    .toList(),
              };
            }).toList(),
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // Safety: If internet is too slow, stop spinner after 10s
              throw "Connection timed out. Check your internet.";
            },
          );

      // 3. Clear Cart
      widget.cart.clearCart();

      // 4. Close Sheet and Return Order ID to Cart Screen
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, orderId); // <--- SENDING ID BACK
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Checkout Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Delivery Address",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: "Enter full delivery address",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      validator: (v) =>
                          v!.isEmpty ? "Address is required" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Phone Number",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "03XX-XXXXXXX",
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? "Phone number is required" : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment Method",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: "Cash on Delivery",
                      value: "Cash on Delivery",
                      icon: Icons.money,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: "Pay Online on Delivery",
                      subtitle: "(Card/Transfer)",
                      value: "Online on Delivery",
                      icon: Icons.credit_card,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confirm Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF6A1B9A)),
          ],
        ),
      ),
    );
  }
}
