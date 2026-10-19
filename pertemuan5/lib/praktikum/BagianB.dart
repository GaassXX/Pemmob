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
      title: 'Praktikum 5 - Bagian B',
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

// HELPER DATABASE SQLITE
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

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

  // MENAMBAHKAN CATATAN
  static Future<int> tambah(Catatan c) async {
    final db = await database;

    return db.insert(
      'catatan',
      c.toMap(),
    );
  }

  // MENGAMBIL SEMUA CATATAN
  static Future<List<Catatan>> semua() async {
    final db = await database;

    final rows = await db.query(
      'catatan',
      orderBy: 'id DESC',
    );

    return rows.map(Catatan.fromMap).toList();
  }

  // MENGUBAH CATATAN
  static Future<int> ubah(Catatan c) async {
    final db = await database;

    return db.update(
      'catatan',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  // MENGHAPUS CATATAN
  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// HALAMAN UNTUK MENGUJI DATABASE
class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  List<Catatan> daftarCatatan = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _muatCatatan();
  }

  // MEMUAT DATA DARI SQLITE
  Future<void> _muatCatatan() async {
    final data = await DbHelper.semua();

    if (!mounted) return;

    setState(() {
      daftarCatatan = data;
      loading = false;
    });
  }

  // FORM TAMBAH CATATAN
  Future<void> _tambahCatatan() async {
    final judulController = TextEditingController();
    final isiController = TextEditingController();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (judulController.text.trim().isEmpty ||
                    isiController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await DbHelper.tambah(
        Catatan(
          judul: judulController.text.trim(),
          isi: isiController.text.trim(),
        ),
      );

      await _muatCatatan();
    }

    judulController.dispose();
    isiController.dispose();
  }

  // FORM UBAH CATATAN
  Future<void> _ubahCatatan(Catatan catatan) async {
    final judulController = TextEditingController(
      text: catatan.judul,
    );
    final isiController = TextEditingController(
      text: catatan.isi,
    );

    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Catatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (judulController.text.trim().isEmpty ||
                    isiController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await DbHelper.ubah(
        Catatan(
          id: catatan.id,
          judul: judulController.text.trim(),
          isi: isiController.text.trim(),
        ),
      );

      await _muatCatatan();
    }

    judulController.dispose();
    isiController.dispose();
  }

  // MENGHAPUS CATATAN
  Future<void> _hapusCatatan(Catatan catatan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: Text(
            'Yakin ingin menghapus "${catatan.judul}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await DbHelper.hapus(catatan.id!);
      await _muatCatatan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan SQLite'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : daftarCatatan.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada catatan.\nTekan tombol + untuk menambahkan.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: daftarCatatan.length,
                  itemBuilder: (context, index) {
                    final catatan = daftarCatatan[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${catatan.id}'),
                        ),
                        title: Text(
                          catatan.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(catatan.isi),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (pilihan) {
                            if (pilihan == 'ubah') {
                              _ubahCatatan(catatan);
                            } else if (pilihan == 'hapus') {
                              _hapusCatatan(catatan);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'ubah',
                              child: Text('Ubah'),
                            ),
                            const PopupMenuItem(
                              value: 'hapus',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}