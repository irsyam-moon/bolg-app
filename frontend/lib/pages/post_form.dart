import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class PostFormPage extends StatefulWidget {
  final Map? post;
  const PostFormPage({super.key, this.post});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final authorController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;
  String? error;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      titleController.text = widget.post!['title'] ?? '';
      contentController.text = widget.post!['content'] ?? '';
      authorController.text = widget.post!['author'] ?? '';
      selectedCategoryId = widget.post!['category_id'];
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() => categories = body['data']);
    }
  }

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategoryId == null) {
      setState(() => error = 'Semua field wajib diisi');
      return;
    }

    final payload = jsonEncode({
      'category_id': selectedCategoryId,
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'author': authorController.text.trim(),
    });

    final res = isEditing
        ? await http.put(
            Uri.parse('$baseUrl/posts/${widget.post!['id']}'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
        : await http.post(
            Uri.parse('$baseUrl/posts'),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          );

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => error = 'Gagal menyimpan (${res.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Artikel' : 'Tambah Artikel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (error != null) ...[
            Text(error!, style: const TextStyle(color: Color(0xFFFF4D4D))),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<int>(
            initialValue: selectedCategoryId,
            dropdownColor: const Color(0xFF1C2541),
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: categories
                .map<DropdownMenuItem<int>>((c) => DropdownMenuItem(
                      value: c['id'],
                      child: Text(c['name']),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedCategoryId = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: authorController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Penulis'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: contentController,
            style: const TextStyle(color: Colors.white),
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Konten'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CAE4),
              foregroundColor: Colors.black,
            ),
            onPressed: submit,
            child: Text(isEditing ? 'Simpan' : 'Publikasikan'),
          ),
        ],
      ),
    );
  }
}
