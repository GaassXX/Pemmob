
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Saya',
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
  final String dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.dibuat,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'dibuat': dibuat,
    };
  }

  factory Catatan.fromMap(Map<String, Object?> map) {
    return Catatan(
      id: map['id'] as int,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      dibuat: map['dibuat'] as String? ?? '',
    );
  }
}

// DATABASE SQLITE
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final lokasi = p.join(
      await getDatabasesPath(),
      'catatan.db',
    );

    _db = await openDatabase(
      lokasi,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi TEXT NOT NULL,
            dibuat TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan ADD COLUMN dibuat TEXT',
          );
        }
      },
    );

    return _db!;
  }

  static Future<int> tambah(Catatan catatan) async {
    final db = await database;
    return db.insert('catatan', catatan.toMap());
  }

  static Future<List<Catatan>> semua({
    String kata = '',
    String urutan = 'terbaru',
  }) async {
    final db = await database;

    return (await db.query(
      'catatan',
      where: kata.trim().isEmpty ? null : 'judul LIKE ?',
      whereArgs: kata.trim().isEmpty
          ? null
          : ['%${kata.trim()}%'],
      orderBy: urutan == 'terbaru'
          ? 'id DESC'
          : 'id ASC',
    ))
        .map((row) => Catatan.fromMap(row))
        .toList();
  }

  static Future<int> ubah(Catatan catatan) async {
    final db = await database;

    return db.update(
      'catatan',
      catatan.toMap(),
      where: 'id = ?',
      whereArgs: [catatan.id],
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

// HALAMAN DAFTAR
class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  Future<List<Catatan>>? _future;
  final TextEditingController _pencarian = TextEditingController();

  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _inisialisasi();
  }

  Future<void> _inisialisasi() async {
    final prefs = await SharedPreferences.getInstance();
    final urutanTersimpan = prefs.getString('urutan_catatan') ?? 'terbaru';

    if (!mounted) return;

    setState(() {
      _urutan = urutanTersimpan;
      _future = DbHelper.semua(
        kata: _pencarian.text,
        urutan: _urutan,
      );
    });
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua(
        kata: _pencarian.text,
        urutan: _urutan,
      );
    });
  }

  Future<void> _ubahUrutan(String nilai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('urutan_catatan', nilai);

    if (!mounted) return;

    setState(() {
      _urutan = nilai;
      _future = DbHelper.semua(
        kata: _pencarian.text,
        urutan: _urutan,
      );
    });
  }

  Future<void> _bukaForm([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(catatan: catatan),
      ),
    );

    if (!mounted) return;
    _muat();
  }

  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Hapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (setuju != true) return;

    await DbHelper.hapus(catatan.id!);

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil dihapus')),
    );
  }

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Urutan catatan',
            icon: const Icon(Icons.sort),
            initialValue: _urutan,
            onSelected: _ubahUrutan,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'terbaru',
                child: Text('Terbaru'),
              ),
              PopupMenuItem(
                value: 'terlama',
                child: Text('Terlama'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _pencarian,
              decoration: InputDecoration(
                hintText: 'Cari judul catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _pencarian.clear();
                    _muat();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _muat(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Catatan>>(
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

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan'),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final catatan = data[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.note_alt_outlined),
                        ),
                        title: Text(catatan.judul),
                        subtitle: Text(
                          '${catatan.isi}\nDibuat: ${catatan.dibuat}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        onTap: () => _bukaForm(catatan),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _konfirmasiHapus(catatan),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// FORM TAMBAH DAN UBAH
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;

  const FormCatatanPage({super.key, this.catatan});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();

    _judul = TextEditingController(
      text: widget.catatan?.judul ?? '',
    );
    _isi = TextEditingController(
      text: widget.catatan?.isi ?? '',
    );
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final sekarang = DateTime.now();
    final tanggal = widget.catatan?.dibuat.isNotEmpty == true
        ? widget.catatan!.dibuat
        : '${sekarang.day.toString().padLeft(2, '0')}/'
          '${sekarang.month.toString().padLeft(2, '0')}/'
          '${sekarang.year} '
          '${sekarang.hour.toString().padLeft(2, '0')}:'
          '${sekarang.minute.toString().padLeft(2, '0')}';

    final catatan = Catatan(
      id: widget.catatan?.id,
      judul: _judul.text.trim(),
      isi: _isi.text.trim(),
      dibuat: tanggal,
    );

    if (widget.catatan == null) {
      await DbHelper.tambah(catatan);
    } else {
      await DbHelper.ubah(catatan);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Catatan Baru' : 'Ubah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isi,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
