import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/models/order_model.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/utils/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int userId; // Needs userId to fetch orders
  const OrderHistoryScreen({super.key, required this.userId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await ApiService.getOrdersByUser(widget.userId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order History', style: AppTextStyles.headlineSmall.copyWith(color: theme.textTheme.bodyMedium?.color)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage', style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 80, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No past orders', style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey)),
                        ],
                      ).animate().fadeIn().scale(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                              ),
                              title: Text(
                                'Order #${order.id}',
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Date: ${order.creationAt.split('T')[0]}',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: const Divider(height: 1),
                                ),
                                ...order.products.map((product) => ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.images.isNotEmpty ? product.images.first : '',
                                      width: 50, height: 50, fit: BoxFit.cover,
                                      errorBuilder: (_,__,___) => Container(
                                        width: 50, height: 50, color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(color: theme.textTheme.bodyMedium?.color),
                                  ),
                                  trailing: Text(
                                    '\$${product.price}',
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                )).toList(),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Items: ${order.products.length}', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                                      // Calculate total if needed, or just show items
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
    );
  }
}
