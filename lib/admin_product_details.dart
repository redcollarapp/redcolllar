import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/product_Screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'favorites_page.dart';
// ignore: unused_import
import 'product_details.dart';

class AdminProductDetailsPage extends StatefulWidget {
  final String category;
  final String documentId;
  final String collectionName;
  final bool isAdmin; // Flag to show admin functionalities

  const AdminProductDetailsPage({
    Key? key,
    required this.category,
    required this.documentId,
    required this.collectionName,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<AdminProductDetailsPage> createState() =>
      _AdminProductDetailsPageState();
}

class _AdminProductDetailsPageState extends State<AdminProductDetailsPage> {
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    print("AdminProductDetailsPage initialized with:");
    print("Category: ${widget.category}");
    print("DocumentId: ${widget.documentId}");
    print("CollectionName: ${widget.collectionName}");
    print("IsAdmin: ${widget.isAdmin}");
  }

  // Utility method to show toast messages
  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
    );
  }

  // Toggle favorite status of an item
  void _toggleFavorite(Map<String, dynamic> item) {
    final isFavorite = favorites.any((fav) => fav['docId'] == item['docId']);
    setState(() {
      if (isFavorite) {
        favorites.removeWhere((fav) => fav['docId'] == item['docId']);
        _showToast("${item['name']} removed from favorites!", Colors.red);
      } else {
        favorites.add(item);
        _showToast("${item['name']} added to favorites!", Colors.orange);
      }
    });
  }

  // Show a dialog to add a new product
  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final imageController = TextEditingController();
    final priceController = TextEditingController();
    final sizeController = TextEditingController();
    final quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name'),
                const SizedBox(height: 8),
                _buildTextField(imageController, 'Image URL or Asset'),
                const SizedBox(height: 8),
                _buildTextField(priceController, 'Price',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField(sizeController, 'Sizes (comma separated)'),
                const SizedBox(height: 8),
                _buildTextField(quantityController, 'Quantity',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate the necessary fields
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  print("Adding new product...");
                  final newProduct = {
                    'name': nameController.text.trim(),
                    'docId': DateTime.now().millisecondsSinceEpoch.toString(),
                    'image': imageController.text.trim().isEmpty
                        ? 'assets/default-product.jpeg'
                        : imageController.text.trim(),
                    'price': double.tryParse(priceController.text.trim()) ?? 0,
                    'sizes': sizeController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList(),
                    'quantity':
                        int.tryParse(quantityController.text.trim()) ?? 0,
                  };

                  try {
                    final docRef = FirebaseFirestore.instance
                        .collection(widget.collectionName)
                        .doc(widget.documentId);

                    final doc = await docRef.get();
                    if (!doc.exists) {
                      print("Document does not exist. Cannot add product.");
                      _showToast("Document not found.", Colors.red);
                      Navigator.pop(context);
                      return;
                    }

                    final data = doc.data() as Map<String, dynamic>;
                    final items =
                        List<Map<String, dynamic>>.from(data['items'] ?? []);
                    items.add(newProduct);

                    await docRef.update({'items': items});
                    _showToast("Product added successfully!", Colors.blue);
                  } catch (e) {
                    print("Error adding product: $e");
                    _showToast("Error adding product.", Colors.red);
                  }

                  Navigator.pop(context);
                } else {
                  _showToast('Please fill in all required fields.', Colors.red);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete a product by removing it from the items array
  Future<void> _deleteProduct(Map<String, dynamic> item) async {
    print("Deleting product with docId: ${item['docId']}");
    try {
      final docRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.documentId);

      final doc = await docRef.get();
      if (!doc.exists) {
        _showToast("Document not found.", Colors.red);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final initialLength = items.length;
      items.removeWhere((prod) => prod['docId'] == item['docId']);

      if (items.length < initialLength) {
        await docRef.update({'items': items});
        _showToast("Product deleted successfully!", Colors.red);
      } else {
        _showToast("Product not found. Deletion failed.", Colors.red);
      }
    } catch (e) {
      print("Error deleting product: $e");
      _showToast("Error deleting product.", Colors.red);
    }
  }

  // Show a dialog to update an existing product
  Future<void> _showUpdateProductDialog(Map<String, dynamic> item) async {
    print("Attempting to update product with docId: ${item['docId']}");
    final nameController = TextEditingController(text: item['name'] ?? '');
    final imageController = TextEditingController(text: item['image'] ?? '');
    final priceController = TextEditingController(
        text: item['price'] != null ? item['price'].toString() : '');
    final sizeController = TextEditingController(
        text: item['sizes'] != null ? (item['sizes'] as List).join(', ') : '');
    final quantityController = TextEditingController(
        text: item['quantity'] != null ? item['quantity'].toString() : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name'),
                const SizedBox(height: 8),
                _buildTextField(imageController, 'Image URL or Asset'),
                const SizedBox(height: 8),
                _buildTextField(priceController, 'Price',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField(sizeController, 'Sizes (comma separated)'),
                const SizedBox(height: 8),
                _buildTextField(quantityController, 'Quantity',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  print("Updating product...");
                  final updatedProduct = {
                    'name': nameController.text.trim(),
                    'docId': item['docId'], // Keep the same docId
                    'image': imageController.text.trim().isEmpty
                        ? 'assets/default-product.jpeg'
                        : imageController.text.trim(),
                    'price': double.tryParse(priceController.text.trim()) ?? 0,
                    'sizes': sizeController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList(),
                    'quantity':
                        int.tryParse(quantityController.text.trim()) ?? 0,
                  };

                  try {
                    final docRef = FirebaseFirestore.instance
                        .collection(widget.collectionName)
                        .doc(widget.documentId);

                    final doc = await docRef.get();
                    if (!doc.exists) {
                      print("Document does not exist for update.");
                      _showToast("Document not found.", Colors.red);
                      Navigator.pop(context);
                      return;
                    }

                    final data = doc.data() as Map<String, dynamic>;
                    final items =
                        List<Map<String, dynamic>>.from(data['items'] ?? []);
                    final index =
                        items.indexWhere((p) => p['docId'] == item['docId']);
                    if (index != -1) {
                      items[index] = updatedProduct;
                      await docRef.update({'items': items});
                      _showToast("Product updated successfully!", Colors.green);
                    } else {
                      print("Product docId not found in items array.");
                      _showToast(
                          "Product not found. Update failed.", Colors.red);
                    }
                  } catch (e) {
                    print("Error updating product: $e");
                    _showToast("Error updating product.", Colors.red);
                  }

                  Navigator.pop(context);
                } else {
                  _showToast('Please fill in all required fields.', Colors.red);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Utility method to build text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  // Utility method to get image widget based on URL or asset
  Widget _getImageWidget(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading network image: $error");
            return const Icon(Icons.image_not_supported, size: 80);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading asset image: $error");
            return const Icon(Icons.image_not_supported, size: 80);
          },
        );
      }
    } catch (e) {
      print("Error in image loading: $e");
      return const Icon(Icons.image_not_supported, size: 80);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building AdminProductDetailsPage...");
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Section'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              print("Navigating to FavoritesPage...");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.collectionName)
            .doc(widget.documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Loading data from Firestore...");
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error loading data: ${snapshot.error}");
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            print("No data found in Firestore document.");
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];
          if (items.isEmpty) {
            print("Items list is empty.");
            return const Center(child: Text('No items available'));
          }

          print("Loaded ${items.length} items.");

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map<String, dynamic>;
              return _buildClothingCard(item);
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                print("FAB pressed to add new product");
                _showAddProductDialog();
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Build individual product card
  Widget _buildClothingCard(Map<String, dynamic> item) {
    final isFavorite = favorites.any((fav) => fav['docId'] == item['docId']);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: _getImageWidget(item['image'] ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Product Price
                Text(
                  '₹${item['price'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                // View Details and Favorite button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View Details Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          print(
                              "Navigating to ProductDetailPage for ${item['name']}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: item, cart: [], favorites: [ runtimeType],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        print("Toggling favorite for ${item['name']}");
                        _toggleFavorite(item);
                      },
                    ),
                  ],
                ),
                // Edit and Delete Buttons (Admin only)
                if (widget.isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          print(
                              "Edit button pressed for item docId: ${item['docId']}");
                          _showUpdateProductDialog(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          print(
                              "Delete button pressed for item docId: ${item['docId']}");
                          _deleteProduct(item);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
