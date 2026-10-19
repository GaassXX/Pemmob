
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// FORMAT RUPIAH
String formatRupiah(int angka) {
  final teks = angka.toString();
  final hasil = StringBuffer();

  for (int i = 0; i < teks.length; i++) {
    hasil.write(teks[i]);

    final sisa = teks.length - i - 1;
    if (sisa > 0 && sisa % 3 == 0) {
      hasil.write('.');
    }
  }

  return 'Rp $hasil';
}

// MODEL PENGELUARAN
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

  factory Pengeluaran.fromMap(Map<String, Object?> map) {
    return Pengeluaran(
      id: map['id'] as int,
      nama: map['nama'] as String,
      jumlah: map['jumlah'] as int,
      kategori: map['kategori'] as String,
      tanggal: map['tanggal'] as String,
    );
  }
}

// DATABASE SQLITE
class DbPengeluaran {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final lokasi = p.join(
      await getDatabasesPath(),
      'pengeluaran.db',
    );

    _db = await openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pengeluaran (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            jumlah INTEGER NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<int> tambah(Pengeluaran data) async {
    final db = await database;
    return db.insert('pengeluaran', data.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;

    final rows = await db.query(
      'pengeluaran',
      orderBy: 'tanggal DESC, id DESC',
    );

    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran data) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// APLIKASI UTAMA + PENGATURAN MODE GELAP
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _gelap = false;
  bool _siap = false;

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _gelap = prefs.getBool('mode_gelap') ?? false;
      _siap = true;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode_gelap', nilai);

    if (!mounted) return;

    setState(() {
      _gelap = nilai;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: _gelap ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      home: _siap
          ? PengeluaranPage(
              gelap: _gelap,
              onTemaBerubah: _ubahTema,
            )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

// HALAMAN UTAMA
class PengeluaranPage extends StatefulWidget {
  final bool gelap;
  final ValueChanged<bool> onTemaBerubah;

  const PengeluaranPage({
    super.key,
    required this.gelap,
    required this.onTemaBerubah,
  });

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _future = DbPengeluaran.semua();
  }

  Future<void> _tambahAtauUbah([Pengeluaran? data]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(data: data),
      ),
    );

    if (!mounted) return;

    setState(_muat);
  }

  Future<void> _hapusPengeluaran(Pengeluaran data) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus pengeluaran "${data.nama}"?'),
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
      ),
    );

    if (setuju != true) return;

    await DbPengeluaran.hapus(data.id!);

    if (!mounted) return;

    setState(_muat);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengeluaran berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) => SafeArea(
                  child: SwitchListTile(
                    title: const Text('Mode gelap'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: widget.gelap,
                    onChanged: (nilai) {
                      widget.onTemaBerubah(nilai);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Pengeluaran>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          final total = data.fold<int>(
            0,
            (jumlah, item) => jumlah + item.jumlah,
          );

          return Column(
            children: [
              // TOTAL PENGELUARAN
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined),
                          SizedBox(width: 8),
                          Text('Total Pengeluaran'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatRupiah(total),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('${data.length} transaksi tercatat'),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Riwayat Pengeluaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: data.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada pengeluaran.\nTekan + untuk menambahkan.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  item.kategori == 'Makanan'
                                      ? Icons.restaurant
                                      : item.kategori == 'Transportasi'
                                          ? Icons.directions_car
                                          : item.kategori == 'Belanja'
                                              ? Icons.shopping_bag
                                              : Icons.receipt_long,
                                ),
                              ),
                              title: Text(
                                item.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${item.kategori} • ${item.tanggal}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (aksi) {
                                  if (aksi == 'ubah') {
                                    _tambahAtauUbah(item);
                                  } else if (aksi == 'hapus') {
                                    _hapusPengeluaran(item);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'ubah',
                                    child: Text('Ubah'),
                                  ),
                                  PopupMenuItem(
                                    value: 'hapus',
                                    child: Text('Hapus'),
                                  ),
                                ],
                              ),
                              isThreeLine: false,
                              onTap: () => _tambahAtauUbah(item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahAtauUbah(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// FORM TAMBAH DAN UBAH
class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? data;

  const FormPengeluaranPage({super.key, this.data});

  @override
  State<FormPengeluaranPage> createState() =>
      _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _jumlah;

  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Pendidikan',
    'Kesehatan',
    'Hiburan',
    'Lainnya',
  ];

  String? _kategori;
  DateTime _tanggal = DateTime.now();
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();

    _nama = TextEditingController(
      text: widget.data?.nama ?? '',
    );

    _jumlah = TextEditingController(
      text: widget.data?.jumlah.toString() ?? '',
    );

    _kategori = widget.data?.kategori;
    if (_kategori != null && !_kategoriList.contains(_kategori)) {
      _kategoriList.add(_kategori!);
    }

    if (widget.data != null) {
      _tanggal = DateTime.tryParse(widget.data!.tanggal) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.year}-'
        '${tanggal.month.toString().padLeft(2, '0')}-'
        '${tanggal.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (hasil != null && mounted) {
      setState(() {
        _tanggal = hasil;
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _menyimpan = true);

    try {
      final data = Pengeluaran(
        id: widget.data?.id,
        nama: _nama.text.trim(),
        jumlah: int.parse(_jumlah.text.trim()),
        kategori: _kategori!,
        tanggal: _formatTanggal(_tanggal),
      );

      if (widget.data == null) {
        await DbPengeluaran.tambah(data);
      } else {
        await DbPengeluaran.ubah(data);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.data == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                hintText: 'Contoh: Makan siang',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Nama pengeluaran wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah pengeluaran',
                hintText: 'Contoh: 25000',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final angka = int.tryParse(nilai.trim());

                if (angka == null) {
                  return 'Jumlah harus berupa angka bulat';
                }

                if (angka <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategori,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih kategori'),
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (nilai) {
                setState(() => _kategori = nilai);
              },
              validator: (nilai) {
                if (nilai == null) {
                  return 'Kategori wajib dipilih';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_month),
              label: Text('Tanggal: ${_formatTanggal(_tanggal)}'),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan Pengeluaran'),
            ),
          ],
        ),
      ),
    );
  }
}
