import 'package:flutter/material.dart';
import 'package:new_project/models/order_model.dart';
import 'package:new_project/services/api_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _orders.isEmpty
                  ? const Center(child: Text('No past orders'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return ExpansionTile(
                          title: Text('Order #${order.id}'),
                          subtitle: Text('Date: ${order.creationAt.split('T')[0]}'),
                          children: order.products.map((product) => ListTile(
                            leading: Image.network(
                              product.images.isNotEmpty ? product.images.first : '',
                              width: 40, height: 40, fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                            ),
                            title: Text(product.title),
                            trailing: Text('\$${product.price}'),
                          )).toList(),
                        );
                      },
                    ),
    );
  }
}
