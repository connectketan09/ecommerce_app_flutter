import 'package:flutter/material.dart';
import 'package:new_project/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Listen to changes manually since we aren't using Provider
  // We can attach a listener in initState
  
  @override
  void initState() {
    super.initState();
    CartService().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return ListTile(
                        leading: Image.network(
                          product.images.isNotEmpty ? product.images.first : 'https://placehold.co/50',
                          width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                        ),
                        title: Text(product.title),
                        subtitle: Text('\$${product.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => cart.remove(product),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            cart.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order placed successfully!')),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
