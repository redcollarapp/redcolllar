import 'package:flutter/material.dart';

class InformationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String address;
  final String phoneNumber; // ✅ Added phoneNumber parameter

  const InformationScreen({
    super.key,
    required this.username,
    required this.email,
    required this.address,
    required this.phoneNumber, // ✅ Fixed issue
  });

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController; // ✅ Fixed phone number controller

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _addressController = TextEditingController(text: widget.address);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber); // ✅ Fixed issue
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // ✅ Save updated information
  void _saveInformation() {
    final String updatedUsername = _usernameController.text;
    final String updatedEmail = _emailController.text;
    final String updatedAddress = _addressController.text;
    final String updatedPhoneNumber = _phoneNumberController.text; // ✅ Fixed type

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Information updated!')),
    );

    print('Updated Username: $updatedUsername');
    print('Updated Email: $updatedEmail');
    print('Updated Address: $updatedAddress');
    print('Updated Phone Number: $updatedPhoneNumber');
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
            // ✅ Username Input
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Email Input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Address Input
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Phone Number Input
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
