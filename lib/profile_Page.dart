import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(100),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E6E53), Color(0xFFB89C89)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
            ),
            child: Column(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getInitials(user?.displayName ?? 'Demo User'),
                    style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  user?.displayName ?? 'Jane A. Meldrum',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // User Email
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'jane@test.com',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Options List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOption(
                  icon: Icons.person_outline,
                  title: 'My Information',
                  onTap: () {
                    Navigator.pushNamed(context, '/my-info');
                  },
                ),
                const Divider(),
                _buildOption(
                  icon: Icons.credit_card_outlined,
                  title: 'Checkout',
                  onTap: () {
                    Navigator.pushNamed(context, '/checkout');
                  },
                ),
                const Divider(),
                _buildOption(
                  icon: Icons.history,
                  title: 'Past Orders',
                  onTap: () {
                    // Handle navigation for past orders
                  },
                ),
                const Divider(),
                _buildOption(
                  icon: Icons.location_on_outlined,
                  title: 'Address Information',
                  onTap: () {
                    // Handle navigation for address information
                  },
                ),
                const Divider(),
                _buildOption(
                  icon: Icons.card_giftcard_outlined,
                  title: 'Coupons',
                  onTap: () {
                    // Handle navigation for coupons
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get initials from the user's display name
  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    }
    return nameParts[0][0];
  }

  /// Build individual option items
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.brown,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
