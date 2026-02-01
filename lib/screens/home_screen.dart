import 'package:flutter/material.dart';
import 'package:new_project/models/category_model.dart';
import 'package:new_project/models/product_model.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/widgets/category_chip.dart';
import 'package:new_project/widgets/product_card.dart';
import 'package:new_project/screens/search_screen.dart';
import 'package:new_project/screens/profile_screen.dart';
import 'package:new_project/screens/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? accessToken;
  const HomeScreen({super.key, this.accessToken});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),
      const SearchScreen(),
      const CartScreen(),
      ProfileScreen(accessToken: widget.accessToken),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search, ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryId = -1; // -1 for "All"

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoriesData = await ApiService.getCategories();
      final productsData = await ApiService.getProducts();

      if (mounted) {
        setState(() {
          _categories = categoriesData;
          _products = productsData;
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

  Future<void> _filterByCategory(int categoryId) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
    });

    try {
      List<Product> products;
      if (categoryId == -1) {
        products = await ApiService.getProducts();
      } else {
        final category = _categories.firstWhere((c) => c.id == categoryId, orElse: () => _categories[0]);
         products = await ApiService.getProductsByCategory(category.name.toLowerCase());
      }
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
       if (mounted) {
        setState(() {
           _isLoading = false; 
           _products = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [], 
      ),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Categories
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length + 1, // +1 for "All"
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                category: Category(id: -1, name: 'All', image: '', creationAt: '', updatedAt: ''),
                                isSelected: _selectedCategoryId == -1,
                                onTap: () => _filterByCategory(-1),
                              );
                            }
                            final category = _categories[index - 1];
                            return CategoryChip(
                              category: category,
                              isSelected: _selectedCategoryId == category.id,
                              onTap: () => _filterByCategory(category.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Products Grid
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: _products[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
