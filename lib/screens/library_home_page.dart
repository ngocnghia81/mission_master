import 'package:flutter/material.dart';
import 'transactions_demo_screen.dart';
import 'lazy_loading_demo_screen.dart';

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({super.key});

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends State<LibraryHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Optimization Demo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Transactions Demo'),
              onTap: () {
                Navigator.pushNamed(context, '/transactions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Lazy Loading & Caching'),
              onTap: () {
                Navigator.pushNamed(context, '/lazy_loading');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SQLite Optimization Demo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Ứng dụng demo các kỹ thuật tối ưu hiệu suất SQLite trong Flutter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                'Transactions Demo',
                Icons.speed,
                'So sánh hiệu suất riêng lẻ vs transactions vs batch',
                () => Navigator.pushNamed(context, '/transactions'),
                Colors.blue.shade100,
              ),
            ),
            Expanded(
              child: _buildFeatureCard(
                'Lazy Loading & Caching',
                Icons.view_list,
                'Demo infinite scrolling và chiến lược cache hiệu quả',
                () => Navigator.pushNamed(context, '/lazy_loading'),
                Colors.green.shade100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    String description,
    VoidCallback onPressed,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
