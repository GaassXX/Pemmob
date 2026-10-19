
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

// ==================== MODEL ITEM ====================

class Item {
  final String nama;
  final IconData ikon;
  final Color warna;

  const Item(this.nama, this.ikon, this.warna);
}

const daftarItem = [
  Item('Flutter', Icons.flutter_dash, Colors.blue),
  Item('Musik', Icons.music_note, Colors.pink),
  Item('Kamera', Icons.camera_alt, Colors.orange),
  Item('Peta', Icons.map, Colors.green),
];

// ==================== MAIN ====================

void main() {
  runApp(const MyApp());
}

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
          home: const ShellPage(),
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

// ==================== BAGIAN D: SHELL / TAB BAWAH ====================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [
    BerandaTab(),
    AnimasiTab(),
    PengaturanTab(),
  ];

  static const _judul = [
    'Beranda',
    'Animasi',
    'Pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: _halaman,
      ),
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
      ),
    );
  }
}

// ==================== BERANDA ====================

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: daftarItem.length,
      itemBuilder: (context, index) {
        final item = daftarItem[index];

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

// ==================== HALAMAN DETAIL ====================

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

// ==================== PENGATURAN TEMA ====================

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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Atur tampilan aplikasi sesuai keinginan.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Mode gelap'),
              subtitle: const Text('Aktifkan tema gelap'),
              secondary: const Icon(Icons.dark_mode),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (value) {
                themeMode.value = value
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final warna in pilihanWarna)
                  GestureDetector(
                    onTap: () {
                      seedColor.value = warna;
                    },
                    child: CircleAvatar(
                      radius: 28,
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

// ==================== ANIMASI ====================

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  int _hitung = 0;

  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();

    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '1. AnimatedContainer',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 200 : 100,
            height: 100,
            decoration: BoxDecoration(
              color: _besar ? warna.primary : warna.tertiary,
              borderRadius: BorderRadius.circular(
                _besar ? 50 : 8,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.animation,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _besar = !_besar;
              });
            },
            child: const Text('Ubah bentuk'),
          ),
        ),
        const Divider(height: 32),
        Text(
          '2. AnimatedSwitcher',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animasi) {
              return ScaleTransition(
                scale: animasi,
                child: child,
              );
            },
            child: Text(
              '$_hitung',
              key: ValueKey(_hitung),
              style: tema.textTheme.displayMedium,
            ),
          ),
        ),
        Center(
          child: FilledButton(
            onPressed: () {
              setState(() {
                _hitung++;
              });
            },
            child: const Text('Tambah angka'),
          ),
        ),
        const Divider(height: 32),
        Text(
          '3. AnimationController',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: RotationTransition(
            turns: _putar,
            child: Icon(
              Icons.settings,
              size: 72,
              color: warna.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.tonal(
            onPressed: () {
              if (_putar.isAnimating) {
                _putar.stop();
              } else {
                _putar.repeat();
              }

              setState(() {});
            },
            child: Text(
              _putar.isAnimating ? 'Berhenti' : 'Putar',
            ),
          ),
        ),
      ],
    );
  }
}
