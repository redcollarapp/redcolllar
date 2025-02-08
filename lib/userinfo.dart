import 'package:flutter/material.dart';

class InformationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String address;

  const InformationScreen({
    super.key,
    required this.username,
    required this.email,
    required this.address,
  });

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
    late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _addressController = TextEditingController(text: widget.address);
     _addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Function to save the updated information
  void _saveInformation() {
    final String updatedUsername = _usernameController.text;
    final String updatedEmail = _emailController.text;
    final String updatedAddress = _addressController.text;

    // For demonstration purposes, we're simply showing a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Information updated!')),
    );

    // Here you can handle the saving logic (e.g., update database, API call, etc.)
    print('Updated Username: $updatedUsername');
    print('Updated Email: $updatedEmail');
    print('Updated Address: $updatedAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Information'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInformation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Input
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Email Input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Address Input
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
