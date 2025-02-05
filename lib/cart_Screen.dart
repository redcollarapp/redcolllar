import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'check_Screen.dart'; // CheckoutScreen file

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key, required List cart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cart = productProvider.cart;

    // Calculate prices
    double subtotal = cart.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    double discount = subtotal * 0.1; // 10% Discount
    double total = subtotal - discount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.brown,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cart.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _buildCartItem(context, item, productProvider);
                    },
                  ),
                ),
                // Summary Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 24, thickness: 1),
                      _buildPriceRow(
                          'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                      _buildPriceRow(
                          'Discount', '-₹${discount.toStringAsFixed(2)}'),
                      _buildPriceRow('Total', '₹${total.toStringAsFixed(2)}',
                          isBold: true),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                cart: cart,
                                subtotal: subtotal,
                                discount: discount,
                                total: total,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.brown,
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item,
      ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _getImageWidget(item['image']),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item['name'] ?? 'Unnamed Item',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Product Category
                    Text(
                      item['category'] ?? 'Category',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price and Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item['price']} x ${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        // Quantity Increment/Decrement
                        Row(
                          children: [
                            // Decrement Button
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.grey),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  provider.updateCartQuantity(
                                      item, item['quantity'] - 1);
                                } else {
                                  provider.removeFromCart(item);
                                }
                              },
                            ),
                            Text(
                              '${item['quantity']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            // Increment Button
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.brown),
                              onPressed: () {
                                provider.updateCartQuantity(
                                    item, item['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.brown),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some products to the cart.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/default_image.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    // Check if the image is an asset or a network URL
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    // For network images
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default_image.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
