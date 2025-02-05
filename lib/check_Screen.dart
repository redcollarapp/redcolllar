import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile_Page.dart';
import 'profile_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    Key? key,
    required this.cart,
    required this.discount,
    required this.subtotal,
    required this.total,
  }) : super(key: key);

  final List<Map<String, dynamic>> cart;
  final double discount;
  final double subtotal;
  final double total;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // User data
  final Map<String, String> _addressData = {
    'fullName': '',
    'email': '',
    'phone': '',
    'address': '',
    'city': '',
    'country': ''
  };

  final Map<String, String> _paymentData = {
    'cardHolderName': '',
    'cardNumber': '',
    'expiryDate': '',
    'cvv': ''
  };

  bool _saveShipping = false;
  bool _saveCard = false;

  // Simulate payment processing
  void _processPayment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay

    // Save payment data if the user opted to save the card
    if (_saveCard) {
      _savePaymentData();
    }

    Navigator.pop(context); // Close the loading dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentCompleteScreen(),
      ),
    );
  }

  void _saveShippingAddress() {
    // Save address data (this could be to a backend or local storage)
    if (_saveShipping) {
      print("Saving shipping address: $_addressData");
    }
  }

  void _savePaymentData() {
    // Save payment data securely (e.g., to encrypted storage or backend)
    print("Saving payment data: $_paymentData");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.brown),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to ProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyInformationScreen()),
              );
            },
          ),
        ],
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _saveShippingAddress();
            setState(() {
              _currentStep++;
            });
          } else if (_currentStep == 1) {
            _processPayment();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Address'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    onSave: (value) => _addressData['fullName'] = value!,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  _buildInputField(
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    onSave: (value) => _addressData['email'] = value!,
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  _buildInputField(
                    label: 'Phone',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    onSave: (value) => _addressData['phone'] = value!,
                    validator: (value) => value == null || value.length < 10
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                  _buildInputField(
                    label: 'Address',
                    hint: 'Type your home address',
                    onSave: (value) => _addressData['address'] = value!,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'City',
                          hint: 'Enter here',
                          onSave: (value) => _addressData['city'] = value!,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'Country',
                          hint: 'Your country',
                          onSave: (value) => _addressData['country'] = value!,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    title: const Text('Save shipping address'),
                    value: _saveShipping,
                    onChanged: (value) {
                      setState(() {
                        _saveShipping = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Complete'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: 'Card Holder Name',
                  hint: 'Your card holder name',
                  onSave: (value) => _paymentData['cardHolderName'] = value!,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                _buildInputField(
                  label: 'Card Number',
                  hint: 'Your card number',
                  keyboardType: TextInputType.number,
                  onSave: (value) => _paymentData['cardNumber'] = value!,
                  validator: (value) => value == null || value.length < 16
                      ? 'Enter a valid card number'
                      : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Month/Year',
                        hint: 'mm/yy',
                        keyboardType: TextInputType.datetime,
                        onSave: (value) => _paymentData['expiryDate'] = value!,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'CVV',
                        hint: '***',
                        keyboardType: TextInputType.number,
                        onSave: (value) => _paymentData['cvv'] = value!,
                        validator: (value) => value == null || value.length != 3
                            ? 'Invalid CVV'
                            : null,
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Save this card'),
                  value: _saveCard,
                  onChanged: (value) {
                    setState(() {
                      _saveCard = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Input field builder
  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSave,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: keyboardType,
        onSaved: onSave,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.brown.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class PaymentCompleteScreen extends StatelessWidget {
  const PaymentCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
