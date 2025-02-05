import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _recentSearches = ["Wilcox", "Kevin"];
  final List<Map<String, dynamic>> _lastViewedItems = [
    {
      'name': 'Wilcox',
      'type': 'Dresses',
      'price': '\$85.88',
      'image': 'assets/overcost/o1-min.jpeg',
      'color': Colors.brown,
      'size': 'XS',
    },
    {
      'name': 'Karen Willis',
      'type': 'Dresses',
      'price': '\$142',
      'image': 'assets/overcost/o1-min.jpeg',
      'color': Colors.brown,
      'size': 'XS',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined,
                        color: Colors.black),
                    onPressed: () {
                      // Add filter logic here
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Search Section
            _buildSectionHeader('Recent Search', () {
              setState(() {
                _recentSearches.clear();
              });
            }),
            const SizedBox(height: 8),
            _buildRecentSearches(),

            const Divider(height: 32, color: Colors.grey),

            // Last Viewed Section
            _buildSectionHeader('Last Viewed', () {
              setState(() {
                _lastViewedItems.clear();
              });
            }),
            const SizedBox(height: 8),
            Expanded(child: _buildLastViewedItems()),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title, VoidCallback onClear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: const Text(
            'Clear All',
            style: TextStyle(
              fontSize: 14,
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Recent Searches
  Widget _buildRecentSearches() {
    return _recentSearches.isEmpty
        ? const Center(
            child: Text(
              'No recent searches.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : Column(
            children: _recentSearches
                .map((search) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.history,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              search,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _recentSearches.remove(search);
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          );
  }

  // Last Viewed Items
  Widget _buildLastViewedItems() {
    return _lastViewedItems.isEmpty
        ? const Center(
            child: Text(
              'No last viewed items.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: _lastViewedItems.length,
            itemBuilder: (context, index) {
              final item = _lastViewedItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        child: Image.asset(
                          item['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['name']} | ${item['type']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['price'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'Color:',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 4),
                                  CircleAvatar(
                                    backgroundColor: item['color'],
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Size:',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['size'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Remove Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _lastViewedItems.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
