import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'clothes_Screen.dart';
import 'profile_Page.dart';
import 'search.dart';
import 'favorites_Page.dart';
import 'cart_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username, required bool isAdmin})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _HomeContent(username: widget.username), // Home Content
      const SearchScreen(), // Search Screen
      FavoritesPage(), // Favorites Page
      const CartScreen(cart: []),
      ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String username;

  String generateImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x200'; // ✅ Placeholder if image is missing
    }
    List<String> parts = imagePath.split('/');
    String filename = parts.last;
    String finalUrl = 'http://10.0.2.2:6000/api/promotions/get-image/$filename';

    print("Generated URL: $finalUrl");
    return finalUrl;
  }

  const _HomeContent({Key? key, required this.username}) : super(key: key);

  // Fetch carousel data from the API
  Future<List<Map<String, dynamic>>> fetchCarouselItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:6000/api/promotions/promotions-getAll'),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          List<dynamic> data = jsonData['data']; // ✅ Extract 'data' correctly

          return data.map((item) {
            return {
              'image': item['Image'] ?? '', // ✅ Use lowercase 'image'
              'title': item['title'] ?? 'No Title',
            };
          }).toList();
        } else {
          throw Exception('Invalid response format: Missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to load carousel data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching carousel data: $e");
      throw Exception('Failed to load carousel data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section with Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $username ', // Replace with dynamic username
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Get popular fashion from everywhere',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Icons for Notification and Shopping Cart
              Row(
                children: [
                  IconButton(
                    color: Colors.brown,
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Notification logic
                    },
                  ),
                  IconButton(
                    color: Colors.brown,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {
                      // Shopping cart logic
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar with Voice Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      iconColor: Colors.brown),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.black),
                  onPressed: () {
                    // Add voice search logic
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTextOption('RECOMMEND'),
                  _buildTextOption('NEW'),
                  _buildTextOption('COLLECTION'),
                  _buildTextOption('POPULAR'),
                ],
              )),
          const SizedBox(height: 16),

          // Carousel Section
          _buildCarousel(),

          // New Arrival Section
          _buildNewArrivals(),
          const SizedBox(height: 16),

          // Categories Section
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Product Grid Section
          _buildProductGrid(context),
        ],
      ),
    );
  }

  // Function to build carousel widget
  Widget _buildCarousel() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCarouselItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final carouselItems = snapshot.data!;
          return CarouselSlider.builder(
            itemCount: carouselItems.length,
            itemBuilder: (context, index, realIndex) {
              final item = carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        generateImageUrl(item[
                            'image']), // Ensure the correct key is used here
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 20,
                        top: 70,
                        left: 20,
                        child: Text(
                          item['title'], // Ensure the correct key is used here
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              aspectRatio: 16 / 9,
            ),
          );
        }
      },
    );
  }

  Widget _buildNewArrivals() {
    final newArrivals = [
      {
        'name': 'Wilcox',
        'type': 'Dresses',
        'price': '\$85.88',
        'image': 'assets/overcost/o1-min.jpeg',
      },
      {
        'name': 'Karen Willis',
        'type': 'Dresses',
        'price': '\$142',
        'image': 'assets/overcost/o1-min.jpeg',
      },
      {
        'name': 'Karen Willis',
        'type': 'Dresses',
        'price': '\$142',
        'image': 'assets/overcost/o1-min.jpeg',
      },
      {
        'name': 'Karen Willis',
        'type': 'Dresses',
        'price': '\$142',
        'image': 'assets/overcost/o1-min.jpeg',
      },
      {
        'name': 'Karen Willis',
        'type': 'Dresses',
        'price': '\$142',
        'image': 'assets/overcost/o1-min.jpeg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Arrival',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ListView Section
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: newArrivals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = newArrivals[index];
              return SizedBox(
                width: 180,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity, // Match card width
                            height: 150, // Consistent height
                          ),
                        ),
                      ),
                      // Details Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Product Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['type']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\₹${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            // Shopping Bag Icon
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // Add to cart logic
                                },
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return FutureBuilder(
      future: fetchCategories(), // Fetching categories data
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load categories'));
        } else {
          final categories = snapshot.data ?? [];
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothesSectionPage(
                        category: category['name'],
                        documentId: category['_id'],
                        collectionName: category['name'].toLowerCase(),
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(getImageUrl(category['images'])),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      category['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:6000/api/category/fetch-all-categories'),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          return jsonData['data']; // ✅ Correctly extract "data" field
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception('Failed to load categories');
    }
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150'; // ✅ Placeholder image for safety
    }
    List<String> splitPath = imagePath.split('/');
    String imageName = splitPath.last;
    return 'http://10.0.2.2:6000/api/category/fetch-category-image/$imageName';
  }

  Widget _buildTextOption(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}
