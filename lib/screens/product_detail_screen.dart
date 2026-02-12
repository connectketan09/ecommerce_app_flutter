import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/models/product_model.dart';
import 'package:new_project/services/cart_service.dart';
import 'package:new_project/screens/cart_screen.dart';
import 'package:new_project/utils/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent, // Avoid tint on scroll
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ).animate().scale(delay: 200.ms),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const CartScreen())),
                  ),
                ),
              ).animate().scale(delay: 300.ms),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: product.id, // Assuming id is unique enough or use product.images.first
                child: Image.network(
                  (product.images.isNotEmpty)
                      ? product.images.first
                      : 'https://placehold.co/400',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    child: Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: isDark ? Colors.grey : Colors.grey)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppTextStyles.headlineMedium.copyWith(height: 1.2, color: theme.textTheme.bodyMedium?.color),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '\$${product.price}',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ).animate().fadeIn().moveY(begin: 20, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      product.category.name.toUpperCase(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: AppTextStyles.headlineSmall.copyWith(color: theme.textTheme.bodyMedium?.color),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 32),
                    // Visual Selectors
                    Row(
                      children: [
                        Expanded(child: _buildSelector(context, 'Size', ['S', 'M', 'L', 'XL'])),
                        Expanded(child: _buildSelector(context, 'Color', ['Black', 'White', 'Blue'])),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 40), // Bottom padding
                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              CartService().add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to Cart!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, color: Colors.white), // Keep white for contrast on primary button
                SizedBox(width: 12),
                Text('Add to Cart'),
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, delay: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSelector(BuildContext context, String title, List<String> options) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: options.map((option) => Container(
            padding: const EdgeInsets.all(8), // Simplified selector
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(option, style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.grey[300] : null)),
          )).toList(),
        )
      ],
    );
  }
}
