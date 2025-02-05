import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'favorites_provider.dart';
import 'cart_Screen.dart';
import 'product_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String selectedImage;
  late String selectedColor;
  late String selectedSize;
  bool isLoading = false;
  bool isAddedToBasket = false;

  @override
  void initState() {
    super.initState();
    List<dynamic> images = widget.product['images'] ?? [];
    selectedImage = images.isNotEmpty ? getImageUrl(images.first) : '';
    selectedColor = widget.product['color']?.first ?? '';
    selectedSize = widget.product['sizes']?.first ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = widget.product;

    List<String> images = (product['images'] as List<dynamic>)
        .map((e) => getImageUrl(e))
        .toList();
    List<String> colors = List<String>.from(product['color'] ?? []);
    List<String> sizes = List<String>.from(product['sizes'] ?? []);

    String productName = product['name'] ?? 'Unknown Product';
    String productDocId = product['_id'] ?? '';
    double originalPrice = (product['original_price'] as num).toDouble();
    double discountPercentage =
        (product['discount_percentage'] as num).toDouble();
    double discountedPrice =
        originalPrice - (originalPrice * discountPercentage / 100);

    bool isFavorite = favoritesProvider.isFavorite(productDocId);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          children: [
            // Image Gallery (Left) & Main Image (Right)
            Expanded(
              child: Row(
                children: [
                  // Left: Image Thumbnails
                  SizedBox(
                    width: 100,
                    child: ListView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        String imageUrl = images[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = imageUrl;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedImage == imageUrl
                                    ? Colors.brown
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right: Main Product Image
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: selectedImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Product Description
                    Text(
                      product['description'] ?? 'No description available.',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),

                    const SizedBox(height: 16),

                    // Color Selection
                    _buildColorSelection(colors),

                    const SizedBox(height: 16),

                    // Size Selection
                    _buildSizeSelection(sizes),

                    const SizedBox(height: 16),

                    // Delivery Option
                    Text(
                      "Delivery Option: ${product['deliveryOption'] ?? 'Standard'}",
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite & Cart Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Add to Favorites Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.brown,
                    size: 32,
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      favoritesProvider.removeFavorite(productDocId);
                    } else {
                      favoritesProvider.addFavorite(product);
                    }
                    setState(() {});
                  },
                ),

                // Add to Cart Button
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          await _addToBasket(
                            product,
                            selectedColor,
                            selectedSize,
                          );
                          setState(() {
                            isLoading = false;
                            isAddedToBasket = true;
                          });
                        },
                  child: Text(
                    isLoading ? 'Adding...' : 'Add to Cart',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            // View Bag & Checkout Buttons
            if (isAddedToBasket)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(cart: []),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    child: const Text("View Bag",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(),
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    child: const Text("Checkout",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelection(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: colors.map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: selectedColor == color ? Colors.brown.withOpacity(0.2) : null,
        ),
        child: Text(
          color, // Just display the color name (no conversion to Color)
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSizeSelection(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: sizes.map((size) => _buildSizeOption(size)).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: selectedSize == size ? Colors.brown.withOpacity(0.2) : null,
        ),
        child: Text(
          size,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String getImageUrl(String imagePath) {
    return 'http://10.0.2.2:6000/api/products/fetch-product-image/${imagePath.split('/').last}';
  }

  Future<void> _addToBasket(
      Map<String, dynamic> product, String color, String size) async {
    final url = Uri.parse('http://10.0.2.2:6000/api/cart/add');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product': product,
          'color': color,
          'size': size,
        }));
    if (response.statusCode == 200) {
      // Successfully added to basket
    } else {
      // Error handling
    }
  }

  // CheckoutScreen declaration
  CheckoutScreen() {
    return Scaffold(
      body: Center(
        child: Text("Checkout Screen"),
      ),
    );
  }
}
