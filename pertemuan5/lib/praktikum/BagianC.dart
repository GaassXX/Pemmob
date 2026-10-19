import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CatatanPage(),
    );
  }
}

// MODEL CATATAN
class Catatan {
  final int? id;
  final String judul;
  final String isi;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
    };
  }

  factory Catatan.fromMap(Map<String, Object?> m) {
    return Catatan(
      id: m['id'] as int,
      judul: m['judul'] as String,
      isi: m['isi'] as String,
    );
  }
}

// DATABASE SQLITE
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = p.join(
      await getDatabasesPath(),
      'catatan.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'judul TEXT NOT NULL, '
          'isi TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  static Future<List<Catatan>> semua() async {
    final db = await database;
    final rows = await db.query(
      'catatan',
      orderBy: 'id DESC',
    );

    return rows.map(Catatan.fromMap).toList();
  }

  static Future<int> ubah(Catatan c) async {
    final db = await database;

    return db.update(
      'catatan',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// HALAMAN DAFTAR CATATAN
class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  late Future<List<Catatan>> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.semua();
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(catatan: catatan),
      ),
    );

    if (!mounted) return;
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Galat: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final c = data[i];

              return ListTile(
                leading: const Icon(
                  Icons.note_alt_outlined,
                  color: Colors.blue,
                ),
                title: Text(c.judul),
                subtitle: Text(
                  c.isi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _buka(c),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    final konfirmasi = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Catatan'),
                        content: Text(
                          'Yakin ingin menghapus "${c.judul}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );

                    if (konfirmasi == true) {
                      await DbHelper.hapus(c.id!);
                      if (!mounted) return;
                      _muat();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// HALAMAN FORM SEMENTARA
// Form tambah dan ubah lengkap dikerjakan pada Bagian D.
class FormCatatanPage extends StatelessWidget {
  final Catatan? catatan;

  const FormCatatanPage({
    super.key,
    this.catatan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          catatan == null ? 'Tambah Catatan' : 'Ubah Catatan',
        ),
      ),
      body: Center(
        child: Text(
          catatan == null
              ? 'Form tambah dibuat pada Bagian D.'
              : 'Form ubah dibuat pada Bagian D.\nJudul: ${catatan!.judul}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}