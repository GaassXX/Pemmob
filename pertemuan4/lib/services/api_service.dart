import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/komentar.dart';
import '../models/post.dart';

class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  Future<List<Post>> ambilPostingan() async {
    final uri = Uri.parse('$baseUrl/posts');

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat postingan '
        '(kode ${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (e) => Post.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Komentar>> ambilKomentar(int postId) async {
    final uri = Uri.parse(
      '$baseUrl/posts/$postId/comments',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat komentar '
        '(kode ${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (e) => Komentar.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}