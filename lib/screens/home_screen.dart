import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/models/category_model.dart';
import 'package:new_project/models/product_model.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/utils/app_theme.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, weight: 600),
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
        final category =
            _categories.firstWhere((c) => c.id == categoryId, orElse: () => _categories[0]);
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: false,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: Text('Discover', style: AppTextStyles.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: AppColors.textPrimary,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                _buildBanner(),
                const SizedBox(height: 24),
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Categories', style: AppTextStyles.headlineSmall),
                ).animate().fadeIn(delay: 200.ms).moveX(begin: -20, end: 0),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length + 1, // +1 for "All"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryChip(
                          category: Category(
                              id: -1, name: 'All', image: '', creationAt: '', updatedAt: ''),
                          isSelected: _selectedCategoryId == -1,
                          onTap: () => _filterByCategory(-1),
                        ).animate().fadeIn(delay: (100 + index * 50).ms);
                      }
                      final category = _categories[index - 1];
                      return CategoryChip(
                        category: category,
                        isSelected: _selectedCategoryId == category.id,
                        onTap: () => _filterByCategory(category.id),
                      ).animate().fadeIn(delay: (100 + index * 50).ms);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Popular Products', style: AppTextStyles.headlineSmall),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Grid
          if (_isLoading && _products.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            SliverFillRemaining(child: Center(child: Text('Error: $_errorMessage')))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: _products[index])
                      .animate()
                      .fadeIn(delay: (50 * (index % 6)).ms)
                      .scale(curve: Curves.easeOut),
                  childCount: _products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Adjusted for taller cards
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final banners = [
      {
        'title': 'Winter Exclusive',
        'subtitle': 'Up to 50% OFF',
        'tag': 'New Collection',
        'color': AppColors.primary,
        'image': '', // Placeholder for now or use gradient
      },
      {
        'title': 'Summer Vibes',
        'subtitle': 'New Arrivals',
        'tag': 'Trending',
        'color': const Color(0xFF2E7D32), // Green
        'image': '',
      },
      {
        'title': 'Premium Shoes',
        'subtitle': 'Flat 30% Discount',
        'tag': 'Hot Deal',
        'color': const Color(0xFFC62828), // Red
        'image': '',
      },
    ];

    return SizedBox(
      height: 200, // Increased height slightly for PageView interactions
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          padEnds: false, // Start from left
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return Container(
              margin: const EdgeInsets.only(right: 12, top: 4, bottom: 12), // Spacing between cards
              decoration: BoxDecoration(
                color: banner['color'] as Color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (banner['color'] as Color).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Decoration
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      radius: 90,
                    ),
                  ),
                  Positioned(
                    top: -20,
                    left: -20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      radius: 60,
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            banner['tag'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          banner['title'] as String,
                          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner['subtitle'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(curve: Curves.easeOutBack);
          },
        ),
      ),
    );
  }
}
