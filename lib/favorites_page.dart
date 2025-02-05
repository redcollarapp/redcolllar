import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return DefaultTabController(
      length: 2, // Two tabs: All Products and Favorites
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Favorites',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.brown,
            indicatorWeight: 3,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All Products'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllProductsView(context), // All Products Tab
            _buildFavoritesView(favoritesProvider), // Favorites Tab
          ],
        ),
      ),
    );
  }

  /// All Products Tab
  Widget _buildAllProductsView(BuildContext context) {
    // Sample product data
    final sampleProducts = [
      {
        'name': 'T-Shirts',
        'docId': 'biRhapgdIk6LdYEcoA6A',
        'image': 'assets/compressedimages/cclothes/t6.jpeg',
      },
      {
        'name': 'Hoodies',
        'docId': '0XT0FaUS8sdxQj7VYnIJ',
        'image': 'assets/compressedimages/choodies/h1.jpeg',
      },
      {
        'name': 'Jeans',
        'docId': '7iUIOTG60q64EmQqAmdV',
        'image': 'assets/compressedimages/cjeans/j1.jpeg',
      },
      {
        'name': 'Shoes',
        'docId': 'Op3RND16TFucJc9YNy7S',
        'image': 'assets/compressedimages/cshoes/s1.jpeg',
      },
    ];

    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemCount: sampleProducts.length,
      itemBuilder: (context, index) {
        final item = sampleProducts[index];
        final isFavorite = favoritesProvider.isFavorite(item['docId']!);

        return _buildProductCard(context, item, isFavorite);
      },
    );
  }

  /// Favorites Tab
  Widget _buildFavoritesView(FavoritesProvider favoritesProvider) {
    final favorites = favoritesProvider.favorites;

    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorites yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return _buildProductCard(context, item, true);
      },
    );
  }

  /// Product Card Widget
  Widget _buildProductCard(
      BuildContext context, Map<String, dynamic> item, bool isFavorite) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Stack(
        children: [
          Image.asset(
            item['image'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              item['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              color: isFavorite ? Colors.red : Colors.grey,
              onPressed: () {
                if (isFavorite) {
                  favoritesProvider.removeFavorite(item['docId']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} removed from favorites!'),
                    ),
                  );
                } else {
                  favoritesProvider.addFavorite(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} added to favorites!'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
