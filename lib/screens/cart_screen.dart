import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/services/cart_service.dart';
import 'package:new_project/utils/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: AppTextStyles.headlineSmall.copyWith(color: theme.textTheme.bodyMedium?.color)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: isDark ? Colors.grey[700] : Colors.grey),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey)),
                ],
              ).animate().fadeIn().scale(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.05),
                               blurRadius: 10,
                               offset: const Offset(0, 4),
                             )
                          ]
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.images.isNotEmpty ? product.images.first : 'https://placehold.co/50',
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                          title: Text(product.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)),
                          subtitle: Text('\$${product.price}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => cart.remove(product),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideX();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.headlineSmall.copyWith(color: theme.textTheme.bodyMedium?.color)),
                          Text('\$${cart.total.toStringAsFixed(2)}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            cart.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Order placed successfully!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutBack),
              ],
            ),
    );
  }
}
