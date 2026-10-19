import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  themeMode.value = ThemeMode.values[
      (prefs.getInt('themeMode') ?? ThemeMode.system.index)
          .clamp(0, ThemeMode.values.length - 1)];

  final savedColor = prefs.getInt('seedColor');
  if (savedColor != null) {
    seedColor.value = Color(savedColor);
  }

  themeMode.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.value.index);
  });

  seedColor.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', seedColor.value.value);
  });

  runApp(const MyApp());
}

// ==================== TEMA GLOBAL ====================

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

final ValueNotifier<Color> seedColor = ValueNotifier(Colors.indigo);

final Map<String, Color> pilihanWarna = {
  'Indigo': Colors.indigo,
  'Teal': Colors.teal,
  'Oranye': Colors.deepOrange,
  'Pink': Colors.pink,
};

ThemeData buatTema(Color warna) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: warna),
  );
}

// ==================== MODEL DAN DATA ====================

class Item {
  final String nama;
  final String deskripsi;
  final IconData ikon;
  final Color warna;

  const Item({
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
  });
}

const List<Item> daftarItem = [
  Item(
    nama: 'Flutter',
    deskripsi: 'Framework untuk membuat aplikasi multiplatform.',
    ikon: Icons.flutter_dash,
    warna: Colors.blue,
  ),
  Item(
    nama: 'Musik',
    deskripsi: 'Kumpulan musik favorit untuk menemani aktivitas.',
    ikon: Icons.music_note,
    warna: Colors.purple,
  ),
  Item(
    nama: 'Kamera',
    deskripsi: 'Fitur untuk mengambil dan menyimpan foto.',
    ikon: Icons.camera_alt,
    warna: Colors.orange,
  ),
  Item(
    nama: 'Peta',
    deskripsi: 'Membantu pengguna menemukan lokasi tujuan.',
    ikon: Icons.map,
    warna: Colors.green,
  ),
];

// ==================== APLIKASI UTAMA ====================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Fundamental',
          theme: buatTema(seedColor.value),
          darkTheme: buatTema(seedColor.value).copyWith(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor.value,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeMode.value,
          home: const ShellPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final argument = settings.arguments;

              if (argument is! Item) {
                return null;
              }

              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DetailPage(item: argument);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              );
            }

            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const Halaman404(),
              settings: settings,
            );
          },
        );
      },
    );
  }
}

// ==================== SHELL DAN DRAWER ====================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  final List<Widget> _halaman = const [
    BerandaTab(),
    AnimasiTab(),
    PengaturanTab(),
  ];

  final List<String> _judul = [
    'Beranda',
    'Animasi',
    'Pengaturan',
  ];

  void _pindahHalaman(int index) {
    setState(() {
      _index = index;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flutter_dash,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Flutter Fundamental',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Beranda'),
                selected: _index == 0,
                onTap: () => _pindahHalaman(0),
              ),
              ListTile(
                leading: const Icon(Icons.animation),
                title: const Text('Animasi'),
                selected: _index == 1,
                onTap: () => _pindahHalaman(1),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                selected: _index == 2,
                onTap: () => _pindahHalaman(2),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Tentang Aplikasi'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Flutter Fundamental',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Tugas Praktikum Flutter',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: _halaman,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.animation_outlined),
            selectedIcon: Icon(Icons.animation),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Galeri Katalog',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Pilih salah satu item untuk melihat detailnya.'),
        const SizedBox(height: 16),
        ...daftarItem.map(
          (item) => Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  backgroundColor: item.warna.withOpacity(0.15),
                  child: Icon(item.ikon, color: item.warna),
                ),
              ),
              title: Text(item.nama),
              subtitle: Text(item.deskripsi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: item,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== DETAIL ITEM ====================

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.nama),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: item.warna.withOpacity(0.15),
                  child: Icon(
                    item.ikon,
                    size: 70,
                    color: item.warna,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item.nama,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                item.deskripsi,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
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
      ),
    );
  }
}

// ==================== PENGATURAN TEMA ====================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan Tampilan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, child) {
              return SwitchListTile(
                secondary: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Mode Gelap'),
                subtitle: const Text('Simpan pilihan tema secara otomatis'),
                value: mode == ThemeMode.dark,
                onChanged: (aktif) {
                  themeMode.value = aktif ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Warna Tema',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pilihanWarna.entries.map((entry) {
                return ValueListenableBuilder<Color>(
                  valueListenable: seedColor,
                  builder: (context, warnaAktif, child) {
                    final terpilih = warnaAktif == entry.value;

                    return Tooltip(
                      message: entry.key,
                      child: InkWell(
                        onTap: () {
                          seedColor.value = entry.value;
                        },
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: entry.value,
                          child: terpilih
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tema dan warna akan tetap tersimpan saat aplikasi dibuka kembali.',
        ),
      ],
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
  bool _terlihat = true;
  int _hitung = 0;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Demo Animasi',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),

        // AnimatedContainer
        Text(
          '1. AnimatedContainer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 180 : 110,
            height: _besar ? 130 : 90,
            decoration: BoxDecoration(
              color: _besar ? Colors.deepOrange : warna,
              borderRadius: BorderRadius.circular(_besar ? 32 : 12),
            ),
            child: const Icon(
              Icons.animation,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            setState(() {
              _besar = !_besar;
            });
          },
          child: const Text('Ubah Bentuk'),
        ),

        const Divider(height: 32),

        // AnimatedSwitcher
        Text(
          '2. AnimatedSwitcher',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              '$_hitung',
              key: ValueKey<int>(_hitung),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            setState(() {
              _hitung++;
            });
          },
          child: const Text('Tambah Angka'),
        ),

        const Divider(height: 32),

        // AnimatedOpacity
        Text(
          '3. AnimatedOpacity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _terlihat ? 1 : 0,
            child: Icon(
              Icons.flutter_dash,
              size: 90,
              color: warna,
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            setState(() {
              _terlihat = !_terlihat;
            });
          },
          child: Text(_terlihat ? 'Sembunyikan Ikon' : 'Tampilkan Ikon'),
        ),

        const Divider(height: 32),

        // RotationTransition
        Text(
          '4. RotationTransition',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.settings,
              size: 90,
              color: warna,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            if (_controller.isAnimating) {
              _controller.stop();
            } else {
              _controller.repeat();
            }
            setState(() {});
          },
          child: Text(
            _controller.isAnimating ? 'Berhenti' : 'Putar Kembali',
          ),
        ),
      ],
    );
  }
}

// ==================== HALAMAN 404 ====================

class Halaman404 extends StatelessWidget {
  const Halaman404({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '404',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Maaf, halaman yang kamu cari tidak tersedia.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShellPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
