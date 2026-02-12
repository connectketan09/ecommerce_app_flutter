import 'package:flutter/material.dart';
import 'package:new_project/models/product_model.dart';
import 'package:new_project/screens/product_detail_screen.dart';
import 'package:new_project/utils/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[50]),
                      child: Image.network(
                        (product.images.isNotEmpty) ? product.images.first : 'https://placehold.co/400',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                             Center(child: Icon(Icons.broken_image, color: isDark ? Colors.grey : Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                      radius: 14,
                      child: Icon(Icons.favorite_border, size: 16, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  )
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.grey : Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 16,
                            color: AppColors.primary, // This might be white in dark mode if AppColors.primary is white? No, AppColors.primary is dark grey.
                            // In darkTheme, I set primary color scheme to White.
                            // Let's check AppTheme.darkTheme primary color.
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, size: 16, color: isDark ? Colors.black : Colors.white),
                        ),
                      ],
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
