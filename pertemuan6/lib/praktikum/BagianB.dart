import 'package:flutter/material.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

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

void main() {
  runApp(const MyApp());
}

// MODEL DATA
class Item {
  final String nama;
  final IconData ikon;
  final Color warna;

  const Item(this.nama, this.ikon, this.warna);
}

// DATA ITEM
const daftarItem = [
  Item('Flutter', Icons.flutter_dash, Colors.blue),
  Item('Musik', Icons.music_note, Colors.pink),
  Item('Kamera', Icons.camera_alt, Colors.orange),
  Item('Peta', Icons.map, Colors.green),
];

// APLIKASI UTAMA
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,

          // ROUTING
          initialRoute: '/',
          routes: {
            '/': (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Beranda'),
                  ),
                  body: const BerandaTab(),
                ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item = settings.arguments as Item;

              return MaterialPageRoute(
                builder: (_) => DetailPage(item: item),
                settings: settings,
              );
            }

            return null;
          },
        );
      },
    );
  }
}

// HALAMAN BERANDA
class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: daftarItem.length,
      itemBuilder: (context, i) {
        final item = daftarItem[i];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Hero(
              tag: 'ikon-${item.nama}',
              child: CircleAvatar(
                backgroundColor: item.warna,
                child: Icon(
                  item.ikon,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(item.nama),
            subtitle: Text('Lihat detail ${item.nama}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: item,
              );
            },
          ),
        );
      },
    );
  }
}

// HALAMAN DETAIL
class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.nama),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ikon-${item.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: item.warna,
                child: Icon(
                  item.ikon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.nama,
              style: tema.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Detail untuk ${item.nama}',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

// PENGATURAN TEMA DARI BAGIAN A
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                for (final warna in pilihanWarna)
                  GestureDetector(
                    onTap: () => seedColor.value = warna,
                    child: CircleAvatar(
                      backgroundColor: warna,
                      child: seedColor.value == warna
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
