# Doc Tugas - Pertemuan 4: Future, HTTP, dan Data API

Disusun oleh: Rizqi Bagas Wicaksono  
NIM: 20240801187

## 1. Tujuan Pembelajaran

Pada pertemuan 4, mahasiswa belajar bagaimana aplikasi Flutter dapat mengambil data dari server menggunakan protokol HTTP, memproses data dalam format JSON, serta menampilkannya dalam bentuk list dan halaman detail. Materi ini sangat penting karena aplikasi modern biasanya berinteraksi dengan API untuk menampilkan data dinamis.

Topik utama pada pertemuan ini adalah:

- konsep `Future` dan `async/await`
- penggunaan `FutureBuilder` untuk menangani proses asynchronous
- pengambilan data dari API dengan package `http`
- parsing JSON ke model class
- menampilkan data dalam `ListView` dan `ListTile`
- navigasi antar halaman dengan `Navigator.push()`
- menampilkan status loading, error, dan refresh data

## 2. Konsep Future dalam Flutter

`Future` adalah representasi dari nilai yang akan tersedia di masa depan. Dalam aplikasi Flutter, operasi yang membutuhkan waktu seperti koneksi jaringan atau membaca file sering kali dijalankan secara asynchronous.

Contoh sederhana dari modul:

```dart
Future<String> ambilSalam() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Halo dari masa depan!';
}
```

Penjelasan:

- `async` menandakan fungsi tersebut melakukan operasi asynchronous
- `await` menunggu proses selesai sebelum melanjutkan
- `Future.delayed` meniru proses yang membutuhkan waktu

Saat data belum tersedia, aplikasi tidak boleh langsung crash. Oleh karena itu digunakan `FutureBuilder` untuk menangani tiga kondisi utama:

- `ConnectionState.waiting` → sedang loading
- `snapshot.hasError` → terjadi error
- `snapshot.hasData` → data sudah diterima

## 3. FutureBuilder

`FutureBuilder` adalah widget yang membangun UI berdasarkan status dari `Future`.

```dart
body: FutureBuilder<List<Post>>(
  future: _future,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Text('Terjadi kesalahan'),
      );
    }

    final posts = snapshot.data ?? [];
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.body),
        );
      },
    );
  },
)
```

Dari kode di atas, dapat dilihat bahwa:

- `FutureBuilder` memantau status `Future` secara realtime
- UI berubah sesuai kondisi data
- `CircularProgressIndicator` ditampilkan saat loading
- pesan error ditampilkan jika request gagal
- data ditampilkan setelah berhasil diambil

## 4. Mengambil Data dari API

Pada modul, data diambil dari API JSONPlaceholder. Endpoint yang digunakan adalah:

- `https://jsonplaceholder.typicode.com/posts`
- `https://jsonplaceholder.typicode.com/comments`
- `https://jsonplaceholder.typicode.com/users`

Contoh fungsi pengambilan data:

```dart
Future<List<Post>> ambilPostingan() async {
  final uri = Uri.parse('$baseUrl/posts');

  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat postingan');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

### Penjelasan:

- `http.get(uri)` mengirim request ke server
- `.timeout(...)` mencegah proses menunggu terlalu lama
- `response.statusCode` mengecek apakah request berhasil
- `jsonDecode()` mengubah response dalam bentuk JSON menjadi objek Dart
- `map()` mengubah setiap item JSON menjadi model `Post`

## 5. Model Class untuk JSON

Untuk menjaga struktur data agar rapi, data JSON dipetakan ke class model.

Contoh `Post`:

```dart
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
```

Tujuan pembuatan model class adalah:

- memudahkan pengelolaan data
- menghindari data mentah yang sulit dibaca
- menjaga keamanan tipe data (`int`, `String`, dll.)
- mempermudah penggunaan data di UI

## 6. Menampilkan Data dalam ListView

Setelah data berhasil diambil, modul menampilkan data dalam `ListView.builder`.

```dart
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
      trailing: const Icon(Icons.chevron_right),
    );
  },
);
```

`ListView.builder` cocok digunakan ketika data bersifat dinamis dan jumlahnya bisa banyak. Keuntungannya:

- efisien dari sisi memori
- hanya widget yang terlihat yang dibuat
- cocok untuk daftar API yang panjang

## 7. Navigasi ke Halaman Detail

Saat item pada list ditekan, aplikasi berpindah ke halaman detail. Ini dilakukan dengan `Navigator.push()` dan `MaterialPageRoute`.

```dart
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
}
```

Fungsi dari navigasi ini adalah:

- membuka halaman baru yang menampilkan informasi lebih lengkap
- memisahkan tampilan daftar dan tampilan detail
- memberi pengalaman aplikasi yang lebih interaktif

## 8. Halaman Detail dengan Komentar

Pada halaman detail, selain menampilkan judul dan isi postingan, aplikasi juga mengambil komentar terkait berdasarkan `postId`.

```dart
Future<List<Komentar>> ambilKomentar(int postId) async {
  final uri = Uri.parse('$baseUrl/posts/$postId/comments');

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat komentar');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((e) => Komentar.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

Sistem ini membuat aplikasi mampu menampilkan:

- judul dan isi postingan utama
- daftar komentar yang terkait
- status loading saat komentar sedang dimuat
- opsi refresh untuk memuat ulang data

## 9. Fitur Refresh dan Error Handling

Pada modul juga diterapkan fitur refresh dan penanganan error.

```dart
void _muatUlang() {
  setState(() {
    _future = _apiService.ambilPostingan();
  });
}
```

Fungsi ini dipanggil ketika user menekan tombol refresh. Setelah itu, `setState()` membuat `Future` baru sehingga data akan dimuat ulang.

Selain itu, aplikasi juga menangani error seperti:

- jaringan tidak tersedia
- server tidak merespons
- format JSON tidak sesuai

Penerapan ini penting agar aplikasi tidak rusak saat terjadi masalah koneksi atau data tidak valid.

## 10. Penerapan di Praktikum 4

Modul praktikum mempraktikkan beberapa bentuk aplikasi:

### a. FutureBuilder dasar

Aplikasi sederhana yang menampilkan teks setelah delay 2 detik.

### b. API pengguna

Aplikasi menampilkan daftar pengguna dari API `jsonplaceholder`.

- data pengguna dibaca dari endpoint users
- model `Pengguna` dibuat untuk mapping JSON
- halaman detail menampilkan username, email, kota, telepon, dan website

### c. Aplikasi postingan dan komentar

Aplikasi yang lebih kompleks:

- daftar postingan
- detail postingan
- daftar komentar per postingan
- tombol refresh
- list item yang bisa diklik

## 11. Kesimpulan

Pertemuan 4 membahas konsep penting dalam pengembangan aplikasi Flutter modern, yaitu komunikasi dengan server melalui API. Mahasiswa belajar bahwa aplikasi tidak hanya menampilkan data statis, tetapi juga harus dapat mengambil, memproses, dan menampilkan data dinamis dari internet.

Poin penting yang dipelajari adalah:

- `Future` digunakan untuk proses asynchronous
- `async` dan `await` membantu menjalankan tugas yang membutuhkan waktu
- `FutureBuilder` sangat penting untuk mengubah UI berdasarkan status data
- `http` digunakan untuk request ke server
- `jsonDecode` mengubah JSON menjadi list atau map object
- `model class` mempermudah pengelolaan data
- `ListView.builder` digunakan untuk daftar data yang dinamis
- `Navigator` digunakan untuk navigasi antar halaman

Dengan memahami materi ini, mahasiswa siap untuk membangun aplikasi yang lebih interaktif dan berbasis data.

## 12. Ringkasan singkat

Pertemuan 4 menekankan bahwa Flutter dapat berinteraksi dengan internet dan memproses data real-time. Data dari API akan diperoleh, dikonversi ke model, dan ditampilkan ke user dalam bentuk list dan detail halaman. Ini adalah fondasi penting sebelum melanjutkan ke materi aplikasi yang lebih kompleks seperti login, CRUD, dan integrasi database.
