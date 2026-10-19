
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final savedMode = prefs.getInt('themeMode') ?? 0;
  final savedColor = prefs.getInt('seedColor');

  themeMode.value = savedMode >= 0 && savedMode < ThemeMode.values.length
      ? ThemeMode.values[savedMode]
      : ThemeMode.system;

  if (savedColor != null) {
    seedColor.value = Color(savedColor);
  }

  runApp(const MyApp());
}

// ================= TEMA DAN PREFERENSI =================

final ValueNotifier<ThemeMode> themeMode =
    ValueNotifier(ThemeMode.system);

final ValueNotifier<Color> seedColor =
    ValueNotifier(Colors.indigo);

final Map<String, Color> pilihanWarna = {
  'Indigo': Colors.indigo,
  'Teal': Colors.teal,
  'Oranye': Colors.deepOrange,
  'Pink': Colors.pink,
};

Future<void> simpanMode(ThemeMode mode) async {
  themeMode.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeMode', mode.index);
}

Future<void> simpanWarna(Color color) async {
  seedColor.value = color;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('seedColor', color.value);
}

ThemeData buatTema(Color warna, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: warna,
      brightness: brightness,
    ),
  );
}

// ================= MODEL KATALOG =================

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

const List<Item> daftarItem = [
  Item(
    nama: 'Flutter',
    kategori: 'Teknologi',
    deskripsi:
        'Flutter adalah framework untuk membangun aplikasi dari satu basis kode.',
    ikon: Icons.flutter_dash,
  ),
  Item(
    nama: 'Musik',
    kategori: 'Hiburan',
    deskripsi:
        'Musik dapat menemani aktivitas, belajar, dan waktu bersantai.',
    ikon: Icons.music_note,
  ),
  Item(
    nama: 'Kamera',
    kategori: 'Fotografi',
    deskripsi:
        'Kamera digunakan untuk mengabadikan momen melalui foto dan video.',
    ikon: Icons.camera_alt,
  ),
  Item(
    nama: 'Peta',
    kategori: 'Perjalanan',
    deskripsi:
        'Peta membantu pengguna memahami lokasi dan menemukan tujuan perjalanan.',
    ikon: Icons.map,
  ),
  Item(
    nama: 'Laptop',
    kategori: 'Teknologi',
    deskripsi:
        'Laptop dapat digunakan untuk belajar, bekerja, dan mengembangkan aplikasi.',
    ikon: Icons.laptop,
  ),
  Item(
    nama: 'Gunung',
    kategori: 'Wisata',
    deskripsi:
        'Gunung menjadi tujuan wisata alam untuk menikmati pemandangan dan mendaki.',
    ikon: Icons.landscape,
  ),
];

final ValueNotifier<Set<String>> favorit =
    ValueNotifier(<String>{});

void toggleFavorit(String nama) {
  favorit.value = {...favorit.value}
    ..remove(nama);

  // Jika sebelumnya tidak ada, tambahkan kembali.
  if (!favorit.value.contains(nama)) {
    favorit.value = {...favorit.value, nama};
  }
}

// ================= APLIKASI UTAMA =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Galeri Interaktif',
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          home: const ShellPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final arg = settings.arguments;

              if (arg is! Item) return null;

              return PageRouteBuilder(
                settings: settings,
                transitionDuration: const Duration(milliseconds: 450),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DetailPage(item: arg);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            }

            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const Halaman404(),
            );
          },
        );
      },
    );
  }
}

// ================= NAVIGASI UTAMA =================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  static const judul = ['Beranda', 'Favorit', 'Pengaturan'];

  void pindahTab(int nilai) {
    setState(() => index = nilai);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(judul[index]),
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
                        Icons.collections,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Galeri Interaktif',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Beranda'),
                selected: index == 0,
                onTap: () {
                  Navigator.pop(context);
                  pindahTab(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Favorit'),
                selected: index == 1,
                onTap: () {
                  Navigator.pop(context);
                  pindahTab(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Pengaturan'),
                selected: index == 2,
                onTap: () {
                  Navigator.pop(context);
                  pindahTab(2);
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Tentang aplikasi'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Galeri Interaktif',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Tugas Flutter Pertemuan 6',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: index,
        children: const [
          BerandaTab(),
          FavoritTab(),
          PengaturanTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: pindahTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
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

// ================= KARTU KATALOG =================

class KartuItem extends StatelessWidget {
  final Item item;

  const KartuItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: item,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'ikon-${item.nama}',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: warna.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        item.ikon,
                        size: 52,
                        color: warna.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.nama,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.kategori,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: favorit,
                  builder: (context, daftarFavorit, child) {
                    final aktif = daftarFavorit.contains(item.nama);

                    return IconButton(
                      tooltip: aktif
                          ? 'Hapus dari favorit'
                          : 'Tambahkan ke favorit',
                      onPressed: () => toggleFavorit(item.nama),
                      icon: Icon(
                        aktif ? Icons.favorite : Icons.favorite_border,
                        color: aktif ? warna.error : warna.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TAB BERANDA =================

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: warna.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.collections,
                size: 40,
                color: warna.onPrimaryContainer,
              ),
              const SizedBox(height: 12),
              Text(
                'Jelajahi Galeri',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: warna.onPrimaryContainer,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Temukan koleksi teknologi, hiburan, dan wisata.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: warna.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Koleksi Pilihan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daftarItem.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            return KartuItem(item: daftarItem[i]);
          },
        ),
      ],
    );
  }
}

// ================= TAB FAVORIT =================

class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorit,
      builder: (context, daftarFavorit, child) {
        final items = daftarItem
            .where((item) => daftarFavorit.contains(item.nama))
            .toList();

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada favorit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tekan ikon hati pada katalog untuk menyimpan favorit.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${items.length} item favorit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  leading: Hero(
                    tag: 'ikon-${item.nama}',
                    child: Icon(
                      item.ikon,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(item.nama),
                  subtitle: Text(item.kategori),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => toggleFavorit(item.nama),
                  ),
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
      },
    );
  }
}

// ================= HALAMAN DETAIL =================

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'ikon-${item.nama}',
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: warna.primaryContainer,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  item.ikon,
                  size: 100,
                  color: warna.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Chip(label: Text(item.kategori)),
          ),
          const SizedBox(height: 12),
          Text(
            item.nama,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            item.deskripsi,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorit,
            builder: (context, daftarFavorit, child) {
              final aktif = daftarFavorit.contains(item.nama);

              return FilledButton.icon(
                onPressed: () => toggleFavorit(item.nama),
                icon: Icon(
                  aktif ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  aktif ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Galeri'),
          ),
        ],
      ),
    );
  }
}

// ================= TAB PENGATURAN =================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final warnaTema = Theme.of(context).colorScheme;

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
                  mode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text('Mode Gelap'),
                subtitle: const Text('Simpan pilihan tema aplikasi'),
                value: mode == ThemeMode.dark,
                onChanged: (aktif) {
                  simpanMode(
                    aktif ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pilih Warna Aksen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Warna ini digunakan untuk menyesuaikan tampilan aplikasi.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<Color>(
              valueListenable: seedColor,
              builder: (context, warnaAktif, child) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: pilihanWarna.entries.map((entry) {
                    final aktif = entry.value == warnaAktif;

                    return InkWell(
                      onTap: () => simpanWarna(entry.value),
                      customBorder: const CircleBorder(),
                      child: Tooltip(
                        message: entry.key,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: entry.value,
                          child: aktif
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: warnaTema.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: warnaTema.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pratinjau Tema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Perubahan tema diterapkan pada halaman dan komponen aplikasi.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================= ANIMASI =================

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool besar = false;
  bool terlihat = true;
  int angka = 0;

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Demo Animasi',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),

        Text(
          '1. AnimatedContainer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: besar ? 180 : 110,
            height: besar ? 130 : 90,
            decoration: BoxDecoration(
              color: warna.primary,
              borderRadius: BorderRadius.circular(besar ? 32 : 12),
            ),
            child: Icon(
              Icons.animation,
              color: warna.onPrimary,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => setState(() => besar = !besar),
          child: const Text('Ubah Bentuk'),
        ),

        const Divider(height: 32),

        Text(
          '2. AnimatedSwitcher',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
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
              '$angka',
              key: ValueKey<int>(angka),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () => setState(() => angka++),
          child: const Text('Tambah Angka'),
        ),

        const Divider(height: 32),

        Text(
          '3. AnimatedOpacity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: terlihat ? 1 : 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(
                  Icons.flutter_dash,
                  size: 64,
                  color: warna.primary,
                ),
              ),
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () => setState(() => terlihat = !terlihat),
          child: Text(terlihat ? 'Sembunyikan Kartu' : 'Tampilkan Kartu'),
        ),

        const Divider(height: 32),

        Text(
          '4. RotationTransition',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: RotationTransition(
            turns: controller,
            child: Icon(
              Icons.settings,
              size: 80,
              color: warna.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            setState(() {
              if (controller.isAnimating) {
                controller.stop();
              } else {
                controller.repeat();
              }
            });
          },
          child: Text(
            controller.isAnimating ? 'Berhenti' : 'Putar Kembali',
          ),
        ),
      ],
    );
  }
}

// ================= HALAMAN 404 =================

class Halaman404 extends StatelessWidget {
  const Halaman404({super.key});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

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
                color: warna.error,
              ),
              const SizedBox(height: 12),
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
