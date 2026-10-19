# Doc Tugas - Pertemuan 6: Tema, Navigasi, dan Animasi pada Flutter

Disusun oleh: Rizqi Bagas Wicaksono  
NIM: 20240801187

## 1. Tujuan Pembelajaran

Pada pertemuan 6, mahasiswa mempelajari bagaimana membuat aplikasi yang tidak hanya berfungsi dengan baik, tetapi juga memiliki tampilan yang menarik dan interaktif. Materi ini fokus pada beberapa konsep penting dalam Flutter, yaitu:

- pengaturan tema aplikasi
- penggunaan `ValueNotifier` untuk update state yang cepat
- route dan navigasi antar halaman
- penggunaan `Hero` untuk animasi transisi antar widget
- `NavigationBar` untuk tab bawah
- animasi seperti `AnimatedContainer`, `AnimatedSwitcher`, dan `RotationTransition`

Tujuan utama dari pertemuan ini adalah agar mahasiswa dapat membuat UI yang lebih modern, dinamis, dan user-friendly.

## 2. Pengaturan Tema Aplikasi

Tema dalam Flutter dapat diatur dengan menggunakan `ThemeData`. Tema ini berfungsi untuk menentukan tampilan umum aplikasi seperti warna, font, pencahayaan, serta styling komponen.

### Contoh kode

```dart
ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}
```

Dari kode tersebut dapat dilihat bahwa:

- `colorSchemeSeed` digunakan untuk menentukan warna utama aplikasi
- `brightness` menentukan apakah tema terang atau gelap
- `useMaterial3: true` menggunakan desain Material 3
- `appBarTheme` mengatur style AppBar secara global

### Penggunaan mode gelap dan terang

Pada praktikum, mode gelap diubah melalui `SwitchListTile`:

```dart
SwitchListTile(
  title: const Text('Mode gelap'),
  value: themeMode.value == ThemeMode.dark,
  onChanged: (v) {
    themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
  },
)
```

Ketika `themeMode.value` berubah, maka `MaterialApp` akan membangun ulang tema sesuai dengan nilai yang dipilih.

## 3. ValueNotifier untuk Reaktivitas UI

Pada pertemuan ini, konsep `ValueNotifier` digunakan untuk menyimpan state tema dan warna aplikasi.

```dart
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);
```

`ValueNotifier` berguna untuk memberi tahu widget bahwa ada perubahan data, sehingga UI dapat dibangun ulang secara otomatis.

### Keunggulan `ValueNotifier`

- lebih sederhana untuk state kecil
- mudah digunakan untuk tema dan pengaturan
- cocok ketika perubahan data hanya terjadi pada sebagian widget

### Penggunaan bersama `ListenableBuilder`

```dart
return ListenableBuilder(
  listenable: Listenable.merge([
    themeMode,
    seedColor,
  ]),
  builder: (context, _) {
    return MaterialApp(
      theme: buatTema(seedColor.value, Brightness.light),
      darkTheme: buatTema(seedColor.value, Brightness.dark),
      themeMode: themeMode.value,
    );
  },
);
```

`ListenableBuilder` akan mendengarkan perubahan dari `themeMode` dan `seedColor`, lalu rebuild widget `MaterialApp` ketika kondisi berubah.

## 4. Navigasi Antar Halaman

Navigasi adalah bagian penting dalam aplikasi mobile. Flutter memiliki beberapa cara navigasi seperti:

- `Navigator.push()`
- `Navigator.pushNamed()`
- `MaterialPageRoute`
- `routes` dan `onGenerateRoute`

### Routing dengan named route

Pada modul, halaman detail dibuka dengan route bernama `/detail`:

```dart
Navigator.pushNamed(
  context,
  '/detail',
  arguments: item,
);
```

Lalu route ditangani dengan `onGenerateRoute`:

```dart
onGenerateRoute: (settings) {
  if (settings.name == '/detail') {
    final item = settings.arguments as Item;

    return MaterialPageRoute(
      builder: (_) => DetailPage(item: item),
      settings: settings,
    );
  }

  return null;
}
```

Fungsi dari routing adalah:

- memisahkan halaman agar lebih rapi
- memudahkan proses navigasi
- membangun aplikasi yang lebih terstruktur

## 5. Hero Animation

Hero animation adalah efek transisi ketika widget berpindah dari satu halaman ke halaman lain dengan elemen yang sama. Dalam modul, ikon dari daftar item bergerak dari halaman beranda ke halaman detail.

```dart
Hero(
  tag: 'ikon-${item.nama}',
  child: CircleAvatar(
    backgroundColor: item.warna,
    child: Icon(item.ikon),
  ),
)
```

Pada halaman detail, widget yang sama dibuat kembali dengan tag yang sama. Karena tag-nya sama, Flutter akan melakukan animasi smooth dari satu layar ke layar lainnya.

### Keuntungan Hero animation

- membuat navigasi terlihat lebih halus
- menambah kesan interaktif pada aplikasi
- mempermudah fokus user pada objek tertentu

## 6. Bottom Navigation / NavigationBar

Pada bagian D, aplikasi dibuat dengan `NavigationBar` sebagai tab bawah. Fungsinya adalah membuat navigasi cepat antar menu utama seperti:

- Beranda
- Animasi
- Pengaturan

Contoh implementasi:

```dart
bottomNavigationBar: NavigationBar(
  selectedIndex: _index,
  onDestinationSelected: (i) {
    setState(() {
      _index = i;
    });
  },
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.animation),
      label: 'Animasi',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Pengaturan',
    ),
  ],
)
```

`IndexedStack` digunakan untuk menjaga state halaman agar tidak dibangun ulang terlalu sering saat berpindah tab.

## 7. AnimatedContainer

`AnimatedContainer` adalah widget yang dapat berubah bentuk, ukuran, warna, atau radius secara animasi ketika propertinya berubah.

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  width: _besar ? 200 : 100,
  height: 100,
  decoration: BoxDecoration(
    color: _besar ? warna.primary : warna.tertiary,
    borderRadius: BorderRadius.circular(_besar ? 50 : 8),
  ),
)
```

### Fungsi

- membuat perubahan visual menjadi lebih halus
- memberikan feedback kepada user saat melakukan interaksi
- mempercantik UI tanpa harus menulis animasi yang rumit

## 8. AnimatedSwitcher

`AnimatedSwitcher` digunakan untuk membuat transisi saat widget berubah, misalnya nilai angka atau tampilan lain.

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  },
  child: Text(
    '$_hitung',
    key: ValueKey(_hitung),
    style: tema.textTheme.displayMedium,
  ),
)
```

Setiap kali angka berubah, widget `Text` akan dibuat ulang dengan key baru, lalu animasi scale akan berjalan.

## 9. RotationTransition dan AnimationController

`AnimationController` digunakan untuk mengontrol animasi yang lebih kompleks seperti rotasi.

```dart
late final AnimationController _putar;

_putar = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 2),
)..repeat();
```

Lalu dibuat widget rotasi dengan:

```dart
RotationTransition(
  turns: _putar,
  child: Icon(
    Icons.settings,
    size: 72,
    color: warna.primary,
  ),
)
```

Fungsi dari animasi ini adalah untuk membuat komponen seperti ikon atau elemen dekoratif bergerak secara berulang sehingga tampilan lebih hidup.

## 10. AnimatedOpacity

`AnimatedOpacity` digunakan untuk membuat efek fade in dan fade out.

```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 500),
  opacity: terlihat ? 1 : 0,
  child: Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Icon(Icons.flutter_dash),
    ),
  ),
)
```

Efek ini sering digunakan untuk menyembunyikan atau menampilkan elemen dengan transisi yang lebih halus.

## 11. Aplikasi Tugas Akhir: Galeri Interaktif

Pada tugas, semua materi di atas digabungkan menjadi satu aplikasi bernama Galeri Interaktif. Aplikasi ini memiliki fitur-fitur berikut:

- halaman beranda dengan grid item
- halaman favorit
- halaman pengaturan
- mode gelap dan warna aksen yang dapat dipilih
- tombol favorit untuk menambahkan item ke daftar favorit
- detail item dengan hero animation
- navigasi dengan `NavigationBar` dan `Drawer`
- animasi visual untuk mempercantik aplikasi

### Model `Item`

```dart
class Item {
  final String nama;
  final String kategori;
  final String deskripsi;
  final IconData ikon;

  const Item({
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.ikon,
  });
}
```

Model ini berfungsi untuk menyimpan data katalog seperti nama, kategori, deskripsi, dan ikon.

### Pengaturan tema yang disimpan

Tugas ini juga menyimpan pengaturan tema ke `SharedPreferences`, sehingga saat aplikasi dibuka lagi, pilihan tema dan warna tetap tersimpan.

```dart
Future<void> simpanMode(ThemeMode mode) async {
  themeMode.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeMode', mode.index);
}
```

## 12. Kesimpulan

Pertemuan 6 membahas bagaimana membuat aplikasi Flutter yang tidak hanya fungsional, tetapi juga menarik secara visual dan interaktif. Mahasiswa mempelajari bagaimana tema, navigasi, dan animasi dapat diimplementasikan untuk menghasilkan pengalaman pengguna yang lebih baik.

Poin utama dari pertemuan ini adalah:

- tema aplikasi dapat diatur dengan `ThemeData`
- `ValueNotifier` memudahkan UI mengikuti perubahan state
- `Navigator` dan route membantu berpindah antar halaman
- `Hero` membuat transisi antar layar lebih halus
- `NavigationBar` mempermudah navigasi tab bawah
- animasi seperti `AnimatedContainer`, `AnimatedSwitcher`, dan `RotationTransition` membuat UI lebih hidup

Dengan memahami konsep ini, mahasiswa dapat membangun aplikasi dengan tampilan yang lebih modern dan interaktif sesuai kebutuhan pengguna.

## 13. Ringkasan singkat

Pertemuan 6 menekankan bahwa desain aplikasi dan interaksi pengguna sangat penting dalam pengembangan mobile. Flutter menyediakan banyak fitur seperti tema, route, hero animation, navigation bar, dan animasi yang dapat memperindah UI sekaligus meningkatkan pengalaman pengguna. Kombinasi dari semua itu membuat aplikasi terasa lebih profesional dan modern.
