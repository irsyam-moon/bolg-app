import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() => categories = body['data']);
    }
    setState(() => loading = false);
  }

  Future<void> addOrEditCategory({Map? category}) async {
    final controller = TextEditingController(text: category?['name'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              if (category == null) {
                await http.post(
                  Uri.parse('$baseUrl/categories'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'name': name}),
                );
              } else {
                await http.put(
                  Uri.parse('$baseUrl/categories/${category['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'name': name}),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
              fetchCategories();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    await http.delete(Uri.parse('$baseUrl/categories/$id'));
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF48CAE4)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(category['name'],
                        style: const TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF48CAE4)),
                          onPressed: () => addOrEditCategory(category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFFF4D4D)),
                          onPressed: () => deleteCategory(category['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditCategory(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
