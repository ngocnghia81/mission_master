import 'package:flutter/material.dart';
import '../services/library_database_helper.dart';

class SchemaOptimizationScreen extends StatefulWidget {
  const SchemaOptimizationScreen({Key? key}) : super(key: key);

  @override
  State<SchemaOptimizationScreen> createState() =>
      _SchemaOptimizationScreenState();
}

class _SchemaOptimizationScreenState extends State<SchemaOptimizationScreen> {
  Map<String, String> _tableSchemas = {};
  List<Map<String, dynamic>> _indexes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDatabaseSchemas();
  }

  Future<void> _loadDatabaseSchemas() async {
    setState(() {
      _isLoading = true;
      _tableSchemas = {};
      _indexes = [];
    });

    try {
      // Load schema for each table
      final tables = ['books', 'authors', 'categories'];
      for (final table in tables) {
        final schema = await LibraryDatabaseHelper.instance.getTableSchema(
          table,
        );
        if (schema.isNotEmpty) {
          setState(() {
            _tableSchemas[table] = schema;
          });
        }
      }

      // Load indexes
      final indexes = await LibraryDatabaseHelper.instance.getAllIndexes();
      setState(() {
        _indexes = indexes;
        _isLoading = false;
      });

      print('Schemas loaded: ${_tableSchemas.length}');
      print('Indexes loaded: ${_indexes.length}');
    } catch (e) {
      print('Error loading schema: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schema Optimization')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildSchemaSection(),
      ),
    );
  }

  Widget _buildSchemaSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Lỗi: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_tableSchemas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Không thể tải schema. Hãy thử lại sau.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cấu trúc cơ sở dữ liệu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._tableSchemas.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      'Bảng: ${entry.key}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[200],
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Các Index',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _indexes.isEmpty
                    ? const Text('Không có index nào')
                    : Column(
                      children:
                          _indexes.map((index) {
                            return ListTile(
                              title: Text(index['name'] as String),
                              subtitle: Text('Table: ${index['tbl_name']}'),
                              leading: const Icon(Icons.insert_chart),
                            );
                          }).toList(),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _loadDatabaseSchemas,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Schema'),
        ),
      ],
    );
  }
}
