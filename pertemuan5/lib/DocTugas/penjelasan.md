# Doc Tugas - Pertemuan 5: Local Storage dengan SharedPreferences dan SQLite

Disusun oleh: Rizqi Bagas Wicaksono  
NIM: 20240801187

## 1. Tujuan Pembelajaran

Pada pertemuan 5, mahasiswa belajar cara menyimpan data secara lokal di aplikasi Flutter. Materi ini penting karena banyak aplikasi perlu menyimpan data meskipun aplikasi ditutup atau perangkat sedang offline. Dalam pertemuan ini terdapat dua teknik utama yang dipelajari, yaitu:

- `SharedPreferences` untuk menyimpan data sederhana seperti nama pengguna dan pengaturan tema
- `SQLite` untuk menyimpan data yang lebih kompleks dan banyak, seperti catatan atau transaksi

Tujuan pembelajaran pada materi ini adalah agar mahasiswa mampu:

- memahami mekanisme penyimpanan data lokal di Flutter
- menyimpan pengaturan aplikasi seperti mode gelap
- menyimpan data teks atau data sederhana ke `SharedPreferences`
- membuat database SQLite untuk CRUD (Create, Read, Update, Delete)
- mengintegrasikan database ke UI dengan `FutureBuilder` dan `setState()`

## 2. SharedPreferences

`SharedPreferences` adalah cara paling sederhana untuk menyimpan data lokal di Flutter. Data yang biasa disimpan biasanya berupa:

- string
- integer
- boolean
- list string

Pada praktikum bagian A, terdapat contoh aplikasi pengaturan sederhana yang menyimpan:

- nama pengguna
- status mode gelap
- berapa kali aplikasi dibuka

### Contoh penggunaan

```dart
final prefs = await SharedPreferences.getInstance();

await prefs.setString('nama', _controller.text.trim());
await prefs.setBool('gelap', nilai);
await prefs.setInt('bukaKe', _bukaKe);
```

### Penjelasan:

- `SharedPreferences.getInstance()` mengambil instance penyimpanan lokal
- `setString()`, `setBool()`, `setInt()` menyimpan data ke memori lokal
- data akan tersimpan dan dapat dibaca saat aplikasi dibuka lagi

### Keunggulan SharedPreferences

- mudah dipahami
- cocok untuk data kecil
- cepat dan sederhana

### Keterbatasan SharedPreferences

- tidak cocok untuk data besar
- kurang cocok untuk data relational atau data yang banyak
- lebih tepat untuk pengaturan aplikasi dan data kecil

## 3. Aplikasi Pengaturan dengan SharedPreferences

Pada bagian A, dibuat kelas `PengaturanPage` dengan beberapa fitur berikut:

- `TextField` untuk input nama
- tombol `Simpan Nama`
- `SwitchListTile` untuk mengubah mode gelap
- teks yang menampilkan jumlah aplikasi dibuka

### Flow kerjanya

1. Saat aplikasi dibuka, `initState()` memanggil `_muat()`
2. `_muat()` memanggil `SharedPreferences.getInstance()`
3. Data yang tersimpan seperti nama atau mode gelap dibaca kembali
4. Nilai tersebut ditampilkan kembali di UI
5. Saat user mengubah data, maka data disimpan kembali ke `SharedPreferences`

### Contoh kode penting

```dart
Future<void> _muat() async {
  final prefs = await SharedPreferences.getInstance();

  if (!mounted) return;

  setState(() {
    _controller.text = prefs.getString('nama') ?? '';
    _gelap = prefs.getBool('gelap') ?? false;
    _bukaKe = (prefs.getInt('bukaKe') ?? 0) + 1;
  });

  await prefs.setInt('bukaKe', _bukaKe);
}
```

Kode di atas menunjukkan bagaimana data lokal dibaca dan menampilkan nilai yang sudah disimpan sebelumnya.

## 4. SQLite dalam Flutter

SQLite adalah database lokal yang lebih kuat dibanding `SharedPreferences`. SQLite sangat cocok untuk data yang lebih banyak dan lebih kompleks, seperti:

- catatan harian
- daftar transaksi
- data inventaris
- data mahasiswa
- aplikasi seperti buku tamu atau diary

Pada pertemuan 5, SQLite digunakan untuk membuat aplikasi catatan sederhana.

### Library yang digunakan

- `sqflite` untuk database SQLite
- `path` untuk menentukan lokasi database di perangkat

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
```

## 5. Struktur Model Catatan

Pada praktikum, dibuat model `Catatan` yang berisi:

```dart
class Catatan {
  final int? id;
  final String judul;
  final String isi;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
  });
}
```

Model ini digunakan untuk menampung data catatan yang akan disimpan ke database. Model juga dilengkapi dengan method:

- `toMap()` untuk mengubah object menjadi map sebelum disimpan ke SQLite
- `fromMap()` untuk mengubah hasil query database menjadi object `Catatan`

```dart
Map<String, Object?> toMap() {
  return {
    'id': id,
    'judul': judul,
    'isi': isi,
  };
}
```

## 6. Membuat Database SQLite

Database dibuat di helper class `DbHelper`.

```dart
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
```

### Fungsi di atas meliputi:

- inisialisasi database bila belum ada
- membuat file database `catatan.db`
- membuat tabel `catatan`
- definisi field tabel:
  - `id` sebagai primary key
  - `judul` sebagai teks
  - `isi` sebagai teks

## 7. CRUD pada SQLite

CRUD adalah singkatan dari:

- Create = menambah data
- Read = membaca data
- Update = mengubah data
- Delete = menghapus data

### a. Create

```dart
static Future<int> tambah(Catatan c) async {
  final db = await database;
  return db.insert('catatan', c.toMap());
}
```

### b. Read

```dart
static Future<List<Catatan>> semua() async {
  final db = await database;

  final rows = await db.query(
    'catatan',
    orderBy: 'id DESC',
  );

  return rows.map(Catatan.fromMap).toList();
}
```

### c. Update

```dart
static Future<int> ubah(Catatan c) async {
  final db = await database;

  return db.update(
    'catatan',
    c.toMap(),
    where: 'id = ?',
    whereArgs: [c.id],
  );
}
```

### d. Delete

```dart
static Future<int> hapus(int id) async {
  final db = await database;

  return db.delete(
    'catatan',
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

## 8. Aplikasi Catatan SQLite

Pada bagian B dan D, dibuat aplikasi Catatan Saya. Aplikasi ini memiliki fitur:

- tambah catatan baru
- menampilkan daftar catatan
- ubah catatan
- hapus catatan
- daftar catatan terlihat seperti list
- `FutureBuilder` untuk menampilkan data dari database

### Tampilan daftar catatan

```dart
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

    final data = snapshot.data ?? [];

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final catatan = data[index];
        return ListTile(
          title: Text(catatan.judul),
          subtitle: Text(catatan.isi),
        );
      },
    );
  },
)
```

### Penjelasan

- `FutureBuilder` memantau proses pengambilan data dari SQLite
- saat data sedang diproses, tampilkan loading indicator
- setelah data selesai dibaca, data ditampilkan ke `ListView`
- ketika catatan baru ditambah atau dihapus, `setState()` atau fungsi `_muat()` dipanggil untuk refresh tampilan

## 9. Form Tambah dan Ubah Catatan

Bagian D menambahkan form yang digunakan untuk menambahkan atau mengubah data catatan. Form ini dibuat dengan `Form` dan `TextFormField`.

```dart
final _formKey = GlobalKey<FormState>();
```

Fungsi ini digunakan untuk validasi form agar input tidak kosong.

### Contoh validasi

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Judul wajib diisi';
  }

  return null;
}
```

Dengan validasi ini, user tidak bisa menyimpan catatan jika judul atau isi kosong.

## 10. Navigasi antar Halaman

Pada aplikasi catatan, saat user menekan tombol tambah atau item catatan, aplikasi berpindah ke halaman form dengan `Navigator.push()`.

```dart
await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FormCatatanPage(catatan: catatan),
  ),
);
```

Setelah form selesai, aplikasi kembali ke halaman sebelumnya dan memuat ulang data.

## 11. Tugas Akhir: Pencatat Pengeluaran

Pada tugas, konsep yang dipelajari pada pertemuan 5 diterapkan dalam bentuk aplikasi pencatat pengeluaran. Aplikasi ini memiliki fitur:

- menyimpan data pengeluaran ke SQLite
- menampilkan total pengeluaran
- mengelompokkan berdasarkan kategori
- menambah, mengubah, dan menghapus data pengeluaran
- pengaturan mode gelap disimpan dengan `SharedPreferences`
- form input dengan validasi
- tanggal dipilih dengan `showDatePicker`
- tampilan daftar transaksi di `ListView`

### Model `Pengeluaran`

```dart
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;
}
```

### Database `DbPengeluaran`

Database dibuat dengan tabel `pengeluaran` dan field:

- `id`
- `nama`
- `jumlah`
- `kategori`
- `tanggal`

### Pengaturan mode gelap

Mode gelap diimplementasikan dengan `SharedPreferences`:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('mode_gelap', nilai);
```

Nilai ini dibaca saat aplikasi dibuka agar tema tetap sesuai preferensi user.

## 12. Kesimpulan

Pertemuan 5 membahas tentang penyimpanan data lokal dalam aplikasi Flutter. Mahasiswa belajar bahwa data tidak hanya bisa ditampilkan secara sementara di memori, tetapi juga dapat disimpan secara permanen di perangkat.

Materi yang dipelajari meliputi:

- `SharedPreferences` untuk data kecil seperti pengaturan aplikasi
- `SQLite` untuk data besar dan lebih kompleks
- CRUD untuk mengelola data
- `FutureBuilder` untuk menangani proses baca/tulis data
- validasi form agar input aman dan benar
- pengaturan tema yang tersimpan secara permanen

Dengan pemahaman ini, mahasiswa dapat membangun aplikasi yang lebih siap digunakan karena dapat menyimpan data secara local dan menjaga keadaan aplikasi tetap konsisten.

## 13. Ringkasan singkat

Pertemuan 5 menekankan pentingnya data lokal dalam aplikasi mobile. `SharedPreferences` cocok untuk konfigurasi sederhana, sedangkan SQLite digunakan untuk data yang lebih banyak dan lebih kompleks. Kombinasi keduanya memungkinkan aplikasi menyimpan pengaturan dan data pengguna secara permanen, sehingga pengalaman pengguna menjadi lebih baik serta aplikasi lebih siap untuk digunakan pada berbagai kondisi.
