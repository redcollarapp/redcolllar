import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// ignore: unused_import

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      print("No user logged in.");
      return;
    }

    final String url = 'http://10.0.2.2:6000/api/orders/user/$userId';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          print(orders);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load orders: ${response.body}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching orders: $error');
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.brown, width: 2), // ✅ Brown border
                      ),
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _styledText('Order ID:', order['_id']),
                            _styledText('Status:', order['order_status']),
                            _styledText('Total Amount:', '\$${order['total_amount']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// Helper function for styled text
  Widget _styledText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: label, 
              style: const TextStyle(fontWeight: FontWeight.bold), // ✅ Bold labels
            ),
            const TextSpan(text: ' '),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}