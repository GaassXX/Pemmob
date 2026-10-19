import 'package:flutter/material.dart';

import 'package:pertemuan4/models/komentar.dart';
import 'package:pertemuan4/models/post.dart';
import 'package:pertemuan4/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Postingan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PostPage(),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ApiService _apiService = ApiService();

  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.ambilPostingan();
  }

  void _muatUlang() {
    setState(() {
      _future = _apiService.ambilPostingan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error.toString(),
              onRetry: _muatUlang,
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text('Tidak ada postingan'),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text('${post.id}'),
                ),
                title: Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPostPage(
                        post: post,
                        apiService: _apiService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPostPage extends StatefulWidget {
  final Post post;
  final ApiService apiService;

  const DetailPostPage({
    super.key,
    required this.post,
    required this.apiService,
  });

  @override
  State<DetailPostPage> createState() =>
      _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();

    _futureKomentar = widget.apiService.ambilKomentar(
      widget.post.id,
    );
  }

  void _muatUlangKomentar() {
    setState(() {
      _futureKomentar =
          widget.apiService.ambilKomentar(
        widget.post.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Postingan ${post.id}',
        ),
        actions: [
          IconButton(
            onPressed: _muatUlangKomentar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            post.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          Text(
            post.body,
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),

          const SizedBox(height: 24),

          Text(
            'Komentar',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<List<Komentar>>(
            future: _futureKomentar,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _ErrorView(
                  error: snapshot.error.toString(),
                  onRetry: _muatUlangKomentar,
                );
              }

              final komentar = snapshot.data ?? [];

              if (komentar.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tidak ada komentar',
                  ),
                );
              }

              return Column(
                children: komentar.map(
                  (item) {
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),

                            const SizedBox(height: 8),

                            Text(item.body),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),

            const SizedBox(height: 12),

            Text(
              'Terjadi kesalahan:\n$error',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}