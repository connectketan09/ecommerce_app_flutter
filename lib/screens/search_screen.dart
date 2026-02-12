import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/models/product_model.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/utils/app_theme.dart';
import 'package:new_project/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _showFilters = false;

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Product> results;

      // If price filter is active, we might want to use that.
      // But the API splits these. We can combine client side or assume one action.
      // Requirements:
      // Search by title: GET .../?title=Generic
      // Filter by price range: GET .../?price_min=900&price_max=1000

      // Logic update: Ensure we use the correct endpoints and types.
      // Platzi fake store often expects Integers for price.
      // We will perform client-side filtering if we have search text,
      // because the API doesn't support searching AND filtering in one request easily in all versions.
      // If only price range, use API.

      int pMin = _priceRange.start.round();
      int pMax = _priceRange.end.round();

      if (_searchController.text.isNotEmpty) {
        // Fetch by search, then filter locally
        var searchResults = await ApiService.searchProducts(_searchController.text);
        if (_showFilters) {
          results = searchResults.where((p) => p.price >= pMin && p.price <= pMax).toList();
        } else {
          results = searchResults;
        }
      } else if (_showFilters) {
        // Only price filter
        results = await ApiService.filterByPriceRange(pMin.toDouble(), pMax.toDouble());
      } else {
        results = [];
      }

      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Search',
            style: AppTextStyles.headlineSmall.copyWith(color: theme.textTheme.bodyMedium?.color)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(_showFilters ? 160 : 80), // Increased height for better spacing
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          prefixIcon: Icon(Icons.search,
                              color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardTheme.color,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _showFilters ? AppColors.primary : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _showFilters ? Icons.filter_list_off : Icons.filter_list,
                          color:
                              _showFilters ? Colors.white : (isDark ? Colors.white : Colors.black),
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_showFilters)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Price Range:',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: theme.textTheme.bodyMedium?.color)),
                          Text(
                            '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[200],
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                        ),
                        child: RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '\$${_priceRange.start.round()}',
                            '\$${_priceRange.end.round()}',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                          onChangeEnd: (_) => _performSearch(),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text('Error: $_errorMessage',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No results found',
                              style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65, // Fixed reported overflow issue
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _products[index]);
                      },
                    ),
    );
  }
}
