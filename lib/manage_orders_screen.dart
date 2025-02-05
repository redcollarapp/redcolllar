import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy order data
    final List<Map<String, dynamic>> orders = [
      {
        'id': '1',
        'date': '2024-12-01',
        'status': 'Completed',
        'price': '\$250'
      },
      {'id': '2', 'date': '2024-12-02', 'status': 'Pending', 'price': '\$150'},
      {'id': '3', 'date': '2024-12-03', 'status': 'Shipped', 'price': '\$100'},
      {'id': '4', 'date': '2024-12-04', 'status': 'Cancelled', 'price': '\$50'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(order['id']),
                ),
                title: Text('Order ID: ${order['id']}'),
                subtitle:
                    Text('Date: ${order['date']} | Status: ${order['status']}'),
                trailing: Text(
                  order['price'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Handle order click (e.g., show order details)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order ${order['id']} clicked')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
