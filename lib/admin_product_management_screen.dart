import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin_product_details.dart';
// Updated import

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'T-Shirt',
      'docId': 'biRhapgdIk6LdYEcoA6A',
      'collection': 'clothes',
      'image': 'assets/t-shop.jpeg',
    },
    {
      'name': 'Hoodie',
      'docId': '0XT0FaUS8sdxQj7VYnIJ',
      'collection': 'hoodies',
      'image': 'assets/hoodie-shop.jpeg',
    },
    {
      'name': 'Jeans',
      'docId': '7iUIOTG60q64EmQqAmdV',
      'collection': 'jeans',
      'image': 'assets/jean-shop.jpeg',
    },
    {
      'name': 'Shoes',
      'docId': 'Op3RND16TFucJc9YNy7S',
      'collection': 'shoes',
      'image': 'assets/shoe-shop.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Product Screen'),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                product['image'] as String,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product['name'] as String),
              subtitle: Text('Collection: ${product['collection']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to AdminProductDetailsPage with admin privileges
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminProductDetailsPage(
                        category: product['name'] as String,
                        documentId: product['docId'] as String,
                        collectionName: product['collection'] as String,
                        isAdmin: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Admin View',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
