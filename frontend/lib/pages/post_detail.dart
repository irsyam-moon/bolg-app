import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'post_form.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map? post;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await http.get(Uri.parse('$baseUrl/posts/${widget.postId}'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() => post = body['data']);
      } else {
        setState(() => error = 'Gagal mengambil artikel (${res.statusCode})');
      }
    } catch (e) {
      setState(() => error = 'Tidak bisa terhubung ke server');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('Hapus Artikel'),
        content: Text('Yakin ingin menghapus "${post!['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF4D4D)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await http.delete(Uri.parse('$baseUrl/posts/${widget.postId}'));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: post == null
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostFormPage(post: post)),
                    );
                    fetchDetail();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF4D4D)),
                  onPressed: deletePost,
                ),
              ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF48CAE4)))
          : error != null
              ? Center(
                  child: Text(error!, style: const TextStyle(color: Color(0xFF8D99AE))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF48CAE4).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          post!['category_name'] ?? '-',
                          style: const TextStyle(
                            color: Color(0xFF48CAE4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post!['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Oleh ${post!['author'] ?? '-'}',
                        style: const TextStyle(color: Color(0xFF8D99AE)),
                      ),
                      const Divider(height: 32, color: Color(0xFF1C2541)),
                      Text(
                        post!['content'] ?? '',
                        style: const TextStyle(color: Colors.white, height: 1.5),
                      ),
                    ],
                  ),
                ),
    );
  }
}
