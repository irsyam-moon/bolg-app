import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'post_detail.dart';
import 'post_form.dart';
import 'category.dart';

const String baseUrl = 'http://localhost:3000/api'; // ganti sesuai device kamu

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List posts = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await http.get(Uri.parse('$baseUrl/posts'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() => posts = body['data']);
      } else {
        setState(() => error = 'Gagal mengambil data (${res.statusCode})');
      }
    } catch (e) {
      setState(() => error = 'Tidak bisa terhubung ke server');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deletePost(int id) async {
    await http.delete(Uri.parse('$baseUrl/posts/$id'));
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Dark App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryPage()),
              );
              fetchPosts();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchPosts),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CAE4)),
            )
          : error != null
          ? Center(
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFF8D99AE)),
              ),
            )
          : posts.isEmpty
          ? const Center(
              child: Text(
                'Belum ada artikel.',
                style: TextStyle(color: Color(0xFF8D99AE)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Kategori: ${post['category_name'] ?? '-'} | Author: ${post['author'] ?? '-'}',
                      style: const TextStyle(color: Color(0xFF8D99AE)),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(postId: post['id']),
                        ),
                      );
                      fetchPosts();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFFF4D4D)),
                      onPressed: () => deletePost(post['id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormPage()),
          );
          fetchPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
